# Hoffman2 Toy Example
#### - Emma Wade

# Prep 

### Login to hoffman
```{bash}
ssh [yourusername]@login1.hoffman2.idre.ucla.edu
```

### Move out of a login node and onto a compute node by starting an interactive session
```{bash}
qrsh -l h_data=10G,h_rt=6:00:00  

```

### Make a new directory to keep our data in, we don't want to keep stuff saved on our home directory and move to it
```{bash}
cd project-awbigham
mkdir labmeeting427
cd labmeeting427

# if you don't have access to Abby's folders yet save your memory in scratch for today (it will delete after a couple of weeks)
cd $SCRATCH
mkdir labmeeting427
cd labmeeting427

```

# Download data
## Grab Chromosome 22 of 1000Genomes Phase 3 High Coverage Processed VCFs
One way to access 1000Genomes data is by navigating to their FTP website: https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/ I would recommend navigating the website and seeing if you can find location of this data yourself (HINT: the directory path is in the URL). "wget" (kind of like website get) pulls a specified file from the internet and gives it to you, so we'll use it to pull the data from online and into hoffman.

``` {bash}
wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20220422_3202_phased_SNV_INDEL_SV/1kGP_high_coverage_Illumina.chr22.filtered.SNV_INDEL_SV_phased_panel.vcf.gz

wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20220422_3202_phased_SNV_INDEL_SV/1kGP_high_coverage_Illumina.chr22.filtered.SNV_INDEL_SV_phased_panel.vcf.gz.tbi # this is an index file which makes navigating the vcf easier, some software requires it
```

## Take a peak at our data 
Here were are going to use the "zless" command to take a peak at our 1kg data. To navigate down, press the space bar. To search something inside the file you can hit the "/" key and then type what you want to look for. Try searching for the SNP "22:10519276:G:C". Hit control c to get out of the search bar and then hit q to get out of the "zless" window.

NOTE: this is a really long file name, instead of typing out the whole thing try typing "1kGP" then press tab and it will outcomplete 

ANOTHER NOTE: "zless" is the gz compatible version of "less", so if you aren't looking at files with the .gz suffix use "less" instead. "less" has some extra capabilities. I particularly like "less +G" which navigates to the end of file (really good if I'm trying to find errors in log files!)

``` {bash}
zless 1kGP_high_coverage_Illumina.chr22.filtered.SNV_INDEL_SV_phased_panel.vcf.gz

```

# Make Plink files
We may want to convert a VCF into a PLINK formatted file to do QC, PCA, ... so we're going to do that. This can take some time with really
large files, so we're going to submit it to the scheduler.

## Job submission script
I've written a starting point for our job submission script below. You'll need to edit [[[[[[add directory]]]]] to be the path in which you saved your files. You can find out the directory by typing "pwd" (print working directory). You have a couple options for how to edit and save the file. 1) You could edit in on a text editor on your local computer and then move it over using Cyberduck. 2) You could edit it in a text editor on your local computer and then copy and paste it onto Hoffman using "nano" (type nano submit_job.sh, copy and paste the text, then save by typing control x and then y to save) 3) You could use RStudioServer instructions for that here https://github.com/Bigham-AnthroGenetics/Bigham-Lab-Tips-and-Tricks/blob/main/AccessingRStudioServer.md

NOTE If you want an extra challenge, I recommend creating a "log" directory in SCRATCH to put all your log files in; however, you can't use  "$SCRATCH" in the submission header so you'll need to find out the full path to your scratch directory. Use "mkdir $SCRATCH/logs" to create the log directory and then run "echo $SCRATCH" to find out what "SCRATCH" stands for. For example, my log files are saved in "/u/scratch/e/eewade/logs" so my -o line would be 

```{bash}
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o [[[[[[add directory]]]]]/joblog.$JOB_ID
#$ -j y
## Edit the line below as needed:
#$ -l h_rt=6:00:00,h_data=5G
## Modify the parallel environment
## and the number of cores as needed:
#$ -pe shared 1
# Email address to notify
#$ -M $USER@mail
# Notify when
#$ -m bea

# echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "

# load the job environment:
. /u/local/Modules/default/init/modules.sh
## Edit the line below as needed:
module load plink

cd [[[[[[add directory]]]]]]

plink --vcf 1kGP_high_coverage_Illumina.chr22.filtered.SNV_INDEL_SV_phased_panel.vcf.gz \
  --keep-allele-order \
  --make-bed \
  --out chr22


# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "
```

## Submit job
Once you've saved your submission, you'll run "qsub" to submit your job
```{bash}
qsub submit_job.sh # or replace with the name of your script 

```

## Check status of job
We can type "myjobs" to check the status of our job. We should see "QRLOGIN" for our interactive session 
and hopefully also "tutorialplink" for this new job. It might be in state "qw" which means
we are waiting our turn. "r" means running. If we no longer see it, it has finished. 

## Look at log file
Let's take a look at our log file. We'll use "less" this time. Type "less [[[[[[fill in directory if you specified somewhere other an current directory]]]]]]joblog". Use the space bar to navigate the log file. How many variants pass filters and QC? 

## Look at output
Let's look at what files plink made
```{bash}
ls 
```
You should see chr22.bim chr22.bed chr22.fam chr22.log chr22.nosex. Play around with looking at these files. 




