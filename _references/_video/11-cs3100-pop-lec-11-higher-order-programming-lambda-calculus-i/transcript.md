# 11-cs3100-pop-lec-11-higher-order-programming-lambda-calculus-i

**CS3100 POP - Lec 11 - Higher order programming + Lambda Calculus Intro**  
id: `qjcoi2V1UgI`  
duration: 3079s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so you should see the recording right now. So we are continuing from where we left off in the last class, right? So we are looking at higher order functions and we looked at a few examples of higher order functions over lists such as map and reverse map.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

So when we talk about higher order functions, we always end up with this one true higher order functions as you mentioned in the last class, right? And that function is a fold function. And the sort of analogy if you want to compare to imperative programming is fold is a function that is very similar to an iterator where you can do arbitrary iterative knows how to traverse a particular data structure, right? And then you can do arbitrary things using the iterator and fold sort of nicely wraps

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

the notion of traversal in the function. And it's actually very generic in the sense that if I gave you a fold function or any particular data structure, be it the tree or a list or say some D plus tree or so on, you can implement every other function which operates over the tree just using fold, right? So that's we will see some of that in this lecture.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

So essentially fold is a function for combining elements from a data structure, right? And it's very powerful. Just as I mentioned, you can experiment, you can express a lot of things with this. And hence it is a it happens to be very generic and at least I found it initially difficult to understand like what is going on here. So what I'll try to do is to first provide the intuition for what the full function is.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

And it is generic, but we will sort of look at a specific function and then we will sort of draw the common properties of the function into this generic function. OK, so without further ado, so here is a function that I can ask you to write. And at this point, you might even write. So here is a function that simply computes the sum of elements in the list. And we want the function to be tail recursive.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So what we ended up doing is we have an accumulator that carries the value. And then we have a list. So if the list given list is empty, then you just return the accumulator. If the list is not empty, then what you do is you add the head element to the accumulator and recursively call the function on the tail of the list with the new accumulator. So this is what you would write. And we know the initial value of the accumulator.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

We are doing summation. So the initial value should be. So it's the initial value should be zero. And OK, so if I run this, so I get this function which goes from integer list to integer. And if I run it on a list which has one, two, three, four, five, I should get 15. So this should be not surprising. So so let's try to break it down. Right. So at this point, you can actually write this function.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

You you you know enough camera to be able to write this. But let's sort of look at what's going on in this function. Right. The first thing that's going on here is there is this notion of walking over a list right from the head element all the way to the tail. And the way we walk over the list is through this recursive call where we match pattern match on the shape of the list. Right. We know that this is a list of nodes, this stuff elements where we have a null and the cons.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

So we split it apart at every position and then we simply recurse through to iterate over the shape of the list. So you can imagine. So another analogy would be. So there is only one. There are two ways to walk a list. Right. So you can either walk it from left to right or right to left. And for trees, you can do in order, preorder, postorder. Right. Or the words and so on. So that is what I mean by traversal over the shape of the list. Right.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

There is also this accumulator that keeps track of the current sum so far in this function. There is this plus function. Right. This plus function that we apply to each element and the accumulator as we traverse the list. OK. And the last thing we have is the initial value of the accumulator. So we have sort of four broad concepts here. Right. So there are, of course, other things. But I'm sort of picking out things that I want to get the point across.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So one thing we can do is we can actually write the same function using list.foldLeft. So foldLeft is a function that traverses the list from left to right and does something on it. Right. And in particular, what it does is let's look at the type of this function. Right. The type of this function is it takes a higher order argument. Right.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

That takes two arguments. You can just read it as takes two arguments A and B, alpha and beta, and then it returns an alpha. So what is this argument? So the first argument is analogous to the function that we apply in the previous example. Right. This plus function that we are applying to every element and the accumulator is precisely this function. Right. Which is applied to the accumulator whose type is alpha here. Right.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

And every element in the list, which is beta here and this function is supposed to return the accumulator type, the new accumulator. Right. So it takes the current value of the accumulator, the current element in the list on which this particular function is being applied. And it is expected to return the same value, same type as the accumulator type so that this becomes the new accumulator and you can keep going on. OK. So that's the first argument. That's the higher order function that captures what you are doing on each element of the list. And the second value is the initial value of the accumulator.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So this is the same as zero that we give here. Right. And that is being captured in the second value of the accumulator, the initial value of the accumulator. And the third argument is the actual list that you are traversing over. So the list is a list of betas. Right. So observe that in the previous example, we used the integer for the accumulator and we were operating over integer list.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

It's sort of generalizing this idea a little bit. Right. So it's saying the accumulator is some type alpha and the list is of some type beta. And the way we connect this alpha and beta is we have this function which goes, which takes alpha and beta and returns an alpha. Right. It takes the accumulator, the list element and then gives you a new accumulator. Right. This is a little bit more generic than what we had seen in the specific instance. And what does this function actually return? It returns a new accumulator. Right.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

So it just returns the accumulator and we are we are done. So, OK. Here is the same function again. Here is the instrumentation of the same function, the sum of elements using fold left. Right. So if I run this, I get the same result, but you can sort of see what is going on. Right. The concepts that I said fold left internally sort of encodes the idea of traversing over the shape of the list. The only thing that it knows about the list is that it has a particular shape and it has a particular type. Right.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

And fold left encodes how to traverse over the shape of the list and apply this given function. Right. Which takes an accumulator, the current element and then forms the new accumulator. You can sort of see it's isomorphic to what we are doing here. Right. We are doing X plus accumulator here. I'm doing accumulator plus X, but it could have been X plus accumulator as well. And this is the initial value. The second argument is the initial value zero. And that's the initial value here.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

And the last argument is the list that I'm applying this over. OK, so what this dot fold left allows you to do is sort of encode these functions that you might write yourself. Using this idea where we split it into, oh, you want to traverse the list from left to right and what to do at each position, which is this function.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

What is the initial value of the accumulator and the list? And in fact, the implementation of fold left is very simple. Right. So so here is the implementation. Again, we can sort of compare this to the implementation of some of elements. It looks again isomorphic. So for left takes the higher order function, the accumulator and the list. If the list is empty, then return the accumulator. If the list is non empty. Right. First, use the function that you've been supplied the Zeph function to combine the accumulator and X to get the new value of the accumulator.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Right. And recursively call the same folder function on the tail of the list. So the same function. Right. New accumulator and the tail of the list. You can sort of see this is isomorphic to this one. Right. So here we've we know what function we are going to apply, which is the plus function in folder fold left. We don't know which function. So we are taking this extra argument. Otherwise, it is exactly the same. Right.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

And yeah, so that's that gives you the desired type. So one way to imagine what happens with the fold left is that you can sort of imagine that to be a natural transformation of the shape of the data structure. Right. So here is one way to write the shape of a list. Right. So you have an empty list that's a list value. Right.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And the list with one, two, three, four, five first contains a singleton list with five. Right. And how do you construct that singleton list? It is the value of five cons to it. An empty list. So that gives you the singleton list five. And the next thing you do is take four and cons it to that singleton list five. Right. That gives you another list and you can keep doing that. Right. So you add a three to the front and to this list and eventually you go back to one and one and all you have is this list with one, two, three, four, five.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

So this is just an illustration of how the shape of yours and four left. You can sort of understand for left as first reversing the list. Right. So we are going to first reverse the list. So one, two, three, four, five becomes five, four, three, two, one. You replace the unit element. Right. So if you've done sort of discrete mathematics, you have this idea of unit elements in groups. Right.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

And the unit element in a list data structure is the nil element. Right. So that's sort of the unit element. You replace the unit element with the initial value of the accumulator. Right. You replace the cons operator which constructs data. Right. So cons takes a value and a list and then constructs a new list.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

You replace that with the function that is used to compose the accumulator and the value in that list. Right. So essentially what I'm trying to show here is that you can sort of view computations and the data constructors as two sides of the same coin.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

Right. So data constructors sort of construct the data, but they're sort of they look very similar to what we do when we do computations. Right. And all fold left is doing is going ahead and replacing cons with plus and then replacing the unit element with zero. And of course, it's doing the list reversing. But you can sort of see that this shed some light into the shape of what fold up to swing. So for left traverses from left to right. Right.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

And what about right to left? So there is a function called fold right. Which traverses from right to left and it's actually much more pleasing than fold left. In particular, if you can consider this to be the shape of the list. Right. Fold right. All it does is take a function f. Take the initial value of the accumulator zero and all it's doing is replacing wherever you see cons.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

You're replacing that with an f and wherever you see empty list, it's replacing that with zero. Right. And in our case, in the sum of all elements, z happens to be zero and f happens to be plus. Right. And that's the whole idea. Right. So you take a shape and you replace the building blocks of the shape with functions and values.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

And that is computation. Right. So I think this is like one of the nicer ideas that you will find in this in functional programming. Essentially, computation is nothing special. Right. It's also one way of constructing some shape. Right. And so happens that you can actually compute the result. But that's the point. Right.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

So why am I mentioning this? So one thing that we will do when we study Lambda calculus in the upcoming lectures is that Lambda calculus is a very poor language. It has just functions all the way through. And in fact, you can use this isomorphism. The fact that you can encode these sort of shapes with functions to actually construct data types like lists and trees and other things.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

Of course, this is Lambda calculus is more of a theoretical exercise, but it underpins all of the things that we are doing with functional programming. And. And. The slide is sort of there to show you that we can approach the isomorphism from OCaml and to its core concept. But we will also approach it from the other side where we will start with Lambda calculus, which is functions and we will build things like lists and trees and so on.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So you can sort of see that these two things are in fact isomorphic. OK. That is it. Right. That's that sort of the philosophy behind Ford and so on. So I keep I keep talking so much about the beauty of Ford and philosophy and so on. But. Is it useful? Right. That's the question that you need to ask at the end of the day. You just want to program. Right. I want to, as I mentioned in the first classes.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

Of course, programming languages are elegant and precise and beautiful and so on. But at the end of the day, they're just tools. Right. You just want to solve some problem and it's like a hammer or a screwdriver. So let's see what it can do. Right. It's first understand fold, right. So. Fold right is. Similar to fold left. The only difference is that the types look odd, but the concept is the same.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

So this is the higher order function. Right. And the accumulator type here is beta. This just happens to be a quirk of who came as type inference. Right. So. Just remember that the list element type is alpha here. The accumulator type is beta and the side order function is supposed to return the new accumulator whose type is beta.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

You take a list which is a alpha list and then you take the initial value, which is the beta and you find when you run fold right, you end up with the final value of the accumulator that sort of captures the notion of doing computation. Right. So fold right is again not special. You can just write it. If you start at the type, there is only one sort of function you can actually write that satisfies this type.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

Yeah. So so here is that function. Right. So it takes a F and an L and an accumulator. So if L is empty, you return the accumulator. Otherwise you fold right on the tail of the list with the accumulator. Right. And then with that result, you call FFX on it. So the the reason for doing this is because fold right applies from right to left. Right. So you want to apply the function. This F

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

for the first element as the last thing that you do. So what do I mean by that? This looks weird, right? It's not tail recursive. So that's the first thing that you should observe. And why are we doing this function application last because fold right is supposed to look like this, right? For the first element, which is one, F is applied last to one. And after all of the computation is done. Right.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

So you finished everything here. And then the last thing you do is to actually apply F1 one and the resultant accumulator. So this is why the function application looks like this. So complete fold right execution for the tail of the list, you will get a new accumulator value. And the last thing that you do is to combine that accumulator with the element, the first element, right? Using F and you return it.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

So the thing that you can see is this is not tail recursive. Right. So whole left was tail recursive, fold right is in tail recursive. And fold is, as I mentioned, very powerful. Right. So you can implement all the useful functions just with the fold. In particular, here is a reverse. Right. And what does reverse do? Reverse takes a list and reverses the elements. And what are we going to do? So think about this. Right. So reverse takes a list and returns

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

a list. So and fold left is going to return an accumulator. So in order for the types to match, the accumulator also has to be a list. Right. Because it's going to return a list. And the initial value of the accumulator is empty. And the reason is that if the list is empty, then you just return empty. Right. So that's the reason why this is empty. And what happens in the actual function? You get this accumulator, which is the list so far. Right. And you get this current element.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

And you just append x2 the front of the accumulator. Because fold left is going from left to right. Let's take a list which is 12345. So initially the accumulator is an empty list. So you will pick one and you will say, oh, create a singleton list with one and that becomes the new accumulator. And the rest of the list is 2345. Right. And the next thing you will do is Yeah, I'm doing that. Right. So, so,

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

so, okay, so we can try to write it down. So what will happen? Right. So initially, accumulator will be empty. Right. And the list will be 12345. Okay.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

In the first step, we will traverse the list from left to right. Right. So we will pick the first element. Right. And, and the current accumulator. And we are going to apply this function, which is accumulator is empty list. And the first element is one. So the new accumulator is one appended to empty list, which is a singleton list with one. So the accumulator is one. And internally, what fold left is going to do is to call the same function on the tail of the list. Right. So the tail becomes 2345.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

Right. You do the same thing again. So consider this to be the accumulator, take the front first element of the list. Right. Sorry, first element of the list and append the first element to the accumulator. So the first element here is two. And the accumulator is the singleton list one. So when you append two to the front of a singleton list, which is one, you get to one. Right. And you get l equals 345.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

Because recall that fold left simply keeps simply keeps applying this on the tail of the list. Right. So you keep doing that. And yes, you can see. To keep doing this, right, what will happen next step will be three to one.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

And yeah, finally, it will be 54321. Right. And then the list will be empty. And at that point, what is fold f2. If the list argument is empty, just returns the accumulator. Right. And what is the accumulator currently?

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

The accumulator is 54321. So that's the reverse of the list. And that's what you get. That's that makes sense. Okay. So if you want to know what's happening, you just take these functions and work through the small definition. Right. And write down the values of accumulator and the list values in each step and then iterate through. That is precisely what I'm doing. And that's how we develop the programs as well. Right. So you sort of see what you want for the base case.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

So if it's an empty list, you want an empty list as an output. And what has to happen for the recursive step. So if you have a if you have a non-empty list, what has to happen? Right. So you have to take the first element, put it in the accumulator and you keep doing this again and again from left to right. Things will become reverse. Okay. So. Yeah. So you can you can work it through. But this is precisely what happens.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

You can compute the length of the list. Right. So because what are you doing in a length? Right. You are iterating over the shape of the list. And for every step you're adding one. So if the list is empty, the result should be zero. So the initial value of the accumulator is zero. And at every step, right, I don't care about what the value of the element is because you don't care. Right. For computing the length. And at each step you just say accumulator is accumulator plus one. Right. And that gives you the length of the list.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

So observe that I have not done anything interesting, but I sort of just wrote on the program and I get the most useful type. Right. This length function can be applied on any list. Right. And I don't have to specify anything special to get the generic length function. It just falls out naturally. And the result is an integer.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

You can in fact implement map. Just using fold and in particular, we are going to use fold right. And the reason is that. So when you. You want to take the so just like what happened with reverse right reverse to the leftmost element and kept pushing it into the accumulator. And what you ended up is the reverse of list.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

But if you start from the right and you kept doing it, you'll get the same list. Right. So if you start from the left and keep pushing an element into the accumulator, you get the reverse of the list. But you start from the right. You kept pushing into the accumulator. You'll get the same list. Right. So we want the order of the elements to be preserved. But what map does is that every step. Right. It maps this function as this higher order function F on each of the element. Right. So you apply F1 each element X.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

Right. So recall that in the last lecture, all it does is if the list contains a one to a n and map function says the higher order function is F and the result is just going to be F applied to a one semicolon F applied to a two semicolon F applied to a three all the way to F applied to a n.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

And this is precisely what is happening here. Right. So I am at each step. All I'm doing is applying F2 X and then appending it to the accumulator to create this new list. And that I'm doing it from right so that the order of the elements in the original list and the resultant list is preserved. OK. So. Yeah, I haven't written. So this is full. Right. So.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So, yeah. So you get the right type for map. So it takes a function that maps from alpha to beta. You give it an alpha list. It does a beta list. I want you to go through these and convince yourself that this works. Right. Work it out for each step. The observation is that map function is not tail recursive because fold is not tail recursive. We saw this earlier. Right. So when I introduced map function, I mentioned that map is not tail recursive.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

It sort of follows from the fact that fold right is not also not also tail recursive. Yeah. OK. So what is it? The observation is that any function. So any function that you want to write on a list can always be written with the fold. Right. So you never have to write any other function for traversing or the list except a fold.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

But sometimes we for convenience we just pattern match and write our own functions by hand because it is readable. But in fact you can write you can write any function using fold. Right. So here is an exercise for you. So instrument a function exists. Right. That takes a predicate. Right. So it applies to it's a function B.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

Which when applied on an element returns true or false. Right. You take a list as an input and the function should return true if an element e exists in L such that P of e is true. So when you apply P to that element should be true. So here is an example. Right. So what I expect is I'm using exists to search for an element. Search.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

I'm using exists to check whether the list has an element zero. Right. So the predicate is E zero. So it's the element zero. And if I apply it to one three zero it should return true. Right. And you can what I want you to do is to implement this with the fold. And Yeah. So this is another exercise for you just to get more practice implement append function which takes two lists. Right.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

And the result is going to be the concatenation of L1 and L2. And here is an example. You can also implement it using fold. Use fold right to implement this. And the reason is that we want to preserve the order of the elements. Right. So The intuition is the same as what we had done for math. Okay. And that completes the higher order functions.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

Lecture. You have any questions. I'll just stop for a minute. And you can ask me any questions. Again fold is sort of full takes a while to get your head around. It might click for a few of you but it didn't click for me. But once you sort of see that everything is a fold you can sort of see fold everywhere.  Yeah. The instrumentation itself is not complicated but it's the

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

Often you have a very powerful abstraction. It is knowing when to use that abstraction. Right. So that's that's really going to be a question and comes with practice. So we'll we'll do a few We'll do a few assignments which sort of gives you this idea. Yeah. So it does have or and and

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

So the question is does OCaml have or and and yes it does. So True and false. Right. And then Okay. Any other question. So if you want to do something more difficult like a minus

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

Good question. So So So you can you can encode this fact in the You can encode this fact in the accumulator right. So So you keep replacing the function. You keep Changing

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

abstractly it's flipping right. So at every step. Initially it is negative then positive negative positive negative so on. So the idea is that this accumulator should sort of Take this idea of Initially there is going to be one function and then it can be. Yeah. So you just Yeah. That's what you do. Right. So I would just

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

Yeah true or false or something. There are multiple ways to do it but that's that's really what you do. So every time you recursively call you just flip it right and flip the sign and keep doing You can you can do So Just teasing with terms but actually terms don't mean anything. Right. So this In programming language theory fold function is known as

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

A catamorphism. So the idea is that it tells you how to traverse a particular Structure. Right. The structure can be any data structure. It just tells you how to traverse that structure. And it is a known result that If you have Catamorphism then any sort of computation can be encoded with that kind of So And the practitioner

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

Translation of the definition is you have a fold you can implement anything. Right. So there is no function that you cannot include Okay, so You can also ask questions on slack. I will try to answer questions there. So what I will do now. So What we see so far seen is We sort of dived into OCaml. Right. And we've been I've been teaching you some concepts as we went along.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

While also introducing the language. Right. So For a change what we will do in the next few lectures is actually with the accumulated knowledge that you have. We will study The Earliest and The simplest programming language it happens to be a functional programming language will just study The simplest functional programming language, which is lambda calculus and we'll sort of tie

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

Lot of the concepts that we've studied here back to what lambda calculus will do. Right. So You just pattern match on it. So Raghu has a question. So is there a way to access the nth element in a tubal You will have to pattern match. Right. So if you know that there are seven elements, then you need to have a pattern which is Seven tuples include seven elements and then you just extract the seventh one

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

You cannot So what Raghu is asking is a very interesting question, right so And you have a End of a table and this is I'm not going to give you an answer, but I'm just going to ask you a question. Right. So can you have right Does there

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

Does there exist a function where you can sort of say Right and Actually, I can't even write the type of this function, right so If you want to extract the end element of a tuple and we know that the tuple can have different type elements, right. So if I want to extract the first element from this

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

And I'm taking an arbitrary index here. The return value is in fact dependent on The type of the return value is dependent on the index Right. So if the index is zero, then the return value is code a if the index is one there in the return value is code B You cannot write this function In OCaml as it is actually we will see in later lectures. We will sort of see how to encode

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

Something similar Using Using A higher level higher level feature of OCaml But just to piece you with an idea, right? So the problem here is the type of this function Right is dependent on the value And Programming languages have this concept of value dependent types So the type of this function is dependent on the value because if the

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

If this is zero, then you get an quote a and if this is a one you get a code B. Right. This concept is known as dependent types. Right. And there are research languages that have dependent types in them. We will study a very rudimentary support for dependent types in OCaml and we study GADTs in later lectures, but You cannot write this type in plain OCaml. Right. Okay.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So anyway, so enough of digressions. I want to move on to Lambda calculus. Right. So we'll sort of see why Lambda calculus today and we might We might then come back to the actual Mechanics in the next class. Okay.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

So Okay, Lambda calculus. So we are going to will study a few lectures on Lambda calculus. I think It's quite interesting in its own field of study, right? Just studying Lambda calculus is interesting. But we'll sort of type back to practical functional programming. Right. So that you can use these concepts. Elsewhere as well.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So, okay. This is all So, okay. So back in the 1930s, right. So really There is this big question about What is computability and I am not going to delve deep into the question, but informally what it meant is what does it mean for a function right that goes from natural numbers to natural numbers to be computable. Right.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

There were In the 1930s was a brilliant period where several brilliant scientists were mathematicians essentially were working on the same problem and making independent progress. Right. And they sort of made revolutionary progress with sort of underlies much of the computing that we do play and informally, the question of what it means to be computable is like

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

If I gave you a pen and a paper. You should be able to Tell me what is the result of f applied to n for any n. Right. That's really What you mean by computable actually the difficult bit here is to define formally what a computable function is. Right. And three different researchers attempted to formalize computability. Actually, once you can frame the definition formally

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

The rest of the things will fall out naturally. Right. And the problem here is just framing the definition So the first of those mathematicians scientists is Alan Turing. Right. So he defined the idealized computer called the Turing machine and What Alan Turing said was if a function is computable a function is computable if and only if it could be computed by a Turing machine. Right. So this is his definition. So what he did was he described what constitutes a Turing machine and he said

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

For a function to be computable It must be the case that it can be computed by a Turing machine and lot of the current programming language technology was to Alan Turing and we have this concept of Turing completeness in programming languages. Right. And

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

We say that the programming language is Turing complete if it can map every Turing machine to a program or you can try it. A program that simulates a universal Turing machine. In the programming language or it is a superset of a known Turing of the language and typically the way we show that programming language is Turing complete is the second one. Right. We just write Interpreter for We just implement a universal Turing machine in the programming language and most of the languages that we use in practice today. Right. Most of the programming languages that we use are Turing complete

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

There are several if you read the Wikipedia page of Turing completeness you'll see a lot of hilarious instances as well. There have been instances where Systems right not even programming languages just systems some constructions right artificial constructions have ended up being Turing complete by completely by accident. Right.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

And a famous example is Yeah, PowerPoint is Turing complete. Yeah, that's right. And C++ templates are Turing complete. You can write entire programs. Right. You can write every program Justin C++ templates. What does this mean? I mean the template compilation right what the C++ compiler does in order to compile a program that has a template use to produce a binary. The compilation itself is Turing complete.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Yeah, so There have been a lot of Games which are Turing complete. You can have a look. It's quite hilarious. While Turing was Making revolutionary progress late along the church was also working on a similar question. So church developed this idea of lambda calculus a formal system for mathematical logic. Right. And he's postulated that

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

Function is computable if and only it can be written as a lambda term. Right. And church was during speech to address it. Right. And Turing later showed that Church's definition of lambda calculus and his Turing machines were in fact equivalent. So this came to be known as church tutoring thesis. And

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

The third person is Kurt. Right. So girl was working on the same definition and he defined this nice framework where he said Without going into details. It contains a class of general recursive functions and he postulated that the function is computable if and only if it is General recursive and it is now known that all three definitions are equivalent. Right. So And

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So church shooting thesis is in fact one of the most important ideas in computer science. Right. So sort of revolutionized The very idea of computing. Right. And And the and the idea goes far beyond just the thesis. But if you sort of look at Even though we've known for a while that these two ideas in particular this lambda calculus and this Turing machines are equivalent.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

In contemporary computer science research. Right. Computer science as an area. These two happen to be concentrated by two different Specializations. In particular, Turing machines are used a lot by folks who work on algorithms and complexity. But lambda calculus is the go to tool for programming languages, people like me. Right.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

And this particular dichotomy is not accidental. So Turing machines are quite low level. Right. So they are They involve a tape and a pointer and what happens at each step and so on. So they are well suited for measuring efficiency. Right.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

And so they are used to And so they are used to        In fact, lambda calculus gives you enough features that all that we are doing in OCaml and so on. It's just you can sort of think about them as just making lambda calculus practical. Right. So

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

And Yeah, so So in fact, lambda calculus is as powerful as any programming language. Right. So It is in fact so small, it is the smallest during complete programming language. Right. So it only considers three instructions. Right. There are only three forms production forms in lambda calculus and it can express

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

All the features that you can find in modern programming languages and what we will try to do in the next series of lectures is to show how you can sort of encode these Wide variety of features, right multi argument functions for loops while loops heaps and so on just using lambda calculus and At its core all lambda calculus does is functions. Right. And all you need is just functions.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

And it doesn't have anything else actually doesn't have a notion of branches. It doesn't have like values and it has values. The only values of function. And the only thing that you can do the function is applied. Right. So it's quite surprising how you can encode all of what we do in modern programming languages using lambda calculus. Right. So, of course, we don't write programs in lambda calculus today and execute them because that would be inefficient, but

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

The point of studying lambda calculus is to get to the essence of what programming is and where these features are, why these features come from, what is primitive and so on. And in fact, The The under calculus is precisely defined here. This is entire lambda calculus. Right. And

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

I don't know why all of this is a little bit off. So I'm describing a grammar here. Right. And I believe that you are studying compilers as well and you might have come across abstract syntax tree. Right. So this is sort of describing How to construct terms in the lambda calculus. Right. And there are only three Ways you can construct expressions in lambda calculus. So the expression could be a variable. Right. The expression could be an abstraction.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

We call it abstraction, but you can sort of imagine an abstraction when you have lambda x dot e you can read it as OCaml for fun x arrow. Right. Here is a way of defining anonymous functions. Right. And this is precisely defining that anonymous function where it takes a single argument x and the body is e and the last thing you have is application. Right. You can you can take a function. You can apply to a value.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

And these two are a bit so this could be more complicated. Right. So it need not be just lambda here. It could be itself an application, for example. And this is all of lambda calculus syntax. Right. And Yeah, so there is nothing but higher order functions here. So

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

So we have functions we can pass around functions. We don't even have zeros and ones. We don't have proven false. We just have the syntax. Right. And I'm going to try to convince you in the next two or three lectures that You can in fact encode lot of the things that we studied so far. Right. You don't study a lot in OCaml, but you study the substantial bit of OCaml. And I'm going to tell you that you can Express all of that using just these three Productions and we'll see how that

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

How we can do that in the next couple of lectures and I think I'll stop here. So any questions so far We've sort of looked at the motivation and in the In the coming classes, you will actually play around with lambda calculus. Right. So So this This Jupyter notebook includes a lambda calculus interpreter. So you can actually think about these as building blocks. Right. So you have Lego, right.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

It has different colors, but if you sort of stare at it, it has a single template and you can construct arbitrary shapes using a Lego. And I hope to provide you the same experience with this. Right. These are like building blocks and using these building blocks, you can manipulate them In the interpreter, you can actually write lambda terms and see them evaluated so that you'll sort of appreciate why lambda calculus and what it has

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3072.5s_

So no questions, I'm just starting at questions on the side. So I'll stop here. I think I'll let you go. And then we can meet next week. Thanks, everyone.

---
