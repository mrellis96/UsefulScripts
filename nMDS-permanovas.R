library(vegan)
library(plyr)
library(pairwiseAdonis)
library(dplyr)
library(ggplot2)
library(ggvenn)

setwd("PATH/TO/FILES")
otu <- read.csv("final_csv", head = T, sep =',') #read in datasheet
env <- otu[,1:5] #seperate out environmental factors
com <- otu[,-(1:5)] #seperate community data
com <- com %>% mutate_if(is.numeric, ~1 * (. > 0)) #remove all cols that = 0

RelAbu <-decostand(com, method="pa") #get relative abundances (change method to best suit)
#Distance Martix
Dist <- vegdist(RelAbu, method = 'binomial', binary = T) #get distance matric (change method to best suit eg, bray)
attach(env) #attach env data within R
Mat<-as.matrix(Dist, lables=T) #convert distances scores to matrix
#nMDS
MDS<-metaMDS(Mat, distance = "binomial", k=2, maxit=999, trymax=1000) #get NMDS scores (change method to best suit eg, bray)
#goodness(MDS) 
stressplot(MDS)
stress <- round(MDS$stress,digits=3) #this gets the nmds stress to add to the plot
stesslab <- paste('Stress: ',stress)
print(stresslab)

data.scores <- as.data.frame(scores(MDS)) #gets datascores for nMDS plot
data.scores$site <- rownames(data.scores)
data.scores$Sample_Method <- env$Type #add in variables from env data
data.scores$Sample <- env$Sameple
data.scores$Site <- env$Site
data.scores$Period <- env$Period
#add more variables as required
Plot <- ggplot() + 
  geom_point(data=data.scores,aes(x=NMDS1,y=NMDS2,colour=Sample_Method, shape=Site),size=3,) + # add the point markers - change shape and colour as needed
  #geom_text(data=data.scores,aes(x=NMDS1,y=NMDS2,label=Site),size=4,vjust=-.5) +  # add the site labels if needed
  scale_color_manual(values=c("#000000", "#E69F00","#009E73","#56B4E9","#0072B2"))+ #set colours
  scale_shape_manual(values=c(15,16,17))+ #set shapes
  annotate(geom="text",label=stesslab, x=-0.25, y=-.4, size=5)+ #add stress to plot - change x and y as needed (sometimes turning off axis.text = element_blank(), axis.ticks = element_blank() below can help)
  coord_equal() +
  theme(axis.text.x = element_blank(), #removes all the background and axis titles to make a neet plot
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_blank(),
        legend.text = element_text(size=13),
        legend.title = element_text(size=15))
Plot #plot it
ggsave("plot.jpg", plot= Plot, width=30, height=24, units="cm", dpi=150) #save it 0- change height and width as needed

Ad<-adonis2(Dist ~ Period/Site/Type, env, permutations=10000, method="binomial") #Permanova - change method (eg bray), formula
Ad
PW<- pairwise.adonis(Dist, env$Type) #pairwise permanova
PW