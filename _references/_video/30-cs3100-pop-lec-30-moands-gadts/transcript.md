# 30-cs3100-pop-lec-30-moands-gadts

**CS3100 POP - Lec 30 - Moands + GADTs**  
id: `lOsA5LJsGGI`  
duration: 3210s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay. So the last thing that we are going to see in this one-hand lecture, so we built up a lot of infrastructure, we've sort of prepared small examples. This is also going to be a small example, but I think the hope is that I want to give you something that

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

allows you to do a certain property which wasn't possible if it weren't for monads. So let's put it that way. So what we are going to do is to define this well-typed stack machine with just three instructions. So we are not going to consider a complicated stack machine, we are going to consider a really simple stack machine that only does three instructions. So it can push a constant of any type on the stack, it can add two integers on the stack

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

and push the result and it has a conditional operator called if and what it does is it expects a Boolean to be on the top of the stack and value for the true case and the value for the false case. And if B is true, then the stack will be modified such that it will be the value one, the true value and the rest of the stack. If B is false,

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

then the stack will be changed to have B2 on top of the stack and the rest of the stack. So this is the setup. So what are we going to do? What's the high-level idea? Imagine you have a stack like this, where you have a Boolean and then say two integers and if I call add on this, this stack machine gets stuck because you cannot add a Boolean and

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

an integer. Add expects two integers on top of the stack and adds it and pushes the result. But if you have a Boolean and an integer, add will get stuck. So this notion of getting stuck is very similar to the type safety and getting stuck that we had seen in Lambda calculus. So there is no reduction possible, but we are not in beta normal form. So we are not yet fully evaluated to a value. So that's the idea. We are going to sort of use the same

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

intuition here. What we are going to get back is you will write a program using these three instructions, which will exactly specify the type of the stack that it expects to run. And you will also be able to build a stack which will exactly represent in its type what the shape of the stack is. And only if the expectation of the shape of the stack matches

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

the stack that you are providing, will the program even type check. So this interpreter will only allow you to interpret programs that has the right program whose stack shape matches the stack that you provide. Everything else gets stuck. So this is type safety for a stack based language. And this is how WebAssembly operational semantics is defined. So I had shared links about WebAssembly. You can have a look at it in your own time. But let's focus

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

on these very simple instructions in this class. And in order to do this, we are going to use the parameterized statement. So that's the connection between this part and the things that we've seen earlier. So as I mentioned, our stack is going to contain values of any type. So we cannot use a list for this purpose because all the values in the list are going

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

to be of the same type. We cannot have mix and match values. So instead, what we are going to do is that if it's an empty, we will just use, say, the unit type. If the stack is going to be one on top of the stack followed by two followed by three, we are constructing, we are representing that with the tuple, which has one, two, three, right, enclosed this way.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

So everything is a pair, just a pair. So the value is a pair with one as the first component and a pair as a second component, where two is the first element of the pair. And the second component is going to be a pair, where three is the first component of the pair. And the second component is going to be unit. We are just using everything as a pair.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

And this idea is isomorphic to the one here, right? The notion of a pair here is the cons constructor, which takes a value on the tail. Here, we take a value and a pair or unit value as a result. But what is the use here? So you cannot write this expression in OCaml. And it doesn't type check, right? This is a list with an integer, a Boolean, and an integer. This is not a well-typed expression. But in our encoding this way, where we use pairs to

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

encode everything, right, this is a fine expression, because this is a pair, which has one as the first element, and a pair as the second element, and the pair happens to have the first element as true. So this is completely fine. So this is the reason why we encode the stack using pairs. Questions on this encoding?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

No questions? Okay. So let's continue. So what do we want to do, right? At the high level, I have some expectations from these operations, right, the operations that I do on the stack

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

about what stack can I operate on, right, the shape of the stack that I'm going to operate on, and the shape of the stack that I will return, right? So we encode that as just the type that we used with parameterized monad. So parameterized state monad, parameterized state monad, just to recall, has an input state s, right, and the computation in a parameterized state monad has three components,

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

right, it's a computation that expects an input state of type s, outputs a state of type t, and the computation itself returns alpha. So this is the idea. In our, in this well-typed stack machine, alpha is always going to be a unit, it is going to be uninteresting. The things that are interesting is

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

what is the precondition for the shape, the state and post condition for the state. And what we do is we use the pre and post condition, right, to represent the shape of the stack on which we can operate on. So our stack will be the state, right, and we will give it a particular type, which will constrain the shape of the stack. What do I mean by that? So what does add do? Add expects two integers on top of the stack, and if both are integers,

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

it adds them and then pushes an integer on top of the stack, which is the result, right? And what does the type say? So the way to read this is, this is the s component, this is the t component, and this is the a component, and a is always going to be unit. So add says that, give me a stack which has an integer and an integer and anything else on the stack. I don't care about the rest of the stack,

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

but the thing that I care about is that the first two components are going to be integers, right? That is the state of this state that add expects. And the result is going to be a stack which has an integer on top, right? That's the result. And the rest of the stack will have the same shape. So if it is code test, this would be code test as well. I'm not specifying what the rest of the stack is. The only constraint I'm doing is by using the same variable here, I'm saying that the type of the rest of the stack is the same.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

Okay, so this is how we encode the properties. So we say that the shape has to be two integers on top, the result shape will have a single integer on top. And let's look at another example. So this is if I'm using underscore before and after because if is a keyword, we cannot use if as just a plainness because that would complain.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So if expects a Boolean on top of the stack followed by two values and the two values must be of the same type. So the reason is exactly the same as what we do for OCaml, right? The left, the true and false branches should have the same expression should have the same type. And for the same reason, it could be of any type, right? But it has to be the same type. And if you execute if on the stack, then you'll be left with one value of type alpha. Right? This could be either of these values, but you'll be left with one value.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

And the rest of the stack could be anything. But if guarantees that the shape of the rest of the stack remains the same. And finally, there is push constant, right? Push constant takes alpha as an argument. So you take an argument and then you push it onto the stack. It can operate on any stack. Right. And what you are left with is a new stack where a value whose type is alpha is on top of the stack.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And again, the actual return value of these operations are not important. So they return unit. OK, so that's the definition of the stack operations. So what we're going to do is to use parameterized monads for this parameterized state monad for this.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

Yeah, so we've seen all of this earlier, except that there is something going on with sharing here where we use colon equals rather than equals. I'm not even going to explain what this just take it and run for now, because I think it's it's not a useful idea to have. Rather than rather than saying run state, we have something called execute, right? Which takes a stack.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

Sorry, which takes a program. Right. Which expects initial stack returns a final stack and then returns an alpha. You give it the initial stack of type S. It will return you the final stack and the final value. The value is always going to be unit, but it's just I don't. Anyway. Right. So that's the execute function. This is analogous to the run state function that we had seen earlier.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

There are lots of other things. These are all the same things that you had seen earlier. In the previous slide, what is the difference between code A and code T type in the previous slide? Where is this code A? So this is code A. Right. And where is the code T? This T. It's. There is no code T. I'm just.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

You clarify what you mean by code T here. You can unmute and speak if you want. Inside the parentheses. I can't find the. OK.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

Sorry. Sorry. So these two happen to have the same name, but they have no relation at all. So this is a type variable. Right. This is a type. These two live in two separate namespaces. There is no relation. I could use another type. Should also work. Yeah. So thanks for asking that question. I think they just. They live in two different universes. They happen to have the same substring, but they are not the same thing.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

OK. So. Yeah. OK. So we have execute here. We have add if and push const. There is also the usual operations for the monad, which is return and let's start. Right. And then we have. The usual type for the parameterized type one. You've seen all of this. Right. And the only thing that we've added in this slide is execute. OK.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

So how do we. So we've just defined the type. Now we have to define the actual interpreter. Right. What happens when you do add or what happens when you do it. So that is what we do here. We define a. Module called stack. Right. We just state stack. Just to clarify stack. Stack is just stack monad. I just name it as stack monad. And.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

It includes the all the operations from parameterized state monad and additionally provides for operations. The three instructions that go on the stack right that manipulate the stack and one for executing. The program and the stack. There is no type annotation here. The types just work out. Right. So it's a little bit. Handy. The operation semantics is very simple. Right. So yeah. So you can think of this as the operation semantics. Right.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

Just like we wrote the dynamic semantics for Lambda calculus. We are just describing what the interpreter does. And all it says is oh you have a function called add. If you get the current stack because of the type we know that X and Y. Will be integers. Right. And what you put back is X plus Y on the stack and the rest of the stack. So you take you expect.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

One integer X another integer Y and some rest of the stack. And what you push back is. Compute X plus Y and then push it along with the rest of the stack. Right. So you get done put. And similarly for if you expect a condition you have a true case. And the false case and the rest of the stack. When you get that you get the stack. Right. Because of the type constraint that we have. We will get this particular stack.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

When you what you push back is you actually evaluate this expression. You say if C we know C is going to be a constant. Right. It is going to be true or false. If it is true then you get the back. Or you get back. And you create a new stack with that value on top and the rest of the stack and you put it back. So finally you have push constant that simply gets the stack. Takes the scale which is the constant that you're pushing.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

And then puts the new stack in. Right. And execute is just a proxy for run state. So with the initial stack and then the actual program that you are writing down. The computation here composes of only three instructions. Right. The programs that you can write in this small language include these three instructions. But you can imagine extending this with arbitrary instructions. OK. So that's the stack.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

Now let's write a very small program. So what is this program do this program is a program that manipulates the stack. And in particular the program first pushes a constant for then pushes a constant five. Then pushes constant group. Then executes if. The shape is going to be right right. So it's going to see true.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

So after executing if the value that will be left on top is going to be five.  And then it performs add. So if you look at look at just this program fragment right. It doesn't say anything about what is underneath the things that we pushed. But because you have an ad here. And after the execution of if you'll be left with just a single integer on top. In order to execute ad it must be the case that the initial stack that is passed into this program.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

This particular fragment of the program should have an integer on the top and the rest of the stack would be anything. The that's the expectation. Right. So that's the guarantee that you want from the input stack in order for this program to execute. Otherwise this program will get stuck. So let's see how that works out. If you just run this you will get a nice type.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

And what does this type say this is weekly polymorphic that is not important. It just says it is some stack. But the program particularly expects and guarantees two properties. There is a precondition and a post condition. The precondition says that give me a stack that has at least one integer on top. And the rest of the stack would be anything at all. I don't care. Right. And what it guarantees is that it will leave an integer on top and the rest of the stack will have the same shape.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

It is the same variable so it has the same type structure. It has the same shape and the program itself returns unit that's not at all important. And you get a computation which operates on the stack. But you also have pre and post conditions for executing this program. So why is this important. So this sort of restricts the shape of the stacks that you can run this program on.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

For example this program cannot be run on an empty stack because an empty stack does not have an integer on top. When you construct an empty stack you will see that you get this type error. So you get a type error which says that this expression has type unit. But an expression was expected of in star week one. It expected an in star week one as the precondition for the shape of the stack.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

So high level. What is it guaranteeing. It is guaranteeing that because the program that any program that you write will ensure that the shape of the stack is going to be the same as what the same as what the shape of the stack is.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

There is an expectation for the shape of the stack and it has to match the stack that you executed on. You have type safety. The program will not get stuck ever. That's the guarantee that you get. And you can also and here is a working example. Here is a stack that has a 20 on top that satisfies the expectation of what the program expects. And it also has some other things which the stack is not going to touch.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

So when you run this, right, you get the result 25. Why is this 25? You get 20. Right. And this three instruction evaluates to five. And then you finally add five to whatever is on top of the stack. So you get left with 25. And then the rest of the stack stays the same. Right. So that's the that's a working example.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So there are also other examples you'll find. Right. So here is an example, which is if right if expects what is it expect it expects a Boolean on top followed by two values of the same type. But here, if you observe the stack here, it has a Boolean on top. It has an integer. The next one should have been an integer. This unit type should be an instar something. So this stack does not satisfy the precondition.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

So this gets a compiler error. The compiler just says you cannot run this program on the stack because the expectation is that you need an integer. It is not there. And similarly for add. Right. So if you say and on an empty stack, it will just because that expects two integers on top. So this is this is one. I think you can also

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

so let's do this. It's not under store equals add in. Let's start So this program will be statically rejected. Right. So we've only seen examples that fail because the stack is not compatible with

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

the program, but it can also be the case that the program itself might not be compatible. The reason is that if you look at this program fragment. Without considering even the stack, this program cannot be executed because when you execute add. Let's just look at how the type checking works. I'm having add first. So add expects two integers on top. So that is sort of refining the precondition and it's going to leave an integer on top. Right.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

But if you look at if if is going to expect a Boolean on top. Right. The thing that is left by add on top is not the thing that is expected by if on top. So it it does not type check the program itself is ill formed. Right. It gives an easy way of type checking the programs also. So I mean there is a big error. But the important bit is the type bool

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

which is expected by if is not compatible with type int which is left by add on top. Yeah. Okay. So that's the well type stack. You can imagine extending this with arbitrary instructions. Right. The same set of rules and see the whole WebAssembly interpreter which happens to be written in the specific specification and the reference interpreter which happens we return in OCaml. It's sort of built on the same principles.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

Every operation has a stack and there is an expectation of the shape of the stack. And this is how it is built. And hopefully that would have given you some idea of how how to use these things in real. So any questions and that's all I have for the Monad lecture. Any questions.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

Okay. So that doesn't seem to be any questions. If you have questions ask me on Slack. So what you will be doing in the assignments.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

The programming has a next programming assignment is you take the state monad not the parameter is that monad the state monad and extend it so that it you provide the ability for creating fresh reference variables. Read and write of these variables. The variables could be of any type. So you add the ability to do freshness and at that point your program that you simulate the interpreter that you're simulating right is

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

has the same expressive power as OCaml itself OCaml reference references. Anyway, so you'll see when the assignment lands. Okay, so that was Monads. And let's move on to the last OCaml

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

picture. So after this what we'll do is we'll shift to doing logic programming. Okay, so let this start. This is a long lecture. Okay. So we've seen algebraic data types right.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

types that we've sort of seen throughout the lecture. There is an extension of algebraic data type called generalized algebraic data type. Of course, as the name suggests, it's a generalization. It sort of extends algebraic data types in very small fashion. Right. So actually the extension itself is sort of some syntax some things that you have to do. But the applications of this

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

extension is quite powerful. Right. So the the lecture is going to be on this idea of generalized algebraic data types also on a GADT because the name is quite a mouthful. The syntax and semantics of this extension is quite simple. It's just a new way of defining new data types. But the applications are quite vast. So we are going to be

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

going to see lots and lots of examples in this lecture. It will be a hopefully it will be an entertaining one. Yeah, so just like we did in the last lecture, right, where we sort of started with an interpreter and then we slowly said, Okay, how can we extend this interpreter to handle division by zero. We again start with some interpreter for a language will go off in a different direction. Okay.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

So we are going to write another interpreter again. And in this interpreter, we have something interesting. We have two values. Okay, so we have a value definition and an expression definition. This is the standard way you define formal languages in the programming languages area. So languages, values and expressions. OCaml also has values and expressions. Similarly, our language also has values and expressions. We have two kinds of values.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

We have an integer and a Boolean. So I use constructors int and bool to create a value which contains an integer and a Boolean. And there are expressions. The expressions are every value is an expression. Plus is an expression where it is parameterized with two expressions. Multiplication is an expression, right, where it is parameterized with two other expressions, which the idea is that you would want to multiply these two expressions.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

And then there is if then else if then else takes three expressions, right? And the hope is that this first expression is a Boolean expression that is a Boolean. And these two expressions could be anything, right? Could be integer or Boolean. We don't care. The idea is that if you evaluate this expression and it evaluates to prove, then the result of evaluating if then else is this expression.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

Otherwise, it is the second expression, just like how if then else works. Nothing new here. It's just a matter of writing down these types. So we've written down these types and looks fine. Let's write an interpreter for this language. We call it evaluator, but it's interpreter. Both are both are the same. So this interpreter is a recursive function. I call it evaluator. So I've written it explicitly using anonymous functions because it makes it easy for the subsequent lectures, but there is no reason to write it this way.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

I could have just written electric eval e equals something. I also made the type annotation explicit. Only because this will make it easier for the rest of lecture. Type annotation is not necessary. So the type annotation could be ignored and it just works. But let's go with this for the moment. What does the type say? Eval is a function that takes an expression and returns a value.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

So take a large expression, you reduce it down to one of the two values integer or Boolean. So what do we have here? You pattern match the current expression. If it is a value already, then you simply return the value. It's an integer or a Boolean. Both of these are of type value. So you just return the value. If it is a plus, then you evaluate e1 and you evaluate e2.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So we know that plus expects two integers. So let's just write it down explicitly as int i1 int i2. Eval e1 gives int i1, eval e2 gives int i2. And then the result is going to be int of i1 plus i2.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

And similarly for multiplication, same thing except multiplication, we do a product here. And then if then else, if then else is here, we evaluate p, the predicate. It should evaluate to a Boolean. And then just put it in if then else such that if b then evaluate e1, otherwise evaluate e2. So this is what we should expect to write. But you can see what will happen. So when I run this, there are a lot of warnings. There are no errors, but there are lots and lots of warnings.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

So I'm just making it smaller so that you can see the warnings. So what is happening here? The warnings sort of seem to say that pattern matching is not exhaustive. This is the root cause.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

You and I know that plus expects two integer expressions, expressions that evaluates to integer values, and it is going to produce another integer expression. But the evaluator itself doesn't know. When you evaluate e1, we are pattern matching that with int i1. But the type just says that it is a value. It doesn't say it's an integer value. So the pattern that we are missing here is bool.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

We should also handle the case that it might be a Boolean. And similarly for this pattern, we are only pattern matching with integer. We are not pattern matching with Boolean. Actually, there should be four cases. Evalu1, evalu2, int int bool, bool int, and bool bool. All of these are sort of ill-typed expressions. They are not expressions that are well-formed, that don't make sense. But the evaluator still has to handle those cases. So it still has to pattern match and handle those cases. We are not doing that.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

The warning is valid. The compiler warns that the program such that 2 plus 10 is not handled. The first, the left-hand side of the plus may be a Boolean expression. I'm only pattern matching with an integer expression here. This is being pattern matched with integer. It could be a Boolean.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

The warning is there for a reason. It's there for a very good reason because there is no pattern that matches this particular expression. Let's just look at this expression. The expression says that it is essentially true plus 10. It is true plus 10. It is the expression that I passed through the evaluator. I am asking what is the result of doing true plus 10.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

The point at which it will fail is it will go through plus and it will start evaluating these two expressions. True will come out of this. It is a Boolean expression which is not pattern matched. When you don't pattern match those expressions, you will have an exception called match failure, which is what we will see here.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

At runtime, this fails. Compiler rightly warned us that there are missing cases that we have not handled. When you evaluate these expressions, which abstractly get stuck, there is no way to evaluate this expression further. We don't have a pattern there. There is a match failure. There are no pattern matches which match these things. We have a runtime error. This is not great. We know for a fact that we can only get integers here. Those are the only ones that are well formed. Everything else is an ill-formed expression.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

See what we are missing is types. If we had types for the simple language. I am not saying types for okml. I am saying types for this language. This language itself does not have any types. It just says expression expression. It doesn't constrain this to say integer expression. Expression that will yield an integer or this expression should yield a Boolean value. That is what we are missing here. Our language here is fully untyped. We should add types here somehow.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

That is the reason why our program gets stuck. We know that well-timed programs do not get stuck. If you make the term language have types, then our evaluator will never enter into the level. Have these warnings in the first place and also not have match failures.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

That is where we want to get to and that is what we will do. Before I move on to that, any questions on this one so far? So far we have not seen the arities. We are just looking at things that we know already. I will move to this slide.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

Ok. Seems like there are no questions. So let me move on. So what we have seen is if you simply evaluate this untyped expression language, you get into these foreigner cases which you have to handle.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

But we have not handled here. Ideally this is what I want to write. I don't want to write all of those other cases. Because I know for a fact that they are not well-formed. I also want to rule them out statically. Just like how we have been emphasizing throughout the course so far, we don't want them to even be able to be constructed.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

You want this expression to be ill-typed. So you shouldn't even be able to construct this, let alone evaluate this. That is what is the problem. Let's try to add types. So this is an orthogonal concept. This is not related to GADTs. But it sort of is a nice segue into GADTs. So there is a concept called phantom types. Again, just a name. The idea is quite simple.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

So let's just look at this type definition. We say that there is a type alpha value where the values are int of integer and bool of boolean. The thing that you should observe here is this cote appears on the left hand side, but does not appear anywhere on the right hand side. So we have seen types of cote earlier. List is also a cote type. Type cote list is nil or fonts of alpha star alpha list.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

There the alpha appeared both on the left hand side and the right hand side. Here alpha only appears on the left hand side. So such type variables which only appear on the left hand side of a type definition are called phantom type variables. It is the upper root of no and they are sort of there. What are they useful for?

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

Because they are not relevant to the values that you are constructing. The idea is that you can specialize this type variable to anything that you want. It does not matter actually. But you can use it for the important reason, which is what we will see here. So here is how I extend the expression language with a phantom type variable. Actually not a phantom type variable here, but a type variable alpha.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

Such that I can add the types to my expression language. Earlier it used to be that it is a type expression. Now it is a type alpha expression. And what does it mean? You can construct a value of type alpha expression. If you have a value which is an alpha type. If you have an alpha value, which is what we defined in the previous slide.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

If you have an alpha value, then you get an alpha expression. For plus, we explicitly constrained the alpha to integer. This is what we want. We want to say plus can only be applied on expressions that will yield integers. By explicitly instantiating this alpha position to integer, we are saying give me an integer expression. Give me another integer expression. Then you can construct a plus.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

So in order to construct a value of this plus, you need to integer expressions. Similarly for multiplication. Give me an integer expression. Give me another integer expression. I will put them together to construct an expression which is a product of those two expressions. And finally, I have the same idea for if-then-else. The condition, the predicate should be a Boolean expression. It should be an expression that evaluates to a Boolean. And the two cases could be of any type. I don't care. They should just match the type. This alpha is the same as this alpha. They should be of the same type.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

And if they are, then you can say that if-then-else is well-typed. Questions on this one?

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Okay, so that seems fine. So what we've done is we've added this phantom type variable to value. Just to say that what we will do is we will say that the thing that you construct out of an integer is going to be an int value. The thing that you construct out of a Boolean is a bool value. Once you have annotations for types for values, then the types for expression is defined based on types of values. So that comes out naturally.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

So let's see how that works. So here are some helper functions. So when you use phantom type variables, because the alpha is not constrained by the right-hand side, the construction of values does not constrain the alpha. So you have to explicitly constrain the alpha according to your own needs and rules. So our need and rule is that whenever we construct an integer value, it has to be an int value.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

Alpha has to be specialized to an integer. When you construct a Boolean value, the alpha there has to be constructed to a bool type. And similarly that extends for expressions as well. So I define helper functions called makein that takes an OCaml integer. And then all it does is it constructs an expression with a value constructor, an integer constructor. And it says, okay, this is going to be an integer expression.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

And I explicitly type, assign the type of this to an integer expression. This is what is actually constraining the type and instantiating the type. And similarly, I define a make bool, takes a Boolean, I construct an expression, which is just the Boolean value, and I explicitly give the type Boolean expression.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

I ascribe an explicit type Boolean expression. And similarly, I do it for plus and multiplication. Actually, this is particularly not necessary because, okay, actually, I need it. So I also give it the type for integer expressions. So sorry, plus and multiplication. I say when you construct a value with this plus constructor, the type that you get is going to be int expression and multi expression.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

So this is how you force the phantom type variable to take a particular type, a concrete type. So if you run this, you'll see what the types are. So makeint is a function that given an integer returns you an integer expression. And similarly, plus is going to be, give me two integer expressions. And I'm going to give you an integer expression out. These are like adding types for our terms, essentially, right? We are making our language more typed.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

So question, I have explicit type annotations here, right? If I drop the type annotation, what will be the types, inferred types? So OCaml will infer the type, right? It's not necessary that it infers, does not infer the type. Let's just look at this one, right? Let's look at this makeint prime, I, val int type. So observe that the type of this one here is an int to int expression.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

If I drop the type annotation, what is going to be the type? So it is certainly an int to some expression, right? What is this? What is this type variable? Any answers?

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Yeah, that's right. So good. So I think you are getting the idea. So this will be, this will be not unified. There are no constraints on this, right? We have not added any constraints. So it will be an alpha expression. And similarly for this one, this will be an alpha expression. For this, this will be an int expression to int expression. Why is this int expression int expression? Because if you look at the constructor for plus, it says I want two int expressions, right?

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

But the result type is not constrained. Oops. So it is going to be an alpha expression and similarly for the multiplication. So if you run this, that is what you'll get. Right? So we get this typo. So the point is we are using these helper functions in this clever way, right? These helper functions in a clever way to force our types. We are saying, okay, I know when I construct an integer, this is going to be an integer. So I use this helper function to force the type.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

But the constructor itself does not constrain the phantom type variable in any way. Good. So I think you are following the lectures up to this point. Okay, so that's fine. So how do we use this? Right? Just like we saw before. I am. These are just examples. So when you do let I val int 0.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

And here I'm doing let I prime make int 0. Make int is the same as this one except that the type is constrained. So when you run this, you will see that because the type, the phantom type variable is not constrained for I, it is going to be an alpha expression. And because I prime is using make int where we constrain the return type, we actually ascribe a particular return type.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

We get an integer expression. And similarly for boolean and plus. So when you don't give it the type, when you directly use the constructors, you will have alpha expression. When you use this helper function make bool, you get a boolean expression. And similarly for plus, right? Without directly using the constructor, you get an alpha expression. If you use the helper function, you get an integer expression. Okay.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So what is the benefit? Right? What is it? So this is fine. What is the benefit for the program that we are considering? So we no longer allow this is true plus n, right? True plus 10. So we no longer allow this expression to be well-typed. So make bool returns a boolean expression, but plus expects an integer expression as an argument.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

So this term is even in type. So just like in OCaml, you cannot, in OCaml, right? If you do true plus 10, even if you don't evaluate it. Yeah. Okay. Complaining the first error, but not the second. Maybe I'll do it. So if you do true plus 10, the type checker is complaining at the position true, right?

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

It says true as type bool, but an expression was expected of type 10 because of this plus. In the same way, now we have added a type checking capability for our domain specific language. I thought I shouldn't use this term, but what we are defining is we are defining a small language, right? And we are adding type system. The domain of this language is like integer expression. And we are defining this domain specific language and we have added types so that we get the benefit of type checking.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

Type checking is a wonderful thing, right? And we get the benefit of type checking for our own language that we define.  Well, plus int expression, int expression show type of, yeah, it does. Right. Sorry, the capital P. So this is what we saw here. Right. Plus.

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

Right. Expects int expression and expression and P has type alpha expression. Satak, does that answer your question? Yes, it does show alpha expression. Okay, good. But when you use the helper function plus it gives you the right type. Okay, this is this is so great. Right. So we have added types for our language now.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

So let's try to write our evaluator for this language. Let's use the same evaluator as the earlier one. So this is just the same code that I had from earlier. If I run this, I get lots of warnings. Okay. I used to get these warnings earlier, but I also have an error. That's new. So we get along with the warnings that we had earlier. We are also getting some errors now.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

The difference is that now our expression and values are different. Right. So we are getting warnings and errors. We will see why this is the case in the next lecture on Friday. So we are we are making progress on one end, but we are failing on the other end. Right. From warnings, we've gone to errors. We'll see how to fix these errors and keep going. I'll stop here. If you have any questions, you can ask.

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

I'll hang around for a minute. Then I will.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3205.3s_

Okay. So looks like there are no other questions. So we'll see how to fix those errors and we will sort of then slowly lead on to why we need G. We haven't seen here. It is so far. I will eventually get to that. Thank you. I'll stop here.

---
