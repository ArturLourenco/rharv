# Regenerates the bundled datasets `precip_pi` and `areas_pi`.
# Run with the package as the working directory:
#   source("data-raw/DATASETS.R")

raw <- "data-raw/raw"

# precip_pi: daily precipitation, Princesa Isabel (ANA/AESA station 738013)
e <- new.env()
load(file.path(raw, "precipdata.RData"), envir = e)
z <- e$pi_plu_ser_1911_2019_full
z <- zoo::na.fill(z, 0)            # treat remaining gaps as dry days
z[as.Date("2016-06-30")] <- 18.9  # known point correction (see case study)
yrs <- as.integer(format(zoo::index(z), "%Y"))
z <- z[!yrs %in% c(1911, 1992, 1993)]  # drop fully-missing years
precip_pi <- data.frame(
  date = as.Date(zoo::index(z)),
  value = as.numeric(zoo::coredata(z))
)
rownames(precip_pi) <- NULL

# areas_pi: catchment (roof) areas of the IFPB-PI campus blocks
a <- sf::st_read(file.path(raw, "building_area.shp"), quiet = TRUE)
ad <- sf::st_drop_geometry(a)
areas_pi <- data.frame(
  block = enc2utf8(as.character(ad$nome)),
  area_m2 = as.numeric(ad$area)
)
areas_pi <- areas_pi[order(-areas_pi$area_m2), ]
rownames(areas_pi) <- NULL

usethis::use_data(precip_pi, areas_pi, overwrite = TRUE, compress = "xz")
