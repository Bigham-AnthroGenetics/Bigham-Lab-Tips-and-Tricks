#!/bin/bash
#$ -cwd
#$ -V
#$ -N PBS_chr
#$ -o /u/scratch/e/eewade/logs/$JOB_NAME.$TASK_ID.out
#$ -e /u/scratch/e/eewade/logs/$JOB_NAME.$TASK_ID.err
#$ -t 1-110 #572 (26*22)
#$ -l h_vmem=20G
#$ -pe share 1

. /u/local/Modules/default/init/modules.sh
module load apptainer
export R_LIBS_USER=$HOME/R/APPTAINER/h2-rstudio_4.1.0

PAIRFILE=~/project-awbigham/data/working-data/202601/filtered_populationpairs.tsv
NCHR=22

TASK_ID=$SGE_TASK_ID
PAIR_INDEX=$(( (TASK_ID - 1) / NCHR + 1 ))
CHR=$(( (TASK_ID - 1) % NCHR + 1 ))

read P1 P2 P3 < <(sed -n "${PAIR_INDEX}p" $PAIRFILE)

echo "Processing P1=$P1 P2=$P2 P3=$P3 | chr=$CHR on $(hostname)"

/usr/bin/time -v apptainer exec $H2_CONTAINER_LOC/h2-rstudio_4.1.0.sif \
  R CMD BATCH --no-save --no-restore \
  "--args -c $CHR --pop1 $P1 --pop2 $P2 --pop3 $P3" \
  ~/project-awbigham/daily/202601/PBS_FST_forvoight1kg.R \
  /u/scratch/e/eewade/logs/pbs_${P1}_${P2}_${P3}_chr${CHR}.$JOB_ID.log

echo "Job finished at: $(date)"

# test logic 
#for t in 1 22 23 44; do
#  PAIR_INDEX=$(( (t - 1) / 22 + 1 ))
#  CHR=$(( (t - 1) % 22 + 1 ))
#  sed -n "${PAIR_INDEX}p" ~/project-awbigham/data/working-data/202601/populationpairs.tsv | awk "{print t, \$0}"
#done

