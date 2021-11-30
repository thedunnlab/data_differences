
setwd("")
## packages 

## data
# load("ARIES_betas_noTwin_rfaminst_pcs_20181023.Rdata")
load("ARIES_BP_rerun_20200225.Rdata")
load("updated_fscore_2021-06-01.Rdata", verbose=T)

# colnames(aries)
outcome.vec <- colnames(aries)[103:ncol(aries)]

fscore_fixed <- fscore_fixed[match(aries$ID, fscore_fixed$ID),]
head(fscore_fixed)
aries <- cbind(aries, fscore_fixed[,-ncol(fscore_fixed)])

## double check the variable types
# lapply(aries[,1:101], function(x){
#   class(x)
# })

## load function for stage 1 LARS, complete data
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

## no FWL
## original covariates (SES parent instead of education)

for(adver in names(recency.vec.list)){
  print(paste0("Beginning to analyze ", adver))
  
res <- select.LARS.complete(df = aries, 
                                  outcome.vec = outcome.vec, 
                                  adver = adver,
                                  covars = c(
                                    # "ed_momgest", 
                                    "SES_parent",
                                    "WHITE", "Female", "mom_birthage", "ppregnum", "birth.weight","sustained.smoke",
                                    # cell counts
                                    "Bcell", "CD4T", "CD8T", "Gran", "Mono", "NK", "sample_type"),
                                  hypos <- c("accumulation", "recency"),
                                  exposures <- "default",
                                  recency.vec = recency.vec.list[adver][[1]],
                                  inf.method = "sI",
                                  FWL = FALSE)

save(res, file = paste0("SLCMA-newDNAm-rerun-sI-noFWL-original-covars", 
                        adver, "_",Sys.Date(),".Rdata"))
}
