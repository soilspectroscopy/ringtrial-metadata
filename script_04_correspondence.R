
## Loading packages
library("tidyverse")
library("ggrepel")
library("qs")
library("ca")

options(scipen = 999)

## Folders
mnt.dir <- "~/projects/mnt-ringtrial/"
dir.metadata <- paste0(mnt.dir, "metadata/")
dir.output <- "outputs/"

## Files
scores <- qread(paste0(dir.metadata, "pca_clustering.qs"))
scores

## Correspondence analysis
metadata <- read_csv(paste0(dir.output, "instruments_metadata_clean.csv"))
metadata

metadata <- metadata %>%
  rename(organization = code) %>%
  mutate(organization = as.factor(organization))

ca.data <- left_join(scores, metadata, by = "organization") %>%
  mutate(cluster = paste0("C", cluster))

names(ca.data)

# manufacturer

ct.manufacturer <- table(ca.data$cluster, ca.data$manufacturer)
ct.manufacturer

chi.sq.result <- chisq.test(ct.manufacturer)
chi.sq.result

# observed
chi.sq.result$observed

# expected
chi.sq.result$expected

# this test must be run only with at least 5 values for any cell in the expected proportion
round(chi.sq.result$expected, 0)

# Pearson residuals - (observed - expected) / sqrt(expected)
chi.sq.result$residuals


# ca implementation
ca.manufacturer <- ca(ct.manufacturer)

# symmetric plot
plot(ca(ct.manufacturer))

# asymmetric plot - row principal
plot(ca(ct.manufacturer), map = "rowprincipal")


# custom implementation
ct.manufacturer.P    <- ct.manufacturer/sum(ct.manufacturer)
ct.manufacturer.r    <- apply(ct.manufacturer.P, 1, sum)
ct.manufacturer.c    <- apply(ct.manufacturer.P, 2, sum)
ct.manufacturer.Dr   <- diag(ct.manufacturer.r)
ct.manufacturer.Dc   <- diag(ct.manufacturer.c)
ct.manufacturer.Drmh <- diag(1/sqrt(ct.manufacturer.r))
ct.manufacturer.Dcmh <- diag(1/sqrt(ct.manufacturer.c))

ct.manufacturer.P   <- as.matrix(ct.manufacturer.P)
ct.manufacturer.S   <- ct.manufacturer.Drmh%*%(ct.manufacturer.P-ct.manufacturer.r%o%ct.manufacturer.c)%*%ct.manufacturer.Dcmh

ct.manufacturer.svd <- svd(ct.manufacturer.S)
ct.manufacturer.svd$d^2 # variance
ct.manufacturer.svd$d^2/sum(ct.manufacturer.svd$d^2)*100 # cumulative variance

ct.manufacturer.rsc <- ct.manufacturer.Drmh%*%ct.manufacturer.svd$u
ct.manufacturer.csc <- ct.manufacturer.Dcmh%*%ct.manufacturer.svd$v
ct.manufacturer.rpc <- ct.manufacturer.rsc%*%diag(ct.manufacturer.svd$d)
ct.manufacturer.cpc <- ct.manufacturer.csc%*%diag(ct.manufacturer.svd$d)

# standard coordinates
row.standard.data <- tibble(type = "cluster",
                            label = rownames(ct.manufacturer),
                            PC1 = ct.manufacturer.rsc[,1],
                            PC2 = ct.manufacturer.rsc[,2])

column.standard.data <- tibble(type = "metadata",
                               label = colnames(ct.manufacturer),
                               PC1 = ct.manufacturer.csc[,1],
                               PC2 = ct.manufacturer.csc[,2])

plot.standard.data <- bind_rows(row.standard.data, column.standard.data)

ggplot(plot.standard.data, aes(x = PC1, y = PC2, color = type, label = label)) +
  geom_point() + xlim(-3,3) + ylim(-3,3) +
  geom_vline(xintercept = 0, lty = "dashed", alpha = .5) +
  geom_hline(yintercept = 0, lty = "dashed", alpha = .5) +
  geom_label_repel(show.legend = F, segment.alpha = .5, point.padding = unit(5, "points")) +
  theme_light() + coord_fixed()

# principal coordinates
row.principal.data <- tibble(type = "cluster",
                            label = rownames(ct.manufacturer),
                            PC1 = ct.manufacturer.rpc[,1],
                            PC2 = ct.manufacturer.rpc[,2])

column.principal.data <- tibble(type = "metadata",
                               label = colnames(ct.manufacturer),
                               PC1 = ct.manufacturer.cpc[,1],
                               PC2 = ct.manufacturer.cpc[,2])

plot.principal.data <- bind_rows(row.principal.data, column.principal.data)

ggplot(plot.principal.data, aes(x = PC1, y = PC2, color = type, label = label)) +
  geom_point() + xlim(-1,2) + ylim(-1,1) +
  geom_vline(xintercept = 0, lty = "dashed", alpha = .5) +
  geom_hline(yintercept = 0, lty = "dashed", alpha = .5) +
  geom_label_repel(show.legend = F, segment.alpha = .5, point.padding = unit(5, "points")) +
  theme_light() + coord_fixed()

# scale 1: row principal

plot.row.principal <- bind_rows(row.principal.data, column.standard.data)

ggplot(plot.row.principal, aes(x = PC1, y = PC2, color = type, label = label)) +
  geom_point() + xlim(-3,3) + ylim(-3,3) +
  geom_vline(xintercept = 0, lty = "dashed", alpha = .5) +
  geom_hline(yintercept = 0, lty = "dashed", alpha = .5) +
  geom_label_repel(show.legend = F, segment.alpha = .5, point.padding = unit(5, "points")) +
  theme_light() + coord_fixed()
