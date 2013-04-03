##
##
##
require(plyr)
require(stringr)
require(sentiment)
require(doMC)
registerDoMC(detectCores())

# import positive and negative words
pos.words <- readLines("../data/positive_words.txt")
neg.words <- readLines("../data/negative_words.txt")

##
##
##
score.sentiment <- function(sentences, .progress='none')
{
  # Parameters
  # sentences: vector of text to score
  # pos.words: vector of words of postive sentiment
  # neg.words: vector of words of negative sentiment
  # .progress: passed to laply() to control of progress bar

  # create simple array of scores with laply
  scores <- laply(sentences, 
                 function(sentence, pos.words, neg.words)
                 {
                   # remove punctuation
#                    sentence <- gsub("[[:punct:]]", "", sentence)
                   # remove control characters
#                    sentence <- gsub("[[:cntrl:]]", "", sentence)
                   # remove digits?
#                    sentence <- gsub('\\d+', '', sentence)
                   
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
  
  return(scores)
}
