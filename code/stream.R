#!/usr/bin/Rscript

##
## Loading libraries & settings
##
require(RCurl)
require(RJSONIO)

source("utils.R")

Sys.setlocale(locale="C")

args  <- commandArgs(TRUE)
query <- ifelse(!is.na(args[1]), args[1], "education,university,professor,college")
lang  <- ifelse(!is.na(args[2]), args[2], "en")

##
## define error handling function when trying tolower
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
## Processing function
##
process <- function(x){
  if(nchar(x)>0){
    json <- fromJSON(x)
    json$text <- clear.text(json$text)
    
    if(nchar(json$text,allowNA=T)>0 & json$user$lang==lang){
      ##
      ## Basic data.frame
      ##
      jdf <- data.frame(id=json$id_str,
                        created=json$created_at,
                        text=json$text,
                        lang=json$user$lang,
                        lat=NA,
                        lng=NA,
                        country=NA,
                        code=NA)
      ##
      ## Geo code
      ##
      if(!is.null(json$coordinates)){
        jdf$lat <- json$coordinates$coordinates[2]
        jdf$lng <- json$coordinates$coordinates[1]
        geo <- geo.names(jdf$lat,jdf$lng)
        
        if(nchar(geo$country)>0){
          jdf$country <- geo$country
          jdf$code <- geo$code
        }
      }
      else{
        loc <- ifelse(is.character(json$user$location), json$user$location, "")
        coords <- geo.coordinates(loc)
        if(nchar(coords$country)>0){
          jdf$lat <- as.numeric(coords$lat)
          jdf$lng <- as.numeric(coords$lng)
          jdf$country <- as.character(coords$country)
          jdf$code <- as.character(coords$code)
        }
      }
      
      # To lower case conversion
      jdf$text <- sapply(jdf$text, tryTolower)
      jdf$text <- as.character(jdf$text)
      jdf <- na.omit(jdf)

      if(nrow(jdf)>0){
        # Counting processed tweets
        i <- attr(process, "count")
        i <- ifelse(is.null(i), 1, i)
        attr(process, "count") <<- i+1
        
        # Print to console
        cat(i, ":", jdf$text, "(", as.character(jdf$code), ")", "\n")
        # Add to file
        write.table(jdf, file="../data/tweets.txt", append=T, row.names=F, col.names=F, sep="\t")
      }
    }
  }
}

##
## Request to Twitter Streaming API
##

getURL("https://stream.twitter.com/1/statuses/filter.json", 
       userpwd="rredmode:chalera-twitter",
       write=process,
       postfields=paste0("track=",query))
