
## old data
load("ARIES_betas_noTwin_rfaminst_pcs_20181023.Rdata")
dim(df)
head(df[,1:10])

outcome.vec <- colnames(df)[87:ncol(df)]

## new data
load("ARIES_BP_rerun_20200225.Rdata")
dim(aries)
head(aries[,1:10])

#Selecting overlapping samples
length(which(df$ID %in% aries$ID))
df <- df[which(df$ID %in% aries$ID), ]
dim(df)


load("ed_momgest_data.Rdata", verbose=T)
df <- merge(df, educ_dat, by = "ID", all.x = TRUE)


colnames(df)[grep("smoke",colnames(df))]

df$smoke.trim.first <- df$smoke.first.trim
df$smoke.trim.second <- df$smoke.second.trim
df$smoke.trim.third <- df$smoke.third.trim

adver <- "smoke.trim"
colnames(df)[grep(adver, colnames(df))]
recency.vec.list <- list(c(1,2,3))
names(recency.vec.list) <- "smoke.trim"

source("covTest-function.R")
source("LARS-noimpute-function-20200225")

res <- select.LARS.complete(df, 
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

save(res, file = paste0("SLCMA-oldDNAm-rerun-covTest-smoking_", 
                        Sys.Date(), ".Rdata"))

