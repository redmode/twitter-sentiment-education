require(twitteR)
require(ROAuth)
require(RJSONIO)

##
## One time authorization
##

# cred <- OAuthFactory$new(consumerKey="uAGvSczjTP3TWRRc8LQ",
#                          consumerSecret="HueEXMCZpSxRqzSdwDmRBgxAoa9pQF5mDGJQzxZI8M",
#                          requestURL="https://api.twitter.com/oauth/request_token",
#                          accessURL="https://api.twitter.com/oauth/access_token",
#                          authURL="https://api.twitter.com/oauth/authorize")
# cred$handshake()
# ##
# ## 2049575
# ##
# registerTwitterOAuth(cred)
# save(cred, file="oauth")

load("oauth")
registerTwitterOAuth(cred)




# ##
# ## Exploring
# ##
# N <- 10
# # geocode <- '0,0,20000km'
# tweets <- searchTwitter("#образование", n=N)
# 
# df <- data.frame(id = sapply(tweets, function(x) x$id),
#                  created = sapply(tweets, function(x) x$created),             
#                  text = sapply(tweets, function(x) x$getText()),
#                  user = sapply(tweets, function(x) x$screenName))
# 
# # View(df[with(df, order(id)), ])
# 
# get.location <- function(usr, verbose=TRUE, sleep=TRUE){
#   loc <- getUser(usr)$location
#   
#   Sys.sleep(1)
#   i <- attr(get.location, "count")
#   i <- ifelse(is.null(i), 1, i)
#   attr(get.location, "count") <<- i+1
#   
#   if(verbose){
#     cat(i,":",loc,"\n")
#   }
# 
#   if(i/100 == i%/%100 & sleep){
#     cat("Sleeping for 1 minute...\n")
#     Sys.sleep(60)
#   }
#   
#   loc
# }
# 
# tmp <- sapply(df$user, get.location)
# names(tmp) <- NULL
# 
# df$loc <- tmp
# df$loc <- sapply(df$loc, clear.location)
# df <- df[nchar(df$loc)>0,]
# 
# coords <- t(sapply(df$loc, geo.coordinates))
# 
# df$lat <- as.numeric(coords[,"lat"])
# df$lng <- as.numeric(coords[,"lng"])
# df$country <- as.character(coords[,"country"])
# df$code <- as.character(coords[,"code"])
# 
# df <- na.omit(df)
# df$text <- sapply(df$text, clear.text)
