# 34-cs3100-pop-lec-34-prolog-basics

**CS3100 POP - Lec 34 - Prolog Basics**  
id: `IFx7v12yfXQ`  
duration: 2900s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

I'm starting my recording. I'll start presenting my screen, and then we can get started. OK, so what we are going to do from today is look at the second part of the course. The second part is logic programming. We've seen imperative features as well when we studied functional programming, but I'm not going to touch on imperative features anymore.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

And this is what we've been seeing when we studied side effects and monads and so on. So what we haven't looked at so far is logic programming. And the way I'm going to do it in this lecture is give you a motivation for Prolog, sort of get you through some basics of Prolog so that you can get a feel for it. And then we will sort of step back and look at the logical foundations of Prolog,

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

and then slowly look at how to program with Prolog, do interesting things with Prolog, and so on. So in this lecture, we're going to sort of motivate why Prolog. And we'll see how that works out. So previously, we've seen functional programming in OCaml. Today, it's going to be logic programming in Prolog. So when we write imperative programs, so here is an imperative program written in Java.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

In order to compute the sum of an integer list, the way we would do it is we would have a variable called result, and we will say, okay, iterate through the entire list. And for each of the elements in the list, add the value in that list element to the result variable. We are destructively updating this result variable. We are incrementing it, and we iterate through it

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

until we reach the end of the list, and we return the result. So this is how you do it in Java. So if you were to do it in, say, functional programming, let's just pick OCaml because that's what we studied. We would write it as a specification which looks like a recursive function, sum, which takes a list. If the list is empty, then return zero. If the list is non-empty, right, then add x plus recursively applying sum

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

on the rest of the list, right? So it says, okay, there are two options, and based on those options, either return the value for the base case or do the recursive case. And when you get back the result for the tail of the list, add it with the head of the list, and that's going to be the result, right? So this is how you would write the sum of a list in OCaml. So here is a prologue program that computes the sum

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

of elements of an integer list, okay? So the way to read this is, in prologue, we say here that there is a predicate called sum, right, which says, right, which says the sum of the empty list, which declares that the sum of an empty list is zero, right? And then it also says that if the list has a head and tail,

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

right, so there is some notation here which we'll sort of come back and look at it, but just go with the flow now. If the list has a head and a tail, then we declare that the sum of the elements in the list is n. If you can show that the sum of the tail of the list is n, right, p is the tail, the sum of the tail of the list is n,

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

and you can also show that n, n is head element plus the sum of the tail of the list, okay? So the key difference between this description and the ones that we've seen previously is that here we are stating the rules for what the sum of the list should be, right? So we are actually declaring some facts here

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

and some rules about how to compute the sum of the list, but we call this a declarative reading as opposed to non-declarative reading in the case of functional programming and Java. So what does that actually mean? So the way to read this idea is a bit subtle, but I think you'll develop an intuition for this as we go on through the lecture, is that in Prolog, the description of the program

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

basically says what the sum of the list is, right? And it doesn't say how to compute the sum. In particular, Prolog program does not define control flow through the program. It doesn't even say in which order you compute the result of the list. It just says declare some facts, right? It declares a fact saying that the sum of an empty list is zero and the sum of an non-empty list is n, right? According to these rules.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

It doesn't describe how the program is executed by the machine. It doesn't say here is the control flow, here is the say branching statement and here are the true and false statements and so on. It just declares a bunch of rules and your Prolog interpreter somehow figures out a way to execute this program, right? So the main difference between Prolog and the languages that you've sort of seen so far

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

is this notion of being declarative. It declares how things are to be done whereas functional programming and imperative programming tell you, give you an operational description that tells you how to compute the sum, right? So that's the difference. We will look at it more and more as we go through but that's the main thing that I want to emphasize in the rest of the lectures, right? And a Prolog program itself is a collection

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

of facts and rules. We will see what those are. And just in this case, this is a fact, right? We declare a fact saying that the sum of an empty list is zero and we declare a rule for the sum of a non-empty list based on other rules and facts, okay? So that is how this works out. So the execution model of Prolog is quite interesting, right?

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

So it is very different from what the languages that you've come across, right? I can for now say that this way of thinking about programming is different from everything else that you've seen so far, be it CC++, Java, Python, JavaScript, OCaml, right? Or any language because when you look at an OCaml, sorry, when you look at a Prolog program,

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

the Prolog program, right? The program that you write in Prolog is essentially describing a database of facts and rules, okay? And the way you interact with the program is by asking queries. So you build up a program and then you post a query. When you post a query based on this program, the Prolog interpreter gives you certain answers. The answers might be a length of a particular list,

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

but the conceptual model of a Prolog program is that it builds a database of facts and rules, right? That's the conceptual model. And when you want to run the program, right? Running the program is essentially posting a query to the program and then the Prolog interpreter comes back with answers. So that's the conceptual model. So this is quite abstract, right? So this model is quite abstract.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

We saw this example with some of a list, right? This looks very similar to how we described some in OCaml. But how does this fit this conceptual model that I just described to you, which is a Prolog program that is this database of facts and rules, right? Using a database using facts and rules. And you asking for a particular sum of a list

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

is going to be a query. So the way you sort of imagine this, right? Conceptually, this is not a concrete execution methodology, but a conceptual view of the program that you should have when you look at an OCaml program is that OCaml inductively builds a table of relations. So given this sum, right?

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Predicate where you say that sum of an empty list is zero. OCaml, sorry, Prolog implicitly builds a table, okay? Where it adds a fact to this table saying that the length of an empty list is going to be zero. So one fact is added, right? And it looks at this rule. And the way to interpret this rule is for every sort of list that you have, right?

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

There are infinite varieties of lists that you can construct because you have infinitely many numbers as well as infinitely, the lengths are also infinite, right? So you can sort of imagine for every potential argument, it sort of builds a particular answer in the sum relation. For example, right?

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

It conceptually records that the sum of a singleton list, the sum of elements of a singleton list with one is going to be one. The sum of elements in a list with one and two is going to be three. The sum of elements in a singleton list with two is going to be two and so on. So conceptually, Prolog is building this relations, right? So it's building these tuples for every kind of list

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

that you can have. And what Prolog is doing is it's just looking up in this table. So, okay, so you have this table built up. Whenever you ask a query, it is simply looking up the answer in this table, right? Of course, this is not exactly how Prolog would work because there are infinite number of lists possible. It is not going to be able to build a database, but that's the conceptual view.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So here is how you ask a query in Prolog, okay? So when you write down facts, you write it down without a question mark. And so there should be a dot here.  When you write down facts, you're sort of feeding some facts and rules into the program. You're building up the database. When you want to ask a query, right? You have this question mark minus, right? That stands for asking a query.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

And this is how you sort of book the program. You sort of say, okay, now that I've given you the construction of what the relation should be, now get me an answer for this particular query, right? So the query we post is, I'm asking Prolog, give me the sum of one, two, three, and this X here is a variable, okay?

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

So Prolog has variables and all of the variables are start with an uppercase character, right? So all I'm asking is go look up in your table and then find me for this list one, two, three, what is this X? What is the value that will satisfy this X, right? So, and if you ask this query, I need to run this thing.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

So if you ask this query, it's going to come back and say, I know that there is going to be one particular satisfying result for this and that X is six, right? So all we are doing is computing the length of the list, but the conceptual model is you're querying the program that you've built up for the result and it returns with six. Okay, so of course the computation model is not to build up a database and look up facts because that wouldn't work.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

We will see how Prolog works in the rest of the course. Okay, so, but you might ask, right? Why do you want this declarative view at all? So we've been perfectly happy with the program, programming languages that you've learned so far and you've learned OCaml in this course as well and I've sort of expounded all of these nice features of OCaml. So why am I even teaching a different paradigm, right? Is this even necessary? And of course there is the question of Turing completeness,

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

so if given that the languages that you studied previously are Turing-complete, why bother learning a new language at all? So the reason is that many problems in computer science, at least a subset of scope of problems that you want to solve are naturally expressed as declarative programs. These sort of programs where you add facts and rules and you ask questions about the program. Some examples include the rule-based AI program analysis

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

that you build up facts about your code. Let's say I have a large code base with million lines of code. I want to find out what are all the functions that call a particular function foo, right? So this is a query that you ask about the program and you have an analysis engine that builds up facts and you can ask questions about the code.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

Type inference itself is sort of a declarative specification of how the types are inferred, right? So whenever we write the inference rules, we sort of write these inference rules as separate entities and then say, okay, the types are now type checking and type inference go hand in hand. We've seen type checking, but the way you have to sort of look at it is these are declarative specifications of what the types should be, right? You can read it both forwards and backwards.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So if you read it one way, you get type checking rules, which is what we saw in synthetic lambda calculus. If you read it the other way, you get type inference, which we haven't seen in detail, but we've used all the way when we were programming in OCaml. That also has a very nice declarative view and graphical programs, right? Whenever we build any sort of graphical UIs, even this one, the thing that I'm using to display the slides to you are never built with,

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

are seldom built with operational view of things. So the way you build modern UIs in JavaScript, right? Think about React and so on. The way you sort of say is, I sort of build up a logic of components. So I put up components together. I tell you this is the way the components should work, right? I won't describe what happens between each component when I click a button. I sort of put them together in a declarative fashion.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

And then the interpreter, the JavaScript interpreter that's sitting underneath powering React, for example, figures out how to modify all of your components together. So if you've done graphical programming, you would sort of understand this, but that's the idea that's going on here. So these set of problems, right? They are naturally expressed as declarative programs. The problem is that as a programmer,

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

when we are writing these programs, you have to convert this to the Von Neumann architecture, right? The Von Neumann architecture has an input device, a central processing unit, a memory unit, a control unit, and an arithmetic unit within the CPU. And then there is an output. So we have to sort of write our program such that there is control. All we do is care about the control, right? And then data flows through the program. So this is not the ideal architecture

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

in order to express these programs, right? Of course, these programs are going to be compiled or interpreted to run on this architecture, right? But as a programmer, you don't want to explicitly write these programs in this architecture. By Von Neumann, think about every imperative language that you can imagine, right? Sometimes these problems are much nicer if they were expressed in their original rule-based, sorry, original declarative thinking.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

And that is where Prolog comes in, right? So logic programming of which Prolog is one particular instantiation, right? That's a particular language that allows you to do logic programming, allows the programmer to declaratively express the program. The programmer expresses the logic, right? And the control, how to execute the program is actually left to the compiler. So we don't say go do this first and then do the second.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

We leave all of those concerns to the compiler. And when you take the logic and the control together, what you get is Prolog, right? So Prolog is a particular language which aids in logic programming. So you can describe logic programs without thinking about a particular language, right? So these are just logical statements. And once you add a compiler, which determines the control,

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

you get a language and the language that we are going to look at is Prolog. So Prolog itself is one of the first logic programming languages, right? So to be precise, Prolog includes a family of languages. So that different by the choice of control, we will again look at what these control choices are. So this was invented way back in 1972, right? So it's been around for a long, long, long time

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

and it has very, very many different implementations. And for our course, we are using one particular Prolog compiler called SWI Prolog. There are lots of Prologs, there is new Prolog and various implementations of Prolog. The one Prolog that we are using is SWI Prolog. The choice is arbitrary. I picked it up because I had previously TA'd a course which used SWI Prolog. But we are not studying the language specifics, right? We are not looking at features of SWI Prolog in detail.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

What I want to get across in this rest of the course is the notion of thinking about logic programs, right? So that's what I want to get across. So you might ask, right? This was invented in 1972, right? So this is so far back in, I mean, it's going to be like 50 years really soon, right? It's been like two years. Why should I bother studying this language? I have so many new languages.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

Should I not be happy with programming in, say, Python, right? Why bother even thinking about these things? So just to give you motivations for why these ideas are important, right? So this is a tweet that was posted two weeks ago, right? For those who don't know, Simon Marlow, which I assume most of you will be in that basket.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

So Simon Marlow is one of the key persons behind the most popular Haskell compiler, the Glasgow Haskell compiler, right? Him and Simon Peyton Jones are the ones who implemented much of the compiler, right? So they used to work together in Microsoft Research. And for the past few years, Simon Marlow has been working at Facebook and in Facebook he's been using Haskell in order to build very cool stuff.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So, I mean, Facebook is now one of the largest users of Haskell internally. And he implemented a project and now he is working on a new project called Glean, right? Which is a data log-like system for indexing source code. So data log is one more logic programming language. It is a more constrained version of Prolog. So let's come back to the actual differences later. But take Prolog and remove some features,

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

you'll get data log, okay? So Glean is a system that is data log-like. So it uses logic programming underneath and it is used for indexing source code. What does he mean by indexing source code is Facebook has some 100 million lines of code, right? Maybe far more, the numbers that I'm saying are what they publicly acknowledged a few years ago. It might be much, much larger now. So what Glean does is Glean sort of goes

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

through your code, does program analysis to discover facts about the code, right? Just like the facts that I mentioned earlier, right? What are all the programs, what are all the functions that call this function X? Is a question that you might want to ask. Why do you want to ask this question? You might want to say, I am going to change the type of this function. So where are all the places I need to change the call site? So if I change say, if the function say takes two arguments A and B, I'm going to

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

for whatever reason change it to B and A. So I want to quickly answer how much code is affected, right? Where are all the places where I'm going to have to change this, do this change. This is refactoring, right? And this is a thing that you often do in large projects. And Glean is a tool that helps you do that. And he's actively hiring for the system, right? So this is two weeks ago. And yeah, so Facebook is actively

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

using logic programming underneath. So it's quite important. And this is the example that I used in the last year, right? So the last version of the course, which I delivered last year, which is around the same time, September 18, 2019, GitHub acquired this company called assembly, which came out of Oxford University, a bunch of researchers implemented the assembly. It is meant for doing very similar things.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

So you have your code, and then you want to ask questions about code. And GitHub is perhaps the largest open repository today of code. And if you use GitHub, right, for projects like JavaScript, whenever you, or Ruby, right, whenever you build, whenever you push code, it automatically runs some security analysis on your code and finds out what vulnerabilities are there

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

in the old version, and it recommends you to upgrade to new versions, compatible new versions, right? So I might say, okay, this version one of this library has some security vulnerability, which was fixed in version 1.1. You should also think about moving your version the other library, which was in version two in order to upgrade it so that it works with version 1.1. These are very complicated constraint. These are essentially constraint programming problems,

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

which is also a subset of logic programming. And the way they actually interact with the code is using this language called QL, which is a query language, which is an object-oriented version of data log, right? Again, an instantiation of logic programming that is suited for their own purpose, and GitHub acquired Semle last year, right? So if you are using GitHub, you are essentially taking advantage of logic programming

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

through this Semle tool that has been integrated into GitHub today. So you don't even have to think about it. So logic programming is quite important, right? So these are but a few examples. I just looked for some recent example, but there are lots and lots of examples where this is important. So if Simon Marlow, who implemented Haskell is sort of saying, okay, there is some interest in data log-like system,

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

it might be useful for us to also know, right? What this logic programming is, and that is what we'll do in this course, right? We won't look at Glean or the data log in detail, but I want to emphasize certain concepts that you might take and understand what these systems are doing at the end of the day. Okay, so... So Prolog is good at modeling relations, right? So as I mentioned, everything is a relation there.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

So let's model family relations. So I'm just picking up the Stark family tree, right? And the family tree is here. Just for example, right? So we are not going to look at this too deeply, but here is the family tree. And what I'm going to do is to encode certain facts and rules about this family tree and ask questions about the family tree.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

Okay, so that is what I'm going to do. So here is... So before we start writing bigger programs in Prolog, we should understand what the Prolog terms are. And so there are only a few terms in Prolog. There is not a wide... The Prolog is not a very large language. It's actually a very, very small language. So you can quickly understand what a Prolog program should mean.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

So Prolog has a couple of terms. The first one is constants, right? Things like one and two numbers, one and two floating point numbers like 3.14. And anything that starts with a lowercase letter, right? So those are all constants. So Rob is a constant. And strings for strings, if you want to actually introduce uppercase letter, you have to put it in a single code, right?

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

How stark is a constant? It's just a constant that starts with the code here, right? These constants are also known as atoms in Prolog. And then we have variables. So we saw one variable earlier called x. Every variable in Prolog starts with a capital letter, right? So x, y, sticks are all variables. And we also have a special variable, which is a don't care variable called underscore. The idea here is very similar to what we've seen in OCaml.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

I don't care about naming this variable. And just let it be underscore. And then you have... So we've seen constants and variables. Now we have terms, compound terms that we can put together. So the compound terms are going to look like male, Rob, father, Ned, Rob. The way you sort of read it is try to translate it into English, right? Rob is a male, right?

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

Ned is the father of Rob. So those are compound terms that are applied over other terms, right? And for compound terms, there are a few things. There is a top function symbol. So this male and father are known as a top function symbol or also known as functors. Again, these functor, the term functor here is very different from the OCaml one. Because it is confusing,

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

I'm just going to use top function symbol in the rest of the lecture. But they are also known as functors here. Each top function symbol also has an arity, right? How many arguments, how many sub terms can it be applied on? The arity of male is one because it takes exactly one argument. The arity of father is two because it has two sub terms, right? And top function symbols are also explicitly written down

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

with the arity in OCaml, in prologue this way. So we write male slash one, father slash two, essentially to say male is a top function symbol whose arity is one, father is a top function symbol whose arity is two. Okay, so those are the terms. So here are some facts about how start.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So this is only a subset of the relations that are out there. But this is useful to understand how prologue works. So what I'm saying is I'm adding a few facts to the database, I'm loading up facts in the database. I'm saying record is the father of Ned, record is the father of Brandon, record is the father of Liana, Ned is the father of Rob, Ned is the father of Sansa, Ned is the father of Arya, right? So I'm loading up these facts.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

If you run the cell, so prologue interpreter comes back and says, okay, I've added six clauses. So these six items have been loaded into the database. And then you can ask queries, right? As I mentioned earlier, queries are going to start with question mark minus, right? In the Jupyter notebook, you have to explicitly type question mark minus. And then if you ask father Ned Sansa,

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

so the way to interpret this query is, is it, do you have a particular fact in your database, which says that Ned is the father of Sansa, right? So that's what you're asking. And because we've added that Ned is the father of Sansa, prologue is going to find that fact and is going to just say true.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

What it's saying is it is true that Ned is the father of Sansa, you know that Ned is the father of Sansa, because that is part of the database of facts that I built up. I'm asking whether record is the father of Sansa, is record the father of Sansa? No, right? So Ned is the father of Sansa. So if you ask this, prologue comes back and says false. So this fact is not true, is what it's coming back and saying.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

So one important thing about prologue is it only knows about the facts that you've given prologue, anything that you've not given, prologue just assumes that those are false, right? So this is known as the closed world assumption. So in the real world, there might be other things that are true, but as far as prologue is concerned, the only thing that you've told prologue is true, right? We know that Ned is the father of Bran, right?

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

Ned is the father of Bran, right? We have that relationship that is true, but I haven't told prologue that relationship, right? I've not told Ned is the father of Bran here. So if you ask prologue, right, whether Ned is the father of Bran, it comes back with false, right? It seems obvious here, it is good that it is obvious, you'll be surprised at certain results.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

And the reason is that anything that prologue doesn't know, it returns to the false, right? Yeah, so there is some interesting interactions with negation, we'll see later. But just assume that because you have a closed world assumption, only things that you have told prologue is true, everything else is false by default. So we can also do existential queries.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

Existential queries go beyond just true or false questions. You can also ask queries that return other answers. We've already done that when we looked at the length of the list, but here we are making it more obvious. So we are saying, okay, the way to read this query is I leave X as a variable. So the question that I'm asking is, who are Ned's children, right?

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

So Ned is the father of X, what are all the X's that satisfy this particular relation or this particular query? So if you run this, you get three answers, right? These are the three facts that I've encoded, right? The funny thing about prologue, right? So this looks like a function call. So I'm asking, okay, who are all Ned's children? It's like a function for which the argument is named

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

and the result is going to be undefined and prologue is returning multiple answers. But you sort of have to like forget this idea of calling a function running arguments, right? You drop it on the floor, there is no function argument in return. All you're asking is querying the program. So you can ask, there is no input and output, right? So there are only queries that you are asking.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

So yeah, the concept of arguments and results is blurred. You can even ask who is the father of Arya, right? So X is the father of Arya and prologue comes back and says Ned, right? And who are Rob's children is, you ask it like this. It comes back and says false because there are no X's that satisfy this relation.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

Rob with a constant, with a ground term, with a constant, right? But you can also do something like this, right? Get me all the satisfying relations that satisfies this very, right? And you get all of these results. So record is the father of Ned, record is the father of Lander and so on. So these are the six facts

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

that we've actually imported earlier. I'll put it back to one of those.  Yeah, so, so far, right? So, so far in this, in this particular example, running example, we've only added facts. So you might, you might sort of ask me, okay.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So, so far what you've done is you've said, okay, prologue and all of these fancy terms, but what you've done so far could be just achieved with the relational database. You load these facts into a database, right? SQL database, whatever, and then write a SQL query which returns who are the parents, who are the children and so on. So what is so unique about prologue, right? Prologue is much more powerful thanks to rules, right? Rules are, rules define further facts inductively

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

based on other facts and rules, right? So we've already seen an example of this. So rules are going to look like this. So there are only two things in prologue, right? You can define facts, you can define rules. So we've defined facts with this father relationship. Now we are going to look at rules and rules are going to always take this form where you have a head of a rule and the body of a rule, right, and we write it as H colon minus B1, B2, B3

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

with who are all, which are all comma separated, right? So that's the way you read it. And the interpretation of this is you read this, H is true, H holds, if B1 holds and B2 holds and up to BN holds, right? So H is true if all of these are true. It's the way you have to read a rule. So what is an example of a rule?

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

Here is an example. So I'm saying I'm defining a rule for parent, right? I'm saying X is the parent of Y if X is the father of Y. Okay, and I'm also defining a mother fact. So I'm saying Caitlin is the mother of Rob. And I'm also saying X is the parent of Y if X is the mother of Y, right?

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

So these are, so we call these, this is a rule because parent is defined based on other facts and rules, right, we only have one here. We say father and mother here, but the parent relationship is actually defined using father and mother. So that's a rule that is defined based on other fact. You can also define this notion of an ancestor, right? Ancestor is a relation which we define as X is an ancestor

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

of Y if X is a parent of Y, right? That is one, but ancestor also includes your grandfather, grandmother, great grandfather and so on, right? So we also include X is the ancestor of Y, ancestor of Y if X is the parent of some Z, right? I'm not going to define Z. X is the parent of some Z and Z is the ancestor of Y, right?

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

So we are adding one hop. So in order to say your grandparent, your father's father is the ancestor of yourself. We are saying your grandfather is the parent of your father and we say your father is the ancestor of you and that is satisfied with parent and because parent includes father, right?

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

So that's the definition there. There is a question in the chat and I'm going to try to answer that. Can you think of these rules as implications going from right to left? They are exactly implications going from right to left. Yeah, so that's precisely the interpretation and we will see the connections in the next lecture. So the way you look at it is it's B1, B2, Bn implies H. That's right.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

Actually, it's a good observation that will help you a lot, right? That is precisely what we are depending here. So we've added the five clauses, right? Clauses and the thing to observe here is Z is a variable that only occurs on the right-hand side of the rule. It doesn't occur on the left-hand side. So the way to read it is Z is an existential variable. So we are saying X is the ancestor of Y if there exists a Z such that X is the parent of Z

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

and Z is the ancestor of Y, right? This variable is existential and this will bring in interesting behaviors when we start looking at real programs. Okay, so now we can ask queries based on the rules that we've defined. So the query that I'm asking here is who are the dissidents of record, right?

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

Record is an ancestor of X and give me all the Xs that satisfy this relationship. So these are also known as goals, right? So in Prolog terminology, that's the goal that we have and Prolog tries to satisfy this goal. And if you ask this query, we get all the Xs that satisfy this goal. Okay, and this is precisely the six relationships that we have defined earlier.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

And as an exercise, you can define other relationships, try to define person and uncle and aunt and sibling, right? So I think it will be useful for you to just write some Prolog program because you'll have to get used to syntax anyway. I'm not going to evaluate any of this, but just try it in this notebook, it should work out. So here is a small question, right? Just to see whether you understood these concepts.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

So I have a few facts and rules. I have a fact that gold is a material, aluminum is a material. And I say that you can process bauxite into alumina and you can process alumina into aluminum, right? And you can process copper into bronze. And I define this rule called valuable. I say that X is valuable if X is a material and X is valuable if there exists a Y such that you can process X into Y and Y is valuable, right?

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

So the question is which of these are valuable? Don't think about whether they are valuable in the real world, just answer the question, thinking about the facts that we've told the Prolog. Is gold valuable? Yes, right, so we said valuable of gold

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

if valuable of material and we have material of gold, right? Is bauxite valuable? Yeah, because, yeah, so it is valuable because you can take bauxite process in the aluminum, which is a material. Is bronze valuable? No, right, because we only said the only thing that are valuable are material and the thing that you can process into a material.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

This we have not added the fact that bronze is a material, right, so that's why it's not valuable and neither is copper for the same reason. So you can ask these questions to Prolog. So I've added seven process. Then I'm going to ask whether gold is valuable, bauxite is valuable, bronze is valuable, copper is valuable. It's going to come back, but true true false words. Okay, I'll probably, I mean, this is,

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

I'll introduce this, but I'll come back to this later. So the way Prolog works underneath, right, so it has this idea of unification. This unification is the central idea that powers Prolog, right, and we've seen this unification earlier. Then we looked at type inference, right, type inference and OCaml, we've just done unification without giving it a name.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

Whenever we had a type variable, right, and we said, okay, I'm going to use this function, say, which takes an alpha to alpha, and I'm going to apply this on some integer, then this particular alpha, right, if you take an identity function, which is an alpha to alpha, and apply this identity function to an integer, this alpha is going to be specialized to an integer, right, and because the argument is an integer, the result is also going to be an integer. So this idea of unification is basically saying,

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

okay, I have some variables, and then I have some concrete instances that can satisfy the variables, and if you have a constraint where the variables appear at multiple times, when you unify a variable with a ground term, you replace all the instances of that variable with the ground term as well. We've done this in OCaml when we had polymorphic types, and that is precisely what powers Rolog as well, right,

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

and in Prolog, we have three rules for unification. So atoms unify if they are identical, right, the lowercase things are atoms, so A and A unifies, but not A and B, because these two are two different constants. Variables unify with anything, so if you have any variable, you can unify it with anything else, right, and compound terms unify with other compound terms,

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

if they are top function symbols and the arities are the same, and their arguments match, unify recursively, right, so we will come back to this again, but the intuition that you should have in your mind is this unification is very similar to how polymorphic function types and data types, polymorphism works in OCaml, right, it'll be very natural when you have a look at this

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

in the next class. So yeah, okay, I'm going to stop here, I'll come back to this. So you have a break from first to fifth, so no class on Friday and no class on Monday as well, right, and we will meet on Tuesday, so have a reasonable, reasonably good break, try to take a break, I'm hoping that you don't have too much to do,

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2888.5s_

and we'll meet on Tuesday, okay, okay, so any questions, otherwise I'll stop here.

---
