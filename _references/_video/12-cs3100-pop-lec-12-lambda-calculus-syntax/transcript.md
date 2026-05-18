# 12-cs3100-pop-lec-12-lambda-calculus-syntax

**CS3100 POP - Lec 12 - Lambda Calculus Syntax**  
id: `JvlEPvT_fSM`  
duration: 3165s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Let's start from where we left off. And in the last class, we were looking at Lambda calculus. We said Lambda calculus is this essence of functional programming. And it's a very small language. And we saw the historical development of Lambda calculus and related ideas and how they are relevant today.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

And what we'll do today is we will delve deeper into the study of Lambda calculus itself. And in particular, we will sort of study the syntactic conventions and certain concepts that arise from just looking at syntax. And to be clear, Lambda calculus is a very, very small language. It's the smallest, curing, complete language that you can ever think of.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

So all of the language is just here. And what does it have? It has a variable. So you can have variables in Lambda calculus. Or you can have abstractions, which are these Lambda x dot e, which are similar to functions. So whenever you see a Lambda x dot e, think about anonymous functions in OCaml, which is one next arrow e. And you have applications. And that's it. That's the entire language.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

And the point here is we don't have any other types. Actually, we don't have any types, first thing. What we are studying first is what is known as untyped Lambda calculus. We don't have any types. And in particular, we don't also have any values. The only value is actually we have one value. The one value is the abstraction. We don't have numbers. We don't have Booleans. We don't have anything.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

But it turns out that this very parsimonious language is enough to encode all the concepts that you might have in modern languages. By encode, I mean we can simulate the behavior that you would observe in all of the languages, in all of the applications, and so on. Anything that you can program with, and you have particular behavior, you can get that same behavior using just the Lambda calculus.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So you might ask, I gave you historical reasons, but why do you want to study Lambda calculus today? The point is that it's a very small core language. It captures the essence of what is Turing complete. So if you want to study programming languages as a thing, instead of studying Java, we are studying linguistics. And the equivalent of capturing the essence of all the languages is this small Turing complete language.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So it makes sense to study Lambda calculus. And one thing we do as programming language practitioners, so we try to explore new ideas, new language features, semantics, proof systems, algorithms, and so on. And the way we do this is we try to map the core of those newer ideas into Lambda calculus, and then we study them. We sort of try to see how they behave, what is the meaning of those programs, for example.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And from a pragmatic standpoint, if you can sort of say, all of these languages which are considered the mainstream C plus plus, PHP, C sharp, and Java, and everything else, now has Lambdas. And hence, studying Lambda calculus sort of gives you an edge, right? So you have this upper hand, you know where the term Lambdas come from, and you actually understand what Lambdas are. And they also form the basis of functional languages

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

like OCaml, Haskell, and F sharp. So that is enough reasons to study Lambda calculus. And before we delve deeper into Lambda calculus, there are two conventions we are going to use. And this is syntactic conventions. It will help you parse Lambda calculus terms. The first convention is that the scope of Lambda extends as far to the right as possible. What do I mean by this?

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

Consider this term. It says Lambda X, and this is some other expression, Lambda expression, and that is Lambda Y, X, Y. And the way you read this is you have a bracket just after this dot, right? Opening bracket and closing bracket goes all the way as far as possible, right? Here we don't have any other term, so it goes until then. And then we have another Lambda here dot, so there is a new bracket here, and it goes all the way to the end.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So whenever I write terms like this, the way you have to read it is whatever follows the Lambda term is in a bracket, right? So getting this right will help you understand what's going on. Lambda calculus is a very small language, right? So when I write larger terms, this might look very confusing,

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

but the point is if you sort of keep two conventions, this is the first convention, these two conventions you can at least parse the terms, you can sort of understand what the terms are before understanding what they do. So the first convention is again, start a bracket just after Lambda and the scope extends as far as possible to the right. And the second convention is if you have a Lambda term, X, Y, Z, then this is application, right?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

And the way you have to read it is function application is left associative just like OCaml. So you read it as X applied to Y, which returns something that is applied to Z, right? So you imagine a bracket here. So when you see applications where you have three terms like this, you always introduce brackets in a way that it is left associative. So function application is left associative. This is the same as OCaml, okay?

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

Okay, and what you're going to do in assignment two, I hope you have started assignment one and you're powering through it, but what we will do in assignment two is implement a interpreter for a Lambda calculus in OCaml. So what does this mean? So we have this very small language, right? And you can write programs that express some behavior

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

and you'll write an interpreter which takes the source language term and then reduces it and gives you an expression at the end which captures the meaning of evaluating that expression. Okay, so that's the second assignment. We will cover a few lectures before you can actually understand what that assignment would mean. But for that, as I mentioned, right? What are you going to do? You're going to implement an interpreter. What does the interpreter do?

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

It takes a Lambda calculus term, reduces it and gives you a Lambda calculus term, right? That is all it can do. And we have to sort of input this Lambda calculus term so that OCaml can accept it, right? And the way we describe the term in Lambda calculus in a way that we can interpret that in OCaml is through what is known as an abstract syntax tree. And because in OCaml we have variant types, right?

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Algebraic data types, this becomes very, very natural, right? Just recall this function, this description of Lambda calculus. So there is a variable, there is an abstraction, there is application, three rules, right? And we can describe those three rules in an OCaml type where we say, where we declare a new type called expression. Expression is the type of Lambda calculus terms, right? And there are three kinds of expressions.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

First is a variable, right? And for a variable, we can have some name for the variable. So it's a string. Second is a Lambda term. What does a Lambda term have? Lambda term has a Lambda, some variable and then some other expression. So Lambda term is, contains a pair. The first one is the variable name, right? That we are introducing. And the expression that might refer to this variable. And the last one is an application

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

where we have an expression star expression, right? So OCaml, actually in practice, OCaml happens to be a nice language for implementing compilers and interpreters. Exactly because OCaml has support for algebraic data types. So it becomes very natural to write these functions and we have exhaustivity checks and so on, right? So even if you extend the language, your compiler will help you identify places where you've not handled certain cases.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So as you will find, right? So this assignment two is sort of serves two purposes. First, it will help you understand Lambda calculus. Second, it will actually help you understand OCaml in a setting where it is very good, right? In a setting where it is known to be good. It is also good for other things. But it is known to be good for writing compilers and interpreters. And the second assignment will help you experience that as well.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

Okay, so let's look at a few Lambda calculus terms that you would write on paper and then look at how those terms will appear as terms in this new type expression that we've defined in OCaml. So whenever I write a term, Lambda calculus term just y, that's just a variable, right? So the OCaml equivalent will be variable of y where y is a string. And this is an identity function, right? Lambda xx takes whatever x and returns the x.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And this is a Lambda, right? So we have a Lambda constructor. And then it has two arguments. The first one is the variable, right? So that variable is a string. So that's here. And the second one is an expression, right? And because it's just an x and the way we describe variables in Lambda calculus which are expressions, it's just bar of x, right? So this is a Lambda term.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

And the next one is a abstraction that takes x and a y, right? It takes an x and then it takes a y and applies x to y. This is equivalent to a Lambda calculus term that has two Lambdas, right? Because we have two Lambdas, Lambda, Lambda. And the arguments are first one is an x, second one is an y. And what are we doing here? We are applying x to y, right? So we have an application, oops.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So we have an application. Application applies two Lambda calculus expressions, right? And what are those expressions? Those two are just variables. And first one is a variable x and then second one is a variable y, right? So we are looking at very small examples, right? But as you start looking at bigger examples, the abstract syntax tree will become very large. It is hard to easily parse what is going on.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

But the reason why I'm sort of explaining this is it will at least give you an ability to debug the expressions, right? When you sort of look at these expressions, you will sort of understand what's going on. So we have this larger expression here, right? So the way I would approach this is there is a E1 here, there is an E2 here, and this is a Lambda calculus expression. So this is an application, right? At the top level, there is an application.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

So we start with the application constructor. There are two expressions, first one and second one. I've written it down as the first one is in the first line and the second one is the second line. Let's look at the second one first. Second one is a Lambda x, right? That takes a Lambda, that is a Lambda, it takes an x and then applies x to x. So it's a Lambda, the variable name is x. It's an application here, right? Where you apply variable x to variable x.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

So application always takes two arguments, right? So it takes the thing that you are applying and the thing that you apply it on, right? Those are the two things. And similarly, this expression is the same as this expression. So we will just have the same thing here. So this is how the thing that we write on paper is represented in our OCaml AST,

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

abstract syntax tree, AST, okay? So, typically the study of Lambda calculus is done in a more theoretical fashion, but I like to, once you actually have these things as something which you can manipulate, right? It's like having some toys, some Lego or something. You can actually play and build with it. You can see what the limitations are and so on.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

So what this notebook has is a implementation of the interpreter. I don't have the source code because that is what you'll be implementing in a segment two, but you can start using this interpreter for evaluating Lambda expressions. So here is the actual way that you bring it in. So this hash uses a meta command.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

This is not OCaml, this is OCaml's command that talks with the Jupyter notebook, right? And it says there is some OCaml code in init.ml function. So in this course, we will never write OCaml code in the file, but when you write OCaml code in the file, you will name the file as .ml files, right? I think building files and building multiple directories is not the point of learning programming languages.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

I think you can learn all of that later, but all this is doing is it is saying there is some OCaml code in this file called init.ml. If you sort of go to this directory and have a look, there'll be a file called init.ml. I'm just loading that file and I'm using, I'm executing whatever OCaml is in that file using use. So when I run that, I bring three functions into scope. So that file has three functions to find.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So let's ignore these two for the moment. So first one is a parse, right? And parse is a function that takes a string, right? A string representation of Lambda, and then gives you, returns you an expression type. It's a syntax.expression, but this expression type is the same as the type that we had seen just now. And here is a way of parsing some Lambdas, right? The first one is just, and these examples are the same as the ones

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

that I've written down here, okay? So what does the parser do? The parser takes the string representation of the Lambda expression and returns you an abstract syntax tree. This type representation, the value representation of Lambda calculus. Okay, so the first one is just a variable. You can write Lambdas using this Unicode symbol Lambda, right? So when you write Lambda x.x, it interprets that as a abstraction,

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

but you can't easily type Lambda, right? Because our QWERTY keyboard doesn't have Lambda. So instead of typing Lambda, you can type two backslashes. So when you see two backslashes, read it as Lambda, right? Lambda x, Lambda y, xy. And the last one is the same expression, right? So Lambda x, Lambda y, xy. You add a bracket here. I've left it out, but the meaning is the same. Okay, when you parse these expressions,

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

what you get is you just get the same terms as before, right? I'm not going to explain it. This is just the same term as before. So this will help you parse the expressions. So that's the first one. Okay, so a few questions just so that we understand what is going on. So do you think these two terms are equivalent? Lambda x, yz, Lambda x without bracket yz. You can just type an answer in the chat.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

Yes or no, true or false. Okay, so yeah, so I see a lot of yeses and one no. It is true, right? Why is it true? Because as I mentioned in the convention one, when you have a Lambda, the bracket extends all the way to the end, right?

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

So you start a bracket here and it extends all the way to the end. So that's basically what this is, right? So these two terms are equivalent. So the reason why I'm sort of asking these as quizzes is you can expect these sort of questions in your final example, right? So it'll be similar. I'm not going to test you. No, it is, so Raghur.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

Yeah, so Lambda, when we are talking about this, so this is what I wanted to, good question. So you're asking whether the bracket is not part of the Lambda calculus, right? It is not, but what we write here is not the syntax and what we write here is not the string representation, right? We are sort of writing the abstract syntax tree. Sometimes it might be useful to disambiguate the terms.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

It doesn't matter whether there is a bracket or not, but it is useful to have a bracket. I mean, just like mathematics, right? You use brackets wherever it is necessary. For disambiguation, we use brackets. So the question of whether bracket is part of Lambda calculus is not something that we can, and I would say it's not a relevant question because we are not describing the actual tokens here.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

We are actually describing the abstract syntax tree, right? For just throwing everything I said, yes, you can use brackets in this Lambda terms, right? So we will use brackets. We will use it for disambiguation. You will see terms with brackets, but they are not part of the abstract syntax tree. The point I'm making is I don't have a bracket here, right? But the string representation might need a bracket for disambiguation. Does that make sense, Raghu?

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

Okay, so yeah, the point is there is no bracket in this expression language because what they're writing is the abstract syntax tree. We are not writing tokens. Of course, yes, bracket is needed for the parser. It needs to parse the bracket token, but that's not a concern here. Okay, so that's the first one. Yeah, what is this term in AST? So I write this term, which is Lambda xx.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

Which one is it equivalent to? C, okay, that's good. Yeah, so three, right? So we have a Lambda here. Yep, good. So we have a Lambda here, and the variable is x, right? So we are introducing the variable, and there is an application, right? This is an application of x over x. So the first one is a Lambda expression, variable x.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

Second one is also a Lambda expression, variable x, right? So that's the correct answer. This term is equivalent to which of the following? So I'm using extra brackets here for disambiguation. Okay. Okay. Four is the correct answer, not three, right? So you are missing the second convention.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

The convention is that when you have an application, the application is left associative, okay? So how do we interpret, how do we parse this expression, right? That's the first question. So there is a Lambda. There's a Lambda here, right? And the convention is that there is a bracket that starts from here and goes all the way to the end. So there is a bracket here, right? And there is an application xab. When you have applications of these terms, right?

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

xab, cd, ef, g, the bracketing is, the application is left associative. So you apply the leftmost term together, and then that is applied to the second following term, subsequent term, and so on. So the answer is the fourth one. And this is an extra bracket, right? I don't actually need this, but it doesn't matter if it is there. The idea is that you first apply x2a, right? And take that result and apply it to b,

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

because function application is left associative. Okay, just apply those two conventions. I will certainly have a question that looks exactly similar to this, right? This is like free score for you. So if you sort of, just remember what I'm saying now, you will score a few easy marks in the final exam.  And okay, so good.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

So some of you, I think, are getting the idea. It's very hard to get feedback from just talking to a bunch of icons here, right? So it's good to have interactions this way. So okay, so free variables. So we are seeing one more new concept here. We've seen free variables when we talk about, okay, well, I think I mentioned it exactly once. We will look at it much more rigorously here. Okay, so here is a lambda term.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

This lambda term has a lambda, right? Lambda x, and then it does an application. Where it applies x to this term y, right? This term y, it is not present in this particular term, right? It's not here. It's not in scope. So when you look at the terms like this, we call the first x to be the binder, right? We use term binding for the variable introduced

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

by lambda calculus, right? This first x is known as the binder. The second x is known as the bound variables. Why is it bound variable? Because this bound variable is bound by this binder, right? And y is not bound, right? There is no lambda term here in this term, which binds y, right? So we call y as a free variable.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

A free variable is a variable which is not bound. Okay, that's the definition of a free variable. You might ask, okay, what is the meaning of this? We are not yet studying meaning, right? So I think we should sort of, this is what I mean by just studying the syntax for now. And we can sort of say, like we will sort of reason about the meaning in the next lecture, right? Okay, so why is a free variable now? So here is a formal definition of what a free variable

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

means, right? And the mathematical way of describing it is FET denotes the free variables in a term, lambda term T, right? We can define FET inductively over the definition of the terms as follows, right? The free variable of the lambda term x is the x. The free variable of, let's look at the third one first. The free variable of terms T1 applied to T2

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

is the union of the free variables in term T1 and the free variables in term T2, okay? And the free variable of an abstraction, right? What does abstraction do? Abstraction introduces a binder, right? And T1 might have some bound variables x which refer to this binder, right? So the way we define free variables of an abstraction is compute the free variables of T1, right? That might have x's,

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

but we know that all of those x's are bound by this binder. So from the result, just remove x, right? And that is the definition of free variables, right? And this is the mathematical way of describing it, but it sort of exactly mirrors what is going on if you write this function in OCaml, right? How will you write this function? You will write a recursive function. That pattern matches on the three patterns,

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

var, app and lamb, right? And you will say, if it is a var x, then the free variable is an x. If it is a lamb, then compute the free variable by recursively calling the expression. And from that expression, remove x and lamb, sorry, app. You compute the two free variables and then join them together, right? So in your assignment two, you will take the specification and implement a function

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

that exactly mirrors what is going on here, right? You will just write it as a mathematical definition. So, yeah, okay. So that's what you will do in one of the sub problems in assignment two. And given a term, if I give you a term and you compute the free variables of the term and if it is an empty set, then we say that t is a closed term, okay?

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

So, yeah, it is a, yeah, Raghu, I think you're asking a really good question, right? So, in order to answer that question, I need to, so Raghu is asking, is lambda x.y a valid term? In order to answer that, you need to tell me what valid is. It is certainly a lambda term, in the sense that it type checks, right? It is a lamb where you have an x and you have a ry. The question you are asking is whether that is a term

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

that has any meaning, we are not yet studying meaning, right? And only if when you have meaning, will you actually define what a valid is? I would say, don't worry about the meaning now, right? It is a lambda term, okay? So, okay, good. So, let's look at how whether we've understood free variables. So, let's look at these terms,

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

and then let's identify the free variables in these terms. Let's look at the first one, right? That's the first one. What are the free variables in the first one? First term, lambda x, right? Lambda yy, none, okay, that's good. What about the free variables in the second term? Yeah, that's good. So, all three are free variables because there is no binder, right? So, everything is a free variable.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

Third and fourth ones might be tricky. So, what are the free variables in the third term? Good, so last y is the answer, right? So, why is that? Because, yeah, precisely. So, you also have to say which y, right? So, just, I think some of you are getting it, but I think you understand what's going on. So, this x, right? So, is the binder and the bracket goes all the way here.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

So, this x is bound here. This y is bound here, right? But this y remains free. And what about the last one? The fourth one? Yeah, y again, right? Because what is happening is this would, so this binder, bracket goes all the way here, right? So, this x is bound here. This y scope only extends to this expression, which is variable x.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

So, this y, this binder does not bind this y. So, this y is in fact free. Okay, so that's the idea. So, all of you have got the idea, which is good. So, here's the answer, right? So, just what you said. I have an implementation of free variables. So, if you, these are the exact four terms that we saw earlier. So, if you call this function,

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

you will get this list of elements. So, the thing that you will do as part of the second assignment is implement this function as well, right? So, you'll implement the free variable function. Should be fairly obvious. The way we work it out, right? It's just a recursive call and the implement will naturally fall out. Okay, so that's good. Moving on. So, we saw the concept of free variables. So, let's keep that away.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

The other concept is this concept known as alpha equivalence.  And the idea here is, if I give you two lambda terms, you can define this notion of these two terms being alpha equivalent, right? I give you one term E1, another term E2. I can ask this question of whether E1 is alpha equivalent to E2 and you can tell me yes or no.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

What does that mean? Whether these two, so, the informally alpha equivalence means whether these two lambda terms are syntactically the same term, right? And because we introduced binders here, right? So, I can introduce a variable, right? Which is a variable X. I can use X in the term.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

If I introduce the variable Y and wherever I use X, I also replace that with Y, right? So, these two terms will be indistinguishable, right? In terms of their usage, right? So, that's really what we are going for. So, if you can safely refactor a lambda term where you replace one variable name with another and those two terms are the same, right? Then we say that they are alpha equivalent.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

Actually, precisely defining this is quite tricky. So, I gave you the informal definition. It sort of should be, I think it might give you some ideas, right? If I say I have an identity function which it's a funX arrow X. If I replace the variable X with Y, if I say the identity function is now funY arrow Y, these two terms are the same, right? Modulo the variable naming conventions.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

That is what we call as alpha equivalence. But precisely defining this is a little bit tricky. So, let's see why. So, lambda calculus uses static scoping, just like OCaml, right? What is static scoping? These relationship between the binder and the bound variable, right? So, this X is bound to this X and this X is bound to this X. And if you have a X here, right? That X would be bound to all the way to this X, okay?

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

And we say that this term is equivalent to this term, right? The only thing that we are doing is we are renaming bound variables, right? We are saying instead of lambda XX, we are using lambda YY, which consistently preserves the meaning, right? We are just renaming the variables so that the term remains the same.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

And this process is called as alpha renaming, right? Because we are doing renaming or alpha conversion, right? And as I mentioned before, if you have a term T1 and it is obtained by alpha renaming another term T2, right? Then we call T1 and T2 to be alpha equivalent, okay? So, that's the definition of alpha renaming.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

So, here is some examples to sort of see whether we've understood the concept. So, which of the, so we write alpha equivalence as equal sign subscripted with the alpha so that we know what equivalence we are talking about. So, let's just look at the first one, right? Whether these two terms are alpha equivalent, right?

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

Whether they can be applied, okay, that was, okay, interesting. So, let's totally look at this, right? So, we had a lambda X, right? And we have a lambda Y and then Y. So, we replace this X with Y. So, this X should be, is bound here. So, we replace that with Y. And what happens to this Y, right?

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

This Y is a three variable, right? This Y can refer to say identity function or a function to launch missiles, right? And, but what I'm doing here is I'm renaming the free variable, right? So, the free variable Y, it's renamed to X here. That's a problem. So, this is no longer the same lambda term, right? You rename Y to X here, that is fine. This is easy, right? So, lambda YY gets renamed to lambda XX.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

I rename X to Y, this is okay, but this is a problem. The fact that I rename this free variable Y, this Y might refer to anything in the scope, right? It is unbound here, which means it can refer to anything at all. And we can't replace anything at all with some X, right? That would be wrong. And we don't know what X is.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

So, these two terms are not just renaming bound variables. They're actually renaming three variables. So, they are not alpha equivalent. Okay, so that was one good answer. I think that's the reason why these two are not alpha equivalent. So, let's look at the second one, right? So, let's look at the second one. What are we doing here? Do you think these two are alpha equivalent? No, okay, good. So, I think now you've got the idea, right?

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So, the point is this Y is a free variable. The answer is no. Let me tell you the other reason. What happened here is we renamed a free variable, right? We had a free variable Y. We made a mistake and renamed it to X. That's not good. Here, we have a free variable Y, right? And what we've done is this is easy. Again, we can forget this, right? Lambda YY gets renamed to Lambda XX.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

That's easy. The problem, the mistake that we did here is Y happens to be a free variable here. By renaming XX, X to Y, this Y gets captured, right? This Y gets bound to this binder, right? This could be arbitrary Y. And what happens here is we've actually said, okay, this Y is not some arbitrary Y. This Y refers to this Y introduced by this Lambda.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

That's wrong. So, this is a different sort of a problem that we've introduced, right? The first one, we had a free variable which we renamed. The second one, we had a free variable which we made to be bound. That's bad, right? So, this is also not alpha equivalent. Let's look at a third example, right? So, the same expression. What about the third one?

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So, yes, okay, that's good. So, the third one is okay, right? We had Lambda YY. We renamed it to Lambda WW. We had Lambda XX. We renamed that to WW as well. This is fine, right? The fact that this W uses the same variable name as this W is fine because anyway the bound, if you draw an arrow, right? This Y binds here, this X binds here. That same binding relationship is there.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

This Y is free. Importantly, this Y is free and the Y remains free here. So, these two are alpha equivalent, okay? So, yeah, just to recall, first one we renamed the free variable, that's bad. Second one we caused a free variable to be a bound one. That is bad. You can also imagine a reverse of this happening, right? If you have a bound variable, you make it free. That is also bad. This one is a free variable which we made bound.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

That is bad. This one is okay. This is the correct one. Okay, so that's the answer. Expect questions like this, right? It's easy for me to formulate these questions, but it also helps you understand what's going on underneath. You can apply the same idea to OCaml, right? In OCaml, if I write two terms like this, you can tell me whether these two terms written in OCaml syntax are alpha equivalent or not.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

So, this idea is very much useful for programming in OCaml as well. Okay, so in order to formally define alpha equivalence, so this alpha equivalence definition is quite subtle. I gave you a lot of different examples, right? Free variable gets bound, bound variables, sorry, free variable gets bound, free variable gets renamed, bound variable gets free and so on. So, defining this precisely is tricky.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

And in fact, to define alpha equivalence, we need a definition of another concept, which is substitution, right? And substitution is sort of intuitively understandable, right? What substitution does, it replaces all free occurrences of a variable, right? Let's say the variable is x with the lambda term n.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

In other term, m. So, the idea here is I give you a term m. This has some uses of x's, right? But all of those x's are free. And what I'm writing here is, in m, sorry, so let me answer the question, someone has asked, are the free occurrences of two x the same?

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

Yes, they are the same, right? So, they are certainly the same. So, you can have two free occurrences. If one gets bound, then the other one will also get bound, right? So, if I introduce a lambda in the outer scope, then certainly they get bound. Yes, so the two free occurrences of x are the same. Okay, so coming back to this, right? Here is a syntax for substitution. The way you read this is in m,

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

wherever you find an x, replace that with the arbitrary lambda term n, right? So, n for x in m. So, x is a variable. Wherever you find the variable x in the lambda term m, replace that with another lambda term n. It's written in a very strange way. This is the syntax that the textbook follows. So, I'm sort of sticking to this syntax.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Okay, so the thing that I forgot to mention is there are two good references for lambda calculus, right? So, the first one is a paper. Actually, I call it a paper, but it's sort of a lesson by Peter Selinger on lambda calculus, right? And the second one is a book called Types and Programming Languages by Benjamin Pierce.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

It's sort of the programming languages 101 book, right? So, that has a section on lambda calculus. Lot of the material here have been borrowed from there. The book is very, very nice. It is also like the prescribed book for doing programming languages. The book has lots of other concepts, but we will focus on just the lambda calculus parts. And the thing that I also want to say is the Peter Selinger's lecture notes

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

are freely available as a PDF on the internet. The Types and Programming Languages book is available as an e-book in IIT Madras library. Okay, so that is also available. I hope you have access to the library resources because you need a VPN. If not, I'll figure out how to securely review that PDF. Okay, so you don't need to buy any books for this. These are good reference books for you.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

The lecture materials covers enough of what is going on, but I highly recommend reading those two sections. They're very readable. It sort of slowly introduce you to concepts. They also have a lot of exercises, right? So, it's because these concepts are very dense, it might be useful to see a lot of exercises so that you understand what's going on. But I've tried to cover everything that you need in this lecture materials on this notebook.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

Okay, so that said, let's look at an example of substitution. So, in this example, what we're doing is, this term is first m, right? This lambda zz sn, and y is the term that we are, the variable that we are replacing for. So, what it says is, in this term, lambda x, x applied to y, wherever you find the free variable y, replace that with lambda zz, right?

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

And all you do is wherever you find the free variable y, right, the qualification is very important, right? Wherever you find the free variable y, you replace that with lambda zz. So, you replace that with lambda zz. If you have a bound variable, you shouldn't replace it. That's the catch there, right? So, this is a simple example of what happens with substitution. So, all we are doing is we are taking one term and replacing that for a variable,

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

but we are doing it only for the free variables. Okay, so that's the important bit. Actually, substitution is quite subtle, right? So, I'm overusing the term subtle, subtle, subtle in this lecture, but they had, in fact, subtle. So, what we will do is we will start with our intuitions, right, we will write a very simple intuitive

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

definition of substitution, and then we will show that how that breaks and we will try to fix it, right? So, and then we finally arrive at the correct example. That way you understand the complexity as we go through the algorithm, right? I mean, it's only four lines long, but there is a lot going on. So, it is good to start with a broken one and then fix it to reach the correct one. And this approach is borrowed from this types and programming languages book by Benjamin Pierce, right? So, if you want more material, you just go

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

and refer to that section there. Okay, so here is my take one of how to implement substitutions. Okay, so the way I described it is here is the term, right? M, N, and then the variable. So, if the lambda term is X, I want to replace all three occurrences of X with S because X is the same as X, the result will be just S.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

And S is the, I use S because S is the, S stands for substitution, right? And it is not just a variable, it could be arbitrary lambda terms, right? It would be any lambda term that you can conceive of. So, if you are replacing X with S in X, then the result is S. If you are replacing X with S in Y, right?

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

Where X and Y are not equal, then the substitution does not do anything, right? It doesn't change the variable. So, you just leave it as such, right? So, these two are easy. So, how do we define substitution for application? So, natural thing we might say is, okay, these two are lambda terms, so let's recursively apply substitution, right? Let's do substitution recursively on T1 and T2. And what about lambda term? Let's just do the basic thing, right?

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

So, if lambda Y dot T1 is the term in which we are substituting S for X, then just replace S for X and T1, right? Again, the bracket is here, right? That's the important bit. So, the bracket is here. Here, we are replacing in the whole term. All I'm saying is, if you want to replace in the lambda, just go ahead and replace it in the body of the lambda. You can sort of see where this breaks, right?

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

So, this definition works for most examples. So, it actually works for a lot of the examples that you can come with. But here is an example where it fails, okay? So, the problem is with this definition. So, let's look at the example first. So, M here is lambda Y X, okay? And we are going to replace the free occurrence of X in this example with this term, okay, sorry.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So, this actually works out. So, the lambda term, lambda Y dot X, in that we are doing substitution where we replace X with lambda Z, Z applied to W. So, this works out. Just replace X with this term. So, lambda Y, lambda Z, Z, W, so that's fine. Here is the example where it actually fails, right?

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

This is a very simple example. So, I have an identity function, right? So, what is an identity function? Identity function just takes away, takes a value and then returns the same value, right? So, it takes an X and returns an X. And in that X, I am replacing that occurrence of X with Y. So, again, the important bit here is substitution can only replace free variables, right?

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

But as we've defined here, we are not checking whether the variable that we are replacing here is free or bound. And that's the problem that is occurring here, right? X is bound here. But if you directly apply the definition that we've described here, just as a function in NoCaml, it will go ahead and replace the bound variable X with Y, right, and the result that you will have is lambda X dot Y. This is bad, right?

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

What has happened here is the identity function, lambda XX has now become a constant function. What is a constant function? A constant function takes whatever value and then returns you the same constant. I'm just ignoring X here, right? I'm just returning Y. So, this is bad because the definition of substitution says you can only replace free variables. And I'm replacing a bound variable here, and that is bad, we have to fix that. And the way we can fix this

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

is by splitting this definition. So, all I've done is I took this rule, right? Okay, so I took this rule for substituting in the lambda, I split it into two different rules. The first one says that if the variable that I'm replacing, X happens to be the same name as the binder, right? Which means that X is bound in this term T1.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

So, there are no free Xs in this term T1 anymore, because any occurrence of an X here will be bound here, or it is bound like in a deeper binder, right? So, there is no need to replace anything. And so, just return the original term, right? Just return lambda X T1, which is the term here. If it is the case that the binder is not the same as the variable that you're replacing it with,

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3164.9s_

I am explicitly writing it down here as well, where X is not equal to Y, then go ahead and replace the occurrence of Xs in T1 with S, right? If it is bound, don't do anything. If it is not bound, then recursively go ahead and replace the variable occurrences in the body of the lambda, okay? This is also broken. We will see how it is broken in the next class. Okay, so I'll stop here, and then we can continue in the next class. Thank you. Thank you.

---
