# 25-cs3100-pop-lec-25-streams

**CS3100 POP - Lec 25 - Streams**  
id: `ilNYZ5KXEnQ`  
duration: 3065s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so what we were looking at yesterday. So we were starting to look at the ideas of streams yesterday. So we had looked at motivations. We started to look at how you might program with streams in OCaml. OCaml allows you to do infinite data structures. But what we were grappling with is how do you actually manipulate

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

these infinite data structures in any useful way? Like we were trying to write this map function and post-pilot. So in order to refresh our memory, let's just look at what we had last seen and then we'll continue. So we observed that we could define a stream data type as a new type, an alpha stream, which doesn't have a nil because streams are infinite. And it only has a cons constructor where you have an element, right?

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

Which is the alpha and then the rest of the stream. Okay, so in order to construct a stream, you have to use this constructor cons for which you always have to provide another stream as a value. And the only way to construct this if you sort of think about it, right? Because you don't have nil. The only way to construct a value of this type is to have a recursive value. Okay, so we had this.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

You can construct a stream of zeros and ones, right? Using this by using the let-track on values. Just to recall, OCaml allows let-track on values as well in addition to functions. When you have a recursive function, you can call it recursively. When you have a recursive value, you can essentially tie the loop. And what is happening here is we are constructing a recursive value called 0 and 1, which is a, you can think of this as an English node, right?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

An English node with 0, which points to a node which has 1, whose next pointer points to 0 again, right? It is 0 once again, so it's a small English with only two nodes, but has a cycle of it. So 0, 1 and points back to 0, right? So we construct that. We see that this is a stream which has a 0 and a 1 and has a cycle here. So the OCaml pretty printer just doesn't print that it is 0 once,

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

but we know that this is pointing back to 0 once here. So if you write a recursive function toString, which takes this stream of zeros and ones, and we want to convert this to a string, naively you can do string of int of the head to convert the head element to a string and then recursively apply toString function on the tail, right? Because the list is cyclic, this function will never terminate.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So here is what we see, right? We saw this yesterday. So when you apply toString on 0 once, there's infinite stream, we get a stack overflow because the function doesn't terminate. So the observation was that we have to somehow pause the execution, right? And what do we mean by pause the execution? We need a way to pause the execution at the tail position, right? So we need to do something at the head, but at the tail it might be the case that we are back to the head.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

So rather than recursively applying the function that we want to apply on the rest of the list, we want to say, okay, I've done the operation that is necessary for the head, but for the tail I'm just going to not do it unless it is certainly required, right? So that is the idea of pausing the execution. And in order to pause an execution, we have seen ideas previously, right? We had this idea of a tongue. A tongue is just a function that goes from unit to alpha.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

The idea is that whatever expression you have in this tongue is not evaluated until you call that function, right? So you can take arbitrary expressions and wrap it in a tongue so that it doesn't evaluate until you actually call the function. So here is a simple example just to remind you of what a tongue does. So I am declaring a variable V, right?

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

Which is the result of fail with error. I don't know whether I introduced fail with earlier in OCaml. This just raises an exception called error, right, with this message. So when I evaluate this particular definition, I immediately get an exception, which just says exception name is failure and the string is error, and it immediately throws me that, right? So you can sort of pause this error being, exception being thrown immediately

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

by wrapping this in a tongue, right? All I've done is I've sort of created an anonymous function here where now what I have is a function which when I run, I get a tongue which goes from unit to alpha, alpha because any exceptions have an alpha type. When you raise an exception, that expression has an alpha type. So it doesn't raise an error when you define it, but when you actually call it, you get an error.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

You get the exception. This shouldn't be surprising, right? But what we are going to do is to use this idea in the definition of a stream that is usable. Okay, so the key point that we are going to use is this, the notion of doing a tongue, which will pause the execution. So how do we use this? So we are going to look at the same stream definition again, but now what we are going to do is to use tongue for pausing the tail of the execution.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

So I'm redefining the stream type as a new type. Type is alpha stream, right? It has a single constructor cons, which takes a, which has two things, right? It has the alpha value and the tail is now a tongue, right? Tail is actually a unit to alpha stream tongue. So that's what will give us the ability to pause the execution, right? Rather than having an alpha stream directly, we have a unit to alpha stream, right?

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So how does this help us? So first let's construct a value, a recursive, sorry, an infinite stream of zeros and ones. So as usual, let's take zero ones, right? First we have zero, then according to the type, I should have a tongue here. So I have an anonymous function, which takes a unit. And the tail is cons one, right?

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

That's the one and the tail of that is going to be another tongue, which points to zeros and ones. So all we've done is we've sort of introduced tongues at two places, right? Rather than directly pointing to the next node, we have a, we have a function, anonymous function that is sitting there. How does this help us? Let's sort of slowly build it up. So we want to eventually go to this map function, right?

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

Which maps over the entire list and then converts all of, see, map over the entire stream and then convert each of the integers to a string. So let's define helper function first. So I want a helper function for getting the head of the stream. So I define this function head, which just returns the head of the stream, which is the value in the cons. We only have one constructor, right? So we can match it at the argument position itself.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

So we are defining a function that pattern matches cons, extract the X, and then simply returns the X. So the type of this function will be, give me a stream and I will give you a head, right? And what about the tail function? So because tail is a thunk, in order to get the stream, you have to call this function. You have to apply this thunk in order to get the stream that is embedded within it.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

So tail is defined such that extract this thunk, XS is actually a thunk here, right? Because of this type. And now call this function. If you call this function, what you will get is a alpha stream node. So tail is a stream to stream. So given a stream, it returns you the tail of that stream. And in particular, what it does is it actually calls the thunk, right? So unless, so the point here is this, right? So tail is the one which is actually going to evaluate the function.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So if you're just looking at head, you're not going to evaluate the function. But when you say I actually want the value of the tail, you go and evaluate. So that is what is giving us this, going to give us the ability to not keep doing all of the operations when you map at the position of mapping. Okay, let's see how this works with more examples. So now I want to define this function called take, right?

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Take nS, takes an integer n, right? And a stream S and returns a list with the first n elements of the stream. So I have an infinite stream. All I want to do is to get the first n elements. So how do you do that? So you define it as a recursive function, right? Takes an n and an S. If n is 0, then you just return an empty list. So you want 0 elements. So you just get an empty list back.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

If n is non-zero, construct a list such that the first element is the head of the stream, right? Head is what we have defined in the previous slide. And you recursively call take on n minus 1 and the tail of the stream, right? And at this position, when you actually want the tail, the stream tongue is evaluated, right? So you recursively call this until you reach the end.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And this is not tail recursive, but that's not a problem here. So this should be fairly standard, right? This is the exact function that you will write for taking, say, n elements from a list as well. We've sort of hidden all of these marks within this tail function. So nothing's surprising here. So that's the take function. It takes an integer, it takes a stream and then returns n elements from the stream as a list.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

So we had defined the 0, 1 stream earlier, right? Which is an infinite stream of 0s and 1s. Let me just take the first 10 elements from it. So I get 0, 1, 0, 1, 0, 1 repeated five types. So that is this function in action. And we can also define a drop function which drops the first 10 elements from a stream. So give me a stream, give me n.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

I will return you a new stream such that the first n elements of the given stream is dropped. So how do you define that? It's a recursive function. If n is 0, then just return the original stream. You're not dropping anything. If n is greater than 0, then you just recursively call drop with n-1 on the tail of the stream. So by simply recursing on the tail, you're dropping elements, right?

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

You keep doing it until you reach 0. So that's the definition. So what do you get? Drop takes an integer, it takes a stream, it drops n elements from the stream to get you a new stream. So that's done. So just to make sure that it works, right? We had the 0, 1 stream that we defined earlier, which is 0, 1, 0, 1, 0, 1, 0, 1, and so on.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

If you drop one element from it, so this element 0 is dropped. What you get is an infinite stream that goes 1, 0, 1, 0, 1, 0, 1, 0, and so on. So which is what you'll see here. So if I run it, it prints 1, that you can sort of do take 10 from drop 1, 0, 1.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

So 1, 0, 1, 0, 1, 0. So you can do as many elements as you want. This is an infinite stream. So it doesn't matter. So you can keep. Yeah, so this is an infinite stream. Okay, so that's take and drop. So now let's actually look at the function that we wanted to define. What we want to do, we want to define a map function, right? Which maps a given higher order function over the stream.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

So here is the definition of the map function, right? Map is a recursive function that takes a higher order function f and a stream s. And what it's going to do is to map this higher order function on every element of the stream. So this is where we failed earlier. If you remember, we tried to do two strings on this infinite stream of 0s and 1s and we failed. So what is different here? The difference is this thing, right? First, the obvious ones. So this is a stream. So we are going to return a new stream.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

So it's going to be a cons value, right? Where the head element is such that it's the original head. Well, f is applied to it. So f applied to the original head is the new head. And for the tail, we are actually creating a tank, which maps f on the tail of the list. So that's the key bit that makes it work.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

By actually creating this as a tank, right? You are not doing map when you call this function once, right? So when you call this function map, you are only doing f on the head. And all you're doing is you're creating a tank, which when applied when you want to get the tail or something, that is exactly when you apply this rest of the map on the tail of the list.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

And it's a recursive definition, right? So if you wanted, say, for the first 10 elements, you will only do map on those first 10 elements, right? You will only apply this f on those first 10 elements. You won't apply it on the rest of the stream. That's the key bit. So every time you actually do a map, we sort of create this chunk, right? So what's the type of this map? It takes a higher order function that goes from alpha to beta, right? Give me an alpha stream. I return your beta stream.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So here's the thing that we failed earlier, right? So I have a stream of zeros and ones. I am now mapping string of int function. It takes an integer and returns your string over each of these elements in the stream. Of course, the stream is infinite. All you're getting is the infinite stream back. So if you apply this, you get a string stream. Zero ones is an integer stream. Now you get a string stream where we just print the first element.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

We are not printing the rest of the element because that's a function value. You can see that it works by, say, taking 10 elements from zero ones string string. So when you take the first 10 elements, you see what you expect, right? So this is zero one zero one zero one. Each one is a string now. Yeah, OK, so this is how we make it work.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

Do you have any questions so far on this? We look at more ideas in the next step. I'll wait a minute to sort of clear out any questions before we look at more advanced use of streams. Yeah.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

So in the case of repeating streams, why can't we just map one cycle? Good question, right? So you're asking a really good question. So the point is once you construct this value, right? So what you're asking is if you know it is actually a cycle, cyclic list, why don't we just map it with one cycle? Once.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

So the thing that you need to do is you need to you need to identify that there is a cycle. Right. So, of course, this can be done for this can be done for our use cases here. So here we construct actually a cyclic list. You have to use some methods which are sort of more low level. First thing, right?

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

Taking a step back, you have to use some notion of physical equality in order to detect the cycle. Right. So you have to sort of say, use the usual cycle detection algorithm that you have for a link list to detect the cycle. And then you can do this idea. But that will work. But what we are building here is we are building. We are building operators that can operate on real streams. Right.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

Here we are sort of simulating streams with cyclic lists. But think about a file that's socket or something, right? Where packets keep coming in. So there is no data structure there. It's just the it's just like a tab. You cannot walk over the data structure anymore. But these sort of functions will still work. So that's the idea there. Yes, you're right. You can you can use you can you can use your standard ways of doing cycle detection to do one one mapping or cycle.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

I would suggest try it. Right. So can you get the same programming interface with that? Essentially, what you want is you want a map which knows when to stop. See whether you can do it. It's an interesting question. Certainly. Yeah. Any other question.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

OK, so if not, I will continue. What we're doing. OK, so we did this. So the next useful function that we are going to see is filter. So what does filter do? Filter is a function that takes a predicate. OK, that and a stream. And the idea is that this predicate is a function that when applied to an element in the stream, it returns a boolean. Right.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

So what we are going to do is to return a new stream such that every element that satisfies the predicate is removed. OK, so take the stream, take this predicate, apply this on the stream. If there are any element that satisfies the predicate, remove that and return a new stream, which doesn't have any of those elements.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

OK, so that's that's what filter is going to do. So how do we define filter? So it's a recursive function. Filter takes a predicate and a stream. And if the predicate applied on the head is true, then the head value should not be in the resultant stream. Right. So we recursively call filter on the tail of the stream. Right. If the predicate does not hold on the head element, then the head element is going to be present in the resultant stream.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

So we create a cons head of the current stream, right, because that doesn't satisfy the predicate. So that's going to be there. And what about the tail? So in the tail, we should also keep applying the filter. Right. So we create a tank where we filter on the tail of the stream.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

Yes, you can build a folder on the stream as well. But but you have to sort of fold is OK. So just to finish this right, that's all is a filter is. So filter takes alpha to Boolean. Right. That's the predicate. It takes an alpha stream and returns an alpha stream where any element that satisfies this predicate does not is not present in the resultant stream. Sartak has a question which says, is it possible to build a fold on the stream?

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

Yes, you can build a folder of the stream just like you build a map on the stream. You have to be you have to be cognizant of what the return type is. Right. Fold. So think about this question. Right. Is it sensible to ask what is the sum of all elements on an infinite stream? Right. That is sort of asking the same question as can I build a fold?

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

Some of all elements are an infinite stream is not a sensible question. Right. But you can still make it a little bit sensible saying what is the sum of all elements up to some and right first and elements. Can you get me a sum? That's the sort of thing that you can build. You cannot. Asking for the sum of all elements in the infinite stream does not make sense. And similarly fold that you define.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

That you define without a notion of. Yeah, without a notion of when to stop is not sensible. I was seeing its use in filtering. It is like more like.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

OK, so the thing that makes filter work and fold not work right is the return type. So filter returns you a new stream. So I'm always constructing a different stream. Yeah, you cannot. You can do all the things right as long as what you return is a stream. So you shouldn't. If your function depends on producing a single value which is not a stream or a list or something that's not going to work because that would by definition mean that.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

By definition mean that you're producing some value that is the result of observing all the values in the stream filter here is very specific right away is. Asking what about fold for is the predicate through for all the elements in the stream, but the return value is a stream right? That's what makes this work here. So because I'm returning a new stream, I am allowed to stop the execution at some point. But if you say give me a I mean this is the same question is asking filter everything and then give me a list of all elements that is not going to work.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

So a specific type of fold will work right where the result of the fold is going to be a stream. I hope that makes sense. I mean I'm very hand-wavy here, but that's the idea. So you cannot write a function that sort of expects to produce something that is not a stream.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

That won't work or you have to stop somewhere right you either have to say I'm going to take the first 10 elements where the result is not a stream or you produce keep producing infinite data structures right filter and map and so on all produces stream as a result. All of those will work. So if you're folder sort of folds over the thing and produces a stream, then it will certainly work. So here is an example right? Let's say I have

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

This tweet example right you can imagine every tweet is associated with the timestamp and you want to produce a stream. Which will have Each element in the stream is going to count the number of tweets that are produced every second. So of course more than one tweet is going to be

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

Tweeted every second. So what the stream does is it accumulates things right? It still does the accumulation but for a limited period of time it accumulates things for a second. And you accumulate it for a second you produce a new stream. So the result is going to be a stream. It doesn't say I'm going to accumulate it and produce it for the entire. The question doesn't even make sense. What does it mean to say I'm going to produce

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

The frequency of tweets forever. Forever has not yet happened. So anything that returns a stream will work. You can do fold and all your fancy Operations as long as it produces a stream as it sort of give you an intuition. Imagine writing something right here. Which takes this infinite list of numbers or something and then sums up the first sums of every 10 10 numbers.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

It sort of accumulates the 10 numbers gets the sum and then it turns you a new stream which is the sum of all numbers there. That is certainly possible. Try to write the function that would be a good exercise to know what is possible. Okay, really good questions. Any other question. Look at a few more examples and sort of will tell you what about how to program with this. It's a little bit

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

Mind bending right so it's sort of you have to sort of Think about Think about data differently. So we so far we've been thinking about data as a static thing right. That's like there and then functions map over it. Now It's inverted right the functions are there and the data maps or it keeps flowing through it. There are nice examples in the in the sequel. So let me continue.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So here is filter right so filter takes a predicate right and filters out all the elements that satisfy the predicate and returns you a new stream. So here is an example where I take zero once right and I filter all the elements that are Equal to zero. So So what would it what would it produce? What is the result of

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

This function. So I take I take zero on stream I filter out every element that is zero and I take the first 10 elements. What would be the result. Just to make sure we're all following right. Okay, good. Okay, is it five ones are 10 ones. 10 ones right because this is going to produce a stream and then on that stream I'm going to take 10 elements right so 10 ones. So that's the idea. So this produces an infinite stream of ones.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

And on which I'm taking 10 elements. So it's 10 ones. And one thing that I want to sort of say here right. The flexibility of functional programming right so and this is true with Other languages as well, but in OCaml it's sort of nice and easy to write this predicate.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

Right. So we've we've used equality before. So I'm just using equality as a Function here which I'm going to partially apply with zero. So what I get is a predicate right which when applied to zero returns true which applied to any other number it turns false. So this this way of writing suxing code is what I believe that

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

OCaml is useful for which is that it's very close to how you would write a mathematical specification. Right. So this is this is if you understand what is going on here. And this is a very succinct way of writing code and this is not just for being clever right when you want to maintain large software. I tend to write and maintain large OCaml software. The ability to write code that is very short and still makes sense. Right. It's not cryptic. It's not cryptic like see it's not like one of those

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

Mumble jumbles of combining multiple operators where you have to remember the precedence and so on. The rules are very simple. Right. There is no precedence table to remember. There is this idea of function and you are partially applying. That is all that is going on here. And I sort of wanted to point that out. Okay. So

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

another function that will come in handy later is this function called zip. So what is zip going to do. It's going to take two streams S1 and S2. Right. And it's going to combine the stream to create a single stream and the function for combination is f. So f is a function that takes two elements right one from S1 and one from S2 and then it is going to return a result which will be the element that is present in the resultant stream.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So how does it work. So it runs a new stream. So cons f applied to head of S1 and head of S2. Right. That will be the new head. And for the for the tail. It is simply a recursive call on the tail of the stream. Right.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So it takes an alpha stream beta stream. It takes a function that goes from alpha to beta to gamma C and then it gives you a gamma stream. Okay. So that's the zip function. Zip is very powerful. We will come back to zip later. So here is here is a way of combining two streams into a single stream. So I take zero one stream and zero one string stream and return a new stream create a new stream where I just

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

each element in this new stream is a pair of one element from the zero one stream one element from the zero and SDR stream. So if you run it. You get zero zero zero and you get one one two two and so on. I don't know whether I have. And then I can write it here. So you take 10 eight ten elements from the stream. You get zero zero one one two two and so on.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

So it's a it's a nice little function. You'll use this function later. Okay. That's it. Of course you can do zip on a list as well. We haven't seen zip on a list but it's but it's a useful function to have so here is here is here is a use of zip right where I take the zero one stream.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

That's the first one. It is stream with zero one zero one zero one until infinity. Right. And I take the one zero stream. I create the one zero stream by dropping the first element. So I get one zero one zero one zero and so on. I use zip to add the streams together. So each element in the resultant stream will be zero plus one one one plus zero one zero plus one one one plus zero one and so on. So the resultant stream S is a infinite stream of once.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

Okay. So you get an in stream which is an infinite stream of once. You can take ten elements and see that it's an infinite stream of once. Okay. So those are some simple examples. So there are some clever ways of constructing well known well known ideas using streams. In particular there is this idea of SIEU of Eretogonysus which is a neat way to compute frames.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

I don't know whether you've seen this earlier but anyway we'll sort of go through the details. So what you're going to do is to build a stream of prime numbers. Okay. So the way we are going to build it is you start with a stream right that has two three four five and natural numbers of the infinity. And the idea is that at every step the head of the stream is a prime.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

So two is a prime number. Right. So we take two. We take the tail of the stream. So that's three four up to infinity. And what you do is to filter out all the elements that are perfectly divisible divisible by this prime element. So what are the elements that are perfectly divisible by two. All the even numbers are gone. Right. And you'll have a stream which is just the just a stream that starts from three.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

Right. And goes five seven nine and so on up to infinity. And you sort of recursively apply primes on this. Right. So three will be a prime. Right. And you apply the same principle. You sort of go through the rest of the stream the tail of the stream. You remove all the elements that are divisible by three and you get a new stream.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

And in that stream the head is a prime. You keep doing this. So you will neatly produce all of the prime numbers. So that is what I describe here. Right. So if you start from two three four up to infinity. He is a prime number. The head of the stream is a prime number. You create a new stream as prime. Right. Where S prime is just the tail of the stream. Where every element that is divisible by the prime number is removed.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

OK. So here is an example which is exactly what I mentioned earlier. In the first step the prime is two. Right. You start from infinite stream of natural numbers from two. So the prime number is two. The new stream has all the even numbers removed. So you have three five seven nine up to infinity. So you keep applying the same principle again. In the second step the prime is three and you remove every number that is divisible by three. So nine is gone. Right. Fifteen is gone. And so on.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

And you keep doing it. So that's the whole idea. That's the principle of producing primes. So let's build a stream of primes this way. OK. So the first thing we are going to do is so we started with this idea of a stream of prime numbers from two. Right. So we don't we don't have a function for doing that. So we will write a stream that will give us a stream of natural numbers from n.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So we call this function from n. So given a number it just returns you a natural number stream from n. So how is it built. It's a recursive value. Right. A recursive function from n. The first number is n. Right. And the subsequent number is n plus one. Recursively called on from. So first number will be say two.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

And the next number will be three. And you'll keep on doing this. So you will essentially end up having a stream that goes from two to infinity. Right. So here is a way to construct an integer stream that goes from two three four up to infinity. So here is the definition of primes. Right. What did we say. So given the current stream. The head of the stream is a prime number. Right.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

You take the head of the stream. That is a prime number. So what are we going to produce. We are going to produce a stream of prime numbers. Right. So I'm going to produce a stream of prime numbers. So the head is going to be a prime number that I just picked up. What is the tail going to be in the tail. You want to filter out all the elements that are divisible by by this prime number. Right. But also apply the prime number principle on the same stream. Right. So get the tail of the current stream. This stream here.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

Filter out all the numbers that are divisible by this prime. So X mod P equals zero is going to filter out all the numbers that satisfies this predicate. So you filter out all these numbers and then you call primes recursively on it because we want to extract the primes from it. Right. Whenever you call whenever you extract say the prime number the first number will be a prime number. The next number should also be a prime number.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

So we call primes recursively on it. OK. So that is just the so whatever I described here is what I sort of written down here. It's a bit mind-bending because we are trying not a little bit here. Right. So we take primes and because we call it and because the data structures are always a little bit mind-bending.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

So that's the definition of primes. And we know that primes start from two. So we call the for the initial stream. We pass the stream that is generated from two infinite stream of natural numbers that starts at two and that will return you the prime stream. So prime stream is the stream of prime numbers. That's it. So you can take the first hunter prime numbers for example. They get the first hunter prime numbers. Essentially this is this is doing the work on demand. Right. Whenever you ask for 1000 prime it will give you the thousand prime.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

Yeah. So that's that's a nice way to construct prime numbers. Any questions here on any of any of this. Can you try primes from one. One is.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

One will fail right because you'll remove every element that is going to be divisible by one. So this won't ever terminate. You enter into an infinite loop because this filter will fail. It's a good reason one is not a prime number. There is another question I will answer that. So one. So the reason why it fails here is I said from one. But this filter. Right. So any number is perfectly divisible by one. So this filter if you look at the filter definition.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

If the head is predicate is true it recursively calls filter. So we are checking whether the two is this one. It is. So we are going to recursively call filter. Three is this one recursively call filter. It's spinning an infinite loop here. It's a tail recursive call so it doesn't stack overflow. So one is not a prime number. So let me put it back to two.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

This is what. So the other question was what is the at at operator. Yeah I should have I should have sort of explained what it is. Just the helper thing to say this bracket goes all the way to the end. So how why is it useful. Let's say I have. I don't know. X Y Z.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

So if I want to say I want to write this. And then Z applied to say a. It's it's more like a thing for brackets. So instead of writing all the brackets here. Right. But I want to say go evaluate this one first.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

And then apply apply X on the result. Right. I can write it like this and keep it here. X at that Y and Z. It's just a it's not a function. It's it's more of a faster. So that's all. It's sometimes nicer because I can avoid three brackets here. Right. So instead of writing a bracket here I can just say times here.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

It makes sense. Yeah there are a few things like this which I should probably not. I should probably avoid. But anyway so. You don't need you don't need to see it. OK good. So we produced a stream of prime numbers. Let's look at one more example.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So here is a neat way to generate the notchy sequence. So we know what the Fibonacci sequences have been sort of going Fibonacci almost every lecture. But here's a different way to consider Fibonacci. Let's consider Fibonacci sequence. Right. So 1 1 2 3 5 8 13 up to infinity. Let's sort of consider the tail of the Fibonacci sequence. Right. The tail of the Fibonacci sequence is 1 2 3 5 8 13 and so on. So it's 1 2.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

1 2 3 5 8 13 and so on. Let's add the two streams. Let's sum up the two streams. What do you get. So 1 plus 1 is 2 1 plus 2 is 3 2 plus 3 is 5 3 plus 5 is 8 5 plus 8 is 13 and so on. What is the relationship between S3 and S1. S3 is the tail of tail of the original Fibonacci sequence.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

So this is the Fibonacci sequence. Right. And S3 is simply the tail of tail of Fibonacci sequence S1. Right. So the sort of surprising bit is this. Right. So if you if you are able to get S3. It is a tail of tail of Fibonacci sequence and you prepend just this two elements one and one to the front. Right. You get S3 and prepend one one to the front. You get the Fibonacci sequence. Right.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

And this all seems true but very weird. Why would you even work it this way. But this gives you a nice way of constructing Fibonacci sequence. So here is the entire function. So what do we do here. We are going to prepend one and one to the front. Right. So cons one. So I'm defining a Fibonacci sequence. Right. Let's take fibs. I'm defining a Fibonacci sequence where I prepend one and I prepend another one.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

And what did I do here. I took the Fibonacci sequence. I took the tail of the Fibonacci sequence and then I added them together. Right. And the way we add two sequences is zip. Right. So I the rest of the sequence is just going to be take the original Fibonacci sequence here. Take the tail of the Fibonacci sequence and then add them together.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Right. So that is going to give you sort of a recursive definition. Right. That is why looking at it by just reading the code might not make sense. But it's really what is happening is this. Right. We're actually defining this by defining this which is in turn defined by defining this. Yeah. OK. So all we did is we prepended one and one sequence that we are defining. We take that that we take the tail of a sequence and we add them together.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

Right. And when you zip them together what you get is this S3 and that is what we need. So that's the integer stream of Fibonacci sequence to confirm that it works. Right. Here is the first 30 Fibonacci numbers. It takes a while actually. I'll come to that point. So it takes a while. So it produces all the Fibonacci numbers from the first 30 Fibonacci numbers.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

Yeah. It took a while. Right. So you should sort of look at why it takes a while. It takes a while because each time we force the computation. Right. We actually compute the Fibonacci sequence twice. It is not obvious here but every Fibs definition here is a Fibs definition that includes a zip internally. Right.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

It is hard to write down the screen version of it pictorially. But what is happening here is equivalent to this definition that we have of this inefficient way to compute Fibonacci. Right. So every time you increase n the cost of computing the nth Fibonacci number is increasing exponentially. Right. So that's that's what is happening here. And that is why this implementation takes a lot of time. Right.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

And if you ask larger numbers it's just going to crawl to a halt. Yeah. So we will look at how to fix this in the next class and then we'll also look at a few other things which talks about how to make these streams efficient. But that's the observation.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So of course I've showed you like what I would call elegant ways of computing Fibonacci and computing frames. Right. But these are not the most efficient way to write either frames of Fibonacci number. Right. But how can you retain the elegance but still make it efficient is what we are going to see in the next class. I'll stop here. If you have any questions I'll hang around for a minute or two and then we'll disperse.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

This is quite clever. This definition of Fibonacci. I didn't come up with it obviously.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

Okay. So what I would suggest is go through these two examples. Right. Sort of. There are a lot of things that you can express as nice prime numbers. They are not really obvious but these two are sort of prototypical example examples of what you can do with stream programming. Right.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3061.0s_

This is just fun in functional programming. This is not like I wouldn't call this practically minder functional program but these are these sort of give you tell you something about the nature of these problems. Right. So I think these are the is a nice study anyway. Go have a look at Fibonacci sequence and frames today then try to convince yourself that they do work. Anyway. So no questions it seems like. So I will stop here and then we can we can meet tomorrow. We look at how to make these faster. Thank you.

---
