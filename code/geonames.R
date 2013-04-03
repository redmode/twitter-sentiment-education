##
## Function uses geonames.org API to retrieve 
## geographical coordinates by location name
##
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

##
## Function uses geonames.org API to retrieve 
## location name by geographical coordinates
##
geo.names <- function(lat,lng){
  res <- getURL("http://api.geonames.org/findNearbyPlaceNameJSON", 
                postfields=paste0("lat=",lat,"&lng=",lng,"&username=redmode"))
  res <- fromJSON(res)
  ret <- list(country=NA,code=NA)
  
  if(!is.null(res$geonames)){
    if(length(res$geonames)>0){
      ret$country <- res$geonames[[1]]$countryName
      ret$code    <- res$geonames[[1]]$countryCode
    }
  }
  else if(!is.null(res$status$value)){
    if(res$status$value == 19){
      stop("Sorry, geonames.org quota exceeded... Try again in one hour...")
    }
  }
  
  ret
}
