library(galah)
galah_config(atlas='ALA',email = "morgan.e@deakin.edu.au")
result <- galah_call() |>
  identify("Asterias amurensis") |>
 # filter(year >= 2015, cl22 == "Victoria") |>
  select(basisOfRecord, group = "basic") |>
  collect()

result |> head()
library(sf)
library(ggplot2)
library(ggspatial)
aus <-  read_sf('~/Documents/basemap/Aus Shape File/AUS_2021_AUST_GDA2020.shp') #basemap
#sites <- read.csv('sites.csv', head=T, sep=",") #to add points to map

lab_dates <- pretty(result$eventDate)
map_plot <- ggplot() +
  geom_sf(data=aus,fill="grey", color="grey") +
  coord_sf(xlim=c(144.358178,145.157496), ylim=c(-38.474281,-37.851734)) + #change to extent of map
  geom_point(data=result, aes(x=decimalLongitude, y=decimalLatitude, colour=as.numeric(eventDate)), shape=16, size= 3)+ #add points from data
  annotation_north_arrow(style = north_arrow_orienteering, location = 'tl')+
#  annotation_scale(location='bl')+
  scale_colour_viridis_c(breaks = as.numeric(lab_dates), 
                         labels = lab_dates)+
  theme(panel.background =element_rect(fill='white'),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank())
map_plot

