############################################################
# 03_spatial_autocorrelation.R
# Global Moran's I and Local Moran's I (LISA)
# for NYC Pet Store Project
############################################################

library(sf)
library(dplyr)
library(spdep)
library(tmap)

#-----------------------------------------------------------
# 1. Load data
#-----------------------------------------------------------

nyc <- st_read("data/raw/nyct2020.shp")
nyc <- st_transform(nyc, 2263)

df <- read.csv("data/processed/nyc_pet_spatial_data.csv")
df$GEOID  <- as.character(df$GEOID)
nyc$GEOID <- as.character(nyc$GEOID)

nyc <- nyc |>
  left_join(df, by = "GEOID")

# Output folders
if (!dir.exists("outputs")) dir.create("outputs")
if (!dir.exists("outputs/figures")) dir.create("outputs/figures")
if (!dir.exists("outputs/tables")) dir.create("outputs/tables")

############################################################
# 2. Build spatial weights (Queen contiguity)
############################################################

nb <- poly2nb(nyc)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)

############################################################
# 3. Global Moran's I
############################################################

pet_rate <- nyc$pet_store_rate

moran_global <- moran.test(pet_rate, lw, zero.policy = TRUE)
print(moran_global)

sink("outputs/tables/Morans_I_global.txt")
print(moran_global)
sink()

# Moran scatterplot
png("outputs/figures/moran_scatterplot.png",
    width = 2000, height = 2000)
moran.plot(
  pet_rate, lw, zero.policy = TRUE,
  xlab = "Pet store rate",
  ylab = "Spatial lag of pet store rate",
  main = "Moran Scatterplot: Pet Store Density"
)
dev.off()

############################################################
# 4. Local Moran's I (LISA)
############################################################

local_moran <- localmoran(pet_rate, lw, zero.policy = TRUE)
local_moran <- as.data.frame(local_moran)
names(local_moran) <- c("Ii", "Ei", "Vi", "Zi", "Pi")

nyc <- nyc |>
  mutate(
    moran_I = local_moran$Ii,
    moran_Z = local_moran$Zi,
    moran_p = local_moran$Pi
  )

# LISA quadrant classification
mean_pet <- mean(pet_rate, na.rm = TRUE)
lag_pet  <- lag.listw(lw, pet_rate, zero.policy = TRUE)
mean_lag <- mean(lag_pet, na.rm = TRUE)

nyc <- nyc |>
  mutate(
    quadrant = case_when(
      pet_store_rate >= mean_pet & lag_pet >= mean_lag & moran_p <= 0.05 ~ "High-High",
      pet_store_rate <= mean_pet & lag_pet <= mean_lag & moran_p <= 0.05 ~ "Low-Low",
      pet_store_rate >= mean_pet & lag_pet <= mean_lag & moran_p <= 0.05 ~ "High-Low",
      pet_store_rate <= mean_pet & lag_pet >= mean_lag & moran_p <= 0.05 ~ "Low-High",
      TRUE ~ "Not significant"
    )
  )

# Save LISA table
lisa_df <- nyc |>
  st_drop_geometry() |>
  select(GEOID, pet_store_rate, moran_I, moran_Z, moran_p, quadrant)

write.csv(
  lisa_df,
  "outputs/tables/LISA_results.csv",
  row.names = FALSE
)

############################################################
# 5. LISA cluster map
############################################################

nyc$quadrant <- factor(
  nyc$quadrant,
  levels = c("High-High", "Low-Low", "High-Low", "Low-High", "Not significant")
)

lisa_map <- tm_shape(nyc) +
  tm_polygons(
    "quadrant",
    title = "LISA clusters",
    palette = c(
      "High-High"       = "red",
      "Low-Low"         = "blue",
      "High-Low"        = "orange",
      "Low-High"        = "lightblue",
      "Not significant" = "grey90"
    )
  ) +
  tm_layout(
    main.title     = "Local Moran's I (LISA) – Pet Store Density",
    legend.outside = TRUE
  )

tmap_save(
  lisa_map,
  filename = "outputs/figures/lisa_clusters_map.png",
  width = 2000, height = 2000, units = "px"
)

############################################################
# END OF SCRIPT
############################################################
