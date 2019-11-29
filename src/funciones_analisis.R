colus <- function(x){
  colnames(x) <- gsub('usuariohab|usuarionid', 'usuario', colnames(x))
  return(x)
}

usuarioanombre <- function(x) {
  x <- x %>% 
    mutate(Nombre = gsub('uid\\:|\\|.*$', '', usuario))
  return(x)
}

n_parcelas <- function(x, pooled=F){
  require(tidyverse)
  x <- colus(x)
  x <- usuarioanombre(x)
  x %>% 
    {`if`(pooled, dplyr::select(., parcela), dplyr::select(., Nombre, parcela))} %>% 
    distinct() %>% 
    {`if`(pooled, group_by(.), group_by(., Nombre))} %>% 
    count(name = 'Número de parcelas visitadas')
}

n_muestras <- function(x, pooled=F){
  require(tidyverse)
  x <- colus(x)
  x <- usuarioanombre(x)
  x %>% 
    {`if`(pooled, dplyr::select(., codigomuestra), dplyr::select(., Nombre, codigomuestra))} %>% 
    {`if`(pooled, group_by(.), group_by(., Nombre))} %>% 
    count(name = 'Número de muestras')
}

n_parcelas_muestras <- function(x, pooled=F){
  require(tidyverse)
  x <- colus(x)
  x <- usuarioanombre(x)
  x %>% 
    {`if`(pooled, dplyr::select(., parcela, codigomuestra), select(., Nombre, parcela, codigomuestra))} %>% 
    distinct() %>% 
    {`if`(pooled, group_by(., parcela), group_by(., Nombre, parcela))} %>% 
    count(name = 'Número de muestras por parcela visitada') %>% 
    mutate(ord = as.numeric(stringr::str_extract(parcela, "\\d+$"))) %>%
    {`if`(pooled, arrange(., ord), arrange(., Nombre, ord))} %>%  select(-ord)
}

parcelas_visitadas <- function(x, pooled=F){
  require(tidyverse)
  x <- colus(x)
  x <- usuarioanombre(x)
  x %>%
    {`if`(pooled, dplyr::select(., parcela), dplyr::select(., Nombre, parcela))} %>%
    distinct() %>%
    {`if`(pooled, group_by(.), group_by(., Nombre))} %>%
    mutate(ord = as.numeric(stringr::str_extract(parcela, "\\d+$"))) %>%
    arrange(ord) %>%  select(-ord) %>% 
    summarise('Parcelas visitadas' = paste(parcela, collapse = ','))
}

mapa <- function(vari, filtusuario = NULL, fun = mean) {
  require(sf)
  require(tmap)
  require(tidyverse)
  tmap_mode('view')
  parcelas <- st_read('export/parcelas_tipo.gpkg', quiet = T)
  todos_los_habitat <- read.csv('export/tabla_todos_los_habitat.csv')
  todos_los_nidos <- read.csv('export/tabla_todos_los_nidos.csv')
  todos_los_habitat <- colus(todos_los_habitat)
  todos_los_nidos <- colus(todos_los_nidos)
  todos_los_habitat <- usuarioanombre(todos_los_habitat)
  todos_los_nidos <- usuarioanombre(todos_los_nidos)
  tipomuestra <- ifelse(any(grepl(filtusuario, c('dahianagb07', 'enrique193', 'maritzafg'))),
                        'nidos', 'habitat')
  if(tipomuestra == 'habitat')
    {parcelas <- parcelas %>%
      inner_join(todos_los_habitat %>% dplyr::select(-tipo), by = 'parcela')}
  else if(is.numeric(todos_los_nidos[,vari]))
    {parcelas <- parcelas %>%
      inner_join(todos_los_nidos %>% dplyr::select(-tipo), by = 'parcela') %>%
      group_by(usuario, parcela) %>% summarise_if(is.numeric, fun)} else
        {parcelas <- parcelas %>%
          inner_join(todos_los_nidos %>% dplyr::select(-tipo), by = 'parcela') %>%
          group_by(usuario, parcela) %>% summarise_if(is.factor, paste, collapse = ',')}
  parcelas <- parcelas %>% filter(grepl(filtusuario, usuario))
  parcelas <- parcelas %>% mutate_if(is.factor, droplevels)
  # return(parcelas)
  m <- tm_shape(parcelas) +
    tm_fill(vari, alpha = 0.9) +
    tm_shape(parcelas) +
    tm_borders(col = 'black') +
    tm_shape(parcelas) +
    tm_text(text = 'parcela', size = 0.8) +
    tm_basemap(server = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png')
  print(m)
}

matriz_comunidad_hab <- function(filtusuario = NULL) {
  require(tidyverse)
  mc <- todos_los_habitat %>%
    select(
      codigomuestra, parcela, usuariohab, identificaciones) %>% 
    colus() %>% usuarioanombre() %>% filter_at(.vars=vars('Nombre'), ~ . == filtusuario) %>% 
    separate_rows(identificaciones, sep = ',') %>%
    left_join(nomlat) %>% dplyr::select(-identificaciones) %>% 
    mutate(genero = word(`nombre latino`, 1), epiteto = word(`nombre latino`, 2)) %>% 
    mutate(
      `nombre latino` = ifelse(genero=='reina(s)', genero,
                               ifelse(is.na(genero), NA, paste(genero)))) %>% 
    dplyr::select(parcela, `nombre latino`) %>%
    filter(!grepl('reina', `nombre latino`)) %>% 
    distinct() %>% mutate(n=1) %>%  spread(`nombre latino`, n, fill = 0) %>%
    select(-contains('<NA>')) %>% 
    column_to_rownames('parcela')
  return(mc)
}

matriz_ambiental_hab <- function(filtusuario = NULL) {
  require(tidyverse)
  ma <- todos_los_habitat %>%
    select(
      parcela, usuariohab,
      matches('distancia|hora|colecta|actividad|^cebos|tipo$|plantas|riqueza')) %>% 
    colus() %>% usuarioanombre() %>%
    filter(Nombre == filtusuario) %>% 
    select(-Nombre, -contains('usuario')) %>% 
    column_to_rownames('parcela')
  return(ma)
}

mc_para_ord <- function(..., method = 'hell') {
  require(vegan)
  #Elimina las muestras sin datos y transforma los datos
  mcout <- matriz_comunidad_hab(...)
  mcout <- mcout[!rowSums(mcout)==0,]
  mcout_hell <- decostand(mcout, method = method)
  return(mcout_hell)
}

ma_para_ord <- function(..., mc = NULL) {
  maout <- matriz_ambiental_hab(...)
  maout <- maout[na.omit(match(rownames(mc), rownames(maout))),] 
  maout <- maout %>% select(riqueza, tipo, matches('distancia|actividad|cebos'))
  return(maout)
}

dendro <- function(mc = NULL, k = NULL) {
  mc_d <- dist.binary(mc, method = 5) #Sorensen
  mc_d_cl <- hclust(mc_d, method = "average")
  # plot(mc_hell_d_cl)
  grupos <- cutree(mc_d_cl, k = k)
  grupos
  plot(mc_d_cl)
  rect.hclust(mc_d_cl, k = k, border = 2)
}

pcoagg <- function(
  #Ejemplo 1: pcoa_mg <- pcoagg(mc = mcmg_ord, ma = mamg_ord)
  #Ejemplo 2: 
  mc = NULL, ma = NULL, distmethod = 'bray', textoetiq = 6, textotema = textoetiq*(14/4),
  delta_s = 0L, dxst = 0, dyst = 0.01, dxsp = 0, dysp = -0.01, p_max = 0.1) {
  require(ggplot2)
  require(ggrepel)
  require(vegan)
  mc_dist <- vegdist(mc, method = distmethod)
  mc_pcoa <- cmdscale(mc_dist, k = (nrow(mc) - 1), eig = TRUE)
  vars <- mc_pcoa$eig/sum(mc_pcoa$eig)
  if(delta_s > 0L) mc_pcoa$points <- mc_pcoa$points + rnorm(nrow(mc)*ncol(mc), delta_s, delta_s)
  mc_pcoa_scores <- data.frame(scores(mc_pcoa))
  mc_wa <- data.frame(wascores(mc_pcoa$points[, 1:2], mc))
  colnames(mc_wa) <- c('Dim1', 'Dim2')
  mc_pcoa_env <- envfit(mc_pcoa, ma)
  mc_pcoa_env_c_f <- data.frame(mc_pcoa_env$factors$centroids)
  f_sign <- paste(names(which(mc_pcoa_env$factors$pvals <= p_max)), collapse = '|')
  mc_pcoa_env_c_f <- mc_pcoa_env_c_f[grepl(f_sign, rownames(mc_pcoa_env$factors$centroids)),]
  mc_pcoa_env_c_v <- data.frame(mc_pcoa_env$vectors$centroids)[names(which(mc_pcoa_env$vectors$pvals <= p_max)),]
  v_sign <- paste(names(which(mc_pcoa_env$vectors$pvals <= p_max)), collapse = '|')
  mc_pcoa_env_c_v <- mc_pcoa_env_c_v[grepl(v_sign, rownames(mc_pcoa_env$vectors$centroids)),]
  p <- ggplot() +
    geom_point(data = mc_pcoa_env_c_f, aes(x = Dim1, y = Dim2), color = 'blue', shape = 22, size = 2) +
    geom_text_repel(data = mc_pcoa_env_c_f, aes(x = Dim1, y = Dim2, label = rownames(mc_pcoa_env_c_f)), color = 'blue', alpha = 0.5, force = 10, size = textoetiq) +
    geom_point(data = mc_wa, aes(x = Dim1, y = Dim2), colour = 'red') +
    geom_text_repel(data = mc_wa, aes(x = Dim1, y = Dim2, label = rownames(mc_wa)), color = 'red', alpha = 0.5, force = 2, nudge_x = dxsp, nudge_y = dysp, size = textoetiq, fontface = 'bold') +
    geom_point(data = mc_pcoa_scores, aes(x = Dim1, y = Dim2), shape = 10, size = 4) +
    geom_label_repel(data = mc_pcoa_scores, aes(x = Dim1, y = Dim2, label = rownames(mc)), alpha = 0.5, nudge_x = dxst, nudge_y = dyst, size = textoetiq) +
    xlab(label = paste0('Dim1, (', round(vars[1]*100,2), '%)')) +
    ylab(label = paste0('Dim2, (', round(vars[2]*100,2), '%)')) +
    theme_light(base_size = textotema)
  return(list(grafico = p, PCoA_adj = mc_pcoa_env, PCoA = mc_pcoa))
}
