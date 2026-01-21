library(data.table)
library(dplyr)

#### Read clinVar classification data
clinvar_classification <- fread("/Clinvar_classification.csv") %>% 
  .[, .(variantID, `Variant type`, `Germline classification`)]
#### Read meta data
meta_data <- fread("/meta_result.tsv")
#### VariantID match
reclassification <- clinvar_classification[meta_data, on = "variantID", nomatch = 0][, .(variantID, `Variant type`, `Germline classification`, OR, `95%_CI_LB`, `95%_CI_UB`, Pvalue)]
#### Reclassification based on odds ratio (OR) and confidence interval (CI)
reclassification[, Classification := fifelse(OR > 3 & `95%_CI_LB` > 1, "VIP",
                                       fifelse(`95%_CI_UB` < 1, "Supports benign",
                                               fifelse(`95%_CI_UB` > 1 & `95%_CI_LB` < 1, "Inconclusive", NA_character_)))]
fwrite(reclassification, "/Clinvar_reclassification.csv")