
## Loading packages
library("tidyverse")

## Creating input/output dirs
if(!dir.exists("outputs")){dir.create("outputs")}
if(!dir.exists("inputs")){dir.create("inputs")}

## Mounted disk for storing big files
# mnt.dir <- "~/mnt-ringtrial/" # VM
mnt.dir <- "~/projects/mnt-ringtrial/" # Mac
