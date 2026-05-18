# 03-cs3100-pop-lec-03-setting-up-the-notebooks

**CS3100 POP - Lec 03 - Setting up the notebooks**  
id: `t34uLXhFxs8`  
duration: 3343s  

![slides/scene_0001.png](slides/scene_0001.png)
_t = 0.0s -- 51.3s_

started setting up the notebook and few of you had issues and this was sorted out. So I'm hoping that others will also soon set it up because what we are going to do in this course is all of your lectures are delivered through the notebook. So I can print the PDF and upload the PDF of the lectures but that's not really going to help you understand the concepts you really have to like put up the notebook and interactively explore the notebook right. I'm going to start presenting and I will try to...

---

![slides/scene_0002.png](slides/scene_0002.png)
_t = 51.3s -- 102.5s_

I think you should be able to see my screen. Okay so the first thing I want you to look at is the actual website. Alright so please go through what is on the website first because my recommendation is that there are lots of information in there which you might or might not have had a chance to look. So have a look. In particular there is a slack channel which is listed here right to join the slack channel because that is where I'm usually hanging out right.

---

![slides/scene_0003.png](slides/scene_0003.png)
_t = 102.5s -- 153.8s_

So I'm looking at the slack channel and there are a bunch of people here. How many people are here? Some 30 odd people are here now. Sorry 48 people are here now. So which means that 30 20 odd people are missing right. So I highly recommend if you are not there do join the slack channel. Okay so the reason is that slack is generally better for interactively asking questions and getting it resolved rather than Moodle. Moodle is quite it's not great for asking programming questions. There are a bunch of things that you can do in slack and I also usually use slack for work. So I am there right. So one recommendation that I would

---

![slides/scene_0004.png](slides/scene_0004.png)
_t = 153.8s -- 205.0s_

have is don't DM me all the questions right. Don't send me a direct message. If the question is not of personal nature right. If you have questions regarding say some syntax or some code that you don't understand just post it under the hash general or create another channel for OCaml help. So do post it there right so that other your friends and classmates can also sort of benefit from the conversation. I mean you have lots of interesting questions right. So if the conversation is interesting perhaps the others will also be useful. So one thing I should mention is there is a channel called notebook setup right

---

![slides/scene_0005.png](slides/scene_0005.png)
_t = 205.0s -- 256.3s_

and this channel is really meant for you to get the notebooks your notebook setup. We've been answering a bunch of questions and there have been a few conversations here and my TAs are also on this channel right. So if I am not responding they would respond. So I highly recommend the rest of the people who have not joined to join slack ask questions right and and then make sure you're set up right. If you are not set up and you're saying I don't have the setup so I can't submit an assignment I'm not going to be able to help you because I mean I've been mentioning it in every class so far and you will also learn a bunch of tools right. So which which are the tools that you are definitely going to use if you end up working in a company or doing research

---

![slides/scene_0006.png](slides/scene_0006.png)
_t = 256.3s -- 307.5s_

right. So think of this as a good excuse to learn some of these tools. We don't have a course that sort of teaches you these sort of tools but I don't think this would work as a good course right. So having a having an interactive experience going through this and using these tools in practice sort of helps you get familiar with a lot of concepts that are going on here right. Okay so yeah so one thing I should say is this whole course website is also just part of this kit. So all of the stuff for the website is also here. I basically want you to focus on these four commands right and there are and there are two

---

![slides/scene_0007.png](slides/scene_0007.png)
_t = 307.5s -- 358.8s_

tools that we are using here. First one is git and the second one is docker to just give a one-line intro to both of these tools. It is a distributed version control system right. So what this means is it's a way of storing your software artifact and developing your software artifact locally but also collaborating with others might be on the internet right. So this is a really good system. I mean this is like the de facto system today right. If you want to do any sort of programming, any thing that you want to work on I mean I keep my papers in git and all the software repositories are in git. So git is something that you really

---

![slides/scene_0008.png](slides/scene_0008.png)
_t = 358.8s -- 410.0s_

should know right. So it will save you lots of trouble. So I lived in a world before git right. So where you wrote a program you create a version one and then you change it keep version two keep version three version four version five and so on right. So you manually copy the files and keep doing it. This is a really bad practice right. It sort of makes it very clean. So yeah so if you don't know git, you don't need many commands for git in this course. We are not going to ask you to do anything funky but all you need to do I'm going to try to do this from scratch right. So let me get my terminal window here. So

---

![slides/scene_0009.png](slides/scene_0009.png)
_t = 410.0s -- 461.3s_

this is going to be a very opinionated git workflow that I'm going to show. Obviously this is not going to cover everything that git can do. Okay so let me make it bigger. So can someone confirm that you can see my screen? You can. Yes sir we can see. Okay okay good. So yeah you just type git and it will show you some commands right. And so what I this particular command what it does is it just clones this repository right. I'm using GitHub. GitHub is again the de facto place where all of the git repositories are stored. It is free right. So I highly recommend you creating a GitHub account and playing around with

---

![slides/scene_0010.png](slides/scene_0010.png)
_t = 461.3s -- 512.5s_

it for your own courses. Let me just check the messages. Okay so fine. Yeah so okay so let's let's just do this first. I really don't have a plan so I'm thinking on the feet. So let's see what do poke me with questions right. So I might be doing something which is that irrelevant for you but do ask me questions. So what we are going to do first is clone the repository. Okay so git clone sort of copies the entire repository. So what git maintains is git maintains the current state of the repository which is just files right. And it also maintains enough metadata to record the previous history as well. So everything that you had previously is also recorded in git. So this is not magic right. So this is let's

---

![slides/scene_0011.png](slides/scene_0011.png)
_t = 512.5s -- 563.8s_

see. So this is the files that I have but there are hidden files here. So if you do ls-a you will see that there is a .git directory. If you see it you'll see a bunch of things and this is git's metadata that stores all of the previous versions. Okay so I am in this repository. How do I know I am even in the git repository you can just do git status. Let me just shrink it a little bit. Okay so if you do git status what it's telling you is it is giving you the status of the current repository. So it

---

![slides/scene_0012.png](slides/scene_0012.png)
_t = 563.8s -- 615.0s_

says that you are on this concept called a branch. You are on the ghpages branch and your branch is up to date with the origins ghpages. So two concepts here. So git has this notion of remotes. So remote is essentially a location which is not the current working directory right. Which sort of contains the same repository as you. So you can do git remote minus v which is verbose. If you sort of type it you will see that we have a single remote called origin which is where we clone the repository from. So I have it from this location. So this git remote is just a URL to that place and git also has this notion of so you can have multiple remotes right. So if I'm

---

![slides/scene_0013.png](slides/scene_0013.png)
_t = 615.0s -- 666.3s_

saying collaborating with 10 other people I will have say 10 I might not have 10 remotes I might just have like two or three remotes but you can have multiple remotes as many remotes as you want right. So that's the first concept. Remotes are sort of like distributed locations where you can where you have a same copy of the repository. It also has a notion of branches. A branch is think of it as a copy of an efficient copy of your local state right. Branches sort of so if you do git branch it says there is a single branch. What it means is that your local repository has a single version which is ghpages. You can of

---

![slides/scene_0014.png](slides/scene_0014.png)
_t = 666.3s -- 717.5s_

course create new branches. You can I can of course create a new branch. So this is the command for creating a new branch. I'm creating a new branch called work in progress. So now if you do git branch you will see that there are two branches and and the current branch is ghpages right. So you can switch branches by checking out the branch name. Some of these commands are sort of not intuitive right. So but you will get to get in touch with what git does eventually and you won't even think about what you're typing. So I have a branch called work in progress right. So now if I do git branch I see that I am in work in progress branch. So what is the point of having branches right. So let's

---

![slides/scene_0015.png](slides/scene_0015.png)
_t = 717.5s -- 768.8s_

see that I have this readme file right. So let's say I'm adding something here. Let's say this was added on the 8th of August. Okay so I just wrote that line. I committed it. So every git branch also has a saved state and currently working state right. If you do git status I just do git status. So git status says that I've modified this file right. So I have modified my readme file because I added that one particular line and my and this is not part of the same state in a branch right. So git branch also has this notion of commits. So this has not been

---

![slides/scene_0016.png](slides/scene_0016.png)
_t = 768.8s -- 820.0s_

committed yet. So if you are aware of some awareness of databases right. When you run database transactions you sort of commit and here is a similar idea. This is an uncommitted thing. So it just says that I've modified this file. The modifications are sort of still hanging around right. They are not committed yet. The nice thing about git is you can quickly see what you've changed. So there is a command called git diff right. If you type this it says that I've changed this readme file here right. So readme file has been changed and what was the addition? The addition was this one particular line. This is really what I added now and I'm just checking the git branch again. I'm in work in progress. So just like databases where you start saving the state right. It has this notion

---

![slides/scene_0017.png](slides/scene_0017.png)
_t = 820.0s -- 871.3s_

of a commit. Commit is a sequence of commits actually is a branch. So I've made some changes. I want to ensure that the changes are saved. The changes are committed and the way you do that is you do git commit and then you can say whatever file has changed add all of the files. So that is minus a right and you can type a message minus m added a line in readme. Okay so I've done this. If I commit it it says that okay one file changed there were two insertions because I added two lines. So if you do git status now you will see that there is nothing to commit right and the working tree is clean which means that all of the changes

---

![slides/scene_0018.png](slides/scene_0018.png)
_t = 871.3s -- 922.5s_

have been saved. One thing to notice is keep in mind is that all of these changes are local. Okay so I've made this change just in the work in progress branch. If I change to say the gh pages branch. git branch. git checkout gh pages. Right and I look at my readme file. You will see that the line is not here. Right so each branch is like a copy of the entire repo right repository and what this branch allows you to do is to say you have one version of the program that you're working on you want to quickly try out a new feature. So you create a new

---

![slides/scene_0019.png](slides/scene_0019.png)
_t = 922.5s -- 973.8s_

branch you work on the branch the feature will keep developing and then at the end of it you can say okay I'm happy with this feature now you can sort of save this feature into the main branch but what did we see here is the main branch which is the gh pages branch does not have the changes. In fact you can even diff between branches so I am so now I am in gh pages branch right and I'm sort of going to ask what are the changes between my current branch which is the gh pages branch and this work in progress branch. So we know that the changes are these two line additions right if you do git diff work in progress and sort of tells you the other way right so what it says is how do I get

---

![slides/scene_0020.png](slides/scene_0020.png)
_t = 973.8s -- 1025.0s_

from work in progress branch to gh pages branch which is oh you just delete these two lines and you will get to the state that is available in gh pages branch right okay so this is a very quick intro to git I don't think you will even need to use all of this information okay so one thing I should say is why bother creating branches if you cannot merge the branches together so of course I have I have my master branches which is sort of the public version gh pages right and I have this other version which is work in progress so what I'll try to do is to merge the changes from the work in progress branch into gh pages branch so the way to do that is this command called git merge so you can

---

![slides/scene_0021.png](slides/scene_0021.png)
_t = 1025.0s -- 1076.3s_

merge branches so you take the work in what it's saying is I am currently in get a GitHub pages gh pages branch right so it's status gives me sorry git branch gives me a gh pages so I am instructing git to say give me all the changes from work in progress branch and merge it into gh pages branch so I do git merge work in progress right now if you see that it says two lines have been added right and if you look at this one you will see that these two lines have been merged together okay now if I do git status so what this tells me is I want a branch GitHub gh pages my local branch right is ahead of the remote branch by

---

![slides/scene_0022.png](slides/scene_0022.png)
_t = 1076.3s -- 1127.5s_

one commit the commit is this addition right so I am one step ahead I have some local changes which is ahead of the remote changes and you can obviously push this changes right so you can so one thing you want to do is to say I have my local changes I want to make sure that the changes are saved in GitHub made available publicly on GitHub so you do git push it's so if you do git push yeah it needs it asks for a username I've not learned it with if you do git push it will go there right so take my word for it I can try to yeah I don't think it's

---

![slides/scene_0023.png](slides/scene_0023.png)
_t = 1127.5s -- 1178.8s_

that useful so anyway so you can do git push what will happen is your changes will appear here why don't we do that if some if no one is asking questions I might just do that so let me clone the repository again so let me move this to something else so I'm cloning this again right I'm running a fresh copy so you can have multiple clones each clone is just a repository right so I actually have two clones here this is the one that we were working on just now and this is the new

---

![slides/scene_0024.png](slides/scene_0024.png)
_t = 1178.8s -- 1230.0s_

one and so let me add a change here so let me do hello world so I added hello world if you do git status actually I'm using something which I haven't showed you so you can just do git status it tells me that this read me file has and then now I can do git push so what is happening now is my local commits are being pushed to github and this will be immediately afflicted right so hello world is here so why am I telling you this workflow this workflow is useful

---

![slides/scene_0025.png](slides/scene_0025.png)
_t = 1230.0s -- 1281.3s_

for you because when you are working on assignments right so make sure that you integrate git into your workflow because you can avoid all of the problems with losing code and not submitting and all of these silly things right all of those will be a non-issue for you and of course you can look at all of the history here so if you look at this one you'll see that yeah so this is my entire history it also allows you to go back to previous version I'm not showing all of that you can read upon it basically if you make a mistake right git keeps all of the history around in an efficient way so that you can go back to a previous version if you wanted to so that's the benefit of git and the

---

![slides/scene_0026.png](slides/scene_0026.png)
_t = 1281.3s -- 1332.5s_

reason why we are using git is a matter of convenience right so in this course I am using git because I keep developing the course I add new stuffs and so on I want a safe way to ensure that my commits are version control so that if I make a mistake I can go back to a previous version okay okay so that is git what else do we do so okay so let's do docker now right so we sort of looked at what git clone does so what is docker? Docker is just a easy way of it's like a virtual machine right to a first approximation docker is like a virtual

---

![slides/scene_0027.png](slides/scene_0027.png)
_t = 1332.5s -- 1383.8s_

machine but docker allows you to allows you to it's a better way to it's a virtual machine so I won't expand beyond this but that's the idea right it's it's like a really easy way to manage and deploy virtual machines when you want to deploy hundreds of virtual machines you don't want each of them to run virtual box right so docker gives you a easy way to sort of start all of this in the cloud and work work there docker is also easy because for a developer it gives you a command line interface right so what what do you mean by command line interface we can just run this command and get a local virtual

---

![slides/scene_0028.png](slides/scene_0028.png)
_t = 1383.8s -- 1435.0s_

machine quickly running okay so so let's do this thing right yeah okay so I am on a I have a MacBook right so this is this is running MacBook and let me CD to lectures which is what I mentioned here and I'm going to run this command so there are there are a bunch of things in this command right what I'm saying is Oh Docker which is a service which is it which is running here right I have a thing called Docker desktop which is an app for Mac which is running here yeah so actually yeah so one thing I should mention is Docker desktop is and Docker

---

![slides/scene_0029.png](slides/scene_0029.png)
_t = 1435.0s -- 1486.3s_

for Windows is our two applications where oCaml is extensively used internally so this this might not be obvious here but if you look at the license agreements I think I can find oops hey so you can have a look at the license agreement there will be a bunch of oCaml licenses in there so okay so what do we want to show I want to show that how Docker works so here is here is another window go here CD to lectures okay so I am in the lectures directory

---

![slides/scene_0030.png](slides/scene_0030.png)
_t = 1486.3s -- 1537.5s_

now I this is my command right what is the command saying Docker run this Docker image right so Docker is also sort of a nice way to manage multiple images together so Docker has this notion of two notions right Docker has this notion of images which are sort of like virtual machines that have been suspended right so suspended virtual machines and containers which are instances of that particular virtual machine so you can have say one virtual machine one virtual machine image right which can be ten instances of which can be started so there is a notion of image which is like a passive thing and

---

![slides/scene_0031.png](slides/scene_0031.png)
_t = 1537.5s -- 1588.8s_

there is a notion of containers which is an active thing so given a single image you can have multiple containers running so in order to look at what images you have you can do Docker images actually on this machine I only have one image right and that's the image name the tag is latest and it was created nine days ago and it is occupying four point one seven gigabytes of disk space right and Docker containers can be looked up by this Docker ps command so ps is the command that you use in Linux right you can sort of look at what process are running similarly Docker ps tells you what containers are running right I only have one container running this is the container that I am using for the course

---

![slides/scene_0032.png](slides/scene_0032.png)
_t = 1588.8s -- 1640.0s_

so it's running in it's it's running here right so that's the container that I see the container has an ID right and it tells you which image it is running currently what command is running right and how long has it been running and there are two things here which is probably useful to note so it says something about port and there is a name right so you can the port is sort of and that comes back to this command again so when I type this command I am running this image to create a new container right to create a live instance of this image right and I have two commands here so I say p 8 8 8 8 8 8

---

![slides/scene_0033.png](slides/scene_0033.png)
_t = 1640.0s -- 1691.3s_

so what this says is when you run this container you take the port 8 8 8 8 8 from the container and map it to the port 8 8 8 8 on the host machine which is my MacBook right essentially what it means is if I send a packet or the weight on a packet on my 8 8 8 8 then I will get the packets that are sent or received by whatever process is running inside the container right so we map we map this port from the host to the container and the reason why we do that is we are going to run Jupiter instance inside the container and we want to use our browser on our host to access the notebook right this is a command line only interface

---

![slides/scene_0034.png](slides/scene_0034.png)
_t = 1691.3s -- 1742.5s_

dog that is usually command line only it doesn't give you a UI so that's why we are mapping this port and the second thing that we are doing is mapping volumes right what does that mean it means that we are mapping a local directory which is my present working directory to the directory called slash lectures within the container okay so whatever changes I do on the host or on the container will be reflected why do we do this I want my local copy the current copy on my host machine my MacBook Pro will be reflected in the container the container is open to 2004 right so it gets reflected there there's a lot of if you sort of think about it and if you are aware of file systems

---

![slides/scene_0035.png](slides/scene_0035.png)
_t = 1742.5s -- 1793.8s_

there is a lot of magic going on here how do you transfer because there are different styles of file systems right the xt4 and Mac has its own file system and there is NFS so you have to sort of translate all of this over there is there's a bunch of very smart operating system things going on in Docker just sort of to kindle your interest right there's a lot of cool systems research here but the high level takeaway is you just map by these folders right so if you look at this folder I have a bunch of files here and if I run this Docker command it's already running so let me terminate the other one so does Docker work on Windows 10 home I don't think it works on Windows 10 home unfortunately so

---

![slides/scene_0036.png](slides/scene_0036.png)
_t = 1793.8s -- 1845.0s_

I have a virtual box image that is available so that our actual box image is here right so it's a bit silly because you are installing virtual box which inside uses Docker but anyway that's the method I would recommend using okay yeah Windows home is here okay I'm just reading the messages on on the chat I if you are enthusiastic go try it out right so I think this is going to be a little bit of fun but if it doesn't work you can always fall back to the virtual disk image right which will box disk image if this sort of stuff

---

![slides/scene_0037.png](slides/scene_0037.png)
_t = 1845.0s -- 1896.3s_

interests you go go wild right so I think this is going to this is going to this is going to give you lots of fun so you will learn a lot of things about opening systems and how things work and so on so try it out anyway so if that doesn't work you can always fall back to this image right okay so let's go back to where we were which is here so the reason why this failed initially is I had another instance running so I'm going to terminate that instance so that this so if I do docker ps now you'll see that nothing is running right the earlier something was running now nothing is running so let me run the

---

![slides/scene_0038.png](slides/scene_0038.png)
_t = 1896.3s -- 1947.5s_

command again so this time it will work right so now I am in inside the container so you can get your name a feeling so it says Linux right and then escape so we are inside the the docker container and in particular if you look at this we have the same folder structure that's been mapped right so which was the same on the host and that's the benefit right so you locally have some changes and we are sort of mapping it there and you can now start jupyter notebook so I'm starting a jupyter notebook and I'm mapping this to zero zero zero zero essentially it maps it to the local host and this gives you

---

![slides/scene_0039.png](slides/scene_0039.png)
_t = 1947.5s -- 1998.8s_

a URL because we've mapped 8 8 8 8 to our host for day day day day this is going to be reflected right so that's the that's the fun to that if you run this you'll see oh yeah how to terminate you can you can press ctrl D internet I I honestly don't know whether oCaml is available on Google pull up I haven't used it I'll be very surprised if it's there available okay so that's my take on it find out I have no idea so okay so anyway so this is running now you can play around with it so the point is if you if you save stuff on it right we are we are in a we are working in a container right so these are ephemeral things so whatever the stuff that you do inside the

---

![slides/scene_0040.png](slides/scene_0040.png)
_t = 1998.8s -- 2050.0s_

container is meant to be temporary right so they will go away after the container is terminated unlike a virtual machine which sort of saves its state all the time so if you create a file in any directory that is not mapped to the home directory so we are mapping exactly one directory right we are having present working directory to slash lectures if I sort of create any other file in the container in the directory that is not mapped to the host the files will be gone when you terminate the containers okay so that's the key thing and we are doing this mapping precisely because I want to show you something I will write new lectures here but the changes will be saved in my host

---

![slides/scene_0041.png](slides/scene_0041.png)
_t = 2050.0s -- 2101.3s_

directory for example I'll just do one simple thing right so let me say starting up so let me change this so if I run this it's in turn right let me change this to one point so float out of float I'll save this okay so the thing to take away here is let me I am still in this lectures directory right and if I do git status which directory am I in

---

![slides/scene_0042.png](slides/scene_0042.png)
_t = 2101.3s -- 2152.6s_

we close this one okay so let me shut this down right this doesn't have git right so but if I terminate the container and then say git status you can see that the container is gone right talk appears no content is running but the file changes have been saved locally so git status you know tells me that this changed and if I do git this you can sort of see that I changed the code right so some execution count has changed the type that we saw has changed right and I had something earlier that is also changed so this is I mean this

---

![slides/scene_0043.png](slides/scene_0043.png)
_t = 2152.6s -- 2203.8s_

is the benefit of doing this code mapping right so sorry the volume mapping so that if you work on your own if you work on your own notebook locally right you edit your solution the changes will be saved locally and then you can commit it and do whatever you want with git again so if we try try out things and save in the container will they go away when you do git pull no they won't right so they won't overwrite only if you have conflicting changes with you I mean even then git will complain there are some conflicting changes and they won't it won't be overwritten so don't worry about that I think it will tell you right if you force it to say pull me still it will bad things can happen but

---

![slides/scene_0044.png](slides/scene_0044.png)
_t = 2203.8s -- 2255.1s_

you can you can always git won't overwrite anything right it is very very careful about overwriting okay so what else do you have see the I don't know about this collab ocamel thing so but but the thing I want you to recognize is this we will be using jupyter notebooks for the assignments as well so even if collab Google collab has ocamel support we are going to use jupyter notebooks the reason is that I can I can actually do auto grading because there is a module where you can do auto grading in jupyter notebooks called nbgrader and that is what I'm using internally it has it is very it is very useful so you sort of

---

![slides/scene_0045.png](slides/scene_0045.png)
_t = 2255.1s -- 2306.3s_

have like a box where you fill in the code sks is right underneath and you just submit me the notebooks and I can run everything in us everything in the same workflow so so yeah so you do need to work on jupyter notebooks for this semester at least okay so what do we have so we have changed something so what I'm going to do is I am on gh pages so I'm going to commit these changes some changes I'm going to push this right whatever changes I push will be reflected so there were some changes upstream which have not been downloaded so I do git pull sorry I went too fast there the point is I did git pull which

---

![slides/scene_0046.png](slides/scene_0046.png)
_t = 2306.3s -- 2357.6s_

got just like pushes taking local changes and sending it to the remote repository you can pull changes from the remote repository to your local repository actually git pull is some command that you will use all the time right so I have only what five lectures put up so far but if you want to get the latest lectures you just go to your loan of the repository and then do a git pull you'll get all of the local all of the new changes and that is how you're going to get new lectures and also assignments right what I will do for the assignments is I will add the assignments to I think I had a I'll just add a folder called assignments and then keep adding assignments there in order to get the

---

![slides/scene_0047.png](slides/scene_0047.png)
_t = 2357.6s -- 2408.8s_

assignments you can just do a git pull and you will have a local copy of the assignments you just work on it and for submission you take that single file right and upload it to model I will tell you how that works when the time comes but that is how you'll be using I do not know whether you will be pushing at all but you will certainly be pulling right pull is certainly something that you will be doing a lot in order to get the latest updates okay so my branch is ahead of this thing by two updates okay so let me go back and delete this thing so that

---

![slides/scene_0048.png](slides/scene_0048.png)
_t = 2408.8s -- 2460.1s_

have developed this habit of having useful commit messages right when you come back and you have to go back to your old old code commit messages help you a lot right so and then git push and the changes will be there okay so I think we have like 10 minutes so I'll sort of like not do anything more because I think I've covered most of the things here so if you have questions now is your time to ask questions sir yeah sir I when I was running the docker container and I just closed it without exiting like and then now now I don't

---

![slides/scene_0049.png](slides/scene_0049.png)
_t = 2460.1s -- 2511.3s_

know how to terminate that okay so so if you close it can you do docker ps yeah if I do docker ps there's one thing running yeah so you can do docker kill again there is always help right so docker kill signal so docker kill sick kill in operating systems is 9 right and you just give the name of the container so the last thing will be some stupid name right some jumpy rabbit or something like that so you just copy paste that and it will kill the container okay thank you yes so good interruption I think this is a good question you will come across is often so the port will be bound you don't know where that other thing is so you can just kill it okay so I'm getting an

---

![slides/scene_0050.png](slides/scene_0050.png)
_t = 2511.3s -- 2562.6s_

error about not being able to connect to docker daemon is docker running so typically your thing should be running if you are on Mac you should have docker stop running I think on Linux there is something similar which operating system are you on Venkata whole then it's okay so yeah I'm just going to Google it because I don't know so yeah so you can so you need to do

---

![slides/scene_0051.png](slides/scene_0051.png)
_t = 2562.6s -- 2613.8s_

this right I think there is a pseudo service Docker status that will tell you whether the Docker daemon is running or not there are two things you can try one and you need to start the Docker daemon okay try that so if you have other questions which you have not resolved my recommendation is go here to slack something called notebook setup who ask questions there okay so next question so how do we set up OCaml kernel in Jupyter notebook are you trying to set it up from scratch yes okay so I have a clean installation of Jupyter notebooks okay so one thing

---

![slides/scene_0052.png](slides/scene_0052.png)
_t = 2613.8s -- 2665.1s_

with the Docker that I forgot to mention is it has a very nice format for creating the images which is just a bunch of commands so if you go here in the repo there is a folder called underscore Docker there is a file called Docker file okay that is going to show you how it is actually set up so so you've done installation of Jupyter right actually you need to do all these commands right you need to do a bunch of these commands is that is that clear I can point you to this repository so OCaml Jupyter kernel you just search for it this is the kernel that I'm using

---

![slides/scene_0053.png](slides/scene_0053.png)
_t = 2665.1s -- 2716.3s_

sir where am I supposed to run this commands so you need to do this you need to sorry where are you supposed to run this you just if you are setting it up on Linux you just run it on Linux right on your host this is not Docker right so actually so if you if you sort of look at all of this right this is the entire set of commands that I run on a fresh fresh Linux Ubuntu with something else right but basically that's that's that these are the list of commands so if you have any question about how I am setting this up you can have a look at this okay so the OCaml kernel itself is here in this

---

![slides/scene_0054.png](slides/scene_0054.png)
_t = 2716.3s -- 2767.6s_

OCaml Jupyter kernel and that has instructions for creating the Jupyter kernel right and then installing the Jupyter kernel okay so next question naman sir I tried this so in this particular one when I was executing the second instruction OCaml installed Jupyter it was saying that there is no switch set up oh I think I believe that so this is because OCaml has a package manager okay so you need to I'll just point you to this thing because I don't want to confuse all of the other people so the thing that you need to do is this one so I think you've installed how did you install OCaml did you install OCaml

---

![slides/scene_0055.png](slides/scene_0055.png)
_t = 2767.6s -- 2818.8s_

I installed OCaml using distribution this distribution okay okay so my recommendation is install it using this command so if you just Google for the OCaml setup right so it will get you to install OCaml link and there there is this single command called curl and install so this will get you the right installation okay so this will install the latest version which is 410 compiler so the version of OCaml that is in the that is distributed with the Linux distributions are quite old okay so this is how you set up OCaml

---

![slides/scene_0056.png](slides/scene_0056.png)
_t = 2818.8s -- 2870.1s_

try it out again if you have any other questions we can always sort it out on the on the chat I'll usually hang around there right so I'm there now so we can continue there okay so I have I have two minutes so keep the questions going so if we don't have time then we will continue there okay more questions

---

![slides/scene_0057.png](slides/scene_0057.png)
_t = 2870.1s -- 2921.3s_

all of that hopefully this will sort of inspire you there is a lot of if you are interested in systems there is a lot of cool stuff that is going on with Git and Docker and all of that yeah so it's it's these are sort of incredible pieces of software that have been made to work and all of this is open source right you can go and read Git source code today

---

![slides/scene_0058.png](slides/scene_0058.png)
_t = 2921.3s -- 2972.6s_

and the best kitbook I found is there is a book called Gitbook so yeah this is freely available so this tells you everything and anything and everything about Git but this might be a bit too deep so Stack Overflow is what I do all the time Git is one of this magical thing it is very powerful but it's also a little bit confusing for the beginners but if you have any questions about Git or Docker or any of these right please use the Slack channel right so either I will answer or my TS will answer I'll be happy to answer anything and everything right so it doesn't need to be particularly with this if I think something is something is not going to be useful I'll just tell you right so but don't hesitate for asking questions

---

![slides/scene_0059.png](slides/scene_0059.png)
_t = 2972.6s -- 3023.8s_

only if you ask questions will you inspire me otherwise I'll just tell you something and canned responses and just walk away so we are one minute past time so I highly recommend you to try this out over the weekend and early next week I will have an assignment zero okay so what I will do is I'll just have like a Hello World program and you just need to write Hello World and submit and that is sort of a forcing function to get all of you to submit that assignment maybe I'll give that one percent mark to that assignment right so this one percent for class participation so make sure you submit it I'll just set a deadline which is comfortable for all of us you just literally have to write one line right so I'll tell you what the line is and go through the process of setting this up and submitting

---

![slides/scene_0060.png](slides/scene_0060.png)
_t = 3023.8s -- 3075.1s_

okay so I'll stop there thanks very much bye bye you

---

![slides/scene_0061.png](slides/scene_0061.png)
_t = 3075.1s -- 3126.3s_

you

---

![slides/scene_0062.png](slides/scene_0062.png)
_t = 3126.3s -- 3177.6s_

you you

---

![slides/scene_0063.png](slides/scene_0063.png)
_t = 3177.6s -- 3228.8s_

you you

---

![slides/scene_0064.png](slides/scene_0064.png)
_t = 3228.8s -- 3280.1s_

you

---

![slides/scene_0065.png](slides/scene_0065.png)
_t = 3280.1s -- 3331.3s_

you you you

---

![slides/scene_0066.png](slides/scene_0066.png)
_t = 3331.3s -- 3331.3s_

_(silence)_

---
