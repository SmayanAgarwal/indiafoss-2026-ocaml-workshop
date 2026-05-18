# 04-cs3100-pop-lec-04-functions

**CS3100 POP - Lec 04 - Functions**  
id: `lYCkQQdLE3g`  
duration: 3049s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so you should be able to see my window and then we'll make it full screen. Can someone confirm that you can see my window? So we started looking at functions, right? We just had a very brief intro into functions. We didn't have much time. So I'll just start anyway, covering some functions today.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

So we are programming in a functional programming language and as the name would suggest the functions sort of play a big role in OCaml. Okay, so one thing I want to say about this lecture is you're going to see a lot of new concepts, right? Sometimes you'll feel that why are there so many concepts? This is so overwhelming. And what you'll end up seeing after we cover a little bit of OCaml is that we will sort of get to the essence of functional programming languages using

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

this very small language called Lambda Galpis. It's a three instruction set language, right? So we saw one instruction set language in our intro. There'll be just three instructions, but you can sort of study the entire complexity of what we are doing here just through those three constructs. Okay, so my take on this lecture is you keep seeing a lot of things, right? So don't get flustered. Just keep taking them as they come along and

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

then we'll sort of, you'll get used to it after some point. And you'll start seeing the same pattern being applied in say JavaScript or C sharp or other languages and you'll just feel familiar at that point. Okay, functions. So OCaml allows you to define anonymous functions. These are functions which don't have name, which you can sort of describe on the fly. So anonymous functions have the syntax where fun is a keyword.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

They take a number of arguments x1 to xn and then an expression, right? When you define an anonymous function, it's just a value, right? There is no further computation to do. E is can be any expression and just like you would define functions in other languages, E is not evaluated until you apply this function, right? You pass the arguments to this function and then evaluation of V happens.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So here is an anonymous function. So this function takes some x, right? And this x plus dot 1 dot, I think, as we saw earlier, 1 dot is equivalent to 1.0 and that's floating point value. So because 1.0 is a floating point value and plus dot is a function for adding floating point numbers, x is inferred. OCaml infers the type of x to be floating point, right?

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

If this is floating point, then it must be the case that this is also a floating point, right? Because those are the same variable. So what you get from OCaml is OCaml says, okay, you wrote this syntax for this function and what I can see is that this function will take a floating point number, right? Takes a floating point number and arrow is the function arrow. It sort of says what you're defining as a function and the argument is floating point number and the return value is a floating point number.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And we can't print the function definition because the function could be constructed on the flight, so it just says fun. Where it says the static semantics is this type and it's just a value. So it just is a placeholder there. Okay, so yeah, so this if you run this, you'll get this. You can also change the type, sorry, change the expressions and what you'll get is a different type now, right?

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

So plus is an integer addition and one is an integer. So x is being inferred as an integer. So this must be an integer and if you mix it up, it's going to complain, right? So this is what we had seen earlier. So if you do this, because plus operates on two integers, 1.2 is a floating point number. The expression has type float, right? This expression has type float, but an expression was expected of type in. So, okay.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

Yeah, you're asking a very good question. I will defer that question for later. Really good question. So there's a question on chat, which I'm sort of looking at. What is the type of this function for next arrow x? I will defer that question. There is something magical going on. It's actually very simple, but I don't want to sort of, you have to sort of, even though it's simple, you have to place it in a context so that it sort of, you can see the beauty of what is happening.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So we'll come back to it later. So I know this is a question. I have slides on this question, so I'll definitely come back to it. Okay, so this is what I wanted to say anyway, I've said it. So here is another function, right? This is a function that takes a unit value, right? So recall that when we write this particular form, right? Open bracket, close bracket, it's sort of a value, a special value in OCaml.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

That's a unit value. The value has type unit, right? It's sort of like, if you think about integers as a set, right? Which contains all the integers. Unit is a set that is a singleton set that has only one element. And that one element is this value, unit value. So what we are defining here is a small function which takes a unit value.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

So we just write unit value here because that's the only possibility here, right? And it returns integer, right? But the specialty of this function is there is only one value you can apply to it, right? So you can only pass it the unit value. So what's the point of this whole function? The point of this function is to suspend evaluation of the right hand side, right? The right hand side expression happens to be a value here. But if I do it as one plus one, it won't evaluate until you apply the unit to it.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

I mean, this seems strange. Why would you want to do this? Imagine doing something like sending a message that is already known over the network, right? You just want to define a function that sort of says when you call this function, you just send a pre-canned message over the network. When you want to describe such a thing, you would use a thunk. A thunk is just a name for a function that takes a unit value and then returns anything.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

It just suspends the computation for the moment so that you can evaluate it later. So that's thunk. Yeah, again, I've said, yeah, can we assign anonymous functions? Yes, you can. So we will see that Ravi Gupta is asking a question. So yes, you can. We will come back to it. Yeah, so these sort of forms are the... There is a separation of ideas, right? So let me go through and then you'll see what I want to say.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

Okay, so the cool thing with anonymous functions is they can refer to variables that are outside of their body. So imagine in C, right? So in C, if you want to... Actually, C doesn't have a good analogy. So let's drop analogies because C does not fit this well. So here is the definition, right? I define some let foo, right?

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Inside the body, sorry, inside the definition of let, I have let y equals 10 and x equals 5, right? And I define an anonymous function which takes a z and then returns you x plus y plus z. The key point I want you to take away is x and y are not arguments, right? They're actually referring to something that is in the environment, right? That is lexically scope. So in your scope, there are two variables called x and y and you are referring to those variables, right?

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

So and the type of this function is going to be inter-event because this is a function that takes a single integer. And these two have been referred to from the environment, right? So and then what you're going to return is an integer. Essentially, the idea here is this is a function which takes some integer, right? And then adds 15 plus that integer and return that value, right?

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So you can sort of refer to things that are in your scope happily and OCaml will not complain. Actually, it is very commonly used.  So the anonymous function here, which is the function that we defined here from z arrow x plus y plus z is set to close over these three variables. So there are two concepts here, right? Three variables are those variables that are not bound by the function arguments.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So this z is not a free variable because it is referred. It is it is being it is being passed as a function argument, right? But x and y are not function arguments. They are being referred to elsewhere. And these are known as free variables. And this function is set to close over those three variables. This is just terms, right?

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

There is there is no syntax over it, but we just tend to use these terms. So that's why I highlighted it here. So this anonymous function, you can just look at this anonymous function and you can see that x and y are not being passed as arguments. So we say that x and y are free variables, right? And this function is closing over these three variables. Just take those things as terms. We'll use them repeatedly when we come to studying more deeper concepts, lambda calculus.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

Okay. What I should do now is actually clear all of my output. Otherwise, I'm giving away a lot of things that I want to say. Okay. So anyway, I've given it away. But anyway, so what is the value of s? So here I'm defining bar, right? Where I say that x equals five and.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

So on y, I'm defining an anonymous anonymous function, which refers to x here, right? Which is five. And then I do, I just add the result. So the result is going to be 15. Right? Why? Because bar is going to be this anonymous function, right? Which takes an integer and then returns an integer and x is bound to five. When you pass y is 10, you get 10 plus 5, which is 15.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So that's the result. And in particular, I want you to notice that to answer the question, right? So you can bind this to. So we are binding this anonymous function to a variable here. So bar gets the function, right? This function and this function type is going to be interrupt. So you can sort of let bound these anonymous functions by that's how you give it a name.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

And this is function application. We just pass the value of 10 to bar and then we apply the function to get 15. Okay, so a couple of concepts here. I'll keep going. So yeah, so the distinction that I wanted to make here is when we studied let definitions, right, we said we can use let to bind the result of any expression.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

Right? And I also mentioned functions are also values, which by definition means they're also expressions. So what is happening here is has nothing to do with anything special to functions, right? Functions are just values. So just like let definition can sort of name any value, we are just naming a function value. So these concepts are quite separated, right?

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

So you can sort of see that functions are one thing, this let definition is another thing. And we are just combining those concepts to give names to functions. So this is unlike what we've possibly done in C and Java and other languages, right? Where function definition is sort of associate that with the name. So here we sort of have more fundamental operators. So you have let definitions and then you have anonymous function and we just name those things together.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

Okay, and the beautiful thing about functional languages is functions are values. So you can pass values around in any language, right? You can send values, return values. And similarly in functional languages, you can have functions that takes functions as arguments and even return function as arguments. So this is a very powerful language feature.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

You might have come across similar concepts if you have studied function pointers in C. But as we will see, the functions as values concepts goes much further than in C. I'll just leave it at that. So just sort of if you want to sort of frame this idea in your mind, right? How do I imagine functions taking arguments and function returning functions as functions?

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

It should be functions, not functions as arguments. Function can return functions. Think about function pointers, right? You can imagine a C function taking a function pointer and also returning a function pointer. But obviously the concept is much more powerful here. And we'll sort of slowly see all of that. So I showed you a very small example of how to apply a function, right? Apply a function is also like calling a function.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

But we tend to use the term apply in functional languages because it sort of fits within the ethos of what we're doing here. We've already seen one example where we've applied bar to 10. We say function bar is being applied to 10. And the general form is this is the syntax. So you have some expression easy row and then a couple of a series of expressions from you want to end right. And there is no parenthesis necessary. So you don't need to use parenthesis.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

And the way to read this is you are applying a function easy row to an argument. So. So here I'm using a very general form. Right. I'm using expressions here and all of these are expressions. So obviously there has to be evaluation of each of the expressions before we can apply this function. And what happens during evaluation. You can sort of think about this as the dynamic semantics.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

Recall the first class where we said every form has a static semantics and a dynamic semantics. Static semantics is the type. Dynamic semantics is what happens when you actually evaluate the expression. What we are seeing here is the dynamic semantics of function application. This is very intuitive. This is what you think should happen. But I'm sort of placing a name around that concept. So what is the what is happening here.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

So we have these application form. So you would go ahead and evaluate each of these expressions in one order. So you would you go from left to right order and then each of these will reduce to a value. So evaluate easy row to end to be zero to be end. As I said functions are just values. So type checking will ensure that B zero which is a value is a function whose type is this.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

Right. It's sorry not the type. The form is this where it takes an arguments and then return some expression. Type checking will ensure that. And what we do is we take each of these we want to be and substitute for each of these variables X1 XN. When you do a substitution you simply get another expression. So you take this expression wherever X and Y and Z and other variables are there. You substitute the actual arguments. You get another expression.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

You go ahead and reduce that expression to a value V which is the result. Right. So this is how evaluation is actually seen in imperative programming. We tend to associate calling a function and returning a value. Right. We still sort of interchangeably use those terms. But really what is happening when you think about function evaluation is what I described here. You take a couple of expressions right. E0 to N.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

You reduce each of the expressions to V0 to VN. V0 is ensured to be a function type. Right. Whose form is X1 XN gives you E. You take each of these V1 to VN substitute for wherever the variables are. Right. So all of the variables are applied and all you get is this expression. This expression will be a complicated expression now. Right. And then you go ahead and reduce the expression according to the expression semantics. Right. And you get a value V which is the result.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

So this is what actually happens when you do function application.  So there is no there is no we don't tend to associate or calling a function and turning a value. It's sort of reduction. Right. Everything is sort of taking an expression and then seeing how can we reduce this expression further. That said you can use these terms interchangeably. I'm not going to be very stringent.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

I know you have to use these particular terms but that's just to give you a comparison of what happens between functional languages and imperative languages. Okay. So here are some examples. So I have a very simple function which takes an X and then and then returns you X plus one. So I take this anonymous function. Right. That's a value and I apply one to it. So what happens here.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

You would expect the natural thing.  So the way you have to imagine this evaluation as you evaluate this to a value for we know function anonymous function is a value. One is also a value. Right. One is a value. So now you substitute in this body expression. Wherever you find X substitute one. So you get one plus one expression and then you reduce it you get two. So that's that's what is happening here.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

And then the same way you can have multiple arguments. So you can have X Y Z and then X plus Y plus Z. And this is going to do one plus two plus three. So that is six. So one thing that I should stress here is there are no multi argument functions in OCaml. So I've used multiple arguments here. Right. It looks like I am this function takes three arguments X Y Z and then returns you X plus Y plus Z.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

This is actually a syntactic sugar. Syntactic sugar is like some helpful syntax for this other form. Right. The form is this because I said the function can take values and return values the way you have to read it as this function. Right. Expects one argument. It expects an X when you apply this function to one argument.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

It is going to return a second function. It's going to return this function. Which takes one argument again. Which is why and it's going to return another function. Which is this function. And the last function the third function is taking one argument. Right. And then it is going to perform X plus Y plus Z. Right. So this is really what is happening when you write the form where you take three arguments.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

It is actually expanded to by the compiler into something like this. Right. So the way to read it is one next is a function which takes one argument and then returns a function. This function which takes again one argument right. Which again takes one argument and then performs this computation. You can use this interchangeably but you sort of see that there are no multi argument functions in OCaml.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

It's just in that issue. The semantics is the same as exactly the same as this form.  And as you would expect this gives you the same result. But the key takeaway is this. Right. So in in many languages you sort of see functions taking many arguments as like a primitive. Right. When we say primitive it is embedded into the language here even though we have special syntax for it.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

It is not at all special. The semantics the static and dynamic semantics of this particular expression. It is the same as the static semantics static and dynamic semantics of this expression. Right. So these two expressions are equivalent in terms of the static and dynamic semantics.  So right. So multi argument functions do not exist in OCaml. I mean at this point you might ask OK this is very this might be inefficient. Right.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

But actually the compiler is very smart. So it optimizes it to a form where it has the same cost as what you would expect in a multi argument function. But that's besides the point.  So we don't care what the compiler does in this course. You are studying compiler scores for that. So I will leave all of that there. All I want you to take away is that these sort of forms are just special forms. Right. And you think about functions that take multiple arguments in your mind.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

Sort of imagine that you can also have functions that take one argument to turn another function. OK. So that's that. Yeah. So just to make it very concrete. We can use let to do to name functions. So here is. Here is one useful name for this function. Right. The function is taken X and then return X plus one. I can give the function the name which means successor.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

So successor is a function that takes one argument. It runs the successor value. And again this is semantically equivalent to writing in this way because writing it takes more characters more keystrokes.  OK. I'm sort of allows you to do something like this. But you say let's suck X. You sort of now read this sucked as a function. Sorry.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

You sort of read sucked as a function definition which takes one argument and then gives you express one. Right. So so just to. We do like all of these. Syntactic sugars right because they save a lot of time. So we will see this form which is let suck X equals X plus one a lot more often than this form. You are you're not wrong when you write this but we will just stick to writing it this way.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

But again my point is when you see that suck X equals X plus one in your mind think about think about the equivalence to a definition like this. You could have equivalently return the same way. OK. So so I need to. A has a question. So I do let my phone equals fun next fun. Yeah. So I need to ask a question. Yes.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

So here's the question. I'm just looking at the chat but I'll try to run it. Yeah. Yeah. So this has to be a let. Right. So we don't we can't use well this be a let and then in. So yes. So we are defining a name right and then we define this function. It takes. It takes one argument. Right. So you take one argument and then you return a function. Right. Which which will expect one more one more argument.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

And if you run this you'll get 15 because then you go ahead and apply the body. So because every multi argument function is a function that takes one argument that does a function you can you can just apply one of the arguments. OK. Yeah I'll delete this one. Then continue. What if we have explain a spot. Yeah that's fine.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

So you'll get minus five. I can go back to. So these are integers right. They had to go from negative positive impacts to infant to in Max. So you can do. Let me try to under the cell and do that itself. I mean the order of arguments. I don't get the question. So you can then you speak perhaps.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So that couple you want to unmute and say. What your question is. I don't think you mean this. Right. You don't mean this. OK so let me move on. I think you'll see. So you want to do something like this. OK so you want to do why.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

This will be fine. So you just naturally progress and just do substitutions. So if you if you reorder the arguments this way. I mean there's nothing magical going on. So this is just. Yeah just so my point is these are very simple. So you just go to this particular slide and then keep doing the same thing.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

The recipe that is described here will get to the values. There is no. So I think the doubt is when we write functions in this way and we have multiple values like one two and three we wrote in which value. To X Y and Z that. Oh no no. So these are good questions. So so these are the. So X is not special. So we are not assigning to X. So these are positional.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

Just like you would. I think that is that I'm good. I'm a sort of making sense. So when you apply a value you are not applying to you are only applying to the first argument. You are not applying somewhere deep inside for X. Is that the question? No one. Sir. Yeah. Yeah. So actually above you have written a conversion of fun of X Y Z equals X plus

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

Y plus Z one two three. Yeah. Yeah. Shouldn't it be in the reverse order then like Z Y X maybe I'm not sure though. No need. Why would so you want to know like you know up you can just go up for a minute. Yeah. Like here which which variable is assigned to which like which gets one which gets to which gets three. So X gets one. Okay. Why gets to open and see gets three.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

See the see the reading is this right. So yeah. So I think I think it's a question of where the brackets go. Is it so if you sort of imagine it this way then it becomes clear.  So this is a function that takes one argument you can sort of ignore this for the moment you can just ignore it for a moment. It does something with X. Right. So X happens to be assigned internally here so that that shouldn't really

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

matter there's only one simple form. Yeah. So that. Yeah. I know it will. So yeah. You are actually like we had that doubt whether it's evaluated bottom of from top down like I mean how does the compiler assign values to the variables. So there is only one form. Right. So which example do I take. So let me just take this example. Right.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So make it should be good. So what is it correct to say that the first variable that is mentioned in the function definition gets assigned to first argument and so on. Yeah. Yeah. So it's what you would expect in a natural NC or something right. So you just if you pass one argument it gets assigned to the first one. If it is second then it gets to the second one. Right. So here here there's one goes to X here.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

Right. See we'll just reduce it by hand.  So what happens here. Are you clear with this example or should I reduce it there. So here I take one two three. Right. So it could be one two three. So one two three. We just replace wherever you find X you just replace that with one and similarly to you just replace that with two here and same for Z.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So you get one plus two plus three which is six. And here you can sort of do this reduction by hand. So let me just write it this year. So this is equivalent to doing one step of reduction. You are going to substitute. You're you just look at this one right. OK. I can see what the issue is if I make all the brackets explicit maybe it's clear. Yeah. Yeah.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

This is the way to interpret it. So the first thing it looks at this. Oh there is a function definition here and you are going to apply to one argument. Right. So I've I've applied one here. So one is applied to X. So now substitute wherever X is there with one. So now what you will get is you'll get this body right where X is one and then you have two three.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

Now the question is what happens next. Then it says it interprets this way. Right. So now you look at two you substitute two for wherever Y is and this expression now reduces. Right. So you you get this expression. And then why is substituted.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

And finally you have three. So one to two. So function application is left associated. Right. So when you look at F of ABC you see it as F of A applied to B.  Right to C.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

I think this should answer some of the questions. Sartek does that answer your question. I think you started the question initially. OK. So OK. So I think I should probably mention it in the next time I teach this course. So yeah function application is left associated. So when you see F of ABC you sort of read it as F applied to A and then that is expected to return a function because otherwise the program wouldn't type check.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

So then this is the interpretive this way and finally this. Thanks for asking my beautiful questions. So these are very very useful questions for me. OK. Any further questions on this one before I I might have confused more people by explaining it badly. So I just want to give you an opportunity for this. OK. So one more question.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

You have fun X Y arrow X plus Y. Yeah you need to give brackets properly. So I think. So. We can try this. So OK we have this. So what is. How is it going to interpret this one. So it's going to it's going to be very confused by this.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

It's a syntax error because you sort of have to provide brackets for values when you encapsulate function anonymous function. It is always nice to give brackets. Otherwise the parser would be very confused. You'll study Nexus and parses in OCaml. Sorry in the compiler scores and you'll see that this is quite tricky to pass. OK so now you have a nice thing right.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

This is this is no longer a parser error. You have this valid form here. You have a valid form here. One valid form somewhere valid from somewhere. What do you think will happen now. If you sort of interpret. What I said before right. Just look at this one. If you have expression you want to eat to eat three four five you reduce all the expressions first. So I reduce I reduce each of these function anonymous functions are reduced values.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

So this is a value. This is a value. This is a value. This is a value. This is a value. Right. OK so people say for. Does anyone want to say something else. Let's let's let's let's just go go ahead. Right. So apply this left associative rule now. Right. So you look at expression easy or even eat to eat three four which is now easy or even eat to eat three before.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

Yeah so that we got caught it. So it's an error right because. First thing it's going to do is it's going to look at this and say I'm going to reduce this expression. OK so the type inference. Yeah so you can't. Yeah that's the answer. So you can't add a function integer right. Type inference is going to enter infer the type for this function as. From looking at plus right it's it knows that this is a into into into into function.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So it takes two integers and then returns an integer. So it expects the arguments to be an integer right. This is not an integer. This thing is a function. So value is a function. So you're going to get another. So yeah. What if he had a parenthesis. Yeah you can. Yeah yeah that will that will solve it.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So the question is what if I had a parenthesis. You need one more parenthesis. So the idea is that. Parse it again will not know how to pass the second argument. So anonymous functions have to be parenthesis properly. So if you parenthesis this way. It'll be fine. Because again go back to that rule right. Each expression reduce it to a value. This is a value.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

This is not a value. This is a function application so you can reduce it. And this reduces to two. Again this is a expression function application that reduces to two. And then you finally apply it. So this will reduce to four. Okay. Any further questions. Good questions. These are really good questions.  So I think I think that might have solved some of the computations.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So we'll continue with what we are seeing earlier.  Oh adding parenthesis all the error. So okay. So let me try to do this again. So oops. So. When I look at this one right.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

There is a question in the chat which is I don't understand how this solved the error. When I look at it this way it looks like five expressions right. One expression two expression three expression four expression five expressions. All of these expressions are values. So when you when you sort of have all of these as values and you have this form where you have V zero V one V two V three V four OCaml is going to say I am assuming V zero is a function.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

Right. I'm going to now apply V one to it. So it is going to do this reduction. First right. It's going to do sort of do this first. Okay. So just look at this particular form. This is wrong. Right. This is wrong because this is a function this goes and gets substituted here. And this becomes something like this. Yeah something like this.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

You can't add a function to a any integer that wouldn't type check. So the type checker will complain. Okay. So it's going to break in some way. So that is not good. Why does the adding parents is solvent when you add a parenthesis here. There are only three expressions now. There is V zero here.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

You want here. And. You do here. So OCaml is going to look at it and say whether each of these expressions are values. The first one is a value. That's just the anonymous function definition. So that's a value. Right. Is the second one a value. It's not a value. Right. It's an anonymous function applied to one. Right. So even can be reduced.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

So easy. It will just be the same thing. Even is apply one here. Right. One where the X is. So one plus one. This becomes two. And the same thing for E3. Sorry E2. Where this is a function application that can be further reduced. So this becomes two as well. Now keep doing the same thing right now you have easy. You want you to.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

E2. Are these values. Yes. So two and two are values. And function anonymous function definition is a value. So you have V0 V1 V2. Now you go ahead and apply.  So X gets the first value and Y gets the second value. So you have two plus two. Two plus two. Which is four.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

So that's why the error is solved. Okay. Good. Okay. That's good. So any further questions. It's important you understand how functions work because you'll be using functions left and right all the time. So the thing that I didn't mention but to take away is that. Function application is left associated. Okay. So you sort of read the packets from from the left.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

And that should clarify what's going on here. Okay. Now function definitions. Yeah. So you have a successor function which is X plus one. And of course you can you can define the function. Now you get the name right. So the type checker says we are defining a function. Which is a suck and it takes an integer returns an integer.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

10 gives you 11.  Yeah. This is just repeating what I had said earlier. Right. So you can you can have functions that take two arguments. Right. I am I am defining add function that takes X and Y and does X plus Y. You sort of read it as add is just a name for an anonymous function. Right.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

That takes one argument returns another function. Right. That takes one argument and does X plus Y. And this sort of reading is not always useful. But the point is they're equivalent. So oftentimes we'll just say add is a function that takes two arguments. Right. And these are equivalent. So yeah. And this should give you addition result. Which is 15 and maybe I've mentioned it earlier.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So the thing that is happening here is I have a definition of add here, which is a top level definition. Right. I have another definition of that here, which is also using the same name. Right. So the when I call add here, I am referring to the closest one in scope. So the closest one is the last defined one, which is that here. So what is happening implicitly is this add is shadowing the previous definition.  So it could be just for fun.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

Right. So I can do it like this as well. I can mix it up as I want. I think it should work. Yeah. What I did here is I defined one argument here and two other arguments are taken here. Right. So if I just. You say 20 and give me 35. Right. Now this ad is actually taking three arguments here.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

That's the ad that I'm referring to. And this definition of ad has been shadowed. Is this definition. Okay. So yeah. So because because of this view, right, where we said every multi argument function is actually a function that takes one argument that returns a function, you don't have to pass all of the arguments to a function, a multi argument function.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

So here is a function which takes three arguments and then returns x plus y plus z. If you just apply it to one, it is going to return a function. I think we've seen this working through that example.  So you can you'll get you'll substitute wherever x is one. So this becomes one. And what you get in return is you have a function that takes two arguments, right? Y and Z. And then this expression.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

And you can give name for this. Right. These are just the values of the point. This is just a value. Right. This is fully evaluated. This is just a value. So you can name it. So I have a name called foo, which I give to a function that takes that to this form.  So there's an anonymous function that adds the three arguments, but I just supply one of the arguments to this. So when I just supply one, you get this back. Right.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

So foo is a function that takes two arguments, right? Adds them up and then adds one to it. Adds one to the result. So here it is going to add two plus three, right? Because it is going to add y plus z. And then this one is already substituted. So it is also going to add one. So you get six hundred. And you can mix these syntaxes up.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

At the end of the day, everything is just a single argument function that may return another function.  Yeah.  So I wanted to ask what is the type of foo? So type of foo is in tarot, in tarot, in. Good question. So while function applications are left associative, right? So let me try to phrase it properly so that again, I don't say something wrong.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

So when you have FAB, right, we sort of read it as F of A. Applied to B.  So but when you write enter, enter, enter, the typical reading is it takes two integers and returns an integer. Right.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

But that's not the only reading because everything is like a multi argument function is just a single argument function. The bracket actually is right associative here. This might be confusing, but just go with it. So the way you have to read it is this way. OK. So the type of foo is a function that takes one argument, right, and returns a function that takes one argument, right, and returns an integer.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

Sir. Yeah. Sir, so there is no explicit type called fun. So everything is written in this form. Yeah. Yeah.  The form. Yeah. Arrow is the function format. Right. So when you when you write arrow here, that really means function. OK, so. Yeah. And then and then you can also partially. So why is this reading useful?

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

Right. I read the type in tarot in tarot in task for types the brackets go right associative. Right. So this is a function that takes one argument and returns a function that takes that. Sorry, returns a function that takes one argument and returns an integer. Why is this reading useful? You can partially apply any multi argument function. Who is a multi argument function? Right. So you can partially apply it. So you get.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

Intervent function. Right. And again, you can name this thing. I can name it as bar. Right. So bar is in tarot and then I can apply bar to the excuse me six. So you sort of. Yeah. Yes, sir. Understood. So. It has its own like unique type casting the way it's. Yeah. There's no there's no type fasting.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

You sort of say it has a type. Right. You just define the function. Okay. Well, in first a single type fasting. Okay, sir. Okay. And yeah, so the fact that we don't explicitly do multi argument function is helpful because we can partially apply any function that expects more than one argument. I think I'm out of time. So yeah, so I'll just stop here and then I'll be will continue in the next class.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3040.9s_

These are really good questions. I think the class is very interactive, even though we are in this weird situation, but we'll continue tomorrow. Thank you.

---
