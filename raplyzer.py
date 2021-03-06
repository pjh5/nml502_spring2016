# -*- coding: utf-8 -*-
import codecs
import re
import numpy as np
import os
import heapq
import datetime as dt
import json
import csv
import sys

from lyrics import Lyrics

def read_lyrics(lyrics_dir='lyrics', 
				print_stats=False, language='en-us', lookback=30):
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

	# Set up CSV file to add the stats of each song to
	with open('raplyzer_out.csv', 'wb') as csvfile:
		csvwriter = csv.writer(csvfile, delimiter=',', lineterminator='\n',
								quotechar='|', quoting=csv.QUOTE_MINIMAL)
		csvwriter.writerow(["Artist", "Song", "Longest Rhyme Length", "Average Rhyme"])

	for a in os.listdir(lyrics_dir):
		print "Analyzing artist: %s" % a

		songs = os.listdir(lyrics_dir + '/' + a)
		songs = [s for s in songs if len(s) > 4 and s[-4:]=='.txt']
		for song in songs:
			file_name = lyrics_dir + '/' + a + '/' + song
			try:
				l = Lyrics(file_name, print_stats=print_stats, language='en-us', lookback=lookback)
				long_r = l.get_longest_rhyme()
				avg_r = l.get_avg_rhyme_length()
				print "\n%s -- %s" % (a, song)

			# Exception reading the file, scrap it and move on
			except:
				print 'Exception reading file ', file_name
				print '\tException: %s' % sys.exc_info()[0]
				long_r = (-1, "")
				avg_r = -1

			# Song file succesfully read
			# Calculate all the statistics we want
			else:
				# Calculate word statistics
				# text = l.text_orig.lower()
				# rx = re.compile(u'[^\wåäö]+')
				# text = rx.sub(' ', text)
				# all_words = text.split()
				# n_uwords = len(set(all_words))
				# n_words = len(all_words)
				# per_uwords = n_uwords / float(n_words)

				# Add the statistics to the csv file
				with open('raplyzer_out.csv', 'ab') as csvfile:
					csvwriter = csv.writer(csvfile, delimiter=',',
											quotechar='|', quoting=csv.QUOTE_MINIMAL)
					csvwriter.writerow([a, song, long_r[0], avg_r])
		

def main():
	# Analyze lyrics of all available artists (English)
	read_lyrics(lookback=15)

if __name__ == '__main__':
	main()
