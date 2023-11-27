## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true")
)

## ----eval = FALSE-------------------------------------------------------------
#  install.packages("rosmium")

## ----eval = FALSE-------------------------------------------------------------
#  # install.packages("remotes")
#  remotes::install_github("ipeaGIT/rosmium")

## ----eval = requireNamespace("ggplot2", quietly = TRUE) && identical(tolower(Sys.getenv("NOT_CRAN")), "true"), fig.width = 6, fig.height = 5.5----
library(rosmium)
library(ggplot2)

cur_pbf <- system.file("extdata/cur.osm.pbf", package = "rosmium")

cur_pbf_lines <- sf::st_read(cur_pbf, layer = "lines", quiet = TRUE)

ggplot(cur_pbf_lines) + geom_sf()

## ----eval = requireNamespace("ggplot2", quietly = TRUE) && identical(tolower(Sys.getenv("NOT_CRAN")), "true"), fig.width = 6, fig.height = 4.5----
# buffering the pbf bounding box 4000 meters inward and using the result
# extent to extract the osm data inside it. transforming the crs because
# inward buffers only work with projected crs

bbox <- sf::st_bbox(cur_pbf_lines)
bbox_polygon <- sf::st_as_sf(sf::st_as_sfc(bbox))
smaller_bbox_poly <- sf::st_buffer(sf::st_transform(bbox_polygon, 5880), -4000)
smaller_bbox_poly <- sf::st_transform(smaller_bbox_poly, 4326)

output_path <- extract(
  cur_pbf,
  smaller_bbox_poly,
  tempfile(fileext = ".osm.pbf"),
  spinner = FALSE
)

extracted_pbf_lines <- sf::st_read(output_path, layer = "lines", quiet = TRUE)

ggplot() +
  geom_sf(data = extracted_pbf_lines) +
  geom_sf(data = smaller_bbox_poly, color = "red", fill = NA)

## -----------------------------------------------------------------------------
# get all amenity nodes
output <- tags_filter(cur_pbf, "n/amenity", tempfile(fileext = ".osm.pbf"))
nodes <- sf::st_read(output, layer = "points", quiet = TRUE)
head(nodes$other_tags)

# get all objects (nodes, ways or relations) with an addr:* tag
output <- tags_filter(
  cur_pbf,
  "addr:*",
  tempfile(fileext = ".osm.pbf"),
  omit_referenced = TRUE,
  spinner = FALSE
)
nodes <- sf::st_read(output, layer = "points", quiet = TRUE)
head(nodes$other_tags)

## -----------------------------------------------------------------------------
# displays the content of the previous tags_filter() output in html format
show_content(output, spinner = FALSE)

## ----echo = FALSE-------------------------------------------------------------
knitr::include_graphics("../man/figures/filtered_file_content.png")

