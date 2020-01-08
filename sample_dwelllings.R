library(dplyr)
install.packages("tidyverse")
library(tidyr)

#x<-c(1:70)

#for (i in 1:nrow(buildings)){
  #buildings$num_dwellings[i]<-sample(x,1, replace = T)
#}

#buildings_2<-as.data.frame(matrix(nrow=sample(30:100), ncol = ncol(buildings)))
#colnames(buildings_2)<-colnames(buildings)

#buildings_2$region_name_en<-clusters$region_name_en[1]
#buildings_2$region_name_uk<-clusters$region_name_uk[1]
#buildings_2$cluster_id<-clusters$id[1]
#buildings_2$structure_number<-c(1:nrow(buildings_2))
#for (i in 1:nrow(buildings_2)){
# buildings_2$num_dwellings[i]<-sample(x,1, replace = T)
#}
#buildingsX<-rbind(buildings,buildings_2)

dwellings.X<-NULL # create empty object for future use

duptimes<-buildingsX$num_dwellings #number of required duplicates (no.dwellings)

idx<-rep(1:nrow(buildingsX), duptimes) #index the rows

dupdf<-buildingsX[idx,] #create duplicare file

dwellings<-dupdf%>%
  mutate(building.id=as.character(structure_number))%>% 
  group_by(building.id)%>%
  mutate(dwelling.id=row_number())%>%
  mutate("ID"=paste(cluster_id,building.id,dwelling.id, sep = "")) # generate buildinga and dwelling ID numbers

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
} # apply smapling procedure across each cluster

