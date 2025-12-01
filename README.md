# NYC Pet Store Spatial Analysis: Identifying Underserved Markets for Pet Health Products

This repository contains a spatial analysis of the pet market in New York City, with a focus on identifying neighborhoods that are underserved by pet stores but have meaningful demand for pet-related products such as pet testing kits and veterinary services.

The project combines spatial data on pet stores, dog ownership, demographics, and income levels to provide data-driven recommendations on where new pet health products or retail locations could be introduced.

---

## 1. Research Question

**Where are the most promising neighborhoods in New York City to introduce new pet health products (e.g., pet testing kits), given existing pet store density, dog ownership, and income levels?**

More specifically:

- Where are pet stores currently concentrated?
- Which neighborhoods have relatively high dog ownership but few pet stores?
- How does income interact with pet store access to shape market potential?

---

## 2. Data

This project uses publicly available spatial and tabular data for New York City. The exact datasets may vary depending on the version of the project, but the core inputs include:

- **Pet stores / pet-related businesses**  
  Point locations of pet pharmacies, pet supply stores, or related retail.

- **Dog ownership**  
  Aggregated dog license counts by neighborhood or ZIP code.

- **Administrative boundaries**  
  NYC boroughs or Neighborhood Tabulation Areas (NTAs), used as the main spatial units.

- **Socioeconomic variables**  
  Population and income information at the neighborhood level.

All raw data files are intended to live in a `data/raw/` folder. Cleaned and merged files ready for analysis can be stored in `data/processed/`.

> Note: This is a teaching/portfolio project. Exact variable names and sources may be adjusted based on course materials and data availability.

---

## 3. Methods

The analysis is conducted in **R**, using spatial analysis and econometric tools. The main steps are:

### 3.1 Data Preparation

- Load spatial polygons for NYC neighborhoods.
- Load point data for pet stores and dog licenses.
- Aggregate pet store counts and dog ownership by neighborhood.
- Merge with income and population data.
- Construct variables such as:
  - Pet store density (stores per 10,000 residents)
  - Dog ownership rate (licenses per 1,000 residents)
  - Income level

### 3.2 Exploratory Spatial Analysis

- Create choropleth maps of:
  - Pet store density  
  - Dog ownership rate  
  - Income levels
- Visually inspect spatial patterns to identify obvious clusters or gaps.

### 3.3 Spatial Autocorrelation

To formally test whether pet store density is spatially clustered:

- **Global Moran’s I**  
  Tests whether high/low values of pet store density cluster in space.

- **Local Moran’s I (LISA)**  
  Identifies specific neighborhoods that belong to:
  - High–High clusters (many stores surrounded by many stores)
  - Low–Low clusters (few stores surrounded by few stores)
  - High–Low or Low–High outliers

These analyses use contiguity-based spatial weights (e.g., queen or rook neighbors).

### 3.4 Spatial Regression

To link pet store density with local demand and socioeconomic conditions:

- Fit baseline **OLS** models:  
  `pet_store_rate ~ dog_rate + median_income + pop_density + population + area_km2 + base_pet`
- Diagnose spatial autocorrelation in residuals.
- Fit **Spatial Lag (SAR/SLM)** and **Spatial Error (SEM)** models using the same predictors.
- Compare coefficients and model fit to assess:
  - How dog ownership and income affect pet store location
  - How strong spatial dependence is in the outcome

---

## 4. Key Findings (Summary)

The exact numerical results depend on the final data and model specification, but a typical pattern from this analysis is:

- **Pet stores are highly concentrated in Manhattan and parts of Brooklyn.**  
  These areas form **High–High clusters** in the LISA analysis. They are well-served but also very competitive markets.

- **Staten Island, outer Queens, and parts of the Bronx often show Low–Low clusters.**  
  These neighborhoods have few pet stores and are surrounded by other low-density areas. Some of them still show **moderate to high dog ownership** and sufficient income levels.

- **Spatial regression results usually support a positive relationship between dog ownership and pet store presence**, even after controlling for income and spatial dependence.

From a market perspective, this suggests that:

> **Underserved neighborhoods with moderate dog ownership and reasonable income—especially in Staten Island, eastern Queens, and some areas of the Bronx—may offer promising opportunities for introducing new pet health products or services.**

---

## 5. Repository Structure (Planned)

```text
nyc-pet-market-spatial-analysis/
├─ README.md                     # Project overview and documentation
├─ data/
│  ├─ raw/                       # Original input data (not committed here)
│  └─ processed/                 # Cleaned / aggregated data for analysis
├─ scrip

