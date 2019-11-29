Todos los mapas disponibles
================

# Todos los mapas disponibles

## Carga de funciones y paquetes

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.2
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ──── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(knitr)
library(sf)
```

    ## Linking to GEOS 3.6.2, GDAL 2.2.3, PROJ 4.9.3

``` r
library(vegan)
```

    ## Loading required package: permute

    ## Loading required package: lattice

    ## This is vegan 2.5-6

``` r
library(ade4)
library(FactoMineR)
```

    ## 
    ## Attaching package: 'FactoMineR'

    ## The following object is masked from 'package:ade4':
    ## 
    ##     reconst

``` r
source('src/funciones_analisis.R')
```

## Carga de datos

``` r
todos_los_habitat <- read.csv('export/tabla_todos_los_habitat.csv')
todos_los_nidos <- read.csv('export/tabla_todos_los_nidos.csv')
```

## Combinaciones usuarios de hábitat con variables:

``` r
variables_hab <- colnames(todos_los_habitat)
usuarios_hab <- (todos_los_habitat %>%
                            colus() %>% usuarioanombre() %>%
                            dplyr::select(usuario=Nombre) %>% distinct())$usuario
comb <- expand.grid(variables_hab, usuarios_hab)

for (i in 15:20) {
  tryCatch(mapa(vari = as.character(comb[i,1]), filtusuario = as.character(comb[i,2])))
}
```

    ## Loading required package: tmap

    ## tmap mode set to interactive viewing

    ## Warning: Column `parcela` joining factors with different levels, coercing
    ## to character vector

    ## tmap mode set to interactive viewing

    ## Warning: Column `parcela` joining factors with different levels, coercing
    ## to character vector

    ## tmap mode set to interactive viewing

    ## Warning: Column `parcela` joining factors with different levels, coercing
    ## to character vector

    ## tmap mode set to interactive viewing

    ## Warning: Column `parcela` joining factors with different levels, coercing
    ## to character vector

    ## tmap mode set to interactive viewing

    ## Warning: Column `parcela` joining factors with different levels, coercing
    ## to character vector

    ## tmap mode set to interactive viewing

    ## Warning: Column `parcela` joining factors with different levels, coercing
    ## to character vector

``` r
# sapply(1:2, function(x) tryCatch(mapa(vari = as.character(comb[x,1]), filtusuario = as.character(comb[x,2]))))
# 1:nrow(comb)
```
