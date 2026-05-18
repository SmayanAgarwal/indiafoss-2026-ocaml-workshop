# 17-cs3100-pop-lec-17-lambda-calculus-encoding-simply-typed-lamb

**CS3100 POP - Lec 17 - Lambda Calculus Encoding + Simply Typed Lambda Calculus**  
id: `kyR7d6d3Vfk`  
duration: 3085s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

All right, so yeah, okay. So continuing from where we left off, we were looking at arithmetic expressions, and in particular, we were looking at subtraction. So the last thing we saw was encoding subtractions, and we saw some examples.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

And the next thing we are going to see is equality. So I want to take two church numerals encoded in lambda calculus, and I want to say, I want to check whether they are equal. So if I gave you subtraction, and I gave you say, a language like C, and we already have seen that is zero function, so we want to check whether a number is zero or not. So if I gave you subtraction and is zero,

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

then you can implement equality by something like this, a test like this, where you subtract one number from the other. If the result is zero, then we know that these two numbers are equal. So this is what we can implement if I gave you integers, but we operate on national numbers. In particular, as we had seen earlier, I think here, so if I do two minus three, I get zero back because I don't have negative numbers

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

encoded in natural numbers. So if I do three minus four, I get zero. So if I directly apply the encoding that I have here, then I would consider three equal to four. So this is not what we want. And what we do want is this, right? If both M minus N is zero and N minus M is zero, which can only happen if the numbers are the same, right? Then we can say M equals N.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

So in this case, three minus four will be zero, but four minus three will be one. So M is not equal to N. So this is how we encode equality, arithmetic equality in natural numbers. Yeah, and it was the, yeah. So that's really what we want. The definition of equality is defined using all the operators here, right?

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

Is zero subtraction and logical conjunction, all of which we have so far built up, right? So we can implement is zero as first checking whether M minus N is zero and then N minus M is zero. And we have a conjunction here. And so if both of these cases are true, then the result is equal. So that's how we encode equality.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

Okay, so I can ask for equal to two. So I'll get true. I can ask for whether three minus two is equal to two, right, I'll get false. I can also ask whether two minus three is equal to zero. Yeah, so this will be equal to zero, right? Because we have natural numbers encoded. So two minus three is zero. So zero will be equal to zero. So that's why you get true here.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

Okay, so far we've seen a lot of arithmetic, right? So we will step up a little bit, right? So the thing with Lambda calculus that I told you earlier was it is as powerful as a Turing machine, right? So when I say it's powerful as a Turing machine, it does a Turing-complete language. And if it is Turing-complete, one of the defining features is we should be able

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

to encode the non-termination in the language, right? And we have seen an example of non-termination, this Omega operator that we had seen earlier, right? Where you can keep reducing and we will never reach a beta normal form. And that sort of hints that we can encode non-termination here. So the question then is, okay, so you can define regular functions, right? Anonymous functions and applications and so on.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

But one powerful way of defining functions that do useful things is recursive functions, right? I want to encode recursion in Lambda calculus, only then will I be able to express something like loops and so on. So how can we encode recursion, right? The hint is that we can encode non-termination. So we are going to use this idea that we can encode non-termination in order to implement recursive functions in Lambda calculus, right? This is also encoding.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So we'll have to come up with a clever scheme for encoding and here's the clever scheme, right? So before we look at how we encode it, I will introduce this concept of fixed points, right? So given a mathematical function f and some value x, we say that x is a fixed point of f if f of x is x, right? We just call that a fixed point for f, right? An example is consider f of x equals x squared, right?

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

This function f of x has two fixed points, zero and one. So zero squared is zero and one squared is one. And there are also functions which don't have any fixed points, right? So here is a mathematical function which is a successor function. So whatever value of x that you provide this function, it will always return a value which is not x, right? So this particular function is set to not have fixed points. A very curious fact about Lambda calculus

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

is that every Lambda calculus term has a fixed point, right? So any Lambda calculus term that you can write has a fixed point. What do we mean by fixed point for Lambda calculus? So for Lambda calculus, a term n is said to be a fixed point of f, right? If f of n equals n, where equality is beta equality. So you can reduce f of n to n, right? So that is meant to be fixed points. This is a very curious fact, right?

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

In untick Lambda calculus, for every f that you can pick, there is always an n that I can pick that is a fixed point. This should sort of tempt you, right? Because I can write simple functions like this which have no fixed points. But I'm saying I can always find a fixed point for any arbitrary Lambda term f. And we will see how that works, right?

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

And we go back to our favorite Omega operator. So let's consider d to be Lambda x x, right? Lambda x, x applied to x. And Omega is basically d applied to d, right? It's self application. So I have a d, I apply it to d to d. So if you apply d to d, all you get back is the same term, right? Which is Lambda, sorry, which is Omega. And this is what we've seen earlier, right? This is the Omega operator. If you try to beta reduce it,

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

you get the same Omega operator again. And this, if you try to beta reduce it, until you reach a beta normal form, the procedure will not terminate. It will go into an infinite group, right? So we can sort of use this Omega operator, modify it a little bit, to come up with this new operator called Y Combinator, right? So Y Combinator is this operator. So Omega is Lambda x x applied to x,

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Lambda x x applied to x. Y Combinator adds a little bit of additional terms on top of Omega. So we have an outer F, right? That's the function for which we are going to compute the fixed point. And we introduce a F around this x applied to x and the same way here, x applied to x, right? So just compare these two, right?

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

It sort of looks similar. It behaves very differently. The only reason why I put these two things next to each other is that we are going to use this idea of self-application, right? This is known as the Y Combinator. There is a very famous incubator called Y Combinator. I think some of you may know it. It's a startup incubator. It's been very successful, right?

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So Paul Graham was one of the people who started that. And Paul Graham has made like lots of investments in large companies now, Uber and Facebook and a bunch of companies which have went on really well. He's a functional programmer, right? So he started writing lists and he still writes lists a lot. And this Y Combinator website is written in lists. At least one of the backend is lists.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Okay, so that interesting anecdote aside, let's look at what Y Combinator can do, right? So here is Y Combinator applied to arbitrary function F. So this is some Lambda term F. I don't care what that term is. I'm just going to consider F as an abstract thing now. So what happens if I apply Y Combinator on F? I can try to beta reduce it, right? So the first thing I'm going to do is substitute

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

this big F for small f, right? Wherever you see a big F in this term, you substitute that, right? So we get a big F here and for this smaller figure big F, and this is self application now. So reduce it one step, one further step. So take this term, substitute this term wherever X is. So you get the outer F, right? And you get the same term repeated twice, right?

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

But if you sort of stare at this term, right? This term, the highlighted term, LO, is the same term as the term here, right? So it's the same exact term. So we know that we got here by reducing YF. So write this term, replace this term just by YF, right?

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

And what you end up getting is F, YF, right? So this F on the outside stays the same. We know that we got here by reducing YF, right? Because YF reduces to this term and this term is the same as this. So you can write this as F, YF. And if I write it out, so I have YF equals, right? Equality here is beta equality, equals F, YF. So if you sort of stare at this, right? You can sort of think about this as X equals F of X, right?

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

Where X is YF. So this YF, right? This YF is said to be the fixed point of F because for any F, I can always create a YF because I know what a Y Combinator is and I don't expect, I don't assume anything about the structure of F here in the Y Combinator application, right? So YF is said to be the fixed point of F, right?

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

Given any F, I can always create a YF which is going to behave as if this equation describes, right? If you apply F to YF, it's the same as YF, right? So, and you can keep expanding this one. That's the whole point. So you have a YF which is equal to F, YF. And we know this YF is equal to F of F of YF. And what you end up getting is multiple applications of F, right?

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

And this is sort of lies at the core of recursion, right? You can keep expanding it as much as possible. So you can use Y Combinator to achieve recursion, right? So the takeaway here is just like mathematical functions had a X equals F of X, where if you had a X equals F of X, X is said to be the fixed point of F. For any Lambda term F, you can always get a YF

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

such that YF is the fixed point of F, right? And Y is the Y Combinator. Okay, so that's the key bit here. So how do we use this to get recursion, right? So here is functional programming, one-on-one program, right? So when you start writing functional programs, this might be one of the first programs that you might encode that online, right? So write a factorial function, right? The usual recursive factorial function.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

What I've done in this lecture so far is I've sort of built up all of the operators that are necessary in order to encode this function. So we've seen equality, right? We've seen is zero. We've encoded the natural numbers, right? We've also seen multiplication. I also showed you read assessor, right? And we're going to see how recursive function application works, right?

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

Okay, so this part should be familiar, right? This part should be familiar. So factorial takes a natural number. If n is zero, then factorial of that is one. Else it's n times sum of n minus one, right? And what is this F? This F is supposed to be the function called used for the recursive case, right? In OKML, this would just be factorial, but we will just make it explicit here

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

because we are going to apply it through the Y-combinator. Okay, so just assume that this is just a recursive version of fact, right? Fact is just this whole function, but think about this F as the function that you're going to call for the recursive case, right? So the second argument is the integer, right? And the first argument is the function called for the recursive case. And we will use Y-combinator to actually tie the knot. So we want to say this F is actually the function

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

that we have here, and we are going to use the Y-combinator for this. So how are we going to use it? It's easiest to just look at an example, right? So we are going to make factorial. This factorial definition recursive. So the way you do that is apply Y-combinator on fact, and then I'm going to trace the execution of fact applied to one, right?

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

Factorial of one is one, we know that. We're just going to see how that expands out, right? So this is Y of fact, and we know that any Y of F can be expanded to F of Y of F, right? That is what we've seen here, right? Given any Y of F, you can always beta reduce it to F of Y of F. So I get fact of Y of fact of one, right?

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

Now I have a function definition here, and then I have two arguments, right? Argument one, argument two. I'm going to apply these two arguments to the definition here. So the definition here is, I can actually copy paste this for simplicity. So let me copy it, paste it here. Okay, so fact we know is this particular function, right?

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

So you apply, wherever F is there, you apply Y of fact, wherever N is there, you apply one. If you expand it, N is one, so you have one equals zero, then one else, N is one, right? And F is Y of fact, so you have Y of fact of, N minus one is zero, right? So you get a zero here, right? So we have also seen if then else,

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

we know how to do test, right? So one equals zero is false. So you get the false branch. So you have the false branch here. Expand Y of F once more, right? So you get from Y of fact, you get a fact of Y of fact applied to zero. Do this beta reduction once more, right? The same application here, right? So you have Y of fact, substitute wherever F is there, and then you have zero here,

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

substitute that wherever N is there. So you get one multiplied by, if zero equals zero, then one else, one into Y of fact of zero. Now zero equals zero is true, right? So you get one. So one times one is one, right? So that's how we get recursion out of this Y combinator. The one thing to consider here is we've been very careful about when we go ahead and reduce Y of fact, right? I'm not keeping on reducing Y of fact.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

Here I could have chosen to reduce Y of fact, but I did not choose to reduce Y of fact. I said, okay, I will do the application here, right? This is important and we will come back to this. Okay, so now I've showed you how this works. We can actually encode it here, right? This is the function that I'm going to encode. So this is the Y combinator, right? I've just written down the Y combinator here. I'm going to write down the factorial function.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

So the test here is n equals zero, right? So I have a is zero variable n, right? That's the test here. And then I have the false branch. What is the false branch? False branch is n multiplied by, so you have multiplied n and f of n minus one, which is application of f applied to predecessor of n, that's the false branch. And the true branch is just one, right?

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

So you can just build it up. So test, so the test here, true branch is one, false branch is fb, false branch here. And that's the factorial function defined for you. So now you can ask for a factorial of two. You get two out, you can ask for factorial of three. Takes a long time, right? So actually this terminates of non-termination because I have a depth limit of 10,000 by default.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

You can increase the depth limit by 10 times. This would work out. Just to show you that this works out, right? One, two, three, four, five, six, factorial of three is six. So you can try four. It will take a long, long, long time, right? So Lambda calculus is sort of useful for encoding these features, but it's not a practical thing for compilation, right? You don't want to directly interpret Lambda calculus

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

as we've done, right? Encoding everything in Lambda calculus, that's not a thing that we do in the real world. If you try four, this won't terminate, right? So that is, or it will take a long time to terminate. So we've actually encoded a non-trivial function here, which is factorial. So Y Combinator is how we achieve this recursion. So here is a question, right?

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

Y Combinator, which is just the Y Combinator here, is a fixed point Combinator under which of these reduction strategies? Is it call by value, call by name, or both or neither? What do you think is the answer? You can take this, I think that's fine.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

No answers, okay. I will tell you the answer. The answer is call by name. Why? Because under call by value, right? So if you look at this particular example, if you look at a particular example, I started with Y fact of one, right? In call by name, I can expand it once, right? And then I can say, okay, now apply this term to fact. But in call by value, what will happen? In call by value, you have to reduce the function term

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

and the argument term all the way, right? Both of them have to be in beta normal form before you can apply it, right? That's how call by value works. Just think about how you would do this in OCaml, right? If I have say F and then G of 10, I would reduce GF10 first to a value and then apply it to F. But we know for a fact that if you keep expanding YF, F, YF fact here, you can keep on expanding it on and on, right?

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

So if you use this in call by value, anytime you find a YF, F, you can keep expanding it forever and ever and ever, this will never terminate. So this particular program, right? The program here terminates because I'm using normal order reduction strategy, right? Which doesn't force the evaluation of the argument term, right? It only forces, it actually forces application whenever you can do an application.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

So in call by value, Y Combinator is not useful. It will just lead to non-termination, right? So what do we do about call by value? So is it the case that we cannot have recursion in call by value? No, we can have recursion, right? We have a Combinator called the Z Combinator, which is the intuition is it is just the eta expansion of Y Combinator. What is eta expansion? So consider the Y Combinator, right? The Y Combinator is just what we've seen.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

All we are going to do in Y Combinator is this is some Lambda term, right? This is just called M and we had studied eta reduction and we said if you had a function that is abstraction that is Lambda Y, M of Y, you can always reduce it to M, right? Recall the last few slides of the previous lecture, but we said if you had a Lambda X, MX,

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

you can always write it as M. And we had also seen this example of sign, right? Lambda X, sign of X is eta equivalent to sign. And that is precisely what we are doing here, right? We take the Y Combinator and then what we do is we have a term X applied to X here, right? What we end up doing is we add a Y to the front, right? We add a Lambda Y to the front and we apply Y here. This is serving no use at all except stopping the evaluation,

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

right? So we will see how that works, right? So you can go from Y Combinator just by eta expanding the correct term here to Z. So, okay, so I haven't told you what eta expansion is. So we've seen that eta reduction is Lambda X, MX to M. Eta expansion just goes the other way. Given any term Lambda M, pick a fresh variable X, right? Which is not a free variable in M.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

And then you can write it as Lambda X, MX, right? So that's the idea. So just to write it out, instead of just doing words. If you have an M, you can eta expanded to Lambda X, MX, right, where X is a free variable, X is not a free variable in M. If X is a free variable, then it gets captured here, right? So this bind and bind set, we don't want that. So this is known as eta expansion.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

And if you go the other way, it is eta reduction, right? If X is a free variable, sorry, X is not a free variable, then of M, then you can go the other way. Okay, so that's what we're doing with the Z Combinator. So just to see how it works, just like we did earlier, right? So we applied Y of F, now we do Z of F. We are going to substitute for small f, this big F. So we get Lambda X, F of this term, right?

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

The same term repeated twice. This is self application. So where X is found substitute this right hand side term, right? There is X, one X here, another X here, right? So you get the same term repeated twice. So you get the term repeated once here and then twice here, right? And you get the Y again here. Just like we did for Y Combinator, this highlighted term, this yellow term

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

is the same as the previous term here, which we know is ZF, right? So you can write this as ZF. Okay, so now what we end up having is, it is F of Lambda Y ZF Y, right? All that has happened compared to Y Combinator. Y Combinator you would have had something like F of Y of F, right? But in Z Combinator, if you use the Z Combinator,

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

then we get this extra Y in the front, this Lambda Y and Y. And this prevents further evaluation of ZF until it is applied, right? Until you apply some Y here. Why? Because in both call by name and call by value, we don't reduce under the Lambda abstraction, right? So we don't evaluate within the body of the Lambda. So this works out. And this is precisely what we want to do

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

to prevent further reduction, right? Whenever you want to suspend the evaluation of some expression until it is applied, you just add a Lambda to the front. And that is what we are doing here. And you can use Z Combinator for both the call by name and call by value. It will work out just fine. But it will not work out for normal order reduction because actually it will work out for normal order reduction because if it's a Lambda abstraction, it will work out.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

So Z Combinator is like, is the thing that you can apply for any reduction strategy, right? So yeah, okay. Okay, so that's Z Combinator. So, okay, so that sort of is what I wanted to say about recursion in Lambda Gathas. So the key takeaway there is we use the fact

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

that we can encode non-termination in a clever way to encode recursion, right? So we've actually written something non-trivial using just the Lambda Gathas that we had seen, right? So we've taken multiple steps, but the idea is that we've encoded a non-trivial program factorial just using the primitive Lambda Gathas expressions. So, okay, so the last thing that we are going to see in this encoding part of Lambda Gathas

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

is recursive data structures, right? So we've seen pairs, but pairs are non-recursive, right? So, pair is just taking two types and then putting them together. But in OCaml, you have algebraic data types, right? We've written lists and trees and all these expressive data structures. You can sort of encode any arbitrary interesting structure that you want with algebraic data types. And if Lambda Gathas can encode everything,

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

then it should be able to encode lists as well. So we are going to encode lists using just the Lambda Gathas encoding, right? And this covers, you can sort of take away this idea and apply it to arbitrary recursive structures, lists, trees, B plus trees, anything that you want, right? And we're going to use an encoding here where we take the constructors of lists

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

or any other recursive structures as arguments in the Lambda encoding. This encoding is called the Morgan-Sinscott encoding, right? So the key takeaway here is we are going to take the constructors as arguments. So how does it work? So what are the two constructors of lists? There is a cons constructor, there is a nil constructor, right? And if you want to encode a data type using Lambda Gathas, there might be several constructors, right?

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

Take each of those constructors as arguments. And that's the key idea here. Okay, so how does it work? So for list, we have two constructors. C stands for the cons constructor, right? And N stands for the nil constructor. And nil value is just the nil constructor. So I'm just going to return N for the nil value. So what does the cons function do?

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So cons is what is cons? Cons, you can write cons in OCaml as XXS, right? And thus, so this is what I'm going for, right? So it takes a head and a tail, and then returns you a list that has X for head and X is for tail, right? So it takes a head and a tail, HNT, right?

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

And then this is the encoding of the list as a data type. So every list takes the two constructors as arguments, the cons constructor and the nil constructor. And what are you doing here, right? I'm just applying the cons constructor to head and tail. I'm sort of saying, okay, that's the entire construction of what a non-empty list is.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

And this should sort of remind you of how we encoded, this encoding at least, should remind you of how we encoded natural numbers, right? So that's zero. And this is similar to one, right? But it has other things going on, but the idea is that we are applying a similar idea to one. Okay, so this is sort of the zero. And this is additional data that is present, right? In natural numbers,

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

we did not have any other additional data that is sitting in, but here we have some additional data that is sitting in. Otherwise, it is similar to how we encoded the successor operator, right? One, two, three, four, and so on. Okay, so that's the encoding, right? And the interesting bit is what we do with this encoding. So here is a list that has two under one in that order,

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

right? In OCaml, this would be a list that has two and one. So how do we do it? So you have a nil constructor, right? And they build a list with a singleton list with one, right? I do an application here. I take that list and then I append the two to the front, right? So I const to this list. So this L2 list is the same as two semicolon one in OCaml. Okay, so that's the list.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

So, okay, so what do we want to do with lists, right? So we put it together, we've constructed the list. So we want to also extract the values out. I want to destruct the list, right? So what are the two ways of destructing? So you can sort of imagine you want to implement equivalent of the head and tail functions in OCaml, right? In OCaml, if you ask for the head, you just get the head element. Otherwise, it throws an exception.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

And if you ask for the tail, if the list is non-empty, then you get the tail, otherwise it throws an exception. We don't have exceptions here. So we are going to cheat a little bit, but that's the intention, right? If I ask for the head and tail of a non-empty list, I get the head element or the tail element. Otherwise, I do something else. So let's see what we do here, right? So we know that the empty list is lambda C, lambda N, and the non-empty list is a construction like this, right?

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

It takes the const constructor, null constructor, and applies the function C to H and T, right? And if I want to extract H out of this, right, what do I do? The trick is this, right? We know we have a function, true and false, which can extract the first and the second element of an application, right? If C were true, then it returns H.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

If C is false, then it returns the tail, right? And that's the trick that we are going to do. So we are going to define the head function as something that takes a list, right, lambda L, and we know that the list takes two arguments, right? It takes a C and an N, it takes a C and an N. So for the first argument, we are going to pass through because we are going to extract head. So if the list is non-empty, right?

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

So we are going to substitute true for C. So this becomes true, right? I actually don't care about the N value, but I'm passing nil here, right? Why am I passing nil? If the list is in fact empty, I can't throw an exception. I have to return something. So I'm just going to return nil as a result, right? So the behavior is not perfect. I mean, it is untyped. So it is sort of returning a nil, that is fine,

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

but I'm sort of filling in the gap for the fact that I don't have exceptions in my lambda calculus at this point, right? So the idea here is head function returns the head if the list is non-empty and returns nil, right? The nil constructor if the list is empty. And similarly, if the list is non-empty, then because we pass a false here, we get the tail out.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

If the list is empty, then we get nil out. Okay, so that's the encoding here. So let's see how it works. So again, recall that L2 is two and one. So if I asked for the head of L2, I should get two. If I asked for the tail of L2, I should get a list, a singleton list, which contains one. If I asked for the head of nil, empty list, I should get nil because that is how we encoded it here. And similarly, if I asked for the tail of an empty list,

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

I should just get nil, right? So that is what we get here. So if I asked for the head of L2, then I should get the value two. So I get the natural number two out, right? If I asked for the tail of L2, I should get a list out, right? I get the singleton list, right? A list contains, takes a C and an N, the constructor is constant nil. And it's a non-empty list, right? Because it applies C to some value, the value is one, right?

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

The value is one, S of Z, this is the one. And the tail is nil, right? This is the nil constructor. And in the last two cases, you just get nil out. Okay, so that's a simple function that extracts the head and tail. And yeah, okay. So I've destructed it, I also want to test it, right? I want to check whether a list is,

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

I may want to check whether a list is empty or not, right? So I defined this function called list nil. So the idea is that if you apply this is a nil function on a nil value, it returns true. If you apply it on a non-empty list, which has a cons, then it returns false, right? So recall the definition of is zero function, right? Is zero function, we defined it like this, it takes a number, right?

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

And then we apply this function for S position, which takes a Y and always returns false. Because if you find an S in the construction, then it is not zero, right? Otherwise we return true. We do a very similar encoding here. So is nil takes a list, right? L and for the C position, we know that C takes two arguments. I actually ignore those two arguments. They are just the lambda X, lambda Y, I don't use that argument.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

I just return false. Because if there is a C present in that encoding, then I know that the list is non-empty, right? So I just return false here, which is similar to the encoding of zero, right? And for the nil position, I return true. So if you apply a snell to an empty list, right? This gets substituted for C, but I don't have a C there.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

So that gets thrown away. And for N, I substitute true, right? And the result will be true. So that's the encoding of snell. So here is just the encoding, return an OCaml syntax, right? And I can ask for whether L2 is snell. We know it is false, right? And the nil should be nil, right? That is true. So you get the false and the true.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

Okay, so that's the test. And the last thing that we're going to see is use this in a non-trivial fashion, right? So we've written in assignment one, you've written lots of examples using lists, right? Lot of recursive functions using lists. A simple recursive function is computing the length of a list, right? So here is the function for computing the length of a list encoded using just the lambda calculus

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

that we've seen so far, right? So it is also going to use the Y Combinator because length is a recursive function. So what do we do for the Y Combinator? For using the Y Combinator, we take F as an explicit argument, right? That is going to be the recursive function. Length takes a function, length takes a list as an input. If L is nil, then the length is zero.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

Else it is the successor of F applied to the tail of the list. Right, this is, at this point, this definition itself shouldn't surprise you, right? So here is the encoding. So I'm using, I'm encoding SNL L here as condition, right? SNL of L. And then the false case is successor of F applied to tail of L.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

So successor of F applied to tail of L, right? And the true case is just zero. True case is just zero, right? So I put it together. So the test condition, the true branch and the false branch, and I want a recursive function. So I apply the Y Combinator here, right? Now I have the length function. It's big, but that doesn't matter. So the length of the empty list should be zero and the length of L2 should be two, right?

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

Let's see if that works. It does, right? So we get the length of empty list to be zero and length of L2 to be two, right? So at this point, I hope that I have convinced you that you can encode the arbitrarily complex programs using Lambda Calc

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

and the Lambda Calc. So I hope that you can do that.               I hope that you can do that.  I hope that you can do that.  I hope that you can do that. I hope that you can do that. Everything that you want, right? Just using Lambda Calc test. So Lambda Calc test is Turing complete, right?

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

And all of the examples that you've seen should tell you that it is as powerful as the languages that we have, right? We used to program in our everyday life, right? In terms of able to encode what they do, not do it at the same performance or so on, but really encode everything that the real language does. But we don't use Lambda Calc test as it is, right?

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

The programs are pretty slow. So if you want to encode say 10,000 plus one, we don't have, we've encoded everything as primitive. We don't have any primitive values. So we've encoded everything using these Lambda terms. So if you have 10,000, it has 10,000 SS and then like a zero at the end. And simple additions will require thousands of function calls, right? Just doing 10,000 plus one requires thousands of function calls. It is also pretty inconvenient in terms of readability, right?

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

I cannot even pretty print these numbers. I mean, these are things that you can address, but it's not a real language that we want to program with. It is useful for reasoning about certain features that you might want to implement in the language, right? If I want to implement an advanced feature, I should be able to reason about it, encode it and show that it works just using Lambda Calc primitives, right? That's the idea here.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

And in practice, we use richer, more expressive languages like OCaml and Python and C++ and Java and whatnot. That include built-in primitives, right? We want to compile these languages efficiently to what the hardware provides. The hardware provides registers. It provides like primitive operators that can manipulate these values, right? And we want to take advantage of all of that. So we don't directly encode everything in Lambda Calculus.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

So that sort of finishes the Lambda Calculus, untyped Lambda Calculus lecture, right? So what we've seen is, we've seen how to take Lambda Calculus and encode non-trivial thingamas. Okay, so that is the Lambda Calculus encoding. Any questions on this one? I think there is a lot to take in this lecture and not everything that you can sort of understand just by sitting through the class.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

But what I hope you would take away is that the power of Lambda Calculus, right? And then focus on simple examples. You don't need to, I won't ask you to, so the thing that I asked in, I think quiz one in the last year was, take this list encoding, right? And then encode something for a binary tree, right? So this is what I had asked.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

If you wanted to encode a binary tree, how will that encoding be, right? So I won't ask you to encode some new thing like Boolean or something, but I might ask you to encode something that is a simple extension of what I've taught here. So if I ask you a clever encoding, I might even not know the answer, right? So I won't ask any of that in the quiz, but sort of go through this

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

and get the intuition behind how this works, right? So that's what I want you to do in this lecture. I have five more minutes, so I will just start the next lecture and then I'll anyway continue tomorrow as well. Okay, so far the lambda calculus

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

that we've seen is untyped, right? So we have no types, there is no static checking. In particular, we were able to, we were sort of carefully working on only writing down correct terms, right? So there is no type safety. So you can go terribly wrong if you pass a function that takes three arguments where you expect two arguments, right? I sort of cleverly avoided all of that,

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

but languages like real languages, right? OCaml, Haskell and C++ and Python and say Java have types, right? And so in this lecture, what we will do is we will add a very simple type system on top of lambda calculus. So lambda calculus is a very small language. So we will add a simple type system on top with the hope that you can appreciate what type systems bring for a language, right? So that's the takeaway there.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

So we will study it in the small, right? And the hope is that by studying type system, a simple type system, just for this very small language, you can appreciate what type system brings you. And we will study a bunch of concepts as well, right? Some principles that we can already see in this very simple language. Okay, so the, yeah, so we call it simply typed lambda calculus because we use simple types

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

and we'll see what the simple types are. So consider this untyped lambda calculus, right? So as someone observed in the last class, the encoding of false was the same as encoding of zero, right? So we have no, we can mix these two things together, right? Where you would have expected a natural number, you get pass a false and that would have been fine because the encoding is the same,

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

but we can also misuse the terms, right? I can apply false to zero. False is supposed to be, false is supposed to be this thing that you pass two values for, right? But if you just pass zero, you'll get an identity function. It's not clear whether you're doing something interesting here and you can also write something like if zero, then right, test if zero, then this is not going to work, right? So this is actually this will work,

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

but you're mixing up terms here. So this is not something that would be accepted by the OCaml compiler because everything evaluates to some functions. You can mix up places where you expect three arguments to what you do with two arguments, right? So this sort of creates a lot of confusion if you wanted to program with this language in the real world, right? And the same thing happens in the assembly language.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

In the assembly language, everything is a machine word. It's a bunch of bits. So all operations take some machine words and take implement other, return you modify other machine words. So unless you are pretty sure what you're doing, you can easily make lots of silly mistakes, right? And the hope is that you can avoid a lot of these mistakes by adding a type system on top, which will catch most of the errors that compile time rather than you running the program

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

and then finding out what things go wrong. So, okay. So how do we fix these errors? We use type lambda calculus, right? And we are going to take the lambda calculus syntax, like just the expression language that we have seen in the previous class. We are going to add types on top. And what we end up getting is what is known as simply type lambda calculus, right? We use the symbol lambda superscript arrow

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

whenever we want to identify simply type lambda calculus, but that's just a, I mean, we only use that because this is too long, right? And I might also use STLC if it is not clear what sort of lambda calculus that we are using. So, okay, so I think I will stop here and then we will start seeing simple types on top of lambda calculus

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3080.9s_

and what they can do in the next class. If you have questions, I'll just hang on for a minute and then I'll wander off. Then you can ask questions offline as well. Stop recording.

---
