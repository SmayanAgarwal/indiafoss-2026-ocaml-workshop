# 15-cs3100-pop-lec-15-lambda-calculus-semantics-encoding

**CS3100 POP - Lec 15 - Lambda Calculus Semantics & Encoding**  
id: `xmpoTpAP8C0`  
duration: 3366s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

OK. So what we are looking at in the last class is various different reduction strategies for lambda calculus. And we had looked at, I mean, we went down this deep rabbit hole. So we said, OK, there's this nice thing called reduction.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

And I told you there are several different kinds of reductions. You have full beta reduction. You have normal order reduction. And then you have call by name reduction. And we saw a specialization called call by need. And we saw call by value. So the idea is that all of these reductions exist for very pragmatic reasons. So some are very theoretical. Like full beta reduction is non-deterministic.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

And normal order is reducing on the lambdas, which is sort of not what real languages do. And this call by need and call by value are practically motivated. So they sort of capture the essence of two different paradigms of functional programming. So basically, the evaluation strategy. So the one is lazy evaluation. Haskell is the sort of epitomizes lazy evaluation in functional programming.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

I mean, it's sort of the other popular functional programming language, which tends to be more popular than OCaml. And then when people think about functional programming, they sort of, if they know a particular functional programming language, it might usually be Haskell or Scala. But Haskell is sort of is puritan in terms of the sort of functional programming style it espouses.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

And certainly, Haskell has weird semantics for a lot of the things, including evaluation. And the call by need is what it does. And it mirrors lazy evaluation done in Haskell. And call by value is what the evaluation strategy that all the languages, including every language that you've probably programmed with. So all the C, C++ languages, Python, everything, and OCaml also use call by value.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So call by need is lazy evaluation. Call by value is strict evaluation. So that's what we saw in the last class. So we also studied this notion of beta equivalence. So if I give you two lambda terms, I can ask whether these two terms are beta equivalent. And the way you do it is if you reduce it, would you reach the same term, modulo alpha equivalence?

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So this is a nice equivalence property that you can have for lambda calculus. The higher level question you might ask is like, I give you two programs, OCaml programs. That's the two OCaml programs that I give you, the functions I might give you behave the same way. If I want to capture the behavior of the two functions, you might want an argument that is similar to beta equivalence.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And beta equivalence works very well for lambda calculus because it lacks many of the features that OCaml has. But the question you want to ask is whether beta equivalence is the best notion of equality between lambda terms. And it turns out it is in because it misses out one corner case. And the corner case is presented here. Consider this statement.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

So it says lambda x dot sine x is beta equivalent to just a function sine. If you sort of imagine, so first thing you want to ask is whether this equivalence holds, it doesn't. Because this is already a beta edex, you cannot reduce it anymore. Assume you have this sine function, primitive sine function that is exposed. So according to the definition of beta equivalence, these are not the same.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

These are not alpha equivalent, certainly, because there are extra lambda abstractions here, which is not here. And they are not beta equivalent because you cannot go from one to the other by either reduction or saying they are alpha equivalent. But we know that these two functions are the same. All the function here does is whatever argument that you pass here, it simply calls that function. So sorry, it simply applies sine to that value.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So intuitively, this should be equivalent to this definition. But beta equivalence and alpha equivalence doesn't capture this particular equivalence. So in particular, just to put it formally, for all, if I say for all m, once you add this m, these two terms are certainly beta equivalent because you can reduce it.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

At this point, this is a edex. So you can throw m here. And you will get sine m and which is sine m, which is the same term, alpha equivalent term. So this equivalence holds, but this doesn't. So this is sort of unfortunate. This is like, oh, we've done all of this hard work. But there is this small thing on the side which you have to worry about.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

And really, what we have is another form of equivalence. This is very, very simple. This is not going to be very complicated. And all it says is that if you have a lambda x mx, we call that eta equivalent to m if x is not a free variable of m. So the premise is important because if you have an x here, which is used in m,

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

then the meaning changes. So this will be, let's say m is just x, in which case this is lambda x applied to x. But this would be just variable x where x is a free variable. So this particular premise is quite important. Under this premise, if you sort of say x is not a free variable of m, then this equivalence intuitively holds. And this is what we call as eta equivalence.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

And it turns out that beta eta equivalence captures the equality of lambda terms quite nicely. If you want to say, I have two lambda terms, are these equivalent? Are the behavior of semantics of these two lambda terms equivalent? The best equality that you can sort of hope for is beta eta equivalence. Beta eta equivalence just says that it is either beta equivalent or eta equivalent.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

So we also have this idea of, just like beta reduction, we have eta reduction. And again, this is directly using the intuition. So if you have a lambda x mx, then you can eta reduce it to m. You're just throwing away the subtraction that is sitting for no reason. So you're just throwing away that to get m. Actually, we've done that in the example. When we first looked at higher order functions,

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

so we had this example of shirt color. And we said, OK, I'm mapping this list.map function. Sorry, I'm using list.map over a list. And the function that I'm mapping is for every element, get the shirt color of x. And I said, OK, this is equivalent to just applying shirt color directly.  So and this is more idiomatic. We often don't write it explicitly like this,

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

because we are adding this anonymous function for no reason. This color takes whatever the element kind is and returns a shirt color. And this does the same thing. So eta equivalence is very intuitive. We've actually done it previously. So that's eta reduction. And that concludes the lecture on the semantics of lambda expressions. So we've seen a lot of different things.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

I can directly sort of go to the next lecture and sort of do a recap. Yeah, so what we've seen is we saw beta reductions. We just focused a lot on beta reductions. We saw different reduction strategies. We also saw what normal forms are, what is beta normal form.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So you reduce something to a lambda term, which cannot be beta reduced anymore. And the last thing that we saw is extensionality. So this extensionality just means eta equivalence and eta reductions. So that sort of captures the semantics of untyped lambda calculus. Entirely. And as I hinted in the first lecture, so lambda calculus is equivalent in expressive power to Turing machines.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

So you should be able to encode all the things that you do in a high level language just using lambda calculus that we've seen so far, which only has, say, anonymous functions and has functional applications and variables. But they are sort of falling out of the fact that you have functions. And in this lecture, what we will see is we will look at how to encode higher level programming features. You'll see Booleans.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

It's good enough because, so there is a question. Sir, can you provide an intuition of how it was proved that beta equivalence is good enough? We don't have a proof. I just told you it is good enough. So you have to take my word for it. It's just a, I think it's hard to quantify what a good enough

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

says. So we are sort of looking at program equivalence. And the idea of, so it is both defined and given by this very definition of beta-eta equivalence. How do you define two terms that are equivalent? We say beta. We observe that there is this corner case that is not sufficient. But we don't have a completeness argument. So that's the answer to your question.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So getting back. So the thing that lambda calculus has is, so is there an eta equivalent version of lambda xx? No. So there is no eta equivalent because that's an identity function. In eta equivalence, it is always the case that you have a lambda x fx. Some f applied to x.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

And all you're doing is saying, I'll just take this as x. Sorry, f. I'll remove the useless abstraction that is sitting around it. So you cannot have an eta equivalent version of lambda x x. Yeah, it is a function. But eta equivalence can be applied when there is an application in the body.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

You can get the eta equivalent term of this. I can sort of wrap this lambda xx term on the outside with the, so let me. So you're asking what does the, give me an, if I just sort of take your question as, I have a term which is lambda xx. And I want to get another term which is eta equivalent to this term.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

I can say this, this, right. I'm just adding a new layer. So these two are eta equivalent. This y is useless. Yeah, but you cannot make this smaller anymore. This is the actual function.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

This is like m. And what I have here is, which is equivalent to, oops, I don't know why this is getting bigger. But this is equivalent to, so you can go from this to this using eta reduction.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

But you can't make this m smaller anymore. Okay, so I'll sort of get back to this lecture. So, okay, so the thing that we have in lambda calculus is we have a single value, right? The value is the function definition, right? So the anonymous function is the only value that we have.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

But real languages have a lot of other things going on, right? It has Boolean, it has floating point numbers, it has arithmetic, it has algebraic data types, right? In OCaml, we have the ability to define algebraic data types like lists and trees and so on. We have record types, we have tuples and triples and whatnot. So if I tell you, right, so you can encode all of these using lambda calculus,

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

you have to ask me, show us an example, right? Show how to do all of this. This lecture is all about showing you how to encode higher level features, right? Including Booleans, arithmetic pairs, we will also encode recursion, right? You have this ability to write recursive functions in OCaml. It turns out that with untyped lambda calculus, recursion naturally falls out. So the way to, so one word of warning about this lecture is,

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

it will look very much like puzzles, right? So this is going to be a little mind bending. It is unlikely that you will learn everything, the way how encoding works just in this lecture, right? When I explain it, it might just, it might not be easily picked up by you. Because the reason is not that this stuff is hard.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

This is just like, if you're sufficiently smart, you can come up with these encodings, right? And these encodings are a long, they have a long tradition of knowledge, right? So no one person came up with all of this encoding just in one day. So it's sort of, and there is no easy recipe that you can follow. I can't tell you, okay, if you want to do XYZ, you have to follow this recipe.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

So the way this lecture is going to be organized is we are going to look at a lot of examples, right? And you can sort of look at that example and maybe extend it a little bit further. But I won't ask you, say, encode records using lambda calculus, right? I'm not going to ask you questions like that. This is just an explanation of the expressive power of lambda calculus, okay? So yeah, I think I mentioned all of this in the first slide.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

We also encode predicate logic, right? So this is what we meant. So we can encode any computation that we want. If we are sufficiently clever, right? So I'm not going to force you to come up with an encoding of something completely new on the flight, on the exam, right? So I'm not going to do that. So, okay, so with that, let me clear the output. At least not a clear output.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

Okay, so again, I'm going to bring in the evaluators so that we can interactively explore these encodings, right? So I'm using unit.ml that brings in loads of the definitions. I'm going to use a bunch of aliases, right? Which are short form for expressing the expressions and parsing and so on.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

So I'm going to use the function mp for parsing a lambda string into a lambda ast. I'm going to use var that just stands for the constructor var. So for application, I'm going to use notation where it takes a list of things, right, so and then applies from left to right. You will see examples as I explained it. I'm going to use lamb for the constructor lamb.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

It takes an X and an A and it's just constructing this lambda. And they have an evaluation and the evaluation order that I choose is normal order evaluation. So the thing to remember about normal order evaluation is it reduces under lambdas, right? This is important for making sense of all of the encodings here, right? So whenever I call eval, all it's doing is it's evaluating in terms of normal order reduction.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

Okay, so here are some examples. So I bring in all that function. So p of lambda xx parses that into So parses that into lambda x, var x, right? And var x is just the ast var x. I have a short form for application that can apply a list of lambda terms, right? So you can sort of imagine this to be just a short form for

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

writing something like x, y, z, right? So this is the term that I'm writing. So I use, so this is interpreted as x applied to y applied to z, right? And that is what you have here. X applied to y and the result of that applied to z. So writing as lists, yeah, you can, what is the notation?

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

Where is, this one, okay, good question. I'll finish this. So lamb xy is just lambda xy. So this is, I don't know whether we saw infix functions. We did see infix functions a little bit, right? And I write something like this. This is a inter or inter int, right? This is just integer addition, but I can use this as a function as well, right?

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

This function definition is just, it's by using these brackets, right? I'm defining an infix function so that you can use it like five plus six, which is 11, but you can also use it just like a function, right? Five, six, right, which is also 11. So you can ask, okay, what is the operator this doing? I'm using this in infix position, right? But it's actually a function.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

And all that function does is takes a value, takes a function, and then applies this function to this value, right? So it's like, it's the same as rev apply x f fx, okay? So that's the entire definition of that. I'm using instead of rev apply, I'm using the name like this, right?

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So, and this is just a handy pipe operator. So if you programmed in Unix, right? We use this pipe operator to pipe results through. And it turns out that this comes in very handy. So s is some input value that I pipe to this function, which produces some output value, which I pipe to this function. So what am I doing here? I'm taking a string, right? And I'm piping this to evaluation.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

Actually, s is a lambda expression, right? So which I pass to this evaluator, which produces an AST for me. I want to print it in a nice fashion. So I'm converting that to a string here, right? So you can do, for example, let me give you one example, and then I'll sort of stop.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

So you can do suck, right? And this gives me two. And you can keep piping this, right? It gives me three and so on. Does that make sense, Satyak? Yes, no? Okay, again, this is not magic, right? This is just a function definition that I told you. It's an infix function that takes an argument and then takes the function and applies that function on the argument and

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

returns the value. We won't use this often. I just happen to use it for no reason. Okay, so we have these helper definitions. Okay, so with that, we will sort of go into our first encoding. So we want to define Booleans now. First thing we want to do is define Booleans. So what do Booleans provide you, right? Booleans have two values, right?

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

A Boolean value could be true or false, and you have some operators over the Boolean, right? You have if-then-else, which checks whether something is true or false, and based on that, takes another branch. You can have Boolean operators on Booleans, right? And or not, and all of that. So we will try to encode all this, right? So we want a definition of the Boolean constants, right? True and false.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

And then we want functions that operate over these constants, okay? But in Lambda calculus, we only have function abstractions, right? We can only use function abstractions. So in order to encode what a Boolean true or false value is, we will use functions, right? Here is the definition of true and false, okay? So it might seem quite strange, but

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

all that I say a true value is, it's a function, right? That takes two arguments, true and a false, and then returns the first argument, right? So observe that in Lambda calculus, everything is a function, right? So we sort of place this higher level meanings on top. When I say something is a true and a false and it returns true, all I'm doing here is I'm defining a function that takes two arguments and

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

returns the first argument, right? And for false, I'm saying that is also a function that takes two arguments true and d and f, and then returns the second argument, right? That's the entire definition of true and false. You can ask, okay, I don't understand this. What is the point of using this definition? Actually, in order to understand why the definition is structured this way, we have to look at the functions that operate on them, right?

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

The only things that can manipulate these constants are the functions, right? So now let's define a first function, right? And what is this function? It's going to work just like if then else, right? Test is given a true and two branches, v and w, whatever needs to happen for v and w. If it is true, it is going to do whatever v is going to do. So by that, if you take this expression test, right,

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

the function that we are going to define is true, which is the value that we've defined here. Two other lambda terms, v and w. If you beta reduce this whole thing, it will reduce to the first argument here. Now this term, test, false, the constant false here, vw, if you beta reduce it, gives you the second term, w.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

Right, this is all it is doing. So here is the actual definition of test function, right? So the thing to notice is this takes three arguments, right? This takes a true, a Boolean value, a term for the left hand side. Sorry, the term for the true branch, a term for the false branch. So test is going to be a function that takes three arguments, lmn, right? And the thing that is quite important here is we know that

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

the first argument is going to be a Boolean value, right? And what is a Boolean value? A Boolean value is a function that takes two arguments and returns either the first or the second based on whether it is true or false, right? So the first one is a Boolean value, but we know because of the encoding that is a function, so we simply apply l to m and n.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

So the idea here, I'm trying to repeat the same thing, but the idea here is that if this l is true, right? And this l will be true and I pass m and n, because it is true function is going to return the first argument, it is just going to return m. If l is false, right, this will be false and false is a function that just returns the second argument.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So it is going to return n, right? And that's the entire definition of the test function, right? It doesn't matter what it prints, right? So that is just an expression. So let's look at how this works, right? So if you apply test through vw, it has to return v. So it is going to do the true branch. So let's see whether that works, right?

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

So I'm applying test true, right? And two variables v and w. This could be arbitrarily complicated expression because this is just the lambda expression. For simplicity, I'm writing down expressions this way, and I evaluate that expression. Okay, so first thing to notice is it is working correctly, right? So when I evaluate this through vw, it reduces to v.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

That is the specification that we described here, right? It reduces to v. And you can see that the final result is v. And how did it actually work? So this is just an expansion of all of this, right? So test this function which takes three arguments, applies for the first argument to the second one and the third one, right? True is just lambda tf returns t and then vw. So we are doing normal order reduction.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

So we reduce the leftmost thing first, right? So the true value gets substituted for l. So the l value gets substituted with the true value. And then we have v and w, which gets substituted for m and n, right? Stepwise, and you get this particular definition, which is true applied to v and w. And what does true do? True just returns the first argument, right?

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

It ignores the second one, and that's why you get v. So here is a definition of what you will use, right? I could have renamed this as if then else. So if then else is a function that takes a Boolean, and then that's the first true if the value Boolean is true and false if the value passed is false. I'll pause here because this is going to be the structure in which we are going to look at all of the encodings, right?

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

Let's make sure at least we understand this particular encoding. You should have questions, right? Or you might understand it completely. If you have questions, now is your time to ask. No questions on this, okay. Then let's level up, right?

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

Okay, so we can return functions, right? Yeah, yeah, everything is a higher order function here. Yes, we can return functions. This could be arbitrarily complex, right? This could be a function as well. This could be instead of variable, it could be lambda as well. We try to lambda x bar x, right?

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So this is identity function lambda x x. So we return x x. This is exactly how OCaml operates, isn't it? You're asking a really good question, right? So is this exactly how OCaml operates? Yes and no. The semantics is the same, right? The semantics is exactly the same. So we have some extra syntax on top. In OCaml, I can write a function, right?

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So which is a net test, v Boolean, v w, which would be something like if then v else w. This function behaves the same way as whatever we do here, right? But this is not how OCaml implements this function internally. That is not how it is compiled, right? This is actually compiled to something very efficient, right?

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

Just like how C would be compiled to x86 code. This is compiled to x86 in OCaml. But that's the point, right? We can understand the semantics of how OCaml works without having to tell you how this function is compiled. I have a different language in order to tell you how this works. And that's the point of studying lambda calculus. Good question. OK, so structure is the same. Yeah, so we are writing OCaml here.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

So you can write. So one thing that is different is this is untyped, right? So let me try a different thing. I'm just trying something different.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

So this works in lambda calculus, right? But this particular function, if you encode directly, in OCaml will not work. Because in OCaml, we have the static semantics as well, right? The semantics says that the type of the left and the right hand side branches must have to match.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

This is an identity function, right? And this is a function that takes two arguments and then returns the first argument. The types of these functions will be different. So this is alpha to alpha function. This is alpha to beta to alpha function. So OCaml will not let you, will not accept this function. But modulo that, yes, it's the same. I'm sort of answering a different question to the one that you are probably asking.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

But that does that give you more information?  You said test takes three arguments. But it is actually taking one argument at a time, right? Yeah, just like OCaml, yes. Yeah, I'm sort of using these terms loosely, right? Because taking a function, taking three arguments is the same as a function taking one argument, returning a function, taking the second argument, returning a function, which takes a third argument,

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

returns something, just like OCaml. So when I say it takes three arguments, it's just far fewer words than actually explaining what is going on. But the intention is the same. Is there a notion of efficiency complexity in lambda calculus? Or you can think about efficiency and complexity in lambda calculus in terms of how many, say, applications you have to do.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

So if you sort of give a cost of one for each application, there might be different ways in which you can reduce it. So you can come up with the cost semantics. And this is what people do. Yeah, so yeah, you can do cost analysis on lambda calculus. We won't do it here. So I think I've answered a few questions. Any more questions?

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

OK, so I will continue. So here is the false. So the same example where instead of true, I apply false. The result should be w for this one. So if I run this, I get w. You have the evaluation here.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

But the evaluation, you can sort of know how beta reduction works at this point. So it's quite easy to follow what's going on. So I would leave it to you. Sometimes if there is anything interesting, I will explain it. Otherwise, the steps are defined here. And the reduction that we use is normal order reduction. So you just follow it along, and you will understand what's going on. OK, so it turns out that false itself is a function, right?

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So all test is doing is it's taking a function, the two arguments, and then applying this function to the both arguments. And in fact, test false vw is equivalent to false vw. It's not a star at this, right? So this is test false. Test false vw.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

It evaluates to beta reduces to false vw. So actually, test is not adding any value at all in our exploration. So we will not consider test anymore. Wherever you want to say test false vw, you can just say false vw because both are the same thing. So false vw just returns the second argument. So false vw just returns w.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

And so we are sort of, because our constants are actually functions, so we can do this here. We don't have this separate notion of what a constant is. The value for us is actually a function, so we can happily do this. OK, so that's the true and false definition. Now we want to do more things, right? We want to perform logical operations and nor and not and so on.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So here is and what does and do? True and false. If both are true, then return true, otherwise return false. And the way, so OK, so what is, let's first establish what the signature of and function should be, right? And takes two arguments. It takes a Boolean 1, Boolean 2, and then returns a Boolean. So here is the definition of and operator, right?

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

And takes two functions. Sorry, and takes two Boolean values, a b and a c, right? And we know that every Boolean is also a function, right? So you can directly, in order to test the value of the Boolean, you just apply the function. So the way to read this is if b is true, then the result is whatever c is.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

If c is true, then the result is true, otherwise it is false. If b is false, right, which means the second value will be returned, so it just return false directly. So sort of look at this as if b is true, then the result of and is whatever the result of c is. If b is false, then we just return false.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

And similarly, what is r? R has the same signature, right? A Boolean to Boolean to Boolean. So it takes two Booleans and then returns a Boolean. If one of the values is true, then you return true. So the way we do it again is it's a function that takes two Boolean values, right? If b is true, then the result of r is true. If b is false, then it is whatever the value of c is.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

If c is true, then it's true, otherwise it is false. So not think about negation. Negation is a function that takes one Boolean, right, and returns another Boolean, which is the negation of the value that is passed, right? So it is lambda that takes the argument b. And the way to read this is if b is true, then the result is false. If b is false, then the result is true.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

So this is the encoding of not. And we have all the logical operators, and few of the logical operators defined here. Any questions on this? Again, these are like puzzles, right? I'm sort of constructing these intricate puzzles that just work out. So here is the definition of and, or, and not. I'm using underscore here just so that this doesn't and, or,

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

and not are the reserved keywords, right? So I don't want to. Yeah, so if you do and, it highlights that as a keyword. So that's why I'm using an underscore. The definition here is the same as the one here, written out explicitly. And is Boolean c false applied to true?

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

And is Boolean c false applied to true? I don't understand the question, Deepesh. And is c false applied to true? So, OK, so I don't understand the question.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

So let's, you can actually, OK, true is also a function. Yes, true is also a function. Yeah. True is also, everything is a function. So we don't have anything else in Lambda calculus. So the way you sort of look at this is it's a Boolean. So we know that the structure of a Boolean is that it takes two arguments and then returns one of them based on whether it is true or false, right? So that's why we are applying it to two arguments here.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

Yeah. So you can play around with the implementation, right? You can actually ask all of the questions that you have by interacting with this notebook and then playing around with it. Let's look at a few things, right? I want to speed up a little bit. So and or not is defined. Again, this is just an encoding of what I'm doing here. For example, I'm defining Lambda b. b applied to false true.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

b applied to false true. So the rest of the things are the same. Again, this is not important. It's just the AST that is being printed. But what is important is whether the operators actually work well. What is the result of and true false? It should be false. So you can evaluate this. The thing that you get here is a Lambda which has the same structure.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

It's alpha equivalent to the false definition that we had earlier. So for example, this is false. So that's false. And the result of evaluation is alpha equivalent to false. So we are actually performing computation which is yielding as false as a result. So that's the way you have to read it. So this is yielding as false as a result. You can sort of look at this as a proof

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

that true and false is false. So because we are actually evaluating this to false by not assuming anything about how the thing operates underneath. Everything is defined just through Lambda calculus. And you can also encode the higher level operators. So we can encode logical implication using the standard formulation.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

It's not B or Q. And then here is a theorem. The theorem says that for all AB, if A and B holds, then A holds. This is obvious. So the way we have proved this on paper, so we will actually use a truth table, for example. So you use the standard definitions

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

of how these things work and then prove it. So you actually reduce it to true eventually. So just like doing that, we can use Lambda calculus to do the proof. So here is implication. All it says is, so implication takes two arguments. You can imagine this to be a function that is applied over a P and a Q. So it takes P and a Q

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

as an argument. And the definition is not B or Q. So R is on the outside. So there is an application R on negation of P and Q. So we are directly encoding what implies this using Lambda calculus. And I've sort of encoded theorem 1 also as a function. So what is theorem 1? Theorem 1 says for all AB.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

So I've encoded that as a Lambda A, Lambda B. I'm saying implication of A and B is A. So A and B implies A. It's what I've written down here. So I've written that down. It expands to a large thing. That's fine. I've just written down the function. I've defined the implication. I've defined the theorem 1 statement.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

How do you prove this? By pen and paper, you can prove it by truth tables. And here we can do prove it by case analysis. So there are four cases. A can be true, false. B can be true or false. In all of those cases, this theorem should be true. Whatever that evaluates to should be true. So here is the way to do it.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

So there are four cases for A and B. So true, true, true, false, false, true, false, false. All of these should evaluate to true, which means that the theorem pulls. So here is the evaluation that evaluates to true. Theorem 1, true, false, evaluates to true. Theorem 1, false, true, evaluates to true. Theorem 1, false, false, evaluates to true. So by case analysis on A and B, we've shown that this theorem pulls without using any of the usual mechanisms.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

We are not constructing truth tables. We are not working through. We are not using our logical reasoning to say, OK, implication is encoded in a way that it is not PRQ. So we can expand it. We're not using any of that. We are actually using lambda calculus as a way to prove this particular theorem just by evaluation. This is a different way of. So just to give you a hint, there

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

is a field called program verification, in particular computer aided program verification, where the idea is that instead of doing proofs on paper, we will use proof assistance, which are just software programs which help you drive the proof. They are not going to automatically give you the proof. They help you say, OK, if you want to prove this, prove it by case analysis. So you have to show that each of these cases hold.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

Or you have to tell the proof assistant that you want to prove this by case analysis. And once you tell that you want to prove by case analysis, the computer knows what to do. These are Boolean values. So there are two values here, two values here. It has to evaluate the true for all of the cases. So we've sort of encoded a very small theorem prover using lambda calculus here. We are doing it manually. But this is the principle by which all of these computerized

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

theorem provers are actually implemented. They're doing something very similar to this underneath. So that, and hence proved, we've proved all of the cases. So the theorem holds. Let's do this quick, quiz, and stop. So what is the lambda calculus encoding for exclusive R, x, and y? So what does exclusive R do?

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

If both are the same, then it is false. If x and y are different, then it is true. So one of these is the correct answer. Can you guess which one it is? These two are, again, these two are just Boolean values, x and y. Yeah, good. So third is the answer. Why?

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

Because if x is true, then go and check if y is true. If y is true, then return false. If y is false, it is true because we are in the true branch of x. Similarly, if x is false, if y is true, then this whole thing returns true. If y is false, it is false. So that's the reason why this is true.

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

So you might expect questions like this. So I'm not going to ask you to design Booleans, but I might ask you to say, OK, what is the lambda calculus encoding for NAND? So I'll give you four options, and you have to pick one. That's the level of questions I expect in the final exam. Yeah, OK. So OK, I'll stop here.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

And we can continue the rest of the things on Monday. This lecture is a bit long. We will slowly go through it. But the idea is that you're going to see a lot of stuff in this lecture, which are going to be sort of mind bending. It is better to take it as it is.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

So don't try to understand how something came about. Try to understand what it is. That is a better way of understanding this lecture. So I'll stop here, and then we'll continue on Monday. Thank you.  Yeah. Sir, can you hear me? Yeah, yeah, I can. Sir, I had a few doubts that I came across while solving the assignment. So should I ask you right now? Yeah, yeah. I think if it is something that we can ask in public, then sure.

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

OK, so we have the fifth question in the assignment in which we had to bucket the elements in the list. So the issue was that I wanted to iterate a list inside a list, right? So do you have any pointers on how I can go about that? You can use a fold inside a fold, right? So that's totally fine. So does that make sense?

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

Fold inside of fold, right?  Can I use a nested match? Yeah, you can use a nested match, but if you really want two for loops, two folds is what you really want. OK, in a way, the fold is an analog of for loop in public. Yeah, yeah. So think about fold just as a for loop, right? So it might look weird, a little bit weird,

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

but I think using that is the most natural way of doing this. OK, OK, sir. And so the other question was that we have this if true, then do something, and else do something else. We have this kind of if-then-else expression. So in impenetr programming, we have this concept that if true, then do a certain block of instructions, and it falls into something else. So can we execute a certain block of instructions if it is true, otherwise?

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

So the expressions could be complicated, right? So if true, then I can do print string hello, right? And print string world. Right? Else unit. Yeah, I need. Yeah, so this, it's not printing, but I don't know why it's. But do you see what I'm doing here?

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3300.0s_

OK, so essentially, I have this. You can use semicolon, right? So you can just write it like this. It'll just look imperative.  OK. OK, sir. And so last thought was that let's say I want to create a function which takes some integer value. It's an integer, right? It doesn't take 3.0. It takes 3. And I want to add 1.5 to it and then return it. So how can I create such a function?

---

![slides/interval_0111.png](slides/interval_0111.png)
_t = 3300.0s -- 3330.0s_

OK, so there are two functions called in of float of width. OK, so I'll have to convert. Yeah, so you have to explicitly convert because implicit conversion is not a thing that we allow in OCaml. Yes, sir. OK, OK, thank you, sir. Yeah, OK. Any other questions regarding assignment? No, sir.

---

![slides/interval_0112.png](slides/interval_0112.png)
_t = 3330.0s -- 3356.9s_

OK, so I'm hanging around. So if others have any questions, now is the time to ask. Thank you, sir. Yeah, sure, OK. OK, so if there are no other questions, you can always ask me on Slack. I'll be there. Thank you very much. Bye-bye.

---
