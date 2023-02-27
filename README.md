Soil spectroscopy ring trial
================

-   <a href="#overview" id="toc-overview">Overview</a>
-   <a href="#metadata" id="toc-metadata">Metadata</a>
-   <a href="#pooled-pca" id="toc-pooled-pca">Pooled PCA</a>
-   <a href="#clustering-analysis" id="toc-clustering-analysis">Clustering
    analysis</a>
-   <a href="#correspondence-analysis"
    id="toc-correspondence-analysis">Correspondence analysis</a>

## Overview

Inter-laboratory comparison of soil spectral measurements as part of the
SoilSpec4GG project.

This repository is used for analyzing the metadata of different
instruments of the ring trial.

The workspace development is defined by:

-   GitHub repository:
    [soilspectroscopy/ringtrial-metadata](https://github.com/soilspectroscopy/ringtrial-metadata).
-   Google Cloud storage for efficient file storage and access:
    [whrc.org/soilcarbon-soilspec/storage/sc-ringtrial](https://console.cloud.google.com/storage/browser/sc-ringtrial).

## Metadata

Similar levels were grouped to a common format. All strings starts with
upper case in the first letter. Spaces are replaced with dash.

The following information was prepared:

-   Manufacturer: the instrument’s manufacturer. Only spaces replaced
    with dash.  
-   Model: the instrument’s model. Several levels are provided, so model
    number was omitted to group the variation to a common model. Spaces
    replaced with dash.  
-   Year: year the instrument was built. No modification.  
-   Beamsplitter: The crystal used to split the beam for generating the
    interferogram. Some proprietary materials have some coatings but
    they were placed under the same basic material.  
-   Detector: The beam detector that is part of the interferogram.
    Again, some variations were placed under the same basic type.  
-   Mirror: mirror material as part of the interferogram..  
-   Accessory: scanning accessory for DRIFT. Manufacturer and accessory
    name is provided. Names formatted to a common string
-   Background: material used as reference for internal calibration.  
-   Sample presentation: soil sample presentation (in the accessory)
    before scanning.  
-   Neat/Mulled: additional sample preparation. Mulled = mixed with a
    compound to form a paste. Neat = unmixed.  
-   Purged: internal gas cleaning before scanning.

Prepared metadata:

| code | manufacturer  | model              | year_built | beamsplitter | detector     | mirror_material | accessory                 | background          | sample_presentation | neat_mulled | purged |
|-----:|:--------------|:-------------------|-----------:|:-------------|:-------------|:----------------|:--------------------------|:--------------------|:--------------------|:------------|:-------|
|    1 | NA            | NA                 |         NA | NA           | NA           | NA              | NA                        | NA                  | NA                  | NA          | NA     |
|    2 | Bruker        | Alpha              |       2020 | KBr          | DTGS         | Gold            | Bruker-QuickSnap          | Roughened-Gold      | Levelled            | Neat        | No     |
|    3 | Bruker        | Vertex             |       2013 | KBr          | DTGS         | NA              | Bruker-HTS-XT             | Roughened-Gold      | Levelled            | Neat        | NA     |
|    4 | Perkin-Elmer  | Spectrum-100       |       2010 | KBr          | DTGS         | NA              | Pike-AutoDiff             | KBr                 | Levelled            | NA          | NA     |
|    5 | Agilent       | 4300-Handheld-FTIR |       2014 | ZnSe         | DTGS         | Aluminium       | Handheld-FTIR             | Roughened-Aluminium | Pressed-Levelled    | NA          | No     |
|    6 | Bruker        | Alpha              |       2012 | ZnSe         | DTGS         | Gold            | Bruker-QuickSnap          | Roughened-Gold      | Pressed-Levelled    | Neat        | NA     |
|    7 | Bruker        | Alpha              |       2013 | ZnSe         | DTGS         | Gold            | Bruker-QuickSnap          | Roughened-Gold      | Levelled            | Neat        | No     |
|    8 | Bruker        | Vertex             |       2015 | Widerange    | MIR-detector | Gold            | Pike-AutoDiff             | Mirror              | Levelled            | Neat        | Yes    |
|    9 | Thermo-Fisher | Nicolet            |       2020 | KBr          | MCT          | Aluminium       | Termo-Fisher-Collector-II | Mirror              | Pressed-Levelled    | Neat        | Yes    |
|   10 | Bruker        | Vertex             |       2017 | KBr          | MCT          | Gold            | Bruker-HTS-XT             | Roughened-Gold      | Pressed             | NA          | NA     |
|   11 | Bruker        | Alpha              |       2021 | KBr          | DTGS         | Gold            | Bruker-QuickSnap          | Roughened-Gold      | Pressed             | Neat        | No     |
|   12 | Thermo-Fisher | Nicolet            |       2018 | KBr          | DTGS         | Gold            | Pike-X,Y-Autosampler      | KBr                 | Levelled            | NA          | No     |
|   13 | Perkin-Elmer  | FT-IR-II           |       2018 | ZnSe         | DTGS         | Aluminium       | Perkin-Elmer-DRIFT        | Mirror              | Levelled            | Neat        | No     |
|   14 | Thermo-Fisher | Nicolet            |       2015 | KBr          | DTGS         | Gold            | Pike-X,Y-Autosampler      | KBr                 | Levelled            | Neat        | No     |
|   15 | Bruker        | Alpha              |       2019 | ZnSe         | DTGS         | Gold            | Bruker-QuickSnap          | Roughened-Gold      | Levelled            | Neat        | No     |
|   16 | Bruker        | Vertex             |         NA | KBr          | MCT          | NA              | Bruker-HTS-XT             | Roughened-Aluminium | Pressed             | Neat        | No     |
|   17 | Bruker        | Invenio            |       2022 | KBr          | DTGS         | Gold            | Bruker-HTS-XT             | Roughened-Gold      | Pressed             | NA          | NA     |
|   18 | Bruker        | Invenio            |       2020 | KBr          | MCT          | Gold            | Bruker-HTS-XT             | Roughened-Gold      | Pressed             | NA          | Yes    |
|   19 | Bruker        | Tensor             |       2016 | KBr          | DTGS         | Gold            | Bruker-HTS-XT             | Roughened-Gold      | Levelled            | NA          | Yes    |
|   20 | Bruker        | Alpha              |         NA | ZnSe         | DTGS         | NA              | NA                        | Roughened-Gold      | NA                  | Neat        | NA     |

## Pooled PCA

Pooled PCA was performend to retain 99.5% of the original variance. This
resulted in 7 components.

<img src="outputs/plot_pca_scores_pooled_raw.png" width=100% heigth=100%>

<img src="outputs/plot_pca_loadings_pooled_raw.png" width=100% heigth=100%>

## Clustering analysis

<img src="outputs/plot_kmeans_aic_absolute.png" width=100% heigth=100%>

<img src="outputs/plot_kmeans_aic_relative.png" width=100% heigth=100%>

<img src="outputs/plot_kmeans_clusters.png" width=100% heigth=100%>

Proportion of instrument samples (%) belonging to spectral clusters

| instrument | majority |      C1 |      C2 |      C3 |     C4 |
|-----------:|:---------|--------:|--------:|--------:|-------:|
|          1 | C4       |   0.000 |   1.429 |   1.429 | 97.143 |
|          2 | C3       |  11.429 |   0.000 |  88.571 |  0.000 |
|          3 | C4       |   0.000 |   1.429 |   2.857 | 95.714 |
|          4 | C2       |   0.000 |  71.429 |   0.000 | 28.571 |
|          5 | C2       |   0.000 |  55.714 |   0.000 | 44.286 |
|          6 | C3       |   4.286 |   0.000 |  95.714 |  0.000 |
|          7 | C3       |   7.143 |   0.000 |  92.857 |  0.000 |
|          8 | C3       |   0.000 |   0.000 | 100.000 |  0.000 |
|          9 | C2       |   0.000 | 100.000 |   0.000 |  0.000 |
|         10 | C4       |   0.000 |   1.429 |   0.000 | 98.571 |
|         11 | C1       | 100.000 |   0.000 |   0.000 |  0.000 |
|         12 | C2       |   0.000 |  67.143 |   1.429 | 31.429 |
|         13 | C2       |   0.000 | 100.000 |   0.000 |  0.000 |
|         14 | C4       |   0.000 |  34.286 |   0.000 | 65.714 |
|         15 | C3       |   7.143 |   0.000 |  92.857 |  0.000 |
|         16 | C4       |   0.000 |   1.429 |   1.429 | 97.143 |
|         17 | C2       |   0.000 |  97.143 |   0.000 |  2.857 |
|         18 | C4       |   0.000 |   0.000 |   2.857 | 97.143 |
|         19 | C4       |   0.000 |   4.286 |   0.000 | 95.714 |
|         20 | C3       |   2.857 |   0.000 |  97.143 |  0.000 |

<img src="outputs/plot_kmeans_clusters_majority.png" width=100% heigth=100%>

<img src="outputs/plot_spectral_variation_clusters.png" width=100% heigth=100%>

## Correspondence analysis
