# 31-cs3100-pop-lec-31-gadts

**CS3100 POP - Lec 31 - GADTs**  
id: `kjOaC-MbHQ8`  
duration: 3198s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so what are we looking at? So we were looking at implementing one more interpreter, right? And this time we have integers and Boolean and we have expressions which are plus multiplication and if then else. And what we're trying to do is we're trying to sort of add the types to our term language

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

so that we can rule out cases which don't make sense. In particular what we were trying to do first is to add the types through the idea of phantom types. What are phantom types? Phantom types are types which have phantom type variables which are type variables which only occur on the left hand side of a type definition and are not manifest on the right hand side. So they are free to be specialized to anything, right?

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

And what we did was okay, we have phantom types now and we saw a few examples of how phantom types can prevent field type expressions from being constructed. And then we said okay, this looks fine. Let's now write an interpreter which has the phantom types in. Right? And what we have now is an interpreter which is eval that takes an alpha expression, an expression which when evaluated gives us alpha and gives us an alpha value back.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

So this is the interpreter. Recall that when we did not have phantom types earlier, we had lots of warnings but no errors. But now, oops, but now you can see that we have a type error in this interpreter. So in particular, so observe that at line 12 which is the line here, right?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

We have an error and the error says that if we make it a little bit bigger so that it is easier to read. And the error says that this expression has the Boolean expression. But an expression is expected of type integer expression. Why is that? That's very strange, right? Because if you look at the type of eval, it's an alpha expression to alpha expression.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So why is it the case that we get the OCaml compiler complaining that this particular expression should be a integer expression and not a Boolean expression? Because just looking at the type, it looks like the evaluator, the recursive call to the evaluator here should be able to take any alpha expression and should return an alpha value, right? This is quite strange. So let's just work it out why.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So okay. So we got an error. So why did we get that error? It turns out, right? So in OCaml by default, all of the recursive calls are expected to be of the same type as in the function. So if you have a function which has multiple recursive calls, all of these invocations are expected to be of the same type, right?

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

If this type gets specialized, but type variables are specialized, then the type that is expected for every recursive call is expected to be the same. So let's see what happens in this particular example, right? So I've sort of dropped, I've only included lines which are important. So this is the type expression definition, I dropped the multiplication and other things. So if you look at plus, right? Plus is a int expression to an int expression.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

And then its type is an alpha expression, right? This type is not particularly specialized, but type is an alpha expression. If then else has the type Boolean expression, x2 expressions, which are alpha expression, alpha expression, and this expression itself has type alpha expression because we are using funder types, the left hand side is not specialized. So what happens during type checking? So keep this in the back of the mind, right?

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

When OCaml type checks the recursive function call, it expects all of the recursive calls to have the same type. So type checking in OCaml happens to go from, if you have a pattern match, it goes from the first pattern towards the last. So what happens here? So the type checking algorithm comes across plus, right? And it looks at the type of the definition of plus and it says that, okay, plus takes two arguments, right? And both of these arguments are integer expressions.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So E1 here should be an integer expression by the constructor, right? The constructor defines the type, so it has to be an integer expression. And similarly for E2, but that's not important here. And the next step, it looks at this line and it observes that there is a recursive call here, right? So this particular recursive call is invoked on E1, which is an integer expression. So what the OCaml type inference does is, okay, it looks at the type of eval.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

Oh, I see that there's an alpha expression to alpha value. And I know that E1 is an integer expression. So it unifies this alpha with an integer. And the inferred type for eval is integer expression to integer value. So at the point of this recursive call, your eval type has been specialized. So what OCaml says is, okay, I have found the type of more specific type for this eval.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

I will expect every other successive call to eval to have the same type, right? So this is the type that is inferred. And this recursive call satisfies the type, right? Because E2 is also an integer expression. So that goes through fine. And you will have a case for division that also goes through fine. Sorry, multiplication that also goes through fine. Then it comes across this if-then-else expression, right? And what does OCaml type inference do?

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

It needs to find the type for P. And by looking at the constructor, it knows that P has via Boolean expression, right? So OCaml knows that P is a Boolean expression. And then it looks at the next line. Here you see that there is a recursive call on eval applied to P. But P is a Boolean expression. And the type inferred for eval is int expression to int value.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

So that is why OCaml complains that it was expecting an integer and it found a Boolean value there. So this is why we have the type error. The type error wasn't there because we did not have this phantom type variable earlier, right? So we have all the additional warnings, but also this new type error, right? It just seems like we've sort of wanted to move forward, but we've stepped backward one step, right?

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

So we are trying to remove the warnings, but it turns out we have a type error as well. So how do we actually fix this, right? So that's the question. And so there is this concept of polymorphic recursion, right? We haven't seen polymorphic recursion so far. And the idea here is that polymorphic recursion allows the ability that we actually want here. In that every recursive call, we want them to be allowed at different types, right?

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

So in the first eval, the type happens to be integer. But in the second eval, the type happens to be a Boolean. We want to allow that as well. So typical type inference for OCaml does not do polymorphic recursion. It expects all of the recursive calls to have the same type. But polymorphic recursion allows us to do this. And there are many names for this. It's also called Miller micro typability.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

Robin Miller was the one who invented type inference and polymorphism that we use in OCaml, right? So they came up with this extension, which works out. So here is how you in OCaml tell OCaml to use polymorphic recursion. OK, so here is how you sort of say when you do type checking for this particular function, assume that we are using polymorphic recursion, right?

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So the only difference between this particular program and the one that was earlier is the new syntax here. So the syntax is sort of saying other things. But the only thing that you have to remember is the way you read it is there is some type A, right? And this function is going to be a function that goes from A expression to A value. So there is some type variable A, type A, and this is going to be A expression to A value.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

The syntax, what it does, OCaml is that when in order to type checking for this function, use polymorphic, allow polymorphic recursion, right? Type A is itself known as locally abstract type. There are lots of details. I'm not going to cover any of that. The only difference that we have here is instead of using quote A and quote A here, we actually use this type A and A expression A value. The rest of the code remains the same. So what this allows to do is ensure that this could be int expression to int value and this could be bool expression to bool value.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

So that is what I think I need to run all of the cells up to this one. So let me do that. Value expression. And then finally, this one. Yeah, OK. So we've used polymorphic recursion and what we've ended up having is.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

So observe that we have lots of warnings, the same warnings as what we had earlier, right? But the type error is gone. So there is no error now. It works out. The inferred type that the OCaml writes out is alpha expression to alpha value. But in order to use polymorphic recursion, you have to explicitly use this syntax. Type A.  So that's that. So you. So.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

OK. So the one question that you want to ask, right? It seems like polymorphic recursion is more general than regular recursive type checking that we have in OCaml. So why bother even using polymorphic recursion at all? So the downside of polymorphic recursion is that the type inference algorithm becomes undecidable. So in OCaml, we sort of write out the programs. You don't explicitly specify the types, but it is not needed.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

And OCaml type checks infers the best possible type for a program. This is no longer true if we have polymorphic recursion for reasons that I won't explain. But that's the case. What does that imply, though? What does that mean? It means that whenever you sort of write use polymorphic recursion, you have to explicitly provide the type for the polymorphic recursive function. So if polymorphic recursion by the default, every recursive function that you write in OCaml should have an explicit type.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

And this is very cumbersome, right? This is the first example where we've actually seen a use for polymorphic recursion, but we've written many, many, many recursive functions so far. So OCaml sort of chooses to have regular OCaml just uses as a default non-polymorphic recursion everywhere, right? And it's just a matter of programming convenience. Which pattern do you use often? And that is a pattern that OCaml goes for.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

And if you want a polymorphic recursion, you explicitly opt into it. And the downside is that you have to provide an explicit type for the polymorphic recursive function. So that's the reason why we don't use polymorphic recursion everywhere. Okay, so the thing that has happened now, right? So we were initially at some point, we had lots of warnings. Then we said, okay, we will add the phantom types. We took a step back. So we had all the warnings and we had one more error, right? And we said, okay, use polymorphic recursion.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

The error is gone, but the warnings are still there, right? We've not actually made any progress so far. And we've been looking at it for so long, right? Where are we heading? So the problem is this, right? Compiler still warns us that there are unhandled patterns in pattern matches. That is what we saw earlier. The problem is that whenever we write these helper functions, right? Where I say make inter phi equals, I'll end with a specific type for this.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

I think it used to be int expression, right? So whenever we use this, it is some convention that we follow. It is like additional thing that we impose on top of the constructor, right? Type inference itself does not pick the right type here. Type inference itself does not say when you construct an expression, using these terms, the type will be integer expression. We have to explicitly say that in this particular function.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

So type inference tries to be general, right? So OCaml does not prevent you from using these constructors directly, right? So you can still write little type expressions using these constructors directly. We are sort of saying, okay, you must use these helper functions, but nothing in OCaml prevents you from directly using these constructors directly. And you can still write ill type programs. So the warnings are still valid.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

For example, I can still write the original bad program that we were looking at, right? The running example, which is true plus 10. Even with phantom types, this particular program is correctly typed. The reason is that all of these make int and make bool are conventions that we place on top. If you use the constructors directly, then you get what do you get? You get alpha expression for this one. This will be alpha expression, right? And plus expects this to be integer expression.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

That is an alpha expression. So you can specialize it, right? So this whole, yeah, so if you sort of think about it, all of the errors that are previously there are still here. And you will still have a match failure. So what has happened is that phantom types sort of help you if you follow the convention of using these helper functions all the time.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

But if you use constructors directly, then we get nothing, right? In particular, the OCaml type checker knows nothing about these conventions that we follow, these helper functions and so on. So it is going to complain. It is going to have all of these match failure warnings, unmatched cases warnings. So what is the key observation here? The observation is that when you use the constructors directly, we are not specializing the type. We are specializing the type using these helper functions.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

So what we actually need, right? What we eventually need is a way to say when you build an expression using this term, which is vultru val of vultru, then the expression must have the type Boolean expression, right? And when you construct an expression with these terms, which is val int of 10, we want the constructor itself to have the constraint, right?

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

To say when you construct a term which is val int 10, give it the type integer expression. So we want to embed this into the constructor themselves. We can't just use these helper functions and get away with it because the OCaml type checker still has to do all of this writing. So that is precisely what GAREDs allow you to do, right? So generalized algebraic data types, one of the things that they allow is to refine the return type of the data constructor.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

So I will explain what this refine is, but one thing they allow you to do is to refine the return type of the data constructor. Just so that we have a comparative study of what GAREDs provide you, let's just take this example, right? So this is the type definition that we had for the phantom type. So we have a phantom type variable here and this type variable does not occur over here, right?

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

And we said this expression type actually is constructed out of these constructors. The key point is that we need to deeply embed this notion of when you construct an integer value with this int constructor and an int value, the type that you get is int value, right? We have to sort of add this constraint here. That is precisely what GAREDs allow you to do.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

So here is the syntax for GAREDs. Just like every new construct that we've been seeing in OCaml so far, there is going to be some syntax and we will study this in analytics. So first, let's look at the syntax, right? GAREDs are nothing but algebraic data types, plus plus, right? So they will have everything that algebraic data types can do, but they also allow you to do a little bit more. So what do they allow you to do? In GAREDs, you can define types, right? So I have a type alpha value, and the way you define GARED constructors is using the syntax.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

So you write int, right? And instead of using of, you sort of look at it as a function type, right? So the thing that comes after colon is sort of saying int is a constructor which when applied to an integer gives you an int value. In particular, it gives you a value which is specialized to the integer type, right?

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

And bool is a constructor which when applied to a boolean gives you a boolean value. So that's the key property that GAREDs get you to do. Here, what they let you do is based on the constructor, right? When you use the bool constructor and the bool value, the type itself is specialized to boolean value. When you use the integer constructor, the type itself is specialized to integer value. Right?

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

Now, this is whenever you construct something with the integer constructor, the only thing that you can get out of is integer value, right? And because this is deeply embedded in the construction itself, all of the constraints work out. So similarly, we write the rest of the program using GARED syntax as well. So these are the constructors val plus mult and it. For example, if then else says if then else is a constructor which is applied to three values, boolean expression, alpha expression, alpha expression,

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

the thing that you construct is a alpha expression. And similarly, multiplication is going to take two expressions, integer expression and an integer expression. And the expression that you construct is now special, right? Its type is specialized to an integer expression. So what we've done actually is add a type system for our simple language.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

Whenever you construct an integer value, you know that the value is an integer because the type says to say so. And whenever you construct multiplication expression, it is required that the arguments are integer expressions and the result is specialized to be an integer expression. Right? So this is what we do. And how does this help? So let's just look at what we get by constructing int 10. Int 10 now is specialized to int value.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

And similarly, if I do bool, say, true, I get bool true, boolean value as a result. So the type, this alpha type is actually specialized based on the constructor.  I'll put it back to what it was. So now, so observe that this is this term is well-typed, right? When you look at if then else, the first should be an integer expression, second and third should be the expressions of the same type.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

It happens to be integer here. And this whole thing returns an integer expression. And that is what we will have here. So that the result type of this expression is an integer. So what do we gain now? So we actually gain what we wanted to start with, right? So if you take the same evaluator as what we had used for Phantom types and now use it on top of the G

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

A R E T types, you get you get no warnings, no errors, everything works out. Observe that this particular evaluator will not get stuck because there can never be a case where you can construct this thing, right? True plus 10 is this thing because when you construct Val Bool True, this will have the type Boolean expression, right?

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

And plus expects an integer expression as the first argument. And this error will be statically called. So so we've what we've done is we use G A R E T to make our interpreter the same.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

And we use the G A R E T to make our interpreter the same. And we need the polymorphic recursion. And then we finally came to G A R E T and we have a G A R E T interpreter that works as plan.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

And what we ended up doing is we've added types to our interpreter using G A R E T. So G A R E T are much more general. So but we'll slowly look at what they bring in. But I want to take a moment to let you think about it and ask any questions if you have.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

Maybe I'll. This one. OK, it appears that there are no questions so far. So G A R E T is, as I mentioned, right, are much more general.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

So the thing that I want to mention here is if you look at this type definition, right, this type says it's a type alpha value and there are two constructors int and bool. When you use the int constructor, you get an int value. When you use a bool constructor, you get a bool value. But the type itself does not specialize alpha, right? So you can, of course, create absurd types such as this one type is a string value. Right. So this is this is this is fine.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

So OCaml will allow you to declare this type, define this type. But this this particular type has no inhabitants at all. You cannot create a value that has this particular type because the only ways of creating values of the value type is using int and bool. Oops. Is using int and bool, which give you int value and bool value. So even though the type you can write down the type string value, this is an uninhabited type.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

So there are no inhabitants for this type, even though you can write the type down. So we've seen uninhabited types and simply type lambda calculus. These types are going to be uninhabited. So you can, of course, create these absurd absurd types. But these absurd types will have no values. And that's the last time we are going to talk about absurd types in G.A. It is right. They are not interesting because you cannot you can write down the type, but you cannot actually create any values that have the type.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

So they don't have any computationally relevant effect. So we are going to ignore them after this. OK. So G.A. is quite powerful. Right. So they are one of the coolest things that OCaml has in terms of the power to eat ratio. So this term you'll hear in programming languages design.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

So G.A. sort of had just two properties over the regular data types. They allow the finding return types, which is what we had seen so far with this int value and bool value. They also introduce existential types. We will discuss this. They just allow you these two simple properties. But the bang for the buck that you get for these two properties is quite enormous.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So some of the users are type domain specific languages, which is just what we saw. We have a we had an interpreter which was typed now. We didn't do much, but we have a type interpreter which does not get stuck. We have types on this property for that as well. We can enforce shape properties on data structures. You can sort of say if you take if you take a list of length L and list of length M, then the resultant list which you get by appending these two is L plus M.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

Right. So you can enforce properties which talk about the shape of data structures. We can also do generic programming things like map and fold once and for all for every data structure. Typically when you write map function, we define map function for a list. You can define map function for a binary tree. You can define map function for a ternary tree. But the overall structure of the map function sort of remains the same.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So there is an idea called generic programming which allows you to write map function and fold function once and for all. So you define one map function and then that's the map function that you can use for every data that you can imagine. So we can do generic programming using G.R.E.T.S. You will see examples for all of this. Right. It's sort of how do I put it. So these look like very disparate useful features, but you can sort of express all of these using G.R.E.T.S.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

And the rest of the lecture is all going to be about what we can use G.R.E.T.S. for. OK. So and it's in particular we are going to see four examples. So we are going to see an example on units of measure. I will explain what it is. We are going to see how to introduce existential types and particularly I sort of didn't explain. Although I had hinted this in the modules lecture, I said there is a concept called first class modules, but I didn't introduce it.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

We will actually import first class modules using G.R.E.T.S. I won't introduce first class modules, but I will show you how to build first class modules. I will show you how to construct functions that operate on tuples of any length. So we will see simple examples about generic programming and we will do interesting shape properties on lists.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

So we will prove properties such as when you take the list and you say reverse it, the length of the list does not change. So these are properties which we haven't expressed through types. The only thing that we've said is when you take a list and reverse it, you get a list of the same type. We will also encode the length of the list as part of the type so that the length of the list is preserved. So your reverse function will have the correctness guarantee that if you give it a list of length five, then the reverse list will also have list five.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

So you'll see these four examples and a few more as we go along. So the first thing is unit of measure. Units of measure is just units. When we talk about physical quantities, we talk about a numerical value, but also a unit.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

And units are quite important because units is how we reason about whether two things are equivalent or not. One of the things that happened back in 1999 is there was a spacecraft that was launched called the Mars Climate Orbiter. So it was supposed to study Martian climate and it was supposed to be up there being a satellite for Mars for many, many years. Unfortunately, that mission was lost, right?

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

And that mission cost $125 million. The mission was lost because of a simple, not a simple, because of a software bug, right? In particular, there are so when NASA sort of builds these large missions, right? They don't build everything by themselves. They sort of subcontract to various contractors. And Lockheed Martin is one of the big aerospace contractors in the US.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

They build a lot of things. They also happen to build parts of this climate orbiter satellite. And NASA, so the thing that happened was Lockheed Martin was still using Imperial system of units, right? This is feet and pounds and so on. NASA used metric, right? They were sensible. They use they started using metric a long time ago, even though the rest of the US uses Imperial.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So it turns out that there was a there was some computation that picked up an Imperial unit that also picked up a metric unit with some computation together. The result came out, which obviously would be wrong and that cost the satellite to be lost. These are software bugs at the end of the day. And it would be nice if these software bugs can be caught statically. Even testing would not have possibly caught this bug because of the values tested, perhaps, right? Who knows?

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

But we can avoid this sort of bug by construction and construction, right? And that is what we call as units of measure. So here is without much further ado, right? Here is here is the way to import this. So what we are going to do is we are just going to import the temperature. And as you know, there are many, many different ways of representing temperature values. So you can use Kelvin units. You can use Celsius Fahrenheit.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

So what we are going to do now is we are going to sort of represent temperature as a temperature type that carries the unit along with it. Whenever you say temperature X, the temperature will say X of this unit. And that's what we are going for. So we define type Kelvin, Celsius and Fahrenheit. In OCaml, when you define just the type and no constructors here, you can imagine this is an uninhabited type, right?

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

So this type cannot be this type cannot have any values at all. The only reason for having this type is to use it as a specialization in a type variable, right? We will never create a value of type Kelvin. We will just use the Kelvin as a label in place of some type variable. It will become clear if you sort of look at the example. So we define these three uninhabited types, Kelvin, Celsius and Fahrenheit.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

And we define the temperature type as one of these three things. We have to deconstruct our Kelvin, Celsius and Fahrenheit. These are three ways of constructing a temperature. Each of these is parameterized by a floating point number that actually represents the actual temperature value. And when you construct the temperature with a Kelvin constructor, what you get out is a Kelvin temperature. That's the key bit here.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

So when you use Kelvin to construct a temperature, you get a Kelvin temperature. When you use Celsius, you get a Celsius temperature. When you use Fahrenheit, you get Fahrenheit temperature. So this underscore here just stands for I don't care about what the type variable is. They will just be specialized here. We don't care about this because we don't intend to use it. We don't intend to name it and use the name in the definition of the type. It's still a phantom type variable, right?

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

So this is still a phantom type variable, but happens to be specialized in the return type. We will often see this underscore type underscore something type name in GITs. So we will just leave it as underscore but specialize it here.  Okay. So what we've done so far is we've just defined the types for the temperature.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

So we have the type temperature with three constructors. How can we prevent this error? So I don't ever want to allow my audition. If I want to do some add two temperatures together, I should never ever have the case where I mix up Kelvin with Fahrenheit or Fahrenheit Kelvin or things like this. How can we prevent this? So the way you do that is by writing a function at temperature.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

That takes us temperature a as an argument. So we use the GIT typing here. We say there is some type A. And this add M is defined such that it takes an A temp to an A temp to an A temp. So this could be any A. So we have three types of three types of we use here.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

This could be Kelvin, Celsius or Fahrenheit. But the add temperature is only defined where the two arguments are the same thing. So this is how we prevent it from mixed up. So how do we and what does it actually do? So you take two temperatures A and B. We know that because of the type constraint here, we add the constraint that these two temperatures are of the same kind.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So the A is the same here. So it must mean that the only three patterns that you can allow are Kelvin, Kelvin, Celsius, Celsius or Fahrenheit Fahrenheit. It cannot be the case that you can have two different patterns here. So the GIT pattern matching only matches these three and it's completely exhausted. So we say if you give me two Kelvin temperatures, I return you a Kelvin temperature where I just do A plus B and similarly for Celsius, A plus B and Fahrenheit A plus B.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So that's the function definition itself is not doing anything crazy. So it just says I'm going to define addition for Kelvin, Kelvin, Celsius, Celsius, Fahrenheit, Fahrenheit. And the fact that there are no other patterns is restricted because of the type constraint that we have here. So now you can add two Kelvin values together.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

If I add a Kelvin 20.23 plus 30.5, I get some result out. But statically, right, so if I try to add Kelvin and Celsius, I get a type error that says that I am trying to add a Celsius together with the Kelvin. This has to be a Kelvin. So this is units of measure. You can, of course, extend this to all units and this will sort of prevent your computations from ever being in a state where you mix up units unnecessarily.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

OK, so that was a bit about units of measure. Any questions on this definition?

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

OK, seems like there are no questions. I'll move on. We can come back next class as well. So have a look at this. And if you have any questions, do ask me. Your next assignment is going to be on just on G.I.R.E.T. So you'll have ample opportunities to play with the G.I.R.E.T. So, OK, so that was the first use case that I wanted to show. So again, this use case is utilizing the fact that I can refine the return type in a G.I.R.E.T.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

Based on the constructor, the type that it returns is actually specialized. That is what I'm using here in order to encode units of measure. As I mentioned earlier, the other thing that G.I.R.E.T. is allowed to do is define existential types. So what are the existential types? They are also known as abstract types. We have seen abstract types in modules. And these two ideas are very closely connected. So let's look at a very simple example.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

And then it will clearly show what the existential type definition is. So just look at this type definition. It says I'm defining a type T. Type T is not a polymorphic type. It's a monomorphic type. It doesn't have any polymorphism, no type variable. And it has a single constructor called PAC. PAC is a constructor that takes any value. It takes an alpha and then returns a T. This seems quite strange.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

Because this is allowed. But if you look at this, this alpha only appears on the right-hand side. It does not appear on the left-hand side. And in particular, it just says that this PAC constructor can be applied on any value. And all it returns is this type T. We know nothing about this type except that when you construct something with a...

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

When you can take this PAC constructor, apply it on any value at all. And what you get back is this type T. That mentions nothing about the alpha at all. It doesn't say anything about alpha. So the thing to observe here is you cannot write this in a regular type. If you write a regular type, regular abstract data type. Abstract data type will complain.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

The type variable alpha is unbound in this type declaration. So it basically says that I don't know what this alpha is. Because you don't have this alpha here. You can add this alpha here. That allows you. But if you only have the alpha on the right-hand side, so this is not allowed by the regular data type. But GRET does allow you to do that. So this is defined. This is fine, right? You might ask, okay, what is the benefit of this?

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

So I am able to define this abstract type. Why do we call this abstract type? When you pack this together with a string, you get a T. When you pack this, the content is an integer, you also get a T. The only thing that you know about any value of type T is that a single constructor pack. And you know nothing about the internal value. It could be anything at all, right? You cannot assume anything about it. So what can you use this for?

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

So let's look at what it will be used for. So first thing is, with the GRETs, with this abstract type, you can create a list that has different values. For example, here is a list that has three different values of three different types. So this is integer, string, and Boolean, right? If you simply put these three in a list, okay, I will complain, right?

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

Oh, it has to be of the same type. This has to be an integer and this has to be an integer. But what I've done is I've just packed them together. So this has type T, this has type T, and this has type T. Now, the whole thing has a type T list, right? It says pack, pack, pack, poly, poly, poly. It just says there is a polymorphic type. I don't know anything about it, right? But it allows you to construct these pack values.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

So you can take these values of different types, put them in this pack constructor, and now you can place them in a list together, right? Now, because all of these are T, you get a T list. But if you sort of think about it, right? Spend two minutes on it and think about it, you cannot do anything useful with this type. The only thing that you can sort of say is, okay, I have this list with three values. I can't say anything about these values because all these values are abstract, right?

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

I have no information about this type. I cannot, in OCaml, there is no runtime type test. You cannot test whether a value is an integer or a string or a boolean. So this ties back to what I had said earlier about type erasure, right? So in OCaml, we do type checking and then we throw away the types. We have no information about types at runtime. So what can you even do with this list, right? You constructed it. You cannot pattern match on it, right?

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

So if you pattern match on it, you get something which is of some type where there are no useful operations on this type. You can do something with it. Let me show you that, Shri Shah. I think it will be clear in the next step. So here is something useful, right? So I'm going to create an existential list of showable types. Showable is what you've been doing in this assignment, right?

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

You have the showable module. We're going to create something very similar. So I'm creating this type showable, which has a single constructor showable, right? That takes two parameters, the value that could be of any type alpha, and then it has to have one function, just a single function that takes the alpha and returns a string. It's like this two string function that you might want to have, right? And if you give me these two values, you can wrap them in showable.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

And what you get is a showable type, right? Now I can do something interesting with it, right? So now I construct a list with the same three values, right? 10, hello, and 3.04. But additionally, what I do is I add the type to string function. So first thing I do is for the integer type, you can get a string by using the string of in function.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

For the string type, it is already a string, so just the identity function. For the floating point, you use string of float function, right? Now if you run this code, you get a showable list, right? So what do we know about this list of showable things? A list of showable things has a value of some type, I don't know what, but I also importantly know that there is one function, right?

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Which when applied to that value gives me back a string, right? I have this one function in addition to this value, which when applied to the value gives me back a string, right? So now I can use it just as Stresia asked, there is one particular function which I can use now. So this function tries to take this list, right? Which is the showable list and maps over it and for each of the values,

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

converge that to a string using the show function that is part of the type, right? Part of the value. So it pattern matches on showable. What you know is that it could be any value at all, some alpha, right? But you also have this show function which takes that particular alpha and then returns your string, right? So all I do is I take this function, I take this value, apply this function on the value. And if I run this, I get a string list back, right?

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

I get 10, hello and 3.04, right? So even though the value is abstract, as long as you attach some functions that operate on these values, you can do things useful with it. This should sort of remind you of an idea that you've seen previously, right? When we studied modules, the notion of abstract types. In fact, the existential types, the abstract types that are introduced by GADPs are exactly as powerful as modules,

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

the abstract types that are introduced by modules, right? Modules happens to be convenient for other reasons, but in terms of expressive power, they are equivalent. Modules also has functors and so on. Let's ignore all of that. But in particular, this type that we define now, type showable, is equal to showable constructor, which takes a value and this function to show is the same as this module, a module type showable that has this abstract type T, right?

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

This value is of that type T, that's this first component of the pair, and it has a show function that given this T returns a string. So given this alpha returns a string. I can make, so okay, so there's a question. I can make alpha to beta function that map will not work with it.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

No, right, because the beta would be anything, and I don't know anything about that beta. The beta would be two different things. So that won't work. But if it's the same monomorphic type, it will work. For the same reason why it works here, right? So if I define an abstract type U, and then I say I have a function that goes from P to U, U is abstract. Unless you give me something where I can use U with, maybe take a U, return a string or take a U, return an integer or something, U is just abstract.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

I don't have any operations that I can apply on U, right? So that's the, that is what GREDs using existential types give you. So they give you the exact power as abstract types that we've seen with modules. So that's the type definition, right? This type definition is equivalent to the module type definition.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

The value definition here, int showable of 10 string of int is equivalent to the module int showable, right? Where the type is an integer, the value is 10, show is string of int, but you explicitly add the type ascription showable, which sort of hides the type. So this is precisely what, this is precisely equivalent to the module definition that we have here. So both GREDs and modules introduce existentials.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

And the thing that you can do, right? So why did I explain all of this? You can see how first class modules will work. What are first class modules? First class modules are the modules where you can, so we have the stratified language, right? We have the module language on top. We have the term language on the bottom. Typically they don't mix. You can't write expressions around modules. So you can't write if 5 is greater than 10, module 1, else module 2.

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

So this won't work. You cannot return values. You cannot take modules as arguments to functions and so on. But we have this GREDs, right? Which also introduce abstract types. And these are just values, right? Whenever I write showable 10 string of int, they are just values. So they sort of give you the same expressive power as first class modules. So if you think about this as just a module, so the showable 10 string of int is just a module.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

What I have here is a list of modules, right? This happens to be a singleton list, but that's fine. The point here I'm making is much deeper, right? What I'm saying is because GRED existential types and the way we encode these abstract types are equivalent to modules, in the same way we can take values and pass values. You can take modules and pass modules around, return modules from functions and so on. That is precisely how first class modules work.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

Of course, they have different syntax, but this is how they actually work underneath. Again, I'm not going to say anything about first class modules beyond it, but because of, if you understand how this works, you know how first class modules work. I think I'll stop here. I'll cover the rest of the examples in the next class. Any questions on this one so far?

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

No questions? Okay. What we'll do is we have a few more examples in GREDs and then that will complete the OCaml part of the course and then we'll shift to Prolog.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3190.6s_

So, my guess is that there'll be like one more lecture hour of OCaml. Okay. All right. Thank you very much.

---
