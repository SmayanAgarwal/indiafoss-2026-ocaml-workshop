# 26-cs3100-pop-lec-26-streams

**CS3100 POP - Lec 26 - Streams**  
id: `5ZTyltUMILQ`  
duration: 3387s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

All right, so we were looking at the last thing we were looking at yesterday was Fibonacci sequence and we encoded the Fibonacci sequence and what we observed is if you run Fibonacci sequence for say, take the first, give me the first 30 Fibonacci numbers, it takes a

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

while, right? So it's noticeable and then it produces the results, that's fine. But really, I would call this inefficient. In particular, this stream encoding has the same exponential behavior as the usual recursive Fibonacci encoding, right? And we know that this is not the appropriate way to encode Fibonacci, right? So in your first assignment,

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

you had also encoded Fibonacci sequence using tail recursive encoding, right? And hopefully we can do the same thing using streams. Otherwise, all of these nice properties that we've seen where you can take individual pieces, combine them and do interesting stuff, they shouldn't be just an intellectual curiosity, right? They have to be usable in practice. So what can we do here? So what is it that we want to do, right? So abstractly, whenever I call

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

Fib of n minus one, that internally has a call to Fib of n minus two, right? And Fib of n minus three, and I have a call to Fib of n minus two here. So if I've computed Fib of n minus two in either of these places, right, I should be able to use that particular result in the second call. So can I reuse the results of a particular function in negation?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

If the function is happens to be pure, which we know it is here, and the argument is the same. So if the function is pure, and the argument is the same, the result should be same, right? Can we do something where we can reuse the results is what we should be asking if we want to optimize this Fibonacci? Of course, the details are there, right? So you can use manually encode this and all of that. But the question is, can you still maintain

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

this nice way of encoding Fibonacci but still be efficient by reusing intermediate results. So we go back to the thing that we have had seen in the lambda calculus semantics, which is call by need reduction strategy. We have to recall what does call by need reduction strategy do? Call by need reduction strategy does not reduce a particular, does not reduce the RHS of an

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

application unless it is really required, but also ensures that if the same expression is reduced twice, then we share the results. So we hadn't implemented call by name need, we had only implemented call by name, but call by need is a variant of call by name, where you tend to reuse the results of certain reductions. And it would be nice to have this as an OCaml feature as well.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

So in OCaml, I would like to save the results of execution previously seen, right and reuse them. And this is what OCaml provides in terms of what is known as lazy values. So OCaml has an opt-in feature for call by need. And the feature is called lazy values, while the rest of the language is called by value, right, which is also known as strict evaluation. OCaml has this opt-in lazy value

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

call by need reduction strategy, which is what we are going to use in this example. So the lazy module in OCaml has a few different functions, but these are the core ones, right. So essentially there is a type called alpha t, okay, so that produces a lazy value, right, you can represent lazy values using this type, and you can force lazy values. What does forcing mean? Forcing just

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

means that go ahead and evaluate this lazy value to reduce it to some value alpha. Okay, so you reduce that value to alpha. And if you force it again, if you've already forced it, you just reuse the result from previous invocation, right. So the idea is that if you force the same lazy twice, the first time you would actually go ahead and evaluate it, the second time you just reuse the

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

results from the previous evaluation. This has some strange semantics in the presence of side effects. So here is an example to just walk you through what happens. So we have this, we have this keyword called lazy in OCaml. Okay, so lazy is just a keyword, you can put lazy around a particular expression, the expression will not be evaluated. So what does this expression first do? So what I'm

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

doing is I'm doing 10 plus 20, right, I'm doing 10 plus 20. But I happen to also print inline hello. So this is a nonsensical program. But all I'm doing is I'm computing 10 plus 20. But while evaluating this expression, I also print and line hello. Right. So if I don't have this lazy, what will happen is I print hello, right, because of this

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

print. And then this whole expression returns 30. Right. So that should be that should be straightforward. If I add a lazy around it, again, lazy is a keyword here, right? Lazy just stops the evaluation. So let's see what happens when you evaluate this, what you get back is a int lazy t.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So the type says that we is lazy computation, right. And when you force this lazy, what you get back is an integer, in particular, what you get back here will be 30. Right. You just got this suspended computation. Now, this should remind you of something that we have done earlier, right. You can think of morally, this is very similar to doing something like this.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

Right. v is a computation, right, which when v is a function, which when invoked returns you 30, but also performs the effect, right, it prints end line when you call this function, not before, right. In the same way, lazy gives you a suspended computation, right, this expression is not evaluated at when you force it, it will go ahead and evaluate. The only difference is

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

when I force this value, say once I get in 30, I also print the value hello. When I force it again, I've pre computed the result, right. But I'm not going to repeat anything that I've done previously. In particular, I'm not going to repeat this print end line. So the second time you force it, you don't see the hello. So the effect, the act of computing

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

the result is only done once. Right. So that's the difference. And this is the difference between doing this and something like this. If you if you say, convert this expression into a tongue like this, every time you evaluate it, you will get the you will get the print end line printed out. So just to show that this works this way. I I've evaluated this function twice, so I get this twice. But with lazy, what we get is if the function is computed,

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

if the lazy is forced once, right, you get the hello the first time, but not the second time, you just get the result. That is all lazy is doing right. So lazy just says, evaluate the computation. If it's previously evaluated, just return the result. Okay, so

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

we saw this analogy, we saw this comparison between lazy and this thunk, right? And they have some similar looking features. So what we're going to do is we're going to sort of replace our definition of the stream data type from using thunks to using lasers. And we will see how it performs. Okay. So in order to see how it performs, the semantics is going to be the same.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

The only difference is going to be execution time, how fast the program goes. So I'm going to have a helper function that will help me measure type. So the function is I'm defining as I met, right, that takes some thunk f, right. And I'm using features from Unix, right get time of day is a Unix function. So if you sort of look at get time of day, look it up,

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

it's the same function that I'm using in OCaml. So it returns the current time and as a floating point number, right, I measure the time before calling the function, I measured the time after calling the function. And then I subtract the time at the start to get the execution time, the execution time is in seconds. So I multiply that by 1000 to get the execution time in milliseconds. And I also return the result. So what time it does is given a thunk, it returns a pair of the result

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

and the time it took to evaluate the function. And the reason why we do this is we are going to keep measuring time in the rest of the lecture, right. So just to show you that certain encodings are efficient. So that's time it right. So it takes a thunk unit to alpha, and then it turns you a pair of alpha and this floating point is the duration that it took for executing the solution. Okay. So first, let's see whether the

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

whether a naive encoding works out, right? Naively, what I'm going to do first is, oh, I know fib 30 taking 30 from the stream fibs is expensive. So let me just put a lazy around it, right, lazy around the whole thing. So what I'm doing here is I'm getting the first 30 Fibonacci numbers,

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

I am reversing it, I'm getting the head, which means I'll get the 30th Fibonacci number, right? I'll return the 30th Fibonacci number. And I'm making this into a lazy computation. So I am naively trying to make it faster. Let's see what happens. So if you do this, you get a computation, which is a int lazy dot t, in particular, this is a lazy computation that

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

will return you the the the return user 30th Fibonacci number, right? And now what I'm doing here is I'm calling this fib 30 of lazy by timing it, right, I'm timing it. So this will be the result of the 30 lazy, which is the 30th Fibonacci number, and this will be the duration of the execution. So I just printed out in a nice form here. So if 30 of something is this and time is in milliseconds, right? So when you run it, it takes a while, right? This star thing is showing that it

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

is evaluating. So we get the 30th Fibonacci number, we also see that that it took 3.15 seconds, right? And because I have a lazy around the entire computation, and I force the lazy in the body, right, I actually forced the lazy here. Because I've already done this once now, I'm going to run it

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

again. The second time you run it, we get the same result. But you also see that it's much faster, right, instead of 3.15 seconds, this took this took 306.36 milliseconds, right? So you can keep running it again. The time changes, but this is so low that it is just showing you the usual variance that you have measuring very small things, right?

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

It's much faster than the initial run. Okay, that's good. So given a particular call for the fib of a particular number, if you ask for the same number again, then it's fine. Right? Let's try the same thing with the fib 31 of lazy, right? So I'm doing the same thing with fib 31 of lazy, right? And I'm measuring the time. So the thing that we are missing here, right, so it takes

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

a long time. The thing that we are missing here is I've already computed fib 30 of lazy, right, in the previous slide here. This fib 31, which internally also contains a call to fib 29 of lazy, right, which is what I would require for fib 31 of lazy, right? So essentially, fib of 31 will recursively call fib of 30 and fib of 29, both of which I have pre computed here. But I'm not

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

using the results in any interesting fashion here. And this execution took almost five seconds. Right. So by just putting lazy around the entire computation, we are not going to make it any faster, because I am not, I'm not reusing the results of the recursive calls, I'm just reusing the results of the outermost call. Right? So of course, if I run this particular number, again,

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

it will be faster. But if I ask for 32, it will be as low as molasses again, right? So so we are not reusing the results of fib 30 in fib 31 here. So how can we make this better? So the important observation is, when we perform the recursive calls, we are not reusing the results, we are just using lazy at the outermost level. So this is not going to work. So we need

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

to embed lazy deeper into the definition of the stream data type, right, which is what we do here. Right. So I redefine the stream data type. So this is a redefinition of the stream data type, where I say a stream as the cons constructor, it has a value, right, the head value, and the tail is a stream. It's a lazy stream, it's a lazy stream of alphas. So recall that the earlier

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

definition used to be unit arrow, alpha stream, right, this is what we were working with so far. So morally, this is doing the same thing, right. So it's also producing a lazy computation, sorry, it is also producing a suspended computation for the tail. But the important difference is that we are not going to repeat evaluation of any functions. If the stream has been computed once, we are going to reuse the

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

results for the same invocation again, that's the most important difference. The rest of the head of cons, tail is get the tail, right. And instead of now we actually lazy force it earlier, we used to call that function because it used to be a function, we now just force

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

the lazy now to get the tail of the stream. Take and zip are just the same functions. So these are character to character, the same function as what we had used earlier. The only difference in head, tail, take and zip is this lazy dot force here instead of calling this function and okay, so now we have a lazy stream which internally uses lazy.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

We've defined all of these four functions because these are the four functions that I'm going to use for Fibonacci. So I construct the fib lazy stream, right. So again, this is the I just use a different name. This is alpha equivalent to the previous definition of the Fibonacci stream that I had. Now this is much faster. So I'm actually doing 100, right. Take the 100

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

Fibonacci number, give me the 100 Fibonacci number, this is going to be very fast. This took 0.1 milliseconds. Recall that even 30 took some three seconds or something and then 31 took five seconds. This is 100 and it goes very, very fast. The reason is that all of the recursive calls that we had are being memoized, sorry, are being cached and reused. So what is happening here is we are as efficient as writing our tail recursive lazy or your sorry, tail

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

recursive Fibonacci or your Fibonacci description with two variables, right, which is what you will do in C. So there's a question. I was going to stop here anyway. So in the definition of the stream, what is the meaning of adding lazy.story up to the stream? So that's the type, right. So

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

any lazy computation has the type alpha lazy t. Whenever you wrap something with the lazy, the thing that you get back is a integer lazy. So if I do something like lazy 10, I get int lazy. And when I force that lazy dot force of v, I get 10 back. So all the type says it is a

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

lazy computation, which when forced gives you an integer is what the type is saying. Does that make sense? And the reason why this is so yeah, so you're asking about this. So the way to read this is the type stream, right, contains a single constructor, which has the head

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

value alpha, and the tail is a lazy stream. Right. So it's a it's a it's a computation, which when forced gives you the tail of the stream. That's the way you have to understand it. And the and the reason why this shows up is we use lazy here. Right. Just look at the definition of this we use cons one lazy cons one lazy, our earlier definition of Fibonacci string

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

used cons one, because we we had used a dunk as the way of describing suspended tail computations. That's the difference. That's that answer your question. Okay, so the second question is, sir, is saying that this stream is lazy different than saying that each element is lazy. So we can define it as

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

the stream is lazy, right. So the each element is not lazy. So the way we've sort of encoded this is in for in the same way, we've sort of suspended the tail, right. So we've sort of said the tail of the stream is a suspended computation. When you need it, you actually invoke it,

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

we are just suspending the tail of the stream using a lazy. Okay, so any question that you can ask about lazy, you can also ask about this definition, right. And for the same reasons, we came down to using a tank for the tail, we are using lazy. There is nothing else that is different, but lazy is internally giving us the reuse of cache results. As it sort of answer your question,

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

sir. Refrace your question, right? You ask yourself the same question that you're asking here, using the previous stream definition. Right. And I think if you can answer that the same answer will be the answer here. Okay, so good. So we got this one to be much faster. And okay, that will be

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

okay. Yeah, so so this this is faster. And this is as efficient as writing, writing the usual tail recursive function that you had written in assignment one. So okay, so I use this one word, which I sort of quickly took back, I use this word called

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

memoization. Right? So and I said, Okay, take it back. Lazy values in OCaml are a general idea, written this general idea in programming called memoization. memoization is a fancy term, but all it stands for is caching. Right. So if you have a pure function, you and the function, because it is a function, it's a mathematical function, you give it some value, it will return

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

some value, right? Mathematics, you don't. If you're just looking at the semantics of the function, in terms of what it does, you're not going to worry about execution times. But when you write programs, you do worry about execution times. So the idea is that if you have a pure function, if I give it some result, after a lot of time, it runs some result, I can just cache the result, I can store it in a table, right input and output pairs. And the next time I get the same argument

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

for the same function, I can just return the result immediately. Right. So this is an idea which is called memoization. And lazy values in OCaml are a specific implementation of this, right. So there is a there are some details, which makes it very efficient to implement lazy values in OCaml, they are embedded deeply in the compiler. But this this whole idea, right, this is just caches attached

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

to pure functions, right. And let's see how to build this ourselves, right. So the idea itself is interesting. But it's not too complicated. It's just the idea of saying, Okay, if you give me a pure function, I'm going to attach a cache to it. And this cache will record the previously seen arguments and result pairs. Right. So we can do this very nicely in OCaml.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

So that is what we'll see in the last part of the lecture. Okay, so we are going to define this function called memo. And the idea is that if you give me a pure function, any pure function, right, some alpha to beta, I am going to attach a cache to it. So I'm using a hash tables here, you've not seen hash tables in OCaml. But hash tables are just the hash maps or other things that you might

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

have seen and say C++, right. So what are hash tables hash tables are are going to give you it's a data structure with the key and the value, right. And you can insert and remove these entries. If you look up with the key, you will return the same value as seen before. And that's generally efficient. So it's most operations happen to be login, right. So that's the advantage that our details are there. So we have a hash table in OCaml as well. Right. So what I'm going to do is

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

because I'm attaching a cache to a function, I'm going to create a hash table, and then attach it to this function. So how do I do this? I first create a hash table, the 16 is a number that sort of signifies the initial size of the hash table. The hash table size is just the initial recommendation, but it can still it can keep growing. So you don't have to worry about

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

sizes anymore. So that's the cache, right. And I'm going to return a new function, right. So memo is going to take your current function from alpha to beta is going to return the new function from alpha to beta, right, which has this internal cache attached so that it is going to look up the arguments first in the cache. If the value is already if the argument is already in the cache, then the value is going to be the result, it is just going to return that. If not, it is going to compute it, add that entry to the hash table, and then return the result. Right.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So this is what we're going to do. And since we are defining a new function, I define a new right, you first look up in the hash table, whether that value is there or not. So for this, we are going to use hash table dot find option. So find option gives you none if the entry is not

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

there. Find option gives you some result if the entry is there, that's the value that we look up. So I look up the hash table cache with the key v. If the key is there, right, I've already, I already have an entry for that particular argument, then the value that is associated with that will be the result of the computation. So I just return the result here. If not, maybe

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

you've not seen this value previously. What you first do is actually call the function, the original function f with this value. Right. So you get a result. So I got the result now. You add to the hash table, right, this cache, a pair of this is the key, the value, sorry, the key, the argument and the result. So now the hash table has an additional entry.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

And then you return the result that you computed. So hash table is a mutable data structure, right. So it has it, if you add it, it destructively updates hash table. So you don't need to keep passing it around or anything. But all we've done here is we've attached this cache hash table to this function, right? Now, whenever you call the resultant function, we are first going to look up in the hash table. If it is already there, just return the result. Otherwise,

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

we're going to first compute the result of this function invocation, add an entry to the hash table, and then return the result. Okay, so, so as, as I suggested earlier, the memo is of is a function that takes any alpha to beta function, and then returns an alpha to beta function. So imagine there is a bracket around that. Right. So even though it is written this way,

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

it's like you take some function, and it's going to return a function, the only observable difference between these two functions is going to be the execution time, because we have a cache and the presence and presence of side effects. Any questions regarding this definition?

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

So I'm, I'm using hash tables here, but it should be fairly straightforward, the use of these options. No questions. Okay. So now let's use this memoization for something interesting. So let's see whether this is useful in practice. So here is here is

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

it is a spin function. So all I'm doing here is given a number of iterations, I just loop for so many iterations. This is just to add some time. Okay, so spin is a recursive function, if n is zero, then it simply returns unit, otherwise, it recursively calls spin with n minus one. So it simply adds some execution time, right? It's just a tight loop. So it takes a number of iterations and does nothing useful, except it spins for a while. So I define an expensive

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

identity function, right? This expensive identity function spins for a little while, and then it does the same value. So the type is going to be alpha to alpha, right? The type is the same as identity function, except that this will be really slow. Okay, so it's going to spin for a while. So now let's aim this function, right? So I'm,

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

I'm calling time met on this expensive ID. I'm going to get the result of which is not interesting. And I'm going to print the duration. So let's see how long it takes. So take a few seconds. So it took 3.6 seconds here, right? So because I had called this function at 10, because and because that is an identity function, I get 10 out. That's not a surprise,

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

it just took 3.6 seconds to execute. So now let's memoize this identity function. So what I'm doing is this function, right? So I get a new function, which I call memoized expensive ID. And the difference between this function, and this original function is that now we have a cache associated with this function. But if you look at the type of this one, it is weak. Because of weak

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

polymorphism that we had studied earlier, I'm not going to go into the detail, but it's still an alpha to alpha, right? So that's the observation here. Don't worry about why this is a weak. The short answer is that this is an application and it has arbitrary effects. In particular, it builds a hash table internally. And that is why this function cannot be in multiple types. You cannot apply string ones and integer ones, because the hash table will contain string and

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

integer. And we don't like to make stripes in OCaml. So this weak polymorphism is necessary here. Okay, so that's fine. So now let's call the let's time the memoized expensive identity function with the same input 10. So the first time we are invoking it, it still takes a lot of time.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

In particular, it took almost the same time as previously, right 3.65, 3.681 seconds. But the next time you call it, it's going to look up the value 10 in the hash table, right? And it's the the value is going to be there in the hash table. So it's going to return very fast. So we got the result back in 0.01 milliseconds. So this is how memoization works. Of course, the hash table keeps growing inside what we are doing is we are trading off space and time.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

So because this function is really expensive, we are adding a little we are adding a table, we are using extra space in order to trade off time. This is not like a perfect cash, right? This is not a cash that you would want to actually use in practice in particular. This keeps growing. So if you have say a million values, the cash table is going to contain

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

million elements, we don't have cash eviction policy or anything. I think you might have studied cash eviction policy policy in computer organization. So we want something like that earlier. The actual implementation of something interesting will have to do all of that. But that's not the point here. We sort of built something that works. So let's use it in more interesting fashion. So the function that we have here

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

is a non recursive function. So we memoized expensive ID. And this is a non recursive function. So that memoization works nicely. But it turns out that the recursive function is quite tricky. But the same reason why this using a lazy in Fibonacci stream was a little bit interesting.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

memoizing recursive functions is also a little bit tricky. So in particular, we need to do this idea called tying the recursive knot. I will slowly lead you on to the problem. So let's start with a simple recursive function that we all know how it works. And then we'll slowly see how what is the problem and then we'll come up with the solution of memoizing recursive functions. So here is the usual

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

definition of Fibonacci, recursive Fibonacci inefficient one. We know how this works. So if you do 5040, it's going to take a while. I don't know how long it's going to take. Okay, seven seconds, okay, 7.7 seconds. And it returns the result. So let's do what we've done previously for expensive ID, right? Let's just memoize

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

the Fibonacci function, I'm just going to call memo fit, which presumably what it's going to do is return you a memoized version of Fibonacci, which internally has a cache, right? So let's try to invoke this function. So here is a memo for let me run this memo fit here is memo fit of 40. So this is going to take a little bit of time, the same as what I had what it had taken earlier,

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

almost 7.7 seconds, right? Because I memoized 40. If I ask for the same value again, it gets me the result really fast, right? 0.009 milliseconds, right? So that's quite fast. But if you sort of look at the structure of Fibonacci, right, when I call Fib of 40,

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

I'm going to call Fib of 38 and Fib of 39. If the function were memoized, does it mean that the recursive calls have also been memoized? It turns out it is not, right? Because we are attaching memoization at the top level. So if you call Fib of 39, it's going to take a lot of time. Right. So this is this is this is taking 4.9 seconds, even though Fib of 40 calls Fib of

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

38 and 39, which internally calls Fib of everything. When I call memo Fib of 39, just after memo Fib of 40, it still takes a lot of time, right? If you run this again, it goes faster because there are two entries in the hash table now, one for 40, one for 39.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

The problem, what is happening here is this memo fib, right, is only memoizing the outermost call. So when you call with 40, it is looking up 40, right? And then it says, okay, initially, there is no 40. So I'm going to call it, it's going to compute the result and going to store 40. And the result, which is this number in the cache, right, but it hasn't memoized any of the recursive calls. Any of the recursive calls are still going to be calls to the original fib function.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

Right. So this is completely missing, right? So, so that is why even though Fib of 40 calls Fib of 39, we are not reusing the results here. This is undesirable, right? So ideally, you want to memoize all of the recursive calls as well. So that instead of this being exponential, this is actually linear. So there are only linear number of calls. So we keep reusing the previous results. So how can we do this? So

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

abstractly, right, what is happening here is whenever I, I, I create this memoization function, I only memoize the outermost call, I don't memoize any of the recursive calls. So how do we do this? So let's let's stop here. So we get a sense of what the yeah. Okay, so start that has a good point. So if we had a global cache,

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

it would not have been a problem. No, it would still be a problem, right? Because, because if you think about it, when I call memo of fib, right, what does the memoization function do? The memoization function calls fib here, right, fib of 40 here. And, and fib of 40 internally is going to call fib of 39, fib of 38, those are not memoized, right? What has to happen

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

is that the memoized version has to recursively call the same memoized version. Right. So abstractly, I don't know why this went all the way here. Um, So this memo definition, right, so we have the

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

yeah, this definition. So this wouldn't be solved with the global table, because when I memo is something I add something like do memoization, right, and then do memoization. And just sort of writing it down

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

abstractly to say, here, we check for the entry n, right. And then if it is there, return the result, otherwise go and compute this function, right? This is not actually calling the memoized functions, the recursive call calls are all on the original function. Ideally, we want all of these to be memo fib, right? This needs to be memo fib, this needs to be memo fib, this needs to be memo fib. I mean, you have this chicken and egg problem now, right? So we want to define the function

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

memo, independently of everything, right? And we want recursive functions to use memoization. But we have this chicken and egg problem, because the definition of recursive function itself needs to be aware of the fact that it is going to be a moist. I mean, this is this is this is the problem of what I mean by tying the recursive not right. So, so yeah, so thanks for

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

that question, Satak. Help me answer it even more. So that's the problem, right? Even adding a global hash table will not fix this problem because the recursive calls are still happening on the non memoized version. How do we fix this? Of course, we have a way to fix this. So it's a bit and again, this is this is this is harking back to the ideas that we've previously seen. And we are going to combine a few interesting recipes that we've seen so far. In particular,

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

right, the first technique that we are going to use is we are going to use an encoding that we had used for passing functions to Y combinator, right? So recall that when we looked at Y combinator, we had this explicit function, right? This function is sort of describing a Fibonacci function again, right? But it's a non recursive version of Fibonacci. The idea is that this function argument,

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

just like we had seen in when we used Y combinator, we will use this function f to be the recursive version of the function that we are defining here. Right. So the recursive calls as of n minus one, sorry, on n minus one and on on n minus two are going to use this function. The idea is that somehow, somehow we are going to create a recursive version of this non recursive function, which will be passed to this f,

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

and we are going to invoke it here and here. Right. Somehow, this is precisely what we have done in Y combinator. Whenever we wanted to use an Y combinator, we had this extra argument, right? Where we said any recursive function takes this extra argument, which will be the recursive version of the function that you are defining. Right. That's the first idea. Right. So,

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

yeah, so we are observed that the original recursive function simply names. If it is fib here, it is just fib here. This fib no rec names the function, but also takes an extra argument. This will be somehow filled in with the recursive version of the function that we are defining. Okay. So that's the idea there. So the way we tie this thing, right, we fill this in is we will use a reference, we'll use our mutability features in the language to tie the knot.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

Okay. So this is perhaps the one of the most complicated programs, three line programs that you will see. So we will walk through it. And I'll hopefully try to explain it. But I also want you to sort of go through it in your own time as well. Right. So our problem is you want to memoize

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

recursive functions, right? There's also memoizes all functions irrespective of whether it's recursive or not. But anyway, so here is here is how we do it. So we define a function called memory, right, that takes a non recursive version of a function f no rec, right, which has to be in this structure. If you want to define a recursive version of memoize Fibonacci, you have to define it

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

like this. So you define a function name, you it takes an additional argument for the recursive call, right, but internally, the body is going to look like this. So that's the expectation here. So f no rec is such a function, right? First step as a first step, what we're going to do is we are going to create a reference called f ref that points to a dummy function, this dummy function is not going to be invoked, right? So that f ref be this reference, that's a reference

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

to a dummy function that takes some argument and then says assert false. If you ever are able to call this function, this function just terminates the execution, right? It just stops the execution. So in the first step, what we've done is we created this f ref variable that points to a reference to this dummy function, I represented functions with this parallelogram, right? And I

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

have a stop sign just saying that this function should not be invoked. That is what has happened in the first step, right? In the second step, what we do is we memoize the function, this f no rec function where the where we use the reference, where we use the function from this reference.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

Okay, so let's do this step by step. So I create a function called f f rec memo. The idea is that this f rec memo is the memoized version of the function that we want to define. Okay. What it's going to do is it is going to call memo on this function. Right? What is that function? It's going to take a value, some argument x, it is going to call this function

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

that is passed, right? The original function that we want to memoize simply that f no rec for the second argument, right? This argument here. So the argument for the recursive call, what we are going to do is we are going to dereference this reference that we defined in the first step, right? That is going to be a function, which is what we are going to pass

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

as a recursive argument. And we are just going to pass the original input function x, sorry, the value x as the argument. And this would, this would fill in the end here. So the observation is that we are somehow going to dereference this. The important observation is we are not dereferencing this f ref yet. This function is going to be dereferenced only when you call it, right? Because we have, we have put this in an anonymous function,

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

only when you call this function, is it going to be dereferenced? So what is happening here is we created this f rec memo function, this effect memo function, right? That's a memoized version of the original function, which internally refers to this reference here, right? This f ref here, which is what this is pointing to. It is pointing to this reference, right? But it is not dereferenced

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

yet. The idea is that if you dereference it now, it will actually point to this function that should not be called, right? This function, but we are not dereferencing it. Okay. So we have a memoized version of the original function, f no rec function here in f rec memo. And the last step that we are

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

going to do is update this f ref reference to point to this recursive function that we've just defined, right? So what is happening here is we are going to update this reference, this reference here, the square reference to point to the same one. So this is what we've done with by tying the recursive knot. So ideally, what has happened here is if you take a step back, right from the code,

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

we have memoized the original function, right? Where internally, every call to the recursive argument is going to be the same function that we have just memoized. And that is what is happening here. Of course, the details are all there. But at the high level, that is what has happened. So we've memoized this recursive version of this function, which is written in this very specific way, right?

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

It takes the recursive function as an argument, the first argument. So we have memoized that function. And we've said that for the first argument, because we've updated f ref to be the function that we just memoized, we've tied the recursive knot. And finally, it looks like this, right? We, we dereference this function every time we recursively call it, but it's going to point to the same function. And actually, this variable is no longer required. The thing that we return

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

is refreq memo. We return this memoized function. So what we started with this is this f no rec. And we used a reference here to make this function recursive, but also memoized. Okay, so it's a little bit mind bending. So it's okay if you don't get the details of this instrumentation here. But it's combining multiple ideas that we've seen previously, right? It's

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

combining the fact that you have a memoization, you have you have, you have references here to tie the knot, we have recursive functions, we have ideas that come from what we saw in y combinator with this additional recursive argument, we put them all together to create a recursive version of memoized version of a recursive function. I'm not going to keep repeating the same words, because that will just confuse you even further. But I just want to show that this

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

actually works in practice, right? So once you have that, you can memoize the recursive function fib no rec. Right? I need to run this. So yeah, so the type is not important. So anyway, so here is so this is fib no rec. Okay, and then here is the memoized version of the Fibonacci,

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

the recursive Fibonacci. I recall that this earlier took around seven seconds. Now, because we are actually memoizing each of the recursive calls, when you call fib of 40, you would call fib of 38 and fib of 39. Since the cache is empty, you would call fib of 39 that goes through all the way and then comes back, you save the result in the cache for fib of 39, you would have two

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

recursive calls, right? That would be fib of 38 and fib of 37. Both of these are previously computed. So it turns out that the execution time is linear with the memoization. Of course, there are the constants are very large, but that's not the point, right? It has gone come down from seven seconds to

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

point oh nine milliseconds. And similarly, fib of 41 is also really fast. It is actually using all of the results from fib of 40 as well. This is not even linear. This is like constant time, right? It has 39 and 38, both of which have been previously observed. And, and yeah, and that's how you memoize the recursive function. There is one last example that uses this, but we'll have a look at it tomorrow. I've already taken five minutes of your time. If you have any questions

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3300.0s_

quickly, I can answer. Otherwise, I'm happy to answer questions in the next class. I'm not going to ask you to write this program in the final exam or anything, right? So no need to try to understand the ideas. But yeah, but this is just not a thing that I would,

---

![slides/interval_0111.png](slides/interval_0111.png)
_t = 3300.0s -- 3330.0s_

I would expect you to come up with in an exam or something. Okay, so take, take today and tomorrow, right? And on Friday, we'll just pause for questions.

---

![slides/interval_0112.png](slides/interval_0112.png)
_t = 3330.0s -- 3360.0s_

Then I have one more example. This is on edit distance. And the idea is that memoization actually captures dynamic programming quite nicely. So what we've done here is dynamic programming, right? So the idea is, if your function is pure, you can have the description of the problem as recursive description and make it as fast as a dynamic programming problem without

---

![slides/interval_0113.png](slides/interval_0113.png)
_t = 3360.0s -- 3380.9s_

having to explicitly do all of the bookkeeping required for dynamic programming. So that's the, that's the idea here. And we will see that we'll see that work in a real example, where you do edit distance computation. I'll stop here. Thanks very much. Bye bye. See you on Friday.

---
