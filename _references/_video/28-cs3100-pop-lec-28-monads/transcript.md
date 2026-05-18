# 28-cs3100-pop-lec-28-monads

**CS3100 POP - Lec 28 - Monads**  
id: `fJR7rizrrGk`  
duration: 3250s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

All right, so before I begin, I hope you had a chance to have a look at the last lecture slides and so on, right? And so if you have any questions, you can ask me now before I continue.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

Any questions on, I mean, we've actually not seen the details of where we are to be in this monad lecture, but if you have any questions, you can ask now. Okay, so looks like there are no questions so far, but if you have any questions to ask

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

during the lecture. So what were we trying to do, right? So just to recall, we are trying to write a simple interpreter for the expressions which has a plus and a divide and we wanted this interpreter to be a total function. By total, we wanted whatever expressions we give this interpreter, we wanted a value, right? But we observed that, of course, this division you can have divide by zero, which means if

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

you directly did that, this will throw an exception and this is not total function anymore. So we rewrote this interpreter using optional values with the idea that we can use none for representing this exceptional state, which is divided by zero exception. But we observed that the program itself was very tedious, right? There was a lot of match with none and some and so on.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

So in order to factor out common parts, we ended up writing two functions. The functions are named just so that they match the monad. But anyway, there are two functions return and bind return given a value just wraps it in some bind takes some computation that might return an option value, right? And if that value is none, then the whole thing is just none.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

It also takes a function that needs to be applied to the value if the value is some. If the value is some V, then we apply F on V. So why is this useful? We can now rewrite our interpreter such that we can use binds everywhere. So binds and returns. For example, in the case of plus, we first evaluate you on if you want evaluates to none and the whole thing should be none.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So we simply bind this value of eval even with the function, this function which goes from here to here. So if eval of even evaluates to none, then this whole expression, right, this whole expression evaluates to none, because that's what we have defined here. If this evaluates to some V, then that we get bound to this V1. So if that actually gives you a value, some integer, then we want to bound to that.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And we do the same thing for E2. And that function goes all the way here. And finally, if both of them are evaluating the values, then we return V1 plus V2. If one of these actually evaluate to none, then this whole expression evaluates to none. So that's the point here. And the interesting bit is the check here, right? So if the denominator is zero, then we return none.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

Otherwise we return whatever the result of the divisions. OK, so this is fine. So typically, when we define monads, we don't use the bind function. We use the infix form of this function. The infix form is greater than greater than equal to for no reason at all. It's just a syntax which says take the result of this computation and feed it to whatever

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

is on the right hand side, right? So that's the reading. And even the first paper, which I had shared earlier in the Slack channel, uses this notation. So we sort of use this everywhere, right? So this is an infix function. So you can rewrite the previous code snippet using this where you evaluate one, right? And instead of writing bind, we use this infix function bind. We just call it is read this as bind.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

We bind, which if it evaluates to some value, binds the V to this V1. And similarly, E2 to V2. And finally, we have a return. This is what you would have seen if you had taken this course earlier this, sorry, last year. Luckily, OCaml has a fancy new syntax for writing monadic programs, which makes it a

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

little bit better. So there is a new syntax since OCaml 408. This was released in June 2019. So it's like just a year and a few months now. But you can extend this let. So we have let in OCaml, right? So let is used to sort of introduce new bindings. Similarly, you can define your own lets. And what we do here is we define our own let.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

And we use the syntax let star, which just stands for bind. So whenever I use let star, I'm actually calling this function bind in the background. And why is this useful? It is useful. Observe that the type of let star is the same as bind. Actually, this is not important. But you can see the example. And that becomes quite clear why this is useful. So again, I'm not introducing anything except changing the syntax. So again, evaluate e.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

And if the expression happens to be e1 comma e2 plus e1 e2, you evaluate e1. And we use the syntax, new syntax let star, instead of using this bind and this greater than equal to this infix function, we can directly write it as let star v1. Internally, what it's doing is if this e1 evaluates to none, this whole expression evaluates to none. But otherwise, this gets bound to the value in the sum.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

Similarly, eval of v2, e2, you see v2. And finally, you can wrap this whole thing in a return. And return wraps it in a sum. So the same way you can define divide. Again, the semantics is the same. The syntax is just different. All that is happening here is we have a nice syntax for writing these sort of programs which internally have this other additional semantics.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

So if you run this, you still get the same type. So given an expression, this returns integer option. So it behaves the same way as the earlier one. It's just nicer to write it this way. Why have we gone through all of this exercise? What is the benefit? So if you sort of look at the original definition and compare this to what we have now.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

So we have a return here, return here, return here, and we've used let star. Let star here, and also here. But except for that, the original definition that we had, which used to return an integer but was broken, it was not total, looks the same as what we have now except for these additional syntactic things. Except for additional returns and let star.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

But the key difference is that this function is not total. This is not total. It has some effect which is not captured in the function type. It actually goes ahead and throws an exception, which is not apparent in the type. It's not a total function that doesn't behave like a mathematical function. But this does. It does behave like a mathematical function in the sense that this is pure. Whatever expression you give, it will give you a value. The value might be none in the case of divide by zero.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

But it's still a total function. So what we've done is we've sort of, what we have done is we've sort of simulated the notion of exceptions. So in this program, there is a divide by zero corner case for which exception is thrown. And we've rewritten that program in a way that exceptions are no longer required. We simulate exceptions using optional values.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Of course, the exception doesn't carry the message, but you can define your own data type instead of optional type. But that's the key idea.  What we've done is we have this effect in OCaml called exceptions. Exceptions are not explainable just as a mathematical entity. You have to sort of think about the stack and so on. Right. Where is the exception thrown? Where is it caught? And so on. If you want to simulate exceptions, you can simulate it using

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

this monad that we've defined. Actually, what have we defined? We've ended up defining an option monad. What is an option monad? Option monad also has the same monadic type.  There is some computation type, alpha t, right? The computation type. There is a way to lift values. Right. Alpha values to alpha t computations.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

Right. All it does in option monad is rapid and some. And there is a bind which takes one computation. Right. It takes the second computation which consumes the result from the first computation and gives you a computation which has the effect of both of these computations. Right. And the result of the computation is a beta. So you're sequencing computations together. That's monad.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

And for an option monad, the computation itself is some expression that returns an optional value. Right. And the turn simply wraps it in some and bind is what we have seen earlier. Right. So the key idea here is this option monad is also a monad. We've just defined a monad. Slowly we've done it through looking at examples. And the high level takeaway is option monad simulates exceptions. Right.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So this is so we've taken one sort of effect exceptions and we've needed an using option monad. So as I mentioned earlier, right, so just satisfying the signature alone is not important. Monads also need to satisfy monad loss. Monad laws essentially say. Places restriction on the semantics of what a monad can do. Right. It constrains what the return function and the bind function can do.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

Right. So so that you get something which is sensitive. And the loss of here, right, this is the law. And the loss of that. And it's it's sort of you can read it. But the idea is that if you have a computation with just lifts up your value. Right. And that's not itself perform any effect. And you have another computation that takes the result of it and performs the computation.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

The effect is that is the same as performing the right hand side. Right. And applying just the value because a return of V does not have any effect on its own. It just takes a pure value and gives it up. In particular, if you if you sort of map it back to this option monad, this return of V is not going to cause divide by zero exception. That's the intuition, because it is not going to raise divide by zero exception. You can just take the value, whatever the result is.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

Right. Which might be some integer and then apply that to apply f to that value. There is also right identity. So this is known as the left identity because the left hand side does not do anything interesting. And similarly, you have a right identity where the right hand side does not do anything. The left hand side is some computation, but the right hand side is just returned. So that should be equivalent to just running V. And the final one is associativity.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

So if you have three computations, M, F and G. If you first sequence them to F and then whole thing to G, then it is the same as taking M binding it to the composition of F and G. You can work out why there is an additional X here, but I'm not going to go into the detail. But this is similar to the associativity laws that you would have seen for, say, additions and multiplications.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

So, OK, so I say monad loss have to be satisfied. Can we show that the option monad that you define satisfies the monad loss? We can. So here is how you do it. So let's just pick one law. Let's pick the left identity law. The left identity law is this one. So return V bound to F is the same as F applied to V.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

That's so what we are going to show is this particular term is the same as F applied to V. And the way you do the proof of these losses, you simply expand the definitions in place. So we know that return V in option monad is just some V. By definition of return, we just expand it and we know that this bind is itself just a pattern

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

match, which matches the left hand side expression, some V with if it is none, the whole thing returns none. If it is some V, then F is applied to V. This is what just expanding the definition of bind gives you. And if you beta reduce it, so we know this is some V and this only matches this turn. So the whole expression evaluates to FV. And we have the right hand side that we need to show.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So this way you can also show other loss just by expanding these things in place and applying beta reduction. So, of course, the all of the yeah, so option monad satisfies all of the laws. Okay, so, okay, so that's option monad, which was used to simulate exceptions. Right.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

The other sort of, as I mentioned, right, monads are there for the simulating side effects. Exception is one sort of a side effect. The other sort of side effect, which we had just seen in earlier lectures is this notion of mutable state. Right. So OCaml allows you to define and manipulate mutable state. Mutable state does not behave like a mathematical function, right? You're destructively modifying something.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

How can we explain what is going on in a mutable state?  And the way you can explain something like a mutable state is try to simulate it in a pure setting. Right. Try to simulate it using something and that something happens to be a monad here.   So this is, I mean, this might seem like a exercise which is aimed at just a study of

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

these properties. But I should say that this is a very nice way of actually building programs.  So imagine having some program that needs to manipulate the state. Say you're defining a graph traversing where you need to modify the visited notions.  So let's say you are traversing through the graph and you want to, whenever you visit a node, you want to say that particular node is visited.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

So this is going to change the state destructively.  But if you sort of abstractly, right, at this point, imagine the fact that you give it some graph, right? And the property that you want is some traversal that you do returns the same result. And the way you do that is easy way of doing that is if there is no mutation, right? If there is no use of side effects, then it must be the case that if you provide an input,

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

then you get the same output again.  You still want to have this notion of mutations for the ease of programming, right? This notion of visited state and so on. But you still don't want to use mutations because it will be difficult for you to reason about the correctness of the algorithm. So you can use something like state monad to simulate the fact that you have mutations,

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

but you're simulating it. We don't use this idea widely in OCaml, but in a language like Haskell. And also, like it is increasingly being used in production languages as well. So things like Scala, right? So which is heavily used in Twitter has these notions slowly creeping into mainstream libraries.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

So what we are so the high level take here is we are going to try to simulate one more side effect. And the side effect that we are going to simulate now is state. And we will define a monad again, we will go through the same sort of exercise. We will go through examples to sort of set the scene up. And then before you know it, you'll have a monad in your hand. And what we are going to do here is.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

So in OCaml, you have the primitives that you have for manipulating mutable states are quite rich. So you can create new locations, right? You can just create a ref 0, which will give you a fresh location, which you can manipulate. And you can have multiple types for these locations as well, right? I can have one location, which is an integer reference, another, which is a Boolean reference, and so on. These are all details, right?

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

Let's get to the core notion of just modifying the state, right? So what we're going to do in this initial exploration is we are going to start off with the single location, right? There is only one location in the whole program that you can manipulate, right? And the single location has a single type, right? So you cannot have multiple types for the same location. So it is going to be a single location with a unique type.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

And we are going to write a monad, which can get the current state, read the current state, and put a new state, right? Modify the existing state. So what you will do in the next assignment is actually extended to full power of ML style references with new locations and different types and so on. But we are going to start here, right? So once you understand this, then the jump from that to full-fledged references is very easy.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

So let's go through this. So I'll stop in the middle and I'll ask you, I'll stop for questions, right? So these topics could be quite abstract, right? So these are, when I saw Monads first, it was different from anything that I had seen before, right? So typically what we, as anyone, right, as humans, what we try to do is to sort of see a new idea

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

and then try to see, try to match it to something that we already know, right? And we say, okay, the new idea is different from this existing idea that I know in these ways, right? And that is how we sort of learn new ideas. One thing I observed with Monads, right? And this is true with anyone who learns Monads is it is so different that it is hard to find

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

existing crutches, which you can hold on to and then look at Monads and understand it. It is different from anything that you might have seen. It is okay if these things are not clear, right? But at the end of doing the next assignment, I think you will completely understand what is going on here. And you will also develop this sense of the underlying principle, right? So, and hopefully that's the goal.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

It's okay if you don't understand everything in the first scope, right? And that's not the point. Okay. So with that, let's proceed. So what's the high level idea, right? The high level idea is that we want to simulate state, right? And there's going to be a single type location. So how do we do this? What we are imagining, going to imagine is that we are going to thread the state through

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

the entire program. What do I mean threading the state through? Threading the straight through means passing the state as an additional function argument to every function. And every function also returns the new state along with the function result, right? You change your entire way of programming to say, all my functions are now going to take this extra argument, the last argument, which is the state.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

And every function now returns a pair of values, the new state and the actual return result for the function. If you do that, then you can, and surely you can see what the current state is because it is always available. And you can change the state because you anyway return the new state in every function. That's the idea, right? It seems very unwieldy. The trick is to actually make it nicer to program with.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

So we'll see what threading the state means with a concrete example. So here is what our usual Fibonacci recursive Fibonacci function looks like, right? It's a recursive function, takes an n and then has two recursive calls. This is a pure function, right? So it takes a value, it returns a result. And if you give it the same value, it will give the same result. Nothing surprising there.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

Now let's change this function such that the last argument is the state that you are passing through the function, right? And just as I mentioned before, the function always returns a pair of the new state and the result of the function, right? So we are going to change the definition of Fibonacci so that there is going to be this S, which is the state that you are going to pass through the function, right? Fibonacci itself is not going to read the state or modify the state, but it is simply going to pass through the state, through the function.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

What do I mean pass through the state? Whenever you call the recursive call, right, fib of n minus 1, you pass the existing state through. So the current state is S, you simply pass it through, right? And similarly for the other recursive call as well. And in the base case, what you do is we know that when n is less than 2, the result of Fibonacci is 1, but we also return the existing state.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

Because Fibonacci does not modify the state, it just returns the same state, right? And because every call to Fibonacci returns a state, Fib of n minus 1 applied to S returns a V1, right? That's the result of Fibonacci and a new state S1, right? Of course, Fibonacci doesn't modify the state, but bear with me, right? So we are going to get a new state S1.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

And what we are doing here is we are calling Fibonacci of n minus 2 with this new state. So we are taking the state from here and passing it to the next function, right? Which returns the result of the function V2 and also returns the new state S2. And finally, the result of this whole Fibonacci function is add V1 plus V2. That's the result of this path, this branch, right? And the current state is going to be S2, right?

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

That's the final state. So this is what I mean threading the state through, right? So we are sort of taking the state here, we are passing it through the first recursive call, which might return a new state S1. We take that one, pass it to the next recursive call, which might return the new state S2. And then we finally return the final state, right? Of course, in this example, Fibonacci does not modify state, but that's the idea of threading the state through.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

Okay, any questions on this? Yeah, so one thing we are doing here is we are making the program unnecessarily complicated, right? So we are adding this extra state for no benefit at all.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

We will, and we are making the code ugly, right? So why any sensible person would not rewrite all of their program with this additional state for no reason. So we are going to try to do that. We are going to try to fix both of those in the SQL. Okay, so looks like this is fine. So, okay, so we've defined Fibonacci, we know how to thread state through.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So because we are passing state through, right, you want to manipulate it in some interesting fashion. So we are going to define a get and a put. Get simply returns the current state, right? And put takes a new state and updates the current state so that it is a new state. And because we are just threading the state through, right? Get does not take any input, it just takes unit as an input, right? This additional state is just being passed through, right?

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

And all get does is it should return the new state. So the result of the function itself is s, right? Get is returning the new state. But you also have this usual additional thing of passing the state through. So the current state you get, you just pass it through because get doesn't modify the state. And get itself returns the state s, right? So we are returning a pair of s, s, but the intuition is that this argument is the usual

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

state that we return from every function. And this is the actual return value of get. So get is giving you the existing state. Okay, so that is get. And what is put doing? Put takes a new state, right? And put is going to change the current state, right? The notion of change here is it just returns a new state. So it takes the new state as an argument.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

It actually ignores whatever state is being threaded through. So something is being passed through. It says, okay, I'm just going to ignore it. So I'm using underscore here. I'm not actually naming the variable. So the state is thrown away, right? Whatever was passed through to put was thrown away. And put says the state is being now modified, right? And the way we represent that is the return value, whatever comes out of put is this us,

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

which was passed as an argument here. And the return value of put, right, the function put actually returns nothing because you're modifying the state. Think of the return value for modifying a reference, right? When you modify a reference, the I can actually do it here. So when you when you modify reference, the value that you get is a unit value, right?

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

It takes a current reference, takes a value returns a unit. And for this reason, put also returns a unit. So, okay, so now, man has a question. We already have existing status. What is the meaning of this? Good point, right? So, so get is a bit pointless at this point, because you are passing the value of the current state to get and we are expecting the same value out.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

Right. So at this point, it's completely pointless, right? So it is it is meant to be that way. It will become clear when we abstract it, right? So it's good that you observed it. And it is it is a bit pointless when we write it this way. As we step through the lecture, it will become clear.  Any other questions? The notion of modification is important, right?

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

There is no modification except that put takes this new state and then returns a pair, right? And the expectation is that whatever is the first argument is the new state. So that is what it is doing. It is actually ignoring whatever was passed through. That's the key bit, right? So if you call put with the new value, the thing that you will get is a new state and a unit value. Okay. So that's fine.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So we have get and put. So we didn't really need references for the state, right? So we are not going to use reference. So that's the point. Is that what you're asking entered? So, so, yeah, so I have what I meant was like we are maintaining an additional return value. So we don't really need reference and a memory location to maintain.   Yeah. Yeah. Yeah. That's that's the idea.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

So the whole point is if you want to sort of reason about it without using state, right, we are we are simulating state by simulating don't depend on the primitive features, right? And that is what we are doing. So like we don't really need reference means there is no sort of mutation actually happening. We are just memory location kind of thing. Precisely. Yeah, exactly. So but what we will see is that as we slowly develop this, right, we will go up to some point

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

in the lecture material and you will you will actually do an assignment which is an extension of this, but you will see that you'll get the full power of references with new locations and so on. But we will not use references underneath, right? We will completely simulate everything using this. You might ask what is the whole point, right? The point is, if you know that something is pure, then you can believe that it behaves

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

like a mathematical function. So it is easier to reason about it is easier to test. You can put these things you can run this thing in parallel, right? There is no notion of trying to reason about shared memory and so on. Lot of things become simpler, but now you are right. The whole point is you're not going to use references. Okay. Okay, so with that, let's step through.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

So here is a simple example that combines the two things that we've seen so far, right? We've defined the Fibonacci function, we define get and put. So what I'm doing here is I'm defining a fib state function. The idea is that I'm going to read the current state that is going to be the input for the Fibonacci function. I'm going to compute the Fibonacci nth Fibonacci number using this input, and I'm going to update the state with the result.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

So of course, I'm passing the state through, right? So I'm going to get the current state. This will be the same as this, but bear with me. So I'm going to get a new state. And I assume that the thing that I read from the state is the input for the Fibonacci, right? That is then I print the value, I print the current state and the result of get. And then I'm going to call Fibonacci with the n, right? And simply pass this one through.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

That will determine a new state and the result of the Fibonacci, right? I print that value here. And then I finally, what I do is I update the state by putting r2, right? Sorry, r is the result of Fibonacci. I'm going to update the state with r, and I'm simply passing this through, right? So s2 is here, and s3 comes out. I print this. And then I say this whole computation has modified the state to s3.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

And this has no effect. Sorry, this returns nothing because the whole point is you read from the current state, you compute a Fibonacci, and you update it against. So it's just a matter of putting these things together. Okay, so I need to define Fib. So yeah, so we've defined that. So let's see this in practice, right? So I'm, fib state does not take any value, but it reads from the state.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

So let the state be 10. So this will be the input for the Fibonacci function. So it is going to compute the 10th Fibonacci number, which will be 89. So the state finally is going to be 89. And if you run it, the first component is a state, right? That is 89. The result is unit because fib state itself returns unit. And you can sort of see what is happening, right?

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

The state at get is 10. And the result of get is also 10. The result of, sorry, the result of fib is 89. Oops, the result of fib is 89. And the state was not modified. It is still 10. And after put, the state got modified to 89, which is the result of Fibonacci. And the result of put itself is unit. So we're sort of slowly getting to the point where we can hide it.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

But that's the intuition. So you get the current state. You update the state finally. Okay, so all of this is fine. So so far, it's all seems like a lot of first for nothing. So one, there are multiple things that you need to observe, right? We changed how we write functions completely, because every function is now taking this extra

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

variable state and naming the state type as just state here. So I'm using the type variable state for the type state. So if you look at the type of Fibonacci, it takes an integer, right? It takes the current state. And Fibonacci returns a new state and the result. And we do this odd thing of threading the state through, right? It's like, why do we call it threading? It's like threading the thread through the needle, right? So it's like stitching. So we take this S that passes to F1,

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

n minus one that comes out as S1. S1 goes here, comes out as S2, and then comes out as S2 here. So we are doing all of this. Lot of this repetitive, right? This is repetitive passing this through. And similarly, we see that this is also repetitive. So you take S, pass it to the first function, get it out, pass it to the second function, get it out, pass it to the third function, get it out, return the result. So one thing we are good at doing in functional programming

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

and in this course is abstracting things away, right? We want to abstract away the details so that we get something that is sensible to program with. So let's just look at the types. So as I mentioned before, I'm going to use the type variable state for the state. Fib itself was a function that took an input integer, the current state, and returns a pair of the new state and an integer, get. Does not take any input, right?

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

Actually, get happened to take a unit, but you can imagine get does not take any input. And then the state argument is passed through. It returns a new state and the result of get is also a state. Put takes the new state as an argument. This state happens to be the state that is threaded through. And it returns a new state and put itself returns unit. Okay, so these are the types that we get for fib get and put.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

We can factor our common parts. There are a lot of common parts here, right? This is common to this one and this sort of is, sorry, which is the same as this. And the thing that we are factoring out is the fact that if you sort of imagine fib get and put as computations, each computation is going to take in the current state, right? And it's going to return a new state and the value, right?

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

So let's name that computation as alpha t. Let's call it the computation type. What is a computation? Every computation takes in a current state, right? And returns a new state and the result of the computation. Just like the option monad, the alpha here represents the result of the computation. Right? So all I've done here is I just defined a new type.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

Now, if you use this new type definition, right, to rewrite fib get and put the types of fib get and put. Now you can sort of see that fib is a computation that takes a current integer, right, it takes an integer and then returns a computation which returns an integer. Right? The state is sort of hidden in this computation type. And similarly get is a computation which when performed gives you the state somehow, right?

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

I'm not going to tell you how. Get is just going to return you the state. Put is a function that takes the state, a new state, and it's going to update it. The computation itself returns a unit value, right? Because this is unit, the computation is going to return you unit. It's not going to return you anything useful. But internally, the computation is going to update the state. Right? So all we've done here is we've taken this type, right, these types, and we've sort of

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

factored these out as computation type, which takes in a state, the current state, and is going to return a new state. Okay. Any questions on this one? This is just a type alias, right? So all I'm doing here is defining a new type, which is an alias for this type, a function type.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

Okay. So let's move on. So I mean, this is where it gets a little bit more tricky. So one thing we want to do here is, as I mentioned, right, we are threading things through. So at every step, this is like a snippet from the earlier function definition. We pass s through, we get s one out, we pass s one through, we get s two out, and we return s two. I don't want to do this.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

I don't want to do this idea of like explicitly sending a state argument, getting the state argument, sending the state argument, getting the state argument out. Fib one, and these fibs are now computations, right? So in option monad, we saw this bind operator, which was a way of putting together computations. It's a way of fusing together computation into a single computation. We are going to define bind here. All it's going to do, right, it's going to do the same thing, it is going to take the current state,

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

call the first one, get the state out, and then take the second computation, pass the state through. Okay, so I've defined the bind function here. m is a computation, oops, m is a computation. I've written types out explicitly, just so that it is clear, or none of these types, annotations are necessary, right? The way to read this is bind takes two computations. One of the computations is m.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

The second computation is a function which takes the result of the first computation and returns your computation beta t and gives you a beta t. So Sartak has a question. In the previous definition, functions are not taking the current state as input, but is that not important? They are taking, right, Sartak? So they are taking the current state as input.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So if you just expand this in place, this will be the same as in state, this is the current state, ro, state, comma, alpha, this is the result state and alpha. Right, they are taking the current state. I'm just writing it in a way that it is not, it is hidden. But they are taking the current state because this is, this definition is the same as this definition. Is it? Okay, good. Right, so it's a nice way of writing it so that you don't have to think about the

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

state being passed through all we are doing it like we are writing it in a clever way that we are hiding the details. So that's what we are doing so that it becomes nicer to program that. Okay, let's look at this function, right? So it's a current computation, it's a function which consumes the result of the current computation and gives you a new computation. And bind is going to attach these computations together and is going to give you one computation

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

which has the effect of both of these and whose result is going to be beta because f returns a beta. Okay, so that's the setting. And because this is a computation and our computation type is a function type, we define an anonymous function, right, f, with the idea that it takes the current state, right? It passes the current state to this computation, m first computation m, right? Because we know that

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

every computation takes the current state, so it takes the current state. It is going to return a new state s prime and the result of the computation V which is a code A, right? And what is f? f consumes code A, right? So we apply f on V and that itself is a computation which needs to take the state. So we pass s prime through and this is going to return a new state as double prime and the final

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

result, right? And we return s double prime the resultant state and result. So if you sort of, so the way to understand this is you sort of compare this to this, right, this definition to the Fibonacci definition. So what we are implicitly doing here is bind, we just lifted it up. So this ms, right, is basically this s here, we're getting an s prime here, which is s one here.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

And we are passing the result of this value here. We are not passing the result here because this function does not need it, right? But we are passing the s prime through, which is the s one here, which comes from here, goes into here, which gives you a s double prime here, we get an s two, and the result, which is V two, right? And we return s two, V one plus V two, here we return s double prime, and just the result. Okay, so that is all we've done, we've sort of taken this and

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

return it in this way. Okay, so the thing that we did, so we have bind here, right? And similar to the earlier option monad, you can use a let star syntax to write it better. So if you use let star, let, let star equals bind, you end up with the syntax just, it just looks like this.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

Again, this looks very much like the Fibonacci function, right? So the usual Fibonacci function takes fib of n minus one takes the result fib of n minus two takes a result, and returns V1 plus V2, we've arrived at that all of this implicit state threading is hidden behind this monadic interface. So all of that is hidden behind this bind and return. So we no longer have an explicit state being passed through, but that's just there. So let's actually see what we've done, right?

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

What we ended up doing is we've defined a state monad, right? We've defined the return and the we haven't seen the return, we have defined the bind function. But a state monad is exactly defining a single type mutable set, right? And it offers get and put functions which we've seen so far. But it also has an additional run state function. The idea is that when you have a

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

computation in the state monad, what is a computation, it takes an initial state and then returns a final state, we just use this helper for helper function run state, which takes the initial state and actually runs the computation. We'll see what it is. I think it's not important, we've seen all of the details so far. So what is a state monad? A state monad is a monad. So we define this type for state monad, right? There is a definition of type state. It has all the

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

functions of a monad. What are those? It has a computation type, it has a return and a bind. In addition, it has a get, which return it is a computation which returns a state, a put, which takes the current state, and then somehow updates it, right? And it's, it's returns a computation, which just returns unit. And you have a run state. Run state is a function, right? Which takes any computation in the state monad. So you built a

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

computation together for the state monad. You pass the initial state. So I'm using labeled argument here. But I think that is not the details are you'll just catch it. But we are passing the initial state. And it is returning the final state and the result of the computation alpha. So it takes a computation, which is an alpha t, it takes the initial state, and it returns the final state and the alpha. Okay, so that's the type of state monad. And the definition of state monad is sort of

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

putting together things that we've so far seen. Right? So I define a functor. So because I said there is going to be a single type state, I'm going to define a functor, which takes a module, which only defines the type, right? So the only thing that it defines is a type T. Right? And this functor returns a state monad, where the state type is the s dot t. So the idea is that you can

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

instantiate this functor state with an integer type or a floating point type or a or a Boolean type, sorry, or a yeah, or a Boolean type. And all you get is a state monad for that particular type. Right? So far, we are only looking at a single type. So that is the idea here. So we make it as a functor, where the type is explicitly given. Right? And the state type is the same as the type

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

that was passed through. The computation type is what we saw earlier, right? It's a state, it takes the initial computation, current current state, and then returns you a new state and the result of the computation, that's the computation type. So we've already seen bind. That is what we have seen in this in the slide here, this is the definition of bind, I just not written down all of

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

the types explicitly. Right? Get input is what we saw earlier. Right? What should return do return return takes a value, and it's going to lift it up to a computation that computation itself does not have any effect. Right? So because a computation is a function, it takes the current state, right? And then just returns the existing state. And the value that it returns is V. So all we are doing is we are taking the value V and then making it into computation, the computation itself just simply

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

passes the state through, gets some state and then returns the same state. Okay, and then returns the value V. So run state, what does run state do? Run state takes some state computation M, you have an initial value. And this is the way you apply labeled arguments. Again, details are not important. But this is taking in it as a initial argument. And because we know computations are

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

functions, right, given an initial state, it is going to return you pair of state and alpha. So we just call, we just apply M1 in it. So if you take this computation and apply the initial state, what you will get is a pair of state and the final result. Okay, so that is what you get this

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

again in the next class. And then we'll see examples of actually using this in an interesting fashion. I'll stop here. Any questions on this so far? I'll cover this part again tomorrow. This is a bit abstract. What I want you to do is come up with questions for tomorrow,

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3243.6s_

right? So we will see a little bit of examples that will become very clear what we are saying. But once you sort of understand, there isn't much going on, it's just a matter of wrapping everything in a type and putting it in a form that we can sort of hide the details underneath. But once you do that, the subsequent examples will make it very clear. Okay, so I'll stop here. I think I already take a lot of time. So we'll continue tomorrow. Thank you very much. Bye bye.

---
