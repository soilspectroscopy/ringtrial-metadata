
## Loading packages
library("tidyverse")
library("FactoMineR")
library("qs")
library("corrplot")

## Folders
mnt.dir <- "~/projects/mnt-ringtrial/"
dir.metadata <- paste0(mnt.dir, "metadata/")
dir.output <- "outputs/"

## Files
scores <- qread(paste0(dir.metadata, "pca_clustering.qs"))
scores

## Example
data(children)
children
res.ca <- CA (children, row.sup = 15:18, col.sup = 6:8)
plot(res.ca)
summary(res.ca)
ellipseCA(res.ca)
ellipseCA(res.ca,ellipse="col",col.col.ell=c(rep("blue",2),rep("transparent",3)),
          invisible=c("row.sup", "col.sup"))

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

# at least 5 for any cell
chi.sq.result$expected

# residuals
chi.sq.result$residuals
corrplot(chi.sq.result$residuals, is.cor = FALSE)

# contribution in percentage
contrib <- 100*chi.sq.result$residuals^2/chi.sq.result$statistic
round(contrib, 3)
corrplot(contrib, is.cor = FALSE)

ca.manufacturer <- CA(ct.manufacturer, graph = FALSE)
summary(ca.manufacturer)

plot(ca.manufacturer)
ellipseCA(ca.manufacturer)

ca.manufacturer$call
ca.manufacturer$row
ca.manufacturer$svd


# model
names(ca.data)

ct.model <- table(ca.data$cluster, ca.data$model)
ct.model

chi.sq.result <- chisq.test(ct.model)
chi.sq.result

chi.sq.result$expected

ca.data %>%
  distinct(model) %>%
  arrange(model)

rownames(ct.model) <- c("C1", "C2", "C3", "C4")
ct.model <- as.data.frame.matrix(ct.model)

ca.model <- CA(ct.model, graph = FALSE)

plot(ca.model)


