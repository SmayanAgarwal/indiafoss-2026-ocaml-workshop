# 33-cs3100-pop-lec-33-gadts

**CS3100 POP - Lec 33 - GADTs**  
id: `jAa7Z6wx9Wo`  
duration: 3050s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so continuing from where we left off, right? So, okay. So this is going to be the last lecture on GADDs and low-camel. Just to set the plane for this lecture. So what we're going to see is we're going to look at the tail recursive reverse, right?

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

What we did in the previous classes, we said, okay, tail recursive reverse is difficult to write directly. And we sort of saw how to write a recursive, non-tail recursive reverse using this additional app1 function. So the reason why we couldn't write this tail recursive reverse was that we needed a tail type-level addition, right? And OKML does not support type-level functions natively. So what do you want to do when you want to say type-level addition?

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

I have some search numeral, right, which represents some number. I want to take another number and then add them together. So we can't do this natively because there is no notion of functions of the type-level. So addition is the function that takes two integers and then returns an integer. The integers here are type-level numerals, right? We don't have that functionality natively in OKML. But what we can in fact do is we can construct explicit proofs of type-level additions.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

So even though we won't have functions, we will construct certain terms whose existence means that we can prove something about addition. Okay, so that's what we are going to do first. And we are going to use that in order to write a tail recursive reverse. Okay, so that's the setter. So how are we going to do this?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

So we are going to do this with the help of a plus type, right? So what I'm defining here is a type plus that has three type variables, okay? So the way you have to read this type variable is if I give you a value of type alpha, beta, gamma plus, abc plus, then you take that to be the proof of C equals a plus b.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So each one is going to be a type-level numeral. And the way you have to read this is if I can construct a value which has the type abc plus, then you have to take this as a proof of C equals a plus b. Okay, so that's the reading. When you see some value having the type abc plus, you read it as C equals a plus b. Okay, we have two constructors for plus.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

I mean, these are specially tailored for the tail recursive reverse. But you can imagine having other constructors as well that say something about the addition. But we are going to look at very specific constructors here, okay? So the first constructor is plus zero, right? Whenever you have plus zero, I assign it the type znn plus. Okay, so what does this mean, right?

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

The reading is that the value plus zero, having the type znn plus is the proof for zero plus n is n. Okay, so zero plus n equals n. I mean, this is obvious. So what we've done is we've sort of explicitly given the type for plus zero constructor to be zero plus n is n. Okay, so whenever I have some value which is zero plus n is n, which is going to be the only value which is plus zero,

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

you sort of read that as a proof for the zero plus n is n. And the second one we have is plus shift constructor, right? And it has the abscs plus as the parameter, right? In order to construct a value using plus shift, you have to provide it a plus value. If you provide that plus value, the type that you get back is,

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

the value that you get back has the type asbcs plus. So how do you read this, right? So the way you read this is take a look at this type, right? It says abscs plus. And if you just translate it to the usual arithmetic, you will read it as a plus b plus one equals c plus one, right? So the way you read this is if you can give me a proof for

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

a plus b plus one equals c plus one, then using this plus shift constructor, I can construct a proof for a plus one plus b equals c plus one. We believe that this is true, right? But what we've done here is we've explicitly constructed this by hand. We're saying if you give me a proof for a plus b plus one is c plus one, then I can give you a term whose type is going to be the proof for, sorry,

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

the term whose type is going to say a plus one plus b equals c plus one, which is essentially the proof for a plus one plus b equals c plus one. Okay, so this is quite a bit abstract so far, but just getting the intuition now is enough, right? We'll see how we are going to use this. So what can we do with these terms, right? We have two terms that we can construct. We can construct terms using plus zero.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

We also can construct terms using plus n. So if you just look at the type of plus zero, which run this cell. So let me do this just once. I need to run everything that is before this cell and all of all. So this should get me the definition of zero and the successor.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

Now if I go back and run this one, it should work out. And now if you sort of look at the type of plus zero, right? Plus zero says, okay, the fact that you have a term plus zero is the proof that zero plus some a equals a. Okay, so these are polymorphic, right? So you can sort of think about this as any number at all. You can specialize this, right? You can specialize this alpha here to a particular number using explicit types.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

This way, right? I take plus zero and all I've done is for alpha type, I've given z SSS, which is three, right? And this has to be the same alpha. So z SSS will be the last argument as well. The way you read this is a proof for zero plus three is three. Okay, right? So I've got something that is zero plus three is three. And what does plus shift do?

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

Plus shift simply given something, it takes a S from B and then moves it to A position, right? If you give me something which is BS, I'll give you something that is AS and B. And using this idea, you can just take SS from the second argument and push it to the first argument and essentially, and you can play around with it.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

But the idea is that what we've constructed here is the proof that two plus three equals five. Right? So we've sort of constructed a proof that two plus three is five. This type of description is essential here. If you don't do it, it just says two plus some number is two plus that number. That is what it's saying, right? Zero SS is two. This is some N. So two plus N is N plus two is what it's saying.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

So if you, and you can specialize this alpha to any type. So I specialize this to three. So you'll have three here plus two, which is five. Okay, so that's why you get the two plus three equals five. So this seems very explicit and very cumbersome, right? But what do we get in return? So the high level idea that we have here is from a Curry Howard perspective.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

So we've seen Curry Howard isomorphism and we studied sensitive data calculus. So the way we look at ABC plus is approved that A plus B plus C is A plus B equals C, right? And what is this office? So types like these, right? Which are the sort of encoding properties that we know implicitly. So we know how arithmetic works. And what we're doing is we are making this concrete using GAR.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

And what GAR it is give you here is a convenient way of programming with proofs as first list objects. When I have some term which has this type, then I know that I have something in my hand which tells me that two plus three is five, right? And the program also understands it. So the underlying implementation also can manipulate with this using the other

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

constructors and the ways to take it apart, right? So that's the idea here. We will use this technique to convince OCaml that this Taylor-Curtis reverse is going to crystal the length, right? That's what we're going to do. We'll see how that works out. Questions, any questions on this? What we're doing here? I'll wait for a minute and then I'll proceed.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

Okay, so I think the utility of this will become clear when we look at the implementation of Taylor-Curtis reverse. So let's do that next. So here is Taylor-Curtis reverse without GAR.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

This is what we have written in our initial lectures. So what we've done is we have a recursive function which is reversed which takes a list and accumulator. If the list is empty, then you return the accumulator. If the list is non-empty, then you reverse the rest of the list where the accumulator is going to be take this head element and append it to the accumulator. So if you keep running this, everything will be reversed and for

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

the initial accumulator, you pass the empty list, right? So given an L, you'll get back the reverse of this L. But what we have to, the challenge here is to show that convince OCaml that in the case where lists have lengths, if this list has length m and this list has length n, then the resultant list has length n present, right?

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

So that is what we want to show. And we are going to use our explicit proofs that we construct for plus for this. So here is the actual implementation. I've annotated it, but we will go through it step by step, okay? So first thing to notice is that reverse now takes an extra argument, right? Reverse takes the first argument, which is the proof that m plus n equals O,

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

right, and says if you give me a list which is of length m and you give me a list which is of length n. So this is the L argument, this is the accumulator argument, right? This is the L, this is the second one is the accumulator. If you give me a list of length m and an accumulator whose length is n, I will return you the result whose length is O.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

And we have the explicit proof that m plus n is O. So we pass the proof of m plus n is O explicitly, right? So how does this help? So there are three arguments, proof, the list L and the accumulator. So we have proof, the list L and accumulator. So what we do in this implementation is we first pattern match P and L, right? So there are two patterns for P, right? The first pattern is plus 0.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

So when P is plus 0, we know that its type is going to be 0 plus n is n, right? And if you just substitute these values in the original list, m is 0, right, n is n and O is also n. So if m is 0, then this m is 0, right? And the only value which will, the list value which will have 0 length

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

is the nil constructor, right? The only list which will have 0 length is the nil constructor. So we only pattern match with the nil constructor here, right? So because this is plus 0 and we know that m is 0 here, it can only be the case that L is nil, right? If L is nil, then what we do, if you just look at the previous implementation,

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

right, if L is nil, we just return the accumulator. And that is precisely what we are doing here. But importantly, we are also proving that the length of the recital list is n. How is this proved? We know that list of length 0 is the only construct is nil. And we know that accumulator has length n, right? And we have to show that the resultant list has length n. And this is achieved just by returning the accumulator directly.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

And this convinces OCaml type checker that if you call reverse with plus 0 and nil, because plus 0 is a proof that 0 plus n is n, the resultant list will also have length n. Okay, so this is the base case for the proof. And because we have the proof that 0 plus n is n,

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

we can convince OCaml that the resultant list here, this O is also n. Okay, so that's the base case. The next case is the recursive case, the inductive case, right? So we have one more constructor for plus, that's plus shift. Okay, so the pattern that we match pattern matches plus shift B prime, right? So if you look at the type of plus shift, what is the type of plus shift?

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

Plus shift has some AS here, right? And that is going to be the pattern for M. So that is going to be M. And because we have AS, the only sort of constructor in list which has non-zero length is the cons constructor, right? So that is why we pattern match with L here. That cannot be any other pattern here, right? Cannot be nil in particular.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

So because this has the type AS as the first type variable, so it has to be cons, right? And we are going to do something. So in order to see how this proof works, rather than speaking about this in some abstract term, we can actually look at a particular example. Let's say that the initial, in this particular case, right? M is going to be five, right? Accumulator is going to be of list length three.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

So if this is five, this is three, and the result will be of eight, right? Five plus three is eight. So that's going to be the result. So let's explicitly consider that plus shift P prime is going to be the proof that five plus three equals eight, right? When I say five plus three equals eight for plus shift, it means that the list of length, sorry, the L list is going to be of length five. The accumulator is going to be of length three.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

And the result, I have to show that it is going to be of length eight. Okay. So, okay, so I know plus shift P prime has a type of five plus three equals eight. So what is the type of P prime? Right? Just look at the constructor here, right? This is five, right? The second term is three, and this is eight. So if plus shift of P prime is five plus three equals eight, then P prime, the thing that

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

is in plus shift, the value that is sort of encapsulated in plus shift has the type. So A S goes to A, right? Which means five minus one equals four. B goes to B S, right? So if this is three, then this will be four. And C S remains C S.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

We know C S is going to be eight. So this is going to be eight. So what is the type of P prime? The type of P prime is four plus four equals eight. Right? Five minus one four, three plus one four is eight. So the type of P prime, because plus shift P prime has type five plus three equals eight, by construction, right? Because we've constructed the value this way, P prime is a proof that four plus four is eight.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

Okay, so we have P prime, which is four plus four is eight. Okay, so let's keep that aside for the moment. We know L is going to be of list length five. And L is going to be a non empty list, right? It is going to be a cons by construction of the list data type, right? Cons constructor tells you that if the list length, sorry, L is going to be of length five, X is going to be of length four. Okay. So we have Xs, which is length four.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

And we know accumulators of length three. So if you cons and X to accumulator, it is going to be of length four. So we have constructed Xs, which is of length four and cons X of accumulator, which is of length four. And that's the recursive call argument, right? If you look at the previous example. So we are going to recursively call reverse with Xs and cons of X accumulator.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

So this is of length four, this is of length four, I have to prove that the resultant list is going to be of length eight. So because we need to explicitly construct proof, we need to explicitly pass an argument which which convinces OCaml that four plus four is eight. And handily, that is what we have in p prime, right? P prime has the type four plus four is eight. So we call reverse with p prime, which is the proof that four plus four is eight.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

We pass the first argument Xs, which we know that has length four, right? Thanks to the way we constructed the list. We know that cons of X accumulator has length four, right? Again, thanks to the way cons constructor holds the proof. And because we explicitly pass the proof, we know that the resultant list is going to be of length eight. So the original list here had length eight, the resultant list can be proved to have length eight as well.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

And that is why OCaml is convinced now that this recursive call, right, reverse p prime, p prime, Xs, cons, X accumulator also has length eight. So this this generalizes, right? So the same way you can say this is if this is m plus n equals O, then this then this resultant list will also have length O. So these are the two cases.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So this is precisely how you will sort of if I were to ask you, write a paper proof that reverse deserves the length. This is the exact reasoning that you will apply. Right. So you will sort of say, Oh, here is how you do it. What we are doing here is we are actually using OCaml in order to mechanically check the proof, right? We are not writing by hand that we can make a mistake. We are actually encoding certain properties about numbers, right, which are easy to understand.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

And we are using those properties to mechanically verify we are helping the computer. Computer is actually helping us to verify this proof. So this proof is said to be mechanically verified. And that is precisely what we have here.  And that's that's the tail recursive reverse. So all we have is an explicit proof here. And we've clearly cleverly constructed the proof to match the recursive arguments.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

And that works out. So that's how you do type level additions. So how do we actually use this?  So this is this is going to be the instrumentation that we are going to work with. Again, I'll stop for a minute, right, because this is different from what you've seen before. So if you have any questions, you can ask now.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

Okay, so we'll see how we actually use this in practice, right? We'll look at an example. So what we are going to do is to reverse this list, which has 012.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

Right. So this list has length three. And I'm going to call this reverse function. In order to call this proof carrying a reverse function, I have to give it the proof that three plus zero equals three. So three is the length of the original list. This is the initial value of the accumulator, which is zero. It will return me two and zero, right, which will have length three.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

But because of the way we return this program, we have to explicitly construct the proof that three plus zero equals three. Right. So how do we construct this proof? We do this exactly as what we had looked at earlier. Right. So you use the plus zero constructor and plus shift constructor. So if you ignore the type here, right, if you don't explicitly specialize the type, what you will get is it says three plus n is n plus three. Right. The proof that we need is three plus zero equals three.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

So we specialize this alpha to zero. Right. By an explicit type. And this says that three plus zero equals three. And how is this helpful? So we've constructed the proof that three plus zero equals three. I call the reverse function with the proof and the list zero and two. Excuse me. And the empty accumulator for the initial argument.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

I need to run this. So if you run this function now, you get the reverse list, right? Two, one, zero. And you have the length that is going to reflect the correct length of the list. So we have the list which is composed of integers and the result and this also has a length three because this this has been three and we have explicitly proved that three plus zero equals three.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

And the fact that this this result and list has length three comes from our proof. You cannot construct with these constructors. You cannot construct the proof that three plus one equals three, for example, because the initial constructors that we've done are valid. They are consistent. So that is why you cannot construct illogical proofs. OK.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

So this seems all very roundabout, right? We are writing a proof by hand and then we are using it for the simple function. This seems very, very cumbersome. Right. For any filter function, for example, how are you even going to think about constructing a group? So this is where you hit the limit of what OCaml can do, right? OCaml is a pragmatic function programming language which has other features, right? It is used to implement real programs.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

Even though it can do simple proofs like this, OCaml is not a language that is built for proving properties about programs. So what we've done here is we've actually proved that reverse precise length. Even though OCaml can do this, we don't normally do this in OCaml. You can prove much deeper properties about the correctness of programs. And other functional languages like Haskell, there are other advanced languages like AgDye, Driss and F*, which can remove this burden of proof construction.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

They have different ways of doing this. But for example, in F*, you don't have to explicitly construct proofs. You just have to write these terms and then it will automatically prove it for you. It will use some technique to prove it for you. We are not going to look at any of that in this course. If you are interested in learning all of those fancy techniques, you should register for programs and proofs that I teach in the next semester,

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

where we will see all of this idea taken to the next level. So what we will see is how do you reason about the correctness of your program, but actually not just on paper. We don't just do paper proofs and we are happy. We will actually use the compiler to mechanically verify that the program will not go wrong. This is much, much stronger. If the program is correct according to a specification, the specification that we have is...

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

The specification that we have for reverse is if you give me M plus N, that is O, right? We've mechanically verified that this is not going to go wrong at all, because at each step we've been very, very precise. And we will see a lot of these examples in this course, programs and proofs. And this is really cutting edge work on how to prove that any code that you write is functionally correct.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

And there are lots of techniques for making it easier and we will study how these techniques work. Okay, the last example that I want to talk about is another data structure, which is trees, right? So we've sort of looked at lists so far. There are some interesting properties that you can do on a tree. We are just going to... This is just going to be a teaser, right? I'm not going to go too deep into this section. There are lots of tree properties that you can write.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

And the tree property that we are going to look at specifically here is a perfectly balanced tree. Okay, so what is a perfectly balanced tree? Let's start with the ordinary tree type. So a tree, an alpha tree is either an empty tree or a tree with the left sub tree and the right sub tree and a value in the node. Okay, so there are two constructors. And of course, this particular tree is not constrained.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

The only constraint that we have is that it's a binary tree. So you can have a right skewed tree. So why is it called right skewed? Observe that the left hand side is empty and the right hand side has a value, a sub tree. And again, the left hand side is empty. The right hand side has a value. The left hand side is empty. So the values are all on the right hand side. This tree is called right skewed. And similarly, you can have a left skewed tree where all the right sub trees are all empty.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

So that's the left skewed tree. And here is a perfectly balanced tree. A perfectly balanced tree has some value and the left hand side and the right hand side happen to be the same trees here. But the definition is that they are perfectly balanced. The spine is all the same. The values might be different.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So that's the perfectly balanced tree. To show you, this is also a perfectly balanced tree. The value just happens to be different.  So we are going to. So what we want is this property, right? This perfectly balanced tree is a shape property. So we are enforcing a property on the shape of the tree. So can we restrict the question we are asking is, can we restrict this tree type so that the only trees that you can construct are perfectly balanced trees.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

You cannot even write this tree. So this would be like the type checker will say this is not a valid construction. The only construction that will be allowed is a perfectly balanced tree. How do we do this? So before that, we're going to look at a few tree operations that we will look at later as well. So here's the depth of the tree.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

A depth of a tree is defined such that if the tree is empty, then the depth is zero. If the tree is non-empty, then it is one plus the maximum depth of either the depth of the left tree, left sub tree or the depth of the right sub tree. And we have the top. Top function. So top function is going to return the value of the top. Top of the tree. This is like list of head.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

It is, of course, possible that the tree is empty, in which case there is no top. So we just return none. If the tree is non-empty, we just return the value. So that's the definition of top. And here is a function, swivel. So swivel, given a tree, you see a mirror image of the tree. Right. So if you take the tree, if you get a mirror image that is going to be swivel.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

So swivel is defined recursively. So if the tree is empty, then its mirror image is empty. If the tree is non-empty, right. Take the swivel the right hand side of the tree, right, and put it as the left sub tree. Swivel the left hand side, left sub tree and put it as the right sub tree. And the value remains the same and you construct a tree out of it. Right.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

So you recursively swivel, but you also swap left and right. So this should give you the mirror image of the tree. You can work out why this is the case. So that given a tree returns a tree. Right. So we've defined three functions. Now we will look at how to define this perfectly balanced tree. So we are going to use GADs to force the shape.  So what's the trick here?

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

The trick is that we are going to have a depth argument along with the alpha argument that we have for the tree. Right. So we all this type as G tree. G tree has elements of type alpha, but it also has a parameter that represents depth. And the things that can go here are the type of numerals.  So an empty perfectly balanced tree, an empty G tree is going to be an alpha Z G tree.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

So the depth is zero. So it is going to be an alpha Z G tree. And here's the clever bit. The tree constructor, right, the non-empty tree constructor takes three arguments as usual. The restriction is that this argument, the depth of the left hand side is the same as the depth of the right hand side. It must be the same as the depth of the right hand side.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

They're all going to be the same kind of trees and the value is going to be alpha. And what we say is if you construct a tree using these three components where the depth is N, where the depth is N, you're going to get a new tree whose depth is N plus one. And the value type is the same. So it's sort of saying the only way you can construct the initial tree is empty and the other constructor, the only other constructor that you have is the tree G, which expects the

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

depth of the left hand side sub tree and the depth of the right sub tree to be the same. And what you get out is a tree with the depth N plus one. Right. So so here is an example. So I need to run this. So here is an example. This is the same example is that what we had seen earlier. Observe that this carries the type, the depth here, right? That this is the depth is three.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

So we have the depth here. And the question you want to ask is what if I replace this with, say, empty G? Right. This won't work out. And the reason is that observe that the constraint that we have on this three G constructor is that these depths will have to be the same. Right. For the left hand side, the depth is two. Right. And the right hand side, the depth is zero. And that is what compiler is complaining.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

Right. This has depth zero. And I really want to be which has depth two. And that is why it works out. OK, so the one day values that you can have for this type G tree are going to be perfectly balanced. OK, so that's the way we restricted. And we can do nice things with these G trees.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

So here is the same functions that we had seen earlier. We are going to look at it again. So here is that function again defined on this G tree. So given a G tree, a perfectly balanced tree whose depth is some N, we are going to return a depth as usual. So if the tree is empty, then the depth is zero. If the tree is non-empty, we say the depth is going to be one plus the depth of the left

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

side. Observe that we initially in the unconstrained tree, we had a maximum of depth of left and depth of right. Because we know that the tree is perfectly balanced and the types actually constrain the values to be only perfectly balanced. We don't need to even check the depth of the right and right tree, right sub tree, because we know that by construction, it's going to be the same.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So we just compute the depth of the left sub tree and it is one plus the depth of the left sub tree that is going to be the depth of the original. So we are using the fact that we know that the type is constrained in order to optimize this function. OK. And here is the implementation of this top element. The idea here is the same as the one that we had for the safe list head. We statically rule out the case that this function cannot be applied on an non-empty tree.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

So here is the top function. It expects a tree which has a depth of at least one. When you have a depth of at least one, the only constructor that you are going to have is this tree constructor. You cannot have the empty constructor because that has depth zero and that is captured in the type. So you can return the value directly. So observe that this is alpha, not alpha option, as it used to be earlier.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So the idea here is the same as what we had done for list not head. So here is Swivel. The thing about Swivel that we know holds true but was not captured in the type. If you look at the earlier type, Swivel says, give me an alpha tree, I'll give you an alpha tree. It says nothing about the fact that the resultant tree will also be have the same

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

depth, for example. And that is what we captured here. This type is strictly stronger than the previous one. The Swivel type here says that give me a perfectly balanced tree whose depth is n. And I am going to return a perfectly balanced tree whose depth is the same. So all we are doing is we are just adding this type annotation which captures the type.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

The rest of the function remains the same. There is no change here. So what we've proved here is that if you give me a perfectly balanced tree of depth five, I will return you a perfectly balanced tree of the five. Right. Again, this is a partial specification, right? It is not a full specification. What do I mean by that? It says only something about the depth of the tree.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

It says something about the spine, but it says nothing about the values. So it might be the case that so this is for example, right? This function also satisfies this type. Swivel is supposed to only produce the mirror image. So the type here only captures the fact that the depth is the same. It says nothing about the values themselves. So the values can change. So this is an illustration of what when we say a program is verified, right?

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

This this function is verified. You have to sort of qualify what you are verifying. Even the initial instrumentation verified certain things. It said if you give me an alpha G tree, alpha tree, I'm going to give you an alpha tree. So the reading is that if you give me an integer tree, I'm going to return you an integer tree. That is sort of saying that is verifying some property, right?

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

The integer type is preserved. This is going further, right? It says that if you give me an integer perfectly balanced tree, I will return you an integer perfectly balanced tree of the same depth. Right. But it says nothing about the values. So if you want to fully verify this, you have to go a little bit further, but we are not going to look at it. But it is important to sort of recognize what you are verifying. So whenever we write a function, we have sort of we have several properties in mind.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

The thing that we are verifying is an additional property, but not full verification. This is not a full specification. But anyway, so this was further than what we had from earlier. OK, so the last operation that we are going to see is zipping to perfectly balanced trees. So we observed just to get you give you an example.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

So if you have, say, 0 1 2 and they have, say, 5 6 7, you can zip it together. Zipping just means that in the simple case, it is going to return you a list which has 6 2 7.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

So this is what you have to be a comma. So given two lists, it will sort of take the first element, take the first element from the other list, put them in a tuple. And return recursively do this and return a list which has this property, right? That the elements at the same indices will be put together in a tuple. Of course, if you look at the actual implementation of zip, right, it has to contend with the case that this can be of different length.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

So what is the behavior of zip here? Do you ignore this value or do you sort of say, I will add a zero as a default value here? What is the semantics? But if you sort of say, I know for a fact that my zip function is always going to be applied on lists of the same length.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

We've seen how we do this, right? You take a list which is length index and you say that zip function takes two lists which are of the same length and the function only works on the list of the same length and returns you a list whose length is the same. So we haven't seen this function, but you can imagine writing this function, right? I would encourage you to try writing that function. We are going to apply the same principle for trees, right? Zipping trees has the same idea.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

If you have two trees, right, I want to zip them together so that the values that the same positions are put together in a table, right? But you have the same problem, right? The shape of the trees might be different. So zipping might not work perfectly, but because we have perfect trees, right, perfectly balanced trees and we have the depth argument, we don't have to handle any of these corner cases, right?

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

So we are sort of defining a function that can zip trees which are perfectly balanced and which have the exact same shape, right? So here is a zip tree implementation that says that give me two perfectly balanced trees, one of which contains alpha values, another which contains beta values and ensure that the depth of the trees are the same. Right? So these two perfectly balanced trees only differ in the values that they have.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

The spine of the tree is the same, right? And if you give me a tree, two trees, which satisfy this property, I will return you a perfectly balanced tree whose values are alpha star beta. So you take an alpha from here, beta from here, you put them together. That would be a perfectly balanced tree and the depth of the tree is going to be n. Right? So that's the guarantee that this type ensures.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

And so a curious thing happens here, right? If the two trees are perfectly balanced, then you pattern match the two trees, x and y this way. At every step, right, the shape is going to be the same. So the only patterns that you have to take care of is empty, empty. The two trees can be empty, in which case the resultant tree is an empty. Or the two trees could be non-empty at the same time.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

So the left, the first tree is going to be LVR. The second tree is going to be MWS. Right? And the result is going to be a new tree where you zip the sub trees, the left sub trees, L and M. Right? We call zip tree on L and M. And similarly for the right sub tree, R and S, we zip it for the right sub tree.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

And for the values V and W, we just put them in a tuple. Right? So if you run this function, OKML does not, OKML says this is fine. Right? It also does not generate any warnings. In particular, if you sort of think about it, right, we don't even have to handle the case where the first tree is empty and the second tree is non-empty or this first tree is non-empty and the second tree is empty. This has to be 3G.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

This is guaranteed not to happen thanks to the type.  We don't even have to handle this case. It's not that you're making this assumption and then you're pattern matching and throwing an exception. Oh, unexpected thing happened. OKML can statically prove the pattern matching compiler sort of says these two cases need not be handled. These cannot even occur.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

So if you try to do something, which is say empty G, 3G underscore, say fail with impossible. So OKML is sort of saying, what are you doing? This case cannot even occur. So it's sort of it knows that if the left hand side tree is an empty tree where the depth is going to be 0, the right hand side tree must be 0. That is what it's saying.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

So this is going to have some type S, but it is not possible that 0 is equal to some n plus 1. So this case is not even necessary. So you can throw it away. And that is what it is by us. So we are writing a specific. Zipping function that only works on perfectly balanced trees of depth n. But we also have the static guarantee that we will have no other possibilities. So we statically ruled out all of those cases.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

Yeah, so that nicely comes to the end of the G.A. lecture. So what we've done here is we sort of. Written some functions that. Are constrained by shape and G.A. It is allow us to constrain the shape of the tree and write functions that are sensible. So the areas are just to summarize. Right. So we have we have seen a lot of the examples using the areas which are very disparate.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

Right. G.A. It is have this very special property that they are they're not very complicated, but they add a lot of. There are a lot of. Features that are not enabled by this ordinary data types. So all we are doing is we are sort of encoding richer properties in types and G.A. It is help us do that. I'll stop here.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

And that concludes our OCaml parts. We will start looking at the solar parts from tomorrow. And if you have any questions, I'll hang around for a minute or two and then you can ask those questions.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

So your last assignment is going. Sorry, not the last one last OCaml assignment. The next assignment is going to be on G.A. So you will play around with these ideas. Yeah, so I'll try to release it early so that you can get started if you want it. OK, looks like there are no further questions. You will have questions when you start doing the assignments.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3042.2s_

So feel free to keep the questions coming in the Slack channel and then we'll try to answer it. Yeah, from tomorrow we'll start looking at the poll. Thank you.

---
