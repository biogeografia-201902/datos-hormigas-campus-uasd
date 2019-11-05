#Selección
est <- c('Dahiana', 'Enrique', 'Bidelkis', 'Jorge', 'Emma', 'Kesia', 'Miguel')
set.seed(1);sample(est, 1)

#Paquetes
library(tidyverse)
library(readr)

#Preguntas:
# Mis preguntas de investigación son las siguientes:
#   
#   ¿Cuál es la distribución espacial entre los nidos edificado y pavimentado que superan los 5 metros de distancia?
#   
#   ¿Influye el transito de humanos en la diversidad de hormigas?
#   
#   ¿Existe diferencia significativa en la densidad de nidos entre distintos sustratos?
#   
#   ¿Qué tanto recambio de especies existe entre nidos de sustratos herbáceos o áreas contruidas?

#Cargar datos
tabla_dahiana <- read_csv("export/tabla_dahiana.csv")
View(tabla_dahiana)

#Básicos
tabla_dahiana %>% group_by(parcela) %>% count %>% 
  print(n=100)
tabla_dahiana %>% group_by(codigomuestra) %>% count %>% 
  print(n=100)
tabla_dahiana %>%
  dplyr::select(codigomuestra, parcela, identificaciones) %>%
  print(n=100)
tabla_dahiana %>% 
  dplyr::select(codigomuestra, parcela,
                distanciavias, identificaciones) %>%
  arrange(parcela, codigomuestra) %>% View
tabla_dahiana %>% 
  dplyr::select(codigomuestra, parcela,
                distanciavias, identificaciones) %>%
  arrange(distanciavias) %>% View


#Bidelkis
# Pregunta 1. ¿Las hormigas se encuentran en mayor concentración en áreas aseadas y sin basura o en zonas donde hay zafacones?
#   
# Pregunta 2. ¿Se relaciona la falta de vegetación herbácea con la abundancia de las hormigas ?

#Todos los datos
todos <- read_csv('export/tabla_todos_los_habitat.csv')


bidelkis <- read_csv('export/tabla_bidelkis.csv')
bidelkis %>% View
bidelkis %>%
  dplyr::select(distanciaabasura, identificaciones) %>% 
  filter(distanciaabasura=='0'|distanciaabasura=='10omas'|distanciaabasura=='6a9')
bidelkis %>% 
  dplyr::select(identificaciones, parcela)
todos %>%
  dplyr::select(distanciaabasura, identificaciones) %>% 
  View

