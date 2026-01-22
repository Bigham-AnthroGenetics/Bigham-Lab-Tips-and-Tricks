# The PBS R file takes in fam files and frequency files from plink for 3 populations and outputs
# a file containing population branch statistics for each snp and each population

# The user of this document needs to change the path of the input files and the path of the output
# file at the very end of the document. 

# outside this script -- shuffle country 1, country 2 for FST maybe set country 1? 

#!/usr/bin/env Rscript
library("optparse")
library(data.table)

option_list = list(
  make_option(c("-s", "--samplelist"), type="character", default="~/project-awbigham/data/1kg/integrated_call_samples_v3.20130502.ALL.panel", 
              help=".panel file format, column named pop and superpop, used for population size and shuffling", metavar="character"),
  make_option(c("-c", "--chromosome"), type="character" ,
              help="chr for freq file, contains all pops in |x|x| format from Johnson & Voight 2018", metavar="character"),
  make_option(c("--pop1"), type="character", 
              help="population that will be looped against", metavar="character") ,
  make_option(c("--pop2"), type="character", 
              help="lowest Fst to P1", metavar="character") ,
  make_option(c("--pop3"), type="character", 
              help="outgroup", metavar="character")
  ); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

stopifnot(
  !is.null(opt$chromosome),
  !is.null(opt$pop1),
  !is.null(opt$pop2),
  !is.null(opt$pop3)
)

cat("Running:",
    "chr =", opt$chromosome,
    "P1 =", opt$pop1,
    "P2 =", opt$pop2,
    "P3 =", opt$pop3, "\n")

samplelist=fread(opt$samplelist)
# freqfile=opt$freq # need to do fancier read
target_chr=opt$chromosome 
p1=opt$pop1
p2=opt$pop2
p3=opt$pop3




if (F){ #for testing
  samplelist=fread("~/project-awbigham/data/1kg/integrated_call_samples_v3.20130502.ALL.panel")
  freq=fread("~/project-awbigham/data/predictors/selscanmetrics/chr21.1kg.p3.allPops.iHS.txt") # will have to make a fancier read in 
  p1="TSI"
  p2="IBS" # closest 
  p3="YRI" # different continent 
  targetchr=4
  
}


# Greta's arguments: 
# load fam files - map files are also acceptable inputs 
# 
#pop1_fam <- read.table("/Users/gretagerdes/Documents/first_year/plink/for_greta/PBS/peru.fam", header = TRUE )
#pop2_fam <- read.table("/Users/gretagerdes/Documents/first_year/plink/for_greta/PBS/mex.fam", header = TRUE)
#pop3_fam <- read.table("/Users/gretagerdes/Documents/first_year/plink/for_greta/PBS/ceu.fam", header = TRUE)

# gather population information
#pop_size1 <- nrow(pop1_fam)
#pop_size2 <- nrow(pop2_fam)
#pop_size3 <- nrow(pop3_fam)

# load frequency files
#pop1 <- read.table("/Users/gretagerdes/Documents/first_year/plink/for_greta/PBS/peru.frq", header = TRUE )
#pop2 <- read.table("/Users/gretagerdes/Documents/first_year/plink/for_greta/PBS/mex.frq", header = TRUE)
#pop3 <- read.table("/Users/gretagerdes/Documents/first_year/plink/for_greta/PBS/ceu.frq", header = TRUE)

# ------------------------------------------------------------
# Function: process_chr_pop
# ------------------------------------------------------------
process_chr_pop <- function(ihs_tar, chr_file, pops_keep, pops) {
  pop_idx <- match(pops_keep, pops)
  
  cmd <- sprintf("tar -xOf %s %s", ihs_tar, chr_file)
  ihs <- fread(cmd, showProgress = FALSE)
  
  daf_split <- tstrsplit(ihs$DAF, "\\|", type.convert = TRUE)
  
  ihs_out <- ihs[, c(
    .(
      CHR   = as.character(CHR),
      POS   = POS,
      RSNUM = RSNUM
    ),
    setNames(
      lapply(pop_idx, function(i) daf_split[[i]]),
      pops_keep
    )
  )]
  
  
  ihs_out
}

# calculates pairwise fst for 2 populations where c is the relative size of the ith population
calculate_Fst <- function(freq1,freq2,c1,c2){
  if(freq1 == 0 | freq2 == 0){
    return(NA)
  }
  p_bar <- (freq1+freq2)/2
  q_bar <- ((1 - freq1)+ (1 - freq2))/2
  # expected heterozygosity based on HWE 
  HS_1 <- 2*freq1*q_bar
  HS_2 <- 2*freq2*q_bar
  HS <- (HS_1*c1 + HS_2*c2)/(c1+c2)
  # total expected heterozygosity
  HT <- 2*p_bar*q_bar
  # calculate Fst 
  Fst <- (HT - HS)/HT
  
  # treat negative Fst values as 0 
  if (is.na(Fst)) {
    return(NA)
  } else if (Fst < 0 ){
    return(0)
  } else {
    return(Fst)
  }
}

# calculate PBS for one population at one locus
calculate_single_PBS <- function(Fst1, Fst2, Fst3){
  T1 <- -log10(1- Fst1)
  T2 <- -log10(1 - Fst2)
  T3 <- -log10(1 - Fst3)
  PBS <- .5*(T1 +T2 - T3)
  return(PBS)
}

# calculates PBS for an entire table of snps and allele frequencies
calculate_PBS<- function(freq_table,pop_size1,pop_size2,pop_size3, p1_name, p2_name, p3_name){
  PBS_table <- data.frame(matrix(0,ncol = 9, nrow = nrow(freq_table)))
  PBS_table[,1] <- freq_table$CHR
  PBS_table[,2] <- freq_table$POS
  PBS_table[,3] <- freq_table$RSNUM
  
  colnames(PBS_table) <- c("CHR", "POS", "RSNUM", "PBS1", "PBS2", "PBS3", "Fst1_2", "Fst1_3", "Fst2_3")
  
  for(snp in 1:nrow(freq_table)){
    current_snp <- freq_table[snp,]
    # calculate pairwise Fst between two subpopulations
    Fst1_2 <- calculate_Fst(current_snp[[p1_name]],current_snp[[p2_name]], pop_size1,pop_size2)
    PBS_table[snp,"Fst1_2"] <- Fst1_2
    Fst1_3 <- calculate_Fst(current_snp[[p1_name]],current_snp[[p3_name]],pop_size1,pop_size3)
    PBS_table[snp,"Fst1_3"] <- Fst1_3
    Fst2_3 <- calculate_Fst(current_snp[[p2_name]],current_snp[[p3_name]],pop_size2,pop_size3)
    PBS_table[snp,"Fst2_3"] <- Fst2_3
    
    # calculate PBS for each population and store it 
    PBS_table[snp,"PBS1"] <- calculate_single_PBS(Fst1_2, Fst1_3 , Fst2_3)
    PBS_table[snp,"PBS2"] <- calculate_single_PBS(Fst1_2, Fst2_3 , Fst1_3)
    PBS_table[snp, "PBS3"] <- calculate_single_PBS(Fst2_3, Fst1_3 , Fst1_2)
  }
  return(PBS_table)
}

#calculate_PBS(freq_table, samplelistfreq[[p1]], samplelistfreq[[p2]], samplelistfreq[[p3]])
# Vectorized PBS for one population
calculate_single_PBS_faster <- function(Fst1, Fst2, Fst3) {
  
  T1 <- -log10(1 - Fst1)
  T2 <- -log10(1 - Fst2)
  T3 <- -log10(1 - Fst3)
  
  0.5 * (T1 + T2 - T3)
}

# Vectorized pairwise Fst for two populations
calculate_Fst_faster <- function(freq1, freq2, c1, c2) {
  
  Fst <- rep(NA_real_, length(freq1))
  
  ok <- freq1 > 0 & freq2 > 0 &
    !is.na(freq1) & !is.na(freq2)
  
  p_bar <- (freq1[ok] + freq2[ok]) / 2
  q_bar <- 1 - p_bar
  
  HS_1 <- 2 * freq1[ok] * q_bar
  HS_2 <- 2 * freq2[ok] * q_bar
  HS   <- (HS_1 * c1 + HS_2 * c2) / (c1 + c2)
  
  HT <- 2 * p_bar * q_bar
  
  fst_vals <- (HT - HS) / HT
  fst_vals[fst_vals < 0] <- 0
  
  Fst[ok] <- fst_vals
  Fst
}

calculate_PBS_faster <- function(freq_table,
                                 pop_size1, pop_size2, pop_size3,
                                 p1_name, p2_name, p3_name) {
  
  p1 <- freq_table[[p1_name]]
  p2 <- freq_table[[p2_name]]
  p3 <- freq_table[[p3_name]]
  
  Fst1_2 <- calculate_Fst_faster(p1, p2, pop_size1, pop_size2)
  Fst1_3 <- calculate_Fst_faster(p1, p3, pop_size1, pop_size3)
  Fst2_3 <- calculate_Fst_faster(p2, p3, pop_size2, pop_size3)
  
  PBS1 <- calculate_single_PBS_faster(Fst1_2, Fst1_3, Fst2_3)
  PBS2 <- calculate_single_PBS_faster(Fst1_2, Fst2_3, Fst1_3)
  PBS3 <- calculate_single_PBS_faster(Fst2_3, Fst1_3, Fst1_2)
  
  data.frame(
    CHR   = freq_table$CHR,
    POS   = freq_table$POS,
    RSNUM = freq_table$RSNUM,
    PBS1, PBS2, PBS3,
    Fst1_2, Fst1_3, Fst2_3
  )
}


# function to clean the PBS table
clean_PBS <- function(PBS_table){
  complete_PBS <- PBS_table[complete.cases(PBS_table),]
  remove_index <- c()
  
  # remove snps that have 0 for more than 1 pairwise Fst 
  for (i in 1:nrow(complete_PBS)){
    zero_count <- 0
    if(complete_PBS$Fst1_2[i] == 0){
      zero_count <- zero_count +1 
    }
    if(complete_PBS$Fst1_3[i] == 0){
      zero_count <- zero_count + 1
    }
    if (complete_PBS$Fst2_3[i] == 0){
      zero_count <- zero_count +1
    }
    if (zero_count > 1){
      remove_index <- c(remove_index, i)
    }
  }
  # negative PBS values treated as 0 
  PBS1_neg_index <- which(complete_PBS$PBS1 < 0)
  complete_PBS[PBS1_neg_index,"PBS1"] <- 0
  PBS2_neg_index <- which(complete_PBS$PBS2 < 0)
  complete_PBS[PBS2_neg_index,"PBS2"] <- 0
  PBS3_neg_index <- which(complete_PBS$PBS3 < 0)
  complete_PBS[PBS3_neg_index,"PBS3"] <- 0
  
  final_PBS <- complete_PBS[-remove_index,]
  return(final_PBS)
}


pops <- c("ESN","GWD","LWK","MSL","YRI","ACB","ASW",
          "CLM","MXL","PEL","PUR","CDX","CHB","CHS",
          "JPT","KHV","CEU","FIN","GBR","IBS","TSI",
          "BEB","GIH","ITU","PJL","STU")

ihs_tar <- "~/project-awbigham/data/predictors/selscanmetrics/JohnsonEA_iHSscores.tar.gz"
#ihs_files <- system(paste("tar -tzf", ihs_tar), intern = TRUE)
chr_file <- paste0("chr", target_chr, ".1kg.p3.allPops.iHS.txt")

#freq_table <- generate_freq_table(pop1,pop2,pop3)
freq_table = process_chr_pop(ihs_tar, chr_file, c(p1, p2, p3), pops)
samplelistfreq = table(samplelist$pop)

PBS_table <- calculate_PBS_faster(freq_table, samplelistfreq[[p1]], samplelistfreq[[p2]], samplelistfreq[[p3]], p1, p2, p3)
clean_PBS <- clean_PBS(PBS_table)

write.csv(clean_PBS, paste("/u/scratch/e/eewade/pbs_fst/PBS_", p1, "_", p2, "_", p3, "_chr_", target_chr, "_faster.csv", sep=""), quote=F, row.names = FALSE)


