#####CROSS-SECTIONAL ANALYSIS
#####STEP 1
#!/bin/bash

regenie \
  --step 1 \
  --bed /ukb_cal_allChrs_hg38 \
  --extract /qc_pass.snplist \
  --keep /VTE_ID.txt \
  --phenoFile /VTE_pheno.txt \
  --covarFile /VTE_cov.txt \
  --catCovarList /batch,sex \
  --maxCatLevels 30 \
  --bt \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix /tmp_prefix \
  --out /step1_list/
  
  
#####STEP2-single variant level
#!/bin/bash
regenie \
  --step 2 \
  --chr ${chrom} \
  --keep /VTE_ID.txt \
  --bed /Q0_unre_Caucasian_c${chrom} \
  --phenoFile /VTE_pheno.txt \
  --covarFile /VTE_cov.txt \
  --catCovarList batch,sex \
  --maxCatLevels 30 \
  --pred /step1_list/_pred.list \
  --apply-rint \
  --bt \
  --firth --firth-se --approx --pThresh 0.05 \
  --minMAC 20 \
  --bsize 1000 \
  --write-samples \
  --print-pheno \
  --out /step2_chr${chrom}


#####STEP2-gene-based level
#!/bin/bash
chrom=$1  # 1-22
genebased=$2 # 'Missense','PTV','Splice','UTR_3','UTR_5','Upstream','Downstream','RNA','Intron','Intergenic','Pseudo','Inframe','Synonymous'
subset=$3
regenie \
  --step 2 \
  --chr ${chrom} \
  --bed /Q0_unre_Caucasian_c${chrom} \
  --phenoFile /VTE_pheno.txt \
  --covarFile /VTE_cov.txt \
  --catCovarList batch,sex \
  --maxCatLevels 30 \
  --pred /step1_list/_pred.list \
  --anno-file /${genebased}_chr${chrom}.txt \
  --set-list /chr${chrom}_${genebased}.setlist \
  --mask-def /Mask_${genebased}.txt \
  # when calculating subset of masks, add the following command:
  --extract /chr${chrom}_${subset}.txt \
  --aaf-bins 0.01 \
  --vc-maxAAF 0.01 \
  --vc-tests skato,acato-full \
  --joint minp,acat,sbat \
  --rgc-gene-p \
  --check-burden-files \
  --write-mask \
  --bt \
  --firth --approx \
  --firth-se \
  --pThresh 0.05 \
  --bsize 200 \
  --threads 100 \
  --write-samples \
  --write-mask-snplist \
  --print-pheno \
  --out /${subset}_chr${chrom}_${genebased}

#####SURVIVAL ANALYSIS
#####STEP1
#!/bin/bash
regenie \
  --step 1 \
  --bed /ukb_cal_allChrs_hg38 \
  --extract /qc_pass.snplist \
  --phenoFile /VTE_pheno.txt \
  --covarFile /VTE_cov.txt \
  --catCovarList batch,sex \
  --maxCatLevels 30 \
  --bt \
  --t2e \
  --eventColList vte \
  --phenoColList vte_date \
  --bsize 1000 \
  --lowmem \
  --lowmem-prefix /tmp_prefix \
  --out /step1_list/


#####STEP2 single-variant level
#!/bin/bash
regenie \
  --step 2 \
  --chr ${chrom} \
  --bed /Q0_unre_Caucasian_c${chrom} \
  --phenoFile /VTE_pheno.txt \
  --covarFile /VTE_cov.txt \
  --catCovarList batch,sex \
  --maxCatLevels 30 \
  --bt \
  --firth --approx \
  --firth-se \
  --pThresh 0.05 \
  --t2e \
  --eventColList vte \
  --phenoColList vte_date \
  --pred /step1_list/_pred.list \
  --minMAC 20 \
  --bsize 1000 \
  --threads 100 \
  --write-samples \
  --print-pheno \
  --out /step2_chr${chrom}


#####STEP2 gene-based level
#!/bin/bash
chrom=$1 # 1-22
genebased=$2 # 'Missense','PTV','Splice','UTR_3','UTR_5','Upstream','Downstream','RNA','Intron','Intergenic','Pseudo','Inframe','Synonymous'
subset=$3
regenie \
  --step 2 \
  --chr ${chrom} \
  --bed /Q0_unre_Caucasian_c${chrom} \
  --phenoFile /VTE_pheno.txt \
  --covarFile /VTE_cov.txt \
  --catCovarList batch,sex \
  --maxCatLevels 30 \
  --anno-file /${genebased}_chr${chrom}.txt \
  --set-list /chr${chrom}_${genebased}.setlist \
  --mask-def /Mask_${genebased}.txt \
  # when calculating subset of masks, add the following command:
  --extract /chr${chrom}_${submask}.txt \
  --aaf-bins 0.01 \
  --vc-maxAAF 0.01 \
  --check-burden-files \
  --write-mask \
  --bt \
  --firth --approx \
  --firth-se \
  --pThresh 0.05 \
  --t2e \
  --eventColList vte \
  --phenoColList vte_date \
  --pred /step1_list/_pred.list \
  --bsize 200 \
  --threads 100 \
  --write-samples \
  --write-mask-snplist \
  --print-pheno \
  --out /${submask}_chr${chrom}_${genebased}


