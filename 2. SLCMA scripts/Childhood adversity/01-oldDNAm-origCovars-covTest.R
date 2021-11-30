

## data
load("ARIES_betas_noTwin_rfaminst_pcs_20181023.Rdata")
dim(df)
head(df[,1:10])

## new data
load("ARIES_BP_rerun_20200225.Rdata")
dim(aries)
head(aries[,1:10])

#Selecting overlapping samples
length(which(df$ID %in% aries$ID))
df <- df[which(df$ID %in% aries$ID), ]
dim(df)

outcome.vec <- colnames(df)[87:ncol(df)]

load("updated_fscore_2021-06-01.Rdata", verbose=T)
fscore_fixed <- fscore_fixed[match(df$ID, df$ID),]
head(df)
df <- cbind(df, fscore_fixed[,-ncol(fscore_fixed)])



## double check the variable types
lapply(df[,1:90], function(x){
  class(x)
})

## load function for stage 1 LARS, complete data

source("covTest-function.R")
source("LARS-noimpute-function-20200225.R")

## a list for the recency vectors 
recency.vec.list <- list(c(18, 30, 42, 57, 69, 81)/12,
                         c(8, 21, 33, 61, 85)/12,
                         c(8, 21, 33, 47, 85)/12,
                         c(18, 30, 42, 57, 69, 81)/12,
                         c(21, 33, 61, 85)/12,
                         c(8, 21, 33, 47, 61, 73)/12,
                         c(8, 21, 33, 61, 73)/12,
                         c(8, 21, 33, 61, 85)/12)
names(recency.vec.list) <-   c("abuse", "Fscore",  "oneadult", "r_faminst", "nbhqual","parc","mompsy",
                               "Fscore_fixed")

covars <- c(## baseline characteristics,EXCLUDE SES
  "SES_parent", "WHITE", "Female", "mom_birthage", "ppregnum", "birth.weight","sustained.smoke",
  # cell counts
  "CD8", "CD4", "CD56", "CD19", "CD14", "Gran")

for(i in names(recency.vec.list)){
  a <- c(covars, colnames(df)[grep(i, colnames(df))] )
  b <- df[,a]
  cat(i, " ", sum(complete.cases(b)), "\n")
  rm(a, b)
}

for(adver in names(recency.vec.list)){
  print(paste0("Beginning to analyze ", adver))
  
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
  
  path = '/data/js95/DunnLab/DNAm-data-diff-analysis/results/'
  save(res, file = paste0(path, "LARS_rev2_rerun_stage1_covTest_", adver, "sampleOL_", Sys.Date(),".Rdata"))
}
