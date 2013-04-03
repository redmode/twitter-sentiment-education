##
## Error handling function when trying 'tolower'
## Source: http://jeffreybreen.wordpress.com/2011/07/04/twitter-text-mining-r-slides/
##
tryTolower <- function(x)
{
  # create missing value
  y = NA
  # tryCatch error
  try_error = tryCatch(tolower(x), error=function(e) e)
  # if not an error
  if (!inherits(try_error, "error"))
    y = tolower(x)
  # result
  as.character(y)
}

##
## Use of RegExp to clear up location name from user profile
##
clear.location <- function(txt){
  # remove retweet entities
  txt <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", txt)
  # remove at people
  txt <- gsub("@\\w+", "", txt)
  # remove numbers
  txt <- gsub("[[:digit:]]", "", txt)
  # remove punctuation
  txt <- gsub("[[:punct:]]", "", txt)
  # remove html links
  txt <- gsub("http\\w+", "", txt)
  # remove unnecessary spaces
  txt <- gsub("^\\s+|\\s+$", "", txt)
  txt <- gsub("[[:space:]\t]{1,}", ",", txt)
    
  txt
}

##
## Use of RegExp to clear up tweet text
##
clear.text <- function(txt){
  # remove retweet entities
  txt <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", txt)
  # remove at people
  txt <- gsub("@\\w+", "", txt)
  # remove punctuation
  txt <- gsub("[[:punct:]]", "", txt)
  # remove numbers
  txt <- gsub("[[:digit:]]", "", txt)
  # remove html links
  txt <- gsub("http\\w+", "", txt)
  # remove everything else except latin letters and spaces
  txt <- gsub("[^a-zA-Z ]", "", txt)
  # remove unnecessary spaces
  txt <- gsub("[ ]{2,}", " ", txt)
  txt <- gsub("^\\s+|\\s+$", "", txt)
  
  txt
}
