library(sf)
library(ggplot2)
library(ggspatial)
library(ggnewscale)
library(patchwork)
library(ggrepel)
setwd("~/path/to/dir/")

island <- st_read("shpaefile.shp") #shapefile
sites <- read.csv('populationstable.csv', head=T, sep=",") #locations of sites with species presences (binary)

#transform to long tbale
sites <- sites %>%
  pivot_longer(cols = Amp:Zos, names_to = "Species", values_to = "Value")%>%
  drop_na()

#seperate out inset sites
sites1 <- sites [ sites$init %in% c("KB", "DI","LP"),]
sites2 <- sites [ ! sites$init %in% c("KB", "DI","LP"),]

#map 1 with rectangle of inset
map_plot <- ggplot() +
  geom_sf(data=island,fill="grey", color="grey") +
  coord_sf() +
  geom_point(data=sites1, aes(x=lon, y=lat, shape=Species, colour=Species),  size= 8,position=position_dodge(width = 0.12))+
  geom_text(data=sites1, aes(x=lon, y=lat, label=Population), vjust = -.7, hjust = 0.5, size = 8)+
  geom_text(data=sites2, aes(x=lon, y=lat, label=init),size = 5)+
  scale_shape_manual(values=c(15,16,17,18), label=c("A. antartica","H. nigricaulis", "P. australis", "Z. muelleri"))+
  scale_colour_manual(values=c("#000000","#8AA9CC","#009E73","#D55e00"),label=c("A. antartica","H. nigricaulis", "P. australis", "Z. muelleri"))+
  annotate("rect",
           xmin = 148.09, xmax = 148.37,
           ymin = -40.37, ymax = -40.17,
           color = "red", fill = NA, linewidth = 1) +
  annotation_north_arrow(style = north_arrow_orienteering, location = 'tl',  height = unit(2, "cm"), width = unit(1.5, "cm"))+
  annotation_scale(aes(width_hint=.4),location='bl',line_width = 1, height = unit(.5,"cm"),text_cex = 1.8)+
  theme(panel.background =element_rect(fill='white'),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        #axis.ticks = element_rect(colour="black"),
        axis.title = element_blank(),
        axis.text = element_text(size=15, colour="black"),
        legend.position.inside = c(.96,-500),
        legend.text = element_text(size=18, face="italic"),
        legend.title = element_text(size=20),
        legend.background = element_blank())
map_plot

#inset map
map_plot2 <- ggplot() +
  geom_sf(data=island,fill="grey", color="grey") +
  coord_sf(xlim=c(148.10,148.37),ylim=c(-40.37,-40.17)) +
  geom_point(data=sites2, aes(x=lon, y=lat, shape=Species, colour=Species),  size= 7,position=position_dodge(width = 0.05))+
  geom_text(data=sites2, aes(x=lon, y=lat, label=Population), vjust = -.7, hjust = 0.5, size = 7)+
  scale_shape_manual(values=c(15,16,17,18), label=c("A. antartica","H. nigricaulis", "P. australis", "Z. mulleri"))+
  scale_colour_manual(values=c("#000000","#8AA9CC","#009E73","#D55e00"),label=c("A. antartica","H. nigracaulis", "P. australis", "Z. muelleri"))+
  #annotation_north_arrow(style = north_arrow_orienteering, location = 't')+
  annotation_scale(aes(width_hint=.4),location='bl',line_width = 1, height = unit(.5,"cm"), text_cex = 1.8)+
  theme(panel.background =element_rect(fill='white'),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        panel.border = element_rect(color = "red", fill = NA, linewidth = 2),
        legend.position = "none")

map_plot2

#plot together
FI_map <- map_plot+inset_element(map_plot2, left=.6, right=1.3, top=1.18, bottom=.4)
FI_map
ggsave("Map_of_Sites.png",FI_map, height = 33, width = 30, units = "cm", dpi="print")   
