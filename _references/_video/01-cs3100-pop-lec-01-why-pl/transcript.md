# 01-cs3100-pop-lec-01-why-pl

**CS3100 POP - Lec 01 - Why PL?**  
id: `9R8Oim7YU20`  
duration: 3061s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

It's not the same being in campus is it Okay, so I can see the issue with this right so It's unclear who the question is there I could do well. We'll get through this and we are all learning so there might be Some issues with Interaction, but hopefully we will all learn right my three-year-old is doing online classes In the next room, so if he can do it we can do it too

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

So let's get started without much further ado. I'll start presenting Okay, can you see my screen

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

Okay, wonderful Yes, okay superb so welcome to this class I'll make it full screen I Will also switch back and forth to admit more people But I am hoping that this will settle down in a few minutes so you

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

Interpol screen, okay, so this is your CS 3 1 double 0 paradigms of programming And we are doing this all in addition due to this code nonsense. Hopefully This will come to an end pretty soon and we can meet face-to-face So I am your instructor. I am Casey's sibaram a Krishna. I have a very long name so I go by Casey So you can just call me Casey right so no need to use my full name

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

Nobody uses my full name if you see me on the street and call me silver amakrishnan. I won't turn right so I go by Casey So yeah, so with that let's dive right in so Let's consider for fun this hypothetical Single instruction programming language right this is a programming language. You can also think about this as a Architecture which only has a single instruction right it has this sub value queue instruction right which takes three arguments and

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

ABC and semantics the meaning of this instruction is that When you run this instruction what it does is we consider a and B to be some pointers Right pointers to say integers What it does is it stores into? B the difference between B and a right the value in B and value in a

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

If B is the value in B is now less than or equal to zero it branches to C Right I assume you've taken C programming so you can sort of see how this might work Right and this is the only instruction in this programming language Right and it might seem very strange for simplicity will also introduce Another syntactic sugar right so this is not a primitive instruction. We are just going to drop

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

The label C. We'll just take sub value Q a B and ignore C Where the meaning is that we are not branching anywhere. We are just branching to the next instruction Right really you can sort of think about This form as just branch to the next instruction industry so You might wonder right what can we even do with this? single instruction programming language You can try it a lot of programs right so

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

here is a program let's assume that initially the value at location Z is zero and Then you have these three instructions Does anyone want to take a wild guess at what this three instructions might do? What it might try to achieve? any guesses would be totally fine Okay, no guesses so we will just work through it right so this is a very simple language

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

We actually know what this one instruction does so we can see right so initially The value at location Z is zero So first you do sub leq a comma Z Which means that you are doing star Z equals star Z minus star a and we know that because star Z is zero initially now star Z The value is minus of the value at a right the original location a and we do the next instruction

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

Which is Z minus sorry sub leq Z comma B What it does is we just apply the same rule right so it says star B equals star B minus star Z But we know that the value and stars in now is minus Star a right so you replace that here and what you get this star B equals star B plus star a and the last instruction

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

Again apply the same pattern so stars equals star Z minus star Z which gives you zero so initially Star Z the value at location Z was zero now It's zero again right and in the intermediate process B is now The value at B plus value at a in fact what it does to give you a high-level term is it does addition right given to loop memory locations, it's adding the The values in those memory locations in the second location

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

Right so okay, so we can do addition you can also do other programs so here is a program I'm not going to explain What is going to do, but you can see that the meaning of the instruction is so simple you can work it out In fact what it does is it just does assignment so it takes the value at location a and then stores it at The location B you can take my word for it right you can you can work through it and

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

You can see that this is what it does interrupt me if you have questions right so Just ask questions. I'll stop and answer So Why am I introducing this very silly language right there is a very important reason? this one instruction programming language or this Abstract machine is as powerful as every other programming language What do I mean by that it's it's Turing complete you can express any program

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

In this one instruction programming language that you can write in every other programming language, right? So it's it's actually a very powerful notion But if that's the case why do we even study other programming languages? Why do we have other programming languages? What is the reason I mean you can basically Argue that no sane person would want to write this

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

Programs in this programming language right you don't even want to write addition and subtraction that alone right things like swiggy Or develop a Facebook or Linux or Grand Theft Auto by game right so all of those are Doable, but it would just be like a gymnastics, right? Really you have some high-level idea in mind you want to translate it to some other You just want you just want to express those ideas in a way That sort of captures what is going on right this is sort of this esoteric thing

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Which is like puzzle solving so we really don't want to do this programming this particular programming language And that's why we have many other programming languages, right? so Why do we even so let's just take this analogy right so? So if if this language single instruction programming language is bad. Why can't we just do with? One single programming language why can't we write everything in say C or everything in say Java? Why do people even bother?

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

But other programming languages So and why do we you have to study right at the end of the day? You are taking this course and you have you you need to ask yourself Why am I being subjected through this course why I just want to do my fancy machine learning algorithm, right? You know see you know Python That's sufficient for doing all the systems level work right and all the high-level stuff

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So why do we even study other programming languages the course is about study of programming languages? So what what is the reason I think the analogy that I can provide is it's like studying a foreign language Suppose you study French or Japanese or other language, right? What do you actually gain? You just don't learn Just the language you also learn about another culture, right? And then you pick the best aspects of their culture you can incorporate it into your own life

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

You might have certain preconceptions and prejudices about others, right and that sort of is erased by learning Other foreign languages, right and at the end of the day even if you just want to talk in your own language, right I Even in that case just understanding another language gives you a way of a comparative study of what your language has and doesn't

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

Right in that way you understand your own language your own mother tongue better by studying a different language right and the goal of this course in my mind is that The goal is that I want you to become better programmers through the study of programming languages, right? I am not going to teach you advanced techniques and how to do Java or advanced techniques and how to do say Python

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

The course is not that right, but the course is going to teach you Certain ways of doing programming that will sort of Hopefully affect the way how you write programs in other languages Some of these statements might be very vague at this point. It will become clear, but bear with me right, so When I say we are going to study programming languages you might ask okay, which programming language right and

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

and here Again, we can use an analogy to say what do we mean by? Programming languages as a field of study so programming languages as a field of study is to Java in the same way as Linguistics is to French right linguistics is the study of? Like various languages and features and so on right you're sort of feeling in the abstract You're sort of you have abstractions that sort of capture

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

The have some knots of various languages and you might be able to think about certain patterns Which go beyond just looking at say a French or Hindi or Tamil right so? You're studying these things in the abstract in the same way programming languages is a field Where you study things more abstractly? than studying individual programming languages it sort of Gives you a way to step away from a particular programming language and appreciate what the language does right?

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

Again, we can make this more concrete When we say programming languages is a field It involves a lot of things right we can say language design implementation semantics Compilers is also part of programming languages Interpreters runtime system security reliability testing verification and so on It's it's adjacent to software engineering in the family tree, but to be clear. This is not a software engineering course right we are going to study programming languages and

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

When you want to ask yourself Why am I doing this in the middle of the night trying to do this assignment think about linguistics right in the same way? You study linguistics Rather than just another language. We are studying programming languages rather than just another language Okay, so When we talk about linguistics right, I'm just trying to push this analogy a little bit further when we talk about linguistics there is this principle of linguistic relativity and the principle says that

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

The structure of the language right affects the speakers worldview and cognition so This seems abstract so there are I Mean in all of our languages we can count right we have numbers we can count I can count to any number I Can you write down any number I can I can sort of say? This number has 1 million thirty two thousand three fifty five right there are some private languages right real languages where

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

You can only count up to say seven and then there is no word for eight or nine or ten and more They just use the word lot Right, so when you have a language that only has Birds up to seven and then you're you're done right everything is a lot it even affects you Like you cannot express additions anymore, right? You will hit this upper limit. You cannot express subtractions

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

You cannot do multiplications all of these are ruled out right and you cannot have advanced thought Right, so that's that's sort of the essence of this Idea of linguistic relativity in the same way we can apply this to programming languages so the way you The way you program in a programming language actually affects programming thought by which I mean I might teach you some language

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

X&Y which has some features right which another language you choose your favorite programming language that might be Python Python might not have the feature But it sort of shapes the way you think about the problem, right? Ideally for all programming languages are just tools right you have an idea in mind and programming language is a way of expressing that thought and Programming languages when we study these concepts will shape your programming thought at the end of the course you will feel that You've actually gained a different perspective

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

into how you think about problems, right and Yeah, so I think I've said everything here and coming back to Programming languages, right Alan J. Perles is this person who was the first recipient of Turing Award, right? You know that during award which is the Nobel Prize equivalent for the computer science, right

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

he received it for the influence in the area of programming techniques and compiler construction and what he said was A language that doesn't affect the way you think about programming is not worth knowing Right in this course. We will look at two languages, right Which is hopefully Quite different from what you've seen so far in your Courses right so they sort of challenge you They sort of unlock this part of your brain

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

which You haven't You didn't know existed right so let's just put it that way I might be talking in hyperbole But this is what I learned right so I'm just echoing those So, okay and Coming to a practical right I'm The aim we will choose Two languages, right? We will choose two languages OCaml

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

Which is a functional programming language and prologue which is a logic programming language to teach this course But the aim of this course is not to teach you OCaml and prologue, right? Even though you will learn OCaml and prologue in the process It is the end goal is not teaching these two languages I could have picked any other two languages that fit within these boxes Right and that would serve my purpose so when you

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

These languages have these languages have features that are Not widely used in other languages, so it sort of shapes how you program in other languages and the fact that Languages are just tools right it's like picking your favorite Water a shoe or something, right It doesn't matter these languages come and go so there was no Java 25 years ago

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

C sharp was 20 years ago. That's this 10 years ago. I mean it's still maturing right that but simply is this new way of Programming for the web which came two years ago There might be other languages that may come next So I would sort of advise you not to get too attached to a programming language Right programming language is like a it's like a tool. It's like a hammer Right when you have program problems that you can solve with a hammer to use the hammer When you have when you want to unscrew something don't use the hammer you use a screwdriver, right?

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

So you should be flexible enough to sort of Not become too attached to a particular programming language. You should become an expert, right? So that's totally independent, but don't Feel this need to get attached too much to a particular programming language And in this course, what we'll do is what why am I saying this you will learn? You learn two languages, right and it is likely that

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

After this course, you may never use these languages, right? So But that that doesn't that shouldn't stop you from Exploring the languages that we teach you in this course to the full extent, right? So don't don't Always compare. Okay, I can do this nicely invite and why am I doing this in this weird way in this other language? Right, that's not the point So what do we actually teach in this course we teach a couple of things couple of things

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

We will see concepts in programming languages. We will see high-level concepts in programming languages You will also see programming paradigms. There are different ways to express the same problem Right some problems are expressed better in one paradigm and we will sort of see What those paradigms are? how to identify a particular problem and Choose which paradigm to apply

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

Right that is sort of the sort of what I mean by programming paradigms And we will also see some details about language design and implementation. So the idea here is not Not to have you implement real compilers, right? So that is that is what you will study in the compiler scores The idea here is to for you to appreciate how To design nice languages that have nice features, right? So we are not going to dive too much into implementations, but it's about

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

coming up with good abstractions and We will also learn what makes a programming language, right? What is the anatomy of programming language? What is fundamental in a programming language? What is just syntactic sugar? Just like we saw in the single instruction Programming language, right so that I I first showed you this instruction that took three operands and I told you the

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

Second form which only took two operands is just a syntactic sugar. So Essentially there is only one right so you will sort of going through the scores you will identify which language which language features are primitive and which language features are Can be implemented as library functions over those primitive features. So Why this is useful? This is useful because it allows you to dive right into Understanding a particular feature, right if you can sort of explain a particular feature in terms of other primitive features

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

You become an expert quite quickly, right? You can sort of see through this facade, which is the syntactic sugar You will you will learn some of this as we go through the course Yeah, so you will learn new languages right you do You will learn ocameran prologue. So this will give you a new way to organize and display computation, right? So and this will guide you in your

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

Exercise when you write Python in the future or JavaScript in the future, right? So So that's that's really what we are that is also the other thing that we will do in this course and This is one thing that we don't appreciate too much is we sort of When when you start learning programming, right? It is all about the language that you pick

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

But if you look at the industry new languages are being designed As we speak right, it's actually growing a lot In the last few years if you just take the last 10 years, right Facebook has two languages that came out so there is a language called flow which is a Type system or JavaScript. There is a language and react is a framework, but really react is A language also so react is this UI framework if you have to build a UI today

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

It is very likely that it is written in Jack And that us does this language that came from Mozilla right as a better replacement for C++ Right type script is a better alternative for JavaScript from Microsoft Swift is a better way of programming mobile devices from Apple WebAssembly came from a combination of Mozilla Microsoft and Google, right? and Opera as well as a better way of writing programs for the web as a replacement for JavaScript so

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

When you go into the industry, right? It is very likely that you will sort of encounter new languages and This course will guide you with the ability to identify and quickly get To the root of what those new languages mean right you will appreciate what is what is the essence of a programming language? and

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

Buried in every large system Right if you take any large systems that you work with there is a language that is embedded in there Right when you pick databases there is sequel When you pick Excel Excel is the most widely used programming language in the world, right? so Excel is incredible and and Word has all these macro functions you can write vbscript macro formulas, etc

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

Emax the editor has a programming language called this embedded in it Anything that you do right in order to write shell scripts or make files to build your files or late Take to write your PDF. They're all programming languages all the now this whole fat with blockchains, right? All of these blockchains have Smart contract languages embedded in them So if you work on it, I mean take my word for it if you work on a large system

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

When you go out and do in the industry or even do research, you will design a programming language This might not look like a new programming language. It might just look like a bunch of scripts that you put together But it is going to be a programming language. It might just be an API even right and that API is also a way of Is out of squint it is also a programming language and you are going to design it and this course will equip you to come up with better API is and better programming languages better domain specific languages and so on and

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

When you are in A position of power or when you get the freedom, right? This course will sort of enable you to Choose the right programming languages for the problem and then remember this analogy about programming languages being tools and Amazon screws and screwdrivers and so on so So this course will sort of guide you even though we don't actually

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

delve into details the source this course will sort of guide you in choosing the right programming languages for the problem that Is not dictated by what libraries are available what standards what your managers tell you to use, right? If I were to give you the freedom the course will give you the ability to Choose the right field in my mind You are going to do wonderful things in the future, right? You will You might do a number of things

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

This course will give you the tools necessary for making informed choices when it comes to programming languages Right, that's the other goal so Coming to the details right the course syllabus itself has two languages. We will study the language called o camel Which is a functional programming language? and we will study lambda calculus which is sort of an abstraction of

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

Functional programming so it's it's a really beautiful very tiny language will study that we will also study logic programming using Prolog oops and For imperative programming we will See those features in the o camel right and if we have time I want to show you a little bit about Parallel programming also in o camel right? So if we have time we'll get to that

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So at this point you might be asking why am I asked to study this? Esoteric language o camel and prologue right are they the best choices to teach this course? why can't this course be taught in say Python right and My response to that would be asking. What is the best programming languages for this course? It's like asking what is the best part? What is the best shoe? There is no one answer to these questions, right so

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

Let's just pick cars and shoes for the moment There are certain cars which are fit for certain purpose, right? If you are going to win the formula on race, there is a certain car for that if you want to take your Friends to some movie, right? You want a big car you want to fit a lot of people and so on So you won't take the s1 car there right that just be stupid you get stuck on Just your garage and not hit up if you are going off-roading you'll choose a different car If you want to move things from your hostel to your home or something

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

You won't pick any of these cars like you will pick a car which has lots of room So in the same way you can think about shoes When you want to play cricket you choose a shoe when you want to go to the beach you should choose a different shoe Hopefully right not wear the cricket shoes when you're going to a formal dinner Right, you want to pick your best address shoes, right not The same shoe that you will wear for a beach in the same way You don't pick a particular programming language, right?

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

We pick ocamel and prologue because it is it gives us the ability to teach you concepts nicely and Just extending this analogy Like let's take a mechanic right who works on a particular Just works and his specialty is cars. He might have a specialty about fixing certain things in a car, right? He might be He might be well very good at fixing the transmission in the car

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

But he also understands how all the cars work, right not a particular make our model He won't say oh if you bring a Hyundai Accent I won't fix it. I will only work on Toyota some Camry or something, right? So he won't say that that's not That's not what he does. Right? He might have particular favorites. He might understand a particular car very very well, but He won't hold something

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

Personal that he won't say I won't work in this thing, right? And he would definitely not refuse to work on a car based on the color that would just be Really bad decision for a mechanic, right? The analogy here is developers right so as developers If you are writing programs, he's art of you might have favorites But you can't you need to understand all of the things right? You need to understand different languages and you might choose to work on one

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

but that doesn't mean that You'll say I won't work on this because I am being asked to write code and say Java Right so that that that that is not something that is very helpful and Again extended extending this analogy a little bit further So imagine a good mechanical engineer who really knows how cars work. He can actually build better ones, right and he's

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

He knows how to tune it he knows how to extract the best out of it, right? The analogy here is compiler engineers and programming language specialists, right? They understand how the cars work They might just work on a single car Right. I am one of the developers of the oCaml programming language I tend to write everything that I do in oCaml, but I also write JavaScript. I also write C, right? I also write Java whenever the situation needs it. I understand oCaml best

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

So I tend to lean towards it, but I am not against any of the other languages, right? so that and This is sort of you right When you are first learning to fix a car or you're first building Like a model car Right, you're not going to build Say the f1 car, right? I'm not going to build toy the Camry Right. Why do you want to get bogged on by features? Like how does this AC work or how does this?

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

I Don't know some Remote key Unlocking mechanism works really you want to get to the essence right you want to say what is a car? how can I understand it? How can I build it and The languages that we've chosen right this oCaml and prologue Get to this essence very nicely compared to other industrial languages again This is a you can sort of say this is a subjective comment, but

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

Really these languages are very good at teaching paradigms it much more than Python or C or Other languages, so that is why we've chosen oCaml and prologue So Going to the details, right? When you sort of learn a programming language you learn a bunch of things you learn Syntax how to write language constructs you learn semantics. What do programs even mean?

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

What is the meaning of a particular program you learn idioms right design patterns? Given a particular language. How do you express? a particular computation in the best possible way you also learn lot of libraries, right third-party library to access data structures are to do a Web request and so on and you also have lots of tools Tools like debugger GUI build system and so on so

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

If you try to break a programming language down into these sort of five Boxes it makes it easy to learn right? What are you actually mean? What do you actually mean by a part learning a particular programming language? and In this course we are only going to focus on semantics and idioms right we might sort of touch up on the other things but really We want to concentrate on semantics, right?

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

When when I give you a program, what is the meaning of the program? right or a compiler or interface right you will sort of learn how to reason about programs and What do I mean by that? We tend to be very very precise about The programs in the same way we are precise about mathematics, right you won't say five plus six I think works like this it can be either

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

11 or 10 right that is not a statement that you would say because mathematics is tends to be very precise and Logic tends to be very precise and in the same way You will learn techniques where you can say Instead of saying I feel like the conditional expressions will work like this you'll actually Know how to precisely specify how a particular language feature like conditional expressions expressions work, right? and Yeah, and

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

Why do you want to do this in reality much of the software development is coming up with good abstractions, right? Good API is a good interfaces and so on so understanding the semantics very deep extent will sort of guide you in Designing better programs. That's the goal and you will also learn a bunch of idioms, right idioms are as I mentioned common patterns of programming So what we will do is we will

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

Look at a couple of ways of writing The same program perhaps some might be better than the others, right? And once you sort of see certain idioms certain patterns and You you have seen the same pattern in multiple languages you sort of see Any given particular language in a better light right if I for example tell you how this is how? Function pointers work and you see the same concept. There is a concept in

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

OCaml called higher order functions. These are quite similar Once you actually see higher order functions, you will understand function pointers in a better light, right? And that is what will happen again. I'm not going to I won't tell you oh here is a pattern that we are seeing this mirrors X and Y in Java or X and Y and C Or X and Y in Python We will just focus on that particular feature

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

But hopefully what you will see while understanding the semantics of certain features you will sort of see that There are features in your favorite programming language which mirrors What is happening here? By not mirror it exactly, but you can sort of use that vocabulary to talk about The meaning right how it works and what it means so that's that's the other thing that we will do

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

So again switching to analogy so consider Hamlet, right? Hamlet is this famous play written by Shakespeare and It's a beautiful work of art right and has lot of deep and eternal roots, right? It is It has lots of well-known sayings And then I think you know a few of those but I will just let you Figure it out yourself and it sort of reading Hamlet makes you a better person because it's like reading one of those

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

Any of those moral books right so there are lessons that you can apply to your own life and it makes you better and It still continues to be studied right centuries later Right, it was written back in the 16th century. We still study it And that is what people do right, but the syntax is really annoying too many so Shakespeare and English is not Not the way you would sort of imagine

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

Writing those sentences in the same way right and it gets in the way all the time Even for experts right when you study Hamlet, there is some beauty in it, but the way of reordering These words and jumbling it sort of makes it hard to understand what is going on and there are of course a lot of plays and adaptations of Original book Hamlet right with the same lessons, right? You could argue like I watched the movie made on Hamlet

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

Why do I even study Hamlet? but reading but reading Hamlet has its own benefits, right and and Of course reading Hamlet will not get you a summer internship the analogy that I am trying to make here is Think of OCaml and prologue like Hamlet, right so You will learn a lot of things which you can Which will which is sort of inform you about programming languages, but but you might you might actually

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

come into Real practical problems with syntax, right? and You can do the same thing in other languages and so on But but just like reading Hamlet has its benefits I believe that Doing programming and prologue and learning prologue and OCaml has benefits right and

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

Libraries and tools are not our focus. We are not going to focus on libraries and tools Again there are Throughout your career you will keep learning New libraries and tools. It's not even worthwhile to talk about libraries and tools in this course, right? We will not even focus on that And syntax is the most boring bit right people object obsessed over syntax all the time Oh, we use a semicolon where we should have used something else curly braces or some some nonsense, right in this class

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

We won't complain about syntax right if you come to me and say oh, okay. Well has this bad syntax I am not going to like even respond to that. That's the most boring bit there is some there is far more interesting things that are happening and complaining about syntax is the is the Easiest way to do by shedding yak shaving. I don't know whether you've heard this So you're sort of like Focusing on unimportant things right we won't focus about syntax syntax will be weird. It will be sometimes you might feel that

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

There is a better way of expressing the same thing, but I think we'll just Take syntax as a bitter pill right to learn what is going on? and In terms of course logistics, I have 10 minutes. So I'll just go through this So the course website is available So if you let me see if I can click on it and it will open up. Yeah, okay The course website is here, right?

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

and if you Yeah, so you can go and see the course website the information is here. There is not much here I'll start filling the schedule and assignments. There's a lot of resources here, right for how to I Reading right recommended reading and so on One thing I will highly recommend in this course is Following this Cornell CS 3 1 0 0 book for OCaml, right? It's an incredible

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

Book it is written in a very easy manner right and it's really available here and The Lectures will not closely follow what the way the book is organized, but I expect you to read this book Right, I won't ask questions that are only in the book but not taught by me that that won't ever happen But you are expected to read

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

The chapters that I point to right. So if you just Go with what I taught in the course What I taught in the lectures you will miss certain things, right? Of course, I'm going to ask questions on topics that I've taught only in the lectures But you are not going to I'll add a little spin on it. But if you haven't sat and thought about Those questions in a different way

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

You will sort of you might lose points right? This is This is my recommendation, right? I don't care if you read the real world OCaml, but Do follow At least the I'll point to specific chapters, right? You just and those are very small chapters So please do read those chapters, right? We are not going to have quizzes. We are just going to have final exam so Start don't wait until the last

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Final exam to read the entire book that's not going to work by point to certain Reading material do try to read it. It's quite important that you do. Okay Let me go back to This thing okay, so it's here So, okay and there is a core slack I think some of you have already joined do join slack I I

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

It's much more interactive. So if you have a question, I can quickly answer to that. Voodoo is very bad at Formatting board and You can you can be are not going to be able to meet In person for resolving your doubts, so just Ask a question and I can quickly respond to it And it's also a nice way to help your fellow students

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

With questions, right? So slack is very nice for them. So I I usually hang out on slack, but I highly recommend joining slack So lectures are delivered through this interactive Jupiter notebook I don't know how many of you have used Jupiter if you've done any sort of Python and Data science things you would have used Jupiter so the Way this course is going to be delivered is just you better notebooks, right?

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

And I use it for lectures. I use it for executing code in place right, and I also use it for the Assignments. So the way assignments are given is you're given a Jupiter notebook you just there are boxes where you fill in the solutions you can run the Jupiter notebook to Check on the open test cases, right and There are some closed test cases which I only have but you can actually interactively program in the Jupiter notebook and you will submit your Jupiter notebook

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

We will go through this slowly, but everything is going to be delivered through Jupiter notebook and there are instructions on the course website how to How to work with Jupiter notebooks, I highly recommend Interactively exploring the Jupiter notebook, right? That is the way you learn don't convert the Jupiter notebook to PDF and then read it That is not going to give you

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

The experience this is paradigms of programming. We are not just going to study these things in abstract, right? It's like It's like a toy, right? So when I give you a toy you can describe that the toy works like this works like that and from a distance But really the way you want to understand the toys play with it Try to take it apart break it put it back again and so on right unless you actually play with your hands you're not going to learn the concept so we don't have labs right in this course, but This is going to help you

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

Practice a lot. You don't have to write arbitrary programs. Just practice what is taught in class Right. So and the Jupiter notebook setup is very easy for them and This is the grading pattern that I have I For NSM will have 50% for programming assignments. We have seven assignments Each of these assignments should take you like

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

Two or three hours, right? They are not going to take you a lot of time if you are following the lectures They are not going to be very difficult Right, they they will get progressively a little bit more complicated, but they are not going to take like Like two full days of sitting and solving the assignment, right? So These are going to be short ones that are going to be enough examples to guide you through Through solving the assignments and the interactive notebook is quite useful for that and I don't want to

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Load the course, I mean we have a very weird situation where we don't have business so I don't want to award all of the scores to the NSM which will be very Yeah, that's not going to occur I personally wouldn't want it so I'm going to have assignments I'm hoping that you will have the ability to run the notebooks if not Do email me and then we will make sure that you set up the notebook and you have some way of

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

Doing the assignments right and if you have problems you should you should write to me you should you should use the Email me right. That's the best way to interact through this and I mean adding this it's not coming to 100% so 1% for class participation Just Show up I there is no attendance just show up in class try to answer questions

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

Directly do something to get that 1% So it's not going to be hard, but we interact and ask questions so that's that's really what I'm looking for in the person and Pagerism I'm going to be very strict on various and right I don't This is going to be a programming course 50% is going to be programming These are going to be very easy programming assignments, right? If you plagiarize on it, you are going to get zero

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

Right for that assignment if I find you repeatedly plagiarizing you're going to get a ugrid. I've enforced this in the Previous year, so I'm not going to be going to shy away from enforcing this again, right? This is your this is the last time I'm mentioning this right if you come to me and say Can you give me relax me the rule relax the rules for me? I am NOT right I'm going to follow this very very strictly and we use

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

multiple plagiarism detection software we have all the assignments from the previous year in order to check so Make sure you try it out, right and these are not hard So if you have a question if you don't understand rather than plagiarizing just come talk to me, right and We will figure out we'll also the TS right they will know how to teach you What's going on? But don't plagiarize. That's my and I'm not going to relax on this

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

I Think let me see how many slides I have I think we are out of time. I don't want to last like okay, so Again, so we will use okml prologue in this course all of the All of the material is provided through Jupyter notebooks, right? There is a docker image that is available if you don't understand what is Jupyter what is Docker and everything? I will have a class where I explain How I set this up right? It's very easy

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

But I think if I show you how this works, it'll be sort of easy for you as well to appreciate that It is easy. I'll do that on Friday, right? and You can install it locally, but I don't recommend doing that. It's a bit of a mess this local installation of okml and prologue but We you don't need advanced knowledge of Docker or Jupyter notebooks. It should just be plain and easy

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

So hopefully we will sort it out. We'll make sure that everyone is sorted, right? We won't let anyone down before giving the assignments We'll make sure that all of you have some setup where you can practice course and submit assignments. Okay So I'll stop here and We will get into more details in the next class any questions No questions Okay, so I

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3054.8s_

will I Will stop recording. Okay, so I see some messages. I haven't actually Seen Sorry, I didn't see any of the messages right so I was in my full-screen mode. I'll try to see how I can get I'll try to figure it out. Okay, so I'll see you tomorrow. Thanks everyone

---
