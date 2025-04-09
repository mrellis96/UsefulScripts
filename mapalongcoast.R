#Needs more debugging!! - maight be plotting straight line

dist_along_coast <- function(coast, points){
# Convert polygon to LINESTRING (coastline extraction)
coastline <- coast %>% st_geometry() %>% st_cast("MULTILINESTRING") %>% st_cast("LINESTRING")
# Convert points to sf object
points_sf <- st_as_sf(points, coords = c("lon", "lat"), crs = 4326)

# Snap points to nearest coastline
snapped_points <- st_nearest_points(points_sf, coastline)

# Extract only the last coordinate of the snapped line (actual snapped point)
snapped_coords <- lapply(1:length(points_sf$id), function(i) { 
  coords <- st_coordinates(snapped_points[i]) 
  coords[nrow(coords), ] 
})
snapped_sf <- st_as_sf(data.frame(id = points$id, lon = sapply(snapped_coords, "[", 1), lat = sapply(snapped_coords, "[", 2)), coords = c("lon", "lat"), crs = 4326)

# Compute coastal distances
num_points <- nrow(snapped_sf)
distances_matrix <- matrix(NA, nrow = num_points, ncol = num_points)
coords_matrix <- st_coordinates(snapped_sf)

# Calculate distances
for (i in 1:(num_points - 1)) { 
  for (j in (i + 1):num_points) {
    point1 <- as.numeric(coords_matrix[i, ])  
    point2 <- as.numeric(coords_matrix[j, ])
    
    if (!is.na(point1[1]) && !is.na(point2[1]) && abs(point1[2]) <= 90 && abs(point2[2]) <= 90) { 
      distances_matrix[i, j] <- distVincentySphere(point1, point2)  
      distances_matrix[j, i] <- distances_matrix[i, j]  # Symmetric
    }
  }
}

# Convert distances matrix to a data frame with original point IDs (upper triangular part)
distances_df <- as.data.frame(as.table(distances_matrix))
colnames(distances_df) <- c("Point1", "Point2", "Distance_m")

# Remove the diagonal (where Point1 == Point2)
distances_df <- distances_df[distances_df$Point1 != distances_df$Point2, ]

# Create all combinations of Point1 and Point2
id_combinations <- expand.grid(Point1 = snapped_sf$id, Point2 = snapped_sf$id)
id_combinations <- id_combinations[id_combinations$Point1 != id_combinations$Point2, ]

# Ensure the number of rows in distances_df and id_combinations match
distances_df$Point1 <- id_combinations$Point1
distances_df$Point2 <- id_combinations$Point2

# Print the distances dataframe
#print(distances_df)
unique_points <- unique(c(distances_df$Point1, distances_df$Point2))

# Initialize an empty distance matrix
distance_matrix <- matrix(NA, nrow = length(unique_points), ncol = length(unique_points),
                          dimnames = list(unique_points, unique_points))

# Fill in the matrix with distances
for (i in 1:nrow(distances_df)) {
  p1 <- distances_df$Point1[i]
  p2 <- distances_df$Point2[i]
  dist <- distances_df$Distance_m[i]
  
  # Assign distance symmetrically
  distance_matrix[p1, p2] <- dist
  distance_matrix[p2, p1] <- dist
}

# Set diagonal to 0 (self-distance)
diag(distance_matrix) <- 0

# Convert to a matrix and print
distance_matrix <- as.matrix(distance_matrix)
print(distance_matrix)
}

