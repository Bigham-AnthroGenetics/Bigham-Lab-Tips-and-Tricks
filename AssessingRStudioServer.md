# Using RStudio Server on Hoffman2
#### - Emma Wade

## Intro
I like to use RStudio Server on Hoffman2, so I can interactively make figures and write RMarkdown and such using the Hoffman2 resources. I describe how I do it below, but it is mostly pulled from https://www.hoffman2.idre.ucla.edu/Using-H2/Software/Software.html#rstudio-server plus my additions of using *tmux*. 

## Logging in 
First, I login to a certain login node. I picked 1 arbitarily just be able to know which one you chose. Why I do this will make sense in a second. 

```{bash}
ssh eewade@login1.hoffman2.idre.ucla.edu
```

Now create a new *tmux* session and name it rstudio (but it can be anything).

```{bash}
tmux new -s rstudio
```

Tmux is a terminal multiplexor. It will let us come back to our work in this terminal later. It's especially useful for RStudio server because if our terminal session is killed RStudio keeps running. However, using the same login node every time is important because our tmux session is linked to our login node. If we get connected to say loginnode3 next time, we'll have lost our work or more pertinent to RStudioServer won't be able to find our username and password again. 

Okay now let's create a new file to store the Rstudio server info. I created a file in my home directory (I know bad practice but it's small) called *start_rstudio_apptainer* with this information: 

```{bash}
# get an interactive job
qrsh -l h_data=10G,h_rt=6:00:00  
# Create small tmp directories for RStudio to write into
mkdir -pv $SCRATCH/rstudiotmp/var/lib
mkdir -pv $SCRATCH/rstudiotmp/var/run
mkdir -pv $SCRATCH/rstudiotmp/tmp
#Setup apptainer
module load apptainer
## Run rstudio 
apptainer run -B $SCRATCH/rstudiotmp/var/lib:/var/lib/rstudio-server -B $SCRATCH/rstudiotmp/var/run:/var/run/rstudio-server -B $SCRATCH/rstudiotmp/tmp:/tmp $H2_CONTAINER_LOC/h2-rstudio_4.1.0.sif
## 

```

We won't execute this file directly. Instead I save the file here for easy access and copy and paste the contents into the terminal when I want to run RStudioServer. Let's do that now. 

Okay after waiting a bit after our interactive session and the commands run. 

You'll have something like this: 

```
Open a SSH tunnel on your local computer by running:
ssh -N -L 8787:n7454:8787 eewade@hoffman2.idre.ucla.edu

Then open your web browser to http://localhost:8787

Your Rstudio USERNAME is: eewade
Your Rstudio PASSWORD is: trmAeXmFIf
Please run [CTRL-C] on this process to exit Rstudio
```
First run this line ssh -N -L 8787:n7454:8787 eewade@hoffman2.idre.ucla.edu on your local terminal ** not on Hoffman **

Then you'll simply copy and paste the http:// bit into your web browser, login, and viola! 

Now let's exit our tmux session, so it keeps running in the background by typing control b and control d. 

To get back to the tmux session, type: 

```
tmux a -t rstudio
```


