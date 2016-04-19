import os
import re
import porter_stemmer
from nltk.corpus import stopwords
import operator
import csv

def main():
	
	# Directory name of lyrics folder
	lyrics_dir = 'lyrics'
	
	# Minimum frequency of word recorded
	MIN_COUNT = 50
	
	# Word Counts
	global_counts = {}
	artist_counts = {}
	song_counts = {}
	
	# Stop words from NLTK
	p = porter_stemmer.PorterStemmer()
	english_stops = [p.stem(w, 0, len(w)-1) for w in stopwords.words('english')]
	
	# Read all files
	for artist in os.listdir(lyrics_dir):
		
		print 'Processing artist ', artist
		artist_counts[artist] = {}
		
		for song in [s for s in os.listdir(lyrics_dir + '/' + artist) if s[-4:]=='.txt']:
			
			print '\tProcessing song ', song
			song_counts[song] = {}
			
			# Read file and process lyrics
			lyrics = open(lyrics_dir + '/' + artist + '/' + song).read()
			words = process_lyrics(lyrics)
			
			# Collect all words into a huge text file
			with open("allwords.txt", "a") as wordfile:
				wordfile.write(' '.join(words))
			
			# Add words to all dictionaries
			for word in words:
				if (word not in english_stops):
					add_to_count(global_counts, word)
					add_to_count(artist_counts[artist], word)
					add_to_count(song_counts[song], word)
	
	# Sort word counts by usage
	top_global = sorted(global_counts.items(), key=operator.itemgetter(1), reverse=True)
	top_global = [wordcount for wordcount in top_global if wordcount[1] > MIN_COUNT];
	
	# Debugging
	# print '\n\nArtist keys: ', artist_counts.keys()
	# print '\n\nSong keys: ', song_counts.keys()
	# print '\n\nWords: ', [wc[0] for wc in top_global]
	
	# Write global word counts
	with open('stemmed_all.csv', 'wb') as csvfile:
		csvwriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
		for i in range(len(top_global)):
			csvwriter.writerow([top_global[i][0], top_global[i][1]])
	
	# Write artist word counts
	with open('stemmed_artist.csv', 'wb') as csvfile:
		csvwriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
		
		# Write header
		csvwriter.writerow(['Artist'] + [word_key[0] for word_key in top_global])
		
		# Write artist
		for artist in artist_counts.keys():
			csvwriter.writerow([artist] + [artist_counts[artist].get(wc[0], 0) for wc in top_global])
	
	# Write song word counts
	with open('stemmed_song.csv', 'wb') as csvfile:
		csvwriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
		
		# Write header
		csvwriter.writerow(['Song'] + [word_key[0] for word_key in top_global])
		
		# Write song
		for song in song_counts.keys():
			csvwriter.writerow([song] + [song_counts[song].get(wc[0], 0) for wc in top_global])



def process_lyrics(lyrics):
	
	# Substitutions
	lyrics = lyrics.lower()
	lyrics = re.sub('\\s', lambda x: ' ', lyrics)
	lyrics = re.sub('\\[.*?\\]', lambda x: '', lyrics)
	lyrics = re.sub('\\(.*?\\)', lambda x: '', lyrics)
	lyrics = re.sub('[^a-zA-Z ]', lambda x: '', lyrics)
	lyrics = re.sub('[a-zA-Z]in ', lambda x: 'ing ', lyrics)
	
	# Word processing
	words = lyrics.split()
	
	# Stemming
	p = porter_stemmer.PorterStemmer()
	for i in range(len(words)):
		words[i] = p.stem(words[i], 0, len(words[i]) - 1)
	
	return words

def add_to_count(dict, key):
	if (dict.has_key(key)):
		dict[key] = dict[key] + 1
	else:
		dict[key] = 1

if __name__ == '__main__':
	main()
