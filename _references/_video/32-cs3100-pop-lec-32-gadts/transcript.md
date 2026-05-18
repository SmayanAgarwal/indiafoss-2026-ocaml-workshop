# 32-cs3100-pop-lec-32-gadts

**CS3100 POP - Lec 32 - GADTs**  
id: `3klWC6B-YqM`  
duration: 3358s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay. So, yeah. So, what we are going to do now is we're going to continue looking at GADTs, right? So we are going to sort of what we had seen in the last class is we saw a few examples of using GADTs for specific purpose. One thing we did is we looked at how we can encode what we achieve with modules, these

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

abstract types using GADTs and we also looked at the interpreter, right, earlier. So what we will do in this lecture is we will continue looking at a few more examples. And the hope is that you can sort of see how programming and proving properties about programs sort of get close to each other.  So, we have seen this Karihawat correspondence, right?

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

When we studied simply deblambagal, what we said was, oh, you have this notion of Karihawat correspondence which sort of says whenever you write a program, you can sort of look at it as an equivalent to writing a proof for a proposition, right? And the types are actually the ones that correspond to the propositions that you want to prove, right? So the connections sort of are not just like an observation and we move on.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

These connections are actually how we sort of rigorously reason about the correctness of programs. In particular, there is this whole area of programs and program verification which is built on top of these sort of ideas. And JRTs give you these simple building blocks with which you can sort of play around with program verification, right?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

And this sort of hints at the idea of what the area of program verification is and the hope is that you can sort of see these properties through the lecture. I mean, even simple type systems are sort of a simple way of doing program verification, right? So when a program says it type checks, it is sound with respect to memory safety and so on, in no camera at least. So we sort of extend the idea for arbitrary properties that we want to prove and that is what we've been doing and we'll look at more examples that way.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So don't think about these as like individual ideas, but they sort of are the particular manifestation of this wider idea of encoding richer properties about your programs using types and JRTs allow us to express rich types and that is what we've been doing so far. Okay, so that's the setting and the first example, the class of examples that we're going to look at in this class is generic programming.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

As I mentioned, generic programming is this idea of writing useful functions that are polymorphic over the shape of the actual data that they operate on. So you might say, oh, I want to define a map function over a list, then you can define a map function over a tree, but then if you have.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

So instead, what you really want is implementing these functions exactly once, right, I want to do it exactly once and I want to able to reuse it elsewhere. So this is the general idea of genetic programming and we are going to look at a particular useful function, right, and the function that we are going to look at is encoding pairs.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

Okay, so we have we have these functions first and second in OCaml. So in OCaml, we have these functions in the standard library. If you run these functions, you will see that first and second are functions that operate on pairs, right, A and B, and then return you the values A and B correspondingly. So first gets the first element of the pair and second gets the second element of the path. But of course, the path data type itself is just this instance of a larger class of data

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

types, right, which are tuples of arbitrary size. So this is a tuple of that contains exactly two elements, but we can also have three, four, five and so on. In particular, these first and second functions are defined for two tuples, right, tuples that have exactly two elements. These functions cannot be applied to tuples that have three elements. For example, look at this, this is first applied to a tuple which has three elements.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

And if you try to apply it, OCaml will complain that this has type ABC, right, this tuple has type ABC, but it expects something that has just two components. So this is unfortunate, right. So I want to say there will always be a first element if you have these tuples which have at least one element, right, that can be applied to any size tuples.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

That's what we are going for. Okay, so how do we do this? So for this, we are going to define our own tuple type, right, based on GADTs. And the idea, the overall idea is that we will encode tuples as a list that has heterogeneous values, okay. So each of the elements in the list will have different type values and that's the encoding

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

of a tuple. So what do we start with? So we started with a type U that has no inhabitants. So this is another way of writing inhabited type in OCaml where we just introduced a bar. I think we've seen this earlier in one of the lectures, I don't remember which one particularly. I think when we introduced the simply type lambda calculus lecture, we looked at the

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

zero type, right. We said the zero type has an analog in OCaml and the way you do it is you just define a type with no variance. So the only thing that we have is an empty bar, but it simply says that this particular type does not have any constructors, right. So it is an uninhabited type. I named this type U, okay. So and then I have this heterogeneous list type that has an alpha which I sort of left

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

and said I just use a underscore. It is basically a list type. So it has a nil and a cons, right. And the nil constructor has the type U H list. So this alpha argument, I just fill it with U just so that I need some type there. I use U there. The interesting bit is the cons one. Okay, so the cons constructor in a list type takes two elements, right, the head and the tail.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

The idea here is that the head could be alpha and the tail is a beta H list. So it's a different type heterogeneous list and the thing that you get out is a alpha star beta H list. So the idea is that it actually represents the type of both alpha and beta in the resultant list.  So this is fine, but if you look at an example, this would be very clear.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Okay, so what we are doing here is we are constructing a tuple, a heterogeneous list that has three values exactly. So it has an integer, it has a Boolean value and it has a floating point number. And finally, it has nil. So observe that this is sort of if you use a regular list in OCaml, this would be ill type, right. Because regular OCaml list expects all of these values to have the same type, we have different values here.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

And if you evaluate this, the interesting bit is the type that you get. The type that you get is an n star bool star float star u, right, which says that this is a heterogeneous list, right. You can sort of view this as a tuple as well. This is a list that has exactly three values. The first value is an integer, the second value is a Boolean and the third value is

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

a floating point number. And this is precisely what a list, a tuple with three values will have, right. I have say in sorry, one true, say 10.4. So that's the exact information that I have here. So this says it's a tuple with three elements in bool and float. This also says the same thing. So we sort of encode tuples using heterogeneous lists this way.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

The type actually says that it has an integer Boolean and floating point. Okay, so this is how we encode the type helps us encode arbitrary length tuples using GREDs. Okay, so the interesting bit is we want to define the first and the second then functions based on these heterogeneous lists. So how do we do that? So here is the definition of the first function.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

Okay, so the first function can be applied on a heterogeneous list that has at least one element, right? So it says there has to be an alpha and the rest of the list. So that could be anything at all that could also be you. So I'm saying if there is at least one element and the first element, the head element in this list is alpha, then the first returns alpha.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

Okay, so all I'm saying is give me a heterogeneous list that has at least one element, right? Alpha and anything else that could be even an illness, then I will return that alpha. Okay, so this is the type that I explicitly give and the and the implementation itself is very simple. So because we restricted this type to have at least one element, the only constructor that can apply here is cons, right?

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

nil cannot apply because this type will not match. If you sort of look at nil here, for nil it is u list, right? u is a concrete type that is not a pair and the only thing that has this shape, this a star b is a cons constructor, right? a star b only occurs for the cons constructor. So we only pattern match on the cons constructor and first simply returns the first element of the pair, right?

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

And so we can keep applying this for arbitrary depth, right? We can say second. So second expects a heterogeneous list that has at least two elements, right? And the way to read this is there is some first element which I don't care about because the second is not going to look at it. There is going to be a second element. Let's say that type is alpha and there is going to be arbitrary number of elements in the tail, zero or more elements. I also don't care about it.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

If you give me such a heterogeneous list, then second will return the alpha, right? This alpha. Right? So that's the type that we give and the function itself because we've actually said that this heterogeneous list will have two elements at least. This is the first one, right? This is the first one. This is the second one. We can pattern match exactly with one pattern, right? We can pattern match with the two application of cons, right?

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

I don't care about the head element. I care about the second element and that is what the second function returns, right? And similarly for third, there has to be at least three elements. I say that the third element should have the type alpha and the third function itself returns this alpha. And because I restricted my type to three or more elements, I can pattern match with three cons. I ignore the first one.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

I ignore the second one and the third one I just return. Okay. So if you do this, the type that you get is quite nice, right? It says that if you have an alpha beta heterogeneous list, then you get the alpha. If you have a BAC heterogeneous list, then I get the alpha here for second. Then for third, I don't care about these types. First two types, I care about the third one alpha and the rest of the list could be anything

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

at all. If you apply, if you give me such a list and apply third on it and I get, I return you alpha. Okay. So how does this work in practice? So in practice, right, because we've sort of said the types of first has to be at least one element, right? It can be applied on a heterogeneous list with at least one element. First can be applied for on any N tuple with N greater than zero.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

And similarly, second applies on any N tuple with N greater than one. So the length is greater than one. So here is an example, right? I apply first on the original example that we had. So 10 true and 10.5. If you apply first on it, you get in 10 out. And I can also apply it on a list with two elements. This also works. The thing that doesn't work is say if you don't satisfy the precondition, right?

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

So the precondition for third, if you sort of look at what do we mean a precondition, the expectation of an input type, right? It only works on a heterogeneous list that has at least three elements. So N must be greater than two. If you give a heterogeneous list which has exactly two elements, say, this won't work out. And it won't work out statically, and that's the beauty of this method, right? So here is a list that has two elements, that's true and 10.5.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

The type of this will be some bool float u heterogeneous list. So which says that this particular heterogeneous list has two elements, right? And because third expects something which has at least three elements to work with, because it is extracting the third element, this will not work out, right? So T has type bool float u H list.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

The way to read this is it is a tuple with bool and up float, right? It's a pair, and I'm applying the third on it. And what does third say? Oh, this expression that you supplied me has type bool float u H list, right? But in order to apply third on it, I want this u to be some alpha beta. So it has to be some alpha beta so that I can extract the alpha out, is what the error is saying.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

So we've statically ruled out, right? We've statically ruled out the possibility of a third being applied on a tuple which has less than three elements. So what we've done is generic programming. Why is it generic? Because the first, second, and third, first and second, right? Unlike OCaml, where it can only be applied on pairs, now it can be applied on any n tuples.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

Of course, you have to use this particular syntax and construction to use it. But that's what you gain as a result. So you can have richer types, and richer types give you better programs. They actually express programs which are generic over the structure of the actual underlying type. Any questions on this one? I'll pause for a moment.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

It's okay if you don't understand the exact mechanisms here, right? You will have enough opportunities in your assignment to play around with it. But the idea, the overall idea is the important one, right? The idea that you want to take away is that we are defining functions which operate over different shape structures, right? And that's generic programming, and that's enabled by the fact that we have the areas which allows us to define the return type.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

So these constructors are a bit cumbersome. Is there a way to get rid of them? I agree. I think they are a bit cumbersome, right? Because you have to use it as cons, cons, cons, nil. You really want to write it as true 10.5. In OCaml, you can't. That's a simple answer that I'm going to give. There are syntax extensions where you can sort of use it in a clever way.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

But the way OCaml evolved, right? OCaml is a language that's been around for 25 years. So when the language was initially implemented, we did not even know what GADTs were. The concepts that we are studying here landed in OCaml 4.0, which is seven or eight years before. So there is no syntactic support for defining these in a nice way. So that's the short answer.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

But you can imagine having a richer language in the future, right? Maybe OCaml itself might evolve where we have syntactic support for these things. But no, these are a bit cumbersome. Yeah, so there is no easy solution for it. Good question. I think that's a ease of use is certainly one of the things that we want to have when we program. And that's why we don't, our default way of writing tuples,

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

we don't use GADs even though they are much more powerful, right? GAD construction of tuples because of the syntactic overhead. So if there is a nice way to reduce the syntactic overhead, maybe this will become much more widely used. Okay, so there seem to be no more further question. Let's move on to the next class of examples, right?

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

So we'll sort of look at a whole series of examples where we enforce shape properties based on types, right? So first thing that we are going to look at is length indexed lists. Okay, so what do I mean by length index lists? Let's look at an example. So this is what we've been doing so far. We'll sort of motivate our ideas with examples. So some of the list functions in the OCaml standard library are quite unsatisfying, right? So we have this function called list.head and list.tail,

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

which when applied to an empty list, right? It raises an exception. This is what it should do, but raising an exception is a runtime failure, right? It is not a static failure. So really what I want is because we've been using types all the way, right? You say, oh, types are great. Types are doing a lot of work for us and so on. But types are not helping us here because the type of head is just alpha list to alpha.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

And alpha list includes the nil list as well. So if you pass a nil, it returns an empty list. I mean, one thing we've done in the past is we said instead of alpha list to alpha, rename the function as alpha list to alpha option, where if it is head, it returns a none. That is okay, but that is also cumbersome, right?

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

Because you're sort of moving the problem elsewhere. You're saying, okay, whoever uses the head function should handle both the none case and some case. It would be nice, right? If I can sort of say list.head should be only applied to lists that have at least one element, right? We've seen this idea of at least in the previous example as well. So what do I need for that?

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So I need a notion of length encoded into the list type. So every construction of a list also includes the notion of how many elements are there in the list. And I will say that the head function can be applied to any list that has at least one element, right? So that's the idea that we are going to go for. And that is what we mean by length index lists, okay? So we want these to be statically caught, this list.head and this.tail to be statically caught.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

So the way we are going to do it is instead of the list type just saying what the content type is, it is also going to encode what the length of the list is as a type, right? And yeah, so I just said all of this. Let's implement our own list type, which will statically cache these errors. And the idea is to encode the length of the list and the type of the list. Okay, length of the list and the type of the list. And what the trick that we are going to use here is our encoding of search numerals.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

So we looked at search numerals in lambda calculus in the lambda calculus encoding lecture, right? And we said, oh, here is how we encode integers and here is how we do additions and so on. So for encoding lengths in the type, we are going to use search numerals. If you sort of think about it, right? Why can't we use, say, the integers that we have in OCaml?

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

So the integers that we have are values, right? We want and they are at the term level. So when I write 1 or 0 or 10 or 1 million, these are all terms, these are all values, right? These are all things that live at the term level. So we actually want integers at the type level. What do I mean by type level? I want an ocean of a 1 and a 0 and 2 and addition and subtraction in the same level as where I have, say, integers and floating points and interes and so on.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

So there is this type here, there is terms here. What we need for encoding length index list is we need a type level encoding of integers. And that is why we use our encoding of search numerals. So, okay, so how do we encode integers in the types? So here is how we do it, right? So the idea is quite similar to what we had done with the search numerals.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

So I define a type Z, right, which has a single constructor Z, right? And I define this. So this is an ordinary type, right? So I'm not using GID here. And then I define this type quote NS. Okay, so that has a single constructor. Okay. And the idea is that if you give me some n type, right, I will return you an NS type.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

So this seems a little bit strange. What is this doing? So you can think sort of think about this as a successor, right? A successor type, which given some integer n gives you n plus 1. So this is zero. And this is defining how to get n plus 1.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

The way you have to construct it is using this S constructor. The idea is that if you give me a type that represents the integer n, then I will give you a value whose type is going to be n plus 1. Right? This is all very abstract. So we'll make it more concrete. So if I just type Z, I get Z. This value is of type Z because that's obvious, right?

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

So the way to read this is this is an value whose type is going to be zero. Okay. And the way to read the SZ. So you can apply S constructor on any type n, right? And what it returns is a quote NS. When you write SZ, you get back ZS. And the way to read this is that this is the encoding of type 1, right?

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

This is just the equivalent of the natural number 1 in the type level, right? This is similar to that. And you can keep doing this, right? And what you get is ZSS. And again, the way to read this is this is the type level encoding of the integer, the natural number 2. And similar to what we saw in lambda calculus encoding, the number, the integer representation is the number of SS that you have.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

So if I have one more S, then that's just, so you read this type as 3, right? A type level encoding for 3. Okay. So that's the basic idea. I mean, the takeaway is very simple, right? You just count the number of SS and that's the natural number at the type level.  So that's that. Any questions on this encoding?

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So, okay. So we are going to use this in an interesting way. Okay. So our usual length, a list type does not have any encoding of length. But what we're going to do is we are going to add this additional property.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

So we define a length index list as something that has two type variables. I'm not naming those type variables. But the idea is that this is the usual type variable alpha that says what the content of the list is. What is the type of each element in the list, right? And the second type variable is the new one that encodes the length of the list. Okay. And this is quite curious. This is quite fun. Right. So I say that there are nil and cons constructors as usual.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

But when I write nil, I give it the type alpha z list. Right. And whenever you see a value of type alpha z list, right, because there is a z here, I know that this list has no elements and the only constructor that has this type is the nil constructor. Okay. So the type itself encodes the length of the list, which is zero here.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

And the only list value that has the type that has the length zero is nil.  And look at cons. What is cons to cons take some head, some tail and then puts them together. Right. So cons says that give me an alpha, right? That's the head. Give me an alpha list that has length n.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

This code and you read it as give me a list of length n. Then I will give you a list which whose contents are alpha and the length is n plus one. The way to read the n s is n plus one. So con says that if you give me a list that has a tail whose length is n, I will give you a list whose length is n plus one. Right. The length is actually encoded here.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

And and that's that's the key property. Right. So length is now encoded as part of the list. So here are some examples. So this is nil. This is list with a singleton list and this has two elements. And if you look at the types, you can see that this is alpha zero length. This is a list that has integers and has length one. That is exactly one element here. And this list has also has integers and has length two.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

And correspondingly, you have two elements in the list. OK, so that's that. Now we can write safe head and tail.  So now that we have the ability to sort of distinguish the lists based on length and we have polymorphism as well.  We can say that head and tail can only be applied to lists that are at least one length and more.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

OK. So so we are going to define the head and tail function so that they can only be applied to non empty lists. So here is the definition of head. Right. And the way to read this is that head takes a list which has some alpha. The type of the elements is alpha and the length is going to be some n plus one. Right.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

And the numbers, the natural numbers started zero.  And because I restrict the type to be n s and could be anything, it could be zero as well. But in that case, the n s type will be one. Right. So the smallest list that head will accept is a singleton list. And when you have a singleton list, you know that you can you have at least one element. And hence I can return that element alpha here.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

And because the type says that it has at least one element, you don't even have to match for the nil case here. The company that actually knows. Right. So I pattern match L. I get the only pattern that they can get this once. Right. Because of the type that they have here. And I get the value and I return it. Right. So I define the function.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

It says that give me a list that has at least a length of at least one. And I'll give you the head element here. You can apply to cons and you get one. If you apply to nil, observe that earlier we got an exception at runtime. Now it's statically says that this particular expression expression nil has type alpha z list. That is a list with the length zero.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

What an expression of was expected of type alpha beta s list. Right. And it says that the length has to be at least one. So it is type z zero is not compatible with the n plus one. So you cannot write zero as some n plus one where the base case is actually zero. So this is quite nice. So we've we've sort of got both. Right. We have static safety, but also we don't have an alpha option here. We just have an alpha.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

So that's the advantage of doing this. And the thing that I mentioned, right. So the fact that the type actually says that the only constructor that can apply here is cons. The company doesn't even want us that we are not matching the real case because the real case cannot occur. Nil nil construct that will not have this type. No constructor will have the type alpha z s sorry alpha z list.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

It won't have n plus one as the length. So what is the advantage of this? The compiler can actually generate more efficient code. Now it doesn't have to even test whether the L is nil or cons. It knows by construction that the only possible case that you have is cons. So using the I.T. is you actually get more efficient code.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

We won't delve too much on this, but you actually help the compiler to generate more efficient code because there is no test here to test whether L is nil. We just say we know that this is cons and that avoids one branch essentially in the compiler and that leads to more efficient code. I mean this these incrementally add up. OK, so.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

Yeah, similarly, you can do tail. Tail also says that give me a list that has at least one element. And I will get you get you. OK, so maybe I should probably say that it takes a list that has n plus one elements. And tail gets the tail of the list. So the length will be one less. So the contract is that if you give me a list with n plus one length, I will return you a list with n length.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

This is gone here as the difference. And the type says that the return the list that is returned has length one less than the input list. And and because we have an N S here, the one possible constructor that we have is cons and we just return X is the values themselves are not interesting. The types are the ones that are interesting. We actually enforce.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

We say something about what is the length of the list that gets returned and we use tail. And yeah, so you can you can do this and the first one had two elements and you got a list with one element. But the length also says that it is one. And similarly, the length for the second case, right. But you had a singleton less zero. You get nil back and the length is zero. OK, so that is head and tail.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

So these are safe and then tail. So this goes much beyond just head and tail, right? This property is very, very cool because a lot of the things that we've been doing when we are writing programs or lists is that we had an implicit assumption about what certain functions do. For example, when we wrote a map function, right? We said that map function takes an input list takes higher order function, applies the function to each element of the list and then returns a new list.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

The type only says that it's a it takes alpha to be the function alpha list to be the list. It says nothing about the fact that map and incorrect map might just return a list with one less element or one more element. Our implementation, we have not sort of seen any of that, but there is no specification in the type.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

The type doesn't tell you that this map function, if you send it a list with 42 elements, it will return a list with three elements. That was not captured in the specification. But we can do that now. We can actually write a type for the map function that will ensure that the length of the input list is the same as the length of the output list. So the implementation itself is not any more complicated. It's the same thing, but just look at the type, right? So I'm writing a recursive function map, right?

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

Where there is some and some length.  It takes this higher order function alpha to beta. It takes a list, which is an alpha list with length n and it returns a beta list whose length is also n. These because these two ends are the same. The contract that we have is that the length of the output list is the same as the length of the input list. And the type checking just works out.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

So you don't have to do anything more to prove that these lengths are the same. And the way it works out is this way. So this is a higher order function. This is a list argument. You match the list. If the length is if the list is nil, then the length is zero. And we just return nil out, which also has length zero. So zero, zero matches. So this particular property is satisfied. For n, this could be zero, zero.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

That is fine. What about cons? Cons. There is a cons here. So the length is going to be some n plus one. And for the recursive argument, we just use the type as a proof. We just say whenever you apply recursively, this property is satisfied. So if it is n, then it is going to be n. So this thing works out.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

The thing that we have to prove is that the length of this list is the same as length of this list. So we have a cons here. We have a cons here. And we have an Xs here. And we have a map of Xs here. And because the map function has a type which says that if you call it on some n, length n, the result will also be length n. You can directly apply that. If this is some length five, this will also be length five. When you put it in a cons, that will be length six.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

And this will also be length six. And hence, the compiler has actually proved that it can type check the function this way. I mean, I'm explaining all of this. But if you sort of just look at the type, it is so natural. The proof is actually done for you by the compiler. So yeah, so you get this map function which carries the proof that it will preserve the length of the list.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

OK. Any questions on this? So what if the function definition may or may not give size n? List of size n. n is anything, right? So you can. So can you sort of clarify what you mean? So I can apply map on any length list.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

So one x arrow x. I can apply it on an L. That works out. Or filter function. Yeah. OK. You're asking really good question. Filter is you cannot do filter with the GRET encodings.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

I mean, I couldn't say you cannot. You can do it. But it's a bit cumbersome because the fact that an element survives. In the final list is dependent upon what the function does. The filter function does what the predicate is. The predicate could be anything. The predicate could even examine some server. It can Google for whether this function should be this element should be part of this list or not.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

So when you have higher order things, it sort of breaks down. But yes, filter is not something that we will see. It's sort of not. It's sort of not see it, but you can't encode filter function using this idea. The observation is that the predicate function is arbitrary. It is during complete. And we cannot reason about what that function does. You can go a bit.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

If so just to answer your question. One step further, but don't expect to understand the answer is that if you know what is the problem with during complete function, right? During complete function, but also this has some effects as well in OCaml. You want to prevent the function to be consulting Google dot com, right? You don't want this function to do that. So if you sort of say the function is performing I.O.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

I don't want any of that. So you can say that the function, the predicate function should be pure. It shouldn't do any effects, but it also has to be terminated. This is like during completeness is a problem because you don't even know whether the function is terminating. You don't even know whether you can reason about it. So if you have if you have pure functions that are also terminating, then certain things are possible.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

We won't look at any of those in this course, but I happen to reach a course in the next semester, which is called programs and proofs, where we will see all of these extra things that you can do. So you can actually implement the specification of filter exactly as it should be. So so that's all I will say about this because it's going far beyond.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

So what if you don't apply? Yeah, if you don't apply any size restriction, then it's fine. So yeah, so you can just write a filter function. And that's that's the filter function that we apply, right? We say it could be any length. It could be any other length. That is fine, but that's not useful. So I can also give it this type here. Right. Let me just say. So here's a type. This won't work out, is it?

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

Yeah, this would work out. But the point is, yeah, this this has the same type as this one. So so if I if I were to be able to write a map function of this type, right? I am not claiming anything about the length here. Right. So I say n m input list is n output list is m.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

Even though this doesn't work out, we can make this work. That's not a problem. The point here is this is not a useful property. So you can always make it more relaxed. But the question is what you can what you really want is to say the final length of the list is going to be exactly. Some less than whatever elements were filtered out. Right. That's the useful bit.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

But yeah, but in OCaml, it's a bit tricky because we don't. OCaml language itself is very explicit. We will look at certain languages in the next course that we will study. Those are those are lots of fun. They just take these ideas to the next level. You should take the course if you want an answer to that question. Can we have streams encoded as GADTs? Yes, you can. You should try it.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

Yeah. So I think you cannot reason about the length there, but you can possibly reason about other sort of properties because streams are infinite. We are doing lengths here, but you can do other things. Yes, you can do streams and put it as a GAD. Let me continue. I have a little bit more to cover. So I've sort of shown you examples where it is easy and works out. There are certain things where the.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

Just like filter, right? We asked this nice question about filter and I told you that filter is not easy to implement. There are also other functions that are not easy to implement, but we will see how to implement this by the end of this lecture. So here is a function that is a tail recursive list. This is what you've written earlier. We've seen this earlier. So if it takes an accumulator, right? I want to reverse the list. Then if it is nil, then return accumulator.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

If it is cons, then reverse the tail of the list. And all you do is take the head and append it to the accumulator. An initial accumulator is empty and you keep on doing this. You will get the reverse of the list out. So what is the property that we want for the reverse, right? If you give it a list of length five, then the result list also has the length five. OK, so this seems like just as simple as doing this map function.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

But this is a lot more tricky to work. Why? If you just think about it, right? What is the type of this function? This function has the type reverse, right, which takes alpha n list. So it takes some list whose type is n. It takes an accumulator, right? Accumulator is also a list. It takes an alpha m list. M could be anything at all.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

That's not the same as n list, right? But what is the final contract? The final contract is that the list that you get has alpha, but the length of the final list is going to be m plus n, right? This n plus m list, right? Initially you provided an empty list and that satisfies this contract. But every recursive call also satisfies it, right?

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

So the first call, this becomes one. This becomes n minus one. And the final list is going to be n minus one plus one, which is going to be n. And similarly, n minus two and two, n minus three and three and so on. So every recursive call, you satisfy this property. The problem is that we have not looked at how to do additions in arithmetic so far. Sorry, in the type level arithmetic so far. We just encoded numbers. We have no operators except successor and predecessor, right?

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

We know how to take apart the numbers. We know how to put them together. But we've not seen any examples of actually how to do additions. So this is going to be a little bit tricky. We will come back to this because we need to see how to encode additions here. But we can encode the non tail recursive functions, recursive reverse function with the helper function. OK, so we need this helper function.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So the point here is the high level thing is we are only going to use the property of successor. Even an n, we know how to compute n plus one. We're just going to build the entire reverse function based on this. So I have this curious helper function here, which is called append one. There is some, it says that there is some length n. Give me a list of length n and give me an element. And I'm going to give you a list of n plus one length.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

And what it's going to do is to take this one element and append it to the end of the list. So it's going to take that one element and append it to the end of this list. So it takes the list l, takes a value v, and all it's going to do is l append it to a singleton list v. And because I'm not using any arithmetic here, I'm not performing additions or anything here. I just know how to construct the successor of an n.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

That is what I'm using. The function itself is trivial. So if the list is empty, then the thing that you get back is a singleton list with v. If the list is non-empty, so you keep recursively applying app one on the tail of the list with the same input argument v. So this works out because if this is length n, this will be n minus one.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

And this says that this is n minus one plus one. App says that if you give n, this is alpha, then you get n plus one. Because x's length is n minus one, this will be of length n. And when you add a cons, it will be n plus one. And that is the contract that we wanted here. So this works out. And using this app one, you can implement reverse.

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

So this is a non-tail recursive reverse. This is not a tail recursive reverse. So the contract that it says is, if you give me a list of length n, I'll give you a list of length n. The type of the elements is the same. It says nothing about the fact that the elements are not changed or whatnot. But we have more additional properties than what the typical reverse will give you. And the implementation is very straightforward. So the list is going to be l.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

And if you give me an empty list, then the result will be an empty list. If you give me a list that has a head and a tail, I'm going to take the head element, and I'm going to push it to the end of the list. And I'm going to reverse the tail of the list. So I take the head. I add it to the tail. But I'm also going to call reverse on the tail of the list. So each element gets reversed.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

So this works out. And you can apply this on reverse of this. And it works out. So it says it has length one, two, three. And the result also has one, two, three. Sartak has a question. So why do we particularly need the app one function? Why can't normal recursive function itself work?

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

So if you write this function, let's say, let me try to. Actually, I don't have that function.  So here is the question. Here's the answer to you. So what is the reverse function saying? Reverse function is saying that if you give me a list of length n, then I get a list of length n out.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

So if you give me zero, then I gave you zero out. If you give me length n, some n, which is not zero, let's call it n plus one for simplicity. Excess I know is length n. And I should prove that whatever expression I get on the right hand side is a list that has length n plus one. That's the contract. If I assume that this has length n plus one, this should also have length n plus one.

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

So that's what I should prove. By use of this cons constructor, I know that excess has length n. If excess has length n, reverse of excess also has length n. I know that reverse of excess also has length n because of this type that I have. So when you type check recursive functions, the recursive function application, you just take that as a given.

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

You can sort of use the inductive cases as a proof. Yeah, precisely. So app one, you don't have anything about app one. And that is going to be append. And you don't want to prove arbitrary append. You precisely got the point. So I don't want to prove the property of append for arbitrary length append. Because when you do it on arbitrary length, this could be left hand side could be n,

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3300.0s_

right hand side could be m, and append has to prove that the resultant list has n plus n, the length has n plus n. So that is why we specialize this app one function because I'm sort of restricting myself to the right hand side being exactly one element. And that is why I needed this helper definition, which shows a given a list of length n and element you get n plus one and the proof works out.

---

![slides/interval_0111.png](slides/interval_0111.png)
_t = 3300.0s -- 3330.0s_

You've actually proved that this is also n plus one now, given that this is n plus one, this is n, excess is n, reverse of excess is n, and app one, given a list of length n, returns you a list of length n plus one and ends the proof. So yes, you're right, Sathak. And that's the reason why we need app one.

---

![slides/interval_0112.png](slides/interval_0112.png)
_t = 3330.0s -- 3353.0s_

We will come back to all of these complicated questions in the next class. But the high level takeaway is this. We have a reverse function which carries the proof that it preserves the length. So that's the takeaway here. I'll stop here. If you have any more questions you can ask, there is a little bit more to cover. I'm hoping that I can finish that in the next class.

---
