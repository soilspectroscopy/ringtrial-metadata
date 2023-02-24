
## Loading packages
library("tidyverse")
library("cluster")
library("kmeansstep")
# library("ggrepel")
# library("cowplot")
library("qs")
library("plotly")

# install.packages("kmeansstep", repos="http://R-Forge.R-project.org")

## Folders
mnt.dir <- "~/projects/mnt-ringtrial/"
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
  labs(x = "Number of clusters", y = "Akaike information criterion",
       title = "k-means clustering and k definition using Elbow method") +
  theme_bw() +
  theme(panel.grid.minor = element_blank()); p.aic

ggsave(paste0(dir.output, paste0("plot_kmeans_aic_absolute.png")),
       p.aic, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)

p.rel.aic <- ggplot(AIC.plot.data, aes(x = cluster, y = relative)) +
  geom_line() + geom_point(size = 3) +
  geom_hline(yintercept = 0.2, linetype = "dashed") +
  scale_x_continuous(limits = c(1,20), breaks = c(1:20)) +
  labs(x = "Number of clusters", y = "Relative change of AIC (%)",
       title = "k-means clustering and k definition using Elbow method") +
  theme_bw() +
  theme(panel.grid.minor = element_blank()); p.rel.aic

ggsave(paste0(dir.output, paste0("plot_kmeans_aic_relative.png")),
       p.rel.aic, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)

## k-means full data

set.seed(1993)
km.pca.scores <- kmeans(scores[,-c(1:2)], 4, nstart = 30)

scores <- scores %>%
  mutate(cluster = km.pca.scores$cluster,
         .after = sample_id)

qsave(scores, paste0(dir.metadata, "pca_clustering.qs"))

## Visualization

pca.variance <- qread(paste0(mnt.dir, "metadata/pca_variance.qs"))
pca.variance

pca.percents <- pca.variance %>%
  filter(terms == "percent variance") %>%
  filter(component <= 2) %>%
  mutate(value = round(value, 2))

scores

p.scores.cluster <- scores %>%
  mutate(cluster = as.factor(cluster)) %>%
  ggplot(aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(size = 0.5) +
  labs(title = "K-means clustering of all instruments' raw spectra",
       x = paste0("PC1 (", pca.percents[[1, "value"]], "%)"),
       y = paste0("PC2 (", pca.percents[[2, "value"]], "%)"),
       color = "Cluster") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
  theme_light() +
  theme(legend.position = "bottom"); p.scores.cluster

ggsave(paste0(dir.output, paste0("plot_kmeans_clusters.png")),
       p.scores.cluster, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)

# ggplotly(p.scores.instruments)
# ggplotly(p.scores.cluster)
