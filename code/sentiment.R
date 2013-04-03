##
## Required packages
##
require(plyr)
require(stringr)

##
## If running on Linux machine - use multicore
##
switch(Sys.info()[['sysname']],
       Linux  = {require(doMC)
                 registerDoMC(detectCores())})
##
## Imports positive and negative words
## Source: http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html
##
pos.words <- readLines("../data/positive_words.txt")
neg.words <- readLines("../data/negative_words.txt")

##
## Simple sentiment scoring, inspired by Jeffrey Breen post
## Source: http://jeffreybreen.wordpress.com/2011/07/04/twitter-text-mining-r-slides/
##
score.sentiment <- function(sentences, .progress='none')
{
  # Parameters
  # sentences: vector of text to score
  # .progress: passed to laply() to control of progress bar

  # create simple array of scores with laply
  scores <- laply(sentences, 
                 function(sentence, pos.words, neg.words)
                 {
                   # text is already cleared and lowercased
                   # so, no need to preprocess
                   
                   # split sentence into words with str_split (stringr package)
                   word.list <- str_split(sentence, "\\s+")
                   words <- unlist(word.list)
                   
                   # compare words to the dictionaries of positive & negative terms
                   pos.matches <- match(words, pos.words)
                   neg.matches <- match(words, neg.words)
                   
                   # get the position of the matched term or NA
                   # we just want a TRUE/FALSE
                   pos.matches <- !is.na(pos.matches)
                   neg.matches <- !is.na(neg.matches)
                   
                   # final score
                   score <- sum(pos.matches) - sum(neg.matches)
                   return(score)
                 }, pos.words, neg.words, .parallel=TRUE, .progress=.progress)
  
  return(as.numeric(scores))
}
