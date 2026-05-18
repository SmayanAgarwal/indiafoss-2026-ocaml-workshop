# 10-cs3100-pop-lec-10-exceptions-higher-order-programming

**CS3100 POP - Lec 10 - Exceptions + Higher order programming**  
id: `nTweoOaDwz8`  
duration: 3073s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so you should be able to see my screen. So in the last class, we saw a lot about exceptions and I think you asked a lot of probing questions which sort of covered the corner cases of exceptions as well. So obviously the class had much more information than what I have on the slides. The video is up there.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

If you want to refresh, I would recommend going and looking at the uploaded video. So what we'll do quickly in this class is I'll just finish up exceptions. I just have one example and then we'll move on to higher order programming. So we are given the specification. Say, given the list of shapes, return a point whose color is green. If no green point exists, then raise no green point exception.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

So we call that we had a definition of shapes and shapes previously. So what I do here is I have an exception declared, which is called a green point, no green point exception. And unlike the previous exceptions that we saw, this one does not take any argument. This is like an ordinary exception, just like a nil constructor for lists, which does not take any argument.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

This is an exception, which just is the constructor itself and does not have any argument. It does not have any payload. So I am implementing a fine green point function, which takes a list of shapes. If the list is empty, then I return, then I raise no green point, which is what the specification says. Raise no green point if no green point exists. If there is a head and a tail, if the head is a color point and the color is green, then I return the point.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

Otherwise, I continue the search. I call recursively call fine green point on the tail of the list. OK, so this might not work because the definition of green point is not defined.  So it should work now. So both of these are defined.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

OK, so both of these are defined. So I've defined an exception. I've also defined this function, which takes a list of shapes and then returns you a point. It returns you this point. And if there is no point, then you get this exception. If there is no green point, you get this exception. So obviously, if I apply this function on an empty list, I get the exception. If I apply this function on a list that has a green point, I get the first of these occurrences.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

Because we sort of look at how the search proceeds. It starts from the head, the first element, and then keeps looking for the first occurrence. And if you find the first occurrence, you just return that point. The search is no longer proceeds. The whole thing just returns that value. If you don't find it, you keep looking for it. So this particular call will return just the point, x0, y0.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And yeah, OK, so exceptions are not a great way to organize programs. Why? Because just look at the type of this function. If I just look at the so in statically-dyed function programming languages,

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

like OCaml and Haskell, and even, say, Scala and other languages, you sort of look at the type, not just as a mechanism that prevents errors, but also as documentation. So what this means is that, abstractly, if you sort of look at the type of a particular function, you should be able to know what the function does, right? Even though it is not fully apparent, you should be able to tell something about it.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

In particular, this fine green point function has a type which takes a list of shapes, and then it just says, I'm going to return a point. So the type checker will expect you to ensure that the return value is a point, right? You handle it just like a point would be handled. But it says nothing about the fact that this function raises an exception, right?

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So that's the important point. The idea is that types do not capture the possibility of an exception. So it's not just a function that is being raised by a function, right? Why does this matter? It matters because suppose you are building a large software, right? And you're sort of looking at the API. By API, I'm not looking at the comments that are attached with each function.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

I'm just looking at just the types, because as you start programming in OCaml, you will sort of use the types as the documentation, much more than the English text that accompanies the type definition, right? So I have no clue that this function will raise this no green point exception, right? And that's bad because I might just send an empty list. And because it is not apparent immediately from the type that this function is going to raise an exception,

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

I might not have a handle around it, right? If I use the library, I might not be aware that I should have a handler around calling this particular function. So at runtime, what this would happen is you would call this function with an empty list and it will throw an exception. You've not handled it. So the exception bubbles all the way up to the top level, and then your program fits. This is as bad as writing programs in say dynamic languages, right? In Python or something.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So scripting languages, which are usually dynamically typed, have this nice advantage that you can start writing programs and it appears that it quickly works, right? You write simple Python, say sorting function, it will just work because you're not checking any types. You might even it might even work on very simple inputs, right? You give it an empty list, returns an empty list, you give it a sort of list, it returns a sort of list.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

The thing that will not, is not ensured by dynamically typed languages is that there is no runtime error. There is still a large class of runtime errors that are not caught at compile time. So what this means in practice is that if you sort of go to employing something like machine learning workflows where you are doing lots of training, right? Or you're doing scientific computing where your program runs for days and days.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

The issue is that because you don't have static types, only after running your program for like three days, you find an error, right? And then your program fits. This is very, very bad, right? You've lost three days of work. Ideally, you would like to have caught this error at compile time so that you haven't wasted all of the three days for running this program. And even after three days, if you fix that bug, it is not guaranteed that there isn't some other bug that will again cause this program to fail after four days.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

So, so having exceptions is very similar to that, right? Because the type doesn't tell you that an exception exists. It might be the case that for some corner case, an exception is raised and your program terminates, right? So this is this is undesirable in practice if you build large software. So the better way to write this function, even though the specification says that you should raise an exception,

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

if you were to write this function, the better way is to return an option type, right? Where it's a point option. The idea is that wherever an exception would be raised, you would say you return none. And wherever you will actually return a value, a point value, you return some value. And how does this work? So I'm just implementing a new function called the green point opt, right?

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

Opt says option. It takes a list again. It simply calls fine green point, right? And if this function returns normally, it's going to return a point, right? I'm just going to wrap that in a some constructor. So the return value of this whole thing is going to be a point option. If it raises an exception, then I'm just going to return none. If you look at the type of this function, right, it is saying a little bit more than what the previous function is saying, right?

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

This function says that I'm going to take a list of shapes and I'm going to give you a point option, which means that there is a possibility that I might not be always able to produce a point. I can produce either some point or none. So the client of this library, the user of this library, just by looking at the type, knows that, okay, I need to handle this other possibility as well where the point might not be returned.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

And because we have pattern matching, which ensures exhaustiveness, right? The OCaml compiler will help you write the program in such a way that these both the cases are captured, right? Even in order to extract the point, you will have to start a pattern match on it. So that will make it obvious. So this is considered a better idiom, right, than raising exceptions.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And if you look at large libraries, this is how they are organized. So even though exceptions are a feature in OCaml, we tend to discourage the use of exceptions. Okay, so this returns none and this returns some x equals zero, y equals zero. This is considered a better style, right? And my recommendation in your code is if possible, avoid exceptions in your code, right? Unhandled exceptions are untamed errors.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

We tried to the whole aim of writing programs in a strongly typed language is to capture a lot of the invariants at compile time, right? So that your program satisfies your program requirements without failing at runtime, because runtime failures are hard to debug and you'll be wasting time. And there are other issues as well, right? If it is a runtime error, then you have to give it a suitable input that causes the runtime failure.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

And because the input space is very large, it is usually the case that you are not completely testing all of the possibilities for your program, right? So even though you might do like very comprehensive testing, your program still might have runtime errors, but static error sort of avoid this completely. Okay, so it's better. And we don't have exhaustiveness check for exceptions, because why?

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

Because exceptions can be dynamically create sorry, not dynamically can be added, right? You can add your own exceptions so we can never be sure that we've got all of the exceptions in our program. You can have a catch all case, but that's not useful. That is also a runtime error, right? And my recommendation is whenever you think you might need to use exceptions, think whether you can rewrite the program such that you can return the value as an option type, right?

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

So wherever a function may return an alpha and may throw an exception, you can always rewrite the function such that it returns an alpha option, right? Where you would have thrown an exception, you return none. But there is also a better type in OCaml, you might not need to use it. So there is a type in OCaml called result. The idea is that in the option type, there is just a single type variable, right?

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

And the case of error, it's just none. There is a result type where there are two type variables. The first type variable is for the result, right? And the second type variable is for the error case. And this could be anything. It could just be string, right? We could just say error value out of scope or something. So just using option is much better than using exceptions. So that's the recommendation.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

And OCaml standard library tends to use a lot of exceptions. So if you, OCaml is 25 years old, right? So the standard library itself is sort of older than when OCaml best practices were developed, right? So there are a lot of functions in the standard library which throw exceptions. For example, there is a function called list.head and list.tail, which given a list, return the head element and the tail element, right?

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

Obviously, this is not going to always be possible. You have to raise exceptions because if the list is empty, then you cannot produce a head or a tail, right? So try to write safe versions of head and tail. So these exercises are just for your practice, right? I'm not going to evaluate it. Try to write a function which takes an alpha list and returns an alpha option for the safe head and then takes an alpha list and returns an alpha list option for the safe tail.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

The idea is that if the list is empty, then you return none. Otherwise, you return the tail. You return some tail, right? Wrap the tail value in a some constructor and you return it. Okay. So another example just to practice pattern matching is, imagine I have three kinds of traversals, right? I have preorder, inorder, and postorder. I have the tree definition, which is a leaf or a node with left, the value and the right sub trees.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

So implement a traverse function which takes a tree and also the traversal, right? This traversal value and returns a list of values in that traversal, right? So if you have, say, one, two, three, and I ask you to do inorder traversal, you will return two, one, three, right? If I ask you to preorder, you will do one, two, three. If I ask you to postorder, you will do two, three, one. So try to write the function.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

It's just a, it's useful for practicing how to write recursive functions and so on. I mean, this might help you write, before you go on to write, attempt the assignments, you might want to try some of these easier ones. Okay. So that's all I wanted to say about pattern matching. Now, let me move on to the next lecture, which is about higher order programming.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

Okay. So, so what is the term higher order mean? Right. So I think we'll first get that out of the question. So, so far, what we've seen is all of our uses of functions have been definitions at the top level.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

And then the functions take values, which are not functions, right? And return values, which are not functions. But as I mentioned in the lecture where I introduced functions, functions are also just values, right? And function can take in values and return values. So, so it is, it is very common, it is possible and very common in OCaml to take functions as arguments to other functions and return functions as arguments, functions as results.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

And so far, what we've done would be called as first order programming, where functions are not taken as arguments and return values are returned. That is similar to what you do in C, right? Or C++. What we are doing here is higher order programming. Higher order just means first class functions, right?

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

First class as in you pass them as values and return functions as results. That's what higher order means. And this is such a common pattern in OCaml that even though we introduced it with much fanfare here, you will just start using it as you go along. You won't say, oh, use higher order functions here. You just be like, this is how I write my OCaml program. I should fix this. Yeah, that's the idea of higher order programming.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

So let's start from very simple. So it's an idiom, right? So this is just a way of writing programs. So this is not like a primitive property of OCaml. So we'll see a few other higher order functions that are quite useful. So we'll start with very simple example. So suppose I define two functions, which is double and square. So double takes an integer and then doubles it. Square squares the given integer.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

So these are the interim functions. And double of 10 gives you 20. Square of 2 gives you 4, like very standard. And now let's implement a quadruple function and a fourth power function. So how do you write this? Just the usual, right? 2 times 2 times x and then fourth is x squared times x squared. So that will give you the fourth power of x.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

So this is also an entire event function. And you can do quad, which gives you 40. It's just multiplying that by 4. And 4 power of 2 is 60. This is quite standard. So observe that when I write quad and 4, there is actually like this is double, right? And this is square. So we can abstract some of the details away. Instead of writing everything from scratch, we can use double and square.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

So I can write quad as double of double. And quad of 10 gives me 40. I'm just calling that function twice. First time I call it, I get the double value. Then I call the function again with the result. I get the quadruple of the given value. Similarly, for fourth, I can say it's a square of square.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

And this works as usual. So I suspect that there should be no surprises so far. So the thing that we are doing here, if you sort of look at these two functions, this function applies double twice. So it applies on the given x, it applies double twice. And this function applies square twice.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

So this is sort of a pattern that is common between the two. So the question is, can we abstract away the details of calling a particular function twice so that we can use that function and the function that we actually want to apply twice on the result, on the input value. So what do I mean by that? Let me just write it. Maybe it will be much easier. So here is a twice function. And the idea is that it takes a function as an argument and then a value as the second argument.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

And what it's going to do is apply this function twice over x. This is the first time you're seeing a higher order function. And what is higher order about it? Look at the type. The type for twice is it takes a function as the first argument, which goes from alpha to alpha, because this is the most generic type that we can have. And it takes an alpha as a second argument.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

And then it returns an alpha. Why does it return an alpha? It applies it once. So you get an alpha. It applies the same function again on alpha. So you get alpha again. So the result is alpha. So this function is a higher order because it takes a function as an argument. So that's twice. And now we can implement quad as apply double twice.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

So twice takes a function to be applied and the input value. So you just say, quadrpling a value is the same as applying double twice on the value. OK, so that's the way you read it. And you get an interim function because we have. You can essentially ignore the x, right? Because we are we are just creating values. You can do partial application.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

So so this function has interim because it takes an integer and then goes ahead and applies twice double x, which means that this argument is applied. This argument is applied and you get the end as a result. Here we are just partially applying twice with double. So we are supplying the first argument for twice. And we know that double is an interim function.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

So what you get as a result of this is a function. As you've seen, recall your partial application lectures. What you get as a part application of twice to double, you apply this argument. So you are left with this. And because double is an interim and this is an interim function and we just name it as what. All that I've done is I've sort of dropped x, but the reason why we get the same type is partial application.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

Right. So I know how to find part in a very succinct manner with sort of captures. Idiomatically, what is going on? Right. What are playing a number is applying a double twice. And this is precisely what is what you can see. Right. And.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

And this this this way of succinctly expressing ideas, right, which is very close to how we think of the requirements is one of the strengths of functional programming because we are not writing any types or anything here. Everything is inferred. And you can just read this as almost an English statement. Right. If you name the variables properly. But but there is nothing else here. And that's the that's the power of OCaml, but also other languages like Haskell and so on.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

If you were to write the same thing and say C, you can not see it, but in C plus plus where you have lambdas or also Java, the syntactic overhead of expressing this will complicate what is going on. It won't be this simple. So type inference. OK, so what is the type of price? Let's do. Twice. What is the type of price type of prices? It takes a function as the first argument.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

It takes a value as a second argument and then returns that same value. What is the type of double? I'm just answering the question that was asked in the chat. So the type of double is interlinked. And you can see that this has the same shape as this function, except that these are placeholder variables. So I can take this function, which is double.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

And I can apply it to twice to satisfy the first argument. What will happen is that because these are placeholders, these get unified. Unified is sort of you can just think of them as being substituted. So so this will become int int. So you can apply it there. And because these are also alpha, these become int int. And hence, if you do twice double, you get an int int. And I'm just naming this twice double as quad.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

Let's call it quad prime. Right. And quad prime is interlinked. And that's the type inference. Is that does that make sense? Sure. Kind of. OK.  So we've done that. I mean, it gives the same result as the previous one just to show that it works.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

The other point that I want to just mention is that this is as sufficient as writing it by hand. The compiler does all the hard work for you by inlining and doing all the optimizations. So this is not a question of efficiency. Compiler knows how to optimize these sort of programs.  So you can do the same thing for four. Four power is just twice applying square twice.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

And you can do the same thing and you get the same value. You see the power of abstraction now. Right. So you can sort of use this twice function to use square and four. We sort of abstracted away from this act of applying twice. And and you can you can abstract it even further. So what we will do here is instead of twice, I can I can write a function which takes a function

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

and apply is applies that function n times over a given argument. And you can write that quite naturally. We'll just call it apply. Which takes the number of times you have to apply the function over the argument. And you take that function that you need to apply and the argument that you are going to apply it on. If n is zero, then just return that argument. So I'm not applying it even once. So I'm just going to return it as is.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

If you want if n is greater than zero, then you call that function recursively on n minus one, the same function and the same argument. So the idea is that this will keep doing something. And eventually it would have applied it n minus one times. And finally apply it once more with f. Right. So you're sort of a sort of constructing this.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

If you say n is five, we are sort of constructing f of f of f of f of f of x. By recursively calling apply on a smaller argument. Right. So so the type that you get is the number of times that you need to apply. And the function that you're going to apply the argument that you're going to apply the function on. And the return value. Right. And that's the return value.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

So twice accepts any pass function. You cannot write. Deepesh has a question. Because it price accepts alpha or alpha function. What happens if I pass a function of type alpha to alpha alpha. This won't work because. Because because this function, the function has a function. Alpha to alpha to alpha expects.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

Two arguments.  And you have to somehow supply two arguments. So twice won't accept it. But doesn't mean that you cannot write a function that applies alpha to alpha to alpha twice. You just need to. You just need to think about what those arguments will be. Right. I think it's not hard if you just spend two minutes on it. You'll get it out. OK. So here is.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

Actually I name it quad but it should be some food. I am applying. I'm applying double. Zero times. Right. I'm creating a function for which applies double zero times on the argument. Right. So who is a function. So if I give four of ten. I get ten as a result. Right. Because I'm applying it zero times. But if I apply it once. I get 20.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

Because I've doubled it once. Play twice I get 40 because I first double it from 10 to 20 then 20 to 40. Then I can apply it say three times. 40 to 80 and so on.  No you can't. In partial application is there a way to supply the middle argument first.  So. Think about writing a function that flips the argument order. This is quite standard.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

So just to. So. Just to finish this thread. Yeah you can apply it say n number of times and it'll just work. Right. So that's the idea of abstracting the. Abstracting the number of times you want to apply the function. So Naaman has a question which is. In the partial application is there a way to supply the first argument. No but you can sort of think about.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So. So. So I'm trying to write a function that flips the. Try to write a function that flips the arguments right so you want if you want to partially apply the second argument you want to have the second argument as the first one.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So. Yeah so try that. I will leave it. So if a function takes. In. A pool. You want to create a function. Right. That accepts. So I'm trying to. That's.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

This isn't what I want. So function accepts. Then I want a function that. Switches the. All humans.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

I'm not going to write this function because I think. It's not hard but it just needs a bit of thinking. I encourage you to think about something right. What I'm trying to get that here is if I have a function. Which says goes from interval to. String. Or I can write this.  Would be. To put C.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

Right I have a function like this. I want to have a function. I want to define a function that takes this function as an argument. Right and then. Returns a function. That does this. This is possible but I am not going to write it here so. Now and this is the way you can partially apply the second argument.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

Right so you can sort of say. Flip the argument first apply the second argument so that you get the first argument to be applied. So if I want to partially apply the second argument. You define this function which given a function of ABC. A function of BAC. And then you partially apply B. So that. The function that will be left with this AC. OK so I want to continue on this further. So we are in switching the argument.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

Yeah yeah. So just do. Right as an exercise I think it is not hard. But I'll I'll still. There's a bunch of material to cover so I will sort of. Leave it for later. OK so is there a way to have a precaution apply. What question so I think we can have.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

So is there a is there an idea of this function being tail recursive. You have to I think it's. There is a way to do tail recursion. So the way.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

Instead of applying the function directly you just build. And the number of times that you need to apply the function. And then you can apply the function together. So there is a way to do it. I'll let you think about it. It is possible. The type of twice would have also been. A arrow. So OK so the type of twice. I'll just answer that question and go on.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

So what is what is twice. OK twice is. Why would you.  Sin do say is that the type of twice would also have been. Alpha to alpha to alpha to alpha. Why would it be the case. Yeah OK so that.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

It's good that you you are thinking about all of this. But it's certainly alpha to the reason why it is alpha to alpha. Right. So. Imagine how OCaml is going to do this right. I don't know about anything about this. I don't know anything about X. Right. So it's initially two type variables. Alpha and beta. So first thing you're doing is you're applying F1X. Right.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

Yeah. So just to quickly answer the Raghuraman's question. Yes alpha can be alpha to alpha. Alpha can be a beta to beta. So let's leave it at that. So it can be a function as well. So it is any type right. It can be this this alpha. Any type and a function type is also any type. So you can that can also be a function. So just to answer the scene those question. How does OCaml get this type. So first it looks at this application right.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So you're applying F1X. So F must be a function and X must be an argument. So I am. So it will say OK because it's a function. Let me just choose a function type a generic function type which is alpha to beta. And let me say that X is of type alpha because the argument has to match the input type of the function. Right. So the type so far inferred is F is alpha to beta and X is alpha.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

So OK. And now the result of this application is beta. Right. But observe that I'm applying the same thing again. I am applying F1 that beta. So here I've applied F1 alpha then I've applied alpha F1 beta which means that alpha and beta have to be the same thing. Right. So that is why it infers alpha to alpha to alpha to alpha.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So if I so to say what I'm to just give you an idea of how this is inferred. If I just say twice is just F of X the type that will be inferred is alpha to beta to alpha to beta because we haven't specialized this beta. Right. And because we apply F here it's type get specialized.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

And the reason is that the return type which is beta is being and F is being applied on this beta. And these are two type variables and these two type variables have to unify.  They can they can only be the same type. And the way to do it is to say wherever you find beta just replace that with alpha and you get this type. So so yeah. So try to. We will see some of this when we study.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

And we are already seeing this but also when we study lambda calculus. So this is it's useful to understand how OCaml infers the type. Because you might get strange type errors which can only be sort of answered. I mean this is not hard. Right. This just that you just need to sort of work out from first principles. Right. So leave it as general as possible initially and then try to infer the types.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

We will study something called simply take lambda calculus which will sort of clarify what is going on here. A lot. And we will also study prologue and prologue. So prologue the way of the way how prologue performs evaluation is very similar to how OCaml performs type checking.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

It may seem very nebulous now but at the end of the course I assure you that you will actually see that these two concepts right where I say oh functional programming and logic are sort of very closely tied together in this idea of type inference and prologue's execution model unification. Right. So we will see all these cool stuff later but now let's proceed the step by step. OK so we saw this and yeah there are very standard way of doing higher order programming over lists and these two functions are called map and fold.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

Right. So these are things that you would come across again and again and again not just to know camel even if you do say big data right you would come across this idea. Actually there is a very nice article in New Yorker about how Sanjay Gemavath and Jeff Dean who are the only two Google senior fellows there are only two senior fellows in the ladder in Google.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

Right. And these two people are Jeff Dean and Sanjay Gemavath. It's a really good article if you like reading about technology. I think this article is must read. And this article sort of explains how and why Jeff and Sanjay built MapReduce which is which is which sort of kick started the big data revolution and now the revolution as well. Right.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

Back in the 2000s it used to be big data cloud and so on. Now it's all machine learning and AI but the systems that underlay the machine learning and AI are all sort of offsprings of what came out of these two people's implementation. And in that article it's called MapReduce like Google has MapReduce this became Hadoop and this thing then Spark is an offspring of that spark is something that is widely used for these big data tasks today.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

So in that article Sanjay and Dean and Gemavath say that Google's MapReduce abstraction is inspired by Map and reduce parameters present in Lisp and many other functional programming languages. So they got their inspiration from functional programming. Actually the idea is quite simple. So they sort of made a lot of systems level innovation but the core ideas about map and reduce are what drove big data revolution.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

And what is map? A map is a function. It is under list module so it's called list.map takes a list. It has n elements a1 to an and a higher order function f and returns a new list. And what are the elements of this new list? The elements of this new list are f applied to a1 f applied to a2 all the way to f applied to an.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

So this is the definition of what list.map does. So for example here is a function that says maps the function which takes a person and then returns the shirt color of the person and they apply it on a list of these three starter characters. So and if you do that the result you will get would be gold blue and red.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

In particular there are a few things that you want to notice here. The length of the list that is written by map is the same as the length of the input list. And you are just mapping this function over each of these elements individually. And you could this one next shirt color X could be written more succinctly. As just shirt color because both of these functions have the same type it's taking an X and applying it to a function called shirt color.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

Right. But you can just write the shirt color and you will get the same behavior and this is more idiomatic. Right. This is what we will write. Yeah. Okay. And this is the same slide. So look at this.map. The list of map says I take a higher order function which goes from alpha to beta. Right. I take an alpha list and I will return you a beta list.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

Right. That is because you are applying F on each of the elements. Right. And that transform each of the elements alpha into a beta and the original input is the alpha list. So you get a beta list. So here is an increment function. Right. I'm mapping an increment function over one two three and the result you get is two three four. You take this function and apply it on each of the elements. Right. And map itself is quite simple to your implement.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

Right. So there is no magic going on in map. It's a recursive function. Right. It takes a list and the function if the list is empty. You just return the empty list. If the list is non empty you apply F on the first element. Right. And then cons it to a recursive invocation of map on the tail of the list. And that is all it does. Actually this is the implementation that the standard library has.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

So this has the same type as what I had shown in the standard library list.  And you can argue that this implementation has a problem because it is not tail recursive. But generally this is not a problem in practice.  Rarely will you have a list which is so large that your stack will overflow. It's actually fine in practice. Mostly in practice we are not summing up numbers from one to billion.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Right. That was a bad example. But here the stack depth is limited by the number of elements in the list. And usually it's fine. Right. So I wouldn't think twice about using map. But if you really wanted the data custom map there is a map. Right. So which is a data custom map but returns the reverse of the map elements.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

And what is the map map map takes a function list and an accumulator. If the list is empty you just return the accumulator. If the list is non-empty then in the accumulator do f of x. Append it to the accumulator and recursively call rev map on the tail of the list. So the first element is going to go to the end. Right. And you're going to keep adding elements to the front of it from left to right.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

So you get a list which is a reverse of the original list. Where each element has been applied by x by f. Right. So in order to get the semantics of the map you need to reverse the final list as well. So here is how you get the map semantics back. Right. So I do rev map. I get the map whose results are in reverse. And there's a function handy function called list.rep.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

This is also easily implementable. You call that function it will reverse the list and give it to you. And now this map behaves the same way. Oops. Yeah this map behaves the same way as the standard library map and the non-tail recursive map. The downside is that we need to iterate over the list twice here.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

It's a stale recursive but this map first needs to iterate for rev map and then needs to iterate for rev. Right. There are two iterations. So the con even though it's still often the constant factors are larger. Right. So in practical programming constant factors do matter. So I just start using list.map and if it doesn't stack overflow fine. If it does stack overflow think about how better to organize your program.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So OK. So this is rev map. I think I'll stop here. I'll save a fold for the Friday's class. Any questions on this. And you have a few minutes and then we can stop. So just to look ahead there is a few.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

Yeah there isn't much. There is some uses of fold and fold is very powerful. Fold is sort of. Yeah it's like a lot of things like one drink to rule them all. So fold is the only thing that you actually need in functional programming. You can actually implement all the possible useful things that you want to do on a data structure. Right. Not just list any data structure. Right.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

And the only function you'll need is fold. It's actually a really nice concept. So fold is sort of. So if you've done. You've done. It rate worse. And. In say C++ right or Java as a treat us. It is a generalization of it rate worse so you can sort of it sort of knows how to it rate over a data structure.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3072.6s_

And that is all you need essentially. And we'll see how that works in practice tomorrow on Friday. At this point you should be able to start working on the assignment one. Right. So there is I believe one question that uses fold. But except that you should be able to finish the rest of the assignments. Just using map and the usual recursive implementations. So OK so I'll stop here and then we can catch up on Friday. Thank you. Bye bye. Thank you.

---
