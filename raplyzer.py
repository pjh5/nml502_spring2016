# -*- coding: utf-8 -*-
import codecs
import re
import numpy as np
import os
import heapq
import datetime as dt
import json
import csv

from lyrics import Lyrics

def read_lyrics(lyrics_dir='lyrics_en', artist=None, album=None, 
                print_stats=False, language='en-us', lookback=15):
    '''
    Read lyrics and compute Rhyme factor (riimikerroin) for each
    artist.

    Input:
        lyrics_dir  Path to the directory containing the lyrics.
        artist      Name of the artist directory under lyrics_dir (if this is
                    not provided, all artists are analyzed).
        album       Name of the album directory under lyrics_dir/artist/
        print_stats Whether we print summary statistics for each individual
                    song.
        language    Use either Finnish (fi), American English (en-us), 
                    or English (en).
        lookback    How many previous words are checked for rhymes. For
                    Finnish I've used 10 and for English 15.
    '''
    
    with open('raplyzer_out.csv', 'wb') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        csvwriter.writerow(["Artist", "Song", "Longest Rhyme Length", "Average Rhyme", "Word Count", "Unique Word Count", "Percent Unique"])
    
    if artist is not None:
        artists = [artist]
    else:
        artists = os.listdir(lyrics_dir)
    artist_scores = []
    song_scores = []
    song_names = []
    uniq_words = []
    longest_rhymes = []
    max_rhymes = 5
    for a in artists:
        print "Analyzing artist: %s" % a
        rls = []
        all_words = []
        if album is not None:
            albums = [album]
        else:
            albums = os.listdir(lyrics_dir+'/'+a)
        for al in albums:
            try:
                album_rls = []
                songs = os.listdir(lyrics_dir+'/'+a+'/'+al)
                # Only the .txt files
                songs = [s for s in songs if len(s)>=4 and s[-4:]=='.txt']
                for song in songs:
                    file_name = lyrics_dir+'/'+a+'/'+al+'/'+song
                    try:
                        l = Lyrics(file_name, print_stats=print_stats, 
                               language=language, lookback=lookback)
                        long_r = l.get_longest_rhyme()
                        avg_r = l.get_avg_rhyme_length()
                    except:
                      print 'Exception reading file ', file_name
                      long_r = (-1, "")
                      avg_r = -1
                    else:
                        rl = l.get_avg_rhyme_length()
                        rls.append(rl)
                        song_scores.append(rl)
                        song_names.append(file_name)
                        album_rls.append(rl)
                        if len(longest_rhymes) < max_rhymes:
                            heapq.heappush(longest_rhymes, l.get_longest_rhyme())
                        else:
                            heapq.heappushpop(longest_rhymes, l.get_longest_rhyme())

                        if language == 'fi':
                            all_words += l.text.split()
                        else:
                            text = l.text_orig.lower()
                            rx = re.compile(u'[^\wåäö]+')
                            text = rx.sub(' ', text)
                            all_words += text.split()
                            
                        # Print song statistics
                        n_uwords = len(set(text))
                        n_words = len(text)
                        per_uwords = n_uwords / float(n_words)
                        # print "%s - %s - %s:" % (a, al, song)
                        # print "\tLongest Rhyme  : %d" % long_r[0]
                        # print "\tAverage Rhyme  : %.3f" % avg_r
                        # print "\tNumber Words   : %d" % n_words
                        # print "\tUnique Words   : %d" % n_uwords
                        # print "\tPercent Unique : %.3f" % per_uwords
                        # print "\n"
                        with open('raplyzer_out.csv', 'a') as csvfile:
                            csvwriter = csv.writer(csvfile, delimiter=',',
                                                    quotechar='|', quoting=csv.QUOTE_MINIMAL)
                            csvwriter.writerow([al, song, long_r[0], avg_r, n_words, n_uwords, per_uwords])
              
                # Print stats for the album
                print "%s - %s: %.3f" % (a, al, np.mean(np.array(album_rls)))
                print "%.5f" % (np.mean(np.array(album_rls)))
            except:
                print "Unable to read album %s" % al
        # Compute the number of unique words the artist has used
        n_words = len(all_words)
        min_w = 20000
        if n_words >= min_w:
            n_uniq_words = len(set(all_words[:min_w]))
            uniq_words.append(n_uniq_words)
        else:
            uniq_words.append(-n_words)
        mean_rl = np.mean(np.array(rls))
        artist_scores.append(mean_rl)

    # Sort the artists based on their avg rhyme lengths
    artist_scores = np.array(artist_scores)
    artists = np.array(artists)
    uniq_words = np.array(uniq_words)
    order = np.argsort(artist_scores)[::-1]
    artists = artists[order]
    uniq_words = uniq_words[order]
    artist_scores = artist_scores[order]

    print "\nBest rhymes"
    while len(longest_rhymes) > 0:
        l, rhyme = heapq.heappop(longest_rhymes)
        print rhyme

    print "\nBest songs:"
    song_scores = np.array(song_scores)
    song_names = np.array(song_names)
    song_names = song_names[np.argsort(song_scores)[::-1]]
    song_scores = sorted(song_scores)[::-1]
    for i in range(len(song_scores)):
        print '%.3f\t%s' % (song_scores[i], song_names[i])

    print "\nBest artists:"
    for i in range(len(artist_scores)):
        rx = re.compile(u'_')
        name = rx.sub(' ', artists[i])
        print '%d.\t%.3f\t%s' % (i+1, artist_scores[i], name)
        

def main():
    # Analyze lyrics of all available artists (English)
    read_lyrics(lyrics_dir='lyrics_en', language='en-us', lookback=15)
    # Analyze lyrics of Paleface (English)
    #read_lyrics(lyrics_dir='lyrics_en', artist='Paleface', print_stats=True, language='en-us', lookback=15)


    # Analyze lyrics of all available artists (Finnish)
    #read_lyrics(lyrics_dir='lyrics', language='fi', lookback=10)
    # Analyze lyrics of Paleface (Finnish)
    #read_lyrics(lyrics_dir='lyrics', artist='Paleface', language='fi', lookback=10)

if __name__ == '__main__':
    main()
