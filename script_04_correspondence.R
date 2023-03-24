
## Loading packages
library("tidyverse")
library("ggrepel")
library("qs")
library("ca")

options(scipen = 999)
set.seed(1993)

## Folders
mnt.dir <- "~/projects/mnt-ringtrial/"
dir.metadata <- paste0(mnt.dir, "metadata/")
dir.output <- "outputs/"

## Files
scores <- qread(paste0(dir.metadata, "pca_majority.qs"))
scores

## Correspondence analysis
metadata <- read_csv(paste0(dir.output, "instruments_metadata_clean.csv"))
metadata

metadata <- metadata %>%
  rename(organization = code) %>%
  mutate(organization = as.factor(organization))

metadata <- metadata %>%
  mutate(manufacturer2 = ifelse(is.na(manufacturer),
                                NA,
                                abbreviate(gsub("-", " ", manufacturer), minlength = 3)), .after = manufacturer) %>%
  mutate(model = ifelse(is.na(manufacturer),
                        NA,
                        paste(manufacturer2, model, sep = "-"))) %>%
  select(-manufacturer2)

ca.data <- left_join(scores, metadata, by = "organization") %>%
  mutate(cluster = paste0("C", cluster)) %>%
  mutate(majority = paste0("C", majority))

names(ca.data)

## All info

names(ca.data)
names(metadata)

# All metadata info
target.metadata <- names(metadata)[-1]

# Only info with at least two levels, and removing year_built
apply(ca.data[,target.metadata], 2, function(x) length(table(x)))

# Final metadata info
target.metadata <- metadata %>%
  select(-organization, -year_built, -neat_mulled) %>%
  names(.)

apply(ca.data[,target.metadata], 2, function(x) length(table(x)))

# Automated analysis

contingency.tables.list <- list()

i=1
for(i in 1:length(target.metadata)){
  
  # contingency table
  
  selected.metadata <- target.metadata[i]
  
  ct <- table(pull(ca.data, majority), pull(ca.data, selected.metadata))
  
  contingency.tables.list[[i]] <- ct
  
  chi.sq.result <- chisq.test(ct)
  
  # implementation
  
  ct.P    <- ct/sum(ct)
  ct.r    <- apply(ct.P, 1, sum)
  ct.c    <- apply(ct.P, 2, sum)
  ct.Dr   <- diag(ct.r)
  ct.Dc   <- diag(ct.c)
  ct.Drmh <- diag(1/sqrt(ct.r))
  ct.Dcmh <- diag(1/sqrt(ct.c))
  
  ct.P   <- as.matrix(ct.P)
  ct.S   <- ct.Drmh%*%(ct.P-ct.r%o%ct.c)%*%ct.Dcmh
  
  ct.svd <- svd(ct.S)
  pca.percents <- round(ct.svd$d^2/sum(ct.svd$d^2)*100, 2)
  
  ct.rsc <- ct.Drmh%*%ct.svd$u
  ct.csc <- ct.Dcmh%*%ct.svd$v
  ct.rpc <- ct.rsc%*%diag(ct.svd$d)
  ct.cpc <- ct.csc%*%diag(ct.svd$d)
  
  # standard coordinates
  
  row.standard.data <- tibble(type = "Row",
                              label = rownames(ct),
                              PC1 = ct.rsc[,1],
                              PC2 = ct.rsc[,2])
  
  column.standard.data <- tibble(type = "Column",
                                 label = colnames(ct),
                                 PC1 = ct.csc[,1],
                                 PC2 = ct.csc[,2])
  
  # principal coordinates
  
  row.principal.data <- tibble(type = "Row",
                               label = rownames(ct),
                               PC1 = ct.rpc[,1],
                               PC2 = ct.rpc[,2])
  
  column.principal.data <- tibble(type = "Column",
                                  label = colnames(ct),
                                  PC1 = ct.cpc[,1],
                                  PC2 = ct.cpc[,2])
  
  # scale 1: row-principal
  
  plot.row.principal <- bind_rows(row.principal.data, column.standard.data)
  
  plot.p.value <- chi.sq.result$p.value
  plot.p.value <- ifelse(plot.p.value < 0.01, " < 0.01", paste0(" = ", round(plot.p.value, 2)))
  plot.chi.value <- round(chi.sq.result$statistic, 2)
  
  plot.label <- paste0("χ² = ", plot.chi.value, ", p", plot.p.value)
  
  p.ca.assymetrical <- ggplot(plot.row.principal, aes(x = PC1, y = PC2, color = type, label = label)) +
    geom_point(show.legend = T) + coord_cartesian(xlim = c(-3,4), ylim = c(-3,4)) +
    geom_vline(xintercept = 0, lty = "dashed", alpha = .5) +
    geom_hline(yintercept = 0, lty = "dashed", alpha = .5) +
    geom_label_repel(show.legend = F, segment.alpha = .5, point.padding = unit(5, "points")) +
    annotate("text", x = Inf, y = Inf, label = plot.label, vjust=2, hjust=1.1) +
    labs(x = paste0("PC1 (", pca.percents[1], "%)"),
         y = paste0("PC2 (", pca.percents[2], "%)"),
         color = "") +
    theme_light() + theme(legend.position = "bottom")
  
  ggsave(paste0(dir.output, paste0("plot_paper_ca_", selected.metadata, ".png")),
         p.ca.assymetrical, dpi = 300, width = 8, height = 6,
         units = "in", scale = 1)
  
}

contingency.tables.list

qsave(contingency.tables.list, "outputs/contingency_tables.qs")

target.metadata
clipr::write_clip(contingency.tables.list[[1]])
clipr::write_clip(contingency.tables.list[[2]])
clipr::write_clip(contingency.tables.list[[3]])
clipr::write_clip(contingency.tables.list[[4]])
clipr::write_clip(contingency.tables.list[[5]])
clipr::write_clip(contingency.tables.list[[6]])
clipr::write_clip(contingency.tables.list[[7]])
clipr::write_clip(contingency.tables.list[[8]])
