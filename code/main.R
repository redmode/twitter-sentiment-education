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

##
## Scoring sentiments (by K tweets at once in order to control memory consumption)
##
K <- 1000
N <- (nrow(stream) %/% K) + 1
for(i in 1:N){
  start  <- (i-1)*K + 1 
  finish <- i*K
  if(i==N) finish <- nrow(stream)
  
  stream$score[start:finish] <- score.sentiment(stream$text[start:finish])
}
rm(list=c("K","N","i","start","finish"))

##
## Normalizing sentiments
##
# stream$score <- as.numeric(stream$score)
stream$score[stream$score> +2] <- +2
stream$score[stream$score< -2] <- -2

##
## Plotting to the map
##
world <- fortify(getMap(resolution="low"))

p <- ggplot() + theme_bw()
p <- p + geom_polygon(data=world, aes(x=long, y=lat, group=group),
                      colour="#888888", fill="#eeeeff", alpha=0.3)
p <- p + geom_point(data=stream, aes(x=lng,y=lat,colour=score), alpha=0.8)
p <- p + scale_colour_manual(name="Оценка", values=c("red","orange","#aaaaaa","#99dd99","#00dd00"))
p <- p + xlab("Долгота, градусы") + ylab("Широта, градусы")
p 

##
## Simple histogramms
##

topnames <- names(sort(table(stream$code), decreasing=T)[1:3])
topnames <- c("BY","RU","UA","KZ","US")

stream$top <- as.character(stream$code)
stream$top[!(stream$code %in% topnames)] <- "Other"

h <- ggplot() + theme_bw()
h <- h + geom_histogram(data=stream[stream$top!="Other",], aes(x=score, y=..density..), binwidth=0.5)
h <- h + facet_grid(.~top)

stream$top <- "World"
h <- h + geom_histogram(data=stream, aes(x=score, y=..density..), binwidth=0.5)
h <- h + scale_x_continuous(labels=c(-2:2), breaks=c(-2:2)+0.25)
h <- h + xlab("Оценки") + ylab("Плотность")
h

##
## 
##

