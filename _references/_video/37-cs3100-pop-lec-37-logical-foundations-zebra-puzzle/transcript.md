# 37-cs3100-pop-lec-37-logical-foundations-zebra-puzzle

**CS3100 POP - Lec 37 - Logical Foundations + Zebra Puzzle**  
id: `qd-rn-zuFXo`  
duration: 2976s  

![slides/scene_0001.png](slides/scene_0001.png)
_t = 0.0s -- 63.2s_

Okay, wonderful. So what were we doing in the last class? So you're looking at logical foundations of Prolog and we looked at this way of computing the answer to the query ancestor, Richard Rob, which used SLD resolution in order to find the query, right? So in order to find the, whether the query is part of the least head brand model of the program. And we sort of went through it by hand. And the high level takeaway from that particular exercise is that in Prolog, unlike other languages, when a Prolog program computes, it is actually doing logical reduction, right? So when you ask a query, what it's trying to do is to answer question about satisfiability, right? And it's a really interesting model of computation

---

![slides/scene_0002.png](slides/scene_0002.png)
_t = 63.2s -- 126.3s_

that is different from how all of the other models of computations that you've possibly seen so far, right? And this sort of computation is common to all the logic programming languages. But in our example, we picked a particular form of logical reduction through SLD resolution. In particular in SLD resolution, what you do is you take the program in the order in which it is written, and we search for matching unifying clauses in the order in which they appear in the program, right? And whenever we found a matching clause, we did the depth first search for proof, right? Until we hit the result. And then finally, what we did is when given a conjunction of goals, essentially we saw a conjunction when we had a ancestor query, which involved a parent and an ancestor, recursive called ancestor. We depth in depth first order,

---

![slides/scene_0003.png](slides/scene_0003.png)
_t = 126.3s -- 189.5s_

explore G1 and then explore G2, right? So SWA Prolog, which is what we are using in this course, is one Prolog implementation, and it picks the reduction, performs the reduction using this algorithm, right? But other Prolog implementations may choose to adopt different strategies. Say instead of depth first search, they can use breadth first search. Or when you're given multiple goals, it may choose the last one instead of the first one as well. So each of these leads to different results being observed, actually, in particular, because we have certain features in Prolog, which don't really nicely fit into this logical framework, but are still useful. So at those places, you will see the difference in the order in which you resolve the computation matter. So the height of a takeaway is

---

![slides/scene_0004.png](slides/scene_0004.png)
_t = 189.5s -- 252.7s_

computation is reduction, right? Let me, so there's a question. Let me try to answer that. So Srisha asks, does Prolog remember memoized facts along the way? So it does remember where it is in the search tree, right? So it's searching, so it knows where it is searching through and it applies unification, right? So there is no need for, it doesn't do explicit memoization, all it does is certain unification. So if you have certain variables, which you found an answer to, and that's like a constraint, right? And if you satisfy that constraint along one path, it remembers that path in that branch. But sometimes it may so happen that you've gone down the wrong path, and you have to come back. At that point, you need to, you need to sort of erase your unifications that you've done. This is known as backtracking. We will see all of this later, but Prolog doesn't do explicit memoization

---

![slides/scene_0005.png](slides/scene_0005.png)
_t = 252.7s -- 315.8s_

of facts along the way. It simply does a search through the program, right? And it knows where it is in the search tree. They're essentially building a huge tree of search and it knows where it is. We will look at all of this when we actually work through certain examples by hand. We'll go through it in the coming lectures. Okay, so the thing that we did in the last lecture, is we took this program and we sort of traced through this program by hand, right? And SWA Prolog has a tracing facility built in. This is not exposed in the Jupyter Notebooks, but it's still useful for debugging programs. So I'm going to show you how to do this tracing in SWA Prolog. So let me, so if you, let me exit from full screen first.

---

![slides/scene_0006.png](slides/scene_0006.png)
_t = 315.8s -- 379.0s_

Okay. Are you able to see this? I'll make it bigger. Can someone confirm whether the font size is okay? Yes sir, we can see. Okay, wonderful. So when you start your Docker container, right? The first thing we do is start the Jupyter Notebook, but the other thing that you can do is actually run any commands in the shell. So one of the things that have been installed in the Docker container already is the Prolog interpreter. So if you say, I think I already have a Docker container running here. But if you just start the Docker container and then type SWAPL, you'll see something like this. So this is the Prolog interpreter that's running.

---

![slides/scene_0007.png](slides/scene_0007.png)
_t = 379.0s -- 442.2s_

And what we are going to do is to try to run this program by hand. So when you run the Prolog interpreter, right? So it prints out something and then immediately stops at question mark minus. So essentially it is waiting for your query to be answered. Initially when it loads up, it doesn't have any facts or rules loaded up. So let's first input the program. So one way of inputting the program is actually typing out the program directly in the interpreter. You can also load files. You will look at it a little bit later. But the way to input the program by hand is you type this command user dot. And then if you press enter, you enter this mode where you can type the program. And what I'm going to do is to copy all of the facts and rules. I'm going to paste this here. Yeah, everything is pasted.

---

![slides/scene_0008.png](slides/scene_0008.png)
_t = 442.2s -- 505.3s_

And then the last thing that you do is if you press control plus D, I press control D and the Prolog says that this program has been compiled with nine classes and it prints true, but all it says is, okay, it's loaded up the program. Now we can ask the query, right? So this is the query ancestor Likertrog. If you ask the query, it's going to come back with true. We know that Likert is the ancestor of log. So what we want to do is to trace through the program. Let's trace through the program. So the way tracing is enabled is there is a query called trace, it's like a meta query. A Prolog knows about this query. So it is essentially a query, but it has some side effect. In particular, it turns the tracing facility on, right? So this says traces on here. So now let's do the same query as earlier. Okay, so if you do ancestor Likertrog,

---

![slides/scene_0009.png](slides/scene_0009.png)
_t = 505.3s -- 568.5s_

Sreesha, you're unmuted, can you mute your mic? Thanks. So now I'm tracing. Okay, so what is happening now is I'm actually going through the program step by step. This is replay, that's okay, Sreesha, totally fine. So what is happening now is we are going to trace through the program step by step. So the first thing that we asked is this query, right? Answers the Likertrog. Prolog says that I'm going to call ancestor Likertrog. And what call says is I'm going to try to satisfy this goal. And it stops there. What is going to happen when you, let me make this bigger. Oops. So what is going to happen when you ask ancestor Likertrog is it's going to search through all of this. It is going to find the first matching,

---

![slides/scene_0010.png](slides/scene_0010.png)
_t = 568.5s -- 631.7s_

first unifying rule where it can satisfy Likertrog. That'd be this one.  That'd be this one. And it's going to try to change the goal to parent Likertrog, right? So if you press enter, you can see that the call now is now at parent Likertrog. It is now here. And now if you go through it again, parent is going to lead to farther xy, which is farther Likertrog. If you press enter again, now this is going to be farther Likertrog. And Prolog is going to search through all the facts in the order in which they are presented and observe that there is no farther Likertrog fact in our program. So what Prolog is going to do is go all the way to the end and then fail, right? If you press enter, so it says that, oh, this particular call has failed because I couldn't prove this particular fact, right? I couldn't find any unifying facts or rules that can satisfy this. So I'm going to fail.

---

![slides/scene_0011.png](slides/scene_0011.png)
_t = 631.7s -- 694.8s_

So when you fail farther, you also fail this parent rule, which was the recursive rule. You also fail the ancestor rule. But for the ancestor rule, we have another option, right? We only tried the first option. We're going to try the second option. So which is why Prolog says redo, right? It's redoing that particular goal and it's going to take a different path now. It's going to take the second path, right? And the second path has two sub-goals, parent and ancestor. In SLD resolution, which is what Prolog does, it is going to pick the first one, right? So if you, but observe that there is a Z here, right? There is no Z on the left-hand side, but there is a Z here that's an existential variable, right? So we don't know what the result for the Z is. There is going to be some Z. What Prolog does is it will just rename the Z to some arbitrary variable so that it can keep on going and find a unifying satisfying thing.

---

![slides/scene_0012.png](slides/scene_0012.png)
_t = 694.8s -- 758.0s_

So we'll see how it works. So if you call this, observe that now there is a parent record underscore 9534, which corresponds to the Z. All Prolog does is it renames every existential variable so that it creates fresh variables so that there is no conflict in those fresh variables, right? This is something that we've done earlier, if you remember when we did substitution, the idea is quite similar. So it's going to continue searching for this, right? Parent goes to what happens in the next step, parent goes to father, right? Parent goes to father and father record this variable 9524 unifies with the first fact, right? There is a fact here which says father record raw, record net and that unifies. So if you press enter, observe that we have this new thing called exit, it certainly says that, oh, I have, now I was trying to prove

---

![slides/scene_0013.png](slides/scene_0013.png)
_t = 758.0s -- 821.1s_

father required some variable. I found a matching fact, right? And that fact had net as the variable. So I'm going to unify 95, underscore 9524 with net. So that's why it prints father record net. And when it steps out, you also see that this step here that corresponds to nine, nine nine is the nesting level. That also corresponds to because we unify 9524 with net, this 9524 is also net. And if you step again, so we've unified that existential variable with net, right? And that's the same existential variable that appears on the second subgroup. So we know that the value of z is net. Now let's try the ancestor. So there also we replace that underscore 9534 with net. And we know why is rob, right? So that's why we get net rob. And this goes through parent and that goes to father.

---

![slides/scene_0014.png](slides/scene_0014.png)
_t = 821.1s -- 884.3s_

And we see that there is a father net rob fact. So that will exit. And now we are at ancestor, we returned to our original question, we exited. So that our complete goal is proved now, right? So we've satisfied, we found a, we asked a query whether this is satisfiable, it is satisfiable. So let's, and we are done. So prologue just says, okay, that's true. And it exists. So this is how you can do tracing within prologue. So, yeah, okay. So, and the last thing that I want to show is you have tracing on, you can turn off tracing by this query call node race, which gets you into this debug mode. Debug mode does not print out the results, but disable certain optimizations.

---

![slides/scene_0015.png](slides/scene_0015.png)
_t = 884.3s -- 947.5s_

Which we will also see later. But if you want to get back to how it was earlier, there is a query called node debug. You always need a dot at the end. Okay, so remember that you need a dot at the end. And you press node debug, you're back at where you started. Okay, the tracing is turned off. Yeah, okay, so that's how we trace programs in prologue. And this perfectly matches the way we work through the example. Any questions on this so far? Oh yeah, okay, let's do that. For the RecurDx. So let's first query this, right? So there are multiple solutions for this. Actually, no, why not?

---

![slides/scene_0016.png](slides/scene_0016.png)
_t = 947.5s -- 1010.6s_

Okay, there are multiple solutions for this. Let me say how this works. So when you type further recurNet, prologue sort of stops here, right? The reason why prologue stops here is it's saying, I found one result, I have other results, do you want to continue? If you press enter, you're saying, I don't want to see any other results. You can press semicolon, okay? I think semicolon is the right key. So if you press semicolon, it prints more and more results until it runs out of results and then it comes back. So your question is what happens if you trace, you can trace it. Let's try this. So we are asking for the X, right? So we have an existential variable there. So this is going to be satisfied with the first option.

---

![slides/scene_0017.png](slides/scene_0017.png)
_t = 1010.6s -- 1073.8s_

And when you press enter, this is going to erase the fact that you went down one path and it's going to dry again, right? So this is what is happening. Do we have a redo for existential variable? I think this is what you're asking, I think, Kamal. We've explored one path, we have satisfied, we forget the fact that we did unification, right? So this is known as backtracking. We'll come back to this later. This is sort of, when you have multiple choices where you perform unification down one path, you also have to undo unification when you come back and try other paths. That's what is happening here. If you don't understand this, that's fine. If you develop an intuition for this, that is also fine. You look at it in detail as we go through the lecture. But this is what is going to happen, right? So it finds the second one, it stops saying, I found a satisfying X random, if you press semicolon again,

---

![slides/scene_0018.png](slides/scene_0018.png)
_t = 1073.8s -- 1137.0s_

it goes through and read us a thing and finds Leona and then prints and exits. Okay, I think I've answered both of your questions. So any other questions? No. How do I put it? No, it's not doing any memoization. So if you ask again, and it's not visible here, but it's actually running everything again. But you can imagine memoizing it, right? So of course memoization is a useful optimization and real implementations would, can and would memoize the results. But I don't know whether it's the way it's prologue this. I don't think we will ever write a program that, where you can actually measure time. Good question.

---

![slides/scene_0019.png](slides/scene_0019.png)
_t = 1137.0s -- 1200.1s_

I think it's an important optimizations, but I don't think we are doing memoization here. Anyway, okay. So, yeah, okay. So let me switch back to the lecture. Yeah, if you want to look at the commands, there's an image of this here, and you can find out what the commands are. And that concludes the logical foundations lecture. So let's move on to the next lecture. So what we're going to do in this lecture is, we're going to try to show like a simple use case for prologue. So this is solving, oops. This is solving a logic puzzle,

---

![slides/scene_0020.png](slides/scene_0020.png)
_t = 1200.1s -- 1263.3s_

and it's a fun problem. I think we'll go through this and I think you will appreciate this puzzle. So some of you might have already seen this puzzle in one of your earlier classes. So have you heard of the Zebra puzzle? Anyone? Yes, no. So we are going to look at solving the Zebra puzzle using prologue. So for queries with, so Vishnu has a question. For queries with existential variable, does prologue try to deduce for each constant? If so, what will happen if the headband base is infinite? Really good question. So that's what gives us non-termination. So we will have examples where you will see that there are infinite number of answers for certain questions. And prologue execution will be infinite. An example of this is,

---

![slides/scene_0021.png](slides/scene_0021.png)
_t = 1263.3s -- 1326.5s_

give me all the last elements of a list or something, and then you replace both the list and the last element to be a variable. And of course there are infinite number of questions, infinite number of lists, and infinite number of last elements that can satisfy this. So yeah, so it does go into, if there are infinite number of results, it gives you infinite number of results. And we will look at the base of sort of saying, give me the first 10 results or something. Okay, coming back to the question that I asked, has anyone, does anyone know the Zebra puzzle at all? No? Okay, I thought you have covered this puzzle in one of the earlier classes. That's what I remembered from the last year. Anyway, it's a very simple puzzle. Okay, so what we're going to do is to solve this puzzle. This is like a classic newspaper style puzzle. The puzzle itself is here, right?

---

![slides/scene_0022.png](slides/scene_0022.png)
_t = 1326.5s -- 1389.6s_

And there is this 15 facts. Okay, so it's describing a set of houses and a set of properties about people who live in each of the houses. And we're going to ask a question about who drinks water, who owns the Zebra. Like the facts are there are five houses. There is an Englishman who lives in the Red House. The Spaniard owns a dog. Coffee is drunk in the Green House. Ukrainian drinks tea. Greenhouse is immediately to the right of the Ivory House. Old gold smoker owns snails. Cools are smoked in the Yellow House and so on. Like there are lots of facts like this. And these are essentially constraints, right? There are five houses and each fact is a constraint that is sort of restricting the set of possibilities for what the houses can be. And these constraints are sufficient to figure out who drinks water and who owns the Zebra.

---

![slides/scene_0023.png](slides/scene_0023.png)
_t = 1389.6s -- 1452.8s_

You can work it out on paper. I don't think this is a difficult problem, but it's nice example to sort of show prologue execution. Okay, so how do you take this puzzle and then convert it into a prologue program? So this is one way of doing it. This is not the only way. Of course, you might think of other ways to do it, but let's look at how we've done it in this lecture. So we have the fact that there are five houses, right? And there are some facts about the people, I mean, each of the houses, right? What are the facts? There is a notion of a nationality of a person who lives in the house, right? Englishman, Spaniard, Ukrainian and Norwegian, Japanese, right? And then each house has a color. Red is one, I think green is another one. Each house, there's a pet in each house.

---

![slides/scene_0024.png](slides/scene_0024.png)
_t = 1452.8s -- 1516.0s_

There's a dog in this house. I think there is a cat somewhere, snails. I don't know why you would keep snails as a pet. Ours is kept here, right? And then there is a drink that is drunk in each of the houses. And there is a brand of cigarettes that is worked in each of the houses, right? Old, cold, cools and so on. So those are the five properties. And we also have some spatial information about the house. So there is this constraint of right of, right? Green house is immediately to the right of the ivory house. Milk is drunk in the middle house. Norwegian lives in the first house. Cools are smoked in the house next to the house where horses kept and so on. So there are some properties, there are some spatial information. Let's try to put it all together in a prologue program. So as I mentioned, each house has five characteristics. Nationality, pet, smoke, drink and color.

---

![slides/scene_0025.png](slides/scene_0025.png)
_t = 1516.0s -- 1579.1s_

We know that these are all the five characteristics, right? So we can define a house as a function, right? Which has these five properties. So houses are a compound term, right? With five properties. And we will represent the street, a row of houses as a street with H1, H2, H3, H2 and H5.  So that's our basic representation. So a few questions. What sort of a term is this house? Nationality, pet, smoke, drink, color. Observe that I'm using capital letters here. These are variables, okay? What sort of a term is this? Is it a number? Is it a compound term? Is it a variable or a constant?

---

![slides/scene_0026.png](slides/scene_0026.png)
_t = 1579.1s -- 1642.3s_

Yeah, compound term, right? So, okay. What sort of a term is this? You don't have a top function symbol, but you have a tuple, which is five things. Assuming that this is a well-formed prologue term, right? What sort of a term can this be? Take it from me that this is the correct prologue program. No, it's a compound term. So the reason why this is a compound term is that it's a tuple, right? In prologue, tuples are compound terms without an explicit function symbol. So you can sort of think about tuples as tuple zero, tuple one, and so on.

---

![slides/scene_0027.png](slides/scene_0027.png)
_t = 1642.3s -- 1705.5s_

I mean, I haven't told you this, but so this is a, the top function symbol is sort of like a tuple with five things, right? And those five things are the five variables. So this is a compound term, okay? So that's the answer. Okay, okay, the first thing that we are going to do is we're going to assert some facts, right? We're going to say Englishman lives in the Red House and so on. And we want to say something like, there exists a house in the street where the Englishman has a Red House, right? There exists a house in the street where some ivory house has some snail or something. So the way we are going to capture that is define a predicate called exists that capture this fact, right? And there are five houses in the street. So we are going to have five facts. The way to read this fact is there exists a house A

---

![slides/scene_0028.png](slides/scene_0028.png)
_t = 1705.5s -- 1768.6s_

in the street of houses. If what is the predicate? It has to be one of these five, right? And we have five facts for each of these five positions. So we say A exists in the street if A is in the first position in the street. A exists in the street if A is the second position, third position, fourth and fifth and so on, right? So this is an easy way of saying that a house exists in the street, right? So we have five clauses added. So let me make this bigger. So we are asking whether H1 exists in the street. What is going to be the result of this query? It's only going to say true or false, right? It's true or false.  Yeah. And H2 is also true. What about the last one? H6 is in the street with H1 text.

---

![slides/scene_0029.png](slides/scene_0029.png)
_t = 1768.6s -- 1831.8s_

H5 false. Yeah. So you don't declare anything under Go-Camel, right? Where you have to sort of say, oh, I'm going to use the street. I'm going to use existence. So on you just define facts in prologue. In that way, there are no types in prologue, right? Everything is untyped except for the fact that you have compound terms, you have predicates and you have constants and variables. That's all the things that you have. So you can happily start writing your program in this way.  So let's another quiz. So which of these queries returned true? So does the first one return true? Okay. So there's a question in the meantime. How to differentiate predicates and functions in prologue? So good question. So predicates are what appears

---

![slides/scene_0030.png](slides/scene_0030.png)
_t = 1831.8s -- 1895.0s_

as the top function symbol in a fact, right? So here when I write exists and I have a dot at the end. So exists is a predicate that has arity too, right? And yeah, that has arity too. And a predicate can also appear here. So you can have P1, some number of arguments say ABC, right? And you can have P2, something, P3, something else, right? So P1, P2 and P3 are predicates, right? They appear either as a fact, I mean, they appear as the head of the rule, right? And they also appear in the body, right? As the top thing. So these are predicates and functions are the things that can only appear here, right? Of course, we don't sort of say,

---

![slides/scene_0031.png](slides/scene_0031.png)
_t = 1895.0s -- 1958.1s_

if you define, so street is a function here, right? Street appears within a predicate, but I can also write a street of zero, right? For whatever reason, I write street of zero. Roll-off will accept this, right? Roll-off will say, okay, this is fine. This street is a function because it appears within the body of a predicate, right? This street is an actually a predicate. So roll-off doesn't distinguish that way. The thing that cannot happen is you cannot have predicates in the body of a predicate. Okay, so you can only have predicates at the top level. I said sort of answer your question. I don't think I, I did a good job of explaining it, but okay, so you will sort of, the things that appear within, right? Those are functions. Those are like function symbols, right? These are compound terms, really.

---

![slides/scene_0032.png](slides/scene_0032.png)
_t = 1958.1s -- 2021.3s_

So you can think of them as constructors, essentially, in OCaml. So they're a way of constructing some data, and these are actually facts and rules that we assert. So, okay, so going back, right? So this is the first one true. So there exists a dog in the street, right? True, okay. So what about the second one? There exists a dog in the street. Yes, okay, good. So false is the answer because the arity is different, right? We define street. The exists fact is applicable to a street with arity five. There always have to be five arguments, right? If you define it with four,

---

![slides/scene_0033.png](slides/scene_0033.png)
_t = 2021.3s -- 2084.4s_

that's not going to be unified with anything. This is simply unification at the end of the day. What about the exists a dog? False, okay, good. So the last one is there exists a house, English read in a street, and it's not very readable, but there are five houses here. And the last one is house English, comma, underscore. True, right? So because these two unified together at the end of the day. So English unifies with English, and read unifies with underscore. Underscore is a variable that unifies within. Okay, good. Yeah, okay, so that's what I wanted to say. And we had this spatial predicates, a few spatial predicates, right? So we said what is the relationship between the houses in terms of where they are located? So we had this fact called fact number six, which is greenhouses immediately to the right of the ivory house.

---

![slides/scene_0034.png](slides/scene_0034.png)
_t = 2084.4s -- 2147.6s_

So we're going to define this predicate called write of. The way to read this is A is to the right of B, right? In the street, if you have this configuration, so which is that B is the first one, and A is the second one. So A is to the right of B. And there are other positions as well, right? So B is the first element, and B is the second element, and B is the third, and B is the fourth. So there are four possible facts for this. And essentially the way you read it is A is to the right of B, if the street has one of these configurations. Okay. And that's a predicate that we defined. We also have the middle house and the first house. We say A is the middle house in the street of A appears in the middle. And A is the first house in the street of A is the first house in this list. And we also have this next two predicate, right? Ghouls are smoked in the house next to the house

---

![slides/scene_0035.png](slides/scene_0035.png)
_t = 2147.6s -- 2210.8s_

where horse is kept. Norwegian lives next to the blue house. So we define next two in this way. So we use both the rule as well as four other facts. So we say that A is next to B in the street S if A is to the right of B in the street S. Because we had already defined right of, right? So we are saying A is next to B, if A is to the right of B. We haven't defined left of earlier. So all we are doing here is we are also stating that A is next to B if A is to the left of B, right? A is next to B if A is to the left of B in these four positions. So that's defined. We've added five clauses. And okay, so now I think we've expressed all of the required structure to express the problem.

---

![slides/scene_0036.png](slides/scene_0036.png)
_t = 2210.8s -- 2273.9s_

So this was the original puzzle, right? And this is going to appear as a query that looks like this. I'll keep it smaller because I'm going to switch back and forth. So we say that there exists a house which I mean, this is the Englishman, the nationality is British. A British person lives in the red house in the street, right? And this is the second of the facts, right? The first fact is encoded by the fact that there are five houses. So we fix the street to have R85. So Englishman lives in the red house, is converted to this British person. The color is red. There is house with British person in red color in the street. And similarly, we say the Spaniard who has a dog is in a house that exists on the street, right? So that's what we say here. The Spaniard who owns the dog.

---

![slides/scene_0037.png](slides/scene_0037.png)
_t = 2273.9s -- 2337.1s_

Coffee is drunk in the greenhouse is coffee green. There's a house called coffee in green and it exists in the street. And let's look at say, cools are smoked in the house next to the house where horses get, right? So that's fact, well. So there's a house where cools are smoked, right? Which is next to the house, next to the house where the animal horse lives, right? In the street. So the thing that, I mean, this is what is happening with all of the other facts, right? You can sort of go through it one by one in your own time. The thing that we are doing here is all of these are constants, okay? These are all constants. We use the same street variable here. What essentially happens is there are lots of possibility for the values of the street, right? And by adding each one of these constraint,

---

![slides/scene_0038.png](slides/scene_0038.png)
_t = 2337.1s -- 2400.3s_

we are sort of constraining the shape of the street, essentially. And the observation is that with all of these facts, there is a single street where you can know for each house, what is the nationality, what is the pet that lives there and so on. Okay, so when you execute this query, the street will be unified to something where all of the facts are obvious, right? And now the actual query, right? Who drinks water, who wants the zebra is expressed this way. So I use the variable water drinker, right? I want to find out the nationality of the water drinker. So I'm placing this variable in the nationality position. The drink is water, right? I'm saying there exists a house in the street where water is drunk. And I'm going to use the variable for the nationality of water drinker.

---

![slides/scene_0039.png](slides/scene_0039.png)
_t = 2400.3s -- 2463.4s_

And similarly for the zebra owner, right? In the street. So once the street has been fully described because of the constraint, it becomes fully ground, it becomes a ground term. There can be only one water drinker and one zebra owner, right? So that's the observation here. And if you execute this query, you get the result. So you get the configuration for, there are three variables, right? There is a street variable, there is a water drinker and zebra owner. The street variable is unified to the actual configuration of the house. And we see that the water drinker is the Norwegian and zebra owner is the Japanese person. Okay, so that's the way you solve this query puzzle. What do I have here? So any questions on this one?

---

![slides/scene_0040.png](slides/scene_0040.png)
_t = 2463.4s -- 2526.6s_

Okay. Yeah, okay. So if there are no questions, I'll continue. You can ask, of course, you can ask questions later. So the observation here is we added all these constraints, right, that constrained the house to a single result. So the constraint, the street to a single result, there is only one possibility for the street. But if you give fewer constraints, then there are possibly multiple different street configurations, right? So this is what we see in this example. So the above query leads to exactly one street configuration. With fewer constraints, there are many more possibilities. So here I have a query where I say there exists a house with the British person, red house, right, in the street. And the Spanish Spaniard who owns the dog is also on the street. I'm not defining anything about the other houses, right? And I'm not defining anything about spatial positions of these houses so they can be anywhere.

---

![slides/scene_0041.png](slides/scene_0041.png)
_t = 2526.6s -- 2589.8s_

So for this query, there are 20 different solutions, right? And 20 different solutions because there are five houses. There's one British red house, one Spanish house with the dog, right? And three other houses are undefined. So you can work it out, right? So there are 20 different results. If you run this program, you get by default 10 results. Okay, so one, two, three, four, five, six, seven, eight, nine, 10, right? And the Jupyter notebook touches the end results and just stops, right? If you want it more than 10 results, we have a handy way to get more results. So we use the syntax with braces n, right? So we use curly brace n. And the idea is that for a query, if you use curly brace n at the end, it prints n results, right?

---

![slides/scene_0042.png](slides/scene_0042.png)
_t = 2589.8s -- 2652.9s_

If the number of results is less than n, it just prints up those results and stops. If it is more than n, it prints n results and stops. I should say that this is specific to the Jupyter notebooks, right? As we saw earlier, the interpreter prints one result, wait for your input, waits for your input. You have to press semicolon to get it to print more results. But here you can just ask for say 40 results. We only have 20, but let me ask for 40. Prints the 20 results. Let me make it smaller. Oops. Yeah, prints the 20 results and stops. You can work it out in your own time. So the key takeaway is if you wanted to see just one result, you can just give one here. Or if you wanted more than one, you can do more. This will come in handy later.  And Aman has a question.

---

![slides/scene_0043.png](slides/scene_0043.png)
_t = 2652.9s -- 2716.1s_

What is the sixth one? If I have, in the query, it's six. I don't know, I can't pass this question. Maybe you can ask the question, Aman. So like in the query, exist only can have, like the state can only have five houses, right?  If I give like a six exist queries, so like set most configurations, will it give error or will it unify? It'll just say false. It says that it will return new and say, oh, I don't have a house which satisfies that. Let me try. I think, it should give false, right?

---

![slides/scene_0044.png](slides/scene_0044.png)
_t = 2716.1s -- 2779.3s_

I mean, this is the, the notebook is behaving differently. It essentially says, okay, I can't, I can't, it will say that I can't find the sixth house. So I can't satisfy our query. So the query is not satisfied. It is just like asking a query which is not true, right? So if it cannot satisfy, it just returns false. Yeah, I need to restart this thing. Anyway, so that's the idea. I want to show a different way of encoding this, right? The observation, if you sort of look at this, I encoded everything as part of the query itself, right? Both the problem and the actual query that I wanted to solve is all part of a single query here. So you can organize it differently. You can say the puzzle is defined over a street, and the puzzle has all of these constraints, right?

---

![slides/scene_0045.png](slides/scene_0045.png)
_t = 2779.3s -- 2842.4s_

It has one of these clauses. And you can now say with this puzzle street, which brings in all of the additional goals, right? It brings in all of the constraints. In which house, like who is the zebra owner, right? So there is a house where there's a zebra owner who owns a zebra. What is the value, satisfying value for the zebra owner in this street? And if you do this, you get that the zebra owner is Japanese and similarly for the Norwegian. Yeah, this is just a different way of encoding it. Why did we not describe the initial queries as facts? So good question, right? So we are not describing them as facts because we want to have the same variable to be used in all of these.

---

![slides/scene_0046.png](slides/scene_0046.png)
_t = 2842.4s -- 2905.6s_

We want the same variable to be unified across the different facts, right? If you describe one fact, if you display another fact, right? If you use the same variable, I think they are implicitly different facts. They are not unified together because if you look at the way prologue proceeds, right? It is not considering who facts together. It's considering one fact and then considering the second fact. The only way to take a variable and unify the variable across two different facts is to have it with this comma, right? Comma is disjunction and we say that, sorry, comma is conjunction. And what we are explicitly asking is, this street variable is the same variable that is used across both of these goals, right? And that is what gives us the satisfaction, right? So that is what gives us the way to satisfy each of these street variables

---

![slides/scene_0047.png](slides/scene_0047.png)
_t = 2905.6s -- 2968.8s_

to be unified with the same thing. If you give it a separate facts, it won't work. You can try it out, right? And the intuition is that these, that's not the way prologue works, right? SLD resolution looks at a single fact at the time. There is no way, if you give it as multiple facts, it will just look at them as individual facts. Okay, so moving on, I think that's the logic. I think we are right on time. Any other questions on this lecture? Okay, so if there are no other questions, what we'll do in the next class is we'll start looking at lists and we'll dig a little bit deeper into how prologue works with infinite programmers, right? So of course prologue has non-termination, what are the implications and so on. So we will start looking at it from Monday. Have a good weekend, bye-bye.

---

![slides/scene_0048.png](slides/scene_0048.png)
_t = 2968.8s -- 2968.8s_

_(silence)_

---
