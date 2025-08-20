
# Using Hoffman2
#### - Emma Wade

## About 
Hi! This is a brief tutorial of the basics of using Hoffman2 to access the lab's cluster resources. More in depth documentation is available here: https://www.hoffman2.idre.ucla.edu/

## Logging in and Important Directories
Once you have requested and received an account (https://www.hoffman2.idre.ucla.edu/Accounts/Accounts.html#requesting-an-account), you can log in on your terminal using: 

```{bash}
ssh login_id@hoffman2.idre.ucla.edu
```

If you have a Windows machine, you'll need to install MobaXTerm or PuTTY. Hoffman2's documentation has more info. 

After entering your password, welcome! You're in!

The first place you'll be directed to is your home directory. 

Let's look at the path of this directory using: 
```{bash}
pwd .
```
*Pwd means print working directory and the . means "give me the directory I'm in please"*

The output should look something like */u/home/e/eewade*

We can also look at what this directory contains using: 
```{bash}
ls . 
```
*I remember this one by thinking ls looks like "list"*

Hopefully you'll see a directory called *"project-awbigham"* and not much else. (If you don't see this, you haven't been added to the team's resources yet. Submit a ticket to IDRE (https://support.idre.ucla.edu) and/or ask Abby)

** Important: do not store things in your home directory! You have limited memory in your home directory, so you'll fill it up fast**

Instead, let's move into your folder on the lab's space and get to work: 
```{bash}
cd project-awbigham
```
*cd means change directory and project-awbigham is the directory we want to move into*

There is another directory that is important to know: scratch. You can access this with the variable $SCRATCH

```{bash}
cd $SCRATCH
```

This directory gives you 1 TB of space --- with a catch. After two weeks, files stored in SCRATCH will be cleared. It's best practice to store temporary files like logs, intermediate files, etc. in SCRATCH and important scripts in project-awbigham. Let's move back to project-awbigham for now: 

```{bash}
cd $SCRATCH
```

## Entering Interactive Session
Okay! We're back inside of *project-awbigham* and ready to work -- almost. Notice the text between the brackets before your cursor. Mine says *eewade@login1 project-awbigham*. Login1 means I'm on login node 1. These login nodes are used by everyone at the university to **login**. These nodes have limited resources and should not be used for working (or you'll slow down Hoffman and make everyone unhappy). Let's move off the login node by starting an interactive session: 

```{bash}
qrsh
```

This will start an interactive session with default resources of 1 GB memory with 2 hours of access. For our purpose this will do, but you may want an interactive session with more memory or space. Here's an example: 

```{bash}
qrsh -l h_data=10G,h_rt=5:00:00
```
But there's a lot of things you can change. Find more info here: https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing.html#requesting-interactive-sessions

Okay we're on an interactive node! You'll notice we no longer have login between the brackets. 

## Submitting a Job
Now that we're in interactive session let's work on submitting a job to the scheduler. 

First, let's create a script. There's lots of ways to do this but for now enter the *nano* text editor. 

```{bash}
nano submissionscript.sh
```

This will enter *nano*, a simple text editor software. Copy and paste the below into the text editor: 

```{bash}
#### submit_job.sh START ####
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o joblog.$JOB_ID
#$ -j y
## Edit the line below as needed:
#$ -l h_rt=1:00:00,h_data=1G
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
module load gcc/4.9.3

## substitute the command to run your code
## in the two lines below:
echo '/usr/bin/time -v hostname'
/usr/bin/time -v hostname

echo 'Hello world!'

# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "
#### submit_job.sh STOP ####

```
To save and exit from *nano*, press Control-x and type Y then enter. 

This is an example script you can edit for your needs. Hoffman2 Documentation walks through the pieces of this script (read more here: https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing.html#submitting-batch-jobs), but for now know that the pieces that start with #$ are the preamble and tell the scheduler what we want to do. 

Before submitting to the scheduler, let's glance at our file to see if it saved correctly: 

```{bash}
less submissionscript.sh
```

*Less* will give you a preview of your file. You can use the arrow keys to go up or down. If it looks good, we can press *q* to exit *less*. 

Okay let's submit! 

```{bash}
qsub submissionscript.sh
```

This will send our job to the scheduler to be submitted. 

We can check the status of our job with 
```{bash}
myjobs
```

This should be a quick job, so we might not see it with *myjobs*. 

If you wanted to cancel it, you can run 

```{bash}
qdel (jobid)
```

Okay after it's finished, let's see what is in our directory: 

```{bash}
ls 
```

You should see a file called joblog.[jobid]. Let's look at it: 

```
less joblog.10246288
```
*The number after joblog will be different for you*

Hopefully you have some stuff in your file and Hello World! 

## Misc Tips
Here are some random commands I often reach back to. 


### Preview End of File
Helpful for long log files
```{bash}
less -G [file]
```

### Look at Available Memory
```{bash}
myquota #hoffman shortcut, for certain directories
du -sh #more general, but slow
```

### Change Permissions
```{bash}
chmod -R 777 [directory or file]
```

### Move Files between local machine and Hoffman

#### Locally to Hoffman: 
```{bash}
scp -r [path of local file or directory] eewade@hoffman2.idre.ucla.edu:[path on hoffman]
```

#### Hoffman to Locally
```{bash}
scp -r eewade@hoffman2.idre.ucla.edu:[path on hoffman] [path of local file or directory] 
```

#### Load Modules
```
module avail
module load [a module]
```