library(gdistance)
library(sf)
library(raster)
library(terra)
library(leaflet)
library(dartRverse)
library(sp)
library(geosphere)
library(tmap)
library(maptiles)
library(ggplot2)
library(ggspatial)
library(ggrepel)



test <- read_sf("Westernport_Merged.shp")
locs <- read.csv("locations.csv")


template = rast(vect(test),res=0.001)

test_raster <- rasterize(vect(test), template,"id")
plot(test_raster)

my_crs <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"

test_raster.merc <- project(test_raster, crs(my_crs))
plot(test_raster.merc)


res.land <- test_raster.merc
#res.land[res.land==0] <- 1
#res.land[res.land!=1] <- 50
#res.land[is.nan(res.land)] <- 100
names(res.land) <- "land50"
plot(res.land)
res.land



r <- as(res.land, "Raster")
tr <- transition(r, mean, directions=16) # Create transition layer
tr <- geoCorrection(tr, type = "c")


from_sf <- st_as_sf(locs, coords = c("Longtitude", "Latitude"), crs = 4326)
from_m  <- st_transform(from_sf, my_crs)
from_pts_m <- st_coordinates(from_m) # Extract the new X/Y matrix


all_routes_list <- list()
route_data <- data.frame()

for (i in 1:nrow(from_pts_m)) {
  for (j in 1:nrow(from_pts_m)) {

    route <- try(shortestPath(tr, 
                              as.matrix(from_pts_m[i, 1:2, drop=F]), 
                              as.matrix(from_pts_m[j, 1:2, drop=F]), 
                              output = "SpatialLines"), silent = TRUE)
    
    if (!inherits(route, "try-error")) {
      # Add to spatial list
      route@lines[[1]]@ID <- paste0("r_", i, "_", j)
      all_routes_list[[length(all_routes_list) + 1]] <- route
      
      # RECORD NAMES AND LENGTH HERE
      route_data <- rbind(route_data, data.frame(
        from = locs$Location[i],
        to = locs$Location[j],
        length_km = as.numeric(st_length(st_as_sf(route))) / 1000
      ))
    }
  }
}

# 2. Pivot the 'route_data' into your matrix
library(tidyr)
final_matrix <- route_data %>%
  pivot_wider(names_from = to, values_from = length_km) %>%
  as.data.frame()

# Set row names and remove the 'from' column
rownames(final_matrix) <- final_matrix$from
final_matrix <- as.matrix(final_matrix[, -1])

print(final_matrix)

#plot map
all_routes_sp <- do.call(rbind, all_routes_list)
proj4string(all_routes_sp) <- CRS(my_crs)
all_routes_sf <- st_as_sf(all_routes_sp)
res_df <- as.data.frame(res.land, xy = TRUE, na.rm = FALSE)


coords <- st_coordinates(from_m)
label_df <- cbind(from_m, coords)

ggplot() +
  geom_raster(data = res_df, aes(x = x, y = y, fill = land50)) +
  scale_fill_continuous(palette = c("gray","white"))+
  geom_sf(data = all_routes_sf, colour = "blue", linewidth = 0.7) +
  geom_sf(data = from_m, colour = "black", size = 2) +
  coord_sf()+
  annotation_scale()+
  annotation_north_arrow(location ="tl")+
  theme_minimal()+
  theme(legend.position = "none",
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        panel.grid=element_blank()
        )


