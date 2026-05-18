# 19-cs3100-pop-lec-19-simply-typed-lambda-calculus

**CS3100 POP - Lec 19 - Simply Typed Lambda Calculus**  
id: `CiKl6XAnmLA`  
duration: 3452s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

All right, so we were looking at the type lambda calculus in the last lecture. And the last thing we were looking at is this idea of types of this. The informal definition is well-typed programs do not get started. It just says that if you have a term, simply type lambda calculus term, it has a type that

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

you can type and check. And there is no, it won't get into a state where it doesn't make sense, such as unit applied to unit and first applied to an abstraction. You can only get a first of a pair. So in practice, this translates to well-typed programs do not have runtime errors. The typed soundness theorem says I've sort of fixed the definition since the last class

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

because it was not correct. So this is the correct definition. The correct definition is for lambda calculus term, simply type lambda calculus term, M has type A, and either M is a value or there exists an M prime, such that you can reduce M to an M prime. And M prime also has type the same type. So you can recursively apply this and you can show that if you have a well-typed term,

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

it either evaluates to a value or it is already a value. So this is types of this. So clearly not all untyped lambda calculus term are well-typed. So examples are these. If you had a untyped lambda calculus term like this, they are certainly not well-typed in the sense that you cannot give it a sensible type for this one. So any term that is stuck is the type.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

But you can also ask the other question. The question is, are there terms that are ill-typed according to simply type lambda calculus, but do not get stuck. So it turns out that unfortunately, yes, this is true. In particular, if you consider all the terms to be set of all terms that you can write

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

down with untyped lambda calculus, terms that do not get stuck are a subset of this. And well-typed terms according to simply type lambda calculus are actually a subset of terms that do not get stuck. An example, a very useful example of this is the y-combinator. You cannot write a type for this y-combinator because there is a self-application here. There is lambda x x applied to x. So for the same reason why you cannot write a sensible type for omega-combinator or just

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

the function that is a lambda x x applied to x, this term you cannot assign a type and simply type lambda calculus. What this means is this is what we were using to write express recursive functions. If we recall from the previous lecture, we were using y-combinator to encode the recursion. We were writing functions such as Fibonacci functions, the length of a list and so on. It turns out that you cannot give a type for this y-combinator in the simply type lambda

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

calculus. And really there is a surprising result which says that every well-typed, simply type lambda calculus term terminates. So if you have, there is no notion of contamination. If you have a well-typed lambda calculus term, then it is strongly normalizing. It always evaluates to evaluate. It sort of rules out useful programs as well.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

So does that mean that we cannot write non-terminating programs with types? Clearly, no. So we can certainly write non-terminating programs. For example, consider OCaml. OCaml has sensible types, but we can write non-terminating programs. The way we sort of do that is by adding recursion as a primitive. So this recursive type, this recursion, must be added as a primitive to the data lambda

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

calculus. Just like we added first and second as primitives in this lecture. So we cannot encode it using other existing primitives. We have to sort of add it as a feature in the code language. That is how OCaml does it. So recursive types are a primitive in OCaml type system. So it would be the same with simply the lambda calculus extended with recursion.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

Okay, so that's that. So the reason why lambda calculus is so interesting is not just because it is useful for programming. We write programs in OCaml and we want to statically ensure that the programs don't have a large class of bugs, which are caught by the compiler and hence types are useful.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

But it turns out that the types also have very deep connections to propositional logic. So here is a question. Consider the following types. I have seven types here. The question is, can you write down closed terms for these types? So what I'm asking is, can you write simply the lambda calculus terms that will have this type? You can work it out in your own time, but I'm going to give you the answer.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

So it turns out that for the first five here, you can indeed write programs and the programs are here. But for the last two, right, six, seven, you cannot write a program like a lambda calculus term, closed lambda calculus term that has this type. In particular, there is much stronger result.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

The result is for these types that does not exist a closed term that has this type. So you cannot, there does not exist a program which has this type. I mean, this is pretty fundamental. So how do I reconcile this understanding? I tell you there are no programs which have this type. Why? So we can sort of ask a different question. We can say in our simple types that we've been seeing in this lecture, replace your

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

arrow type with logical implication. This is a logical implication that you've studied in this mathematical logic and replace your product type, the pair type with conjunction. So if you sort of take these types and just do that transformation, you will end up with these propositions.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

And the question that I want to ask now is which of these propositions are valid? And we know how to answer the validity question. What is valid? Valid propositions are those for which any assignment of true and false to any of those variables will always give you true, will always evaluate a true. So I'm asking whether these terms are valid.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

It turns out that the first few are valid for the last two are not. For example, A implies A and B. You can always pick A to be true and B to be false. So this would be true implies false, which is hence, this is not valid. And the same way you can pick A to be false and C to be false here and you will derive false there. So that's also not valid.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

So if you start to stare at this observation, so it turns out one and five are not valid and six and seven aren't. And this is the same answer that we arrived here. So where the examples are the types one to five had a program, but six and seven, there is no problem with those types. So this is this is quite interesting.  Yeah, observe this correspondence.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So this is the same propositional logic formula. Six and seven are not valid. And here we have six and seven don't have a term. You cannot write a term which have the types mentioned in six and seven. So where is this? So this is an interesting observation. But why does this sort of correspondence exist?

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So let's say I give you the proposition A and B implies A and I ask you to prove it. How do you prove it? You assume that A and B holds. And because A and B holds and we know what conjunction gives you, both A should hold and B should hold. Only then A and B can hold. Hence by just picking the first conjunct, you can derive A and hence the proof.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

If you sort of consider the program, this particular program, it says that take any X, which is a pair of A and B and then extract the first of X, which will be A. This sort of mirrors this proof. Observe that the reason that we are using assume A and B holds is like how you have a variable in hand value in hand with that type A and B. And by the first conjunct. So you're sort of saying, OK, extract the first one from this conjunction that also holds hence the proof.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And here we're saying extract the first component of the pen. And what is the type of this program? So this program, this program has type. It takes a pair A, A times B and then it is a function. So it returns a name. So it returns a name. So now observe the correspondence between this type and this proposition and use the rules that we described earlier.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

Replace all conjunctions with the product type and then integration with the arrow type and you arrive at something very similar. So what we end up having here is what is known as Curry-Howard correspondence. And correspondence is a correspondence between simply type lambda calculus and the propositional logic.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

In particular, Curry-Howard correspondence says that proof is to proposition as program is to a type. So as proof is to this proposition, this program is to this type. So if you want, if I give you a proposition and I ask for a proof, it is the same as I giving you a type and I ask you to write a program that has the type. And this is very crucial.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

So this gives you a way of proving certain propositions by just writing down programs. Yeah. So and this is known as Curry-Howard correspondence and the logic we use here, the proposition logic that we use here is not classical logic. So I assume that it is very natural to be introduced to classical logic when we talk about proposition logic.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

In classical logic, we have this, right, which says that A or negation of A always holds for arbitrary. This is a valid statement here. So this is known as the law of excluded middle. This law holds in classical logic. The thing that we do here is known as constructive logic. So in constructive logic, law of excluded middle does not hold.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

That axiom is not true. The reason is that in order to prove things in constructive logic, you have to construct the proof object. What does that mean? Concretely, you can sort of use the Curry-Howard correspondence to understand the statement. What do I mean by constructing the proof? In order to prove something in constructive logic, which is like for a given type, give me a program, I have to actually construct a program.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

I can't say, I can't tell you without writing a program that a particular type is valid. I cannot use contradiction. I cannot essentially use contradiction to prove something. That's the difference, right? So you sort of have it in the back of the mind. The only thing that you need to remember is that we cannot use law of excluded middle.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

Okay, so how does constructive logic look? So this is going to be a sort of a little bit of digression, but I will sort of jump right back to what we had seen earlier. In constructive logic, we have formulas. So we have, so this is implication. So this should be A implies B. And then we have disjunction. We have true. I have not added faults for a particular reason.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

The ideas will become clear as we go along through the lecture. And then you can have atomic formula. Sun shines is an atomic formula that is always true. So then you can, so we write down a derivation in this logic. We use this syntax. It says, so A1, A2, A3 up to A n are assumptions. And X1, X2, Xn are the names for those assumptions.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

And the way to read this is under the assumption that A1, A2, A3 up until A n holds. A holds. So that is the reading of this. I'm sort of using the same constructs that I've used in type checking. And there is a reason for this. It will become clear. So here is an example. I can assume that C holds. And I get this assumption in a name C. I'm not going to use this in any interesting fashion, but the name still is there.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

Assuming C holds, I'm saying that given A and B holds, A and C holds. This is true. The proof is going to look something like this. Given A and B holds, I know A holds. And from assumption, I know C holds. So given that A holds and C holds, A and C holds. So hence the proof. So this is sort of the shape of the constitutive logic. And just like we wrote down the inference rules,

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

we can write down the deduction rules for the constructible logic. So the idea here is... Okay, so there is a question. Sree Shah says, sir, as an excluder middle, does not hold this. No, you... no, no. Good question. So you cannot take that as an axiom is what I meant. So A implies A holds.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

But in order to show that A implies A holds, you have to construct a proof. So again, this is very abstract. So think of... use carry-out correspondence, right? If I want to show that there exists a function of type inter-wind, I actually have to write a function that has type inter-wind. So I can give a successor function as a proof for the proposition. I cannot use the law of excluder middle as a proof technique.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

I cannot say by contradiction something holds. I always have to provide a proof. Okay, so that's the answer to that question. Yeah, let me get back to this...

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

... ...   ... ...

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

... ... ... ...  ... ... ...  ... ... ... ... ...  ...     ... ... ...

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

... ... ...

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

... ...  ...  ... ... ... ... ... ... ...    ...  ... ...  ... ... ...

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

...  ...  ... ... ... ...  ... ... ... ...  ... ... ... ...

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

... ... ... ... ...  ... ...   ...  ... ... ... ... ... ... ... ...  ... ... ... ... ...

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

... ... ... ... ... ... ...  ... ... ... ... ... ...    ... ... ... ...    ... ...

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

... ... ... ... ... ... ...   ... ... ... ... ... ... ... ...     ...

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

...  ... ... ...   ... ... ... ...  ... ...  ... ... ... ... ... ... ...     ...

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

...  ... ... ... ... ...      ...  ... ... ... ...    ... ... ...  ... ... ... ... ... ...  ... ... ... ...

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

... ... ... ... ... ...   ... ...  ... ... ... ...  ... ... ... ... ... ... ...

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

... ... ...  ... ... ...  ... ... ...  ...      ...  ... ... ... ... ... ... ... ... ... ...   ...  ... ... ... ... ...

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

...  ... ... ...    ...  ... ...  ... ... ... ...  ... ... ... ... ... ...  ... ... ...

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

... ... ... ... ... ... ... ... ...  ...  ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

... ... ... ... ... ... ... ... ...  ... ... ... ... ... ... ... ... ...

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

...   ... ...   ...   ... ... ... ... ...   ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...    ...  ...

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

...  ... ... ... ...  ... ... ...  ... ... ... ... ... ... ... ... ... ... ...  ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

... ... ... ... ... ... ... ... ... ...  ... ... ...

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

... ... ... ...

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...   ... ... ... ... ... ...  ... ...

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

... ... ... ...       ... ... ... ... ... ...  ... ... ... ... ... ...

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

... ... ...  ...  ... ... ... ... ... ... ... ...  ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

... ... ... ... ... ... ... ... ...  ... ... ...  ...

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

...   ... ... ... ... ...  ...

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

...       ...  ... ... ...  ... ...       ... ... ... ... ...   ... ...

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

... ...  ...  ...

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

... ... ... ... ...   ...  ... ...   ... ...  ... ...  ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

... ... ... ...

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

... ...  ... ...

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

... ...   ... ... ... ... ... ... ... ...   ... ... ... ...  ... ...

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

...  ... ... ... ... ... ...   ...   ... ... ...   ... ...  ... ... ... ...   ... ... ... ...  ...  ... ... ... ... ...  ...  ... ... ... ... ...  ... ... ... ... ... ...

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

... ... ... ...  ... ... ...

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

... ... ... ... ... ... ...  ...  ...    ... ... ... ...

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

...   ... ... ...    ... ...

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

...       ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

... ... ... ... ... ... ... ... ... ...  ... ... ... ...  ...  ... ... ...  ... ... ... ... ...  ...

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

... ... ... ...   ...

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

...

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

...

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

...

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

... ... ... ... ... ...  ... ... ... ...

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

...   ... ...  ... ... ... ... ... ... ...    ... ... ...

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

...  ... ... ... ... ... ... ... ...  ... ... ... ... ... ... ...  ... ...  ...

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

... ... ... ... ...  ... ...   ... ... ...  ...  ... ...

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

... ...  ...

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

... ... ... ... ... ... ... ...   ... ... ... ... ...   ...

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

... ...

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

... ... ... ... ...  ...

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

... ... ... ... ... ... ... ...       ... ...  ...  ...

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

... ... ... ...  ...  ...

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

... ... ... ...  ... ...

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

... ... ... ... ... ... ... ... ... ... ... ... ...  ...

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

... ... ... ... ...

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

... ... ... ... ...  ...  ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

...

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

... ...  ... ... ... ... ... ...  ... ... ... ...

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

... ... ... ...

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

...

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

...

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

... ... ...

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

... ... ...  ... ... ... ... ... ... ...

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

... ... ... ...

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

... ... ... ... ... ... ... ... ...  ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

... ... ... ... ... ...  ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

... ... ...  ... ... ...  ... ... ...  ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

... ... ...  ... ... ... ...

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

... ... ... ... ... ... ...  ... ... ...  ... ... ...

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

...  ... ... ... ...  ... ... ... ... ... ... ... ... ... ...  ...  ...

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

... ... ... ...

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3300.0s_

...  ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...

---

![slides/interval_0111.png](slides/interval_0111.png)
_t = 3300.0s -- 3330.0s_

... ... ... ... ... ... ... ... ... ...  ... ... ... ... ... ... ...

---

![slides/interval_0112.png](slides/interval_0112.png)
_t = 3330.0s -- 3360.0s_

... ... ... ...   ... ...  ... ... ...  ... ... ... ... ...

---

![slides/interval_0113.png](slides/interval_0113.png)
_t = 3360.0s -- 3390.0s_

... ... ... ...  ... ... ... ... ... ... ... ... ... ... ...     ... ... ... ...

---

![slides/interval_0114.png](slides/interval_0114.png)
_t = 3390.0s -- 3420.0s_

... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ...  ... ...

---

![slides/interval_0115.png](slides/interval_0115.png)
_t = 3420.0s -- 3452.0s_

... ... ... ... ... ...  ...   ...    ... ...  ...

---
