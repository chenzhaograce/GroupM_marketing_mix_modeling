#regression
AF=read.csv("AF_Final.csv",header=TRUE)
help(lm)
Model1=lm(Sales~Sales.Event+CCI+NationalTV2,data=AF)

#dummy variable
#black friday
AF[,"Black_Friday"]=0
View(AF)
AF$Period=as.Date(AF$Period,"%m/%d/%Y")
AF[which(AF$Period=="2014-11-24"),"Black_Friday"]=1
AF[which(AF$Period=="2015-11-30"),"Black_Friday"]=1
AF[which(AF$Period=="2016-11-28"),"Black_Friday"]=1
AF[which(AF$Period=="2017-11-27"),"Black_Friday"]=1

#July4th
AF[,"July4th"]=0
AF[which(AF$Period=="2014-07-07"),"July4th"]=1
AF[which(AF$Period=="2015-07-06"),"July4th"]=1
AF[which(AF$Period=="2016-07-04"),"July4th"]=1
AF[which(AF$Period=="2017-07-03"),"July4th"]=1


#Test model
#Base
Model1=lm(Sales~Black_Friday+July4th+Sales.Event+CCI+NationalTV2+Magazine1+Display1+Facebook2+PaidSearch1+Wechat2+Comp.Media.Spend,data=AF)
summary(Model1)

#Add Media variable
#Add Wechat

#Contribution
Model=lm(Sales~Black_Friday+July4th+Sales.Event+CCI+NationalTV2+Magazine1+Display1+Facebook2+PaidSearch1+Wechat2+Comp.Media.Spend,data=AF,x=TRUE)
test=Model$x
View(test)
Model$coefficients
contribution=Model$x%*%diag(Model$coefficients)
View(contribution)
contribution=as.data.frame(contribution)
contribution$Period=AF$Period
colnames(contribution)=c(names(Model$coefficients),"Period")

#unpivot
library(reshape)
help(melt)
contri=melt(contribution,id.vars="Period",measures.vars=names(Model$coefficients))
View(contri)
write.csv(contri,"contribution.csv",row.names=FALSE)

#AVM
AVM=cbind(AF[,c("Period","Sales")],Model$fitted.values)
View(AVM)
colnames(AVM)=c("Period","Sales","Modeled Sales")
write.csv(AVM,"AVM.csv",row.names=FALSE)
