library(tidyverse)
library(reshape2)
informacoes_completas <- read_csv("dados_completos.csv")
cols_sem_na <- colnames(informacoes_completas)[sapply(informacoes_completas, function(col) sum(is.na(col)))==0]

informacoes_aux <- informacoes_completas[cols_sem_na] %>% 
  select(-c(id, title, 
            channel_id, channel_title,
            url)) %>% 
  mutate(across(c('viewCount', 'likeCount', 'favoriteCount'),
                as.numeric))
informacoes_aux$favoriteCount %>% summary()

infos_audios <- informacoes_aux %>% select(starts_with("Q0."))
pairs(infos_audios)
pca_audios <- princomp((infos_audios))
pca_audios %>% summary()

library(ggbiplot)
ggbiplot(pca_audios,
         labels = 1:nrow(informacoes_completas),
         varname.color = "red",
         varname.size = c(rep(7, 4), 
                          rep(5,11), 
                          rep(7, 4)),
         varname.adjust = 2.5,
         labels.size = 6
        )+
  xlim(c(-4,3))+
  theme_bw()+
  labs(x = paste0("Comp. 1 (",round(100*pca_audios$sdev[1]^2/sum(pca_audios$sdev^2),2),"%)"),
       y = paste0("Comp. 2 (",round(100*pca_audios$sdev[2]^2/sum(pca_audios$sdev^2),2),"%)"))+
  theme(axis.title = element_text(size=18),
        axis.text = element_text(size=14))

df_final <- informacoes_aux %>% select(-favoriteCount) %>% 
  select(!starts_with("Q0.")) %>% 
  mutate(audios = pca_audios$scores[,1]) %>% 
  mutate(publication_date = as.Date(publication_date),
         publication_date = as.numeric(publication_date - min(publication_date)))

summary(df_final)
sapply(df_final, sd)

df_scaled <- df_final %>% 
  mutate(publication_date = publication_date/210,
         likeCount = likeCount/3,
         viewCount = viewCount/55,
         duracao = duracao/580,
         Mean_l = Mean_l/7.5,
         audios = audios/5300)

sapply(df_scaled, sd)


distancias <- matrix(0, nrow(df_scaled), nrow(df_scaled))
distancias[lower.tri(distancias)] <- dist(df_scaled, diag = T, upper = T)
distancias[upper.tri(distancias)] <- t(distancias)[upper.tri(distancias)]
distancias %>% isSymmetric.matrix()

distancias_plot <- melt(distancias, c("x", "y"),
                        value.name = "z")
distancias_plot %>% ggplot(aes(x=x,y=y,fill=z))+
                             geom_tile()+
  scale_fill_viridis_c()+
  theme_bw()+
  labs(x = "Índice do vídeo",
       y = "Índice do vídeo",
       fill = "Distância")+
  theme(axis.title = element_text(size=18),
        axis.text = element_text(size=14),
        legend.title = element_text(size=18),
        legend.text = element_text(size=14))# df_scaled <- df_final %>% mutate(across(colnames(df_final), scale))

library(cluster)
pams <- list()
for(i in 2:(nrow(df_scaled)-1)){
  if(i %in% c(3,6,10,40,70,100)) print(i)
  pam <- pam(df_scaled, i)
  pams[[i-1]] <- c(i, pam$silinfo$avg.width) # silhueta do PAM com k = i
}
pams_df <- do.call(rbind, pams)
colnames(pams_df) <- c("k", "s_barra_k")
pams_df %>% data.frame() %>% 
  arrange(-s_barra_k) %>% 
  # Valores de k ordernados por s_barra_k
  head() %>% mutate(s_barra_k = round(s_barra_k,4))
library(factoextra)
fviz_nbclust(x = df_scaled, FUNcluster = cluster::pam,
             method = "silhouette", k.max = 15)+
  labs(x = "Número de clusters (k)",
      y = "Tamanho médio da silhueta")+
  theme(plot.title = element_blank(),
        axis.title = element_text(size=18),
        axis.text = element_text(size=14),
        legend.title = element_text(size=18),
        legend.text = element_text(size=14))+
  geom_line(aes(group = 1), size = 3, color = "blue") + 
  geom_point(group = 1, size = 5, color = "blue")+
  geom_vline(xintercept = 5, size = 2)

fviz_nbclust(x = df_scaled, FUNcluster = cluster::pam, method = "wss")

melhor_pam <- pam(df_scaled, 5)
melhor_pam$medoids # atributos dos medoides
melhor_pam$medoids %>% 
  data.frame() %>% 
  mutate(publication_date = publication_date*210,
         likeCount = likeCount*3,
         viewCount = viewCount*55,
         duracao = duracao*580,
         Mean_l = Mean_l*7.5,
         audios = audios*5300)
melhor_pam$id.med
informacoes_completas[melhor_pam$id.med,"title"]
melhor_pam$clusinfo
melhor_pam$silinfo
plot(silhouette(melhor_pam))

fviz_silhouette(melhor_pam)+
  theme_bw()+
  labs(x = "Índice do vídeo",
    y = "Comprimento da silhueta", fill = "Cluster",
       color = "Cluster")+
  scale_x_discrete(guide = guide_axis(n.dodge=3))+
  theme(plot.title = element_blank(),
        axis.title = element_text(size=18),
        axis.text = element_text(size=14),
        legend.title = element_text(size=18),
        legend.text = element_text(size=14),
        axis.text.x = element_text(hjust = .5, angle = 90,
                                   vjust = .5,
                                   size = 14))

library(aplpack)

faces(df_scaled[melhor_pam$id.med,], labels = melhor_pam$id.med)
#informacoes_completas[melhor_pam$id.med,] %>% view

faces(df_scaled[1:100,], labels = melhor_pam$clustering[1:100])

d <- dist(df_scaled) # euclidean distances between the rows
fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim
fit # view results
x <- fit$points[,1]
y <- fit$points[,2]
data.frame(fit$points, 
           cluster = factor(melhor_pam$clustering, levels = 1:5, 
                            #labels = informacoes_completas[melhor_pam$id.med,
#                                                           "title"]
)) %>% 
  ggplot(aes(x=x, y=y, color = cluster))+
  geom_point(size = 3) + 
  theme_bw()+
  labs(fill = "Cluster",
       color = "Cluster")+
  theme(plot.title = element_blank(),
        axis.title = element_text(size=18),
        axis.text = element_text(size=14),
        legend.title = element_text(size=18),
        legend.text = element_text(size=14),
        axis.text.x = element_text(angle = 90, hjust = .5,
                                   vjust = .5, size = 14))


sum(fit$eig[1:2])/sum(fit$eig)

