############################################################
# 04_spatial_regression.R
# Spatial Lag & Spatial Error Models – NYC Pet Store Project
#
# This script:
# 1) Loads NYC census tract polygons and merged pet/socioeconomic data
# 2) Builds spatial weights based on polygon contiguity
# 3) Estimates OLS, Spatial Lag (SLM), and Spatial Error (SEM) models
# 4) Saves model summaries and AIC comparison to the outputs folder
############################################################

### --------------------------------------------------------
### 0. Packages
### --------------------------------------------------------
library(sf)
library(dplyr)
library(spdep)
library(spatialreg)

### --------------------------------------------------------
### 1. Load spatial data
### --------------------------------------------------------
nyc <- st_read("data/raw/nyct2020.shp")
nyc <- st_transform(nyc, 2263)

# Load merged CSV
df <- read.csv("data/processed/nyc_pet_spatial_data.csv")

df$GEOID  <- as.character(df$GEOID)
nyc$GEOID <- as.character(nyc$GEOID)

# Join attributes
nyc <- nyc |> left_join(df, by = "GEOID")

### --------------------------------------------------------
### 2. Build spatial weights (Queen contiguity)
### --------------------------------------------------------
nb <- poly2nb(nyc)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)

### --------------------------------------------------------
### 3. Select variables for modeling
### --------------------------------------------------------
vars_for_model <- c(
  "pet_store_rate",   # dependent variable
  "dog_rate",
  "median_income",
  "pop_density",
  "population",
  "area_km2",
  "base_pet"
)

print(vars_for_model %in% names(nyc))

model_data <- as.data.frame(nyc)
model_data <- model_data[, vars_for_model]

# Create output folder if not exists
if (!dir.exists("outputs")) dir.create("outputs")
if (!dir.exists("outputs/tables")) dir.create("outputs/tables")

# Save clean model data
write.csv(
  model_data,
  "outputs/tables/model_data_spatial_regression.csv",
  row.names = FALSE
)

############################################################
### 4. OLS Model
############################################################

ols_model <- lm(
  pet_store_rate ~ dog_rate + median_income +
    pop_density + population + area_km2 + base_pet,
  data = model_data
)

ols_summary <- summary(ols_model)
print(ols_summary)

sink("outputs/tables/OLS_results.txt")
print(ols_summary)
sink()

############################################################
### 5. Spatial Lag Model (SLM)
############################################################

lag_model <- lagsarlm(
  pet_store_rate ~ dog_rate + median_income +
    pop_density + population + area_km2 + base_pet,
  data = model_data,
  listw = lw,
  zero.policy = TRUE
)

lag_summary <- summary(lag_model)
print(lag_summary)

sink("outputs/tables/Spatial_Lag_results.txt")
print(lag_summary)
sink()

############################################################
### 6. Spatial Error Model (SEM)
############################################################

error_model <- errorsarlm(
  pet_store_rate ~ dog_rate + median_income +
    pop_density + population + area_km2 + base_pet,
  data = model_data,
  listw = lw,
  zero.policy = TRUE
)

error_summary <- summary(error_model)
print(error_summary)

sink("outputs/tables/Spatial_Error_results.txt")
print(error_summary)
sink()

############################################################
### 7. AIC Comparison
############################################################

aic_table <- AIC(ols_model, lag_model, error_model)
print(aic_table)

sink("outputs/tables/Model_AIC_comparison.txt")
print(aic_table)
sink()

############################################################
# END OF SCRIPT
############################################################
