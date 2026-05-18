# 20-cs3100-pop-lec-20-side-effects

**CS3100 POP - Lec 20 - Side Effects**  
id: `YFQ1oGxrWQA`  
duration: 3301s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so I think you should start seeing my presentation. Okay, good. So in the last few lectures, right in the last eight lectures, you've seen lambda calculus, you sort of, you can keep digging into lambda calculus further, but I think you've covered enough of lambda calculus to appreciate what is going on in the functional programming

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

language, but also other languages, right? So let's not just say functional programming languages. So now what we're going to do is, this is sort of the third part of the course. So we started with the initial part of OCaml, then we switched to lambda calculus. We saw a lot of lambda calculus, we sort of looked at principles of what underlays programming, and we will switch back to pragmatic concerns. So we will switch back to OCaml.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

The next few lectures will be on OCaml, right? So this is, all of this is going to be like a bit specific to OCaml, but you can also sort of think of them as ideas that you can transplant to other languages as well, but not particularly to say C or C++. These are like advanced ideas that will open up the way you think about programming, right? So that's the hope with the rest of the lectures.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

But in this lecture, we're going to start small, right? So we are going to look at side effects. And so far, we've only used purely functional features of OCaml, right? And our study of lambda calculus also used just purely functional features. So we had the lambdas and we had applications, we extended them with pair and match cases and so on, but everything is purely functional. Of course, the above statements are sort of nice, right? So we have used the IO.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

In particular, we use print and line to print out the output to screen and print this and other ways to display results. These are all side effects, right? These are features that are not captured in the type. The type doesn't tell you a function is going to print, for example. These are side effects, right? These are known as side effects. There are many, many side effects, but these are, IO is one kind of a side effect that we've already seen.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

We've not sort of looked at them in detail what their underlying principles are. But anyway, we've sort of used them for practical purposes, right? And of course, it is sometimes useful to write programs that have side effects. It's not always great to say, OK, I have this beautiful language which can describe so many things beautifully, but I can't do anything that interacts with the real world, right? In reality, you're writing programs because you want to do something in the real world,

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

right? You write a program because of its effect that it will have on the real world. So we call these side effects in the language. I sort of don't like the term side. I would just call them as effects, but side effects is what people tend to use for all of these features in a functional programming language, right? So that's that.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And what are the side effects that we have in the language? In OCaml, we have ways to mutate values on the program heap, right? So, so far, everything that we've seen is purely functional. We can define a variable. If you use the same name, you're defining a new variable that sort of shadows the previous definition, right? We did not have any features where you change the value of a variable so far. This is not what we've done.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

So this is known as mutations in functional programming, right? So mutation is you can sort of think about them as destructively updating the value of a program state, right? So the program state changes value by destructive update. We've also seen writing to screen. So you can also think about reading from screen. So reading and writing from standard input and standard output. You can write to the network, pipe sockets, all of these things, right?

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

OCaml allows you to do all the things that you can do on a modern operating system. So all of these are side effects. We also want to do higher level things, right? These are low level things. We also want to compose emails, send and receive them, write documents, edit slides, and so on. So I would say side effects is this broad class of things that you want to do, which involve some operation that sort of goes outside of the scope of the program. So that is one and destructively mutating state.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

That is the other one. So in broad classes, so there are two sort of side effects. One is mutations, right? Changing the program state destructively. So OCaml has a bunch of features for this. We have what are known as reference cells, arrays, and mutable record fields, right? So that is one. The other box is IO, right? Input, output of all sorts. And in this lecture, we are going to focus on just the mutations.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

We won't see IO in much detail. You'll read a lot about IO and how it is implemented, hopefully in the operating systems lecture. And all of those ideas directly apply here. So nothing interesting is going on there. Of course, IO in itself is quite interesting from a programming language point of view. We are not going to look at that in this course, right? So in this lecture, we are going to focus just on the mutations.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

Okay, so the basic way of creating mutations in OCaml is the concept of mutable reference cells. So what is the idea here? A reference cell is a pointer to a typed location memory, right? It has a type. It is a pointer to that location, right? And you can refer to this location. And this reference itself is immutable, but you can change the contents of the cell.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So this is a lot of words, but if you sort of think about C, right? In C, when you create, when you do say malloc, you get a location, right? And you can change the contents of this location. This is precisely what we encode in a type safe manner in OCaml, and we call it references. So what is the idea here? The idea is that you have a variable that refers to the reference cell. The variable itself is R. It refers to the cell.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

This binding to this variable to the cell is immutable, just like the variables that we had seen in OCaml so far, right? When I write x equals 5, x is referring to 5. You cannot change the value of x. You can define a new definition of x which says x equals 6, which shadows the previous definition, right? Just like that, this binding is immutable, but you can change the contents of what the cell points to. So it happens to point to this object O and, right?

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

When I say object, I'm not talking about object oriented programming. I'm just talking about some entity that is on the heap, right? So it points to O1, right? And you can change this to O2. Okay, so you can change this to O2, you can change it back to O1, or you can change it to something else as well. So the mutation is in the reference cell. So you can, a reference cell allows you to change the contents of the cell. The content happens to be a pointer to a different object here. That is all there is.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Okay, any questions? Quickly. Okay, I think we should start seeing more examples to generate more questions. Okay, let's see more examples. So here is how you create a new cell. Okay, so the key word that you use is ref, right? So this statement, what it does is it creates a new reference cell whose content is zero, right?

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

And we use the variable R to reference refer to the cell. So there is what it says, R is a int ref. In OCaml, you always have to read the types from right to left. So R is a reference cell whose content is integer, right? And its content is zero now. So it just says its content is zero now.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

Because we started with zero, right? And the thing is, because R is a reference cell, you can change the contents, right? And there are two things you want to do on any variable, right? So you want to sort of read the value and you also want to update the value. We use two functions to do this, right? So we use colon equals for update. The syntax is a bit weird, but let's not worry about the syntax.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

We use colon equals to perform the update because we are using equality for just building up the expressions, right? So we have to use a different expression. So we use colon equals. And we use exclamation mark for reading the values from a reference. Okay, so here we started with the reference cell which has initially zero. So this statement, right, this is now a statement. It is reading the value of R at this time, right?

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

And we know that R is an intref, so the value that will be read is an integer. We add one to it, right? We add one to it here and we store the result in R again, right? And we read the value again just to see what it is. What will be the result here? So initially it is zero and I'm just doing plus one here. So what will be the result of reading R here?

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

Yeah, so one, right? So, okay, good. So it's one because initially zero, so we added one. All we've done is we've done x equals x plus one, right? But there is additional syntax here. The whole thing is none of this is syntax, right? All of these are just functions. Okay, Shreesha has a nice question. From a programmer's perspective, why is immutability important?

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

For all of our purposes, shadowing would be equivalent to changing the content itself, right? As we haven't had the idea of addresses or where the content of values are. We don't, but immutability is important because, because if you consider the good question, right? So for programmability, it is important, right? Oops, so let me go back here. I want to type something here.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

Okay, so let me do x equals one in, right? Some function here, okay? Where the internally I'm, let me do x equals two, right? So I'm going to do something where I do x equals two, right? In, so this function returns something, right?

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

And then I say in two of plus x. Immutability is important here because I can reason about this function, which also happens to use x, right? If you sort of imagine this to be a destructive update of x, the meaning of this whole function will change, right? So this function defines an x which shadows the previous definition.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

So let me finish this answer. I'll sort of look at the question and continue. So the idea here is this x equals two is shadowing, right? It redefines x, but the original x is still there. So if you imagine this to be updating, you cannot reason about

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

this function as a purely functional thing anymore, right? The meaning of this x will change because x will be two. So that is why we are. So the example here is you can sort of imagine this to be equivalent to having a global variable, right? Imagine if you have C and you just had global variables. You don't have local variables at all, right? And in that case, what will happen? So if you use the same variable name elsewhere, you're going to, the meaning is going to change, right?

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

I'm just calling foo here, so I don't expect this value to change. And immutability is really useful for the program reasoning, right? So you can sort of look at a function, you can look at a type and just not worry about the internals of the function definition, right? So it becomes much easier. Of course, the compiler can implement it in other ways, right? If it can know that you do x equals one,

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

then do say let x equals three here. This is completely shadowed, right? This x is not going to be used. The compiler will throw you a warning here saying this x is not used. Of course, the compiler will optimize it, but immutability is good for reasoning, right? So actually, I have some notes, I have some content in this lecture which will cover some of that.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

That will better answer your question. So here is a preview answer, but I'll give you a better answer as we go through the lecture. So Ravi has a question. Won't we have to recreate big data structures if we don't have, I don't know what that means Ravi. So what does it mean to say what we have to recreate big data structures? Maybe we can take it offline, right?

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

So let's just take it offline. Okay, so we won't be able to make small changes. I think it is, if everything were mutable, right? I think that you can still program as you do, right? But you have to be really careful. Imagine C, right? In C, you have some notion of a local variable, right?

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

Which where the scope of a local variable is the function that it is defined, right? And the local variable can change. It is always easier to reason about variables not changing, right? And the variables change, you have to sort of look at the functions from top to bottom. And the variables don't change, you can look at it in any order. Modulo side effects, right?

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

And this is not what Haskell, sorry, OCaml does, but Haskell has this notion of just pure functions. The type actually captures something pure. So Haskell does not have an order of evaluation. So order of evaluation is called by name where it can evaluate anything in any order. And why is this important? The order doesn't matter, right? So you don't have to read the program from top to bottom in order to understand what it does. You can read it in any order and it will make sense.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

And the advantage of doing that is you can, it makes it much easier to reason about small parts of the program. If some function says it is a successor function and it is purely functional, it will only do successor. It won't change magically say change some global state. So that's the higher level idea. I think this is all leading to stuff that I'm going to cover in this lecture. So do we have any control over the address to which the reference? We don't have any control.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

So just like good question. So I think you're doing Java in compilers, right? Just like you don't know, actually C++ also, right? Also C, when you do malloc, you have a... It gets allocated by the allocator at some location. You don't have any control. In particular, we don't have pointer arithmetic, right? Point arithmetic is a really bad idea because if you do, if I have a location which is,

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

say, one byte long, I can do an arithmetic to point to the next byte and then read it and say fault, right? So pointer arithmetic is not a thing in OCaml. Neither is it a thing in Java, right? Java is similar to OCaml in the sense that if the program type checks, then the program will not check fault, right? And this is quite important for Java because you can, in Java, you can download a class file that was compiled on any machine, right?

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

And run it on your machine. When you have a memory error, a memory error is a security error. So because Java's type system ensures that you cannot have memory errors, you don't have security, large class of security errors. And for this, it does not have any pointer arithmetic. But that does not mean you cannot follow pointers, you cannot do arithmetic on pointers, right? You cannot say, take this pointer and then add one to it, make a new pointer, read that pointer now. You cannot do that with the references.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

The only operators that the references provide you is these three, right? So actually, these are not operators, they are just functions. So the function ref takes some value of type quote a and then returns you a cell, which is of type quote a ref. And the value that is initially in the cell is the value that you provided here, right? And exclamation is the prefix function. It's a very special function in OCaml, but it's just a function, right?

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

And you can sort of get the functional form by using the brackets here. What is exclamation doing? You apply exclamation on a reference cell, it gets the value in the reference cell, right? If the reference cell is of type alpha ref, then the value that you get is alpha. And what about colon equals? Colon equals, you have a left hand side and the right hand side, right? It's an infix function. So on the left hand side, you have a reference cell, right?

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

The location that you're updating, which is an alpha ref, on the right hand side, you have to have the value, which is the alpha, it updates the reference cell, and it does not return anything, right? So everything is going to be an expression, right? Because these are functions, this update has to return some value. And because we are not update returning anything useful, it returns unit. So all of these are not special, right? They're just functions.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

They just happen to be functions that are defined in the standard library of OCaml, but they're just functions at the end of the day. So that's how we tie these operators down to functions that we've already seen in OCaml. And in particular, we don't have pointer arithmetic. You cannot take a reference cell and then say, get me the next address in the reference cell. That is not an operation that is sensible. OK, so let me continue.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

So here is there is an implementation of a counter, right? And the idea of this counter is that it will give you a function which you can call to get the next value of the counter. So this is if you think about the number of lines of code that you need to write to do something like this in, say, Java or even C, right? It's going to be quite tricky. You'll have to use a global variable.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

We are not using a global variable here. So that's the key. So what we do here, so make counter is a function that takes the initial value of the counter. It creates the reference cell with the initial value. And what it is going to return is a higher order function. It's actually going to return a function. It's going to return a function whose type the argument type is unit. So it's a unit to something function. What is that something?

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So when you call this function, it's going to increment the counter value and then return the current value of the counter. So when you make a counter, so this is a function that takes an initial integer, it takes an integer and returns you a function that takes a unit and then it turns you an integer. So it returns a higher order function. And what can you do with this counter? Let's say I make a counter with initially zero.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

I can call this function once I get one. I can keep calling this gets me different values. But the point is I can make it doesn't use a global variable in C. If you had to implement it, you will need to use a global variable. But if I I can easily make a different counter, which is different from every other counter that is in the program so far, right? And then I can say next to type.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

I haven't done this.  Why is it causing a problem? This expression should have a unit. OK, so it's. We do it this way. Next to next to. So it produces two, two, three, three. Happens to be the same value, but let me do a different value.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

You start with something else. Let's say 100. So I have two different counters now. So I easily wrote a function for creating multiple counters and each of which gives you different values. I mean, of course, you can do it in C with Malick and so on. But the way we do it here is we wrap this thing in the higher order function. And that makes the counter work.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

And this gives you a nice way to dynamically create additional counters as you as you want. Just a simple trick to show how to combine mutable state and higher order functions. Right. And the combination of mutable state and higher order functions will come back to over and over again. This is one of the key points of. Expressive power of how to do interesting things with interesting things in OCaml.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

OK, so let's move on. So to come back to the question and the follow up discussion, right. Sir, in every call we are creating a new reference. No, we are not.  So good question. So we are not creating a new reference every time. So you have the initial reference cell that is created when you call the make counter first time.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

When you call this make counter the first time, you create a cell. Every time you call the make counter, you create one cell. And every other time you're just updating the value of the counter. Every time you call the next function, this is the function that you're calling. In particular, this doesn't have the key address. You're not creating new borders. Is that is that clear? OK.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

So. Yeah, OK. What do you want to say? So this is so we have an example of. Having this higher order functions and mutable state, right. And in particular, the so far, right, before we've had mutations, we've had this beautiful property called the referential transparency.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

Which allows you to say, you know, you know, you know, you know, you know, you know, you take any expression in the program, right. And you can replace that with V happily if he is beta equivalent to V, right. If beta evaluates to V, let's say I have a complicated function. I evaluate that function with some value. It gives me some other value. I can replace that expression with this value and the program meaning does not change. Right. This is the key property that she was asking.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

Right. So I think the discussions are the values to that the property that we have with purely functional programs is referential transparency. The fact that you can take any and then replace that with a V side effects break referential transparency. What does that mean? Right. So here is here is a simple example. It's a full full of X equals X plus one. That's just a successive function. Right. So this is an entire function.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

When I call the bass equals four of ten, it gives me eleven.  And I can optimize this program as two, eleven. Right. The meaning of the program hasn't changed, even though internally I'm calling that function. I'm no longer calling that function because who is your right. It behaves like a mathematical function. If the only value that I'm calling through with this ten, then I can replace this call with just eleven. Right.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So this should be obvious. We can do this because this implementation is referentially transparent, which means it's pure.  But let's take a different example. Let's let's call this function bar. Right. Which takes an X and then returns you X plus this next function that we defined earlier. Right. Which keeps returning new values.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

So I'm defined the function. Observe that this function also has inter-event type. So the type doesn't tell you that it is doing side effects. So if I run it once, I get 16. The question is whether I can now replace this with 16. Right. The original function is let X equals one of ten. It returns 16. Can I just replace the definition of X with 16? No, it doesn't work. Right. Because if you run it again, it gets 17, 18, 19, 20.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So referential transparency does not hold just by looking at this function. I can't just say, OK, this function has inter-end. I know that I am applying 10. I evaluate it to 19. So I'm going to replace this with 19. This optimization cannot be done. You can think of this as an optimization, but also program reasoning.  If you have a program which is purely functional, you send a value, it returns some value, you exactly know what it is doing.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

You can just by looking at the input and output behavior, you can fully describe what that function does. But if you have side effects, the function might be sending, say, one packet on the network. You don't know that. But if you optimize, say, two calls to that function with, say, one call, you might just be sending one packet. And that is not obvious in the type. So you cannot perform optimizations.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

But when you write large programs, this referential transparency actually makes it difficult to reason about programs. And sorry, the side effects make it difficult to reason about programs. The lack of referential transparency is the reason. OK, so that's the idea there. We've not seen very large programs, so it might be hard to appreciate this idea. But the general principle is keep it purely functional.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

If you can, don't use side effects unless you really need to. That's the general idea. And this is not a thing that you need to think about only in the context of OCaml. Even if you write C functions or Java or Python or whatnot, if you write the function such that you don't have side effects, then reasoning about the function, when you use it in the client side, it becomes easier to reason about the function.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

I can just look at the type of the function and know what it is doing without having to look at the details of the function and looking at the side effects. This is a general principle that applies to every language. OK, let's see how I'm doing with time. OK, I'm OK. So the thing that references allows you to do is create aliases. What are aliases? Before that, let's just look at this program.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

I have x, which is a reference to 10, and y, which is a ref cell that has value 10. And I say z equals x. The idea here is z is just another name for x. It is just an alias for x. And z also points to the same cell. And I now say, get the value of x, which is 10, add 1 to it, and store it in z.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

We know that z is the same as x, so x becomes 11 now. And if you get the value of x, which is 11, get the value of y, which is 10, and you add it, you get 21 back. And what is happening here is we say that z and x are aliases of each other. So they both point to the same memory location. And the way to imagine this is x and y are variables. I'm going to use this notation for variables.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

And this rounded square for rounded rectangles for references. So both x and z point to a reference cell which has 10 in it. And y happens to point to a reference cell which has 10 in it. So that's the idea. Yeah, OK. So we've introduced the concept of aliases.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So this notion of having aliasing, OK, so there's a question here. So do these references follow scoping? Can I access x from outside? The variable scoping is the same as what we have in OCaml so far. If you have a variable, if the variable is available in scope, you can access it. But if the variable is not available in scope, if you declare the. So let me answer you with this concrete thing, right?

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

So we looked at this. We looked at this make counter. So the C is referenced only by this function. This function only references C. There is no way to access the C directly. And hence, you cannot access it. Right. Because the scope of C ends here, right? C is a variable that is only defined in this scope. You cannot access it from outside this function. Does it make sense?

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

I mean, does it mean that there is a memory location which is permanent? Yes. So as far as the program is concerned, yes. So that is there is a C, right, which has a particular memory location. And that memory location is not going to be shared by any other reference that you get. OK, so. The question of permanent is different, right?

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

You want to do something about these references that you get. Yeah, you can only access it in that scope. You don't have to explicitly destroy this reference. Because we have garbage collectors. So just like in Java, you can create a new object. And then you don't explicitly free it, right? The program takes care of freeing it when it is no longer referenced. So similarly here, as long as you hold the reference to the C, there is a reference to the C through this function.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

So as long as you hold the reference to this next function, you can indirectly access C, but you cannot directly access the memory. Does that answer your question?  Good. Yeah, OK. So the notion of aliasing introduces a different notion of equality, right? So you can now ask two questions, right?

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

One, whether the two variables, two expressions point to the same memory location, right? That is one question that you can ask for equality, whether they point to the same location as one version of equal. But the version of equality that we've been using so far is whether two values are equal. So we use the term, we use the syntax equals for equality, right?

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

We've been using that in our examples. And this is known as structural equality, right? There is two notions of equality. The first one is structural equality. This is what we've been using. So this checks whether two values are equal structurally, right? So if I want to check whether the one to three is equal to one to three, I'm going to first check whether both of these are lists, right? And whether the head is one here, so that is true.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

And whether the tail is equal. And how do you check whether the tail is equal? You recursively apply the same thing, right? You check whether the head is equal, yes. And then you check whether the tail is equal. Then you check whether the head is equal. The last one we'll have is an empty list. The empty list is equal to empty list. So this is looking at the structure of the values. So this is not a structural equality. This is what we've been using so far. And because we've introduced references, you may also want to ask whether two expressions are aliases, right?

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

I might want to ask whether x and z are pointing to the same location in memory or not. This is similar to pointer equality, right? So and we call this physical equality. So in OCaml, we use double equals to check for physical equality, right? Again, syntax, but just go with the syntax, right? So whenever I write single equals, I mean structural equality. When I write double equals, I mean physical equality.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

So why does this difference matter? Actually, before that, just the types, right? Equality is just a function, right? On left, it has to be some alpha. On right, it has to be alpha as well, because we can only compare values of the same type. And it turns you Boolean, which represents whether the values are equal or not. And similarly, double equals is also alpha to alpha to bool. But the meaning is different. So this one checks whether the values are structurally equal.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

This checks whether the values are aliases, right? Whether they are pointing to the same location in memory. OK, why is this important? Let's look at one example, right? All of the syntax here is what you've seen earlier, right? What I've done is I created a list L1, which is 123. And I say L2 is equal to L1. So this is just a variable which represents the same thing.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

I write L3 equals 123, right? And I create a reference R1, which creates a reference cell, which points to L1. So it points to the contents of L1, right? I create an R2, which is just an alias for R1, right? And I create R3, which is a reference cell. I create a new reference cell that points to L3. And there are lots of questions here, right?

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

Because we can apply the only restriction on equals and w equals is they have to be the same type on left and right. There are a bunch of questions here, right? And in order to answer this question, the easiest thing to do is to, let's just run this function. It produces something. The easiest way to answer this function is to actually write down a version of this, version of a heap, right?

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So what we are describing here is the structure of the heap. If you run this lines of code, let's look at, let's look at how we arrived at this, right? We said initially L1 equals 123. What happens when you create a list with 123 this way is, it creates an object on the heap, which will have 123, right? abstractly, there is an object which has 123.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

And L1 is a variable that points to this object, right? L1 is a variable that points to this object. And I say L2 is equal to L1. So L2 is just an alias for L1. So L2 points to the same object, 123. L3 is 123, right? When in OCaml, whenever you create a new value, which is a complex structure, right? Not a primitive value.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

This is not just a floating point or a integer or a Boolean. It is actually a list. So list, when you create a new value, which is a list again, it creates a new object, right? It creates a new object, which is 123. And L3 points to this, right? And then I create a R1, which is a reference cell that points to L1. So you create this reference cell, which points to L1. And you have this variable R1 point to that.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

You have an R2, which is equal to R1. R2 is just an alias for R1. It points to the same thing as R1, right? Because R1 points to this reference cell, R2 also points to this reference cell. And finally, R3 is equal to the f of L3. So R3 is a reference cell that points to whatever that is pointed to by L3, right? Which is this object. OK. So that is how you arrive at this heap, right?

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

It seems strange that you're creating these objects, multiple objects here, but that's fine. OCaml is very efficient at creating and throwing away objects. So you don't need to worry about efficiency at this point. So we've created this heap. Now we can answer all the questions, right? L1 equals L2. L1 equals L2. This equality is structure and equality. OK. So we are checking whether the value that is L1

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

is the same as value that is L2. They are actually physically equal. Any physically equal value is also structurally equal. So L1 equals L2 returns you true.  And then I asked whether L1 equals L3. So L1 is this object. L3 is this other object. But they are structurally equal, right? They are both lists, 1, 2, 3. So L1 equals L3 also returns true.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

And then I asked R1 W equals R2. W equals is physical equality. So I checked whether R1 and R2 are pointing to the same object on the heap. They are. So R1 W equals R2 returns true. So I am then asking L1 W equals L2. L1 W equals L2 will also return true because they are both pointing to the same object on the heap, right? L1 W equals L2.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

And now I am asking whether L1 equals the value 1, 2, 3. So what I mean by this is L1 equals 1, 2, 3. This is also true, right? L1 is a value which is 1, 2, 3. And 1, 2, 3 is just an expression, right? It's just a value. And we are using structural equality here. And hence it is true. Now I'm asking L1 W equals 1, 2, 3.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

So here is where we get false, right? When I write this expression, I get a new object, which is 1, 2, 3, right? And I asked whether the object that is pointed to by L1 is the same as the object that is allocated freshly because of 1, 2, 3. It is not, right? So you get a false here. Okay. So this is the interesting bit, right?

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

So whenever you write this expression, you always create a new object. So that's the first thing to remember. I'm asking whether R1 W equals R3. R1 is this object. R3 is this object. I'm asking for physical equality. This will be false. R1 W equals R3. That is false. L1 W equals L3. L1 is not equal to L3. That is also false. That is also false. R1 equals R2, right?

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

I'm asking whether R1 equals R2. R1 is physically equal to R2, right? So it is also structurally equal. R1 equals R2 will be true. Now, finally I'm asking whether R1 equals R3, right? R1 equals R3 is true, right? We see that the result is true, but R1 and R3 are references, right? So the question is how do I interpret structural equality on references?

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So the way OCaml defines this is references are structurally equal if and only if their contents are structurally equal, right? So we are asking for structural equality between R1 reference and R3 reference. They are not physically equal, right? But are they structurally equal? We know that R1 and R3 are references, right? And we say that references are structurally equal if their contents are structurally equal. What is the content of these two?

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

Both of these are one, two, three, one, two, three. They happen to be different objects, right? But these indeed are structurally equal, right? The value that is in R1 and the value that is in R3 are structurally equal. So we get a group here. So importantly, there were two concepts mainly, right? The first concept is this idea that references are structurally equal if their contents are structurally equal. The second concept is whenever you create this, you're actually allocating a new object on the heap.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

So this will never be true, right? Because you're always creating a fresh object and this fresh object is different from every other object that has been previously allocated. So this will always be false. Yeah, you can, it's okay, two questions. So sir, can we have a int ref type? Yeah, you can, right? So you can just do that,

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

equals ref of zero. Yeah, so this is certainly possible. It's just a reference that points to a reference that points whose content is an integer. This is certainly true. Let R4 equals ref of, yeah. So Ravi's question is, let R4 equals ref of R1. So ref of R1 creates a new location.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

Actually, this is a ref of L1. So this creates a new location, right? So this is certainly different from every other location that has been previously created. It gives you freshness essentially. And hence R1 will not be physically equal to, oops, R1 will not be physically equal to R4.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

R1, W equals R4 will be false. Whenever you create a ref, it is chosen at a location which is different, right? Different from everything else that's been previously created. Okay, so that's the whole idea here. So my recommendation for, I think I might certainly ask questions that looks this way, right? And my recommendation is you look at this,

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

you create a heap like this, and then you can answer it easily, right? And the two things that you have to remember is this rule and what happens when you actually create a complex type like this. You always create a new location that is different from every other location that you've previously seen. Okay, I think I'll stop here. I think I need a little bit of time for this topic. So any other questions?

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

Yeah, so you recursively apply this, right? What about the structural equality of the ref ref type? This is a recursive definition, right? References are structurally equal if their contents are structurally equal. So you apply that for the first ref. So references are structurally equal if their content is structurally equal. So the inner well content also happens to be a reference. So you apply the same rule. References are structurally equal

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

if their contents are structurally equal. And then if the content is structurally equal, then it is fine. So let me give you an example. So ref of zero, right? In smaller.  If R2 equals ref of zero, right? I asked R1 equals R2. This is true because we applied this twice, right?

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

We applied this rule twice. So it makes sense to me. Yes, no. Any other questions? Sir, when we do ref zero. Yeah. The zero is a different object. And for ref zero, we create another zero object and then make a little.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So in OCaml, I mean, we are not going to study this. Maybe we will. In OCaml, there are the two kinds of values, right? So one is primitive value and another is objects. So zero is a primitive value. So what happens in memory is that you create a new location, a box that holds the value zero. So zero is always physically equal to zero because they are primitive values. So similarly, true is always physically equal to true.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

But this is not physically equal because strings are objects themselves. When you create the string, it is going to be allocated as an object, like just like C, right? In C, you create strings as an array with characters. It's the same representation here. So I think they should return false. Yeah, this returns false

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

because this is an object in memory and this is another object in memory. So if we do refer for string true, then the string true is a different object and for doing ref, another object is created and a pointer is. Yeah, so if you do, but if you ask true equals true, it is true because they are structurally equal. Structurally equality for strings is just, the strings are equal. Okay.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

Does it make sense? Yeah, if you do this, this is also true because this is one object, right? And true is another object. Again, this is one object, true is another object because these are references, we check for the structural equality of the contents. We check for whether these are structurally equal, they are equal. Okay, thank you. Okay, so, no, right?

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

So Venkates asking whether the OCaml maintains a common memory for all primitive values. There is no memory, right? It's just bit pattern. In, imagine how you would encode the integers, right? If I say the integer value is 20, I just have the, in 64 is 20. I have a 64 bit word whose value is 20. Similarly, OCaml just, it doesn't,

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

there's no common memory. The memory is just the bit pattern, right? If I say ref of 20, what it internally has is, it creates a box, right? The box has a single, the size of the box is a single word and the word's content is the bit pattern 20, right? So, and if I do ref of 20, this is another box, right?

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

And the box is of size one word and the word is 20, the bit pattern 20. Okay, so is L2 an alias for L1? Yes, L2 is an alias for L1. But I introduced aliases in this lecture because if I told you those are aliases, I would have to tell you about the heap, but without introducing references, heap is not interesting. Actually, that's the beauty, right?

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

So, so far we've not had to think about heaps and other things because we were in this purely functional land where everything was, you didn't have to think about heaps, but you now you have to think about heaps and other things. Okay, so any other questions? Okay, so I think I'll stop here and then we can continue from the rest of the,

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

changing L2, change L1, you cannot change L2. L2 is a, L2 is a value, right? You can, you can sort of define another L2, which is one, two, three, but there's no way to change it. It's not a reference, right? It's just a list value.

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

But if you change, okay, so if you change, so okay, so maybe the interesting question is this, right? R1 and R2 refer to the same list. So if I, so let's do bang R1, it's one, two, three, right? And then I can do R2 equals empty list. And then I do bang R1. So, yeah.

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

So this one is also, this is saying R1 is empty now, right? Why is it empty? Because R2 and R1 are aliases, right? I use the R2 to update the list to empty. Of course, both, both will be empty, right? So if I just say bang R2, both are aliases, so I get, I get empty. Actually, I should write it like this,

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3295.3s_

which gives you a tuple, but, but even if you drop this outer bracket, OCaml interprets, if you have an empty comma, it just says, okay, I think you're trying to define a tuple, so that's why it interprets this way. Does that make sense, Sushar? Okay, you said okay already. Okay, fine, I won't take you any more time. You have another class. Talk to you tomorrow, bye-bye.

---
