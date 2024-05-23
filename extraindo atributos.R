library(pdftools)
library(tidyverse)
library(words)
arqs <- list.files("Papers/", pattern = ".pdf")
arqs[startsWith(arqs, "Corrigendum")]
file.remove(file.path("Papers",arqs[startsWith(arqs, "Corrigendum")]))

arqs[str_detect(arqs, "\\(1")]
file.remove(file.path("Papers",arqs[str_detect(arqs, "\\(1")]))


resultados <- map(1:length(arqs),
                  function(i){
dados <- pdftools::pdf_data(file.path("Papers", arqs[i]))
dados <- dados %>% list_rbind
titulo <- str_remove(arqs[i],".pdf") %>% str_split(" ")
ultima_palavra_titulo <- str_to_upper(titulo[[1]][length(titulo[[1]])])
ultima_palavra_titulo <- ifelse(str_ends(ultima_palavra_titulo, "_"),
       str_replace(ultima_palavra_titulo, "_", "?"), ultima_palavra_titulo)
dados_sem_titulo <- dados %>% mutate(idx = 1:nrow(dados),
                                     text = str_to_upper(text)) %>% 
  filter(cumsum(text == ultima_palavra_titulo)>=1)
dados_sem_titulo <- dados_sem_titulo[2:nrow(dados_sem_titulo),]
dados_sem_titulo <- dados_sem_titulo %>%
  filter(text != "\u0003") 

paper <- dados_sem_titulo %>%
  filter(cumsum(str_detect(text, "KEYWORDS")) > 0,
         cumsum(text == "REFERENCES") <
           max(cumsum(text == "REFERENCES")))
paper <- paper[2:nrow(paper),]
paper_aux <- paper %>%
  mutate(text = str_replace_all(text, "[^[:alpha:]]", ""))
paper_sem_pontuacao <- paper_aux

n_palavras <- paper_sem_pontuacao %>% nrow()

n_palavras_dic <- (paper_sem_pontuacao %>% 
  filter(text %in% str_to_upper(words$word)))$text %>% 
  unique() %>% length()

n_frases <- (paper %>%
               mutate(text = str_replace_all(text, "[[:alnum:]]", "")) %>% 
               filter(text != ""))$text %>% paste0(collapse = "") %>% str_count("\\.")
n_virgs <- (paper %>%
               mutate(text = str_replace_all(text, "[[:alnum:]]", "")) %>% 
               filter(text != ""))$text %>% paste0(collapse = "") %>% str_count(",")

n_num <- (paper %>%
                  mutate(text = str_replace_all(text, "[^[:number:]]", "")) %>% 
                  filter(text != ""))$text %>% paste0(collapse = "") %>% nchar

n_char <- paper_sem_pontuacao$text %>%
  paste0(collapse = " ") %>% nchar()

data.frame(paper = str_remove(arqs[i], ".pdf"),
           n_char = n_char,
           n_palavras_dic = n_palavras_dic,
           n_palavras = n_palavras,
           n_num = n_num,
           n_frases = n_frases,
           n_virgs = n_virgs
           )
})
resultados <- list_rbind(resultados)
resultados[-1] %>% pairs
resultados %>% view
write_csv(resultados, "Resultados.csv")
