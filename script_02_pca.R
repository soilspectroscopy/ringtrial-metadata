
## Loading packages
library("tidyverse")
library("tidymodels")
library("readxl")
library("qs")

## Folders
mnt.dir <- "~/projects/mnt-ringtrial/"
dir.preprocessed <- paste0(mnt.dir, "preprocessed/")

dir.output <- "outputs/"

## Reading organization codes
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

## Pooled PCA of raw spectra

all.mirspectra.raw <- read_csv(paste0(dir.preprocessed, "RT_STD_allMIRspectra_raw.csv"))

all.mirspectra.raw <- all.mirspectra.raw %>%
  mutate(organization = recode(organization, !!!new_codes)) %>%
  mutate(organization = factor(organization, levels = as.character(new_codes)))

all.mirspectra.raw

pca.model <- all.mirspectra.raw %>%
  recipe() %>%
  update_role(everything()) %>%
  update_role(all_of(c("organization", "sample_id")), new_role = "id") %>%
  step_normalize(all_predictors(), id = "normalization") %>% # Center and scale spectra
  step_pca(all_predictors(), threshold = 0.995, id = "pca") %>% # Keep 99.5% of original variance
  prep()

pca.variance <- tidy(pca.model, id = "pca", type = "variance")

pca.variance %>%
  distinct(terms)

pca.variance <- pca.variance %>%
  filter(component <= 7)

qsave(pca.variance, paste0(mnt.dir, "metadata/pca_variance.qs"))

pca.percents <- pca.variance %>%
  filter(terms == "percent variance") %>%
  filter(component <= 2) %>%
  mutate(value = round(value, 2))

# PC space - 7 PCs

pca.scores.train <- juice(pca.model) %>%
  rename_at(vars(starts_with("PC")), ~paste0("PC", as.numeric(gsub("PC", "", .))))

p.scores.all.pooled <- pca.scores.train %>%
  ggplot(aes(x = PC1, y = PC2, color = organization)) +
  geom_point(size = 0.5) +
  scale_colour_discrete(breaks = as.character(new_codes), labels = as.character(new_codes)) +
  labs(title = "Projection of all instruments with pooled raw spectra",
       x = paste0("PC1 (", pca.percents[[1, "value"]], "%)"),
       y = paste0("PC2 (", pca.percents[[2, "value"]], "%)"),
       color = "") +
  guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
  theme_light() +
  theme(legend.position = "bottom"); p.scores.all.pooled

ggsave(paste0(dir.output, paste0("plot_pca_scores_pooled_raw.png")),
       p.scores.all.pooled, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)

# Loadings

pca.loadings.train <- tidy(pca.model, id = "pca", type = "coef") %>%
  select(-id) %>%
  filter(component %in% names(pca.scores.train)) %>%
  pivot_wider(values_from = "value", names_from = "component")

qsave(pca.loadings.train, paste0(mnt.dir, "metadata/pca_loadings.qs"))

pca.normalization.train <- tidy(pca.model, id = "normalization", type = "coef")

qsave(pca.normalization.train, paste0(mnt.dir, "metadata/pca_normalization.qs"))

p.loading <- pca.loadings.train %>%
  pivot_longer(-terms, names_to = "PC", values_to = "loading") %>%
  ggplot(aes(x = as.numeric(terms), y = loading, group = PC)) +
  geom_line(size = 0.5) +
  facet_wrap(~PC, ncol = 1, scale = "free_y") +
  labs(x = bquote(Wavenumber~(cm^-1)), y = "PCA loading",
       title = "Loadings of pooled pca") +
  scale_x_continuous(breaks = c(650, 1200, 1800, 2400, 3000, 3600, 4000),
                     trans = "reverse") +
  theme_light(); p.loading

ggsave(paste0(dir.output, paste0("plot_pca_loadings_pooled_raw.png")),
       p.loading, dpi = 300, width = 8, height = 6,
       units = "in", scale = 1)

## Exporting results

qsave(pca.scores.train, paste0(mnt.dir, "metadata/pca_scores_pooled_raw.qs"))
