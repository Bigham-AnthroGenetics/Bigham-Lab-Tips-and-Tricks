

# 1) Get VEP SIF, Download Cache Data 
# Described here: https://www.ensembl.info/2021/05/24/cool-stuff-the-vep-can-do-singularity/
# NOTE above link uses singularity instead of apptainer, 
# they are the same thing singularity just changed it's name to apptainer recently
# so you can drop in "apptainer" whereever it says "singularity"
# Emma's code below

# This part I did on an interactive node
module load apptainer
apptainer pull --name vep.sif docker://ensemblorg/ensembl-vep
apptainer exec vep.sif /opt/vep/src/ensembl-vep/vep #run

DATA_DIR="/u/project/awbigham/eewade/data/"
mkdir $DATA_DIR/vep_data
chmod a+rwx $DATA_DIR/vep_data 

# this part you may want to send to a scheduler (I don't quite remember how look it took but not instant), remember to change to GRCh37
apptainer exec \
  -B $DATA_DIR/vep_data:/opt/vep/.vep \
  /u/project/awbigham/eewade/Software/vep.sif \
  perl /opt/vep/src/ensembl-vep/INSTALL.pl \
  -a cf \
  -s homo_sapiens \
  -y GRCh38 \ 
  -c /opt/vep/.vep
  
# 2) Get AncestralAllele Plugin, get ancestral allele Fasta 
# Below copy and pasted from Ancestral allele plug-in: 
# https://raw.githubusercontent.com/ensembl-variation/VEP_plugins/main/AncestralAllele.pm
 
wget https://raw.githubusercontent.com/ensembl-variation/VEP_plugins/main/AncestralAllele.pm
mv AncestralAllele.pm ~/.vep/Plugins 
# example usage : ./vep -i variations.vcf --plugin AncestralAllele,homo_sapiens_ancestor_GRCh38.fa.gz

#An Ensembl VEP plugin that retrieves ancestral allele sequences from a FASTA file.

#Ensembl produces FASTA file dumps of the ancestral sequences of key species.
# - Data files for GRCh37: https://ftp.ensembl.org/pub/release-75/fasta/ancestral_alleles/
# - Data files for GRCh38: https://ftp.ensembl.org/pub/current_fasta/ancestral_alleles/

# For optimal retrieval speed, you should pre-process the FASTA files into a single
# bgzipped file that can be accessed via 'Bio::DB::HTS::Faidx' (installed by
# INSTALL.pl - see Ensembl/ensembl-vep repository):

# you may want to submit this to the scheduler as well
cd # wherever you want data stored 
wget https://ftp.ensembl.org/pub/current_fasta/ancestral_alleles/homo_sapiens_ancestor_GRCh38.tar.gz
tar xfz homo_sapiens_ancestor_GRCh38.tar.gz
cat homo_sapiens_ancestor_GRCh38/*.fa | bgzip -c > homo_sapiens_ancestor_GRCh38.fa.gz
rm -rf homo_sapiens_ancestor_GRCh38/ homo_sapiens_ancestor_GRCh38.tar.gz
# example usage: ./vep -i variations.vcf --plugin AncestralAllele,homo_sapiens_ancestor_GRCh38.fa.gz

# 3) Run VEP

# Emma's code below
#!/bin/bash
#$ -cwd
#$ -V
#$ -N vep
#$ -o /u/scratch/e/eewade/logs/$JOB_NAME.$TASK_ID.out
#$ -e /u/scratch/e/eewade/logs/$JOB_NAME.$TASK_ID.err
#$ -t 1-22 # my data is separated by chromosome so I have a separate job per chr
#$ -l h_rt=23:00:00,h_vmem=15G
#$ -pe share 4 

set -euo pipefail

#-------------------------------
# Load modules
#-------------------------------
. /u/local/Modules/default/init/modules.sh
module load apptainer

#-------------------------------
# Paths
#-------------------------------
DATA_DIR="/u/project/awbigham/eewade/data"
basedir="/u/home/e/eewade/project-awbigham/data/vcf_1kg220425"
PROC="${basedir}/processing"

chr="chr${SGE_TASK_ID}"
input="${basedir}/processed-mask-bisnp/mask.bisnp.1kGP.${chr}.vcf.gz"
vep_out="${PROC}/mask.bisnp.1kGP.vep.${chr}.vcf.gz"

#-------------------------------
# Step 1: VEP
#-------------------------------
if [ ! -s "$vep_out" ]; then
    log "[VEP] Running..."
    apptainer exec \
        -B ${DATA_DIR}/vep_data:/opt/vep/.vep \
        -B ${PWD}:/data \
        ${H2_CONTAINER_LOC}/vep.sif \
        vep \
        --input_file  ${input} \
        --output_file ${vep_out} \
        --vcf \
        --compress_output bgzip \
        --cache \
        --offline \
        --dir_cache /opt/vep/.vep \
        --assembly GRCh38 \ 
        --no_stats \
        --force_overwrite \
        --plugin AncestralAllele,${DATA_DIR}/vep_data/homo_sapiens_ancestor_GRCh38.fa 

    bcftools index -t -f "$vep_out"

fi

