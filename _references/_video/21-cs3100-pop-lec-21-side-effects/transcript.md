# 21-cs3100-pop-lec-21-side-effects

**CS3100 POP - Lec 21 - Side Effects**  
id: `HOyxQTU6JEE`  
duration: 3273s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

All right. Okay, you should see the question question now. Let's start from where we left off. So we're looking at side effects. And we were looking at how to reason about programs that use side effects, right? In particular, we saw this idea of aliases. And we also introduced the concept of physical and structural equality.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

And we saw an example how to interpret what happens when you ask questions about physical and structural equality. So the other thing that happens when you add side effects to a language is that type system gets a little bit complicated in unusual ways.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

So one of the ways it gets complicated is this idea of value restriction. So this concept has a name, but let's keep that aside for the moment. Let's just look at a very simple example that motivates why what happens when we add side effects to OCaml. So we have a purely functional language. We add side effects. Something interesting happens. Consider this program. This program is very simple. So it says that R equals an empty list.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

And then it says, oh, create an alias for R, which is an int list. And then R1 is an int list. Actually, R happens to be an empty list, so that's fine. And create R2 such that R2 is a string list. So I am explicitly ascribing types here. So you don't need these types. I am using these types for a particular reason. I'm saying R2 is string list.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

And it has the same value as R. So these are just values. So the value of that is going to be an empty list. So that is also fine. And then I say, OK, return a pair of R1, R2. So both of these are empty lists. So the value is empty list. But because we had explicitly ascribed the types here, the pair will have the type int list star string list. Int list star string list.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So the only thing that is interesting here is R has type alpha list. Because it's an empty list. Empty list constructor is the same constructor for arbitrary list contents. So R itself has type alpha list. But otherwise, nothing is surprising here. You've seen this example previously. And nothing is going on here. So let's modify this example in a simple way.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So let's just do, actually, let me clear all the executed outputs so that I don't give away the surprise. Restart and clear output. Restart and clear outputs. OK, so now we had this example. Yeah, so we saw this example. I'm going to modify this example in a very small way. I'm going to say instead of an empty list, I'm going to make R a reference to an empty list.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

So I create a ref cell that points to an empty list. OK, and then correspondingly, I'm going to change the type of R1 and R2 such that they are now int list ref and string list ref. So that this is int list and string list here. But here, because I'm adding a reference to a list here. So this becomes int list ref and string list ref. And I simply return the pair of R1 and R2 now.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

If you run this program, you get an adder. So we get a compiler that says on line 3, like this line, R happens to be an int list ref. But an expression that is expected of type string list ref, because I say R2 is a string list ref. So the right hand side expression must be a string list ref. But what I have here is an int list ref.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

Type int is not compatible with type string. So the question you have to ask is, OK, why is this program showing an error, but a similar program here is not raising an error. The only thing that I've done is I've added a ref here and I've changed the types correspondingly to add refs. Why is the compiler complaining? Yeah, Sartak has the right answer.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So is this because each cell can hold only. Yeah, that's that's exactly right. It is because each cell can only hold one type of value. And in order to in order to see what can happen, right, it is better to ask the question of what happens if you allow the cell to hold different sorts of values. If this program were allowed, what can go wrong? So here is.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

So let's first look at how OCaml is sort of catching this error. So OCaml has this idea of value restriction. And if you look at the type of ref of empty list. So the thing that you see here is it's not an alpha list anymore. It is this thing known as port underscore week.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

And so what this says at a high level is that this particular R is only weakly polymorphic. What does weak polymorphism mean? Weak can be unified with exactly one type. So you can unify if you unify it with say integer, that particular type gets specialized to integer. You cannot unify that with a string later. I wouldn't go too deep into what weak polymorphism is, but I'm just going to give you examples and try to explain what is going on.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

That is the concept, right? That's the high level concept. You can have something weakly polymorphic. It can get unified with one particular concrete type and that's it, right? You don't have the usual polymorphism which says if I have an alpha list, I can use it in a string list and an int list place. But why does this value restriction exist? So this is the example.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

Let's say we just take the same first three lines. I'm writing this in the slide as a markdown and not a cell because this wouldn't compile. If you run this code in OCaml, this wouldn't compile. I want to make a point here. Let's say R is a reference to an empty list and I say R1 is the same alias. It's an alias to the reference to an empty list.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

I ascribe the type int list ref and similarly R2 is an alias. I give it the type string list ref. Now, because R1 is an integer list reference, I can store in it an integer list. Because it's a reference to an integer list, I can store an integer list into it. I'm going to take the singleton list one and I'm going to store it into R1. Now, R2 and R1 are aliases of the same underlying ref cell.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

So because R2 is a reference to a string list, I can read, I can dereference R2. I dereference R2. What do I get when I dereference R2? Because R2 is a string list reference, I will get a string list. I'm going to get the head of the list.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

So the list head should be a string and I'm going to print and line the string. So you can see what is going on wrong here. If I actually am able to do this, I will get an integer. I won't get a string. So at this point, the thing that I will get out will be an integer, not a string, because R1 and R2 are aliases of the same thing. And this is this breaks type safety, right? So we are storing in an int list in R1 and reading it out as a string list through R2.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

And this is bad. And so that's that's the reason why we have value restriction in the first place. It turns out that value restriction was actually something that the original designers of a language, a precursor to OCaml called standard ML, did not come up with in the original standard. So they formalized the they initially implemented the language. They added references. And the first version of the language had this bug.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So they had to go and fix the specifications such that they added value restriction into the language. So this is not something that it seems so obvious when I explain it to you. But for the initial designers of the language, they didn't think about this case. And it is not surprising, right? So we don't always design languages with full proofs of correctness all the time. So Java, initial version of Java also got a concept called subtyping wrong because it got the concept called subtyping wrong.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

And subtyping, Java, unlike OCaml, which can erase all of the types, we saw type erasure earlier, right? So unlike OCaml, which can erase all the types, Java has must do dynamic type checking for array type busting. Details are not important here. But the point is language designers do get the design strong. And you have to sort of live with it forever in the case of Java.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

But in the case of standard ML and OCaml, we sort of knew how to not live with it and actually fix it and break code that uses that feature. Anyway, so if this feature were allowed, it breaks type safety. This code will take fault, right? If I run it in OCaml, if this code type checks. So this concept called value restriction exists.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

In OCaml, value restriction is implemented as a syntactic check of what expressions are allowed on the right hand side, right? What expressions are allowed on the right hand side, right? If the expression on the right hand side belongs to a particular class, right? I won't define what the class is. The details are not important here. Then the variable that is on the left hand side of the expression gets a weakly polymorphic type. So because this is weakly polymorphic and you first unify it with the int list reference, right?

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

The type gets unified to an int list reference. And here, because this is a different type here, which is a stringless reference, int is not compatible with string. Details are beyond the scope of this course. It's not important, but it is important to know that the concept called value restriction exists. And here is an example of what can go wrong if value restriction did not exist. Okay, so how is value restriction relevant to you?

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

So when you write programs in OCaml, you can do partial application. So since value restriction is implemented as a syntactic check, it is not precise, right? There are examples where something is okay to be fully polymorphic. But because of the way value restriction is implemented, which is an approximate way of saying it's conservative, right? So it looks at the right hand side expression.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

It just says, okay, this fits to this class of things, which I don't know, which might go wrong. So I'm going to give it a weakly polymorphic. So here is an example that shows up in practice, right? When you do partial application. So here is an example. So I defined this function called swap list. What it does is it takes a list of pairs, pairs of values. And for each element in the pair, it swaps it.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

When you have the pair A, B swapping is B, A, right? For each of the elements in the pair and returns a new list. And the way I implement it is through partial application of map. So I want to do a map over each element in the list. And for each of the elements, I'm going to take A, B, and I'm going to return B, A. So this is a partial application of a map where you only provide the higher order function.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

And if you happen to apply swap list with the list L, then what you end up getting is the swap list. But if you look at the type of this, it is a weakly polymorphic type because function application this way, in lead binding, happens to be one of the patterns where OCaml says there can be arbitrary effects here. So I'm going to make it weakly polymorphic. So that's the idea. So what is the problem? So let's look at the type, right?

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

The first type seems OK, right? It takes a polymorphic thing, week two, a polymorphic thing, week three, a list of those things, and returns a week three, week two list. But it so happens that these are weakly polymorphic. The problem is that if you use this in a context, the swap list, in a context where you apply it on two different types, so here is an example.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

So I apply swap list first on a singleton list with integer one and string hello. So the result I would expect is a singleton list again where you have a hello and one, right? And I again apply swap list on one comma one, which is integer integer. So you get one one. You should get one one out. But if you run this program, I mean, if you compile this program, OCaml will complain because swap list is weakly polymorphic.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

The first application here forces unifies the types with integer and string. This becomes int string list and string int list. And because this is weakly polymorphic, this gets unified. So here it is expected that the type here is an integer, the type here is a string, just like the previous application. And that's not true. And here we have an integer.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So OCaml complains this expression has type n, but an expression is a big drop type string. So this is what you'll get. But there is an easy fix for this. If you happen to encounter value restriction, so weak polymorphism, when you apply partial application, you can just do eta expansion. So recall that eta reduction takes an expression, which is lambda X, M X, and then reduces that to M. So eta expansion goes the other way, right?

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

If you give some arbitrary lambda term, eta expansion just says, add a lambda to the front, lambda X, and then apply that X. So here is an eta expanded version of the original expression. So what do I mean by eta expansion? I just take L as an argument here, right? And I apply L. So the original definition happened to be a partial application, right? I did not take an L. I did not apply an L. I was using the idea of partial application.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

Here, I'm not doing partial application. I define a function that takes one argument, and here it's fully applied, right? List.map, the higher order function, and list. This happens to be an expression. It's not a let binding of variable, but a function. So this weak polymorphism does not kick in, right? And you get a fully polymorphic type that you would expect, which is alpha, beta list, and beta alpha list.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

And now this example works. So it is a takeaway from this section is it is not important to know what all expressions will trigger weak polymorphism. But if you encounter weak polymorphism while programming in partial application, you just eta expanded. You add the additional binder, right?

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

You define it as a function. It will go away. So that's the trick to get across weakly polymorphism. Okay, so that that is weakly polymorphism in OCaml. So, so far, what we've seen, we have introduced the references, right? And all of the discussion has been about references. So references are one way to introduce mutations, mutable features in OCaml.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

OCaml also has this concept of mutable record fields, right? So you can think of mutable record fields as how you would operate on a structure and see. So that there is going to be syntax and semantics. We'll first.  So there is a question in the chat. I'm going to try to answer that. Why is partial application considered to be weakly typed without going into details, right?

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

The the expression on the right hand side is a function application, right? And here I'm defining a variable, right? This is some some term. It's it's just a binder. It's not it's not a function definition. It's just a binder. And I'm doing a function application here. So the high level idea is that when you do function application, there can be arbitrary effects internally,

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

which might end up doing something similar to this one internally, right? Because OCaml cannot when you do type checking, right? You don't actually go and look at the definition of the function. You just look at what those types are and try to apply.  So OCaml is sort of assuming that there are arbitrary effects, which it cannot reason about when you do this let definition when you define this variable.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

But here you're defining a function. Right. And this is not because you're defining a function that does not apply. Actually, there is a there is there isn't a precise definition of when to do value restriction in OCaml or the or the standard ML.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

So both of the languages are ML like languages which take Lambda calculus, right, and add mutations on top. So these are these are approximate. Right. So it's hard to give a precise definition of why it should be considered. So I'm not going to give details because that goes beyond the scope of the course. You don't need to understand the details is what I would say. But if you are interested, you should just check for the you should search for a paper called.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

The relaxed value restriction in OCaml, I think that defines that defines the original value restriction and how OCaml does value restriction in a relaxed fashion. It actually allows weak polymers. So I'll just refer you to that paper. So let's move on. Okay, so mutable record fields. So there are there's going to be syntax and semantics.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

So for syntax, when you define records, we've seen records earlier. In records, all you define is a label and a type, you can make fields mutable in the record by just adding this mutable keyword to the front.  And in particular, references in OCaml are actually just a syntactic sugar over the mutable record fields.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

They actually have the same representation internally. So whenever we define this type alpha ref, what we are actually defining is a record, right, with a single field called contents, whose whose type is alpha. Right. And it's a mutable record field. So you can change the contents of this record.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

So that's the idea here. This is exactly how references are defined in OCaml. So references are not even though we saw references is a primitive thing earlier. References are in turn implemented with the mutable record fields. And yeah, you can you can just create a record just like we used to earlier. So here is a ref function that we saw earlier, which given an initial value creates a record with contents set to that value.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

So you just create a record, right, where you say contents equals x, right, that creates a record. And dereferencing, getting the value is the same as the record syntax. So when I dereference a reference, all I do is I use the dot syntax. So the record dot contents, which is the label for the field. And the additional thing that we have on top of records is this way to update the context.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

So assignment, right, of reference to a new value is done like this. So you take the record dot contents, right, left arrow, like less than minus new value. So this is sort of a syntax that we use for assignment to records. So that's all we have for records. Right.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

And yeah, OK, so let's look at how we use it with an actual example. So the point is you can do so, OK, well, is a function programming language, but you can write because of all of these beautiful features, right, you can write programs that you would naturally write and say C. So we are going to look at a program for the writing doubly linked list. So this might seems seems strange, right?

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

You have this functional language. We've been saying how functional programming is so great and so on. But why would you want a doubly linked list? The linked list has a particular nice property, right? You can just if you have a reference to some element in the list which you need to delete, you can delete that in constant time. So this is not true with the list definition that we've seen so far, right? Because the list definition is defined like an onion. So you have the head and the tail head and tail head and tail.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

If you want to delete one element in the middle, it is linear time. So you have to go all the way. Take the tail of the list, tail of the list for where the head is the element that you want to delete. And you have to reconstruct the rest of the prefix of the list. So this is both time inefficient and memory inefficient. Of course, you want to do efficient data structures, right?

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

You want to do circular linked lists and doubly linked lists and sequences and ropes and all of these fancy data structures you know behave much better than just purely functional ones. So, hence, in OCaml, we don't particularly look down upon imperative programming, right? We sort of provide enough features for imperative programming such that you can get your job done, right? This sort of is a nice balance, right?

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

If you look at Haskell, for example, that exposes pure functional programming, which has its benefits. I mean, it's not like you can't get the performance that you need, but you have to try a little harder. So a lot of the knowledge that we build based on mutable data structures, you have to sort of reimagine and then be clever to implement that. But in OCaml, you can just do it directly. And the history of why it is this way is unlike Haskell, which came from academic tradition, OCaml also came from academic tradition.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

Haskell is a playground for experimenting with new language features, right? So Haskell has his motto, which says, avoid success at all costs, right? So this is very funny, but this is very true. Haskell is sort of always forward looking. It is less strict about having advanced features into the language, merged into the language.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

So Haskell happens to be, the core language is simple, but contains so many advanced features. It's just a playground. It's a beautiful playground for exploring high level ideas. Of course, it has its benefits, but OCaml has always been a language for getting things done, right? It is targeted at engineers in particular. So you want to write large software.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

Functional programming has its benefits. So let's develop a language with sort of appeals to people who might not go for functional programming in the first go. So that's the sort of place where OCaml has targeted at. And in particular, OCaml, initial versions of OCaml, right, try to be as close to as close to Fortran programs. So people are writing Fortran.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

And then so the OCaml developers said, okay, we would like those programmers to use better abstractions, but we don't want them to give up all of their knowledge, right? They know how to write good Fortran programs. How can we take that and transplant it into a better setting? So that is why we have all these beautiful features in OCaml. That's a bit of history. So with that, we can look at how we implement doubly linked list.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

Okay, so we define a node in a linked list with usual things, right? We have a value, which is alpha. The node is also typed. So the type we define here is alpha node. It has a value that is alpha. It refers to it has the next and the previous pointers. So the next pointer is alpha node option, right? It can either be there or not. And the previous is also alpha node option. And these are mutable, right?

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

You can change the next and previous. Okay, so that's the definition of node. And typically for doubly linked list, if you implement it and see, the head will be just a pointer to a node, right? And an empty list will be represented by a null. We don't have null here, right? We have to use some different type. So the type that we define here is alpha DL list, a doubly linked list,

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

is a reference to a option node. So it's a reference. So it can be mutated, right? And it's an option so that you can represent the fact that an empty list is just a reference to a non-option. So empty list is less than and non-empty list will have some node, right? And some node can have a previous and next one. Okay, so that's the difference, right? So because we don't want to use null, we have a separate type for doubly linked list and node.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

Node is precisely the same as what you would have in C. And here we have a different type just so that we can get across this idea of avoiding the use of nulls. Okay, so how do we create an empty linked list? An empty linked list is just a reference to non, right? And yeah, if you want to get the first node,

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

take the list t and then dereference it. So that can be, so what does it give? It gives you an option, right? It is either none or some node. Actually, we can run this. Oops, I need to run this. You can run this to look at the type. So first, takes a doubly linked list and gives you a node option. So if it is none, you know that the list is empty. If it is some node, then the list is non-empty.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So in order to check if the list is empty, we dereference that t reference, right? And if it is none, then the list is empty, right? So is empty is alpha dl list to Boolean, right? It is true or false. And we define helper functions to just fetch the value the next and previous. So we just use dot. The syntax highlighting is a bit off here.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

It should be black, but its value is sort of one keyword that you can use in OCaml, but it's not, it is also allowed for variable names. So that's why it's green, but otherwise it should be black, right? This should be black. So given a node, you can get the value, right? Alpha node to alpha. You can get the next and the previous, right? And these are optional values. They are optional values because next and the previous may not exist. So we use options.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

Okay. So let's look at a few functions. These functions are going to look exactly the same as what you do in terms of logic, right? Exactly the same as what you do in C, except that we have these minor differences, right? We don't check for null. We actually do a pattern match and things like that. So we are going to implement this insert first function. So what does this do? It takes a list and a value and inserts a new node.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

It creates a new node whose value is the given value, right? And the insert inserts a new node as the first node in the list, right? So if you have a list and you give it a value, insert first creates a new node, which has the value and then insert it. That's the first question. And it returns a node, a newly created node. So what do we do? So we take the list and the value.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

We first create a new node, right? A new node is created as saying because it's going to be the first node, the previous is none, right? The next one is whatever the current first of the list is, right? And the value is V. So we've created the node here, n, right? And if t is empty list. So if the list is empty, then we are not doing anything here.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

But if the list is non-empty, right? If the list is non-empty, there is an old first, right? And because we are inserting the new node before the old first, old's first previous is this particular node. We use some n because we have to wrap it in an optional type. So the old first points to this newly created node. We update this reference because n is the first node now. We update the list reference to some n and then we return n.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

Okay, so that's the function. And what does it do? It takes a wlinklist. It takes a value. It inserts the new node which has the value as its contents at the first position and returns you the same node. Okay, so that's what insert first does. Okay, so now let's look at another function, insertAfter. So what does insertAfter do?

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

InsertAfter takes a node to insertAfter, takes a value, right, to insert in the new node. It first creates a new node called n', right? Whose value is v and inserts it after the given node n, right? And it returns the newly created node m', right? So this is what it's doing.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

So again, just like before, we create a new node for that has the value v, right? And because we are inserting after n, the previous of the new node is going to be the node that we are inserting after. The next node is going to be the next node of n, okay? And if the next node does not exist, then we do nothing.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

If the next node is some old next, then we have to update the previous pointer of the next node, old next node. So we do that here, old next is previous and some n', right? This is a newly created node. And finally, what we do is we update the next node of the node that we are inserting after through this newly created node, we return the node.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

Of course, I'm sort of hand-wavingly explaining this, but you can just draw this out and this is just work out, right? If you've done doubly-link list before, which I assume you have, this is no different, right? We just use some OCamlisms to explain it. So that's inserted after. So yeah, delete is going to be just the usual one. The only thing that we have to do in delete, as we do in C,

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

is we have to update the previous pointer and the next pointer, right? So we have to do both of that. And that's it. It just works out. Okay. So we've defined all of these imperative features that you will find, right? So we've defined insert and remove, but we can also do functional features in it. So the thing that we like with higher-order functions is we can do iterations

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

over any data structure, right? So we define an iter function, right? Iteration function takes a list and takes a higher-order function f and applies f on each value in the list from left to right. So it is just iterating. It is not returning you anything useful, but it's just going through the list and applying this f function. So because f is not running anything useful, it is just an alpha to unit function.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

So we run f for effect. It might just be like print each value or something like that. So it takes a list and then this higher-order function and applies it over each element. So we write recursive function for the loop, right? Yeah, I can possibly do it not like this. So I don't want to introduce new syntax. So I can write it like this.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

So I'm going to call this function with whatever is the result of dereferencing t. So that can be an optional type if the list is empty. So in which case we don't do anything. If it is not empty, so we get some even, some node and we extract the value in that node and apply the function f that we supplied. That's the higher-order function that we got. And we simply loop until we reach the end of the list.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

Oops, and both value value. Okay, so yeah, I'm avoiding some syntactic sugar that I had used. Anyway, so loop is a recursive function that takes a list and then it rates to the end of the wlink list. So the whole function has type, take a wlink list, take this higher-order function

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

and apply it to each element and it's not going to return anything useful, so it returns unit. Okay, so this is the termination case for the, for the iteration, so which returns unit. So this whole function returns unit. Okay, so we've done iteration, but you can also imagine doing folds, right? If you implement fold over the wlink list, you can use that to implement iteration and whatnot. So you can do all the things that you want.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

But I just wanted to give you an idea of how to use these things. So let's, let's play with this, right? So let's create a wmtwlink list. Let's first insert a node with zero in it. And then I'm going to insert one after it, right? So I insert first a node with zero in this list, which returns the node n0, right? So that's the first node.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

And I'm going to insert a new node with value one after n0. Let me finish this. And then we insert a new node with two, right? That's the value. Okay, so we just create a wlink list with zero one two. Ask the contents. Shreesha has a question. Said in the previous functions, why did we wrap the pattern match with begin and end?

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

Should we always do that? Where do we do begin and end?  Oh, here. Okay. Yeah, you don't need it. You can do. You can do this if you want. The reason for doing that is.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

If you write it like this.  The OCaml will interpret this as something like this. By default, so when you have a, I mean, this is unfortunate. I mean, this is syntactic. It's a bad syntax, right?

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

So essentially, the parser will look at the original definition as a definition like this. All of this comes under the non case. So that's that's not what we want here. So the semicolon is to blame because I use a semicolon here. It is unclear whether the semicolon ends the whole match with block or this single expression. And it always ends the closest expression.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

So it ends the this expression and this everything else comes under this block. And that's not the intention. So that's why we needed. We needed this beginning and end. But you can also use brackets like this. So if you use a bracket like this open close, then that will also work. That's the answer to your question. Okay.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

Yeah, I don't I don't prefer brackets because bigger than that nicer to read. And it's a bit difficult to read the brackets. Okay, so okay, so let me move on. So I created a linked list with three nodes zero and two. So it prints the actual values, right? We can have a look actually.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

So the list itself is weakly polymorphic because this is a this happens to be an application which creates an effect, right? And it does something that is polymorphic. But just like we saw earlier, right, this value restriction because of value restriction, we have a weekly polymorphic w linked list. Initially, the w linked list is empty, right? So it's its content is none. So when you see content is none, it is a reference that points to reference, which is a box, which has none in it.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

So it's an optional value, but it's a reference, right? So the content is none. And then what we did is we inserted the first node in the list with content zero, right? And what you end up having is n zero is an int node and the value is zero. Next is none, previous is none. Okay, so that's fine. And n one is also a node, right?

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

It is also an integer node. Its value is one. Its next is none, right? Because that's the last node. Its previous is this node zero, right? So it says previous is some. This whole thing is just referring to the content here, right? So previous of n zero is none. So that's the first node. So previous is none, right?

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

The value of the first node is zero because the value is zero.  And we have we see something curious here, right? We see next equals some cycle. Why do we see this? Because next equals some, the same node that we are defining here, right? So you can sort of replace this with n one here, right? This would be n one. But that is not what OCaml prints because OCaml, the pretty printer tries to

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

recursively traverse through the entire data structure until it can sort of print everything. But that's not true here, right? If you keep going on and on with this, I mean, this is an infinite loop, right? So you have a next pointer from n zero to n one at a previous pointer from n one to n zero. So if you try to do it naively, you just go ahead and print everything.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

This would print the entire, this would not terminate, right? And just like graph traversal, what you do when you traverse graph is you sort of have visited nodes. And the current node that you're defining is happens to be visited. So here it's a cycle, but you can sort of abstractly write this should be n one is the idea. n one is not defined until this value is defined. So you can't define it's like a second and egg problem.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

So that's why the pretty printer avoids printing n one and just print cycle. But that's the intention. And similarly, what is the last expression that is that is an integer node. We don't give it a name. So we don't actually see anything here. Its value is two. That's the last node. So next is none. And its previous is going to be n one, right? Its previous is going to be some this whole thing, right?

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

This whole thing is this whole thing. And there are cycles here, but that's the reason. The reason there is a cycle is just what I had explained now. Okay, so we sort of see what is printed. Let's see if it actually works out. So I'm going to iterate over the list and print the values. I'm doing printf. Person HD. I know that the values are integer. I'm introducing a new line character.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

And I'm also flushing the buffer for every printing. This is strictly not necessary, but I'm just using it because this JavaScript interface that we are using expects a flush in order to show the output. But otherwise I'm just printing out the value zero and two. Okay, so that's doubly wrinkled. And so we've seen references.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

We've seen mutable record fields. And we saw that references are in fact implemented using mutable record fields. That is the third way of introducing mutations, general purpose mutations in OCaml. Those are arrays. Just like you have arrays in C, arrays are useful in OCaml. So again, arrays are contiguous data structures. They have efficient accesses and so on. They are not linked.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

So there are reasons to have arrays in the language. And so since we are looking at a new perimeter, we are going to look at the syntax and semantics. So there is going to be static semantics, the types and the dynamic semantics, what it actually does. So syntax, right? First thing that we do for declaring arrays is we use the syntax which is similar to lists, but has this bar. So if I write something like this, this would be a list which has into one, two, three.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

For arrays, we use this syntax. Again, this syntax, just go with the syntax. So this defines an array that has one, two, three. And we have a static semantics. We have a type called array. And A is an integer array. And so we want to do two things. We want to read the elements of the array and store into particular indices.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

And the syntax is here. So if you want to retrieve the ith element of an array A, you do A dot open bracket, I close bracket. So this is so I'm going to retrieve the first element of the array. So A dot zero. So that gives me one. And because we have type safety, right? We have type safety.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

Unlike C, we cannot allow you to read arbitrary indices. That would just be wrong because the memory in that location could be anything. I don't know what it is. And similar to, say, Java or JavaScript or any other language which enforces type safety and memory safety. Whenever you access an array index, we always check the bounds. And if you access indices which are outside of the bounds, you'll get an error.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

So here I'm accessing the element at index zero, but the length of the array is three. So the maximum index that I have is two. So this will raise an exception. This is not returning some arbitrary value. This actually raises an exception saying invalid argument array index out of bounds. This is quite important for type safety. Because that would be arbitrary things that integer is fine.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

Imagine you have an array of, say, trees or something. And then I can't make up trees by reading arbitrary bits. That would just be wrong.  So that is array read. And you can store into array using the left arrow syntax. So here is, so what I'm doing here is I'm updating the value at index one to zero. Okay, so I use the syntax and I just retrieve the array here.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

So I update the value at index one to zero. So I get zero one zero three instead of one two three, which was earlier. And I can access it here, which is zero. Arrays behave very similar to arrays in C. Actually, their memory layout is also very similar. So I'm not going to say much about this because you've programmed with arrays already in C. You should look at the array module.

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

At this point, you know, in a folk ml to sort of look at the standard library that has certain types and that has documentation, you should be able to understand what's going on. There is nothing surprising here. What it's like, see like arrays. Okay, so just to conclude this lecture. So there are benefits to immutability, right? Program doesn't have to think about aliasing. So we don't have this notion of what physical and structural equality is.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

The language implementation is free to share objects. If I happen to have the same value, which happens to be allocated as two different objects, and if the values are the same, then the compiler can internally choose to use a single object. And because I don't have any mutable features, I wouldn't be able to deliver a difference. I can only use structural equality and structural equality anyway tells that both objects are the same.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

So this that makes things simpler. It also having mutability also introduces the problem of value restriction. So now we have to think about what we call morphism is and so on. It is easier to reason about what your program does. Your program has a specification which is fully defined by the type. But when you have mutability, the type doesn't capture what is going on. The program might have some updating a global variable, which is not captured in the type.

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

So it is not about clear what it is doing. So there are benefits to immutability. And when you start doing parallel programs, having immutability is great because if I have something that is purely functional, I can create seven copies of it. All of these will not interfere with each other because there is no mutation going on. But you cannot do this when you have mutable features. If each of them has a reference, which it is internally updating,

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

if you create seven copies and run it in parallel, all of them are operating on the shared data structure. You will have all the problems of parallel programming, which I think you will study in operating systems later. But that said, mutability is useful, right? Just like we saw doubly linked list, we want to use things like arrays which have certain memory representation. We want to use hash tables. We want to use red-black trees and whatnot. So all of these have implementations in OCaml. So all of these are implemented in an imperative fashion.

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

So what is the takeaway from this lecture? The idea is that use immutable data structures unless performance cannot be compromised. Don't go for mutable implementation. Start with an immutable one. And if you see that there is necessary for performance where you think mutations will give you better performance, then go for it. This is what Standard Library does. Standard Library has hash tables and mutable sets and so on.

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3272.6s_

They're all implemented in a mutable way, but have an interface which sort of looks very functional. I think that's a reasonable compromise to go with. And that's all I had for this lecture. I'll stop here. I think I've already taken five more minutes. So I'll see you tomorrow. Thank you very much. Thank you.

---
