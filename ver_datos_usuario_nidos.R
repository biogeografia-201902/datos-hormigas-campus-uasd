vernid <- function(x, exportar=F){
  require(tidyverse)
  colnid <- colnid %>% filter(grepl(x, usuarionid)) %>% arrange(codigomuestra, parcela)
  View(colnid)
  ident <- ident %>% filter(grepl(x, usuarioident)) %>% arrange(codigomuestra, parcela)
  View(ident)
  if (exportar){
    write_csv(x = colnid, path = paste0('buffer/colnid_', x, '.csv'))
    write_csv(x = ident, path = paste0('buffer/ident_', x, '.csv'))
  }
}
