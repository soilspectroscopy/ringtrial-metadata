
## Loading packages
library("tidyverse")
library("readxl")
library("cluster")
library("kmeansstep")
library("plotly")
library("qs")
library("ggrepel")

# install.packages("kmeansstep", repos="http://R-Forge.R-project.org")

## Folders
mnt.dir <- "~/projects/mnt-ringtrial/"
dir.preprocessed <- paste0(mnt.dir, "preprocessed/")
dir.metadata <- paste0(mnt.dir, "metadata/")
dir.output <- "outputs/"

## Files
scores <- qread(paste0(dir.metadata, "pca_majority.qs"))
scores

pca.variance <- qread(paste0(mnt.dir, "metadata/pca_variance.qs"))
pca.variance

## Visualization

pca.percents <- pca.variance %>%
  filter(terms == "percent variance") %>%
  filter(component <= 2) %>%
  mutate(value = round(value, 2))

scores.centroid <- scores %>%
  group_by(organization) %>%
  summarise(PC1 = mean(PC1), PC2 = mean(PC2),
            majority = first(majority)) %>%
  mutate(majority = as.factor(majority))

p.scores.cluster <- scores %>%
  mutate(majority = as.factor(majority)) %>%
  ggplot(aes(x = PC1, y = PC2, color = majority)) +
  geom_point(size = 0.5) +
  geom_label_repel(data = scores.centroid,
             aes(x = PC1, y = PC2, label = organization, color = majority),
             max.overlaps = Inf, show.legend = F) +
  labs(x = paste0("PC1 (", pca.percents[[1, "value"]], "%)"),
       y = paste0("PC2 (", pca.percents[[2, "value"]], "%)"),
       color = "Cluster") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
  theme_light() +
  theme(legend.position = "bottom"); p.scores.cluster

ggsave(paste0(dir.output, paste0("plot_paper_kmeans_clusters.png")),
       p.scores.cluster, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)
