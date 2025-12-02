############################################################
# 04_spatial_regression.R
# OLS, Spatial Lag, and Spatial Error Models
# for NYC Pet Store Project
############################################################

library(sf)
library(dplyr)
library(spdep)
library(spatialreg)

#-----------------------------------------------------------
# 1. Load spatial and attribute data
#-----------------------------------------------------------

nyc <- st_read("data/raw/nyct2020.shp")
nyc <- st_transform(nyc, 2263)

df <- read.csv("data/processed/nyc_pet_spatial_data.csv")
df$GEOID  <- as.character(df$GEOID)
nyc$GEOID <- as.character(nyc$GEOID)

nyc <- nyc |>
  left_join(df, by = "GEOID")

#-----------------------------------------------------------
# 2. Spatial weights
#-----------------------------------------------------------

nb <- poly2nb(nyc)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)

#-----------------------------------------------------------
# 3. Variables for modeling
#-----------------------------------------------------------

vars_for_model <- c(
  "pet_store_rate",
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

if (!dir.exists("outputs")) dir.create("outputs")
if (!dir.exists("outputs/tables")) dir.create("outputs/tables")

write.csv(
  model_data,
  "outputs/tables/model_data_spatial_regression.csv",
  row.names = FALSE
)

############################################################
# 4. OLS model
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
# 5. Spatial Lag Model (SLM)
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
# 6. Spatial Error Model (SEM)
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
# 7. AIC comparison
############################################################

aic_table <- AIC(ols_model, lag_model, error_model)
print(aic_table)

sink("outputs/tables/Model_AIC_comparison.txt")
print(aic_table)
sink()

############################################################
# END OF SCRIPT
############################################################

