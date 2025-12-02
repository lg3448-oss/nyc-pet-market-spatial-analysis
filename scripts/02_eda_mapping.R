############################################################
# 02_eda_mapping.R
# Choropleth maps for NYC Pet Store Project
############################################################

library(sf)
library(dplyr)
library(tmap)

#-----------------------------------------------------------
# 1. Load spatial data and merged attribute data
#-----------------------------------------------------------

nyc <- st_read("data/raw/nyct2020.shp")
nyc <- st_transform(nyc, 2263)

df <- read.csv("data/processed/nyc_pet_spatial_data.csv")
df$GEOID  <- as.character(df$GEOID)
nyc$GEOID <- as.character(nyc$GEOID)

nyc <- nyc |>
  left_join(df, by = "GEOID")

# Ensure output folders exist
if (!dir.exists("outputs")) dir.create("outputs")
if (!dir.exists("outputs/figures")) dir.create("outputs/figures")

############################################################
# 2. Pet store density map
############################################################

map_pet_store <- tm_shape(nyc) +
  tm_polygons(
    "pet_store_rate",
    style   = "quantile",
    palette = "Blues",
    title   = "Pet stores per 10,000 residents"
  ) +
  tm_layout(
    main.title     = "NYC Pet Store Density",
    legend.outside = TRUE
  )

tmap_save(
  map_pet_store,
  filename = "outputs/figures/pet_store_density_map.png",
  width = 2000, height = 2000, units = "px"
)

############################################################
# 3. Dog ownership rate map
############################################################

map_dog_rate <- tm_shape(nyc) +
  tm_polygons(
    "dog_rate",
    style   = "quantile",
    palette = "Greens",
    title   = "Dog licenses per 1,000 residents"
  ) +
  tm_layout(
    main.title     = "NYC Dog Ownership Rate",
    legend.outside = TRUE
  )

tmap_save(
  map_dog_rate,
  filename = "outputs/figures/dog_rate_map.png",
  width = 2000, height = 2000, units = "px"
)

############################################################
# 4. Median income map (optional)
############################################################

map_income <- tm_shape(nyc) +
  tm_polygons(
    "median_income",
    style   = "quantile",
    palette = "Purples",
    title   = "Median income"
  ) +
  tm_layout(
    main.title     = "Median Income by Tract",
    legend.outside = TRUE
  )

tmap_save(
  map_income,
  filename = "outputs/figures/income_map.png",
  width = 2000, height = 2000, units = "px"
)

############################################################
# END OF SCRIPT
############################################################
