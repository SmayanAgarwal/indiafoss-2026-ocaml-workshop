# 29-cs3100-pop-lec-29-monads

**CS3100 POP - Lec 29 - Monads**  
id: `GL8FcFd6HB0`  
duration: 3303s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

I forgot to upload it. I'll upload it today. So just to recall, what we were doing is we were defining this new monad for state that allows you to simulate state. And we had incrementally built up to define this state monad. So how do we define a state monad? A state monad is a functor that takes some type as an argument.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

Essentially, this module argument sits here only for getting this type. And this functor is going to return you a state monad where the state type is s.t, whatever type that was passed through. The idea is that you can instantiate the state monad for a particular type. So you can create an integer state monad or a Boolean state monad or any one particular state monad specialized to one particular type.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

So the type of state is s.t, just as the sharing constraint here says. The type of computation is a function that takes the current state and returns you a pair of the new state and the result of the computation. So when you write alpha t, you are essentially saying it's a computation that when run returns you an alpha. And return simply returns the value and does not read or write the state. It simply gets the state and returns it. Mind is what we have seen earlier.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

So get the current state, pass it to m, the first computation. That will give you s prime and a result of the computation. And apply f to a and s prime. That is going to return a pair of a new state s double prime and a result of f, which is some b. And this whole thing is the bind operator. It is going to return the current state and does not modify the state.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

So the first argument is the same. It takes a new state. It ignores the current state that is passed through. It changes the state so that the state is now whatever that was passed through as an argument. And put itself does not return anything useful. It returns u. And finally, there is run state. It takes a computation, an initial state, and runs it. So it returns a pair of the final state and the final result.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So this is what we had seen earlier, the last thing that we saw yesterday. Any questions on this definition? There are a few things going on because everything is a function here. Is there anything that is not clear in the definition of the state monad? You can ask questions. I'll wait for a minute.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

The bind. So I think bind is easier to explain looking at the previous definition where we introduced the bind. So what is bind doing?

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

Bind is like take two computations together and then return me a computation which performs the effect of both of the computations. It's like a glorified semicolon. So it's like putting together two computations together. So what are the arguments for bind? First one is a computation. It's a computation that returns an alpha, which when run, it's going to modify the state somehow. The byte doesn't explain it. But it is going to return an alpha value.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

And that's the result of the computation. And the usual argument in bind in a monad is that the second argument is a function which consumes the result of the first computation. So essentially, it's a function that takes alpha, which is the result of the first computation. And itself is going to define another computation. It's a function that just returns another computation. So that computation has the type beta.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

So now we are in the second part. This is beta. And what does beta do? Beta is essentially something which, when run, is going to return you a beta value, a value of type beta. And because we are putting together computations, we are attaching one computation to the other so that the effect of both of the computations are done. Since the result of f, so this is going to be beta, the result of the whole bound together computation,

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

when you put them together, you're going to get a beta out. So that is the type of the result. So I've annotated the arguments just to make the types clear. So that's the type. And the type says that the thing that you return is a beta. So the beta computation. So what bind returns is a new computation.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

It is going to the type from the type. We know what the type of the bind in the monad is. From the type, we can see that it is a computation. And what is the thing whose type is a computation? The type is just an alias for this function. It is something that takes a state and returns your pair of the resultant state and some return value. So because the thing that bind should return is a computation, we define a computation here.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

How do you define this computation? It has to be a function that takes a state and returns your pair of state and final value. So it's a function that takes the current state. What do you do with the current state? The idea is that you first pass the current state to m, which is a computation, which we know is a function also. So you apply m to s, the current state. You are essentially passing this through,

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

which returns you an s prime, which is a state, resultant state, and b, which is the result of evaluating m, whose type is alpha. So if you sort of look at this particular line, this matches the line here. It is some function to which you pass it s. It is going to return s1 and the result of the computation. And the next thing that you do is you pass this s1 back into the next computation, which is what we do here.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

So we have f, which is the function, which takes the result of the previous computation, which is b. It takes that. But it also takes the state. The current state could be modified. We don't know what m is doing. It might be different. So you take s prime and pass it through here, which is what we do here. We take s1, pass it through here. So that comes out as s double prime and result.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

And in bind, all we say is we just return. This is a pair of new state and the result. Is that sort of better, Rajwal? That's bind. Run state is so I think run state will become clear when we look at an example. I think that we have a lot of examples that will come.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

But just think about this idea. So what is run state? Run state is going to. So what we've done so far is just built up computation. Oh, we built up this huge function. Essentially, because function is a computation, we built up this function. And we have to sort of plop in the initial state. It will do some computation and then plop out the final state and the value.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

So that is what run state is going to do. So run state has the type alpha t. So given a computation which returns alpha, we have to give it some initial state. We have to put in the initial state, which is in it. And it returns you the final state and the value, which is the result of running the computation. If you look at the type of this monad, this is the only one that actually returns a pair

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

of a state and computation. So sorry, pair of a state and a result. The idea here is that we know that alpha t is itself a function. It's just the type of a computation is just a function. This is hidden. This is hidden behind the interface, but we know that the type of a computation is just a function that takes a state and returns you a state and an alpha.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So in init, if you take this computation, it will expect a state as an argument. So we just take this argument, apply it to the initial state, and that will just return us the final state and computation. It's just a function application at the end of the day. So which is what we do. We take the initial state, sorry, the computation, the initial state, and we apply the computation to the initial state, which will run that function. That's the computation result, always the same type as the state.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

Yeah, that's the thing that we have, Sree Shah. Good question. So what we say here is we fix the type here, right? Type of state. Actually, in this lecture, right, what we are going to do is to alter reason about changing types, but now everything is going to be the same type. So there is a single, so if you instantiate the state with integer, the state is going to be integer. All of these functions are going to be specialized for this integer state.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

So there is no change in state at all. Actually, let me move on, right? As you see examples, it will become clear. We've been looking at that very abstractly. So let's look at how do we use this example. So here is the use of, okay. So just before I move on, I'll just answer the Naaman's question. This tilde in it is labeled argument, Naaman. I haven't fully explained it

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

because I think it is sort of, you can learn it by practice is what I want to do. OCaml has this idea of labeled arguments. I think C++ has labeled arguments, right? I forget C++ has been so long. Similarly, OCaml has labeled arguments. C++ has default values, not labeled arguments. Anyway, so labeled arguments gives you, so typically when we write functions, every function is a positional argument.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So if a function foo takes integer, integer, integer, integer, integer, integer, five integers and then compute something, right? So it will be inter, inter, inter, inter, in. There is no idea of what these integers might mean. So labeled arguments give you this ability to actually label each of the argument. You can say first one is the X coordinate, second one is the Y coordinate, third one is the velocity, fourth one is the acceleration,

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

first one is say some answer or no answer or whatever, right? So you can add these labels to arguments and the advantage is that you no longer need to pass the arguments in the right order. You can use the labels and pass the arguments in whatever order you want. There are two benefits to label arguments. First one is actually these are self-documenting, right? The types will, look at the type.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

The type will actually reflect that the argument has a label in it. The idea is that when I just look at the state here, I know this is an initial state, right? So that is one benefit of labeled argument. The second benefit is you can use it in any order. We don't use it in any interesting fashion here, but that's the label. In it is the label and this is the actual type, right? Don't worry too much about it. I can actually remove this and nothing would be lost.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

But it's nicer to introduce these features incrementally as we go on. So the way you do labeled arguments is you actually write down the type here, right? That's the type side of labeled arguments. On the term side, when you actually write the function that takes a labeled argument, you have to use this tilde and that the variable name should match the name of the label, okay? And then you can use it just as a function.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

Is that I won't explain it further because I think it will take it away from what I want to do. Okay, so Sree-Sha, so in the bind, the beta, will in practice be the alpha itself? No, no, no, no. So the state will be the same, but the result of the computation could be different. So let's look at an example. So you're asking a good question. It is not necessary that the thing that you compute, right?

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

Alpha and beta are referring to, so let me make it clear. Maybe I'll just explain it before I go on. So the type of state is fixed, right? The type of state is a single type, but the result of a computation is different. So you can have a computation that can return, it's like a function return value, right? That can return a unit or a string or an integer and each of the functions can return different things. So that is completely fine.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

The thing that you cannot change is the state type, right? Of course, bind changes the type, right? So you take a computation that say returns a string, the state could be an integer, right? We are not talking about the state at all here. This is a computation which when run does something with the state, but returns a string. F could be a function that takes a string and returns the integer computation, right? And this whole thing is an integer computation. When you run this, you will get a pair of

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

whatever the state type is and this integer, right? So that is the idea. Does that make sense, Shreesha? Let's look at an example. I think all of these questions will become clear. Yeah, okay. So here is state, right? Okay, last question, but I really want to move.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So if we could change the type of state, then the return type would be, if you could change the type of state, then strange things will happen. Okay, so the return type would be not BU, right? T is just standing for the type definition here. When you want to return the state, when you want to change the state, right? This is no longer state to state function. Right, state is just a type variable.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

You can think of this one as some S1 state to S2 state. Does that make sense? So we actually fix the type of state in this module, right? There is only one state type we are fixing. But if you really want the computation to change the state, this will be some quote a quote S1, and this will be quote S2. And the idea would be that you will have three polymorphic, sorry, T three type variables here,

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

the initial state type, the final state type, and the result of the computation. Actually, we have an example in subject. I think we should do that next. It'll become very clear, but that's the idea, right? So it's not that you'll change the T. T is just a placeholder for a new type. The thing that will change is, T is the type name, right? So it won't be beta U. The thing that will change is these two arguments.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

So this will be some quote S1, and this will be some quote S2. We have, we are going to look at some examples like that. These are really good questions. So, but I think all of these will be answered in the rest of the lecture. Okay, last question I'm done. So you have state, I'm initializing the state with an integer, right? So the idea is that we have a monad now

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

which is specialized for just the integer state. You have all these functions put and get, which puts an integer and gets an integer and so on. Okay, so we have a module in state and I open the in state module. I'm defining very simple functions just to get the point across. So, incv, right, takes a value and then increments the state by v, right? I know this is an integer state.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

So what I'm going to do is to get the state and then put s plus v. Decv, right, decrements the state. So it gets the current state. Somehow magically get this, getting this value, right? Because all of that is hidden behind this monadic interface. We just get the current state and then we put s minus v which is decrement, right? And double gets the current state and then puts the double of that value. Observe that this is like,

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

although we are not naming the reference, right? There is only one reference in this world, in this world that we are defining. So this is as close to what you can ideally write, right? So get does not need to take a value because there is only one reference. We just get, you'll get that value and you can put. So all of the complexity of how we simulate this is hidden behind the interface. It is almost as if you are just programming with references except that you only have one reference here. So you can look at the type of this one.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

How do I do this?  Maybe the types are not useful. So I'll show you the type anyway. So, okay. So what I want to show is the type of increment, decrement and double. So increment, oops, okay.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

Increment takes an integer and then returns unit instead, right? The idea is that it takes an integer, increments the state, but itself does not return anything useful, right? It almost follows this integer, but the integer is not gone. It's actually in this in state one add, but the computation itself returns a unit. decrement also takes an integer, returns a unit. Double does not take any arguments, right? It just reads a state, doubles it, and then puts a state back.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

So it is a computation which just returns unit. Okay, so that's the idea there. Let me switch back to slide mode. Okay, so now let's use it in a program. So here is a program, right? I'm actually writing a computation using the functions that I've defined. So here is a program, I call it com computation,

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

which increments the current state by 20, right? Doubles it and then decrements the state by 10. So if you give it some state, it'll increment it, double it and then decrement 10. So I've defined a computation, right? So a computation is just alpha t. In this case, it will be unit t, right? Because decrement also returns a unit value. I have to actually run this computation.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

That is why run state is here. When you call run state with an initial value of 10 and the computation, what it does is, it first initial, the state is 10, right? So it increments the state, which gives it 30, doubles it, so goes to 60, and then decrements it by 10. So the state is going to be 50, right? When you run this program, the state is going to be 50,

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

and the computation itself returns unit, right? So this is a state value and we get a unit here because the last thing that we did is decrement and decrement is returning unit value, right? Questions on this. I hope some of the questions should be resolved, but further questions.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

Okay, looks like there aren't questions. So similarly, as I mentioned, right? So we are defining a single type mutable cells for a particular state. So if you want the state to be a floating point number,

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

you have to instantiate that with the floating point state. So we have a float state here, where I instantiate this functor with type floating point, right, and I open the floating point state, and I define a computation which gets the current state and then increments the state by 1.2, right? The current state will be floating point, and then I put B plus 1.2. So if the initial state is going to be 5.4,

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

the final state will be 6.4, right? So 6.4. The thing is we always return unit, but you can also return something more interesting if you want. So I know put returns unit, so let it be unit, and then I can do return hello world. So the computation itself is a string computation.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

So maybe I'll do it this way. Let it be this, so that you can see the type of the computation.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

So, so the computation itself now, oops, is a string float state dot t. So what that says is this computation is, this is, this comp is a computation, right? Which when run using run state is going to return a string. And the state type is whatever the float state dot t is,

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

which we know that it is a floating point number. That's the way you have to read it. So when you run it, you'll get a string back. So that is why we got a string here. And the state itself is a floating point number. So that's what you get by state here, right? Float state dot t is the state, and the result of the computation is a string. So of course the, so this answers, Suresha's question, of course the type can change

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

because the result of put is a unit, but we took a unit and this result is a string, right? We have to lift it up. So we are using return here because return is a value, a string value, we need to lift it up to a computation. That is why we need to use return, but that changes the type of the computation, right? So this one is going to return your state. This is actually returning a unit value.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

And this is a computation which returns a string. And because we are binding it all together using this let's start syntax, this whole computation returns a string. And that is what we have here. And that's why when we run this computation, we get a string out. Okay, so that should possibly answer some questions. I'll keep moving on because we are going to see a few more fun ideas.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

Okay, so this is what I did. So just to complete the discussion, right? So we started with this Fibonacci example and we defined the strip state, which took the input for the Fibonacci from the state and then wrote out the result of the Fibonacci in the state. We did this all this threading through and everything, right? Now, finally, because we've defined this as a monad,

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

this is essentially a state monad where the state is an integer. This function almost looks like Fibonacci, right? Except that you have returns and let's start, but otherwise there is no threading the state through and everything. State is being implicitly passed through. Again, here we used to thread state through, right? We need to, we got a state here, we threaded through to get, which we got out, thread it through to, which we got out and then we put all of that is gone.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So this is what you would call idiomatic code, right? So this is what you will write if you had to write it in a pure fashion, but there is an implicit state that is being threaded through. Yeah, this is just the Fib and so I'm calling Fib state computation, right? With an initial state of 10. So the final state will be 89 and the computation itself is going to return a unit value.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

The important thing is how the state is modified. So if you run it, you will see that the state is 89 and the result itself is unit. So that's the result of Fibonacci. Okay, so again to close the loop. So this definition also satisfies the Monad loss. I'm going to be right associativity for now, but this satisfies other laws as well.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So this is the right associativity law. So if you have a computation V, which you bind to just return, which doesn't have any effect, it just takes this value and then just returns the same state, right? The effect of that is going to be just the same as running the computation V. How do we prove this? You start with the definition, you expand the definition of bind first, right? You expand it in place, you just say funness, let S prime A equals VS, because that's what we do.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

We pass it through because this is a computation we are going to pass this initial state, right? And then that returns S prime and A, we call return with A and S prime. And you expand the definition of return for this Monad. So that is just the function, which takes the value of the state and then returns you the state and the value, right? So it takes a value, takes the state and then returns the same thing over.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

So if you substitute A for V and S prime for S, you get this term, right? All I've done is I've done beta reduction of this application, right? So you get S prime A, but if you just focus on this particular term here, right? So I'm calling some function VS, it is returning S prime A and I'm just returning S prime A here, rather than having a let

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

and then returning the same thing, I can just call the function VS here. This is similar to eta reduction. This is like very, very close, right? So this is like eta reduction for rather than writing it in the Lambda syntax, we are actually writing it in that syntax, they are equivalent. So you can replace this whole term, right? With just VS, because that's what we are doing here.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

We are calling VS, it returns a pair of values, we are just returning the pair of values in here. So by eta reduction, you just get VS and if you look at this one, this is classic eta reduction, right? So fun S arrow VS, so that is equivalent to just V and that's what we want to prove. So you can prove the other laws as well. You just have to do these simple beta reductions and eta reductions, you can prove it.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So why do we care about monad laws? We care about monad laws because then we can actually do program optimization, you can reason about properties of the monads and so on. Not every monad that everyone writes is a satisfies monad laws. This is like in practice, you can add certain features into monads which you think are sensible but will make the monad laws fail. The problem is that these are not expressible

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

just in types, right? You have to go somewhere beyond types. The fact that this term is equivalent to this term cannot even be expressed in types. You can only, you can test it by having particular instances of V but testing doesn't prove it, right? So unfortunately it means that in practice you have to be really careful about monad laws as well.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

We won't see too much about monad laws but I just want to interpret monad laws so that you are aware of it. Okay, so that's the thing about monad laws. Okay, so this comes to finally the thing that I want to cover in the rest of the lecture is the observation that few of you had which is the case that the type of state that we have is a single type, right? For integer you wanted to initialize it with integer type and you get a thing which is a computation

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

whose state is an integer. You cannot mix it with the computation which changes the state, right? This is a bit unfortunate because your state can only be unit type but it's also quite interesting how we can change the type as I hinted earlier, right? So you have to do something about the computation type and that's what we are going to look. The question that we are going to write our answer is

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

can we change the type of state as the computation evolves? So you might have a computation whose state type is integer and it changes the risk. It takes in an initial state of type integer and maybe returns a state of type floating point. If you think about, so this is the place where we sort of go beyond what we can do with plain references, right?

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

If you just had a plain reference, when I create a reference, okay, so the analogy that we were having so far is that imagine a world, right? Where you just have one reference, right? That is the analogy that we are doing. In OCaml, you can just imagine we create a single reference ref of zero, right? And ref of zero has integer type. It is not the case that this ref is now integer but I do some operation which changes the thing that is stored in the ref to be a floating point number.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

That's not a sensible thing to do, right? If you sort of take this analogy and extend it to here, what we are doing is quite strange, right? If you imagine there is a single reference, we are actually changing the type of the reference as the computation evolves. So in some sense, the thing that we are going to see here is more powerful than plain references, right? Of course, references in OCaml have other things, right? You can dynamically create references.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

The references could be of multiple types. We will do that in the assignment but this particular property that the state actually changes type as the computation evolves is not something that plain references in OCaml has, right? Okay, with that, we can actually look at how we are going to do this, right? So the trick is this, right? So in our computation type, we just had an alpha.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

The alpha represents the return value of the computation. It doesn't say anything about state. All it says is if you run this computation, you will get an alpha back. But now we have to reason about what the initial state is and what the final state is. And we want it to be generic, right? So we want the initial state to be some code p, right? For the starting state, the computation, when it runs, changes the state to some value of type code q

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

and produces a result of type alpha. So while the original definition of state one had a single type variable, we now have three type variables, right? Our computation has this type code p, code q alpha, code a. And the way to read this is that, oh, this code p, code q, code a, d,

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

a value which has this type is a computation which expects an initial state whose type is code p, right? It performs the computation and it returns a final state whose type is code q and it also returns some value which is of type alpha, right? So this alpha is the one that we had in the previous definition. These two are new. So these, you can sort of think about this as like a precondition and a post condition.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

So in order to run this computation, you need to supply an initial state of type code p and the final state, the post condition will be of type code q, right? So that's the setup. The thing that is going to happen here is we are going to have extra letters, right? But the structure of the state monad is the same, right? So we are defining a parametri state monad, right?

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

Which has three parameters, the type of the initial state, the type of the final state and the result of the computation. Suitably, we have to change the type of return and bind. So return takes a value, right, of type alpha. It is not going to change the state. So because it is not changing the state, it is not going to change the type of the state. So the state is going to be some mess initial state and the same as the final state because we are not doing anything interesting.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

And then the return type is going to be alpha, right? Earlier it used to be that it's alpha to alpha t. Now we have this additional parameter, which only says that whatever you pass in as the initial state, it will just return the same thing as the final state. Same type as the final state. So let is a bit interesting now, right? Because we are stitching together computations which might return different states, right?

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So the thing that we want is when we put them together like this, these two should match, right? Whatever the result type of the first computation, sorry, the result state type of the first computation should match the input state type of the second computation. So that is what we see here. So we take the first computation which changes the state from R to S, right? And returns an alpha.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

We take a function which consumes the alpha and returns a state, returns a computation whose initial type is S. So this S and this S matches, right? So that's where we are sort of putting them together so that the states match, right? And itself is going to return some state of type T, right? And the result of that computation is beta.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

Then when you put them together, right? What should happen? The initial state should be R, right? The final state should be T. And because the computation itself returns a beta, the whole thing returns a beta, right? So because the initial one is R, for the composed thing, the initial one is R, since the final state is T, the final state is T, and because the second computation is returning beta, this computation, the thing that you get

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

as a result of putting them together also returns a beta. The thing that it should match here in the state is the same reason why these two types should match, right? Because this is a computation that returns an alpha, this has to be a function that accepts an alpha. And similarly, because it's a state that is of type S, this has to be a state of type S as well.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

Okay, so that's the static side of things. So the functions themselves, right? Get and put are going to look, are going to have a little bit of interesting, right? So let's look at get. So what does get do, right? Get only returns you the current state. It can be applied to any state, it doesn't change the state. It just returns you the current state as the result of the function.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

So let's assume that the state that is passed in is S, right? It is not going to change the state. So the thing that comes out is also S and it is going to return the state. So that is also going to be S. So get is a computation that is a SSSD, right? That's the input state. It's not going to change the state. And the thing that it returns is the actual current state. That's that. Put takes in some S prime, right? That's going to be the new state.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

And the result of the computation is that we don't actually care about what the previous state was. I'm not even going to name it, right? It's undefined because what put is going to do is to actually change the result state, right? To be of the same type as the argument. So if you give a new state, which is an integer, then the resultant state will be an integer. The initial state could be string or something. It doesn't matter.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

We'll just say that now this computational return and integer. And the result of this computation, when you evaluate it, the thing that you get is a unit because it's not returning anything useful. And run state, what does run state do? Given a computation which accepts an initial state of type S, returns a final state of type T and returns a value of type A, right? And you give it the initial state of type S.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

So this S and this S matches. You will get a pair of the final state and the value. So the final state is T. So you get T here and the final computation is alpha. So you get alpha here, right? So that's the story for the additional functions for parameterized monad. Okay, so I need to run this thing. And actually there is nothing interesting here. This definition is the same as what we had.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

The function definition itself, right? It's the same as what we had earlier. Except that we no longer have to, it's not a functor. It's just a module definition. We don't take the type as an argument. While the state monad definition was a functor, p state is just a module. We don't need to specify the type. Type just works out. We'll see how that works. But these functions, right? They are exactly one-to-one compatible. We are just playing games with the type.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

There is nothing else going on with the actual way in which these functions are constructed. Which is quite curious, right? So we play a lot of games with just the type. Okay, so we get a p state. Now here is some interesting functions, right? So we open p state, increment, decrement and double are what we had seen earlier. So get an increment just puts a new value which increments the value double, gets the current state and puts a new state

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

which is a double, right? And then we have additional functions. These are going to be special. So two string takes the current state which it expects to be an integer, converts the integer to a string and puts the state which is now a string, right? It is now converting the state from integer to a string and off string reads the current state

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

which it expects to be a string, right? Converge that to an integer and then puts the new state which is now a string. The state has now changed. So two string expects the initial state to be an integer, final state is a string, off string expects the initial state to be a string and then converts that to an integer. This will be apparent when you actually see the pipe,

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

right, two string expects the state to be an integer, finally the state to be a string, off string expects the state to be a string, it changes the state to be of type integer, right? Okay, so we've done that. Otherwise these are like not interesting. So they just expect, they don't change the type of the state, the type remains the same. So now you can write some interesting computations. So foo is a function which increments five

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

and then converts that to string, right? Whatever state is, so the initial state expectation is that it should be a string, increments and then converts that to a string, bar gets the string, right? And then as suffixes zero, zero string, right? To be any string, it just suffixes that to be a zero, zero string. So I define bars as a composition of foo and bar, just do foo first and then do bar, right?

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

So this is an int to string computation, right? The changes the state from integer to string, this is string to string, bar is string to string. So these two types match, right? Int to string and string to string, string string matches. So that's fine. Yeah, if you do this, then int to string, string to string. So when you put them together, you get integer to string, which is what we have in BaaS, right? If you give it integer, it returns a string.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

Actually, you'll see that it also works out. So why do we get the string 1000? We increment five, right? Initial state is five, we increment five, so that is 10. And then we do bar, which adds zero, zero. So when you add zero, zero to 10, you get 1000. So the thing is, you can attach foo to bar, but not bar to foo, right? Because this return type is a string and this type will be an integer. These two will not be compatible.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

So we can see that that is the case. If you start with bar and then attach that to foo, bar return type is a string, this expects an integer. So you cannot put them together. So we get a complaint in foo saying that this expression has type int string unit, right? That is what we have in string and itself does not do anything interesting.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

But something is expected of type whose initial state is string. So all it is saying is the types don't match when you bind them together. So it is expected that this has to be some computation that whose initial precondition is a string type. This is quite important, right? So we are sort of manipulating references by type, but the fact that we are tracking the state type as part of the type itself,

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

that is what lets us actually write this program safely, right? So even though this changes the type of the state, the fact that we know what the type is still maintains type safety. You cannot do this. So without going through other mechanisms, you cannot do this with OCaml references. When you create references in OCaml, they're going to be a single type,

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

but we are doing something quite interesting here. I will cover this. So we put in a lot of effort to build all of this. Okay, this is fine. I mean, we are doing something interesting. What is this useful for? So the last thing that we will see tomorrow is we will build this thing called a well-typed stack machine. I don't think you would have seen a stack machine so far,

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

but imagine writing a calculator in postfix notation, right? You convert an integer expression to a postfix notation, and then you can use a stack to evaluate. I assume I'm sort of making sense. When you have say five plus six, if you convert to postfix, it would be five, six plus, right? So you can use a stack like, oh, push five first, then push six. Then if you see a plus, the operation that you should do is like

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

pop the first two elements, add them together and push the result back, right? This is what a stack machine is. So you sort of write the interpreter as a thing that manipulates the stack. So you have an explicit stack where you push and pop. So the thing that, calculator is fine, right? So calculator is okay because you're operating on integers and the types are fluid. But if you sort of imagine real programs, right?

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

Where you have in string, off string, say call a function and function needs multiple arguments and so on. You cannot, you have to have some guarantees about type safety of the stack machine. In particular, stack machine is what a standard model of computation for many languages. Java, for example, right, is a stack machine.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

So the abstract model is that Java emits, when you compile a Java program, it emits some byte code, right? And the byte code is a set of instructions which manipulates an abstract stack. So it says push a value into the stack, then push some other value into the stack, now add the values or if it needs to call a function, it says that push n arguments into the stack and push the function and it will have an instruction called call five say, which says the first argument

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

should be a function. There should be five arguments whose type should match the five function arguments and then you call this function. Of course, I am saying there should be, the type should match, but these are not, these are not checked at runtime, right? Java makes type checking at a compile time and then has this implicit safety guarantee. We saw this type soundness and type safety guarantee, right? Once you know that the program is type safe,

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

then if you compile it down, you don't need to carry around the types, the types can be erased, everything is fine. But interestingly, right, there is a thing called WebAssembly which you should certainly look at. So WebAssembly is this new virtual machine instruction set for the web. So today if you want to write something that runs on the browser, it has to be JavaScript. Actually I'm lying a bit because WebAssembly is part of all of the major browsers.

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

So WebAssembly is a small interpreter. So we've been writing interpreters, it is also an interpreter. It has a instruction set, which is not as low level as say x86 or ARM or RISC-V, but it's still an instruction set. The instruction set is a stack machine, right? And the idea is that it is a really good target for compiling C, C++, OKML, Haskell, Scala, Java,

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

all of these languages so that they can run on the browser. So it's a really interesting project. We should certainly have a look, there is a link. If you click on this, this will go to the link. All major browsers support it. So the idea is that you can write a C program and actually run it efficiently on the browser. So the WebAssembly has an operational semantics. Semantics, the dynamic semantics that we had seen in all of these lectures is operational semantics. And WebAssembly has a very specific operational semantics,

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

which says very something very special about types. Because you are compiling C to WebAssembly, you don't have this guarantee of type safety. C doesn't guarantee type safety, right? But you are running it on this WebAssembly interpreter that is sitting in your browser, right? And C, I think you will study some of this in the operating system lectures, but also security lectures. C is very unsafe, right?

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

You can write C programs, which if you have, say vulnerabilities like buffer overflow and so on, you can exploit things that are in your program, in your process. So imagine this world, right? Where you have WebAssembly running in one tab and you have your bank account open in the other tab. And you compile C to WebAssembly. If WebAssembly sort of runs everything deliberately, right? So the problem is that there is no safety at the point.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

You can run some C program which you thought was safe, but it can read your bank account information, for example. This is not what happens, right? This would be a terrible idea. People who write web process are really clever. So they have this very nice property that anything that runs on WebAssembly has a type safety guarantee. And there is type safety, not on the source level, but actually at the byte code level, right?

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

Just like WebAssembly, sorry, just like Java compiles to a byte code. WebAssembly is just a stack machine. It's just a couple of bytes, sorry. It's a list of instructions which operate on a stack machine. So what you need to do is to say that whatever program that you run through these stacks will not ever set fault essentially, will not break type safety.

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

This is a very, very strong guarantee. This is quite critical because you can be complaining arbitrary programs to run on WebAssembly. The way this property is enforced is through a well-typed stack machine. Why did I say all of this? We are going to use this parametri stack component to define a very small well-typed stack machine. So this is going to be a stack machine which takes a couple of instructions, but will never go wrong.

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3294.0s_

So the shape of the program will tell you exactly the type of the stack that you should have, and it will never go wrong. So it will never get stuck. It will never do anything bad. It's a really interesting thing that we will see tomorrow. I've already taken a lot of time. Apologies for that, but we will look at this tomorrow. Then we'll close out the section on Monads. Thank you very much.

---
