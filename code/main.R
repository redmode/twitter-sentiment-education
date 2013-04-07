#########################################################################
##
## main.R
## Main working & experimental code. Not all code may be runnable.
## Alexander Gedranovich, 2013
##
#########################################################################


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
require(data.table)
source("sentiment.R")
source("utils.R")

##
## Reading stream
##
# stream <- read.table(file="../data/tweets.txt", header=F, sep="\t",
#                      encoding="UTF-8",
#                      fill=T, allowEscapes=T,
#                      col.names=c("id","date","text","lang","lat","lng","country","code"))
# stream <- na.omit(stream)
# stream$score <- NA

##
## Scoring sentiments (by K tweets at once in order to control memory consumption)
##
# K <- min(2000, nrow(stream))
# N <- (nrow(stream) %/% K) + 1
# for(i in 1:N){
#   start  <- (i-1)*K + 1 
#   finish <- i*K
#   if(i==N) finish <- nrow(stream)
#   
#   stream$score[start:finish] <- score.sentiment(stream$text[start:finish])
# }
# rm(list=c("K","N","i","start","finish"))
# save(stream, file="../data/stream.rda")

load("../data/stream.rda")


##
## Getting typical tweets
##

# sample(stream$text[stream$score> +2], 5)
# sample(stream$text[stream$score< -2], 5)

# pos.tweets <- c("She got good head, good brain, good education",
#                 "Education is a better safeguard of liberty than a standing armyedward everett hale quotesfolder",
#                 "Interesting story. University hospital has among best cardiac arrest survival rates in region",
#                 "One of my best friends who I met through college just got an article published I'm so proud of this girl! It's unreal!",
#                 "Wow! Just made a professor who never smiles smile! Haha I try")
# 
# neg.tweets <- c("All I hear from my professor this morning is blah-blah-blah. Crazy psychology professor",
#                 "Life hack: if you're considering taking abnormal psychology in college - consider suicide instead",
#                 "My management class was boring. Oh, hell! No! The professor even has really bad reviews",
#                 "I hope Clemson University parking service employees have a nice time burning in hell",
#                 "College makes me turn against what I loved. Year of cooking - started hating cooking. Now music college is making me hate music")
# 
# tweets <- data.frame(Positive=pos.tweets, Negative=neg.tweets)
# save(tweets, file="../writing/pos.neg.tweets.rda")
# rm(list=c("pos.tweets","neg.tweets","tweets"))

##
## Popular words clouds
##

plot.wordcloud(stream$text[stream$score>0], "../writing/figure/word.cloud.pos.png")
plot.wordcloud(stream$text[stream$score<0], "../writing/figure/word.cloud.neg.png")


##
## Normalizing sentiments
##
stream$score[stream$score> +2] <- +2
stream$score[stream$score< -2] <- -2

####################################
##
## Basic stats
##
####################################

##
## Top countries
##
top.n <- 10
score.table <- table(stream$country,stream$score)
df <- data.frame(positive=rowSums(score.table[,c(4,5)]),
                 negative=rowSums(score.table[,c(1,2)]),
                 neutral=score.table[,3],
                 total=rowSums(score.table[,c(1:5)]))
sum.cum <- colSums(df)
df <- head(df[with(df, order(-total)),], top.n)
sum.head <- colSums(df)
df <- rbind(df, sum.cum-sum.head, sum.cum)
rownames(df)[c(top.n+1,top.n+2)] <- c("Other", "World, total")
df$percentage <- 100*df$total/sum.cum[4]
tweets.table <- df
## Save to file
save(tweets.table, file="../writing/tweets.pandoc.rda")
## Clear workspace
rm(list=c("top.n","score.table","df","sum.cum","sum.head","tweets.table"))


##
## Plotting to the map
##
estream <- stream[stream$score!=0,c("lat","lng","score")]

N <- 500
estream$clng <- as.numeric(cut(estream$lng, breaks=N*2))
estream$clat <- as.numeric(cut(estream$lat, breaks=N))

dt <- data.table(estream)
setkey(dt, clat, clng)

m <- dt[,list(lat=mean(lat),lng=mean(lng),score=mode(score),size=log(length(score)+1,2)),by="clat,clng"]
m <- data.frame(m)[,3:6]
m <- rbind(m, data.frame(lng=0,lat=0,score=0,size=1))

world <- fortify(getMap(resolution="low"))

p <- ggplot() + theme_bw()
p <- p + geom_polygon(data=world, aes(x=long, y=lat, group=group),
                      colour="#888888", fill="#eeeeff", alpha=0.3)
p <- p + geom_point(data=m, aes(x=lng,y=lat,colour=as.factor(score),size=size), alpha=0.8, position="jitter")
p <- p + scale_colour_manual(name="Оценка", values=c("red","red","#999999","#00dd00","#00dd00"))
p <- p + scale_size(guide="none")
p <- p + xlab("Долгота, градусы") + ylab("Широта, градусы")
# world
p
# usa
p.usa <- p + coord_cartesian(ylim=c(22, 52), xlim=c(-130,-60))
p.usa
# europe
p.europe <- p + coord_cartesian(ylim=c(30, 70), xlim=c(-10,50))

ggsave(file="../writing/figure/map.pdf",p,cairo_pdf,dpi=600,width=25,height=15,units="cm")
ggsave(file="../writing/figure/map.europe.pdf",p.europe,cairo_pdf,dpi=600,width=25,height=15,units="cm")
ggsave(file="../writing/figure/map.usa.pdf",p.usa,cairo_pdf,dpi=600,width=25,height=15,units="cm")

rm(list=c("estream","m","world","N","dt","p","p.usa","p.europe"))

##
## Simple histogramms
##

topnames <- names(sort(table(stream$code), decreasing=T)[1:3])
topnames <- c("BY","RU","UA","US")

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
ggsave("../writing/figure/density.pdf", plot=h, dpi=300, width=25, height=10, units="cm")

##
## 
##

