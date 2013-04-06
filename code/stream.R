#!/usr/bin/Rscript

#########################################################################
##
## stream.R
## Rscript for connection to Twitter Streaming API
## Alexander Gedranovich, 2013
##
#########################################################################

##
## Loading libraries & sources
##
require(RCurl)
require(RJSONIO)
source("utils.R")
source("geonames.R")

##
## Args & settings
##
Sys.setlocale(locale="C")

args  <- commandArgs(TRUE)
if(is.na(args[1]))
  stop("You should provide your Twitter Streaming API username:password as first argument!")
usrpwd <- args[1]
query  <- ifelse(!is.na(args[2]), args[2], "education,university,professor,college")
lang   <- ifelse(!is.na(args[3]), args[3], "en")

##
## Welcome message
##
cat("\n\nQuering Twitter Stream:",
    "\n**********************************************************\n",
    "Query:   ", query, "\n",
    "Language:", lang,
    "\n**********************************************************\n\n")

##
## Processing function for raw tweets
##
process <- function(x){
  if(nchar(x)>0){
    ## Checks if JSON
    if(isValidJSON(x, TRUE)){
      json <- fromJSON(x)
    }
    else
      return(NULL)
    ## Checks the 'text' field
    if(!is.null(json$text)){
      json$text <- clear.text(json$text)
    }
    else
      return(NULL)    
    
    ##
    ## Basic processing
    ##
    if(nchar(json$text,allowNA=T)>0 & json$user$lang==lang){
      ##
      ## Constructs data.frame
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
      ## Geo coded tweet
      ##
      if(!is.null(json$coordinates)){
        jdf$lat <- json$coordinates$coordinates[2]
        jdf$lng <- json$coordinates$coordinates[1]
        geo <- geo.names(jdf$lat,jdf$lng)
        
        if(nchar(geo$country)>0){
          jdf$country <- geo$country
          jdf$code    <- geo$code
        }
      }
      ##
      ## Not geo-coded tweet
      ##
      else{
        loc <- ifelse(is.character(json$user$location), json$user$location, "")
        coords <- geo.coordinates(loc)
        if(nchar(coords$country)>0){
          jdf$lat <- as.numeric(coords$lat)
          jdf$lng <- as.numeric(coords$lng)
          jdf$country <- as.character(coords$country)
          jdf$code    <- as.character(coords$code)
        }
      }
      
      # To lower case conversion
      jdf$text <- sapply(jdf$text, tryTolower)
      jdf$text <- as.character(jdf$text)
      jdf$code <- as.character(jdf$code)
      jdf <- na.omit(jdf)

      if(nrow(jdf)>0){
        # Counting processed tweets
        i <- attr(process, "count")
        i <- ifelse(is.null(i), 1, i)
        attr(process, "count") <<- i+1
        
        # Print to console
        cat(i, ":", jdf$text, "(", jdf$code, ")", "\n")
        # Add to file
        write.table(jdf, file="../data/tweets.txt", append=T, row.names=F, col.names=F, sep="\t")
      }
    }
  }
  
  return(NULL)
}

##
## Request to Twitter Streaming API
##
getURL("https://stream.twitter.com/1/statuses/filter.json", 
       userpwd=usrpwd,
       write=process,
       postfields=paste0("track=",query))
