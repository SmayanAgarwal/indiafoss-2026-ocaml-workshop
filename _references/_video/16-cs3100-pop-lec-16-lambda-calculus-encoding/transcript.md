# 16-cs3100-pop-lec-16-lambda-calculus-encoding

**CS3100 POP - Lec 16 - Lambda Calculus Encoding**  
id: `MKbnRNT5-bc`  
duration: 3164s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

All right, so I have released the assignment two over the weekend. And as I had mentioned before, the assignment two is basically about implementing the various reduction strategies. In particular, the assignment two tests whether you can implement the normal order reduction,

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

the call by name and call by value reduction strategies. So just to give you a hint, right, so the amount of code that you will write will be far less than the amount of test cases and examples that we have in that file. So if you know what you're doing, each of those pieces of functions that they expect you to write are three or four lines long for each one.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

So if you're writing more than 10 lines, you have to sort of stop and ask whether you're doing the right thing. So it's meant to be really small. It shouldn't take you a long time. But if you're writing a lot of lines, then certainly you're doing something wrong. So take that as a hint. So the thing to follow there is look at the earlier part of the semantics lectures where we described the semantics very thoroughly using inference rules.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

So you'll be translating those inference rules into a program. It should be really short and really explicit. You will know what you are writing. If you're writing a lot of code and you're trying to, you're poking around in the dark, you're not going to make progress. So that's my suggestion for that assignment. Okay. Yeah, so can anyone, everyone hear me?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

Yes, okay. It might just be a issue on the students. Okay. Okay, so in the last class, we are looking at semantics. In particular, we were looking at semantics of encodings. And what we were looking at in the last class is how to encode Booleans in NAMDA calculus. So Booleans are primitive data types. We encoded Boolean values. We also encoded functions that operate over Booleans.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

In a language like OCaml, you also have other structures. In particular, we have the ability to construct new complex types. And a simple complex type is pairs, right? So what is a pair? Pair is just a tuple with two components. Okay, so here is an implementation of the important functions of pairs in OCaml.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So pair is a primitive, so OCaml embeds primitive syntax for constructing pairs. So you can just do open bracket one comma two, close bracket, that will create a pair value with two ints. I can make it a little bit more explicit. I can say make pair is a function. Okay, so the function takes two arguments x and y and just returns you a pair. This is just so that we explicitly see that this is just a syntax over writing just a function like this.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And then you have two functions. Those functions are extract. Give me the first element of the pair. Give me the second element of the pair. First pattern matches on x and y, right? And then returns you the first element. And second, S and D pattern matches on x and y and gives you the second element. So the thing to note here is make pair is a function that takes two arguments, right?

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

A and B, and then returns you a pair, which is A star B. First and second, both take the pair as inputs and then return the first and the second component. So if we want to encode pairs in Lambda calculus, we want both the constructor, right? The way of constructing pairs and the destructors, these two things which allow us to extract the components of the pair. So let's do that.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

So first we look at the constructor, right? So in NoCaml, if I tell you that the two components are f and s, the construction is just basically put them in this bracket syntax, right? Or use make pair function to construct them. In Lambda calculus, we don't have any of these things, right? So we have to sort of explicitly encode them using functions. And the way we represent pairs in Lambda calculus is this encoding. Right?

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So pair constructor is a function that takes two arguments f and s, right? Just like the make pair function. And the pair value itself is represented by this particular term. What does it say? It says it takes a single argument, right? And by convention, we will say that that argument is a Boolean, right? And applies this Boolean on f and s, right?

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

Our encoding of a pair value is a function that takes a single argument, which is a Boolean, and then applies that Boolean on f and s. Okay, so that's our entire pair construction. Why is it a Boolean? Because the only thing that we want to do is to extract first and second elements of the pair. Okay, so this might seem a bit strange, but if you sort of look at the destructors, the first and second function, the encoding becomes clear. So let's run with it for now, right?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

Let's say I define a function called pair, which is just this function, right? Which is the same as what I've written here. So it takes two arguments f and s for the two components, and then returns you a pair value. So this term sort of represents the pair value. And the idea here is we take this Boolean and apply it to f and s. Right? So whatever is printed below is not important. Okay, so let's look at how this actually looks when we evaluate, right?

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So we have a function, pair, and we have two components, v and w. So I'm going to construct a pair with v and w. So I apply this pair function on v and w, and I evaluate it. So if you look at the result of the evaluation, you will see that what you end up having is a term which takes a Boolean value and then applies it to v and w. So v and w are three variables here. So you can sort of imagine that they are in the environment, right?

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

So they're just there. And if you ask for any one of these components, you will get v or w. So as I said, v is a Boolean function. I've been repeating Boolean, Boolean, Boolean. But this is just a convention, right? There is no type safety. So we are studying untyped lambda calculus. So we can't say, oh, this is a function that takes a Boolean and then does something with it, right? We have no type safety. When I say Boolean, it's sort of a convention that we have to follow.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

If you pass something else there, it will just go wrong. But for the study, right, all of this encoding lecture, we will sort of assume that we will only do the right thing because we don't have type safety. So we can't put static guarantees on what is allowed and what is not. OK. OK. So here is the accessor functions. So recall that the pair value itself is this term, right?

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

It takes a Boolean and applies the Boolean to first and second, where v and w are the first and second elements of the pair. And we did study something that looks very similar to this when we studied Booleans, right? So imagine what happens if b is true. If this b is true, then what you get is v back, right? We get the first element back. And if this b is false, then you get the second element back. So because that is how true and false values work in this encoding.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

So this is precisely how we will define the first and second functions.  What first does. I keep doing this again and again. So let me try to slowly do it. What first does is it takes a pair and then applies true to it. So what happens? Let's assume that the bar is this pair. When you apply true to this term, true gets substituted here. So what you will get is true vw.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So you'll get v out. And similarly, let's say we are going to do second on this pair. So if you do second, this will become false and you'll get w back. OK, that's the idea. So we are sort of encoding the fact that we want to extract the first and the second by using true and false. OK, so here is the encoding of first and second. This encoding is just the same as this. Right. So I have a lambda P. They apply P to true.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Second is lambda P apply P to false. OK, so that's done. So let's look at how this actually works in practice. So here is here is evaluation of a lambda term where the first thing I do is I construct a pair with V and W. So I construct a pair and I extract the first element of that pair. So if you run this, you can see that what we extracted is V.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

So what has happened? So this is the first function. Right. It takes a pair and then applies the true value to it. This is the constructor of the pair and these are the values. Right. So first we construct if you reduce this one, first we construct the pair. Right. And then we extract the first element using here.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

But this this doesn't happen in this order because we are using normal order evaluation and we first apply the whole term to this P. So the evaluation might be might not correspond to your intuitive understanding of what I explained, which is first construct the pair and then destruct it. But the result is the same. Right. So when you extract the first element of a pair with V and W, you get V back. And similarly, when you extract the second element of a pair with V and W, you get W back.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

OK, so that's the idea. So this is how we construct pairs. So, OK, so that is constructor and destructor. Right. And you might want to implement other functions on top. You might want to do other things that you might want to do with pairs. So one thing you want to do is to implement something like a swap function. So swap function takes a pair X and Y and returns you a pair Y X. Right. This is the whole implementation of that function in OCaml.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So if I can encode it in OCaml, I should be able to encode it in lambda calculus as well. So so what is happening here? So if you sort of imagine this to be P, right, if you imagine this to be P, then swap is swap can be implemented as this. Right. So it's the second of P and then the first of P. Right.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

So you take a P, you return a new pair where the first component is the second of P and the second component is the first of P. Right. So we explicitly deconstructed the pair and wrote it out explicitly. But you can also write it like this because we have function second and first. And this is precisely the implementation of a soft function in lambda calculus. So what does swap take? Swap takes a pair. It has to take an input pair as a first input.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

And what does it return? It returns a pair.  And our encoding of pair is a function that takes a Boolean. Right. So here is a function that takes a Boolean. Right. So this this whole thing is the resultant pair. Right. This is the input P that corresponds to this P and this whole term corresponds to this term here. Right. And and what we do here, all we do is you take this Boolean.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

Right. In the resultant path, if the first component is requested, I return the second component of the original pair. Right. Which is the same as this one. And if the second component is requested, where this would be false, you actually return the first component of the original pair. So and that's the encoding. And here is the implementation of the encoding in OCaml.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

But this is one to one corresponding to this definition that I've written down here. OK, so let's see how this works in practice. So what I'm going to do is I'm going to swap V and W. I'm going to extract the first component. So what will be the result? You can type the messages there. What's the result of this evaluation?

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

Yeah. OK. Good. I'm asking these questions because I just want some feedback. Right. So otherwise, it's like talking to a wall. So thanks for the response. Do interact. Right. So if I ask questions, even if you are not inclined to even if attempt to have some interaction in the class. Right. So otherwise, it'll be boring both for you and me. Let's put it that way.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

OK, so here is here is the actual evaluation of that term. So you can see that first is here and I apply swap to the path that they construct using V and W. So if you run this, you get W back. So you can implement arbitrary functions that operate over paths just using this idea. The core idea is this right there is when you construct these pairs, there is a constructor and a destructor.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

And we've cleverly encoded the constructor and destructor using this function representation that takes a Boolean as in. OK, so that is pairs. Right. So we've seen Booleans. We've seen simple data types. We also have lots of other data types, primitive data types in OCaml. Right. In particular, we have numbers. We have zeros once and whatnot.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

We don't have zeros and ones in Lambda calculus. It turns out that you can actually encode zeros and ones using this very clever encoding called the church numerals. Right. We will keep coming back to this idea of church numerals even in the later lecture. So it's a very clever encoding. So let's and it's a lot of fun. So what is the church numeral? Church numeral is just a way of encoding natural numbers by using functions. Right.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

And just like we had a representation of a pair, which is a function that takes a single argument Boolean and does something with it. Right. For for natural numbers, what we will do is we will represent that as a function that takes two arguments. Right. And the idea is that the first argument is the successor function. Right. It is the successor function that given a number adds one to it. Right.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

We studied successor in OCaml like the sub function. So imagine that S is the successor function represents the successor function and Z is the representation of zero. We are not actually going to care about what the concrete thing is, but we are just going to say Z is zero. Right. So we represent the natural number zero as a function that takes the successor and the zero. Right. And then just return zero because that is zero.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

How do you represent one one is also a function that takes a successor and zero and it applies the successor once on zero. Right. So there is one s. So we say that that encodes one and two is a function that takes two arguments successor and zero. And there are two s s. So the way to read this is you first apply s on Z to get one. Right.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

And you apply s on one to get two. So these are all conventions that I'm piling on. But but there is no semantics beyond this the term that I've written down. Right. That's just a syntactic term. So I'm giving you all these intuitions. But the term itself is just whatever it is. Right. It's just a syntax.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

And three is three applications of s on Z. And similarly n is any natural number n is a function that takes a successor and Z and applies s n times to Z. Right. It's the number of s's that we count. Right. So if you have n s's then the number that it represents is n. Right. That's the encoding that we go for. And we write higher order functions here. S and Z are functions. Right. We have nothing else here. So everything is higher order functions as you will see in what we do with these numbers. Right.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

We will keep passing higher order functions over there. So S and Z will be passed other functions. Yeah. You can. We will get to something like that. Yeah. So three to Z does not. OK. Really good questions. A few questions. Right. I will. So I answered Sartek's question. Can we write higher order functions here. Yes you can.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

I need this question is three to Z equals five. Three is a function. Right. It takes S and Z. Right. So if you apply three to two. So you are applying this term. Where you are substituting for S. Right.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

It won't type check but I'll tell you how to do additions. So this is not the thing that you've written is not going to type check but we will see additions. So it will it will work out. So is it a coincidence that zero is alpha equivalent to false. It is a coincidence. Good question. So it is really a coincidence. So this has nothing to do with the fact that. In C we use zero for false. Right. It's just a pure coincidence.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

OK. Good observation. OK. So we've encoded church numerals. Right. Again this is just writing down sometimes if you cannot do the things that you can do with natural numbers. This is not natural numbers in particular. I want to do addition multiplication. All the beautiful things that I want to do with natural numbers. Right. Let's slowly look at how to do all of these. So here is just the encoding of zero one two three so that I can use them later. OK.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

So quick question. So what will be the OCaml type of church encoded natural number two. So this church encoded natural number two is funness arrow fun Z S of S of Z. Right. What will be its type. So it's one of these answers. What I'm asking is if you wrote down this function in OCaml. Right. What will be the type of that term.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

Yeah. Good. So good answers. So the term will be the type will be this one. Right. Why. Because you take a lambda S as an argument. So there is a function and you're using that as a function. Oops. And you take a lambda Z as an argument and you're applying S to Z. So S has to be a function. Right. Which is applied to Z. So the argument type of S has to match the type of Z.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

And the result type is again applied to S. Right. So it must be the fact that the argument type and the result type are the same for S and the argument type is the same for Z. So so that's why you arrive at this one.  Yeah. OK. So let me try a little variant on this. So let me remove this.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

What is the type of this one. Again the answer is that. Right. So yeah good. So good answers. So now the point is S is a function. Right. You pick the most general type of the function alpha to beta. Right. And Z is applied. Sorry. S is applied to Z.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

So these type should match S's argument type. So that only constrains the function type to this one. So S is alpha to beta and good answers. Good. So let me put it back. I'm happy that you're following very closely. So OK. So that's the answer. So OK. So let's start implementing things on functions. Right.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

If I just gave you natural numbers and I gave you no operators on natural numbers. What uses it. Right. So the point of having natural numbers is to do addition and subtraction and multiplication and so on. So let's look at a really simple function first. First thing I want to do is to implement successor function. So given some natural number five let's say five I want it to return six. Right.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

So how do you do this. So successor function takes an integer returns an integer. Right. So in OCaml but in lambda calculus it takes a natural number n and it has to return a natural number. We know that natural numbers are encoded as functions that take two arguments S and Z. Right. And what we are doing here is intuitively right. So if any natural number let's say five is represented with the five S's. Right.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

If I read the term there will be five S's and a Z. The successor contains one more S on the outside. Right. It will contain six S's and a Z. So the whole point is I want to add one more S on the outside. So it's like a wrapping this number which has five S's with one more wrapper which is an S and that is six. And this is what we try to do here. Right. So this number natural number input I know is a function that takes an S and a Z.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

So I apply S and a Z. So to get to remove the lambdas. Right. But what I will have is if the function is five I'll have five S's now and a Z. Right. I add one more S on the outside and that gives me the successor. Right. And we are we are applying this here precisely because n is also a function that takes two arguments. Right. And applying S and Z removes it such that all you have is three variables.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

It will be a term that is S applied to S applied to S applied to Z. And we are adding one more S here and then we are wrapping it back in a lambda S and Z. Right. Now you get the number out. Again I am sort of explaining it. It is better to actually see it in practice. Right. So we can compute with these encodings that we have defined here. So here is the encoding of successor just like it is described here. Right. And the successor of zero is one. Right. So we know. So let's see how it works out.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

Right. This is zero S of Z of Z is zero. Right. And this is the successor definition. Right. It takes an n S and Z and then as the outer S. So first thing we do is we substitute this term for n. Right. Wherever n is you substitute that one. So n is here. So you substitute zero at that position. Right.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

And then we are using normal order reduction. So we go inside the lambda term and reduce it. So we can see that there is an application here. Right. And we go ahead and do the application. So substitute S for S. We are not using S in the body. So S is gone. And substitute Z for Z. And we just have Z. Right. So that in two steps gives you just a Z.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

And we have an outer S. Right. That just sits here. Right. We have it here. So the final term you get is lambda S lambda Z S Z. And that's one. Right. That is the encoding that we had. So we have actually defined a successor function that given any number. Right. If I give say three. It gives me four. So three is one two three S's. Right. And the result has one two three four S's.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So from so you cannot play this on any number and it will just add an S on the outside. Okay. So that's successor. The other thing that you can do on natural numbers is perform a test. Right. I want to check whether some number is zero or one or two. It turns out that you can encode all these sticks by having this primitive check for zero. So all I want to do is given a number. Check whether the number is zero. I call that function is zero. Right.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

And what is in OCaml what does zero do? Zero takes a natural number and returns you a Boolean value. Right. True or false. So in lambda calculus we encoded such that it is a function. Right.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

And if you think about how natural numbers are encoded. They are encoded with the as a function that takes two arguments S and Z. Right. And you apply S's arbitrary number of times. Right. It could be arbitrary number of times based on the value of n. And then finally there is a Z. Right. So S is a function. Right. S takes single argument and returns you a single result. So with that what we are going to do is something very clever. So given an N for S pass this function. Right. That takes any value and then return false.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

The idea here is we are testing for is zero. Right. If you in the encoding of the number if there is even a single S we just want to return false. Right. So that's the idea. If there is no S's then is zero is zero. Right. So then we return true. So we cleverly use the function S and Z to

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

To test whether a particular number is zero. Right. So that's the encoding. Let's actually see how it works in practice. It will become clear. So here is the OCaml version of this one written down. So now let's check whether the zero is zero. Right. So what is happening here. So we have the zero here. Right. Is zero takes an X a natural number. Right. Here and then applies this function.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

Which is take any argument that is just going to be substituted where S is present. Take any argument and then just return false. Right. The idea is if you happen to find an S in the term it is just false. So that is what precisely is zero saying. And this is just the encoding of true.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

OK. So what happens here. We first substitute zero for n. Right. And this year. So we get n. And this term which is the same as this term. And the term here which is true. Which is true here. Right. And now we have an application as well. This is a applied to b applied to c. So first apply it to b.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So for S substitute this whole term. But we don't have any SS in the body. So that's ignored. Right. So that just goes away. So you have Lambda ZZ. True. So if you apply true to Z. You just get true back. So is zero zero evaluates to true. So let's try zero of one. Right. So the same thing. So we have one here. We have the zero function here. So first substitute for n one. So you get one for n. Right. And these two terms are the same as these two terms. Right. Now this is again a b c.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

First apply it to be. Wherever you find an S substitute this term. Right. So this gets substituted. We have an S here. Right. So it gets substituted in the body. Right. What do we have. This is the clever bit. Right. We have a function that takes whatever argument and then just returns false.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

The false is encoded here. Right. So you have this function which takes a Lambda Z. And then whatever you pass it is going to just return false here. And that's the clever bit. And if you now apply true here. True gets substituted for Z. So you get true here. For this Z.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

And I'm just going to ignore true here. Right. That's what is happening here. So this true value gets substituted for this way. And we don't use why in the body. And all I'm doing is it's a constant function at that point. You give me anything. I'm just going to I'm just going to return your false. And this false gets written. You can sort of imagine this works for arbitrary numbers. Right. So just to complete that argument is zero one is false is what it's saying is zero zero is true zero one is false. If you apply to you get the same idea.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

You can apply for arbitrary numbers. I don't have any numbers beyond three constants beyond three. But you get the idea. Everything is false. OK. So we've defined a zero function which is going to be a test that returns either true or false. So OK. So we've defined successor. We've defined zero. This is a test for a natural number.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

The common thing that we do on natural numbers is additions and multiplications. Right. So let's define additional multiplication. Again the encoding is is quite clever but I'll sort of try to give you an intuition. But the concrete steps are better explained by looking at an example. So what's the intuition of a plus. Right. Plus takes two numbers. Right. Two natural numbers and returns you a natural number. Right. So it is a function that goes from natural number to natural number and returns a natural number.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

And in our lambda encoding how do we represent numbers. It is the number of S's right. If I give you one which has one S and two which has two S's then the result should have three S's apply to Z. Right. That's what we are going to go for. And the idea is this. So so let's let's actually walk through the example. Right. So as I mentioned plus is a function that takes two natural numbers.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

And it's going to return a natural number. Right. Just because just just like how we encode natural numbers as functions that take two arguments we have function that take two arguments. Right. And all we're doing here is. So this M is a natural number. Right. And that has some number of S's and then the last one will be a zero. Right.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

A last thing will be a zero. What we are going to do is take the zero throw that away and then just replace the zero with whatever number of SZ that M has. Right. So if one has SZ one is represented as let me just write it out.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

If if one is represented as SZ I ignoring certain things but that's not important. Two is represented as S of S of Z. Right. I'm going to say one plus two S replace the Z with this term. Right. Take this Z out. Right. And replace that with whatever I have here. What that gives me is S sorry S of this S comes from here. Right. This goes away and we are replacing that with this term. So we get S of S of Z. So S of S of S of Z and that is three.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

And that is precisely what we are doing in terms of plus. So I have the first number. I just keep the S's just like it is. But where Z would be there I just replace that with the body of the number N.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

OK. So if you have N S's there it will be N S's followed by Z. OK. So that's addition. So all we are doing is we are taking out the zero and then replacing that with whatever the body of the second number is. Multiplication can be understood as something very similar. So instead of replacing the zero number replace the S's. Right. So what is happening here is let's say I have some interesting number. Let's say I have two. So which is S of S of Z. Right.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

I'm going to multiply that with three S of S S of S of Z. OK. So what I'm going to do in multiplication is wherever I find an S in the original number I'm going to replace that with these number of S's from the second number. Right.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So if you find an S here replace that with the number of S's that you find in the second number. So essentially two times three two times three is going to be for this one S replace this with so many number of S's. Right. And for the second S again replace that with so many number of S's. Right.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

And then a Z and yeah of course brackets are the you just get the bracketing right. So the idea is one two three four five six and two times three is six. Right. So that's that's the intuition behind it. And of course not being precise here. But that is precisely what is happening in the definition of multiplication.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

So wherever you find the S replace that with the number of S's that you will find in the second number. OK. OK. So with that we can actually look at an example to make our understanding a bit more clear. So these this term is precisely the same term here. So I define plus and multiplication. So let's do one plus two. OK.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So one plus two the solution is three. Right. And yeah I'm not going to go through all of this. I recommend you to follow along what I mentioned the intuition that I mentioned. Right. So the idea is that you take the first number. Right. You take the first number which is one. And then replace the Z with the body of this number. So you have S applied to S of S of Z and you get three S result. OK. So that's that's three.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

The high level concept here is this right. So this actually proves that one plus two is three. We are not sort of taking in because we've encoded one two and three as counting the number of S's.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

The fact that I am able to evaluate this using one and two to get this particular term which is three is a proof that one plus two is three. And these are the steps here defined here are the proof steps for getting from one plus two. Two three. And using lambda we can build an entire theory of arithmetic. So we can prove all of the things about natural numbers that we want to do using natural using lambda calculus. Right. So if you want to prove a theorem about something you can use lambda calculus to prove it with the assistance of a computer. Right.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

You do paper proofs using an intuition and such. But we are not using intuitions here. Right. The only thing that we've sort of assumed is the fact that count the number of S's in the body and that is going to represent the natural number. Everything else we've just encoded from scratch. If you believe lambda calculus is correct and our encoding is sort of natural then just by doing that we've actually proved one plus two is three.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

Right. So I think that's the power of lambda calculus. You can sort of prove you can prove higher level concepts without appealing to intuitions. Right. Okay. So again so here is multiplication. So I'm multiplying two times three. I'm not going to work through this. I don't recommend you to work through all of the details but the intuition is important. Right.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

That's the intuition that I described earlier. So two times three is six. So you'll see one two three four five sixes. Right. So here we proved two times three six. Okay. So we've done success at before. Success is just adding one s in front of a term. Right. You have a body of S's. You add one s to the front.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

You get a successor predecessor. It turns out is quite tricky. So it's like an peeling an onion. Right. So you have a number of S's. You have to peel an onion out and peeling is not a primitive operation that we have. So adding a layer is application. Right. Lambda calculus gives you application. I can do application as a primitive operation. But peeling something is not a primitive operation. Lambda calculus because everything is a function of a form.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

It's a function application. If you apply a function it's not like you can take it apart. And for this reason it turns out to be much more tricky than a successor. So we will use a very clever trick here. Right. What we will do is we will use an encoding using a pair where the idea is the the pair will always represent a number and its predecessor together.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Right. So this is the intuition. Let's see how it works in practice. So I define ZZ as a term that is a pair with zero and zero. The idea here is the predecessor of zero is zero. We are using natural numbers. Right. So when you when you get to zero we don't have we don't have a notion of what a predecessor of zero is. So we just happen to use zero. Right.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

And for any other number. Right. So given a pair of that looks something like this. The successor is defined such that it is the second component of P which is which is this component. Right. And the first component plus one. Sorry the second component. Sorry. One plus the second component. So this. So OK. So let me try to give concrete example and it will make sense.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

So we define zero zero as a pair with zero comma zero. OK. So that's the basic definition here. Right. Zero zero zero comma zero. If you apply SS to zero zero. It takes the second component of the pair which is zero. Right. And the first component is just the second component of the original pair. So we get zero here. And the second component of this new one is one plus the second component. Right. One plus the second component. So one.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

And if you apply one more SS here. So you take the second component that becomes the first component. You take the second component add one to it that becomes the second company. So the idea here is every term. That is a pair here contains the number.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

The number as a second component and its predecessor. Right. For zero zero it is odd because we don't have a predecessor for zero. But for every other number it is one and its previous number zero to previous number one previous number two and so on. So this is a intermediate step for us to help define the predecessor. Right. So we are using this clever encoding. We will see how we actually use this. The intuition is once you actually build this proof up if you need to get the predecessor of three if you are able to build this from ground up then you know that the first component will have the predecessor. Right. If I need to get the predecessor of three it is going to be two.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

That is what we are going to get towards. And how do we get to that. The predecessor function. Right. What is the greatest function. This function takes a natural number and returns a natural number which is a predecessor. Right. So this is the clever bit. Right. So we take the natural number for the predecessor.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

Give in the natural number. Wherever S is found use this function S.S. Right. And where ever Z is found use this function use this term ZZ. Right. So this will set a proof from the bottom up. So if M contains two S.S. Right. It builds the proof from bottom up saying the predecessor of zero zero is zero zero one zero two is one.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

So it builds this whole term up from bottom up. So the term that you've built for two. Let's say this MS2 is a pair which contains two as the second component. Right. And then has one as the first component and we are extracting that first here. Right. So that's the clever bit. So you use the instructor to build the proof from bottom up. So anytime you require a predecessor what you're doing.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Yeah. So you can't you need a different encoding for negative. I'm just looking at the question set but but since the base case is zero zero how are we going to define negative numbers. You can define negative numbers but you have to you have to go for a different encoding so we cannot use the natural number encoding here. Right. So we won't see negative numbers. But that's the idea. Okay. So how does this actually work. So I've defined ZZ and SS. Right.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

And then I've defined a predecessor here which is just the encoding of whatever is here. That's two predecessors of three. And what you get is two out and let's do this is of zero you get zero. So pretty much zero sort of zero because we are operating with natural numbers. There's a lower bound and we cannot go towards go below that.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

And essentially when we ask for three what we're doing is we first build zero zero then we say oh zero one. Then we say one two and we say two three and that's the term that we have finally and we extract the first component of the term which is two and that happens to be this term. Okay so Again This is sort of

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

Works as expected but this is not how you will implement it in practice. Right. If you want to implement predecessor in your in your real language. This is not what we do. So this is sort of Just think about these as Proofs of predecessor rather than encoding creasing predecessors in practice. Okay. So yeah, so now you can use the predecessor to implement subtraction. So the idea is that

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

With the addition what we did is we replace the zero term with the number of SS. Right. But in subtraction you have to Take out So if I subtract say if the if I want to do m minus n if we want to do m minus n m is some number that has some number of SS. Right. And n is some number that represents the number of SS that needs to be taken out of m.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So all we do here is apply The predecessor function n times on m Right. So this is like saying take the number m. Right. And apply n times the predecessor function. This is a bit tricky. This is like multiplication a little bit like multiplication. But

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

But it works out. I think if you start off start at it offline you will see how it works. Again I don't want you to focus too deeply on how we came to input this. I just wanted to Take away that these things can be encoded. OK. So that's the that's the idea there. Why can't we implement numbers as n people says you can do that. Yeah. You can certainly do Bitwise booleans as well. So the these encodings are just one way of doing it. Right. So there are the

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

There are several different ways to input numbers. It depends on what you want to show. Right. So So in In real machines. Right. We encode everything as boolean because that is how That is how they are represented underneath. Right. So essentially all these machines work on Booleans. They operate on bits but we don't operate on bits here. We operate on high level concepts. So it is better to encode.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

It depends on what you want to do with those things. Here we want to just show how additional subtraction on all these things work. So you can encode booleans but that would be that would be just Yeah that that would possibly allow more things to be encoded but If you just want to encode additional subtraction at the end of the day. I don't see a benefit in encoding everything as boolean. You can do bitwise operations but

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

Of course you can't do bitwise operations here. So getting back to this. Right. So here is an implementation of subtraction. It's very large details are not important. But subtraction works out. Right. You do three minus two. You get one But subtraction doesn't work out for two minus three. Right. We have natural numbers. So you have two minus four will be zero. Two minus three will be zero because

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

So what does it do it. What is it doing. Right. The way we encoded this is you have to which is which contains two S's and we are saying take three S's out of this two. So we don't have three S's so we can only take out two and we stop at zero. Right. So this sort of gives you Naturally gives you what should happen at the at the limits. Right. So once you hit the zero you just stop.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3164.0s_

Okay. I think I'll continue with the rest of the things in the next class. I'll stop here. We've seen a couple of things. I hope that I can finish this lecture. In the next class. Questions. Any questions. No questions. You can also ask questions on slack. Okay. In that case I'll stop now. Thank you very much. Thank you.

---
