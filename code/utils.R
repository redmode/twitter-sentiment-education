
clear.location <- function(txt){
  # remove retweet entities
  txt <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", txt)
  # remove at people
  txt <- gsub("@\\w+", "", txt)
  # remove numbers
  txt <- gsub("[[:digit:]]", "", txt)
  txt <- gsub(",", "0", txt)
  # remove punctuation
  txt <- gsub("[[:punct:]]", "", txt)
  # remove html links
  txt <- gsub("http\\w+", "", txt)
  # remove unnecessary spaces
  txt <- gsub("[ \t]{2,}", "", txt)
  txt <- gsub("^\\s+|\\s+$", "", txt)
  
  txt <- gsub("[[:space:]]", ",", txt)
  txt <- gsub("0", ",", txt)
  txt <- gsub("[,]{2,}", ",", txt)
  txt
}

clear.text <- function(txt){
  # remove retweet entities
  txt <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", txt)
  # remove at people
  txt <- gsub("@\\w+", "", txt)
#   #remove punctuation
  txt <- gsub("[[:punct:]]", "", txt)
#   #remove numbers
  txt <- gsub("[[:digit:]]", "", txt)
  # remove html links
  txt <- gsub("http\\w+", "", txt)
  # everything else
  txt <- gsub("[^a-zA-Z ]", "", txt)
  # remove unnecessary spaces
#   txt <- gsub("[\n]", " ", txt)
  txt <- gsub("[ ]{2,}", " ", txt)
  txt <- gsub("^\\s+|\\s+$", "", txt)
  txt
}

geo.coordinates <- function(name){
  res <- getURL("http://api.geonames.org/searchJSON", 
                postfields=paste0("q=",name,"&maxRows=1&fuzzy=0.8&username=redmode"))
  res <- fromJSON(res)
  ret <- list(lat=NA,lng=NA,country=NA,code=NA)
  
  if(!is.null(res$totalResultsCount)){
    if(res$totalResultsCount>0){
      ret$lat <- res$geonames[[1]]$lat
      ret$lng <- res$geonames[[1]]$lng
      ret$country <- res$geonames[[1]]$countryName
      ret$code <- res$geonames[[1]]$countryCode
    }
  }
  else if(!is.null(res$status$value)){
    if(res$status$value == 19){
      stop("Sorry, geonames.org quota exceeded... Try again in one hour...")
    }
  }
  
  ret
}

geo.names <- function(lat,lng){
  res <- getURL("http://api.geonames.org/findNearbyPlaceNameJSON", 
                postfields=paste0("lat=",lat,"&lng=",lng,"&username=redmode"))
  res <- fromJSON(res)
  ret <- list(lat=NA,lng=NA,country=NA,code=NA)
  
  if(!is.null(res$geonames)){
    if(length(res$geonames)>0){
      ret$lat <- res$geonames[[1]]$lat
      ret$lng <- res$geonames[[1]]$lng
      ret$country <- res$geonames[[1]]$countryName
      ret$code <- res$geonames[[1]]$countryCode
    }
  }
  else if(!is.null(res$status$value)){
    if(res$status$value == 19){
      stop("Sorry, geonames.org quota exceeded... Try again in one hour...")
    }
  }

  ret
}

