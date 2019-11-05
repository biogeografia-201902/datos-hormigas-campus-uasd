#Resolución parcelas
library(foreign)
library(sf)
library(tidyverse)
library(readr)
parcelastipo <- read.dbf('buffer/c50mpctgrp.dbf')
parcelastipo_sf <- st_read('buffer/c50mpctgrp.shp')
parcelastipo_sf <- parcelastipo_sf %>% mutate(parcela = paste0('p', layer)) %>% 
  mutate(tipo = recode(grp,
                       '1' = 'pavimentado, acerado (bordes edificios, bancos, postes)',
                       '2' = 'edificación erguida',
                       '3' = 'suelo, herbáceas, no edificado ni cubierto',
                       '4' = 'dosel')) %>% 
  dplyr::select(parcela, tipo)
st_write(parcelastipo_sf, dsn = 'export/parcelas_tipo.gpkg', driver = 'GPKG')
saveRDS(parcelastipo_sf, 'export/parcelas_tipo.RDS')
parcelastipo_sf %>% st_drop_geometry() %>% write_csv('export/parcelas_tipo.csv')
