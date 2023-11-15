
## Loading packages
library("tidyverse")
library("readxl")

## Mounted disk for storing big files
# mnt.dir <- "~/mnt-ringtrial/" # VM
mnt.dir <- "~/projects/mnt-ringtrial/" # Mac

## Read files
list.files(mnt.dir)

excel_sheets(paste0(mnt.dir, "Spectrometers_Metadata.xlsx"))

metadata.raw <- read_xlsx(paste0(mnt.dir, "Spectrometers_Metadata.xlsx"), sheet = 1)
metadata.naming <- read_xlsx(paste0(mnt.dir, "Spectrometers_Metadata.xlsx"), sheet = 2, col_names = F)

metadata <- metadata.raw %>%
  select(code, manufacturer, model, year_built,
         beamsplitter, detector, mirror_material, accessory, background,
         sample_presentation, neat_mulled, Purged) %>%
  rename(purged = Purged) %>%
  filter(row_number() <= 20)

## Levels of manufacturer

metadata %>%
  distinct(manufacturer)

metadata <- metadata %>%
  mutate(manufacturer_clean = case_when(manufacturer == "PerkinElmer" ~ "Perkin Elmer",
                                  TRUE ~ manufacturer),
         .after = manufacturer) %>%
  mutate(manufacturer_clean = str_replace_all(manufacturer_clean, " ", "-"))

metadata %>%
  distinct(manufacturer_clean)

## Levels of model

metadata %>%
  distinct(model)

metadata <- metadata %>%
  mutate(model_clean = case_when(grepl("Alpha", model) ~ "Alpha",
                                 grepl("Vertex", model) ~ "Vertex",
                                 grepl("Nicolet", model) ~ "Nicolet",
                                 grepl("Invenio", model) ~ "Invenio",
                                 grepl("Tensor", model) ~ "Tensor",
                                 TRUE ~ model),
         .after = model) %>%
  mutate(model_clean = str_replace_all(model_clean, " ", "-"))

metadata %>%
  distinct(model_clean)

## Levels of year_built

metadata %>%
  distinct(year_built)

metadata <- metadata %>%
  mutate(year_built_clean = year_built,
         .after = year_built)

metadata %>%
  distinct(year_built_clean)

## Levels of beamsplitter

metadata %>%
  distinct(beamsplitter)

metadata <- metadata %>%
  mutate(beamsplitter_clean = case_when(grepl("OptKBr", beamsplitter) ~ "KBr",
                                        grepl("XT-KBr", beamsplitter) ~ "KBr",
                                        grepl("ZnSe or HeNe or KBr?", beamsplitter) ~ "ZnSe",
                                        grepl("widerange", beamsplitter) ~ "Widerange",
                                        TRUE ~ beamsplitter),
         .after = beamsplitter)

metadata %>%
  distinct(beamsplitter_clean)

## Levels of detector

metadata %>%
  distinct(detector)

metadata <- metadata %>%
  mutate(detector_clean = case_when(grepl("DLaTGS", detector) ~ "DTGS",
                                    grepl("RT-DLaTGS", detector) ~ "DTGS",
                                    grepl("MIR DTGS", detector) ~ "DTGS",
                                    grepl("DGTS", detector) ~ "DTGS",
                                    TRUE ~ detector),
         .after = detector) %>%
  mutate(detector_clean = str_replace_all(detector_clean, " ", "-"))

metadata %>%
  distinct(detector_clean)

## Levels of mirror_material

names(metadata)

metadata %>%
  distinct(mirror_material)

metadata <- metadata %>%
  mutate(mirror_material_clean = case_when(grepl("Not gold", mirror_material) ~ NA_character_,
                                           grepl("not known", mirror_material) ~ NA_character_,
                                           TRUE ~ mirror_material),
         .after = mirror_material)

metadata %>%
  distinct(mirror_material_clean)

## Levels of accessory

metadata %>%
  distinct(accessory)

metadata <- metadata %>%
  mutate(accessory_clean = case_when(grepl("Bruker Alpha QuickSnap", accessory) ~ "Bruker QuickSnap DRIFT",
                                     grepl("Bruker Front-facing accessory", accessory) ~ "Bruker Front Reflectance",
                                     grepl("Bruker Alpha II QuickSnap DRIFT", accessory) ~ "Bruker QuickSnap DRIFT",
                                     grepl("HTS-XT", accessory) ~ "Bruker HTS-XT",
                                     grepl("Pike X, Y Autosampler", accessory) ~ "Pike X,Y Autosampler",
                                     grepl("Collector II Diffuse Reflectance Accessory", accessory) ~ "Thermo-Fisher Collector II",
                                     grepl("DRIFT", accessory) ~ "Perkin Elmer DRIFT",
                                     TRUE ~ accessory),
         .after = accessory) %>%
  mutate(accessory_clean = str_replace_all(accessory_clean, " ", "-"))

metadata %>%
  distinct(accessory_clean)

## Levels of background

names(metadata)

metadata %>%
  distinct(background)

metadata <- metadata %>%
  mutate(background_clean = case_when(grepl("Roughened gold", background) ~ "Roughened Gold",
                                     TRUE ~ background),
         .after = background) %>%
  mutate(background_clean = str_replace_all(background_clean, " ", "-"))

metadata %>%
  distinct(background_clean)

## Levels of sample_presentation

names(metadata)

metadata %>%
  distinct(sample_presentation)

metadata <- metadata %>%
  mutate(sample_presentation_clean = case_when(grepl("Pressed / levelled|Pressed/levelled", sample_presentation) ~ "Pressed-Levelled",
                                      TRUE ~ sample_presentation),
         .after = sample_presentation)

metadata %>%
  distinct(sample_presentation_clean)

## Levels of neat_mulled

names(metadata)

metadata %>%
  distinct(neat_mulled)

metadata <- metadata %>%
  mutate(neat_mulled_clean = case_when(grepl("neat", neat_mulled) ~ "Neat",
                                       grepl("mulled", neat_mulled) ~ "Mulled",
                                       TRUE ~ neat_mulled),
         .after = neat_mulled)

metadata %>%
  distinct(neat_mulled_clean)

## Levels of purged

names(metadata)

metadata %>%
  distinct(purged)

metadata <- metadata %>%
  mutate(purged_clean = case_when(grepl("yes", purged) ~ "Yes",
                                  grepl("no", purged) ~ "No",
                                  TRUE ~ purged),
         .after = purged)

metadata %>%
  distinct(purged_clean)

## Export results

names(metadata.raw)

metadata.original <- metadata %>%
  filter(!is.na(code)) %>%
  select(code, !contains("clean"))

write_csv(metadata.original, "outputs/instruments_metadata_original.csv")

metadata.clean <- metadata %>%
  filter(!is.na(code)) %>%
  select(code, contains("clean"))

old.names <- names(metadata.clean)
new.names <- gsub("_clean", "", old.names)

metadata.clean <- rename_with(metadata.clean, ~new.names, old.names)

write_csv(metadata.clean, "outputs/instruments_metadata_clean.csv")
