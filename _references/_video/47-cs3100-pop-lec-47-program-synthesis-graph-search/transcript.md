# 47-cs3100-pop-lec-47-program-synthesis-graph-search

**CS3100 POP - Lec 47 - Program Synthesis + Graph Search**  
id: `He2hjyDCrzc`  
duration: 3429s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so before I continue, any questions on the stuff that we had seen yesterday?

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

No questions. Okay, so in which case we will continue with what we are doing, right? So to give a summary, what we were doing is we had this type checking procedure that we had seen as part of simply lambda calculus. And what we had seen is if you encode the type checking procedure exactly as it is defined, right, without any additional word, infrolog, you get type

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

inference for free. For example, we can get the type of we can even get the type of polymorphic functions such as lambda f lambda x fx. I think I just okay, so I need to run the previous is I might do that in the background. Let me do that. So you can run you can. Okay, so let's let this

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

run in the background that are going to be a few cells, which are going to take a few 10s of seconds to run. But anyway, so we can get polymorphic types out for free, right? So the idea is that we have this type predicate, which takes a term, right, a lambda calculus term, and then gets you the type.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

But as we have seen, over and over again in prologue, right, so there is no input and output, all you're doing is querying the program. So the question interesting question is, what if I give the type, but make the program available? And what prologue will the question sort of says that, find me all the programs that satisfy a particular type? Right. And and this is, this is quite a

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

curious notion of programming, essentially. And this is this is this broader concept of coming up with programs, according to some specifications is known as program synthesis, right. And in our particular case, the specifications happen to be types. So we say, Okay, what is that program? Give me a program that will satisfy this type. And, and what we are going to do in the rest of this

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

lecture is going to generate lambda calculus programs, right, in the same language that we've seen so far, which we will generate according to a particular type that is given. And as you can see, right, so we have this notion of the most general type for a particular program. So we can say, okay, if I give you a program, there is one best type for a program. But if you think about the

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

question flip, you flip the question, if I give it type, is there one good program that has the type? And what is the definition of good then, right? So because the programs might have different behaviors, so you can have all sorts of interesting programs that return an integer. So it is not not clear whether there is one program that you can generate. And the programs may be large and small, right. So the simplest program that I can think of for an integer type is just the program

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

with zero, right? The expression is just zero, that has type integer, but you can also have a program that computes the Fibonacci number of like 100 Fibonacci number, right? That also returns an integer. And that also satisfies the specification, which is just give me a program that satisfies the type integer. So because we have a large class of these programs, what we will do is we will say,

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

okay, rather than getting me all sort of programs, because the tree of possible programs is infinite, right? So what we will try to do is to apply our iterative deepening technique that we learned earlier in class, that we found the closest answer to this countdown puzzle. So here, what we will do is we will find the smallest program that will satisfy a type. By smallest,

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

I define the size of a program to be the depth of the abstract syntax tree, right? And for an expression zero, the depth is zero. And if you have complex expressions, you'll have a greater depth. So what we'll do is this. So we will ask for a lot to generate programs, small programs first, and then bigger and bigger programs as we go along, right? So that is what we are going to do. Yeah, so as I mentioned, we are going to use the depth of the abstract syntax tree of the terms,

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

right, in order to iteratively search starting from depth zero. So this is going to combine all of the ideas that we've seen so far. So in order to compute the depth, what we're going to do is start from some depth n, and that every step, we're going to decrease the depth, right? So in order to do that, I define this predecessor predicate, which holds if b is the predecessor of n, right?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

And this is defined just as you would imagine it to be defined. So if n is greater than or equal to zero, then p is n minus one. So that's there, we define predecessor. Now, we are going to iteratively deepen our search space, right? So the thing that we want to do is to add this notion of depth to our type checking rules. This is very similar to how we did the delta in the countdown example,

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

all we're going to say is every rule now takes this additional depth. Okay, and what we are saying is, let's look at this rule now, right? So let's start from arrow elimination. So this used to be a rule before. So it says that it gives the type checking rules for applications. In order to assign

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

the type b for m applied to n under gamma g, right, show me that m has type a, r, o, b, right, for some a, m has to be a function type, and n has to be of type a, right? This is what we have seen earlier. And what is the new rule augmented with depth? So we have this d parameter extra, right? We say the type of application of terms m to n under gamma has type b with depth d. If d, d is the

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

predecessor of d, right, we decrease d by one, that's d, d. And we can show that under the, we use the depth d, d for the recursive terms. Essentially, we say that for type checking, we will only explore up to certain depth. And because pre-decisor of zero is not defined, that particular property will not hold, we won't infinitely, we won't go for the depth beyond zero,

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

right? So the idea is that our type checking pre itself is proved at a certain depth. And this is how we sort of iteratively explore. So we, and this is the same idea in all of the places. For example, if you start, if you want to type check, if you want to check that first of m, the term m has type a under the gamma d, then you compute the predecessor,

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

d, d of d, right, that is one less than the current depth. And show me that m has type, some pair type with an a, the first component is a, second component, I don't care, right? We don't care about the second component, but the depth is d, d. So we decrement one, and eventually for these rules, right, if you sort of look at what the base cases of these rules should be,

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

firstly, predecessor must hold, right? And it only holds if depth is greater than or equal to zero. So we have to satisfy this with the given bound. Any questions on this?

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Okay, no questions. So what I'll do is I'll, so I've added depth here, I, beyond adding depth, we are not doing anything interesting. And I do the same for the additional rules as well, for integers and Boolean and if then else and additions of traction and so on. Okay, so we added all the classes. Now we write a procedure for synthesizing programs, which is basically type checking with this gen function.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

A gen we have seen earlier, right? Gen generates all the numbers from start to end inclusive. So we start from depth zero and we go up to depth 10. Even with depth 10, we get very large terms. And we take the depth and we ask if you want to synthesize a program P, right, for the type T, compute, take some depth D, right, which might be between zero and 10. Under an empty context,

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

the program P should have the type T and depth argument is just the depth argument. So that proves the search tree, right? So we initially start with zero, and then we continue up to 10, and we that's all we explore. Okay, so that synthesis, and it's essentially type checking plus this iterative deepening, and this gen gives us the iterative deepening

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

mechanism. Okay, so now we can synthesize programs. So what I'm asking Prolog to do here is, give me all the programs P, right? I mean, give me first 1000 programs that you can find for which satisfy the type integer, right? And if you run this, you get a lot of examples. All of these are programs that have integer type. So we see that we have zero one,

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

right? We have zero plus zero, which is an integer program, we have if 10 else, true, zero, zero, false, zero, zero, we also have start to see complicated programs, right? This is lambda x x identity function applied to one, this is lambda x x applied to zero plus zero, right? And so on. So this keeps increasing, right? So this is this is quite good. So we are doing

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

quite nicely, right? All of these programs have type integer. integer is okay. So we have not integer as a specification is not that useful, right? So let's try to synthesize more interesting ones. So here is an interesting program, right? So here is, I can I can believe that I may ask you to write this program in your say exam, right? So I can

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

ask this question where you say, Oh, give me an OCaml program, which has this type, it takes a pair, and then returns to the first component of the pair. And you will write, oh, it's a it's a function type, right? So it takes a pair, and then extracts the first element of the pair using first. So all prologue knows here is just the type checking rules, right? And we are going to ask it to compute that particular program, which has this type. So I've written that

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

down here, and saying, get me all the programs that satisfy that type. Let's see what prologue produces. So prologue produces 10 candidates. By default, we prune at 10, but it might produce more. Let's see what program it has produced. So prologue says, I'll pick A to B unit type, right and B to B some polymorphic type underscore 1592. And, and prologue says the program that

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

I've generated for you is a lambda x dot u, right? It's a it's a constant function that always returns a unit value. It's quite strange, right? So if you sort of look at this type, you'll think that this is the only possibility for that. But what prologue has done here is it has gone ahead and specialized A and B to concrete types, right? It is not concrete

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

is to the type here, but it has concretized the type for a, which is what is in prologue is sort of playing fast and loose because our specifications are not quite tight. We never told prologue, okay, you have to generate a polymorphic program. We never said the prologue, you cannot specialize the type for a. So prologue has just specialized the type for a, right to be unit. And it has just

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

generated the program, which takes a polymorphic argument that could be anything and prologue says, oh, that could as well be a star B, right? I completely ignore it. And I just return unit type. Right. And because they has been unified with the unit, this program actually satisfies the specification that we've given here. Right. But if you read through the other examples, prologue is trying to do the same. It specializes all of the, it specializes A,

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

and then just gives you programs that return the same A. So this is valid according to the specification, right? We never told prologue, don't specialize A. But what we are interested in is sort of this idea of a most general program, even though there is no one most general program, one nice property that we want is to preserve polymorphism, right? So we don't want prologue to specialize A or B. When we asked for prologue to

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

generate the programs of this form. So when we asked prologue, please generate a program from A star B to A. We want to also say that don't specialize A and don't specialize B, right? Don't assign, don't ground these variables, right? In other words, types must be polymorphic. And the way you can do this in prologue, prologue has some built-in predicates for helping with that.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

And there is a predicate called the LAR-1, which basically applies to a variable, right? And it says it only holds if the given variable happens to be a variable. It does not specialize to any other term, right? So what we asked prologue to do here is we force prologue to keep A to be a variable, maintain A to be polymorphic, keep B to be a variable, maintain B to be polymorphic and ensure that A and B are distinct. So DIF is another inbuilt predicate.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

We've seen DIF as part of the cuts and negations class, right? So DIF is similar. It says keep A and B to be distinct, right? Just so that we naturally capture what is said here. We don't want it to be A star A to A. I really want it to be A star B to A, right? So that's what I am asking prologue to do. And I'm asking prologue to generate exactly one candidate for that.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

It is sort of star added, right? There can be only, yeah. So there is one good program for this particular type and prologue finds the program, right? So prologue says A is some variable, B is also some variable. And the program that it is producing is lambda x first of x, right? Or lambda p first of p. And this is precisely the program that we were looking for,

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

right? Lambda p first of p. And by adding suitable constraints for our program generation, we can get the necessary type, necessary program that satisfies our intuitive understanding of what we are asking. We can also generate all sort of, as long as you can express the type and then express the constraints, you can generate and keep generating interesting programs, right? So here I'm asking prologue to generate a candidate program for, which takes

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

which takes as input A star, B star C, and then returns a B, right? How do you get here? You need to extract the second component of the given input, right? And extract the first component. And we want all three A, B, C to be polymorphic and distinct. So that is what we do, right? So we just write down the type here. And we asked prologue to generate synthesize that program. We leave,

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

we asked prologue to keep these as variables. And we keep, we asked them to be distinct. Of course, you can sort of write a procedure, right? It takes a list of variables and then ensures that all of these are variables and all of them are distinct. I will leave that to you. But I'm making a point here that we can generate interesting programs. This program is a little bit interesting, right?

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

So it's, you have to search through the terms that you have to get the intended semantics. And the semantics is actually given by the type, right? By looking at the type, we are getting the semantics. And if you run this program, prologue searches for a little bit, right? And then gets back with the answer, which is lambda x, lambda p, first of second of p, which is precisely the program that we were looking for. And of course, I'm only scratching the surface of program synthesis here,

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

right? Program synthesis as an area is like very rich right now. And it's sort of, it is also interesting now, thanks to the revolution in machine learning and artificial intelligence, right? So we have lots of data driven methods, which we can combine with these rule driven methods in order to generate interesting programs. Imagine a world where you can just write

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

a specification. I mean, I've given you a lot of specifications in this course, you can also think about specifications for your, say C program, right? Write a red black tree, we know what a red black tree is, we know what a red black tree property is, but we still have to write those programs. Imagine a world where you are able to specify the properties in some language, we use types as a language here, right? And with additional things here. But if you have a rich enough language where

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

you can specify these constraints, and the program and the computer can automatically generate the program, according to some specifications, we are not even considering things about efficiency and so on here. But you can imagine if you have a rich enough language, maybe we will get to a world where we can generate programs automatically. This is programming, but what you're doing is

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

you are just writing the specification, right? We are looking at very simple. So the distinction that I want you to take away is that we are specifying the program, we are not actually writing the program, right? I'm not writing this function. The example here is very simple, right? And it is the structure of the type is closely matching the structure of the program. But you can imagine more interesting structure. I mean, as I said, I'm only scratching the surface.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

Think about the sorting procedure, right? It is much easier to describe what a sorted list is. I can say a sort procedure takes an input list, right? Returns a list where the membership of the list remains the same, and the list happens to be sorted. Here, the specification is so much easier compared to actually sorting the list. Right? So there are instances where the

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

specification happens to be much smaller and well understood than the actual program. And here, it's sort of so simple that you might not see it. But I mean, this is a very, very rich field, right? So again, program synthesis sort of just to give you more ideas, right? So

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

it might seem like an easy way to just specify what we want from the program. And then have the computer generated, we know exactly what type that we want here, right? And we are saying, go generate a program of this type. Oftentimes, the problem in real world software development is we don't know precise specification. Right? So there are also interesting methods that sort of generate synthesized programs based on input output examples. So you'll say you will give

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

an input list, and you will show that it is sorted, right? You give several examples like this. And based on lots of cool techniques, we come up with candidate solutions that satisfy all of these properties. The interesting avenues are combining both data driven techniques, pure data driven techniques, search for things based on ML and AI, and these sort of deductive techniques, right? So

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

it's a very rich area. So scratching the surface here. But that's all I wanted to say about this lecture. Any more questions or comments or anything on this? While I open up the next one, you can ask questions on the chat. I'll have a look.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

Okay, so I find no questions. So I'm going to continue with this lecture. Yeah, so this will be the last lecture. Okay, so I had two other lectures, but I think I am way

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

over time, and it's not useful to overload you with too much material in this interesting circumstances. So what I'll do is I'll finish with this lecture. So I'm hoping that we can finish this by this week. So what we are going to see in this lecture is graph search, right? A lot of the problems that you see in the real world can be translated into a graph search problem. And as

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

we've seen with the last few lectures, we will look at examples, right? We'll pick one example, and then we'll keep on building upon that example to do more interesting things. So this example, this lecture is going to be just graph search. And we can start with a very simple graph search problem. So a part of what you will learn in this lecture is look at certain problems, identify that

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

they are graph problems, convert them to Prolog so that you can solve the problem Prolog. So here is a simple maze, right? If I ask you to solve it, you will solve it and solve it very quickly. And there are multiple paths in this maze, right? Not everything leads to the solution, the center.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

And the question is, okay, how do you solve this? And how do you make Prolog solve this? And that's what we are going to see. So, yeah, so the first learning goal for this problem is, how do you encode? How do you take that maze and convert that to a graph search problem? And how do you solve that problem? And how do you handle cycles in the graph search? And oftentimes, you will see that the real world problems have cycles in the graph. You look at how to handle

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

cycles in the search path. So the technique here is to say, okay, every opening in this maze, I will label it, right? And I will consider that to be a vertex in the graph. So I have lots of labels here, every opening is labeled. Okay. And I will consider that there will be an edge connecting adjacent openings. So if I can go from, I can enter through A, right? And I can go to G

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

and B. So I consider that there is a path from A to B and A to G. And similarly, I wrote from B to C and B to H, and so on, right? So just to give you, like, if you sort of look at solution, the solution is a path, right, which goes from A, B, C to D, D, J, R, and U. So that's

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

the solution. And we will sort of search through this graph to reach the solution. And we will use the predicate route. If B is one of the openings that is reachable on entering A, right? So you are at A. And if you can reach B, then we say that there is a route from A to B. And we will use this to encode this whole maze into a set of facts, which describe the graph. So here is the actual

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

graph, where you can see that there are different paths, right? And if you draw that out as a tree, right, you will get this tree. So observe that you can go from A, B, C, D, J, R, U. So that is one path, A, B, C, D, J, R, U. But there are other paths which are not

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

reaching the goal, right? The goal is U. U and T are ends, but really U is where you can reach, even though there is a T, you cannot reach T from the opening vertex A. And if you look at this, T is not reachable from A. And this is all the paths that are reachable from A. And this is what we are going to do. And I encode all the graph edges as facts,

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

like nodes, we just encode nodes as atoms in prologue. So I load all of these clauses, I get 15 clauses, which correspond to 15 edges. And now the route is sort of capturing one hop, right? And you want to capture the notion of traveling from the start to the end. And the way we do that is define this predicate called travel, which holds if you can travel from

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

some node A to some node C. And there are two ways to travel, right? If you, you can travel always from the current node to the current node. So you are already there. And you can travel from A to C if there is a route from A to B, right? And you can travel from B to C. So this is, this is basically transitive reflexive closure defined using prologue process. Okay, so we define the travel process. And then we describe what is the start and end,

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

start and finish nodes. We say start of A holds, that's the start and finish of U holds, to say that that is the finished node. And we define this clause called solve, where we say, okay, you have to start at some A, you have to finish at B, some B, right? And you have to be able to travel from A to B. Right, so I encode all of these facts. And if

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

I asked prologue to say, can you solve this prologue will say, okay, it's true, right? So, of course, there is a path. And prologue has internally solved this, right? But we are not getting any useful rule because we, when we solve the maze, we actually want the path from the starting node to the center. And the way you can do this is you can attach a log to remember the route that you've took, that you've taken. So I defined the predicate travel log,

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

which maintains the list of paths that were traversed, right? So if you travel from A to A, there is no path. So the list is empty. If you travel from A to C, you can travel from A to C, if you have a route from A to B, and you can travel from B to C, right? And if traveling from B to C gives you the path steps, right, steps is the list of steps,

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

then traveling from A to C will have one additional step, right? It will have the step from A to B, because that's the step that we have here. And now we are remembering the actual traversal in this list. So now you can solve for the particular path, right? So what we are asking here is, is there a solution where the path is L, such that you start at A, start was defined

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

earlier as the vertex A, and finish at some B, where you finish, finish was defined as U, and the travel log from A to B happens to be L, right? So that's why we have this L variable here, which in order to get out the path. So if you do this, this gives us ABBCCDDJ JRRU. And if you go here, this is the same as ABBCCDDJ JRRU, right? So that's the solution that we were

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

looking for, right? We got both the fact that there was a solution and the fact that what the solution was. Any questions on this so far?

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

Okay, no questions. So let's make this problem more interesting, right? So let's add a new opening. So if you look at this one, I created a new opening here, and I named it V. And the reason for doing this is we are introducing cycles in the graph. Yeah, Venkata is right. So that's precisely what I'm doing right now. The earlier puzzle, the earlier maze did not have cycles,

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

right? But now I'm explicitly introducing a cycle. And you can see that there is a path from ABCDVQ and then PI. And there's a path here, right? If you go down this route, we get stuck. And if you think about how prologue does resolution, right, how prologue computes, it is doing a DFS, right? So it is going to get stuck if it enters this path. If it is unlucky enough to enter this path,

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

right, we don't know whether it will certainly enter it. We know that it will get stuck. If it goes through here. So we want to avoid this, right? We want to handle cycles. How do you do cycle avoidance in a typical graph traversal? You will have this notion of visited nodes, right? You will mark nodes being visited. And you will prevent visiting the nodes that you previously visited. You will do the same thing here. So I've added a cycle. So what happens here

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

is now there is a path from CD. The solution is down this path. But now you can enter through here, you can go QVD or QVDQVD, so on. There are going to be like these two problematic edges that I'm going to add to the previously added edges. So I'm going to add a path from Q to V and V to D. Okay. So I'm going to add a path from Q to V and V to D. I'm not going to run this because

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

this goes into an infinite loop. You can try this out yourself. Okay. So we have to handle this somehow. So what we are going to do is to remember the visited nodes, right? So I define a travel safe predicate now, which does not have the log right now, but it only remembers the visited nodes.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

And travel safe of AA holds regardless of what the visited nodes are. And travel safe of AC holds with the visited node visited. If there is a route from A to B, and B is not a member of the visited set. So there are two things going on here. Member is a built-in predicate. You can define membership by yourself. It is not. This is this point, you should be able to define

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

it yourself quite easily. Member is going to check whether the given term is a member of this list, right? It holds them. And recall that backslash plus we use for renegade. It's just not. So what we're saying is there must be a route from A to B. And B should not be part

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

of the visited set. And we can, B is not a part of the visited set. And we can travel from B to C. And we update the visited set to include B. Because we are going through B. We are augmenting the visited set with B as the head. So if you do this, then you can solve the given

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

puzzle. So this just returns true. And we don't have the log here. But you can do, we can attach a log to this as an exercise. So we've seen how to do logs before. So we've handled cycles as well in this. And that answers Venkat Rao's question. Okay. So any questions on this so far?

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

Okay. This is maybe quite easy because you've seen enough for prologue right now. Okay, so let's move on. So it turns out that a lot of the problems that you see in the real world are sort of, if you stare at it, you can sort of think about them as graph problems.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

And here is a famous puzzle, the standard puzzle. There are many, many names for it, but we'll just use missionaries and cannibals as a name for it. So the puzzle is, you might have heard of this puzzle earlier. So there are three missionaries and three cannibals and one boat who are on the left bank of a river. The boat carries two people.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

And the intention is to take all of them to the right bank. And the catch is that if on any one bank, if there are more cannibals than missionaries, then the cannibals will eat the missionaries. So you want to safely take all of them to the other bank. So the question is, can you take all of them to the other bank? And if so, what is the actual set of steps that you have to follow in

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

order to take the missionaries and cannibals to the other bank? This is a very standard puzzle, right? And we'll see how to solve this puzzle using prologue. So in order to approach this problem, you have to start with some structure that captures the notion of cannibals and missionaries and the left bank and the right bank and where the boat is and so on.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

So what we will do is basically define this as some state, which encodes all of the facts that we know about the state of the problem. And we will describe the puzzle as a state transition system. So you can go from one state to the other state according to whatever is allowed. And we will see that some states are safe and other states are not safe. You can only step through

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

safe states. And given a particular state, there are possibly multiple outgoing edges, options for the next state. For example, here, I have three cannibals and three missionaries. So I can take, this is a safe state. Cannibals and missionaries are all equal, so that's safe. If I take two missionaries on the boat to the other bank, the cannibals will

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

lead this missionary. And that's an unsafe state. There's a possibility of doing that, but that is unsafe. But I can take, say, one cannibal and one missionary or two cannibals to the other side, and both of those lead us to safe states. So the question is, what we are going to do is to enable these as some configurations and a state transition system. And we will let Prolog explore the state transition system to get to the intended final state, which is all of these

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

folks are on the other side safely, without going through, without anyone having eaten anyone else. Okay, so the configuration that we will use for this problem is, I'll just call it config. It's a function with five arguments, right? Prolog function, five arguments. And the

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

number of cannibals on the left bank, number of missionaries on the right bank, number of cannibals on the right bank, and then the position of the boat on the bank, right, it might be left or right. So the starting configuration, right, I write start predicate for this configuration is going to be three cannibals, three missionaries and three cannibals on the left bank, zero

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

missionaries, zero cannibals on the right bank, and the boat is on the left bank. So this is L, it is deceptively looking like one, but that is L. And the finished configuration that we are interested in is there are zero cannibals and missionaries on the left bank, right? And there are three cannibals and missionaries on the right bank, and I don't care where the boat is. So the boat might be anywhere. I mean, it has to be on the right bank, but that's not important.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Okay, so let me add those two clauses. It's already added. Let me restart it here. So let me add these. Oops. Okay, so now if I had this, okay, I added two clauses now.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

Okay, and then, so not every configuration is safe, right? There are configurations where the cannibals will lead missionaries. So what is a safe configuration, right? A state is safe if no missionary gets eaten in that given state, right? A missionary gets eaten if there is at least one missionary on that bank and the number of cannibals on that bank

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

outnumber them, right? There has to be at least one missionary and the number of cannibals on the same bank outnumber the number of missionaries. So we say that these three clauses are defining the safe states. So what does this say? So if there are no missionaries on the left bank, I don't care what the number of cannibals on the left bank is, because there are no missionaries to be eaten. If there are M2 missionaries on the right bank and C2 cannibals on

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

the right bank, it better be the case that the number of missionaries is greater than or equal to the number of cannibals, right? That's the safe state. And similarly, for we do the same for left bank, let M1 be the number of missionaries on the left bank, C1 be the number of cannibals on the left bank. If there are no missionaries on the right bank, I don't care what the number of

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

cannibals on that bank is. But I do want to make sure that for safety, the number of missionaries on the left bank is greater than or equal to the number of cannibals on the left bank. And these are handling the cases where there are no missionaries on the left bank, left and right banks. I don't care about what the number of cannibals is. But in case these two are not true, right? So we can have missionaries on both the banks and cannibals on both the banks.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

And we want to ensure that the number of missionaries is greater than the number of cannibals on that bank. Okay, so that's safety. So we define three clauses for what a safe state is. Okay, so that's the, that is giving us safety for a particular state. Now we need to define the transition between states. So how can we transition from one state to the other? A board can carry a

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

few people, one or it must be either one or two persons from one bank to the other. So we define this predicate called carry that is parameterized with the number of missionaries on that board and number of cannibals on that board. So you can carry, the board can travel if there are two missionaries, no cannibals, one missionary, one cannibal, two cannibals, one missionary or one

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

cannibal. So there are five possible ways to transition from one state to the other. Not all five are possible all the time, because there might be no missionaries or cannibals on one side to satisfy all of these, but these are the all five possibilities. So that is added as well. And now here is the state transition system. So this is defining, given a configuration,

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

how do I step to the next configuration? So we have two clauses here. Right. And the two clauses are going from left to right bank. Right. And this is going from right to left bank. Okay, so that is why we have two clauses. And what are we saying? So I'm using

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

variables in a suggestive manner. So these are the way you should read this is the number of missionaries on the left bank at the beginning, the number of cannibals on the left bank at the beginning, the number of missionaries on the right bank at the beginning, number of cannibals on the right bank at the beginning. And similarly, number of missionaries on the left bank at the end. Right. Number of cannibals on the left bank at the end. Number of missionaries on the right bank at the end. Number of cannibals on the right bank at the end. So we are going from the begin

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

state to the end state. And these are the variables that I'm using. So how do we how do we do this step? Right. So let's take a configuration, the initial start configuration. And this is going to be the end configuration, you can go from start to end. If you can carry MC, some number of missionaries and cannibals. So if you are carrying M missionaries, it must be the case that and we

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

are starting from the left bank. Right. So this is left to right. So if you are carrying M missionaries, it must be the case that the number of missionaries that you had on the left bank is greater than or equal to M. If you're carrying M missionaries by both from left to right bank, it must be the case that you at least have that many missionaries on the left bank. Right. And similarly, for cannibals,

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

we use the same idea. So it must be the case that there are at least so many cannibals on the left bank. Right. As they are being carried on the boat. And what happens when you carry people? Right. The number of people on the left bank will reduce and the number of people on the right bank will increase. So that is what we write here. So the number of people on the left bank in the end state is the number of people on the left bank in the beginning state minus M. Right. We carried M

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

people. So that is minus M. And similarly, we will increase the number of people on the other side. So the number of people on the right bank in the end state is the number of people that you started with on the right bank for missionaries. Right. Number of missionaries on the right bank at the beginning plus M. So we carry so many people. And similarly, we do the same thing for cannibals. And this rule is just for the other direction travel. Right. So we just use the variable names

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

appropriately. And you should be able to read it through yourself. So the point here is there might be multiple carry possibilities. Right. If there are three cannibals, then I can three missionaries, I can carry zero missionaries or one missionaries or two. Right. So if this defines multiple outgoing edges in the graph. Okay. I've added that.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

Any questions on this? I think I'm very close to the end. So I'll finish this lecture quickly. Today. Okay. So and then we now have defined all the necessary steps. Now we can actually define travel. So just like before, we can travel. Travel is a predicate that has four components. So start

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

configuration and end configuration. The set of visited nodes, because you can keep going back and forth with the same set of people, right? You can go from safe state to state. We don't want prologue to go in this infinite loop. So we have the visited configurations as well. And we also keep a log of the steps that we do. So we have a log as well. So we can always travel from the current state to the current state. We can travel from a state A to state C. If you can step from A

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

to B, where the step predicate is the one that is defined here. Right. And B happens to be a safe state. The target state happens to be a safe state. The target state is not one of the visited states. And you can travel from B to C. Right. Where A and B are both visited. And then you have the rest of the steps. Right. And the result will contain B as part of the steps that you visit.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

Okay. So if you do this, then we can now write the solve procedure, where you start at some state. Recall that we've already defined what the start state is and then state is finished status. And we should be able to travel from A to B with initially no visited states. And the result is going to be L. That is what we push out here. Right. And solve for is only here just so that the

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

result becomes is formatted nicely. Okay. So I'm not going to explain the details there. It's just a matter of presentation. So you can ask for the solution. The solution says that you can you start from the configuration, which is 3300L. Both all the cannibals and missionaries, missionaries and cannibals are on the left bank. Then you move to configuration 2211R. The meaning is that you take

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

one missionary, one cannibal on the boat to the right bank. And the boat is now on the right bank. Right. So you can you can read this that way. And we get this final configuration, which is 0033R. Right. The solution is the same as what is given in the Wikipedia for this problem.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

This Wikipedia calls this jealous husband's problem. But you can sort of see that in the same way. So there are three missionaries, three cannibals. Initially, you take one missionary, one cannibal to the other side. Then you bring in one missionary over to go to the left bank and you keep doing these are cannibals. The blue things are cannibals. And you'll see that the solution that we have here precisely corresponds to the solution that is presented for this problem on Wikipedia.

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

So what we've done is we have solved the the missionaries and cannibals problem by encoding them in this generic way in in prologue. Right. So this also particular instance of the problem. But you can imagine for end missionaries and end cannibals, this will just work. Right. We just use the three and four as three and zero as three and three as numbers.

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

You can solve it for any numbers. So yeah, so there are lots of problems that fit this pattern. Though they might not appear to be graph problems in the beginning. Another example is towers of Hanoi. I suspect that you might have heard about this problem. So the idea is that there are these pigs, right, from the starting state. And you want these pigs to be in the same order in the ending

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3300.0s_

state. And you can only move one pig at a time. And you want to get to the ending state. And the question is, how do you what are the series of moves that you can do with this intermediate temporary state to get to the final state, which is all the pigs are moved here. If you started it, sort of, you can sort of encode the same problem in the same way as how we've

---

![slides/interval_0111.png](slides/interval_0111.png)
_t = 3300.0s -- 3330.0s_

encoded the missionaries and cannibals problem. And you can you can try this on your own. So I'll stop here. And I think I'll I think this is all I wanted to cover in this course. So I hope that the course was as enjoyable for you as it was for me. Right. So and

---

![slides/interval_0112.png](slides/interval_0112.png)
_t = 3330.0s -- 3360.0s_

and I suspect that I haven't decided about the final exam yet, because it becomes quite tricky to run the final exam remotely for this course. I haven't made a decision. It is likely that you won't have a final exam this year. Right. So I haven't made a decision about it. It will be start of the next semester, hopefully, if the situation changes. Otherwise, we'll figure out what to do. I'll give you sufficient time before I announce the exam so that you can prepare for it.

---

![slides/interval_0113.png](slides/interval_0113.png)
_t = 3360.0s -- 3390.0s_

And if it happens to be if it happens to be a remote, then open book and all the rules apply. Right. So we'll see what what we do anyway. So any questions on this? Otherwise, I'll stop here. And you can continue asking questions on Slack. I'll hang around on Slack and answering questions

---

![slides/interval_0114.png](slides/interval_0114.png)
_t = 3390.0s -- 3423.7s_

about the assignments. So OK, thank you very much. Yeah, thanks to everyone for making this enjoyable, even in this period time, right? I haven't met any of you personally. So hopefully we will meet all of you when this thing ends. Right. And be nice to meet every one of you. And let's make sure we meet each other. Thank you very much. Yeah. And stop.

---
