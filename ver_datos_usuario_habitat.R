verhab <- function(x){
  View(colhab %>% filter(grepl(x, usuariohab)) %>% arrange(codigomuestra))
  View(ident %>% filter(grepl(x, usuarioident)) %>% arrange(codigomuestra))
}