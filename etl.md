
<!-- Este .md fue generado a partir del .Rmd homónimo. Edítese el .Rmd -->

# Extraer, transformar y cargar (ETL) base de datos de ODK sobre colectas de campo e identificación de hormigas en el campus de la UASD para la asignatura “Biogeografía”, semestre 2019-02, licenciatura en Geografía, UASD.

## Acceso a servidor

``` bash
#En PC local
ssh <USUARIO>@<SERVIDOR>
#En ODK aggregate server
sudo -i -u postgres
psql
##Cambiar path de usuario postgres en aggregate (sólo una vez):
###ALTER ROLE postgres SET search_path TO aggregate,public;
###\q
###psql
```

## Generación de consultas y exportar a CSV

``` sql
\c aggregate
/*HABITAT*/
COPY (
SELECT "CODIGO" codigomuestra, "PARCELA" parcela, "_CREATOR_URI_USER" usuariohab,
 "_CREATION_DATE" fechacreacionhab, "_SUBMISSION_DATE" fechaenviohab, "_URI" idodkhabitat,
 "HORAINICIO" horainicio, "HORAFINAL" horafinal, "COORDENADAID_LNG" longitud, "COORDENADAID_LAT" latitud,
 "COORDENADAID_ALT" elevacion, "COORDENADAID_ACC" precisioncoords, "LOCALIDADID" localidad,
 "INFOAMB_DISTANCIABASURA" distanciaabasura, "INFOAMB_DISTANCIAAGUA" distanciaagua,
 "INFOAMB_DISTANCIACAMINOSCALLES" distanciavias, "INFOAMB_ACTIVIDADPERSONAS" actividadpersonas,
 "ACTIVIDADCEBOSG_CEBO1" actividadcebo1, "ACTIVIDADCEBOSG_CEBO2" actividadcebo2,
 "ACTIVIDADCEBOSG_CEBO3" actividadcebo3, "ACTIVIDADCEBOSG_CEBO4" actividadcebo4,
 "COLECTAREALIZADAENFECHA" fechacolecta, "COLECTORESG_OTRASPERSONAS" otroscolectores,
 "OBSERVACIONES" observaciones, "PLANTAS" plantas, 
 idparentalcolec, siglascolectores,
 idparentaltiposdecebo, tiposdecebo,
 idparentalcebosbajo, cebosbajo,
 idparentalcebossobre, cebossobre,
 idparentalcebosotrosele, cebosotrosele
 FROM "HORMIGASUASDHABITAT_CORE" habitatcore
 INNER JOIN (SELECT "_PARENT_AURI" idparentalcolec, string_agg("VALUE", ',') siglascolectores
 FROM  "HORMIGASUASDHABITAT_COLECTORESG_COLECTORES"
 GROUP BY idparentalcolec) AS tcolectores
 ON tcolectores.idparentalcolec=habitatcore."_URI"
 INNER JOIN (SELECT "_PARENT_AURI" idparentaltiposdecebo, string_agg("VALUE", ',') tiposdecebo
 FROM  "HORMIGASUASDHABITAT_INFOAMB_TIPOSDECEBO"
 GROUP BY idparentaltiposdecebo) AS ttiposdecebo
 ON ttiposdecebo.idparentaltiposdecebo=habitatcore."_URI"
 INNER JOIN (SELECT "_PARENT_AURI" idparentalcebosbajo, string_agg("VALUE", ',') cebosbajo
 FROM  "HORMIGASUASDHABITAT_INFOAMB_CEBOSBAJO"
 GROUP BY idparentalcebosbajo) AS tcebosbajo
 ON tcebosbajo.idparentalcebosbajo=habitatcore."_URI"
 INNER JOIN (SELECT "_PARENT_AURI" idparentalcebossobre, string_agg("VALUE", ',') cebossobre
 FROM  "HORMIGASUASDHABITAT_INFOAMB_CEBOSSOBRE"
 GROUP BY idparentalcebossobre) AS tcebossobre
 ON tcebossobre.idparentalcebossobre=habitatcore."_URI"
 INNER JOIN (SELECT "_PARENT_AURI" idparentalcebosotrosele, string_agg("VALUE", ',') cebosotrosele
 FROM  "HORMIGASUASDHABITAT_INFOAMB_CEBOSOTROSELE"
 GROUP BY idparentalcebosotrosele) AS tcebosotrosele
 ON tcebosotrosele.idparentalcebosotrosele=habitatcore."_URI")
 TO '/tmp/colecta_habitat.csv' DELIMITER ',' NULL AS 'NULL' csv header;

/*NIDOS*/
COPY (
SELECT "CODIGO" codigomuestra, "PARCELA" parcela, "_CREATOR_URI_USER" usuarionid,
 "_CREATION_DATE" fechacreacionnid, "_SUBMISSION_DATE" fechaenvionid, "_URI" idodknidos,
 "HORA" horainicio, "COORDENADAID_LNG" longitud, "COORDENADAID_LAT" latitud,
 "COORDENADAID_ALT" elevacion, "COORDENADAID_ACC" precisioncoords, "LOCALIDADID" localidad,
 "INFOAMB_DISTANCIABASURA" distanciaabasura, "INFOAMB_DISTANCIAAGUA" distanciaagua,
 "INFOAMB_DISTANCIACAMINOSCALLES" distanciavias,
 "COLECTAREALIZADAENFECHA" fechacolecta, "COLECTORESG_OTRASPERSONAS" otroscolectores,
 "OBSERVACIONES" observaciones, "PLANTAS" plantas, 
 idparentalcolec, siglascolectores
 FROM "HORMIGASUASDNIDOS_CORE" habitatcore
 LEFT JOIN (SELECT "_PARENT_AURI" idparentalcolec, string_agg("VALUE", ',') siglascolectores
 FROM  "HORMIGASUASDNIDOS_COLECTORESG_COLECTORES"
 GROUP BY idparentalcolec) AS tcolectores
 ON tcolectores.idparentalcolec=habitatcore."_URI")
 TO '/tmp/colecta_nidos.csv' DELIMITER ',' NULL AS 'NULL' csv header;

/*IDENTIFICACIONES*/
COPY (
SELECT "DATOSCOLECTA_CODIGO" codigomuestra, "DATOSCOLECTA_PARCELA" parcela, "_CREATOR_URI_USER" usuarioident,
 "_CREATION_DATE" fechacreacionident, "_SUBMISSION_DATE" fechaenvioident, "_URI" idodkident,
 "DATOSCOLECTA_IDENTIFICACIONREALIZADAENFECHA" fechaidentificacion,
 identificadores, "DATOSCOLECTA_OTROSIDENTIFICADORES" otrosidentificadores,
 idparentalidentificaciones, identificaciones
 FROM "HORMIGASUASDID_CORE" identificacionescore
 INNER JOIN (SELECT "_PARENT_AURI" idparentalidentificadores, string_agg("VALUE", ',') identificadores
 FROM  "HORMIGASUASDID_DATOSCOLECTA_IDENTIFICACIONREALIZADAPOR"
 GROUP BY idparentalidentificadores) AS tidentificadores
 ON tidentificadores.idparentalidentificadores=identificacionescore."_URI"
 INNER JOIN (SELECT "_PARENT_AURI" idparentalidentificaciones, string_agg(distinct "ESPECIEID", ',') identificaciones
 FROM  "HORMIGASUASDID_ESPECIES"
 GROUP BY idparentalidentificaciones) AS tidentificaciones
 ON tidentificaciones.idparentalidentificaciones=identificacionescore."_URI") 
 TO '/tmp/identificaciones.csv' DELIMITER ',' NULL AS 'NULL' csv header;
```

## Archivos desde servidor a cliente local

``` bash
cd <CARPETA PARA ALOJAR LOS .CSV PROCEDENTES DEL SERVIDOR>
scp <USUARIO>@<SERVIDOR>:/tmp/*.csv .
```

## Paquetes

``` r
library(tidyverse)
## ── Attaching packages ────────── tidyverse 1.2.1 ──
## ✔ ggplot2 3.2.1     ✔ purrr   0.3.2
## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
## ✔ readr   1.3.1     ✔ forcats 0.4.0
## ── Conflicts ───────────── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
library(lubridate)
## 
## Attaching package: 'lubridate'
## The following object is masked from 'package:base':
## 
##     date
```

## Lectura en R, importar

``` r
colhab <- read_csv('buffer/colecta_habitat.csv')
colnid <- read_csv('buffer/colecta_nidos.csv')
ident <- read_csv('buffer/identificaciones.csv')
nomlat <- read_csv('equivalencia_etiqueta_nombre_latino.csv')
```

## Eliminar formularios de prueba

``` r
colhab <- colhab %>% filter(!grepl('PROBANDO', observaciones)) %>%
  filter(!grepl('jimenezsosa', usuariohab))
colnid <- colnid %>% filter(!grepl('Probando', observaciones))
View(colhab %>% arrange(usuariohab, codigomuestra))
View(colnid %>% arrange(usuarionid, codigomuestra))
View(ident)
source('ver_datos_usuario_habitat.R')
source('ver_datos_usuario_nidos.R')
source('ver_exportar_tablas.R')
```

## Hábitat

### Bidelkis

``` r
verhab(x='bidelk')
#Parcela 126 no aparece en ident. Quizá no había hormigas en ella.
#Corrección error codigomuestra
ident <- ident %>%
  mutate(codigomuestra = ifelse(codigomuestra=='20190927B2'&grepl('bidelk', usuarioident), '20190928B2', codigomuestra))
#Visualizar resultado
bidelkis <- colhab %>% filter(grepl('bidelk', usuariohab)) %>%
  left_join(ident %>% filter(grepl('bidelk', usuarioident))) %>% 
  mutate(fechaidentificacion=as_date(fechaidentificacion))
verexp(bidelkis)
```

### Emma

``` r
verhab(x='emdil')
#¡NADA QUE CORREGIR EN LOS CÓDIGOS DE MUESTRAS!
#Corrigiendo la fecha de identificación, a petición de la dueña de los datos
ident <- ident %>%
  mutate(fechaidentificacion = if_else(codigomuestra=='20191014M07'&grepl('emdil', usuarioident), as_date('2019-10-17'), as_date(fechaidentificacion)))
#Visualizar resultado
emma <- colhab %>% filter(grepl('emdil', usuariohab)) %>%
  left_join(ident %>% filter(grepl('emdil', usuarioident)))
verexp(emma)
```

### Jorge

``` r
verhab(x='jorge')
#No hay datos de identificación subidos a ODK
#Visualizar resultado
jorge <- colhab %>% filter(grepl('jorge', usuariohab)) %>%
  left_join(ident %>% filter(grepl('jorge', usuarioident)))
verexp(jorge)
```

### Miguel

``` r
verhab(x='mangoland')
#Eliminar los registros "otra" de la tabla de identificación, pues se trata de muestras sin ocurrencias. Eliminar también registro duplicado con codigomuestra "m1"
colhab <- colhab %>% mutate(
  parcela = case_when(
    codigomuestra == 'H20191012m2' & grepl('mangoland', usuariohab) ~ 'p107',
    codigomuestra == 'H20191012m4' & grepl('mangoland', usuariohab) ~ 'p104',
    codigomuestra == 'H20191012m5' & grepl('mangoland', usuariohab) ~ 'p16',
    codigomuestra == 'H20191012m6' & grepl('mangoland', usuariohab) ~ 'p28',
    codigomuestra == 'H20191012m7' & grepl('mangoland', usuariohab) ~ 'p178',
    TRUE ~ parcela
  ))
ident <- ident %>% filter(
  !(grepl('mangoland', usuarioident) &
    grepl('H20191012m4|H20191013m9|H20191013m11|^m1$', codigomuestra)))
#Corregir coordenada
colhab <- colhab %>% mutate(
  longitud = case_when(
    codigomuestra == 'H20190914m1' & grepl('mangoland', usuariohab) ~ -69.91789,
    codigomuestra == 'H20191012m3' & grepl('mangoland', usuariohab) ~ -69.92021,
    TRUE ~ longitud
  ),
  latitud = case_when(
    codigomuestra == 'H20190914m1' & grepl('mangoland', usuariohab) ~ 18.46009,
    codigomuestra == 'H20191012m3' & grepl('mangoland', usuariohab) ~ 18.46128,
    TRUE ~ latitud
  )
)
#Visualizar resultado
miguel <- colhab %>% filter(grepl('mangoland', usuariohab)) %>% 
  left_join(ident %>% filter(grepl('mangoland', usuarioident)))
verexp(miguel)
```

### Todas muestras de hábitat

``` r
todos_los_habitat <- bind_rows(bidelkis, emma, jorge, miguel)
partipo <- read_csv('export/parcelas_tipo.csv')
todos_los_habitat <- todos_los_habitat %>% inner_join(partipo, by = 'parcela')
todos_los_habitat <- todos_los_habitat %>%
  mutate(riqueza = ifelse(
    grepl('reina',identificaciones), str_count(identificaciones, ','),
    str_count(identificaciones, ',') + 1))
todos_los_habitat <- todos_los_habitat %>% 
  mutate_at(vars(contains('distancia')),
            function(x) ifelse(x=='0', 'no hay a la vista', x))
saveRDS(todos_los_habitat, 'export/tabla_todos_los_habitat.RDS')
verexp(todos_los_habitat)
mcpooledhabitat <- todos_los_habitat %>%
  separate_rows(identificaciones, sep = ',') %>%
  left_join(nomlat) %>% dplyr::select(-identificaciones) %>% 
  mutate(genero = word(`nombre latino`, 1), epiteto = word(`nombre latino`, 2)) %>% 
  mutate(
    `nombre latino` = ifelse(genero=='reina(s)', genero,
                             ifelse(is.na(genero), NA, paste(genero)))) %>% 
  dplyr::select(parcela, `nombre latino`) %>%
  filter(!grepl('reina', `nombre latino`)) %>% 
  distinct() %>% mutate(n=1) %>%  spread(`nombre latino`, n, fill = 0) %>%
  select(-`<NA>`) %>% 
  column_to_rownames('parcela')
write.csv(mcpooledhabitat, 'export/mc_pooled_habitat.csv', row.names = T)
saveRDS(mcpooledhabitat, 'export/mc_pooled_habitat.RDS')
```

## Nidos

### Dahiana

``` r
vernid(x='dahiana', exportar = T)
#Resolución de discrepancias en códigos de muestras entre ambos formularios
colnid <- colnid %>% mutate(
  codigomuestra = case_when(
    idodknidos == 'uuid:99349817-83d2-48e4-b10b-22618fabe91b' & grepl('dahiana', usuarionid) ~ 'p1m2',
    idodknidos == 'uuid:97dc8d29-2377-452e-9d6b-b2511798566d' & grepl('dahiana', usuarionid) ~ 'p1m3',
    idodknidos == 'uuid:0b77bc0c-b77f-4937-962b-67ba37721453' & grepl('dahiana', usuarionid) ~ 'p25m3',
    idodknidos == 'uuid:cb1cf13b-5c4e-4069-8263-24673c61d344' & grepl('dahiana', usuarionid) ~ 'p25m2',
    TRUE ~ codigomuestra),
  parcela = case_when(
    idodknidos == 'uuid:0b77bc0c-b77f-4937-962b-67ba37721453' & grepl('dahiana', usuarionid) ~ 'p25',
    TRUE ~ parcela))
ident <- ident %>% mutate(
  codigomuestra = case_when(
    idodkident == 'uuid:e099700b-ba60-47da-b18a-3306c34a5416' & grepl('dahiana', usuarioident) ~ 'p10m2',
    idodkident == 'uuid:00fc68f2-ff88-471f-9012-502c126e3af6' & grepl('dahiana', usuarioident) ~ 'p25m1',
    idodkident == 'uuid:ee61b671-fd14-48d1-9843-3268edf24de8' & grepl('dahiana', usuarioident) ~ 'p27m1',
    idodkident == 'uuid:1e2128c5-fbb9-4955-8f5a-0f879635ff31' & grepl('dahiana', usuarioident) ~ 'p70m1',
    idodkident == 'uuid:512ed2f7-effc-4ea5-a914-1f28a75ccf2e' & grepl('dahiana', usuarioident) ~ 'p70m2',
    idodkident == 'uuid:5ebecff3-7640-4105-b4d1-d42c5b9aa308' & grepl('dahiana', usuarioident) ~ 'p148m1',
    TRUE ~ codigomuestra),
  parcela = case_when(
    idodkident == 'uuid:5ebecff3-7640-4105-b4d1-d42c5b9aa308' & grepl('dahiana', usuarioident) ~ 'p148',
    TRUE ~ parcela))
colnid <- colnid %>% mutate(
  codigomuestra = ifelse(grepl('dahiana', usuarionid), gsub(' ', '', toupper(codigomuestra)), codigomuestra))
ident <- ident %>% mutate(
  codigomuestra = ifelse(grepl('dahiana', usuarioident), gsub(' ', '', toupper(codigomuestra)), codigomuestra))
#Visualizar resultado
dahiana <- colnid %>% filter(grepl('dahiana', usuarionid)) %>%
  left_join(ident %>% filter(grepl('dahiana', usuarioident)))
verexp(dahiana)
```

### Enrique

``` r
# vernid(x='enrique', exportar = T)
vernid(x='enrique')
colnid <- colnid %>% mutate(
  codigomuestra = ifelse(grepl('enrique', usuarionid), gsub(' ', '', toupper(codigomuestra)), codigomuestra))
ident <- ident %>% mutate(
  codigomuestra = ifelse(grepl('enrique', usuarioident), gsub(' ', '', toupper(codigomuestra)), codigomuestra))
colnid <- colnid %>% mutate(
  codigomuestra = case_when(
    codigomuestra == 'PM86M1' & grepl('enrique', usuarionid) ~ 'PN86M1',
    grepl('P2|P42', codigomuestra) & grepl('enrique', usuarionid) ~ gsub('P', 'PN', codigomuestra),
    TRUE ~ codigomuestra
  ))
ident <- ident %>% mutate(
  codigomuestra = case_when(
    codigomuestra == '166M4' & grepl('enrique', usuarioident) ~ 'PN166M4',
    TRUE ~ codigomuestra
  ))
#Tras mensaje de respuesta de Enrique, 4/nov/2019
ident <- ident %>% mutate(
  codigomuestra = case_when(
    idodkident == 'uuid:9ea67257-64e2-47af-9718-b41b5f4bcfdb' & grepl('enrique', usuarioident) ~ 'PN21M2',
    idodkident == 'uuid:a996f1a9-fe0b-423b-ba86-8f32dfac98d3' & grepl('enrique', usuarioident) ~ 'PN22M1',
    TRUE ~ codigomuestra),
  parcela = case_when(
    idodkident == 'uuid:9ea67257-64e2-47af-9718-b41b5f4bcfdb' & grepl('enrique', usuarioident) ~ 'p21',
    TRUE ~ parcela))
#Nuevas discrepancias detectadas
ident <- ident %>% mutate(
  parcela = case_when(
    idodkident == 'uuid:073ea94d-4812-485c-b346-842e80f1f106' & grepl('enrique', usuarioident) ~ 'p151',
    TRUE ~ parcela))
colnid <- colnid %>% mutate(
  parcela = case_when(
    idodknidos == 'uuid:2933f009-4001-4ae0-98db-8aa27da63a00' & grepl('enrique', usuarionid) ~ 'p86',
    TRUE ~ parcela))
#Añadir filas a colnid donde no aparecieron nidos 68, 81, 109, 159, 170
parcelasanadirenrique <- c(68, 81, 109, 159, 170)
colnid <- colnid %>% add_row(
  parcela = paste0('p', parcelasanadirenrique),
  usuarionid = 'uid:enrique193|2019-08-27T17:32:44.132698Z',
  observaciones = 'No se reportaron nidos'
)
#Visualizar resultado
enrique <- colnid %>% filter(grepl('enrique', usuarionid)) %>%
  left_join(ident %>% filter(grepl('enrique', usuarioident)))
verexp(enrique)
```

### Kesia

``` r
vernid(x='maritza', exportar = F)
#Visualizar resultado
colnid <- colnid %>% mutate(
  parcela = case_when(
    idodknidos == 'uuid:da95c62d-7bf9-4dbf-863f-3f301b308755' & grepl('maritza', usuarionid) ~ 'p106',
    TRUE ~ parcela),
  observaciones = case_when(
    idodknidos == 'uuid:da95c62d-7bf9-4dbf-863f-3f301b308755' & grepl('maritza', usuarionid) ~ 'No se reportaron nidos',
    TRUE ~ observaciones))
ident <- ident %>% mutate(
  identificaciones = case_when(
    idodkident == 'uuid:454ae767-1a39-42c3-85fb-1d1a06adbc15' & grepl('maritza', usuarioident) ~ gsub('pseudoponera', 'pseudomyrmex', identificaciones),
  TRUE ~ identificaciones))
kesia <- colnid %>% filter(grepl('maritza', usuarionid)) %>%
  dplyr::select(-codigomuestra) %>%
  left_join(ident %>% filter(grepl('maritza', usuarioident))) %>% 
  dplyr::select(codigomuestra, parcela:siglascolectores, usuarioident:identificaciones)
verexp(kesia)
```

### Todas las muestras de nidos

``` r
todos_los_nidos <- bind_rows(dahiana, enrique, kesia)
partipo <- read_csv('export/parcelas_tipo.csv')
todos_los_nidos <- todos_los_nidos %>% inner_join(partipo, by = 'parcela')
todos_los_nidos <- todos_los_nidos %>%
  mutate(riqueza = ifelse(
    grepl('reina',identificaciones), str_count(identificaciones, ','),
    str_count(identificaciones, ',') + 1))
todos_los_nidos <- todos_los_nidos %>% 
  mutate_at(vars(contains('distancia')),
            function(x) ifelse(x=='0', 'no hay a la vista', x))
saveRDS(todos_los_nidos, 'export/tabla_todos_los_nidos.RDS')
verexp(todos_los_nidos)
mcpoolednidos <- todos_los_nidos %>%
  separate_rows(identificaciones, sep = ',') %>%
  left_join(nomlat) %>% dplyr::select(-identificaciones) %>% 
  mutate(genero = word(`nombre latino`, 1), epiteto = word(`nombre latino`, 2)) %>% 
  mutate(
    `nombre latino` = ifelse(genero=='reina(s)', genero,
                             ifelse(is.na(genero), NA, paste(genero)))) %>% 
  dplyr::select(parcela, `nombre latino`) %>%
  filter(!grepl('reina', `nombre latino`))  %>%
  distinct() %>% mutate(n=1) %>%  spread(`nombre latino`, n, fill = 0) %>%
  select(-`<NA>`) %>% 
  column_to_rownames('parcela')
write.csv(mcpoolednidos, 'export/mc_pooled_nidos.csv', row.names = T)
saveRDS(mcpoolednidos, 'export/mc_pooled_nidos.RDS')
```

## Guardando los resultados del proceso de ETL en RDS y CSV

``` r
saveRDS(colhab, 'export/colhab.RDS')
saveRDS(colnid, 'export/colnid.RDS')
saveRDS(ident, 'export/ident.RDS')
write_csv(colhab, 'export/colecta_habitat.csv')
write_csv(colnid, 'export/colecta_nidos.csv')
write_csv(ident, 'export/identificaciones.csv')
```

## Análisis

### Lectura de datos

``` r
colhab <- readRDS('export/colhab.RDS')
colnid <- readRDS('export/colnid.RDS')
ident <- readRDS('export/ident.RDS')
todos_los_habitat <- readRDS('export/tabla_todos_los_habitat.RDS')
todos_los_nidos <- readRDS('export/tabla_todos_los_nidos.RDS')
mcpooledhabitat <- readRDS('export/mc_pooled_habitat.RDS')
mcpoolednidos <- readRDS('export/mc_pooled_nidos.RDS')
```

### Análisis básicos

``` r
#Número de nidos por parcela:
colnid %>% filter(!observaciones=='No se reportaron nidos') %>% group_by(parcela) %>% count %>% arrange(desc(n)) %>% print(n=100)
## # A tibble: 24 x 2
## # Groups:   parcela [24]
##    parcela     n
##    <chr>   <int>
##  1 p42         6
##  2 p166        4
##  3 p25         4
##  4 p1          3
##  5 p10         3
##  6 p167        3
##  7 p27         3
##  8 p70         3
##  9 p147        2
## 10 p151        2
## 11 p163        2
## 12 p21         2
## 13 p78         2
## 14 p131        1
## 15 p143        1
## 16 p148        1
## 17 p157        1
## 18 p160        1
## 19 p168        1
## 20 p179        1
## 21 p22         1
## 22 p66         1
## 23 p77         1
## 24 p86         1

#Número de se muestrearon las parcela con cebos
colhab %>% group_by(parcela) %>% count %>% arrange(desc(n)) %>% print(n=100)
## # A tibble: 38 x 2
## # Groups:   parcela [38]
##    parcela     n
##    <chr>   <int>
##  1 p182        3
##  2 p107        2
##  3 p122        2
##  4 p16         2
##  5 p28         2
##  6 p104        1
##  7 p105        1
##  8 p126        1
##  9 p132        1
## 10 p134        1
## 11 p135        1
## 12 p140        1
## 13 p148        1
## 14 p156        1
## 15 p158        1
## 16 p160        1
## 17 p169        1
## 18 p17         1
## 19 p171        1
## 20 p178        1
## 21 p187        1
## 22 p24         1
## 23 p25         1
## 24 p33         1
## 25 p39         1
## 26 p40         1
## 27 p41         1
## 28 p42         1
## 29 p44         1
## 30 p49         1
## 31 p53         1
## 32 p54         1
## 33 p64         1
## 34 p78         1
## 35 p8          1
## 36 p86         1
## 37 p88         1
## 38 p97         1

#Nidos
mcpoolednidos %>% rowSums %>% length
## [1] 30
mcpoolednidos %>% rowSums %>% sort
## p106 p109 p159 p170  p68  p81 p148 p151 p157 p168  p22  p77  p86   p1 p131 
##    0    0    0    0    0    0    1    1    1    1    1    1    1    2    2 
## p143 p147 p163 p166 p167  p21  p66  p70  p10 p179  p25  p27  p42  p78 p160 
##    2    2    2    2    2    2    2    2    3    3    3    4    4    4    5
mcpoolednidos %>% rowSums %>% table
## .
##  0  1  2  3  4  5 
##  6  7 10  3  3  1
mcpoolednidos %>% colSums %>% sort
## Cardiocondyla  Pseudomyrmex    Monomorium  Brachymyrmex  Paratrechina 
##             1             1             5             6             6 
##      Pheidole    Dorymyrmex    Solenopsis 
##             7            12            15

#Hábitat
mcpooledhabitat %>% rowSums %>% length
## [1] 38
mcpooledhabitat %>% rowSums %>% sort
## p104 p126 p140 p156 p105 p158 p160 p169  p17  p39  p40  p41  p78 p122 p148 
##    0    0    0    0    1    1    1    1    1    1    1    1    1    2    2 
## p178 p187  p49  p53  p64   p8  p86 p135 p171  p97 p134  p16 p182  p25  p28 
##    2    2    2    2    2    2    2    3    3    3    4    4    4    4    4 
##  p42  p44  p54  p88 p107 p132  p24  p33 
##    4    4    4    4    5    5    6    6
mcpooledhabitat %>% rowSums %>% table
## .
## 0 1 2 3 4 5 6 
## 4 9 9 3 9 2 2
mcpooledhabitat %>% colSums %>% sort
##  Odontomachus     Wasmannia  Pseudomyrmex   Tetramorium    Monomorium 
##             1             1             2             2             3 
## Cardiocondyla  Paratrechina  Brachymyrmex      Pheidole    Solenopsis 
##             4             8            14            14            19 
##    Dorymyrmex 
##            26
```

## Herramientas de base de datos

### Crear copia de seguridad:

``` bash
#En ODK aggregate server
cd /tmp
sudo -i -u postgres
pg_dump aggregate > `date "+%Y%m%d"`
exit
zip `date "+%Y%m%d"`.zip `date "+%Y%m%d"`
#En PC local
scp <USUARIO>@<SERVIDOR>:/tmp/`date "+%Y%m%d"`.zip .
```

### Crear copia de BD en PC local

``` bash
#Borrar BD anterior:
sudo -i -u postgres
dropdb <BASE DE DATOS RECEPTORA>
#Crear nueva
createdb <BASE DE DATOS RECEPTORA>
#Copiar nueva
unzip `date "+%Y%m%d"`
psql -U <USUARIO LOCAL> -d <BASE DE DATOS RECEPTORA> -f `date "+%Y%m%d"`
#Permisos
sudo -i -u postgres
# Postgres:
## ALTER ROLE <USUARIO LOCAL> SET search_path TO aggregate, public;
## Solo una vez: ALTER ROLE <USUARIO LOCAL> WITH SUPERUSER 
## \q
exit
psql -U <USUARIO LOCAL> -d <BASE DE DATOS RECEPTORA>
```
