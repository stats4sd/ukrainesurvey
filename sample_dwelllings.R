library(dplyr)
install.packages("tidyverse")
library(tidyr)
library(RMySQL)

x<-c(1:25)

for (i in 1:nrow(buildings)){
  buildings$num_dwellings[i]<-sample(x,1, replace = T)
}

buildings_2<-as.data.frame(matrix(nrow=sample(30:100), ncol = ncol(buildings)))
colnames(buildings_2)<-colnames(buildings)

buildings_2$region_name_en<-clusters$region_name_en[1]
buildings_2$region_name_uk<-clusters$region_name_uk[1]
buildings_2$cluster_id<-clusters$id[1]
buildings_2$structure_number<-c(1:nrow(buildings_2))
for (i in 1:nrow(buildings_2)){
 buildings_2$num_dwellings[i]<-sample(x,1, replace = T)
}
buildingsX<-rbind(buildings,buildings_2)

#READ IN BUILDINGS TO DATA FRAME FROM DATABASE#



dwellings.X<-NULL # create empty object for future use

duptimes<-buildingsX$num_dwellings #number of required duplicates (no.dwellings)

idx<-rep(1:nrow(buildingsX), duptimes) #index the rows

dupdf<-buildingsX[idx,] #create duplicare file

dwellings<-dupdf%>%
  group_by(structure_number)%>%
  mutate(dwelling.id=row_number())%>%
  mutate("ID"=paste(cluster_id,structure_number,dwelling.id, sep = ""))%>%
  select(region_name_en, region_name_uk, cluster_id, structure_number, dwelling.id)
# generate buildinga and dwelling ID numbers

cluster.dwellings.split<-split(dwellings,dwellings$cluster_id) #split into seperate data frames per cluster

colnames<-c(colnames(dwellings), "sample.order", "sampled", "replacement.order") #generate column names

for(i in 1:length(cluster.dwellings.split))
  {
  tmp<-data.frame(cluster.dwellings.split[i])
  tmp$sample.order<-sample(1:nrow(tmp))
  tmp$sampled<-ifelse(tmp$sample.order<=16,1,0)
  tmp$replacement.order<-ifelse(tmp$sampled==0,tmp$sample.order-16,NA)
  colnames(tmp)<-colnames
  dwellings.X<-data.frame(rbind(dwellings.X,tmp))
} #apply smapling procedure across each cluster

sampled.dwellings<-(subset.data.frame(dwellings.X, sampled==1))
sampled.dwellings.cluster<-split(sampled.dwellings, sampled.dwellings$cluster_id)


Ukraine_sampling<-function(df, cluster.id=NULL){

  dwellings<-df%>%
    filter(cluster_id==cluster.id)%>%
    group_by(structure_number)%>%
  mutate(dwelling.id=row_number())    
  
  dwellings$sample.order<-sample(1:nrow(dwellings))
  
  dwellings$sampled<-ifelse(dwellings$sample.order<=16,TRUE,FALSE)
  
  dwellings$replacement.order<-ifelse(dwellings$sampled==FALSE,dwellings$sample.order-16,NA)
  
  dwellings<-dwellings%>%
    select(region_name_en, region_name_uk, structure_number, dwelling.id, sample.order, sampled, replacement.order)%>%
    arrange(sample.order)
  
  dwellings.s<<-data.frame(dwellings)
}


Ukraine_sampling(dwellings, cluster.id = "140580")
