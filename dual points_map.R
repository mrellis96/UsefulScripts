library(sf)
library(ggplot2)
library(ggspatial)
library(ggnewscale)
library(patchwork)

aus <-  read_sf('~/Documents/basemap/Aus Shape File/AUS_2021_AUST_GDA2020.shp')
sites <- read.csv('Wadawurrung sites.csv', head=T, sep=",")
sites$edna <- as.factor(sites$edna)
sites$delim <- as.factor(sites$delim)
sites$edna <- factor(sites$edna, levels = c('1','0'))
sites$delim <- factor(sites$delim, levels = c('1','0'))

map_plot <- ggplot() +
  geom_sf(data=aus,fill="grey", color="grey") +
  coord_sf(xlim=c(144.358178,145.157496), ylim=c(-38.474281,-37.851734)) +
  geom_point(data=sites, aes(x=Lon, y=Lat, colour=edna), shape=15,  size= 3)+
  scale_colour_manual(values=c("blue",'red'), labels = c('Y','N'))+
  new_scale_color()+
  geom_point(data=sites, aes(x=Lon, y=Lat, colour=delim), shape=16,  size= 3, position = position_dodge(width=0.03, preserve='single'))+
  scale_colour_manual(values=c("blue",'red'), labels = c('Y','N'))+
  annotation_north_arrow(style = north_arrow_orienteering, location = 'tl')+
  annotation_scale(location='bl')+
  theme(panel.background =element_rect(fill='white'),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
       # axis.ticks = element_blank(),
        axis.title = element_blank(),
      #  axis.text = element_blank(),
        legend.position.inside = c(.96,0.56),
        legend.text = element_text(size=13),
        legend.title = element_text(size=14),
        legend.background = element_blank())
map_plot

aus_plot <- ggplot() +
  geom_sf(data=aus,fill="grey", color="grey") +
  coord_sf(xlim=c(114.5, 153), ylim=c(-10,-43)) +
  geom_rect(aes(xmin = 144.358178, xmax = 145.157496, ymin = -38.474281, ymax = -37.851734), color = "red", fill = NA)  +
    theme(panel.background =element_rect(fill='white'),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        legend.position.inside = c(.96,0.56),
        legend.text = element_text(size=13),
        legend.title = element_text(size=14),
        legend.background = element_blank(),
        panel.border = element_rect(colour="black", linewidth = 2, fill=NA))
aus_plot

map_plot + inset_element(aus_plot, left = 0, bottom=0, right =  .4, top = .4, align_to = 'panel', clip=TRUE)    
