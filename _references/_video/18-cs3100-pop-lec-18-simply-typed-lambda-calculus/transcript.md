# 18-cs3100-pop-lec-18-simply-typed-lambda-calculus

**CS3100 POP - Lec 18 - Simply Typed Lambda Calculus**  
id: `RO8BC21jfro`  
duration: 3321s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

So, okay, so what we were looking at as the last thing yesterday was adding types on top of untyped lambda gatherers. So just like OCaml prevents a lot of error statically, you can sort of think about typing as a lightweight program analysis or compiler analysis that removes a lot of bugs statically. So that is what we are going to see.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

And we are also going to sort of look at the meaning of typing beyond the pragmatism, which is simply programming. We are going to establish very deep connections between what types mean for an over untyped lambda gatherers and what the connections to logic essentially. So we'll sort of look at both aspects of adding types to lambda gatherers.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

One is pragmatism, which is programming how to types in OCaml word. So you'll get you'll develop an intuition of how OCaml does the type checking, what types mean and so on. You have an intuitive understanding of typing already. This would just give you a formal framework for thinking about these types. Second thing we'll do, which I think is very cool, is establish the connections between

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

what types mean and logic. And we'll sort of slowly ease into all of this. Okay. So the first thing we are going to do is to add syntax for types. So in OCaml there are primitive types, there is a pair type, arrow type and so on. We want some notion of types on top of untyped lambda gatherers. Untyped lambda gatherers has terms, terms for abstraction, application and variables.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

Similarly, we want syntax for types. So here is the syntax for type. So in simply typed lambda calculus, we have types. So we will use A and B to represent type variables. Just like we use M and N for terms, we will use A and B for types. There is a set of base types, right? And the base types could be integer, bool, float, string, etc, etc, etc, right? Let's just assume that there is some set of base types.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

And then there is a function type, right? A to B. This is similar to OCaml. There are products, products are just pairs, right? So pairs, we've seen A star B and OCaml. This is very similar. So we have a paired type, which is a product of type A and type B. And we have a unit type. So in OCaml, we just use the word unit. But for succinctness, we just use one as a unit.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

And this one sort of is there because it's a singleton type, right? So there is only a single inhabitant for this unit type. Just like OCaml, the unit type has exactly one value which has the type, which is the unit value. So that's just the reason why we have one here. Okay, so yeah, this B is the set of all base primitive types. You could add arbitrary things, but it doesn't really matter for this discussion.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And then we assume that the product binds stronger than arrow, which means when I write A times B arrow C, you should read it as A times B arrow C, right? And arrow types are right associative just like OCaml. So when I write ABC, you should read it as a function which takes an A, returns a B to C function, right? So function which takes an A and then returns a B to C function.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

And yeah, if you don't add either the unit type or the base type, then the system would be degenerate. We would not be able to write down any concrete types at all, because you can sort of write A times B and AROB, but there will be no base cases for the productions. So that's why we have unit type and base type, right?

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

But the point is these are not going to be interesting at all. The interesting things are going to happen in the functions and product types. We'll sort of see what happens now. So, okay. So in untyped Lambda calculus, we had exactly three productions, right? So we had variables, applications and abstractions. Here, I want to add a few more ideas into Lambda calculus.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So I've added product types, right? If I'm adding product types, I also need a way to construct product values and also destruct them, right? I want to be able to construct pairs and destruct the pairs. So there are a few more rules here, right? Few more terms here in Lambda calculus. And we also have the unit value. So let's go through one by one, right? Again, M and N are Lambda terms.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

A term could either be a variable or an application or an abstraction, right? In untyped Lambda calculus, we just had, oops, we just had Lambda x.m, right? So we said, that's a binder and that's a term. So here, what we have in addition is we have to explicitly provide the type for the binder, that's the additional bit because we are adding types on top. And we are not going to do type inference on this, right?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

We are not going to automatically come up with the best possible type because of reasons that I will explain later. But what we have here is we have an explicit type for the binder. If the binder is x, the syntax says that I'm going to create an abstraction, right, where the binder is x with the type a. Right, with the type a and the body of that abstraction is m.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

And so this is an additional bit over untyped Lambda calculus. So this is a syntax for pair, right? So in OCaml, you just use open bracket, m,n, close bracket. It's nicer to use a different syntax just so that it is clear. So this is fair. And we have first and second, right? To project out the first of a pair and the second of a pair. And finally, we have the unit value. The unit value is there because we have a unit type, right?

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

And unit value is the only inhabitant of this unit type. Okay. Any questions so far on this? Okay, good. So let me proceed. Oops.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

Okay, so what we are going to do is to say, because I've introduced both terms and types, right? I want to say, okay, this particular term has this particular type, right? I want to write this down formally. And in Lambda calculus, right, the terms might have three variables as well. So I want to write down the type of some open expression, open Lambda term.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Assuming that three variables have other types, right? So the way we do this is through what is known as typing judgments, right? It's just more syntax right now, but just follow along with me. As I mentioned before, when I write an expression like this, right? M colon A, I say that M is a term and A is a type, right? All this says is M has type A, right? You can sort of write this sort of,

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

this particular type expression makes sense only when M doesn't have three variables, right? If M has three variables, let's say M is just X, right? And if you say X has type in, it is unclear whether what context I'm talking about, because X could be something else which is defined as float in the environment, right? So that's not a valid assignment.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So instead what we do is we have this idea called typing judgments, right? Typing rules are expressed as typing judgments. And the point is this. So instead of just saying M has type A, we also have the set of assumptions for the three variables, right? So all this says is under the assumption that the variable X1 has type A1, X2 has type A2, up to Xn has type An.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

The term M, which might use any of these three variables, has type A. Okay, so under the assumption, these are the assumptions, right? The thing to the left-hand side of the entails is the assumptions and the right-hand side is the conclusion, right? So it says under these assumptions, M has type A1,

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

M has type A1, and M has type A2.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

Sir, you're on mute. Sir, you're on mute. Okay, thanks. So what we are going to, thanks very much. So what we're going to do is to say under the set of assumptions, big gamma, right? M has the term M has type A. And we assume that gamma has no duplicates.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

So we can't say under the assumption that X has type integer and X has type floating point, X has type integer, right? So we don't want any duplicates in assumptions. This is just convention, right? We will just assume that gamma is a set, sorry, it's a map from variables to types. So there are, even though we write it as comma syntax, you sort of implicitly assume that there are not going to be any duplicates in gamma, right?

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

This is just convention. We will use this convention everywhere. The way to read this convention is this big gamma is the typing environment, right? It sort of defines the types for the three variables. M is the term that we are going to type under this environment. And all we are saying is under this assumption of a typing environment, the term lambda term M has type A, right? And this is what we will use.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

Okay, so with that, we can see a few examples now, right? So here is, here are a few examples. So let's assume that P is a pair, right? And it's a pair where the first component is a unit type and the second component is a function type that goes from unit to unit. So under this assumption, right, the term second of P has type unit arrow unit

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

because you are extracting the second argument of this pair. So this is a valid typing judgment, right? So this typing judgment holds. So we say that this typing judgment is a holds. And we can also have empty assumptions, right? For example, this is a pair of unit values, right? So there are no variables here. In particular, there are no free variables here.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

So we can say that under an empty set of assumptions, this particular term, which is a pair of unit values, has the type unit cross unit, right? So that's the type. And similarly, you can have multiple assumptions. So what this says is, assume that f is a function that goes from unit times unit to unit, right?

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

So that f is a function type. And x is a variable x has type unit times unit. So under these assumptions, if you apply f to x, then that particular expression, the result of the expression, right, will have type unit because that naturally follows from the fact that f returns the unit type.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

And finally, why do we need these annotations for binders? So this will become clear here. So the idea is that if I don't have this binder, right, in OCaml, you can say that this lambda expression, lambda x dot x has type alpha to alpha, right? Where alpha is a type variable. And the type of this function is polymorphic, right?

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

So we don't describe what the type is. We just say it can be applied to any type. And the thing that distinguishes simply type lambda calculus and what OCaml does, which is polymorphic lambda calculus, is the fact that we don't have any polymorphism in our types. So all of our types are grounded, right? There are no type variables. You can produce terms which all have concrete types. We don't have support for polymorphism, so we cannot write alpha to alpha as a type.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

And for that reason, we have to explicitly provide what the binder binds to. So this binder, if I assume that this binder has type unit, then this abstraction is unit to unit. Okay, so the key difference is this, right? So we are studying simple types. And this is the reason for the idea that we use the word simple.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

Polymorphic types are complex types. And all we have here is non-polymorphic, monomorphic types, right? Monomorphic is there is only one form of any particular type. And every type is grounded. So there are no type variables. And for that reason, in order to assign this function, this abstraction a type, we require the type annotation of the binders, right?

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

So because I am saying this x is 1, this is 1, 1. Okay, so that is a few examples of typing judgments. Okay, so we've sort of used our intuition for arriving at all of these valid typing judgments. So I can make a, I can sort of say, right, something like this. So this is, this is, this typing judgment is incorrect, right? Because the type does not check.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

So there is this notion of correct typing judgment and an incorrect typing judgment. So this sort of ties very deeply to type checking, right? If you write a program, all your compiler is trying to do is to say, ignore type inference for the moment. It is all it's trying to do is to check whether the program has correct types. And you can say that this program has a correct type. This is correct. This is correct. But this is incorrect.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

So there is this notion of a particular typing judgment being correct or not. So what we will do is because we have a very simple language, we can completely define how to do type checking on this very simple language.  So, so before that, let's have a small quiz, right? So here is a typing judgment, right? There is a gamma. The assumptions are there is arbitrary set of assumptions, gamma,

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

and then there is the assumption that X has type A, and the variable Y has type B under these set of assumptions, some lambda term, sorry, some lambda term M has type C, right? Which of the following is true? Is one true?

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

Actually, let's do two, right? So let's do two. Does X belong to gamma? So assume that all of these have to be unique, right? The entire set has to be, it's like a map. Imagine this to be a map. When I write it like this, the idea is that this whole environment, right, has unique keys to values.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

So there are no two different types for X. So let me give you the answer. X doesn't belong to gamma, right? So if X belongs to gamma, then there might be duplicates here. This is what I mentioned at this point. Assume there are no duplicates in the assumptions. Okay, so we assume that there are no duplicates. So this doesn't hold. Y does not belong to gamma. That is true.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

Because we have an explicit Y here, it must mean that Y does not belong here. Otherwise, we will have conflicting assumptions for what the type of, we may have conflicting assumptions for what the type of Y is. So this is just convention, right? If I write it out like this, where I have a big gamma X, Y, then it must mean that X and Y do not belong to gamma. So can A and B be the same type? Yes, they can, right? They are just placeholders.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

So A could be a unit type, B could also be a unit type. So we don't have any restrictions on that. Can X and Y be the same variable? They can't be the same variable because all of this is unique, right? And yeah, so that's, these are the, this is just what I explained now, right? So X cannot belong to gamma because we assume that all of these assumptions are

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

forming a map from keys to, sorry, the variables to types. So if you have an X here, then there is no X in the gamma. And this is correct. Y does not belong to gamma. A and B may be the same type. X and Y may not be the same variable. And you cannot directly write something like this. This is sort of a trick question, right? I cannot say M colon C holes because that might not,

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

that question will not make sense because M can have a free variable for which we don't know what the type is. We haven't provided enough information about what the type of the free variables in MIT. So this is not a valid question at all. So the thing that you can ask is something like this, right? Under, when I write it like this, I'm asking under an empty assumption,

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

does the term M have type C? This might or might not hold, right? Again, this is not something that we can answer. This is like asking validity of some propositional statement, right? I write some propositional logic statement and I ask whether this is valid or not. It might or might not hold. But this doesn't even make sense, right? This is not a well-formed question. So if I just say this M colon C holes, that's not a well-formed question.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

Okay. So a few typing judgment ideas. Okay. So with that, we can go back to what I wanted to say earlier. So here we are using our intuitions, right? We are saying, okay, I know how second works. So that's why second of P has type unit or a unit. But you can sort of define the rules, the algorithm completely, because we have a very small language.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

And our choice of describing algorithms in this course, actually throughout the course will be inference rules, right? So here is the set of inference rules for type checking. So this is the complete set of rules that is required to perform type checking on simply that lambda calculus. Okay. So we'll see how we will use this, but we'll start looking at individual rules. So the simplest rule is this, right?

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

The rule says when you have a unit value, right, you can always assign it the type unit, right? That holds irrespective of what gamma is. So I don't care what gamma is because this is just a value. And I know that it has a, it is a unit value, so it must have a unit type, right? So without any assumptions, you can conclude that unit value has a unit type.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

So when can you conclude that x has type, the variable x has type a. So you can conclude that the variable x has type a. If you have an assumption, right, where we say that x has type a. So again, recall that all of these are assumptions, right? You must have an assumption which says x has type a in order to conclude that x has type a. Okay.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

So now let's look at, so the thing that we are doing here, right? These things are just labels naming the rules. So we call this the bar rule. This is the unit rule. So we are going to look at rules for functions, right? So we have two rules for functions. One is elimination and another is introduction. So we call this elimination because there is an arrow in the assumptions and there is no arrow in the conclusion, right?

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

The premises have an arrow, but the conclusion does not have an arrow. And on the flip side, here is the introduction rule where the premises don't have an arrow, the conclusions have an arrow. So a standard thing that you will keep on seeing in this lecture is for every sort of type producer, right? So these arrows and products, you will have an elimination and an introduction rule, right?

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

There might be multiple elimination and introduction rule, but this is a common idea that sort of goes around. So we will see what that elimination rule actually says. So the conclusion says, okay, if I have an application M applied to N, when can I conclude that it has type B, right? What should be the property on the assumptions, essentially? So when does this typing judgment hold?

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

So if I apply F to X and I say it has an integer as a result, the type of F of X is in. When can I conclude that F of X has type integer, right? So what is the intuition behind it? If you apply F of X, F has to be a function, X has to be a variable and X's type should match the argument type of the function.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

That's the intuition. That is precisely what we encode here. So in order to conclude that under gamma, M applied to N has type B, it better be the case that under the same gamma, M should have type, a function type that goes from A to B and N, the argument has type A. So this A has to match this A, this captures our intuition concretely.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

So M has to be a function type, N has to be some type, I don't care what the type is. The only requirement is the argument type of M should match the type of N. And the return type B is the type that is written by this application. So this is our intuition captured formally. And this is the elimination rule. So on the flip side, we have an introduction rule.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

So when can I conclude that this lambda X, A dot M, which says that lambda X where X is of type A and the body is M has type A or B. So when can I assign it the type A or B? I have an abstraction. I say that has the type A or B. It's a function type. How do I type check this? In order to do that, assume that you have all the original assumptions in gamma and assume, add another assumption where you say X has type A,

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

all the original assumptions and this new assumption that X has type A. Now, under the combined set of assumptions, all of these assumptions, if you can show that M has type B, then the typing judgment where under gamma, lambda X, A dot M has A or B holes.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

So this is sort of telling you how to type check a function abstraction. If you want to check that this function abstraction has type A or B, you go ahead and assume X has type A in addition to your original assumptions. And you must show that M has type B. So that's the procedure for actually type checking a lambda abstraction. So those are elimination and introduction rules.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So this is function applications and function abstractions. And similarly, we have introduction and elimination rules for products. So there are two elimination rules. So corresponding to first and second. So what does this rule say? When can I conclude that under gamma, the first component of M, I'm going to write this expression first component of M has type A.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

In order to be able to do that, it better be the case that M is actually a product type. M must be a product. And in particular, the first component of M should be the same as the type that you are concluding. So under the same assumption. And similarly for the second one. So we want to conclude that second of M has type B. It better be the case that M is a product. M is a product type.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

And the second component of M is B. So these two are elimination rules. And you can have the introduction rule here. So if I want to conclude that the pair M, N has type A times B. So if I need to prove that M, N has the type A times B or check that this has the type A times B.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

I need to show that under the same set of assumptions, M has type A and N has type B. So this describes the complete rules, the sort of formalizes the rules for how to do type checking. So here is the procedure. So when you do type checking, you keep on exploring a downer tree.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

So here is an example. So in order to prove that an abstraction has an arrow type, I need to show that the body has some type. And you can imagine this could be an abstraction. This keeps on going. So you build up this proof tree. And why is this a tree? Because a particular conclusion here might have multiple premises. So this has two premises, one and two. And hence, you keep on exploring down this path until you reach the base case.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

What are the base cases? The base cases are this variable case, which has no assumption and this unit case, which has no assumption. So given a complex term, you sort of build this proof tree where you keep applying these rules. You keep finding these patterns and applying it until you reach the base cases. So once you are able to reach the base case, you can actually show that all of this holds. OK, so here is an example of type checking a non-trivial tree.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

OK, so here is the term. Are you able to read this? Is this too small? I can make it bigger as I go. Can someone confirm? Is this too small or it's readable? Good. So what are we doing here?

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So we are trying to say we are asking a question. I'm asking whether this complex term has this type. So that's the thing that I want to do. What is this term? If you sort of ignore the type annotations for the moment, it says lambda x, lambda y, x sub y to x sub y. All it's saying is fun x arrow fun y x of x of y.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

And because we need to provide the type annotations explicitly for the binders, I am assigning the type a arrow a for x. And I'm saying y is of type a. And I'm saying this whole term has type a arrow a, arrow a, arrow a. And we can intuitively check whether this is true.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

Let's see. So the first argument is a arrow a. So that's a arrow a. That's fine. The second argument is y, which is a. And that takes an a. That's fine. Then you're applying x to y first. When you apply x to y, you get an a out. So this term has type a. And then you again apply x to that result. So you should get a result as an a. And that's why this is an a. That's the intuitive understanding of how this works.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

And the way the type checker formally proceeds checking the types is using the rules that we applied. So the cool thing about the rules that we described is it's deterministic. So there is only one possibility, one pattern match that applies. So if you have, say, an abstraction, we know precisely how to type check an abstraction because we have the rule for abstraction.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

The only rule that applies abstraction is the lambda, the arrow introduction rule. So we directly appeal to this arrow introduction rule. What does the arrow introduction rule say? The rule says that if you want to type check a lambda abstraction, such that it has type a or b, assume that the binder has type a in the assumption and show that the body has type b.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

The body, m, has type b. This is precisely what we will do here. The binder here is x. So we move x to the assumption. So one thing I forgot to mention is we are type checking this in an empty set of assumptions because this is a closed term. We don't need any set of assumptions. So the assumption set here is empty.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

And just as the introduction rule says, we move the binder to the set of assumptions. So what you end up having to prove now is to show that assuming x has type a to a, arrow a, prove that this body, which is lambda y, x applied to y, has type a arrow a. So we arrived at this because this is b.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

This is why we have arrow a here. So we've done that. Again, we have a lambda abstraction here. So we have to appeal to the introduction rule again. So one more application of introduction rule. So the binder here is y. So we move the assumptions to, we move y has type a to the assumption. So that is in addition to what we have already, which is x has type a arrow a. And now we have to show that x applied to x applied to y has type a.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

This is a because this has type a. What we have now is application, right? x applied to x applied to y. And if you sort of go back to these rules, there is only one rule for application, and that is arrow elimination. So you directly appeal to the arrow elimination rule. If you do that, there are two premises, right? One for showing that m is actually a function.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

The next for showing that n has type a and that type matches. So what do we have here? We have to show that x is a function and x applied to y has a type which matches the argument type of x. So how do we do that? So I want to show that. So this. So the first premise leads to this this proof obligation, right?

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

So the obligation is under the assumption that x has type a arrow a, y has type a. This variable x has type a arrow a, I have to show that it has a function type. And this is easy, right? We just appeal to the variable rule now. So all the variable rule now says is if you need to show that the variable x has type some type a, it better be the case that there is an assumption which just says x has type a. So we do have that assumption here, right?

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So we have the assumption that x has type a arrow a and x has type a arrow a, that type x. So we are done with that part of the tree so that that branch is done. And the next thing we want to show is x applied to y has type a. This is again arrow elimination. So the function type here should be x and the value type is y. So we have two premises again.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So the first premise we have to show x has type a arrow a, which is just the variable rule. And the second one is we have to show that y has type a. And that is also true because of variable rule because we have added an assumption where he said y has type a. So what I showed here is like a formal way of looking at how to do type checking. We've been using our intuitions all the time.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

So you can imagine this is exactly how you will implement a type checker for synthetic gramm and you can call the type checking function on the body.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So you keep on doing this until you reach the base cases. So you can sort of imagine this to be a description of the algorithm, a small description of the algorithm. Instead of showing source code that is written in OCaml, I'm showing this as an inference rule. But it should be fairly obvious how to take this particular set of rules and convert this to a program. I'm not going to ask you to implement this, but you are doing something very similar for assignment 2.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

And once you finish assignment 2, it should be obvious that you can do this. It is likely that I will ask you in the exam, write down a type derivation tree for a particular judgment like this. So I will give you the rules. If I ask this question, I will give you all of the rules.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

But what I would expect is you write down this tree. And it might be the case that this particular checking works out, all of the types hold. But it might be the case that you have a free variable somewhere. Let's say I have a... I can't edit this. Let's assume this y is not a y, but a z.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

If this is a z, then your type checking here will fail. This will be a z where I need to show that z has type A, but I will not have any assumptions for z because z is a free variable. And type checking fails here. So your type checker, whatever you will write, will say, okay, you told me that z should have type A, but I don't have any assumptions where I can show that z has type A.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

So no rule applies and type checking fails. So that's how type checkers work. And this is precisely how all of the type checkers work. They might have more complicated rules or more complicated terms, but this is how they work internally. So as I mentioned, for each lambda term, there is exactly one type rule that applies and that sort of makes the whole thing deterministic. So you just look up by pattern matching which rule applies and you just keep applying those rules recursively.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

Okay, so we come to this idea of typeability. So in particular, so we have lambda calculus terms. So not all simply typed lambda calculus terms can be assigned a type. This is meant to rule out incorrect programs.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

Unlike untyped lambda calculus, we can explicitly rule out bad programs. And here is an example. I am asking for the first of a lambda abstraction. This is not a sensible thing. This is not a sensible term. Why do I not say it's sensible? Because you cannot reduce this further. It doesn't make sense. I'm asking for the first component of the lambda term. This doesn't make sense. You can sort of catch this by type checking.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

If you cannot assign this term a particular type. So the cool bit is if you cannot give a particular lambda term a type, then the type is not well formed. So then you cannot run this. So here is something that is not for which you cannot assign a type. So you cannot run this program.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

And here is a pair that is in the function position. I'm applying this pair to P. This should be a lambda abstraction. And this also does not type check. And hence you can sort of imagine this is not something that we can actually go ahead and beta reduce because it doesn't make any sense. Surprisingly, it turns out that some of the useful things that we had done in untyped lambda calculus can also not be assigned a type.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

So here is a simple function that is self application. So this is lambda x x applied to x. You cannot assign a type for this particular term in simply the lambda calculus because why because the issue is that x must be a arrow type.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

And the constraint that we have is the argument of x should be the same as the type of x here. And that sort of a recursive argument. So the argument has to be the type of x. So you can keep on expanding this type. If you assume x as type a roa. This x also has to have the type a roa, which means this has to be a roa roa and this has to be a type a roa roa. Keep on expanding this.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So you cannot assign a valid type for lambda x x or x in simply lambda calculus or ocamel. So in ocamel if you write fun x arrow x applied to x ocamel will comply. So ocamel will say I am not able to infer a type for this function. You can try it out. Okay. So this is the other thing that I wanted to mention. So in ocamel we can define first and second like this. What is first?

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

First is just takes a pattern matches on a pair and then returns the first of the pair. A and second pattern matches on the pair and returns the second component. So if you run this you get you get a type of this polymorphic. It's an alpha star beta to alpha and second is alpha star beta to beta. This polymorphism is quite important. We don't care what these components are, but we can always give it a type in ocamel because we have polymorphism.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

So this is alpha. Whatever type this is, that will be the same type as this one. And this is beta. Whatever type this is, this will be the same as the result type. But we don't have polymorphism in simply take lambda calculus. We don't have the ability to even write alpha and beta in the type. We don't have the capability. We only have base types or function types or product types where each of these components are going to be based on arrow types and so on.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

So given that we have that restriction, first and second are actually keywords in simply take lambda calculus. So the question you need to think about is why can't we implement first and second as lambdas just like this. If I write a lambda a lambda b dot a, what type will I assign for a?

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

So that's the question. You cannot do this. You cannot define first and second as functions. Hence, first and second are actually keywords in simply take lambda calculus because of the lack of polymorphism. But for any given type, so if I know concretely what a and b is, if I say a is unit type, b is unit type, then I can define a function which goes from unit to unit to unit. So I'm using type variables here.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

This is not polymorphism. This is just a placeholder. So this is filled in with concrete types for any concrete type. I can always write down this function, but still first and second are certainly keywords here. So the thing that I'm trying to get is in the previous lecture, we actually encoded pairs and first and second, just using lambda.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

And what I'm claiming here, what I'm showing you here is because of the lack of polymorphism, because we need to assign types for the terms, we cannot use a trick. We have to encode first and second as primitives in the language. So that's done. And the dynamic semantics is very straightforward. We've already seen multiple reductions, so I'm not going to belabor a lot on this idea. So if you, I mean, it's compressed and written down.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

If you have an application, right, all you do is substitution. So if you want to apply this lambda to n, then substitute in the body of m, n for x, right, in the body of m, substitute n for x, and that will be the result of performing the application. There is eta reduction, right? If you have lambda x dot mx, then you can reduce it to m, assuming that x is not a free variable.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

If you ask for the first variable of a pair, you get the pair out, first component out. If you ask for the second component, you get the second component out, right? And similar to eta reduction, right, for the obstructions, you have an eta reduction for the products. And what this says is, if I take a pair m and I construct a pair with first of m and second of m, the resultant pair is going to be the same as m, right?

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

So I give you a pair which contains 5 and 6, and I'm going to construct a new pair, where the first component is the first component of the given pair, and the second component is the second component of the given pair. And the pair that you're going to get as a result will be the same as the original pair, right? That's the intuition here, right, in this one. And these, oops.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

And these are just the rules that we have seen for normal order reduction, right? So if you have an m applied to n, if you can actually not, not full beta reduction. So if you have m applied to n, so if you can reduce m, go ahead and reduce m. If you can reduce n, go ahead and reduce n. If you have a lambda abstraction, you can reduce within the body of the lambda, right? So the reductions, the dynamic semantics is actually very simple. We've covered dynamic semantics, right? So the interesting thing that we are covering in this lecture is static semantics.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

This is just here for completeness. Okay, so this sort of underlies the key property of why we want types, right? We want types in OCaml, we want types in C, we want types in Java, because we want to rule out bad programs, right? And there is a very nice way of capturing that property in the language, in the very small simply typed lambda calculus that we've defined.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

So the property that we have is that, as I hinted before, right, if you take a simply typed lambda calculus term, and you can say, okay, this term has some type, I don't care about what the type is. If the term has some type, then that will reduce to a beta normal form, right? This is a very strong property. So if the term has some type, then you can always reduce it to a beta normal form.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

In particular, it will never get stuck, right? So you will never get into a state where it is stuck, where by stuck, I mean something like this, right? It will never enter into a state where it may be a complex expression. But what I'm claiming is this, if you can sort of give this complex expression some type, right? I don't care what that expression is. But I can prove, I give you this proof that when you reduce this expression, you will never produce this particular term, right?

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

Which is first off, oops, I don't know why I keep doing this. Which is first off, lambda abstraction, this is a very powerful property, right? I'm saying, if my program type checks, it won't go wrong. And that's precisely what I'm claiming, right? So whatever be the program, whatever be the term, if you can assign the term some type,

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

then that particular term, while beta reducing will never get into a stuck state. A stuck state is, for example, getting the first component of abstraction, right? This doesn't make sense. You cannot reduce this further. This is stuck. And similarly, say unit applied to unit is stuck, because this has to be a lambda, right? You cannot use this in a function position. This is known as, this idea is very, very critical, right?

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

This is the idea behind why OCaml is able to remove a lot of these. OCaml does not have seg faults, right? Segmentation fault is not a thing that OCaml will do, right? This is not a thing that Java will do. And the reason why Java and OCaml have this property is because of types of this. So both of these languages are supposed to have types of this. C++ and C does not have types on this, right?

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

And the distinction is this. If you can give a program, if the compiler says your program is type checking, right? If your compiler allows you to compile the program, then your program will not have a seg fault. And the property is types of this. And the formal definition of the property is this, right? If I take a lambda term and I say the lambda term has type A, right? And I can reduce the term, right? From m to m prime, beta reduction, then either m prime is a value.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

So you completed evaluation of m prime to its value. So it's zero or one or unit or whatever. Or you can keep reducing as further, right? Or you can go from m prime to m double prime. So this is the critical bit, right? This says that you will never encounter a stuck state. You can always keep on reducing it until it is a value. And this is precisely why, I mean, if you imagine this to happen in the runtime, right? I don't care what this is. I just assume that this bit representation is a function.

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

And I start applying this bit representation on this pair, which I think it is a pair, but it's actually an abstraction. It is going to seg fault. But this is not a thing that Java and C++ do. And sorry, Java and OCaml do. And this is precisely because we have types on this. Okay, so much of the programming language work is about taking complex properties and encoding them as types on this. We are not going to see types on this in any further detail.

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

Right. But this, this theorem is very critical. Okay, so I'll just leave it at that. I'll stop here. I think we can continue on Friday for the next of the rest of the lectures. Any questions on this? I know this is a very theoretical exploration, but the hope is that you can actually understand the underlying principles of what drives languages like Rust and Java and OCaml.

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3300.0s_

The concept is types on this at the end of the day. Rust also has types on this. Typezone says if the Rust program type checks, it will not have any seg faults. It will not have any of the errors that C++ has. It's a very strong property. And the way that the property is phrased is using this idea called types on this.

---

![slides/interval_0111.png](slides/interval_0111.png)
_t = 3300.0s -- 3315.8s_

Okay, so I think I'll leave you to go. Have a go through this lecture. Right. So walk through it. Let's, let's, we'll finish it and we'll come back to maybe have a look at it again later. Okay. Thank you very much.

---
