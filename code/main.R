##
## Clearing the workspace
##
rm(list=ls(all=TRUE))
gc(reset=TRUE)
set.seed(12345)

##
## Required packages
##
require(ggplot2)
require(rworldmap)
source("sentiment.R")


##
## Reading stream
##
stream <- read.table(file="../data/tweets.txt", header=F, sep="\t",
                     encoding="UTF-8",
                     fill=T, allowEscapes=T,
                     col.names=c("id","date","text","lang","lat","lng","country","code"))
stream <- na.omit(stream)
stream$score <- NA

K <- 5000
N <- (nrow(stream) %/% K) + 1
for(i in 1:N){
  start  <- (i-1)*K + 1 
  finish <- i*K
  if(i==N) finish <- nrow(stream)
  
  stream$score[start:finish] <- score.sentiment(stream$text[start:finish])
}

##
## Scoring sentiments
##
# stream$score <- score.sentiment(stream$text, .progress='text')[,2]
stream$score[stream$score>  2] <- +2
stream$score[stream$score< -2] <- -2
stream$score <- as.factor(stream$score)

##
## Plotting to the map
##
world <- fortify(getMap(resolution="low"))

p <- ggplot()
p <- p + geom_polygon(data=world, aes(x=long, y=lat, group=group),
                      colour="#888888", fill="#ddddee", alpha=0.6)
p <- p + geom_point(data=stream, aes(x=lng,y=lat,colour=score), alpha=0.8)
p <- p + scale_colour_manual(name="Оценка",
                             values=c("red","orange","#aaaaaa","#99dd99","#00dd00"))
p + xlab("Долгота, градусы") + ylab("Широта, градусы")


##
## Simple histogramms
##

topnames <- names(sort(table(stream$code), decreasing=T)[1:3])
stream$top <- as.character(stream$code)
stream$top[!(stream$code %in% topnames)] <- "Other"

h <- ggplot()
h <- h + geom_histogram(data=stream, aes(x=score)) + facet_grid(.~top)
h

##
## 
##

