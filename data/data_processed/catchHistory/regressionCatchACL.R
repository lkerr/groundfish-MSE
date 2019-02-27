# Reorganize catchHist data for plotting
#read_csv("catchHist.csv")

mydata <- catchHist %>% 
  select(Stock, Total, Year, data_type) %>% #select columns of interest
  rename_all(tolower) %>% #make all names lowercase
  mutate(stock = tolower(stock)) %>% #make stock names lowercase
  filter(grepl(paste(c("cod","haddock"), collapse="|"),stock)) #get just cod and haddock data

###
ggplot(mydata, aes(x=year, y=total, group=data_type, color=data_type)) +
  geom_line() +
  facet_wrap(~stock,scales = "free")

#####  fit implementation error model #####
# Set up data to model cod-haddock Interactions
mydata<-mydata %>% 
  filter(stock=="gb cod"|stock=="gb haddock")
mydata$stock[mydata$stock=="gb cod"]<-"cod"
mydata$stock[mydata$stock=="gb haddock"]<-"haddock"

regdata <- mydata %>%
  spread(data_type,total) %>% 
  mutate(ACL2=ACL^2) %>% 
  gather(data_type,total,-c(year,stock)) %>% 
  spread(stock,total) %>% 
  myspread(data_type, c("cod","haddock"))

# reg<-lm(Catch_cod~ACL_cod,regdata)
# reg2<-lm(Catch_cod~ACL_cod+ACL2_cod,regdata)
# regboth<-lm(Catch_cod~ACL_cod+ACL_haddock,regdata)
# regboth2<-lm(Catch_cod~ACL_cod+ACL_haddock+ACL2_cod+ACL2_haddock,regdata)
# xs_cod<-seq(0,5000,500)
# pre_reg2<-predict(reg2,list(ACL_cod=xs_cod,ACL2_cod=xs_cod^2))
# 
# plot(Catch_cod~ACL_cod,data=regdata)
# abline(reg,col="red")
# lines(xs_cod,pre_reg2,col="blue")
# 
# reg<-lm(Catch_haddock~ACL_haddock,regdata)
# reg2<-lm(Catch_haddock~ACL_haddock+ACL2_haddock,regdata)
# regboth<-lm(Catch_haddock~ACL_cod+ACL_haddock,regdata)
# regboth2<-lm(Catch_haddock~ACL_cod+ACL_haddock+ACL2_cod+ACL2_haddock,regdata)
# xs_haddock<-seq(0,60000,10000)
# pre_reg2<-predict(reg2,list(ACL_haddock=xs_haddock,ACL2_haddock=xs_haddock^2))
# 
# plot(Catch_haddock~ACL_haddock,data=regdata)
# abline(reg,col="red")
# lines(xs_haddock,pre_reg2,col="blue")
# 
# plot(Catch_haddock~ACL_cod,data=regdata)
# abline(regboth,col="red")
# lines(xs_cod,pre_reg2,col="blue")
# 
# plot(Catch_cod~ACL_haddock,data=regdata)
# abline(regboth,col="red")
# 
# ggplot(regdata,aes(Catch_cod,Catch_haddock))+geom_point()+geom_smooth(method="lm")
# ggplot(regdata,aes(ACL_cod,Catch_haddock))+geom_point()+geom_smooth(method="lm")

mreg<-lm(cbind(Catch_cod,Catch_haddock)~ACL_cod+ACL_haddock,regdata)
mreg
vcov(mreg)
predict(mreg)

in_cod<-seq(0,10000,length.out=20)
in_haddock<-seq(0,100000,length.out=20)
predict(mreg,list(ACL_cod=in_cod,ACL_haddock=in_haddock))