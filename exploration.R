# Data Exploration
library(raster)
library(tidyverse)
library(tmap)
library(ggmap)
library(mongolite)
library(lubridate)
library(jsonlite)

office <- c('Gramophone', 'Walkman')[2]
data_path <- switch(office,
                    'Gramophone' = '/home/dmasson/data/OpenDataDayZurich2016/',
                    'Walkman' = '/home/dmasson/data/OpenDataDayZurich2016/')


# ggmap
zlon <- 8+33/60
zlat <- 47+22/60
zurich_map <- get_map(location = c(lon = zlon, lat = zlat), zoom = 13, scale = 1,
                      maptype = 'toner')
ggmap(zurich_map)

# tmap
shpfiles <- data_frame(
  Fussgaengerzone = 'shapefiles/fussgaengerzone/Fussgaengerzone.shp',
  Fahrverbotszone = 'shapefiles/fahrverbotszone/Fahrverbotszone.shp',
  Stadtkreis = 'shapefiles/stadtkreis/Stadtkreis.shp'
  )
shp <- shapefile(paste0(data_path, 
                        # shpfiles$Fussgaengerzone
                        shpfiles$Stadtkreis
                        ))
str(shp@data, max.level = 2)
tm_shape(shp = shp, is.master = T) + tm_polygons(
  # col = 'ZONENNAME'
  col = 'KNAME'
  )

# VBZ data
f1 <- paste0(data_path,'data/delay_data/fahrzeitensollist2015092020150926.csv')
df1 <- read_csv(file = f1)
times <- df1$betriebsdatum %>% unique()

# Explore data inserted in MongoDB
con <- mongo(collection = 'fahrzeitensollist', db = 'VBZ')

con$count()
infos <- con$info() %>% .$stats

fo <- con$find(limit = 1)

qry <- list(linie = 10,
            betriebsdatum = '2015-10-04' %>% ymd()) %>% 
  toJSON(auto_unbox=T, POSIXt = "mongo")
res <- con$find(query = qry)

# Topographic SRTM data
fl <- paste0(data_path,'srtm_38_03/srtm_38_03.tif')
rtopo <- raster(fl)
b <- as(extent(zlon-0.03, zlon+0.03, zlat-0.02, zlat+0.02), 'SpatialPolygons')
crs(b) <- crs(rtopo)
rtzh <- rtopo %>% crop(b)
plot(rtzh)

# Weather data
