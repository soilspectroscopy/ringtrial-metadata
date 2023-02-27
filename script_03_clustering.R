
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
  labs(x = "Number of clusters", y = "Akaike information criterion",
       title = "K-means clustering and k definition using Elbow method") +
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
       title = "K-means clustering and k definition using Elbow method") +
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

# ggplotly(p.scores.cluster)

# Proportion table

scores <- qread(paste0(dir.metadata, "pca_clustering.qs"))
scores

proportions <- scores %>%
  group_by(organization, cluster) %>%
  summarise(count = n(),
            .groups = "drop") %>%
  group_by(organization) %>%
  mutate(prop = count/sum(count)*100) %>%
  select(-count) %>%
  ungroup() %>%
  mutate(cluster = paste0("C", cluster)) %>%
  pivot_wider(names_from = "cluster", values_from = "prop") %>%
  mutate_if(is.numeric, replace_na, 0) %>%
  mutate(majority = names(.[2:5])[max.col(.[2:5])]) %>%
  select(organization, majority, C1, C2, C3, C4)

write_csv(proportions, "outputs/proportions_clustering.csv")

scores <- scores %>%
  left_join({proportions %>%
      select(organization, majority)}, by = "organization") %>%
  relocate(majority, .after = cluster) %>%
  mutate(majority = as.integer(gsub("C", "", majority)))

scores

# PCA summary

pca.variance <- qread(paste0(mnt.dir, "metadata/pca_variance.qs"))
pca.variance

pca.percents <- pca.variance %>%
  filter(terms == "percent variance") %>%
  filter(component <= 2) %>%
  mutate(value = round(value, 2))

p.scores.cluster.majority <- scores %>%
  mutate(majority = as.factor(majority)) %>%
  ggplot(aes(x = PC1, y = PC2, color = majority)) +
  geom_point(size = 0.5) +
  labs(title = "Major cluster of each instruments' raw spectra",
       x = paste0("PC1 (", pca.percents[[1, "value"]], "%)"),
       y = paste0("PC2 (", pca.percents[[2, "value"]], "%)"),
       color = "Cluster") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
  theme_light() +
  theme(legend.position = "bottom"); p.scores.cluster.majority

ggsave(paste0(dir.output, paste0("plot_kmeans_clusters_majority.png")),
       p.scores.cluster.majority, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)

# Spectral summary

metadata <- read_xlsx(paste0(mnt.dir, "Spectrometers_Metadata.xlsx"), 1)

metadata <- metadata %>%
  filter(!is.na(code)) %>%
  select(code, folder_name, unique_name, country_iso)

new_codes <- metadata %>%
  pull(code)

names(new_codes) <- pull(metadata, folder_name)

organizations <- metadata %>%
  pull(folder_name)

codes <- metadata %>%
  pull(code)

all.mirspectra.raw <- read_csv(paste0(dir.preprocessed, "RT_STD_allMIRspectra_raw.csv"))

all.mirspectra.raw <- all.mirspectra.raw %>%
  mutate(organization = recode(organization, !!!new_codes)) %>%
  mutate(organization = factor(organization, levels = as.character(new_codes)))

all.mirspectra.raw

all.mirspectra.raw <- all.mirspectra.raw %>%
  left_join({proportions %>%
      select(organization, majority)}, by = "organization") %>%
  relocate(majority, .after = sample_id) %>%
  mutate(majority = as.integer(gsub("C", "", majority)))

all.mirspectra.raw

all.mirspectra.raw.summary <- all.mirspectra.raw %>%
  select(-organization, -sample_id) %>%
  group_by(majority) %>%
  summarise(across(everything(),
                   list(p05 = ~quantile(., probs = c(0.05)),
                        p50 = ~quantile(., probs = c(0.50)),
                        p95 = ~quantile(., probs = c(0.95))))) %>%
  pivot_longer(-majority, names_to = "variable", values_to = "value") %>%
  separate(variable, into = c("wavenumber", "percentile"), sep = "_") %>%
  mutate(wavenumber = as.integer(wavenumber)) %>%
  pivot_wider(names_from = "percentile", values_from = "value")
  
all.mirspectra.raw.summary

p.summary <- all.mirspectra.raw.summary %>%
  mutate(majority = as.factor(majority)) %>%
  ggplot(aes(x = wavenumber)) +
  geom_line(aes(y = p50, color = majority), size = 0.5, show.legend = F) +
  geom_ribbon(aes(ymax = p95, ymin = p05, fill = majority), alpha = 0.25) +
  labs(x = bquote(Wavenumber~(cm^-1)), y = bquote(Absorbance~(log[10]~units)),
       fill = "Cluster", title = "Spectral variation of clusters (5th, median, and 95th)") +
  scale_x_continuous(breaks = c(650, 1200, 1800, 2400, 3000, 3600, 4000),
                     trans = "reverse") +
  theme_light() + theme(legend.position = "bottom"); p.summary

ggsave(paste0(dir.output, paste0("plot_spectral_variation_clusters.png")),
       p.summary, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)
