
## Loading packages
library("tidyverse")
library("readxl")
library("cluster")
library("kmeansstep")
library("plotly")
library("qs")

# install.packages("kmeansstep", repos="http://R-Forge.R-project.org")

## Folders
mnt.dir <- "~/projects/mnt-ringtrial/"
dir.preprocessed <- paste0(mnt.dir, "preprocessed/")
dir.metadata <- paste0(mnt.dir, "metadata/")
dir.output <- "outputs/"

## Files
scores <- qread(paste0(dir.metadata, "pca_scores_pooled_raw.qs"))
scores

## Computing k-means for different k values

# AIC is a parsimony metric, i.e. the simplest model/theory
# with the least assumptions and variables, but with greatest explanatory power.

n.clusters <- 1:20

AIC.values <- c()

set.seed(1993)
for(i in 1:length(n.clusters)) {
  km.pca.scores <- kmeans(scores[,-c(1:2)], n.clusters[i], nstart = 30)
  km.aic <- kmeansAIC(km.pca.scores)
  AIC.values[i] <- km.aic
}

AIC.values
diff(AIC.values)
diff(AIC.values)/AIC.values[-20]

AIC.plot.data <- tibble(cluster = n.clusters,
                        AIC = AIC.values) %>%
  mutate(lag = lag(AIC)) %>%
  mutate(difference = abs(AIC - lag)) %>%
  mutate(relative = (difference/lag)); AIC.plot.data

p.aic <- ggplot(AIC.plot.data, aes(x = cluster, y = AIC)) +
  geom_line(size = 0.5) + geom_point(size = 3) +
  geom_hline(yintercept = 250642, linetype = "dashed") +
  scale_x_continuous(limits = c(1,20), breaks = 1:20) +
  labs(x = "Number of clusters", y = "Akaike information criterion") +
  theme_bw() +
  theme(panel.grid.minor = element_blank()); p.aic

ggsave(paste0(dir.output, paste0("plot_paper_kmeans_aic_absolute.png")),
       p.aic, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)
