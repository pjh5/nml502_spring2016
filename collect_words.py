import os
import re
import porter_stemmer
import operator
import csv

def main():
	# Count all words
	lyrics_dir = 'lyrics'
	p = porter_stemmer.PorterStemmer()
	word_counts = {}
	for artist in os.listdir(lyrics_dir):
		for song in [s for s in os.listdir(lyrics_dir + '/' + artist) if s[-4:]=='.txt']:
			lyrics = open(lyrics_dir + '/' + artist + '/' + song).read();
			lyrics = re.sub('\\s', lambda x: ' ', lyrics)
			lyrics = re.sub('\\[.*?\\]', lambda x: '', lyrics)
			lyrics = re.sub('\\(.*?\\)', lambda x: '', lyrics)
			lyrics = re.sub('[^a-zA-Z ]', lambda x: '', lyrics)
			lyrics = re.sub('[a-zA-Z]in ', lambda x: 'ing ', lyrics)
			
			words = lyrics.lower().split()
			for i in range(len(words)):
				words[i] = p.stem(words[i], 0, len(words[i]) - 1)
				
				if (word_counts.has_key(words[i])):
					word_counts[words[i]] = word_counts[words[i]] + 1
				else:
					word_counts[words[i]] = 1
			
			words = ' '.join(words)
			with open("allwords.txt", "a") as wordfile:
				wordfile.write(words)

	ordered_words = sorted(word_counts.items(), key=operator.itemgetter(1))
	with open('top_stemmed_words.csv', 'wb') as csvfile:
		csvwriter = csv.writer(csvfile, delimiter=',',
								quotechar='|', quoting=csv.QUOTE_MINIMAL)
		for i in range(len(ordered_words)):
			csvwriter.writerow([i, ordered_words[i][0], ordered_words[i][1]])

if __name__ == '__main__':
	main()
