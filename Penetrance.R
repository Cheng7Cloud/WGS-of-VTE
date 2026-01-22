# Step 1: Extract individual-level genotypes for each gene-mask-MAF bin using PLINK
# Files are saved as: Gene_chrXX_mask_MAFbin.raw (XX is chromosome number)

pacman::p_load(data.table, dplyr, magrittr)

# Step 2: Collapse variants to gene-level carrier status (sum of alternate alleles)
# This code processes each .raw file

extract_dir <- "./extracted"
raw_files <- list.files(extract_dir, pattern = "\\.raw$", full.names = TRUE)

for (file in raw_files) {
  data <- fread(file) %>% as.data.frame() 
  selected_data <- data %>% select(IID, all_alt_alleles)
  selected_data$sum <- rowSums(selected_data[, -1, drop = FALSE], na.rm = TRUE) # sum of alternate alleles for each gene-mask-MAF bin
  output_data <- selected_data[, c("IID", "sum")]
  output_file <- gsub("\\.raw$", ".sum", file)
  fwrite(output_data, output_file, sep = "\t", row.names = FALSE, col.names = TRUE)
}

# Step 3: Calculate penetrance per gene-mask-MAFbin

meta <- fread("gene_mask_mafbin_annotation.tsv")  # columns: filename_base, Gene, SYMBOL, CHROM, mask, MAFbin
outcome <- fread("total_pheno.txt") %>% as.data.frame() %>% select(IID, vte)

sum_files <- list.files(extract_dir, pattern = "\\.sum$", full.names = TRUE)
results <- data.frame()

for (file in sum_files) {
  base_name <- tools::file_path_sans_ext(basename(file))
  
  info <- meta %>% filter(filename_base == base_name)
  
  sum_data <- fread(file) %>% as.data.frame()
  merged_data <- merge(sum_data, outcome, by = "IID", all.x = TRUE)
  
  carriers <- merged_data %>% filter(sum > 0)
  n_carrier <- nrow(carriers)
  n_vte_case <- sum(carriers$vte == 1, na.rm = TRUE)
  penetrance <- if (n_carrier > 0) n_vte_case / n_carrier else NA_real_
  
  result_row <- data.frame(
    Gene    = info$Gene[1],
    SYMBOL  = info$SYMBOL[1],
    CHROM   = info$CHROM[1],
    mask    = info$mask[1],
    MAFbin  = info$MAFbin[1],
    n_carrier   = n_carrier,
    n_vte_case  = n_vte_case,
    penetrance  = penetrance
  )
  
  results <- rbind(results, result_row)
}

fwrite(results, "./results/penetrance_results.tsv", sep = "\t", na = "NA", row.names = FALSE)
