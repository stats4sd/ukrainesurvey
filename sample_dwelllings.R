library(dplyr)
install.packages("tidyverse")
library(tidyr)

#x<-c(1:70)

#for (i in 1:nrow(buildings)){
 # buildings$num_dwellings[i]<-sample(x,1, replace = T)
#}

#read in buildings file
#group_by cluster?
#sperate into seperate cluster files?
#run scrpit across cluster files?

duptimes<-buildings$num_dwellings #number of required duplicates

idx<-rep(1:nrow(buildings), duptimes) #index the rows

dupdf<-buildings[idx,] #create duplicare file

dwellings<-dupdf%>%
  mutate(building.id=as.character(structure_number))%>% 
  group_by(building.id)%>%
  mutate(dwelling.id=row_number())%>%
  mutate("ID"=paste(cluster_id,building.id,dwelling.id, sep = "")) #add id numbers

dwellings$sample.order<-sample(1:nrow(dwellings)) # sample order creation 1:nrow()
dwellings$sampled<-ifelse(dwellings$sample.order<=16,1,0)#smapled if 16 or under
dwellings$replacement.order<-ifelse(dwellings$sampled==0, dwellings$sample.order-16, NA) #replacement order of dwellings
