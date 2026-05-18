# 36-cs3100-pop-lec-36-logical-foundations

**CS3100 POP - Lec 36 - Logical Foundations**  
id: `WMexaLTl8Os`  
duration: 3357s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so what we've been looking at is the logical foundations of Prolog and in the last class all we had seen as first order logic, right? And we saw various properties of first order logic and in particular we saw that the question

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

of validity in first order logic is not desirable and we said can we do better, right? Can we do better by restricting the language somehow so that the resultant language is semi-decidable, right? So that's where we wanted to get to and in this lecture what we will do is we will see what that restriction looks like, why that is semi-decidable and where Prolog comes from, right?

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

So that's the rest of the lecture today. So yeah, so what is semi-decirability, right? So the definition is that if I had a language L, L is said to be desirable if you can build a Turing machine that accepts every string in L and then rejects every string not in L, right? So this is an algorithm that can either accept or reject every string that is in L and if you can build such a Turing machine then that language is said to be desirable, right?

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

So what is semi-decirability now? Semi-decirability is if the language is, if you can, if consider the language L and assume that you have a Turing machine, right? Which given any string that is in L accepts that string in L, right? But for every string not in L, it either rejects it or it may loop forever, right?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

So this is where the semi-decirability comes in, right? So if you have a desirable language, you can, the Turing machine will always reject every string not in L. But here if you give a string to this Turing machine which is not in L, then it rejects it or loops forever. And this is the high level definition. And Prolog is, Prolog is a program which is, it's a language and an interpreter which has

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

this property of semi-decirability, okay? So in order to look at Prolog, what we are going to do is to take first order logic and restrict it. And in particular, what we are going to do is to define this subset of first order logic called definite logic programs, definite clauses. So definite logic programs are constructed out of definite clauses. These are just formulas, right? But they have a certain restriction.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

And definite clauses are such a restriction that make the first order logic, the subset of first order logic semi-decirability, right? And Prolog is essentially programming with definite clauses. Prolog, although there is a language, the concept of logic programming in the style of Prolog is essentially programming with definite clauses. We will see how this comes through. So I should, before I go on, I should define what definite clauses are formally, right? So that we can have the foundations for reasoning about what the restriction is.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

Okay. So first off, we start with clauses, right? A clause is a, sorry, an atomic formula, right? In first order logic itself, right? When we say an atomic formula, an atomic formula is some formula that does not have any connectives at all. For example, we've been looking at this running example of natural numbers.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

An atomic formula in the running example is even of x and prime of x, but not negation of even of x or even of x or prime of x. All of these include the connectives. So they are not atomic formula. The only atomic formula here are even of x and prime of x, right? Okay, that's atomic formula. Now what is a clause? A clause is a first order logic formula, okay, which has a specific structure. The only structure that is allowed is you have an outer for all, right?

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

You should have for all only on the outside and you have a series of disjunctions of L1, L2, L3 up to Ln, where every Li is either an atomic formula, right? Like this one even or prime or the negation of an atomic formula. So you could have not even, not prime and so on. So that's the only structure that is allowed.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

Observe that this is a restriction of the formula that you can construct, right? We restrict such that the for all quantifier appears on the outside. We don't have any existential literal in this construction. And the only connector that is allowed is the disjunction of L1s, but each L1 is either a positive literal, an atomic formula, or a negative literal, a negation of an atomic formula, okay?

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

So these are known as clauses. So each one of these is known as a clause. So that is a clause. We are going to define a subset of clauses, okay? Which are known as definite clauses. A definite clause is a clause that has exactly one positive literal. So again, recall that positive literal is an atomic formula. Negative literal is a negation of an atomic formula, right?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

So a definite clause is a clause that has exactly one positive literal. So there is one positive literal here, and everything else is a negative literal. And you have a for all quantifier on the outside. So when you have this, right, we've looked at logical equivalences earlier in the extra nice class. When you have not PRQ, that is equivalent to P implies Q. So you can rewrite this whole formula as, and dropping the for all quantifier here, but that's implicit here.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

You can write this as a1, because we are going to extract this negation out, right, using the logical equivalence, all of this becomes conjunctions. So what you have is a0 is implied by the conjunction of a1 to an, where n is greater than or equal to 0. It might be 0, but it might also be greater than or 0.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

And simply in prologue in logic programs, because conjunction is sort of the only operator that can appear there, we just use commas. So every definite clause we write as a0 implied by a1, a2, a3, up to an, where n is greater than or equal to 0. Observe that this is sort of getting close to what we had seen in the prologue running example in the prologue basics lecture, where we defined the ancestor relationship and so on, right. So we are getting somewhere here.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

Essentially, prologue is nothing but a finite set of definite pluses, right. The set is finite, and each one is a definite clause, and that is a prologue program, right. So here is the actual relationship between definite clauses and prologue, right. There are two forms of clauses that we saw in prologue, right. We had facts, right, and we had rules, and

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

both can be written down as definite clauses. Whenever we write a fact such as 0 is even, right, even z is a fact, because that's the base case of the recursion. So we say 0 is even. This is a fact that you can load into the prologue interpretive, right. And the equivalent definite clause is you have a for all quantifier on the outside on some variable, right, some free variable that does not occur on the right hand side.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

It's just for satisfying the structural property, right, for all x where x is not used here, right. Even of z is implied by true. This t stands for true. So this is only there because definite clauses allow n to be greater than or equal to 0, n is equal to 0 here. So we simply replace that by true, right. So for all x, true implies even of z, right.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

That just means that even of z, and we've written it in the form of a definite clause. Okay, so that's how prologue facts can be rewritten into a definite clause. And the next one is prologue rules. It is a bit more natural, right. We had a rule which said x is an ancestor of y if x is a parent of z, some z, and z is an ancestor of y, right. So you can write this into a definite clause where you have all the variables on

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

the outside, right, universally quantified. So we have for all x, y, z, ancestor of x, y is implied by parent of x, z and ancestor of z, y, right. So we're just rewriting the rule directly into a definite clause. And because of the logical equivalence between implication and that exists, right.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

So if you push for all existential variable into an implication on the left hand side that becomes an existential variable. So all I've done here is I push the z variable which is on the outside. It's outside this entire formula here, entire term here. I'm pushing z to the left hand side of an implication, right. We write implications in the reverse direction, so left hand side is here. When you push z inside an implication, it becomes that exists, right.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And this is much more natural to read. This is the logical reading. This is what we say in English when we look at this particular rule in prologue, right. We say for all x, y, x is an ancestor of y. If there exists a z such that x is a parent of z and z is an ancestor of y. So this particular rule in prologue exactly corresponds to this definite clause.

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

So when we describe a prologue program, all we are doing is we are just describing a set of definite losses. So that's the restriction of first order logic that prologue is. Just moving on, right. So what's the so we've chosen to restrict first order logic in a very specific form, right. Actually, what does this bias, right?

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

If you sort of take a language and then restrict it, the point of restriction should be it gives us some property that is not given by the more the larger language. So what property do we get from going from, say, first order logic, full first order logic, which we know is undesirable, right. And we sort of restrict it to definite plus program. We have this very nice property now, which is that every definite loss program has a model.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

If you write down a set of definite losses, you always have a model for that definite clause program. Essentially, what this means is that a model for a first order logic formula is equivalent to a satisfying assignment for a propositional logic formula, right. So what this says is if you write down a set of facts and rules in a prologue program, you can always answer queries on the program, right, because it has a model.

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

And you can also read this as every definite loss program is consistent. You cannot write an inconsistent definite clause program. This is very important, right. You cannot write something that is inconsistent, such as this one. So I cannot write a definite loss program that is f and the negation of f. This is invalid, right. This is not a valid statement because there is no, you cannot satisfy this

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

ever, right. So why is this case, right? Why is it the fact that every definite clause program has a model? This is just an intuition, right. This is not a full proof. This is just the proof sketch. The intuition is that in a definite clause program, you cannot encode negative information. This is the key, but you cannot encode something is not true at all in

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

a definite clause program. This is true with prologue as well. We will study negation, a restricted form of negation later. That is that is quite weird. It works in certain cases, but it behaves very weirdly. But you cannot encode facts such as one is not an even number. All you can say is zero is an even number. Who is an even number? You can say one is an odd number, but you cannot say one is not an even number. Or you cannot say, if X is an even number,

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

then X is not an odd number. This is, I'm just going to give you this intuition. You can think of why that is not possible because because because of the structure of the restriction, I will leave it to you. But it's important to take away this intuition that you cannot encode negative information because you cannot put negation at arbitrary places. For example, this is not

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

a this is not a definite clause, because we have a conjunction here. In a definite clause, everything is a distinction. I will let you work it out in your own time. But the important bit is there is no way to encode negative information. Okay, so so you can ask, right? So

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

so every logic program written using definite clauses as a model. So what does this help us? So you can ask, Okay, how do we construct this model? But the important question that you should ask is, why should we construct this model? Right? Why should we compute the model, the satisfying assignment for a definite clause program, which is the logic program? Again, the intuition is that, as I mentioned, models for a best order logic program is the same as its analogous to satisfying

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

assignments for propositional logic programs. Right? So here, we are working with definite clause programs. So we also saw that every definite clause program has a model, which means that we can always find a satisfying assignment for a logic program. So why is this important? So consider this particular program, right? This is a subset of the rules and facts that I had

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

in the motivating examples. In the first lecture, where we defined the game of thrones family tree, right? So I'm having a single fact here, which says Ned is the father of Rob. And then I have rules, a couple of rules, which defines parent and ancestor relationship. So what does it mean to have a model for this particular set of roll-off boxes? When we say we have a model,

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

essentially, you can build a database of facts, right? This database will contain everything that is true about this program. And that is essentially the satisfying assignment for this program. And what are the queries that we are asking? All the queries that we are asking is, can you find something that is true for the model of this program? Right? Oh, you have this program, I said, in the first class, I said the logical model of prologue program is built a database, because every definite plus program has a model, we can build a database for every prologue program.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

And all we are doing in a query is looking up facts in the database, right? What are all the assignments that we can give to x here in this query that are true in the model of this logic program, right? So the fact that we have models is what is allowing us to answer queries in a prologue program. So that's the key intuition that I want you to take from this logical

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

foundations lecture. So the next question that we want to ask is, okay, that's fine. But you also told us that we are not going to compute a database of facts, right? We are not going to compute all the possible assignments for the all the possible ground terms, right? All the possible satisfying things for ancestors, except it does not include a variable, we're not exactly

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

going to build a database and then look up facts in the database, right? That's not the computation model. So the question, the next question that you want to have is like, how do we actually compute the models for definite plus program because that is intimately related to answering queries about prologue programs. But in order to look at that, we will have to see more definitions. So what I will do is like, if you have any questions on any of this, I mean, these are

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

mostly definitions so far, you can ask because I'm going to throw more definitions at you unfortunately. But if you have any questions at this point, you can ask.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

So sort of this pause is also important because I'm going to throw more definitions. And I don't know about you, my mind cannot take definition after definition all the time. So this is just a pause so that you can also take in what was said and then be ready for more definitions. Okay, the pause was useful anyway. So

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

the last thing that we're going to see, right, is how does prologue computation actually work? The rephrasing that question is essentially how do we compute models of definite plus programs? Okay. So more definitions. So these are definitions that are specific to logic programs. Right. So the first definition is the definition of something called a headbrand universe.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

Right. So it says that given a logic program P, when I mentioned logic program, think about definite plus programs, right? I use these terms interchangeably. They are, whenever I mentioned logic program, I mean definite plus program. So when you are given this logic program P, we can define a thing called headbrand universe of the program logic program, which we write down as up, u of P, which is the set of all ground terms that you can be that can be formed with

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

constants and functions, symbols in P. So ignore the predicates, but this is the set of all ground terms that you can form with just the constant and functions. Right. So what is a concrete example? In our encoding of natural numbers, we had a single constant, we had a single constant Z, and then we had a function which is S of X. Right. And the headbrand universe for this particular

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

logic program is Z, SZ, SSZ, SSZ and so on. So this is just a set of all terms that you can, ground terms that you can construct with the constant and the function symbols. Again, I should define what a ground term is. So a ground term is one which does not have any variables. Okay. So we have S of X here where X is a variable and there are no variables here.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So everything is a constant or a function with a term, which is also recursively either a function or a constant that appears no variables here. Right. Okay. So that's headbrand universe. So if there are no function symbols at all, right, imagine we did not have S of X here, then by definition our headbrand universe would be finite, right? You can only have constants

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

and then we cannot construct more and more ground terms such as these ones. So if there are no function symbols, then the headbrand universe is finite. And if there are no constants in the logic program, it is possible that there are no constants in the logic program. We add an arbitrary constant just to build up a headbrand universe. So this is like an edge case, we won't ever encounter this case in practice, but if there are no constants, then we simply

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

add an arbitrary constant to the headbrand universe. Okay. So we looked at constants and functions. Now we have losses and predicates, right? So for that, we define something called a headbrand base. The headbrand base of a logic program is denoted by B of P is the set of all ground goals that can be formed with predicates in P. So a goal is something that is a fact,

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

right? And if you look at an example, it will be clear. So for our encoding of natural numbers, so the constants that we had are Z and S of X. Let's assume that the only predicate that we have for now we are considering is even of X, right? Let's only consider that as the predicate.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

If that is the only predicate, and given that we have that constant Z and the function S of Z, the headbrand base of this logic program will contain even of Z, even of S of Z, even of S of S of Z and so on. So this is all the things that you can construct using the predicates, right? The clauses and the constants and the functions. And the observation here is,

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

if the headbrand base is infinite, if you have functions where you can construct arbitrary terms such that your headbrand, sorry, this should be, so headbrand base is infinite if headbrand universe is, right? If you can construct an infinite headbrand universe, then your base will also be infinite, right? So because we have Z, S of Z, S of S of Z, S of S of Z, and so on,

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

my headbrand base, it simply wraps even around these terms will also be infinite. So the idea is that if headbrand universe is infinite, then headbrand base is also infinite. On the flip side, if headbrand universe is finite, then headbrand base is also finite. Right? So this is just the nature of how functions behave.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

Okay, so we looked at two definitions, we've looked at headbrand universe and headbrand base. We're going to look at headbrand interpretation. And headbrand interpretation is just a subset of headbrand base, right? This is easy. So you take an interpretation, what is an interpretation? You take the headbrand base, take a subset, any subset is an interpretation, right? Why is this useful? An interpretation assigns true or false values to elements of

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

the headbrand base, right? So when I pick something which says even Z drops the even of S of Z, but only has even of S of S of Z, implicitly, that particular interpretation is saying that even of Z is true, even of S of S of Z is true, even of S of S of S of S of Z is true, and so on. That's the idea of having a headbrand interpretation. And finally, we come to the

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

definition of a headbrand model. Again, what we are slowly moving towards is actually finding now finding out what is the meaning of a program that you described in Prolog, right? And that model is an interpretation, right? A model is an interpretation just like what we saw in first order logic, such that for all ground instantiations of the form, so we have rules and

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

logic programs, right? Definite closed programs. So whenever you have a rule like this, if B1, B2, B3, B4 up to Bn belongs to the model, right, then A also belongs to the model, right? So this is basically saying if you have B1, B2, B3 up to Bn in a model, then A also belongs to the model. So how does this work? So let the logic program be even of Z,

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

right? I'm saying 0 is even, and then S of S of X is even, right? X plus 2 is even if X is even, right? So what is this definition saying? If B1 to Bn belongs to M, right? Here we have true, as we saw earlier, you can read this as for all X, even of Z is implied by true, right? True always

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

belongs to the model. So true is just true, right? So even of Z belongs to the model. If even of Z belongs to the model, then even of S of S of Z belongs to the model, right? So urban model of this program includes even of Z, even of S of S of Z. And because even of S of S of Z belongs to the model, even of S of S of S of S of Z belongs to the model, right? So that is sort of telling you

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

how to construct all the things that hold true for a logic program. Okay. But mathematicians are quite weird. I don't know why they use this particular form of encoding. So this is Hebran model, right? But surprisingly, Hebran model also includes, may include elements from S where S is even of 1, even of 3 and so on. This is quite weird. This is just how mathematicians choose to

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

describe sets, right? When mathematicians describe this definition, this is a mathematical definition, they say what should belong to the model, right? They don't say what shouldn't belong to the model. And the problem is that if you don't describe what shouldn't belong to the model, you can have arbitrary elements that belong to the model, right? So you can observe, if you closely

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

read this definition, it only says that if B1, B2, Bn belongs to the model, it's a set, right? I'm describing a set. I'm saying, oh, what are the elements in the set? If you have one of these ground instantiated B1 to Bn, all of these B1 to Bn belong to the model, then A also belongs to the model, completely reading this. If E1 of Z belongs to the model, then even of S of S of Z belongs to the model. It doesn't rule out what doesn't belong to the model, right? So we are sort of describing

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

sets by what should be in the set. We are not describing what shouldn't be in the set. So this is the difficulty. So when you have Hebran model, that particular definition that we saw in the previous slide does not preclude elements such as even of one and even of three from belonging to the model. This is just a quirk of how we do mathematics, right? Mathematicians should really use constructive definitions. So the way we write programs, right, sort of look at a program, we

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

start with the ground terms, base cases, and then inductively build it up. Mathematicians tend to not use it. Unfortunately, this means that Hebran base of a definite program is always a Hebran model, right? Hebran basis is anything that you can construct, right? In this particular program, Hebran base contains even of zero, even of one, even of two, even of three, even of four, up to

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

even of infinity, right? That is also a model because by this definition, anything can belong to the model, right? And yeah, so this is not at all useful, right? This particular definition seemed to be going in the right direction by looking at the rules. But because of this non-constructive definition, it's sort of looking at what is in the set and does not describe what is not in the set. We have to have one last definition. Finally, we are going to define

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

the least Hebran model, right? So this is Mathematicians way of getting back to what is the smallest set, what is the smallest model that you can build. And they have this curious way of describing it, which is that a least Hebran model is one, which is the intersection of every Hebran model, right? So there are some rules about what should belong to the set. There can be

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

arbitrary things that can also be added to the set, right? But if you take all of these Hebran models, that arbitrary things can be present according to the rules, right? And if you take an intersection of all these sets, the set that you will have is the smallest one, right? Of all of these models, and we call this least Hebran model. So we define a least Hebran model as the intersection of every Hebran model. So we throw away all these nonsensical things out of

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

the Hebran model, and we get the least Hebran model. And we have the definition that we want for precisely describing a meaning of a logic program, right? So now what we defined is we precisely have defined this least Hebran model, which is a set, right? Which is a set, which

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

contains one entry, each for every fact that holds true, right? But nothing else. So if you don't have a particular fact that is in a least Hebran model, then if you ask the prologue program, like the query, the prologue program, whether this is true, it will come back with false, right? And that's the notion of building a least Hebran model. And okay, so we've seen a lot of definitions.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

So let's try to refresh our understanding of these definitions, right? So let's take this languages, right, with constants, Rob, Rickard and Ned, right? And we'll consider two predicates. Father, a function, civil with rt2 and ancestor with rt2. And we have the facts, which are record is the father of Ned, and Ned is the father of Rob. And we have the rules.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

x is an ancestor of y if x is a father of y. And x is an ancestor of y. If x is a father of some z, right, I'm not going to tell you what z this is. But z is the ancestor of y. So this is the same as what you had seen earlier. So given this language is these constants, these predicates, which of the following statements are true? Right? So, so the first question is,

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

is the Hebran universe, U of S infinite. We call that a Hebran universe for a language is infinite, if you have function symbols. Do we have function symbols here? We don't have function symbols, right? We have the constants and we have predicates. We don't have function symbols, right? So this is false, right? Is the Hebran base finite? Is the question. We call that Hebran base is finite if the Hebran universe is finite. So is the Hebran base finite?

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

Yeah, it is finite. That's right. So, okay, so now we know that the Hebran universe is finite and the Hebran base is finite. The next question is, does the ground term father of ancestor of Rob belong to the Hebran base of S? So does this term belong to the Hebran base? So basis, the set of all things

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

that you can construct with the predicates and the constants and the function symbols. So does this term belong to the base? So yeah, the answer is no, right? Because the problem is that we are syntactically wrong here. Father is a predicate that has RAT2 and ancestor is also

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

RAT2. So it takes two arguments, right? That's right. We are applying to one argument. I mean, this is ill-formed by construction. So it does not belong to the Hebran base. And so the fourth statement says that there exists some model M such that father net-net belongs to M, where M is the Hebran model of the program. Is this true? Recall that we have two definitions, right? We have least Hebran model and Hebran model. What I'm asking is whether father net-net,

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

net is the father of net belongs to some M, where M is the Hebran model. Is it true or false? It's true, right? Hebran model can have nonsensical things. It describes what should be present. It doesn't describe what shouldn't be present. And as we saw earlier, the Hebran base is also a Hebran

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

model. This is a well-formed statement, right? Whether this is true or false is like beside the question. I can write down this father has this father predicate has already too. And these are valid constants from the language. This is part of the Hebran base. And hence, this is part of the Hebran model. The last one is actually asking the useful question, right? Is father net-net, does father net-net belong to M, where M is the least Hebran model?

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

No, right? So that's the idea then. So the least Hebran model is meant to be capture the precise meaning of what the program conveys. You can even answer it intuitively, right? If it is a precise meaning, then according to these rules and facts, this is not true. So, but you can also assume that you can go from the definitions, right? Least is the intersection

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

of every Hebran model. And the smallest model does not contain father net-net. Okay, that's good. So it seems like we've managed to understand this reasonably well. And these are important, right? It's important to know where these things come from so that if you happen to be in a position later, where you look at a particular problem, and you're like, okay, this looks like a logic

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

programming problem. How do I think about this problem, these sort of terms will come in handy. So that's the idea of teaching all of this. But anyway, so it looks like we've gotten some of the ideas from this, from the part of this lecture. Yeah, this is actually what I had explained.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

So, okay, so we've sort of, we know how to define least Hebran models, right? And the mathematical definition that we saw said, okay, compute all the models and then take the intersection of all of these models, that will be the least Hebran model. Of course, we don't want to compute answers for our program, prologue queries by enumerating all the models and then taking an intersection. That would just be impossible to do if you have function symbols, right? Because

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

the Hebran universe will be infinite, that procedure will not even terminate. So, the question is okay. All of this is fine, the definitions are fine. How do we actually answer the prologue queries? Right? How do we, how does prologue compute answers to queries? So the interesting thing to, thing with prologue is, in order to understand how prologue programs, what prologue programs do,

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

you need to understand how prologue works, right? Okay, so this is, this is sort of curious thing about prologue. So prologue is a very small language. In order to understand OCaml, right, you did not have to understand how the compiler works or how garbage collector works or anything. So we had a nice model on top. We said, okay, we will work with this simple model. And we had models which are far removed from how you will implement OCaml,

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

right? But for prologue, this is, I mean, putting my programming language hat on, this is not the way I would actually describe, implement prologue if I were to do it again. But, you know, in order to understand how prologue programs, what prologue programs do, you need to understand how prologue works underneath, right? It's like, it's like this weird thing where the, the semantics

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

of the program is fully described by, only by the interpreter, right? So you need to understand how to implement a prologue interpreter in order to understand how prologue programs work. This is quite curious. So I found it really interesting that the behavior of some program is so closely tied to the implementation, right? So what really helped me

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

was to actually go ahead and implement an interpreter for prologue. And that is what you will do in assignment seven. So this is just a thing to say. In the last assignment in this course, what you will do is you will implement a prologue interpreter in OCaml. So that's sort of mixing two ideas that we have studied in this course. So you'll take all of your

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

OCaml knowledge, right? And use it to build an interpreter for prologue. You will only build interesting bits. You won't have to implement the parser and everything. Just like how we did for Lambda calculus, you'll go ahead and implement like a full prologue interpreter. It's not a large program. But as you'll see in the rest of the course, right, there are some subtleties which you can only understand by understanding how the prologue interpreter works. This, look at the rest of the lecture as sort of a vehicle for them,

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

right? We'll come back to these ideas over and over again throughout the course, because in order to understand how prologue programs work, you have to understand the interpreter. But here is like a 10 minute intro to how prologue works. So the core of how prologue works is this algorithm known as SLD resolution, right? SLD stands for Selective Linear Resolution with Definite Losses.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Yeah, I don't know why people choose complicated terms. You sort of take a Definite Losses program, and then you sort of apply a particular procedure in order to answer queries. Importantly, right, this particular resolution algorithm, SLD resolution is semi decidable. Right? What does that mean? If you ask for unsatisfiable set of formula, it is guaranteed

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

to derive false, right? It goes through the program and it guarantees that the program will terminate, this procedure will terminate. If you give it a satisfiable set, right, of formulas, so you sort of give it a bunch of rules and facts, and then you provide the query. If the query is satisfiable, then it may never terminate, right? So this is where the semi decidability

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

comes in. And this is also why prologue has non termination. It's Turing complete, right? Prologue itself is Turing complete. So we'll see what this SLD resolution is. I think the scariest thing about this SLD resolution is its name, Selective Linear Resolution with Definite Losses. The actual procedure is actually quite natural and simple and intuitive. We'll go through what that is. So again, it is best to study this using an example. We have the same running example as

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

what we had in the last class. We have a bunch of facts described, right? Which describes the father relationship between game of thrones characters. We have the parent relationship, a parent of X, X is a parent of Y, if X is a father of Y, and then we have the ancestor relationships. We have two rules for ancestors, right? Direct ancestor who is a parent,

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

and then ancestor with multiple hops, right? And then given these prologue facts and rules, I'm going to try to answer the query is a record the ancestor of Rob. That's what I'm going to try to answer. I'm going to try to apply a SLD resolution from first principles, right? And I want to try to convince you that this is a reasonable thing to do. Okay, so the query is,

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

so what is the query? The query says, okay, record is the ancestor of Rob. The thing that you don't want to do is to compute the least headband model for this program. Although you can do this for this particular program, if you have function symbols, then this program becomes the procedure to compute the universe and the base becomes infinite, right? So you don't want to do that. But all you're asking is whether this particular ground term, right? Record is an

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

ancestor of Rob belongs to the least headband model, right? So what I'm asking is, is ancestor of record Rob belong to the least headband model of P, the program? So how can I derive this, right? If you sort of go back to the definition of models, so it says what should belong to the model, right? It looked at rule and said, if you have some rule, then that particular ground instantiation of the rule should belong to the model, we are going to apply the same intuition

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

here, right? I see ancestor record Rob, right? That's the query. So we use the term goals for queries, because as you try to answer the queries, you will have more and more goals that you will have to answer. So queries, the top level thing that you feed into the program, and internally,

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

the query becomes a goal, and prologue might have more and more goals as it does the SLDs resolution. So I might use the term goals as well. But think about goals as just things that prologue needs to show are satisfiable, right? So the first goal is, it needs to show that record is the ancestor of Rob, how can I derive this is what prologue is going to ask. It looks at this rule, right? SLD resolution looks at the rules that can be unified from top to bottom. So these are for the father, father,

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

father, parent, parent, and it's looking at something that satisfies the ancestor, right? And the first thing that satisfies the unifies with ancestor is this particular rule. So ancestor x y unifies with ancestor record Rob, right? Okay, that unifies. So I can get ancestor record Rob, if I can show that record is the parent of Rob, record is the parent of Rob, right? So that's the

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

way prologue SLD resolution works. And the logical view of that particular rule is for all x y ancestor x y implies parent x y. We saw a few logical inference rules. Earlier in the lecture, you can you can actually apply those inference rules to convince yourself why this is a valid

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

thing to do going from this goal to this goal, right? But the intuition is this, right? If I want to show that record is the ancestor of Rob, and they observe that there is a rule which says that ancestor of x is an ancestor of y if parent of x is a parent of y, then I can derive ancestor of record Rob by showing that parent record Rob is what prologue is trying to do.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

So what it's going to do is to take this rule. And logically, what it's going to do is to this holds for all x y, but I'm going to do for all elimination and pick x equals record and y equals Rob, right? Substitute x equals record and y equals Rob, and then apply the rule for implication elimination. So eliminate the implication. So we know that the goal is true,

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

because that is what I'm going to try to show. And we know that this holds true as well. ancestor record Rob is implied by parent record Rob. If this needs to hold, then I need to show that parent record Rob goals, right? So we started with the original goal, which is ancestor record Rob, in order to show that this actually holds, our goal has now become parent record Rob. Right. So the original goal to derive ancestor record Rob has been replaced by the goal to

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

parent record Rob. So prologue tries to keep going down this route. It says, okay, can I show that record is a parent of Rob? So how can you derive record is a parent of Rob? Again, it goes through the rules and facts in the order in which they are described. In order to see which one unifies father doesn't unify, or I see parent x y, right? Well, this this looks like a nice term, let me

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

try to unify the term parent record Rob with parent x y. And then I'm going to try to show that father x y goals. So it's going to go down the the truth, apply the rules. So parent record Rob unifies with this parent x y. And then the goal now becomes father x y, which is specialized becomes father record Rob, right? So the new goal is now father record Rob. So prologue says, okay,

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

I need to show that father record is a father of Rob. Again, it goes through the same procedure, it goes through the goals and facts in the order. Father unifies here, but the term doesn't unify, right? The record Rob is not a pair here. Right. We have record net record, Brandon net Rob, but no father record Rob. So obviously, it goes through all of these father goes through all the way to the end and then finds that there is no term that unifies with our current goal. The current

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

goal is father record Rob, there is nothing that unifies. And then prologue says, Okay, SLD resolution says, this is I cannot satisfy this goal. So what do I do? The important observation is when SLD resolution looked for the unifying term for ancestor, there were two terms, right? There is one here, and there is another here. And we picked the first one, we went on the first path,

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

we sort of hit a dead end, right? We went on ancestor, we went on this, sorry, we went on this rule. Oops, let me try again. We went on this rule. And then we came here. And then we got stuck at father x y. Right? But there is a second path as well. We can we could have chosen this rule. SLD resolution chooses the rules to apply in the order in which they are described.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

So now it goes back, right? We are stuck here, it goes back to this position, and then says, Okay, there is another option which I haven't tried. Let me try that option right now. So it goes ahead. And okay, I should be here. So how can I derive it asked the same question, right? How can I derive ancestor record rock? The first path left to a dead end, let me try the second part. The second path was this term unifies to this term. But in order to satisfy

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

ancestor x y, I need to have two goals now. So I have the goal to show that x is a parent of z, x is record, there exists some z, right? And z stands for y. So I need to show that both of these hold, right? I can derive both of these, then I can show that I can derive ancestor record rock. So you can apply logical equivalences, you can apply these rules. But the idea is that you

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

end up with two goals. But you say I need to show that record is a parent of some z. And z is the ancestor of rock. Okay, where z is the same variable. So we use the same z here. So we have two goals. And SLD resolution picks the first goal, left hand side goal in order to do this traversal. So the current goal is now parent record z, right? You keep applying the same procedure,

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

it goes to father record z and father record z unifies with father record net, right? So that unifies with father record net. And prolox says, Okay, I found a satisfying assignment for the z. So it specializes the z to net in all of the goals that you have. So we have one other goal that is sitting on the side, right? So it says, Okay, the first

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

goal is satisfying. The second goal is now specialized to proving that net is the ancestor of Rob. Again, you can keep applying the same procedure. ancestor net Rob can be shown by parent of net Rob, which can be shown by father of net Rob, right? You can keep applying this procedure over and over again. And eventually, this is also satisfying. And yeah, and hence we

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3300.0s_

have proved that since both of the goals are satisfied, the goal one is satisfied, and the goal two is satisfied, the original goal is satisfied, and hence proved. So what is proof, that particular question, whether ancestor of record Rob is true is satisfied by SLD resolution. So this is exactly how prologue works. Okay, so what we've shown is ancestor record Rob for

---

![slides/interval_0111.png](slides/interval_0111.png)
_t = 3300.0s -- 3330.0s_

the given program P is part of the least-at-ground model of P. So we've sort of applied the rule in this procedure. And this procedure is called SLD resolution. This is quite intuitive, right? And yeah, okay, so if you look at how, yeah, the, I'll come back to this in the next class, I think there are only two slides more, but that's the idea, right? So you started with some goal,

---

![slides/interval_0112.png](slides/interval_0112.png)
_t = 3330.0s -- 3351.7s_

and you apply this SLD resolution principle, which was actually quite intuitive. And then you computed the answer to the query. And in the last class, we'll complete this lecture, and we'll go into more prologue program. I'll stop here, I've taken much more time, but I want to finish this anyway. Begin the questions for the next class. Thanks very much.

---
