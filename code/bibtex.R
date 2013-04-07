require(knitcitations)
require(bibtex)

write.bibtex(file="../writing/ref.bib", append=FALSE, create_key=TRUE,
             c(Yihui2013 = citation("knitr"),
               Boettiger2013 = citation("wordcloud"))
             )