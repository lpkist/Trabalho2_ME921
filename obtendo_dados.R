library(tidyverse)
informacoes <- read_csv("links.csv")
str(informacoes)

audios_baixados <- list.files(file.path("audios"))
titulos_duplicados <- informacoes %>% group_by(title) %>% 
  slice(2) %>% mutate(title = paste0(title, " (1)"))
titulos_primeiros <- informacoes %>% group_by(title) %>% 
  slice(1)

informacoes <- rbind(titulos_primeiros, titulos_duplicados) %>% 
  arrange(publication_date)
contagem_titulos <- table(informacoes$title)

for(i in names(contagem_titulos)){
  i_aux <- str_replace_all(i, ':', "_")
  i_aux <- str_replace_all(i_aux, '\\?', "_")
  audio <- paste0(i_aux,".mp3")
  if(!(audio %in% audios_baixados)) print(c((informacoes %>% filter(title == i))$url,
                                            audio))
}
# obs: 'Transmissão ao vivo de Formiga Atômica' não está disponível para download
informacoes <- informacoes %>%
  filter(title != 'Transmissão ao vivo de Formiga Atômica')

library(tuneR)
informacoes_completas <- map(informacoes$title, function(i){
  i_aux <- str_replace_all(i, ':', "_")
  i_aux <- str_replace_all(i_aux, '\\?', "_")
  audio <- paste0(i_aux,".mp3")
  voz <- readMP3(file.path("audios", audio))
  duracao <- round(length(voz@left)/voz@samp.rate, 2)
  summary_voz_l <- data.frame(q = seq(.05,.95, by = .05),
    valor_q = quantile(voz@left,
                                       seq(.05,.95, by = .05)),
                              Mean_l = mean(voz@left, na.rm = T)) %>% 
    pivot_wider(names_from = q, values_from = valor_q, 
                names_prefix = "Q")
  summary_voz_r <- data.frame(Mediana_r = median(voz@right),
                              Mean_r = mean(voz@right, na.rm = T))
  rownames(summary_voz_l) <- NULL
  rownames(summary_voz_r) <- NULL
  data.frame(informacoes %>% filter(title == i),
             duracao, summary_voz_l,
             summary_voz_r)
})
informacoes_completas <- list_rbind(informacoes_completas)
write_csv(informacoes_completas, file = "dados_completos.csv")
