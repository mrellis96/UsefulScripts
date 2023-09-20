setwd("WORKINGDIRECTORY/") #change for WD
vendata <- read.csv("FILE.csv", head=T, sep=",") #change file name

venn_list <- list(GROUP1=vendata$GROUP1, GROUP2=vendata$GROUP2) #swap GROUPx for target variable (eg, sequenceing & traditional), add more groups as needed
vencombplot <- ggvenn(venn_list,fill_color = c("black", "lightgrey"), text_size = 8) #add change colours as needed
venplot
ggsave("venplot.jpg", plot= vencombplot, width=15, height=12, units="cm", dpi=480)