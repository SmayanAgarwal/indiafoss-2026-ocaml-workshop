# 35-cs3100-pop-lec-35-prolog-basic-and-logical-foundations

**CS3100 POP - Lec 35 - Prolog Basic and Logical Foundations**  
id: `2v_xTC8h8o0`  
duration: 3034s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay. All right. So the last thing we briefly touched upon was unification in Prolog. At the core of how Prolog computes is this idea of unification. And as I had mentioned in the previous class, unification is very closely tied to how type

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

inference works in OCaml. So some of these terms will be familiar, but we are using unification for a very different purpose now.  So in Prolog unification is way computation actually runs, but we'll come to all of that later. So let's just look at how unification is defined in Prolog. Okay. So recall that Prolog has terms and variables.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

So the terms could be atoms, right? Or compound terms. Compound terms have a top function symbol and then some arguments which could itself be some other terms and you have variables, right? Variables are all those strings that start with a capital letter. Okay. So there are only three rules for unification in Prolog. It's very, very simple. So the rules are that atoms unify if they are identical.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

So if you give me the same atom, I would say that they unify. So A and A unifies, but not A and B. Recall that atoms are all the things that start with lowercase letters and are not functions themselves. So A and A unify, but not A and B. Variables will unify with everything, right? So if you give me a variable and anything on the other side, it will unify. And for compound terms, the idea is that the top function symbols should match.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

The top function symbols should match. The functions, the compound terms should have the same arity. So they have to take the same number of arguments, right? And their arguments, which could itself be more complicated terms, should unify recursively. Okay, so the top functions should match. They have to have the same number of arguments. And then their argument should recursively unify. And that is to unification.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

So with that, here are a few questions, right, just to clarify our understanding of unification. So which of these terms unify? So do you wanna take a minute and then answer which terms unify? You can just write down your solutions in chat.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

Does A and A unify? Yeah, okay, so there are a few answers. Yep, A and A unifies, right? So but A and B does not unify. Yeah, I think we have a few answers, right? So that's right, that's correct. So A and A unifies just like we saw earlier. A and B does not unify because they are two different atoms.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

And variables unify with anything. So A capital A is a variable, so that unifies with anything. Capital B is also a variable, so that unifies with anything. And you apply the same variable rule here, right? So A is a variable, this is a compound term. Component term doesn't matter. Variable unifies with anything, so this unifies, right? Yeah, so you're all right. So a few more questions, okay? Which of these terms unify now?

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

Again, as you have done, you can respond with your answers in the chat.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

So we can ask one by one, right? Okay, so what about, these are compound terms, right? It's a compound term on the right-hand side as well. What is the rule for compound communication? So the top function symbol should match, right? Three and three matches. They have the same arities, which means they take the same number of arguments. And they are the, yeah, so I think we have a few answers and those are the correct answers.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

There is a subtlety which we'll come back to. So the argument should recursively unify, so then you sort of look at the arguments, right? We have an atom here, L, another atom R, and then on the right-hand side we have two variables, so they will unify. So this is fine. Similarly here, the top function symbols are the same, the arities are the same. We have variables here, compound term here, compound term here, variables here. So those unify, fine, that's fine.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

We have third one, we have an A and A, right? Variables unify with anything. It also includes other variables, right? So A and A unify. R and B will also unify because V is a variable. Fourth one will unify by according to the rule that I mentioned, right? Variables unify with anything. A is a variable, so it unifies with anything. There is a bit of a subtlety there because the right-hand side itself mentions A, right?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

So now, I mean, the point of unification is to arrive at replacement for every substitution for every variable, right? So I have to arrive at something for each variable, which does not include other variables, right? It shouldn't mention any variables in that substitution. That's the ideal goal. But if you sort of look at this, right, you cannot do this here because

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

if A unifies with A of capital A, then A itself mentions that variable itself, right? So this is sort of subtlety. We will come back to this later, okay? So there is some subtlety going on here, but it does unify, right? In prologue, if you ask whether they will unify, it will unify. Lastly, we have an atom here under A of A, right?

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

So one way prologue looks at atoms is that a prologue sort of says every atom is also a compound term with R T 0. So you sort of imagine that to be a compound term with the top function symbol A with R T 0. Here you have a compound term with R T 1. The top function symbol matches, but the R T doesn't match. So that's prologue's way of reconciling the compound term with variables.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

But again, this does not unify, is the answer, because they have to be the same. So Venkat has a question, sir. It does unify, right? And the substitution is A equals B equals R, right? You say A equals B and A equals R. So A equals B equals R is the substitution. So yes, they do unify.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

We'll come back to this. I mean, this is the whole point of actually computing. It's okay to have a hazy idea of unification right now. We'll make it much more precise later. Yeah, there is something called. So as I mentioned, the fourth one does unify. There is something called occurs check, which we'll come back to later.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

Yeah, I'm not going to say much about this. We'll come back to this later. But yes, you're right. One, two, three, four unifies five doesn't. So okay, so this is a cautionary note about Prolog notebooks, right? So Prolog typically does not have a well supported Jupyter notebook interface. This is something that I hacked up for the course based on other work that has been previously done.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

It might behave in a strange way for certain instances, right? In particular, unlike OCaml, where we have say definitions, where we say let x equals this, right? And we say something, we don't have those sort of top level definitions in Prolog. All you can do with Prolog is you can add facts and rules to the database and you can query it, right? And you may see strange behaviors when you work with the notebook. So here is one strange behavior, right?

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

I write a fact which says that the fact is called string of int. It says that string of int of one is ONE, the string one, okay? Let me add that fact to the database. Facts and rules are also known as clauses, okay? So that's why this is printing added one plus to the database. If you run the same thing again, you'll see that it doesn't print it anymore because the clauses are already in the database, right?

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

So there is already the exact clause, the exact fact already in the database, so it's not adding, right? And you can query it. That's fine, right? So we said what is the string of int of one? It replies with, and we have a variable x, and the only variable that will satisfy this, only value that will satisfy this is one, right? Typically, when we do interactive development, what we tend to do is,

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

I'll just go and change this capital ONE to small ONE, right? And I'll run this program again, right? So, but you can imagine what is going to happen here. There is a prologue interpreter that is sitting in the background, right? So, and we are sending it commands. It has an active state that is already there. So it already has a fact which says, when you give me an integer one, it is going to be the string capital ONE, right?

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

When you change this and add another fact, it is added as a second fact, okay? So now if you ask what is the string of int of one next, it will return two, right? So it has the old fact and the new fact. Unfortunately, this is how the notebooks work, right? They allow you the interactivity, but they are also sort of not great here because they can produce strange values. If you see anything a little bit strange, and you can't explain it,

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

it might well be a bug in your code. But my recommendation is restart the kernel if you find weird results. So if you restart it, all of the current database is erased, and the only thing that will be added is ONE and it'll work out, okay? So yeah, so this is just a like a debugging thing. So you might, if you find weird results, yeah, we have shadowing, right? We have top level.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

Raghuraman has a, this is exactly how OCaml works, but we don't see it because of shadowing, that's precisely right. We don't name these things, right? We don't say this is a fact, and I named this fact x. We are sort of adding facts willy-nilly into the database, and that's the problem that occurs here. But yeah, but I think once you've seen this error, you know what you'll have to do. Anyway, so that was prologue basics.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

So the next thing that I want to do is, that is the, so just like what we did for OCaml. So we looked at Lambda calculus, which sort of was the foundation for OCaml. We will spend this lecture, and possibly this is a long lecture, so we will spend this and the next one. Looking at the logical foundations of prologue.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

So let me set it up, and then switch to. Right here, okay, so we're going to look at logical foundations. The point here is, this right, so what are we going to do in this lecture is, prologue has this interesting execution semantics, right?

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

We've sort of looked at it as a database-querying language, but it is much more, it is a Turing-complete language, right? So, but it is Turing-complete in a very weird way. It's just, it is very different from what I have at least seen before I learned prologue, right? It was quite different from how I thought programming should be done, right? What is a program and so on. I thought program was C, right?

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

And then I got introduced to other languages, I thought program was, okay, C and this other way of doing it. Prologue is a completely different way of thinking about programs. It's Turing-complete, so you can express everything that you can do in any other language, right? But the execution model of prologue is so different that it is well worth looking at where prologue comes from, okay? And in particular, this lecture, we are going to look at the logical foundations. Prologue is actually a very clever instantiation,

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

very clever subset of using first-order logic as a programming language, right? And so what we'll do in this lecture is we'll look at first-order logic. We'll look at why we can't use first-order logic as a direct model of computation. You've already studied this in logic machines and computations. First-order logic validity of formula and first-order logic is undecidable, right?

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

So what we'll do is we will restrict the language such that we get something that is semi-decidable. We look at all these terms in this lecture, right? And the learning goal of this lecture is going to be to understand where prologue comes from. So if you just look at prologue as just a programming language, we sort of miss the underlying beauty of what prologue is, right?

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

And as I mentioned in the initial lecture, people tend to use logic programming, but as sort of embedding within other languages. So glean is this data-like language that is embedded within a larger context, right? So if you just look at prologue as it is and sort of ignore it and go away, you won't understand what is the core meaning of what prologue is and where it is applicable, right?

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

So what we'll try to do in this lecture is sort of give you the logical foundations, and hopefully you can appreciate where prologue comes from and what it can do and what are the different paths that you can take in this very large space actually. So this lecture is going to be a bit theoretical, but I'll sort of throw, I mean, there are not going to be any cells that includes any programs, but what I'll try to do is to insert questions so that we keep you on your toes.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

Anyway, so first we are going to look at first order logic, review first order logic, so that we are all on the same plate, right? I'm going to go through it a little bit fast because you've already studied first order logic earlier. I'm not saying anything new here, but after that we'll look at specific things that appeal to prologue. So first order logic, right?

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

Just like we studied the language semantics, right? When we say OCaml, when we studied first order simply take lambda calculus, we said, okay, there is syntax and semantics. We are going to study first order logic in the same way. We are going to look at syntax first, and then we are going to say what those statements actually mean, right? We sort of went to mix them together when we study them, but it's nicer to study them separately. So we are going to look at first

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

order logic syntax first. So first order logic terms includes constants, variables, and function symbols. And functions are appear like this where they have a function name and some other arguments which are all terms, right? f and g are function symbols and we have terms here. In order to make this concrete we'll use a running example. So we are going to think about natural numbers and some facts and about natural numbers,

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

right? So we're going to encode natural numbers, right? So the constant, the only constant that I'm going to have is the constant z which corresponds to zero, right? And I'm going to have functions for the successor, right? S of x is going to be the successor of x. Mull x, y just stands for x is the, it represents the product of x and y and square of x represents

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

the square of the natural number x, right? So these are just functions. There is no meaning ascribed to it even though the names are hinting at some meaning, right? So we have, so in this system we just have a single constant and three functions s, mull and square. And then the interesting bit of first order logic is the, are the predicates and the connectives, right? So you can have predicates which are some predicate symbol p and then some terms

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

which say something about the terms that are constructed in first order logic. And then you can take these atomic predicates and then combine them together with this rich set of connectives, logical connectives. So negation, conjunction, disjunction, implication, by implication, right? By implication just means f implies g and g implies f.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

And then what is first order logic? First order logic extends propositional logic with quantifiers, right? So you have a for all quantifier which takes a variable x and then some formula, right? And the other predicate is there exists, there exists an f such that some f formula holds, right? And x is a variable here. So these are going to be the interesting ones in

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

first order logic, right? They bring in lots of power, but also bring in a lot of complexity. And that's what we are going to look at now. So here are some predicates over natural numbers. So you can say x is even, x is odd, x is prime. This, you read this as x divides y, right? The read this as x is less than or equal to y, x is greater than y, right? So this is a general

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

recommendation for reading prologue programs, right? When you have like a binary relation, such as this one, you always read it as the variable name, the function symbol, and then the second variable. That's usually the way you sort of read these things, right? If it says further x, y, x is the father of y. That's the way you read it. And similarly, x divides y, x is less than or equal to y, x greater than y. And we'll try to stick to this notation throughout

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

this rest of the lecture. And there is some precedence associated with these logical connectors. They are the usual ones. So they are ordered now from strongest to weakest. So negation binds strongest, followed by disjunction, followed by consumption, implication, and then the quantifiers bind the weakest. So why is this useful?

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So you could take some formula that has all these brackets, not B and C in place A. In these logical connectors, implication is the weakest one, then disjunction is stronger than that, and the strongest one is negation. So you could just write it as not B and C in place A, right? So whenever I write it like this, it means this one.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

We will, I mean, I won't quiz you on this, right? So this is just a notational thing. I won't ask you what is the precedence and so on. But wherever there is, it's ambiguous, we'll make sure that there is enough brackets in order to ensure that the meaning is clear. Okay, so what is the use of all of this? You can write some facts about statements about natural numbers, right? Every natural number is even or odd, but not both. So this is a fact. How do we

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

write it formally? We say that for all x, even of x or odd of x and negation of even of x and odd of x, right? So it cannot be the fact that both of these facts hold at the same time, but one of these holds, right? A natural number is even if and only if it is divisible by 2. So it says that for all x, which are natural numbers, x is even if and only if 2 divides x.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

So if some natural number x is even, then so is x squared. For all x, if x is even, then the square of x, so square of x is a function, right? And that is going to represent some natural number. And we are saying that that natural number is also even.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

Similarly, we can have more statements. A natural number x is even if and only if x plus 1 is odd. For all x, x is even if and only if x plus 1 is odd. So s of x is x plus 1, right? That's the reading. So we are going to say x plus 1 is odd. Doesn't conjunction have higher precedence than disjunction? I think this is not a hard and fast rule. So in our description, we are going to have

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

disjunction to have higher precedence than conjunction. I think this doesn't matter. This might as well be a bug in my slide. But if it ever comes up, we'll have a verification. Is that okay? I mean, these are not the way you sort of have to think about these is this is a syntax that we are defining. So it might well be the case that you are right. But let's see whether it comes up at all. But I'll keep this in mind.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

Where was I? Yeah, here. So any prime number that is greater than 2 is odd. And how do you do that? For all x such that x is a prime. And we also want to say that greater than 2. So x is greater than 2 implies that x is odd. And for any three natural numbers x, y and z, if x divides y and y divides z, then x divides z. For all x, y, z, if x divides y and y divides z, then x divides z.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

Okay. Okay, some more the last set of examples. There exists an odd composite number, a composite number, recall that a composite number is not a prime number. We're just saying that there exists an odd composite number. So there exists an x such that x is odd, and x is composite. Again,

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

I'm not defining what these things are right now. But that doesn't matter right now, because we are just looking at syntax, right? We are not looking at semantics. Every natural number greater than 1 has a prime divisor. So for all x, if x is greater than 1, then there exists a prime number, right? There exists a p such that p is a prime number and p divides x. So that is precisely what the statement says. The question of whether this is valid or not is like, this is valid, but let's

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

not think about that right now. The point here is how do we take these English language statements and then write it down formally? Okay. So those are a few examples. I think you're reasonably familiar with those. And there are some syntactic equivalences that we can provide, right? Negation of negation of f is f. Implication is just f implies z is not f or g. This is the

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

usual rule. By implication is f implies z and g implies f. Negation distributes over disjunction and conjunction, and then flipping the disjunction with conjunctions and vice versa, right? And similarly, negation distributes over the quantifiers as well, flipping the quantifiers, right? So for not for all x f of x is there exists an x such that a negation of f of x. And similarly,

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

when you have a negation outside of an existential, if you bring it in, this becomes a for all. And there are a few more logical equivalences. So this is talking about the distribution of the quantifier for all over the conjunction and disjunction. Okay. So when you have a statement which says that for all x f of x and g of x,

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

it is equivalent to for all x f of x and for all x g of x. But if you have a statement that says that for all x f of x or g of x, it is not equivalent to for all x f of x or for all x g of x. How do we show that this does not hold? We'll just show a counterexample, right? Pick f as even and g as odd. So if you just substitute for f and g even and odd, the statement that you get is

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

for all x even of x or odd of x, we know this is valid, right? Any number is even or odd. But on the right hand side, you see that it says that for all x even of x or for all x odd of x, you can you can pick x. So if it says that for all x even of x, pick x to be 1. So this this will be false, right? And for all x odd of x, pick x to be 2, right? And this becomes false as well. So

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

this is an invalid statement, right? And hence this equivalence does not hold. So here, the left hand side is valid, but the right hand side does not. So these are not equivalent. And similarly, you have the exact flip for that exists operator. When you have a there exists for

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

all sorry, there exists an x such that f of x or g of x holds, it is equivalent to that exists and f of x or that exists or g of x. But this equivalence does not hold. Again, we substitute f to be even and g to be odd and we show by counterexample. So if you do the substitution, what you get is there exists an x such that even of x and odd of x. Obviously, that does not hold. Given a particular number, this does not hold. It can't be both even or not. But if you sort of

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

look at the right hand side, it says that there exists an x such that even of x and there exists an x such that odd of x. Of course, you can pick x to be 0 here and x to be 1 here, in which case, the left hand side is valid. So it's it's it's satisfiable. But the right hand side is not. Sorry, am I flipping it? The right hand side is satisfiable by the left hand side is.

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

Yeah, but you get the point. So these are a few logical equivalences. Keep that in the back of the mind. We are not going to look at it too closely, but it's important to know about these logical equivalences. OK, and then we also have inference rules, right? Which sort of given certain syntactic forms, we can infer other syntactic forms. Essentially, if you have f implies

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

g and then you have your you can also show f, then you can show g. Right. If f holds and f implies g holds, then g holds. I'm using the notation that we introduced in Lambda calculus, right? So I'm calling this implication elimination because implication appears on the premise, but not on the conclusion. And similarly, I'm calling this for all elimination. If you know

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

that f of x holds for all x. Excuse me. Sorry. So if you know that f of x holds for all x, then it must be the case that f holds for some t, where t is picked from the same domain. But let's not look at it too deeply right now. And similarly, if f of t holds for some t, then you can write that there exists an x such that f of x holds. Right. So this is for all elimination, for all

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

is gone. Right. This is there exists introduction because there exists this in the conclusion. Finally, if you have both f and g independently, f holds and g holds, then it must be the case that f and g holds. Right. So these are inference rules. Everything so far is syntactic. Right. So we've not assigned any semantics to it. Of course, we intuitively know that these all are true. But that's beside the point. Right. We are just writing these down.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

If you sort of give you if you show this to an alien and then tell them that these are true, the alien might not agree. Right. So I just say you just written down some symbols. Okay, the symbols are fine. But I don't have an intuitive understanding of what these things are. So this is where we come to semantics. Right. Everything that we've seen so far is syntactic, even though we try to appeal to these validity using some examples and so on. They are all syntactic.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

That when we look at semantics, we are going to look at look at it much more precisely. Right. So so we have a definition called interpretation. Right. So we call this an interpretation for first order logic formula. So what is an interpretation? Interpretation is a way of giving semantics to a first order logic formula. Right. And the definition is this. So given an alphabet A from which the terms are drawn, the terms for

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

the first order logic are drawn. I'm not going to define A precisely, but I'm just saying there is some A. Right. And a domain D. Right. So domain D might be some other domain not connected to A. An interpretation is something that maps each constant that belongs to the alphabet A to an element in D. Every function that you define in the terms that we defined, you map it to a function

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

that in that goes from taking n arguments, each of which is D in D and returning your D. And every predicate B belongs to A. You define it as a relation. That's just a cross product of these n terms. So if it's nary, then you have n. Right. So why is this useful? Let's look at it with the help of an example.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

We have a running example where we've looked at the Z and S of X and a few facts about natural numbers. Let's actually give it semantics. Right. Let's give it an interpretation. And what does that mean? So we have to pick a domain D. Right. We have some atoms. So we have this atom A. We have this S of X. We have less than and so on. So this is a constant. This is a function. This is a

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

predicate that's actually give meaning to this. The way we give meaning to this is pick a domain D. Right. And the domain that I'm going to pick is the domain of natural numbers. Right. And I say that I want to map the constant to an element in D. I'm going to map the constant Z to zero. Every function I map to a function that takes so many arguments and returns an argument, which is also in D. For S of X. Right. I'm going to map it to a function called S of X. Right.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

That takes one argument, which is D. So it's a natural number and returns you X plus one, which assigns meaning for what S of X is. And similarly, for the predicate L E, I'm going to use the less than or equal to relation on natural numbers. So this is going to define pass. You can imagine defining every pair of natural numbers. So one is zero is less than or equal to zero. Zero is less than or equal to one. And you can sort of imagine building a whole

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

database of all of the paths that hold that satisfies this relation. Of course, that's like a nice view, but practically we don't want to do that. But that's besides the point. So what we are doing here is we take these constants, functions and less than or equal to and actually give them meaning. We say, OK, these correspond to these particular interpretation

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

picked from the natural number domain. OK, so that's the that's one way of giving meaning. The thing that you want to ask is, of course, you can pick anything here. I can pick, I can map this in whatever way that I want. How do I make this useful? I'm giving some semantics. How do I know that the semantics is meaningful? Here is why we need this definition of a model.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

A model of a set of astrologic formulas is equivalent to assignment of truth variables. In predicate logic, right? In predicate logic, if you if I just gave you the formula A and B. Right. And I ask you, OK, give me a satisfiable assignment of this particular predicate. What does it mean? Give me an assignment of the truth variables that will make this whole

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

formula true. Right. And the assignment that you want here is true. True. So this is for a predicate logic formula, which doesn't have quantifiers. Right. The equivalent of this assignment for first order logic is what is known as a model. Right. And what is a model? So given an interpretation M for a first order logic formula. So interpretation is just what we saw

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

on the previous slide. This interpretation is known to be a model if and only if every formula of B, because we have quantifiers, right, every formula of B is true in this interpretation. So give me an interpretation. That interpretation, I will call it a model if and only if every formula in that set of first order logic formulas is valid, is true. Then I call that interpretation

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

of model. And we use this notation where we say if M is the model of a formula F, we write M models F on M satisfies F. Right. So. Yeah. So interpretation is like picking some truth variables. Right. And model is that choice which makes the formula all the formulas that is

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

defined by that particular first order logic formula true. So here is an example. I think these ideas are made much nicer with examples. So let's just take this formula. Right. It says that F is a formula which says for all y, z is less than or equal to y. So z is the constant and y is a variable. I'm using lowercase, but it's not ambiguous here. So I'm saying that for all y,

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

zero is less than or equal to y. Right. And I want to pick models for for this formula. Right. And if you want to pick a model, you want to pick an interpretation where this formula holds true. Right. And here are some examples. Right. So pick the domain to be the domain of natural numbers. Z map Z to zero. Right. And map S of X to X plus one. Right. S of

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

X the function S of X to the function S of X equals X plus one and less than or equal to maps to less than or equal to. Right. This is what we saw earlier. And intuitively this holds. Right. If you if you sort of do this substitution, it becomes for all y where y is picked from the natural number domain, zero is less than or equal to any number that you can pick. Of course, that

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

is true. Right. We know that is true. But you can also give other interpretations which are models. So here is another example. We still pick the domain to be natural numbers. Zero maps to zero. And S of X maps to X plus two. Right. And less than or equal to maps to less than or equal to. This is also true. And it is true because we are not using successor at all here.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

Right. So it doesn't matter what you pick for S of X. So this is also true. This is a model as well. This interpretation is also a model. This interpretation is also a model where S of X is just X. Right. I am actually saying when you write S of X, all you mean is the same number. This this particular interpretation while it looks strange is also a model for this formula because this formula doesn't appeal to S of X at all.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

Right. So as long as the choice of the constant and less than or equal to are same, whatever you pick for S of X doesn't matter. Right. And the domain must also be same. So these are models. It looks like everything is fine. We have to look at counter examples. Right. So here is here are examples which are not models of this. Right. So rather than picking

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

the natural number domain, I picked the integer domain. So negative infinity to positive infinity. Right. I picked zero to be Z to be zero. S of X maps to X plus one is that equal to maps to less than or equal to L.D. maps to less than or equal to. Of course, this is not this does not fold. Right. This interpretation is not valid because if you just replace the formula, right, write it explicitly, it says that because the domain is Z for all Y such that Y belongs to Z,

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

zero is less than or equal to Y does not hold because you can always pick Z to be minus one. Right. And zero is not less than or equal to minus one. And that does not hold. And similarly, yeah, this is a silly example, but you can pick the domain to be a natural number. Z maps to zero.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

S of X maps to X plus one. Right. Less than or equal to maps to L.D. maps to this greater than or equal to relation. Right. It looks silly here, but the point is these two are disconnected. Right. L.D. by itself is just some characters, some atoms. It doesn't have any implicit meaning. I am giving it some meaning by picking the interpretation. I am saying L.D. is now this relation greater than or equal to that does not hold because if you do the substitution, you will

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

get for all Y, Y belongs to the natural numbers. Zero is greater than or equal to Y. This does not hold. Right. So you can pick Y to be any number other than zero. And that is. So what I want you to take away is this. There is a syntactic notion of what formulas are. There are interpretations, interpretations and a few of those interpretations are known as models where the formula is true for

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

every assignment of the variables and every formula that you can have from that particular formula. Okay. So. A quiz. Okay. So which of these interpretations are models of F equals for all Y less than or equal to Z, Y. So we say that for all Y, Z is less than or equal to Y.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So that's the formula. And here are some interpretations. I'm asking which of these are models. Okay. So we have some answers. Right. So this is the domain. Right. So one and two. Right. Because what does it say? I picked the domain to be natural numbers without zero. I picked zero element to be one. S equals X plus one. Less than or equal to is less than or equal to. So this is fine. Right. Because I cleverly picked the right number that would satisfy everything. So that

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

works out. This is the same as the previous one except that X of X is X plus X times two. We are not using X of X here. So it doesn't matter as long as these choices are fine. And the last one. I pick Z to be zero, but less than or equal to maps to less than. And this is invalid because you can. I mean, zero is not less than zero. Right.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

It says for all Y Y can be picked from the natural number domain. Zero is less than or equal to Y. I can pick Y to be zero and that does not hold. So one and two is the right answer. Good. Okay. So yeah. So S is a no one and two is the right answer. So. Okay. So. If you've given a so. Okay. So then we come to the question of satisfiability.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

Right. So I set a formula as first order logic formulas are set to be satisfiable. If you have some model for people. So you pick a model. We just saw what model is to pick a model. If there is exists some model for a set of first order logic formulas, then we call it satisfiable. And some formulas do not have models. These is one is.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

F and not if so that there does not exist a model for this, which will satisfy this. So this is known as unsatisfiable. It's a set of formulas that are set to be unsatisfiable. And so the next definition we have is so when you have satisfiability, the other question is validity, right? A formula F is said to be valid if it is true in every model that you can pick.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Right. So. So I have a set of formula that is internally consistent. So whatever interpretation that you whatever model that you pick it is true. Right. So that's we just write it as this formula is valid. Right. So. So. How do we usually show validity? That's the next question. Right. So we show validity by proving that the negation of the formula is unsatisfiable.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

So validity and satisfiability are like two flip side. Right. So if you want to show validity of something, this is how. Satsalvat work. When you want to show something, some formula is valid. You sort of say take the negation of the original formula and feed it to the Satsalvat. If the Satsalvat says, OK, this particular formula is unsatisfiable, then you know that

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

particular formula is valid. OK. And there is this nice theorem which says that it is undesirable whether a given first order logic formula is valid. So if I give you a first order logic formula and I ask whether this formula is valid or not, with the full power of first order logic, this question is undesirable. So you cannot have a decision procedure. You cannot write a program that is going to give you this answer. Like there is no algorithm that you can write down,

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

which can give you this answer. There are lots of approximations. This is the whole area of Satsalvat. Satsalvat is a simple solver and so on. But the question itself is undesirable. So what we've seen is we've seen first order logic. First order logic is quite nice to express certain facts. We saw some facts about numbers, but this would be about arbitrary things.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

It was able to capture intention. But the question of whether something is valid or not cannot be answered nicely because it is undesirable. So if you sort of think about first order logic as a foundation of a logic programming language, then it's not practical because of the undecidability issue. So the question is how can we do better? Of course, you can't take full first

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

order logic and say, okay, this is a programming language now, whatever that means. Because the question of answering validity is not desirable. So the clever bit that a lot of people have worked on, and this is the whole series of work that's been going on for the last 60, 70 years, even before computers were even practical is how do you imagine subsets of the language which are useful,

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

but desirable? And prologue is such a subset. So in particular, we are going to restrict the first order logic language such that the language is semi-decidable. And what is semi-decidability? We will look at semi-decidability in the next class. We'll also finish this lecture in the next class. So that's the key. So if I give you a full first order logic, it's not going to be

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3029.2s_

practical. So we are going to put some restriction on first order logic formula. And then we are going to make it practical. And you'll see prologue fallout of this restriction. It's a really, really simple idea actually. And we'll look at it in the next class. I'll stop here and we'll meet tomorrow. Thank you.

---
