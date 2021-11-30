

## new data
load("ARIES_BP_rerun_20200225.Rdata")
dim(aries)
colnames(aries)
outcome.vec <- colnames(aries)[103:ncol(aries)]

load("ed_momgest_data.Rdata", verbose=T)
aries <- merge(aries, educ_dat, by = "ID", all.x = TRUE)

colnames(aries)[grep("smoke",colnames(aries))]

aries$smoke.trim.first <- aries$smoke.first.trim
aries$smoke.trim.second <- aries$smoke.second.trim
aries$smoke.trim.third <- aries$smoke.third.trim

adver <- "smoke.trim"
colnames(aries)[grep(adver, colnames(aries))]
recency.vec.list <- list(c(1,2,3))
names(recency.vec.list) <- "smoke.trim"

source("covTest-function.R")
source("LARS-noimpute-function-20200225")

res <- select.LARS.complete(aries, 
                            outcome.vec = outcome.vec, 
                            adver = adver,
                            covars <- c(## baseline characteristics,EXCLUDE SES
                              "SES_parent", "WHITE", "Female", "mom_birthage", "ppregnum", "birth.weight","sustained.smoke",
                              # cell counts
                              "CD8", "CD4", "CD56", "CD19", "CD14", "Gran"),
                            hypos <- c("accumulation", "recency"),
                            exposures <- "default",
                            recency.vec = recency.vec.list[adver][[1]],
                            inf.method = "covTest")

save(res, file = paste0("SLCMA-newDNAm-rerun-covTest-smoking_", 
                        Sys.Date(), ".Rdata"))

