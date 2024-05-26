library(tidyverse)
library(covRobust)
library(mclust)
library(cluster)
resultados <- read_csv("Resultados.csv")
options(OutDec = ",")
#resultados %>% view
#resultados[,-1] %>% pairs


resultados2 <- resultados %>% 
  transmute(caracteres = sqrt(as.numeric(n_char)),
            palavras = sqrt(as.numeric(n_palavras)),
            palavras_dicionario = sqrt(as.numeric(n_palavras_dic)),
            pontos = sqrt(as.numeric(n_frases)),
            virgulas = sqrt(as.numeric(n_virgs)),
            numeros = sqrt(n_num))

resultados2 %>% pairs(cex.labels = 1.8)

nnve.out <- cov.nnve(resultados2)
pairs(resultados2, col = ifelse(nnve.out$classification == 0, 
                                "red", "green"
                                ), cex.labels = 1.8)
cor(resultados2)
table(nnve.out$classification)

modelos_mclust <- Mclust(resultados2, 
                         initialization = list(noise = (nnve.out$classification == 0)))
modelos_mclust$BIC
plot(modelos_mclust, what = "BIC")

par(mfrow = c(3,1))
mod1 <- Mclust(resultados2, G = 2, modelNames = "EEE", initialization = list(noise = (nnve.out$classification == 0)))
plot(sort(mod1$uncertainty), ylim = c(0, 0.5), cex.axis = 1.5,
     cex.lab = 1.5,
     main = "EEE com 2 clusters", ylab = "Incerteza",
     cex.main = 1.7)
p*(p+1)/2
mod2 <- Mclust(resultados2, G = 2, modelNames = "VEE", initialization = list(noise = (nnve.out$classification == 0)))
plot(sort(mod2$uncertainty), ylim = c(0, 0.5), cex.axis = 1.5,
     cex.lab = 1.5,
     main = "VEE com 2 clusters", ylab = "Incerteza",
     cex.main = 1.7)
C = 2
p = 6
C+(p+2)*(p-1)/2
mod3 <- Mclust(resultados2, G = 2, modelNames = "EVE", initialization = list(noise = (nnve.out$classification == 0)))
plot(sort(mod3$uncertainty), ylim = c(0, 0.5), cex.axis = 1.5,
     main = "EVE com 2 clusters", ylab = "Incerteza",
     cex.lab = 1.5,
     cex.main = 1.7)
C = 2
p = 6
1+(p+2*C)*(p-1)/2
table(mod3$classification)
nnve.out_1 <- cov.nnve(resultados2[-1])
modelos_mclust_1 <- Mclust(resultados2[-1], 
                         initialization = list(noise = (nnve.out_1$classification == 0)))
modelos_mclust_1$BIC
plot(modelos_mclust_1, what = "BIC")

par(mfrow = c(3,1))
mod1_1 <- Mclust(resultados2[-1], G = 2, modelNames = "EEE", initialization = list(noise = (nnve.out_1$classification == 0)))
plot(sort(mod1_1$uncertainty), ylim = c(0, 0.5), cex.axis = 1.5,
     cex.lab = 1.5,
     main = "EEE com 2 clusters", ylab = "Incerteza",
     cex.main = 1.7)

mod2_1 <- Mclust(resultados2[-1], G = 2, modelNames = "VEE", initialization = list(noise = (nnve.out_1$classification == 0)))
plot(sort(mod2_1$uncertainty), ylim = c(0, 0.5), cex.axis = 1.5,
     cex.lab = 1.5,
     main = "VEE com 2 clusters", ylab = "Incerteza",
     cex.main = 1.7)

mod3_1 <- Mclust(resultados2[-1], G = 2, modelNames = "EVE", initialization = list(noise = (nnve.out_1$classification == 0)))
plot(sort(mod3_1$uncertainty), ylim = c(0, 0.5), cex.axis = 1.5,
     main = "EVE com 2 clusters", ylab = "Incerteza",
     cex.lab = 1.5,
     cex.main = 1.7)





plot(mod3, what = "classification", cex.labels = 1.8)
pams <- list()
for(i in 2:10){
  pam <- pam(scale(resultados2), i)
  pams[[i]] <- data.frame(k = i, avg_sil = pam$silinfo$avg.width)
}
pams <- list_rbind(pams)
pams %>% plot
pams %>% head %>% t() %>% xtable::xtable()
max(pams$avg_sil)
pams2 <- pam(scale(resultados2), 2)
pairs(resultados2, col = ifelse(pams2$clustering == 1, "#1c86ee", "#cd0000"),
      cex.labels = 1.8, pch = pams2$clustering)
pams2$medoids %>% round(2) %>% xtable::xtable()
table(pams2$clustering)
library(caret)
confusionMatrix(factor(pams2$clustering, levels = 0:2),
                factor(mod3$classification, levels = 0:2))$table %>% xtable::xtable()
resultados3 <- sapply(resultados2, function(x) (x-min(x))/diff(range(x)))
cbind(resultados3, data.frame(Cluster = factor(mod3$classification, levels = c(0,2,1)))) %>%
  pivot_longer(cols = 1:6, names_to = "Atributo", values_to = "Valor") %>% 
  ggplot(aes(x = factor(Atributo), y = Valor, fill = Cluster))+
  geom_boxplot()+
  theme_bw()+
  labs(x = "Atributo", y = "Valor normalizado", fill = "Cluster mclust")+
  theme(axis.title = element_text(size=18),
        axis.text = element_text(size=14),
        legend.title = element_text(size=18),
        legend.text = element_text(size=14))+
  scale_fill_manual(values = c("white", "#cd0000", "#1c86ee"))

cbind(resultados3, data.frame(Cluster = factor(pams2$clustering))) %>%
  pivot_longer(cols = 1:6, names_to = "Atributo", values_to = "Valor") %>% 
  ggplot(aes(x = factor(Atributo), y = Valor, fill = Cluster))+
  geom_boxplot()+
  theme_bw()+
  labs(x = "Atributo", y = "Valor normalizado", fill = "Cluster pam")+
  theme(axis.title = element_text(size=18),
        axis.text = element_text(size=14),
        legend.title = element_text(size=18),
        legend.text = element_text(size=14))

