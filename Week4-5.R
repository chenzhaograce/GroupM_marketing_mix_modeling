AF<-read.csv("MMM_AF_S6.csv",header=TRUE)
test=c(1,2,NA,3)
is.na(test)
AF$Period=as.Date(AF$Period,"%m/%d/%Y")
AF$Sales=as.numeric(AF$Sales)
plot(AF$Period,AF$Sales,type="l")
View(AF$Period)
par(new=TRUE)
plot(AF$Period,AF$Sales.Event,type='l',col="red")
#scatter plot
plot(AF$Facebook.Impressions,AF$Sales)
plot(AF$National.TV.GRPs,AF$Sales)
plot(AF$Magazine.GRPs,AF$Sales)
plot(AF$Paid.Search,AF$Sales)
plot(AF$Display,AF$Sales)
plot(AF$Wechat,AF$Sales)

#correlation matrix
test=AF[,3:12]
View(test)
correlation=cor(AF[,3:12])
View(correlation)

library(corrplot)
corrplot(correlation,tl.col="black",tl.cex=0.5)
help(corrplot)
options(download.file.method="libcurl")

