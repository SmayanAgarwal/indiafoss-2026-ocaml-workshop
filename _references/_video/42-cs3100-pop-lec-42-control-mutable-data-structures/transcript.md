# 42-cs3100-pop-lec-42-control-mutable-data-structures

**CS3100 POP - Lec 42 - Control + Mutable Data Structures**  
id: `rTNxiLzkwcA`  
duration: 3224s  

![slides/scene_0001.png](slides/scene_0001.png)
_t = 0.0s -- 69.9s_

Okay. So in the last class, what we finally looked at is how to compute the most general unifier. So that was the slide and we had gone through one example. Before I move on, do you have any questions on this example? How this example works? No questions.  So also, I only see 23 people here. It's something happening, like some interviews or something. We have 70 plus people in class, but I only see 23 people show up. Anyway, so everyone who showed up, great, thank you.

---

![slides/scene_0002.png](slides/scene_0002.png)
_t = 69.9s -- 139.8s_

I'll just follow up with everyone else who's not showed up. I've not been keeping track of assignments very closely, but 23 is a very small number. Let's see if this improves through this picture. Okay. Okay, fine. We'll continue. So, okay. So we've computed the MGU, the most general unifier, and that happens to be the core of the Prologs execution. And the actual interpreter is very simple. So we are going to look at an interpreter. The interpreter is an interpreter for Prolog programs. So you load a bunch of rules or clauses, and then you have a goal. And the interpreter is going to give you either true or false, right? Or give you an actual result for the query that you asked. Okay. But the interpreter is going to be abstract in the sense that the interpreter does not

---

![slides/scene_0003.png](slides/scene_0003.png)
_t = 139.8s -- 209.7s_

encode explicitly the rule order or the goal order. And this non-determinism is essential for the correctness of this very small interpreter. This doesn't include any of the choice points, backtracking, or anything at all, right? But this captures the core of how Prolog works. We will see how this works, right? How this small algorithm can actually give you all the features that Prolog actually does, which is backtracking choice points and all of these other things. Anyway, that aside, let's look at the interpreter itself. So the input to this interpreter is a goal, right? Goal G. And then a program P. The program P is a list of clauses.  And the output is an instance of G. This instance is a keyword that we had defined earlier, right? An instance of a particular term is a specialization, right? So you have some substitution. You specialize it and you get an instance of the goal. Basically, you sort of look at instances, assignments to the variables that you might have in that goal.

---

![slides/scene_0004.png](slides/scene_0004.png)
_t = 209.7s -- 279.6s_

And what will output is the instance of G that is a logical consequence of P, which essentially means that given the program P, we will find assignments for the variables in that goal or false otherwise. So this will output false otherwise. And the algorithm itself is just run with run PG. So P is the program, G is the goal. So we will use this term called the resolvent. So resolvent is the current set of goals, right? So as we have seen earlier, because the body of a rule can have multiple goals, and we would have to keep track of everything, we'll just call that the current list of goals, the resolvent.  So if you initially had just one goal, say, what is the length of list 1, 2? Let's 1, 2. That will be the initial goal. And as we go along, this resolvent will increase and decrease in size based on how we solve each of the goals. If we find a particular assignment for one sub-goal and we prove it, then that goal will go away. And then if we apply a rule, then that resolvent will grow.

---

![slides/scene_0005.png](slides/scene_0005.png)
_t = 279.6s -- 349.5s_

So we'll see how that works out. So the algorithm works like this. So you initialize this resolvent to G. You can think of resolvent as this global variable that is always there. So given goal is now the resolvent. So we have a while loop here. And the while loop is guarded by resolvent is not empty. So initially, the goal is not empty. So it goes in. So what we do first is we choose one goal from the resolvent. Resolvent is a list of goals. We arbitrarily pick one goal from this resolvent and say, OK, we've picked a goal. And now we have to show that this goal is satisfiable. It's a logical consequence of the program. So what we do is we pick some rule. So some clause of this form. This form is saying, OK, you have some A prime with some body. Head is A prime with some body B1, B2 to Bn. You pick some one of the rules such that the A prime, the head of the rule, unifies with

---

![slides/scene_0006.png](slides/scene_0006.png)
_t = 349.5s -- 419.4s_

the actual goal that you picked from the resolvent. So let's pick A and A prime such that they unify. And the most central unifier happens to be theta here. So we use the MGO algorithm that we saw in the last lecture in order to find the MGO of these two terms. The thing to note here is this is a general form which also includes fact. If it is a fact, then this B1 to Bn will be just true. And that covers that case as well. So that is not explicitly written out. So what we've done is we picked some rule, some clause where the head of the clause unifies with the goal that we picked. That is A. And we have a MGU that is theta. So if you are not able to find anything at all, if you are not able to find such a matching clause, then we say, oh, we can't proceed further. So we exit the while loop. And if you exit the while loop, so we'll see what happens later. But if you can't find such a matching clause, then what you have is you have this theta.

---

![slides/scene_0007.png](slides/scene_0007.png)
_t = 419.4s -- 489.3s_

You have the MGU theta. So the first thing that we do is we replace the goal A in the list of goals with the body of the resolvent. So we pick all the body of the resolvent. We actually replace that one goal with the body, the goals from the body of the clause that we picked. That's the first thing that we do. And the second thing that we do is apply theta, apply the substitution to the resolvent, the original resolvent, the resolvent that we are building, and the goal G. So initially we had a G. We performed the substitutions both on the resolvent, the current set of goals, as well as the goal G. You keep doing this over and over again. And eventually what will happen is you will run out of resolvent or you will exit out of this. If the resolvent is empty, then because we are specializing G at every step, the output

---

![slides/scene_0008.png](slides/scene_0008.png)
_t = 489.3s -- 559.1s_

G will be the result that you're looking for. Otherwise we just output false. If the resolvent is non-empty, which means that we've actually escaped out of this while loop, the output falls because we couldn't find any matching clause there. The one thing that we do here, which I forgot to mention is whenever we pick a rule to unify with, we always rename the clause. So this is just so that we don't confuse the variables. Because we might pick the same clause twice. We want to use fresh variable names every time you pick a rule so that they don't get unified in the wrong order. So this is what we've been doing when we trace the programs by hand. So this is precisely what we do here. So this works out. That is the entire algorithm. All you do is you pick a right clause that unifies. You find the MGU. And then you replace the body, B1 to Bn, in the resolvent, in for A. So you throw away A from the resolvent and replace that with the body. And then apply the theta to the resolvent in G. This works out.

---

![slides/scene_0009.png](slides/scene_0009.png)
_t = 559.1s -- 629.0s_

But you should be very curious now because we've sort of looked at a lot of concepts. We've looked at things like backtracking and choice points and so on. So how does this algorithm actually work? So the key reason why this algorithm works is that the abstract interpreter is not deterministic. What do I mean by that? Unlike SLD resolution or the prologue, which picks the rules in the order in which the program is written down and the goals from left to right, leftmost goal in the resolvent and then continue, we arbitrarily pick the rule and the goal. And that is the reason why it works. And here is an example. So consider this very simple program. So I have three facts. I say plus one, three, four. The way to read this is one plus three is four. And I have two plus two is four. And I say even is two. Those are all the facts that I have in the program. And my goal is going to be plus x, y, four and even of x.

---

![slides/scene_0010.png](slides/scene_0010.png)
_t = 629.0s -- 698.9s_

I say find the assignments for these x and y variables. Is this goal satisfiable in this program? If you think about prologue, it would pick the first goal and then go on and then backtrack. But here this will succeed. Let's see how. So the first observation is for plus x, y, four, both plus two to four and plus one, three, four unified. Both of them unified. But if you observe the second goal, even of x, only if you pick plus two to four, this x will be two here and then even of two will hold. Right. If you pick the first goal, the interpreter will get stuck. So if you force the interpreter to pick the goals in the order in which it is written down, then the abstract interpreter will get stuck. But the abstract interpreter is non-deterministic. Right. It just says choose some goal, choose some goal that unifies this way.

---

![slides/scene_0011.png](slides/scene_0011.png)
_t = 698.9s -- 768.8s_

And this non-determinism is like some article. Right. It knows which goal to pick. We have some non-determinism encoded here. And that is the reason why the way the execution proceeds is I might pick any rule at all to unify. I will pick, I mean, because this is an abstract interpreter and has non-determinism, it can pick any goal that unifies. We will assume that it has picked plus two to four. Right. It picks plus two to four, in which case this goal will be satisfied. Right. This goal will be satisfied. And because of the MGU, MGU will say for X it is true and Y it is two. And you apply this on. So there is no right hand side. So this particular goal goes away from the resolvent. And then you take the MGU and apply to the current resolvent, which is even of X. If you apply it there, then X is two now. So it becomes even of two and even of two gets satisfied. Right. So we don't need to encode the abstract interpreter does not encode the actual control flow. It basically says everything is not in the district.

---

![slides/scene_0012.png](slides/scene_0012.png)
_t = 768.8s -- 838.7s_

As long as there is one path which can satisfy the program, the program will succeed. Right. And that's the key reason for calling this abstract interpreter because it doesn't include the precise control flow. OK. Questions on this one? Any questions? If I change this, the thing to remember is if I change this to say rather than saying choose a renamed clause, this one, if I say choose the first renamed clause that unifies, then this interpreter will not work. Because the first clause that satisfies here will be this one. Right. Plus one, three, four. If you pick plus one, three, four, X will be unified with one. And the next one will be even of one which does not hold. Right. And this interpreter gets out and outputs false incorrectly. That's that's wrong. The reason why it works is we leave the interpreter to choose some goal that satisfies. OK. So that's the key bit.

---

![slides/scene_0013.png](slides/scene_0013.png)
_t = 838.7s -- 908.6s_

So this rule order is not a deterministic here in the abstract interpreter. On the other hand, right, we also don't pick the precise order in which the goals are chosen. So given the resolvent, the resolvent initially will be the set of list of goals. So there is there will be one goal, this one. And the second goal will be this one. Let's say our abstract interpreter picks the second goal to pursue first. So it will pick the second goal, even of X, and it will look at the program and the only possibility is even of two. Right. So it specializes this to two and it specializes the rest of the resolvent to put the same substitution. So this becomes plus two y four. Right. And the only clause that satisfies with the plus two y four is plus two to four. Right. And and the abstract interpreters successfully finds the result for this program.

---

![slides/scene_0014.png](slides/scene_0014.png)
_t = 908.6s -- 978.5s_

And what the abstract interpreter will output is it will output the same initial resolvent, the initial goal G, with all of the variables filled in. Right. It will output X equals. So it will output plus two to four, comma, even of two. Right. And again, the choice points are also left implicit. Right. If there are multiple options, then the interpreter will output one. And because the choice is not deterministic, you can assume that the interpreter will have outputted all of the choices. And that's the idea of this abstract interpreter. And the key takeaway here is not deterministic is essential for the characters of this interpreter here. OK. So, yeah. So this abstract interpreter does not explicitly encode backtracking and choice points. Right. How to recover from bad choices are present more than one result. When you give a program and a particular goal, the program is said to be deterministic.

---

![slides/scene_0015.png](slides/scene_0015.png)
_t = 978.5s -- 1048.4s_

If there is precisely one choice that you can make at every point. Right. If there is one rule that unifies one goal that is always there, not every program is deterministic and not every deterministic program is useful. But that's a point that you can keep in mind. So a deterministic program exactly has one clause for reducing each goal. So there is there is no multiple options. There is exactly one goal that you can pick at any point. Right. And when you have a deterministic program, no backtracking or choice points are necessary because if there is only one choice that you can pick and the choice fails, your program has failed. Right. There is no recovery from bad choices because that's the only choice. And again, there are no choice points to produce more than one result because by definition there is only one clause that you can pick. There are no two paths. So so this is an auxiliary definition that you can keep in mind. So I might ask something like is the given program deterministic for the given goal. Right. Anyway, so in your last assignment, which I think I will release today, so I'll release two assignments today, assignment six and seven.

---

![slides/scene_0016.png](slides/scene_0016.png)
_t = 1048.4s -- 1118.3s_

Six will be programming with Prolog lists and seven will be implementing the prologue interpreter. Right. And here you will take the ideas from the abstract interpreter, but you will implement backtracking and choice points because when you when you write an OCaml program, OCaml program cannot say not deterministically pick one. Right. It has to pick one of the choices. So in which case you have to encode the backtracking and choice points support explicitly. They are naturally encoded as recursive orientations. I mean, you will you will you will know what this means when you look at the questions. But think about writing recursive programs. So don't worry about the discussion. Just write recursive programs. If you maintain global state, the idea is that if you go down one path and you perform some unification, if you come back, you need to undo all of the unification.

---

![slides/scene_0017.png](slides/scene_0017.png)
_t = 1118.3s -- 1188.2s_

But instead, if you write it as a purely functional program that sort of passes the state around, you don't need to undo anything because all you have to do is get back. And because there is no global state around, you can happily continue all of the work for backtracking and choice points that automatically done for you. I have I mean, this is just a hint. You don't have to follow this. Right. I'm not going to test whether you've done a recursive formulation, but it becomes much easier to write it as a recursive program. Include no global state. Right. Don't don't use references in this assignment. Use references, it will become much more complicated than it is meant to be. Right. And you will implement backtracking and choice points in assignment seven. Right. And that carries one third of the score. It will, as we've done with all of the assignments, right, it might seem daunting right now, but we will slowly build it up. So we will slowly give you small, small pieces that you need to finish up and we'll have test cases once you have that this naturally builds up to the entire thing. So don't worry about building it from scratch.

---

![slides/scene_0018.png](slides/scene_0018.png)
_t = 1188.2s -- 1258.1s_

You'll you'll be provided all the skeletons. You just need to work out the code algorithm. So, yeah, so that's what I wanted to say about the abstract interpreters of the log. So, OK, so that sort of finishes one part of our prologue exploration. So what we've done is we look at some prologue, but we also looked at a lot of ideas about backtracking choice points and so on. So in the rest of the few lectures that are left, what we'll do is we look at one concept, but but it will be more of applications of prologue. Right. So so we'll use prologue to encode interesting things. And that is what we'll focus on mainly in the rest of the lectures. So let me move on to the next lecture. Which is mutable data structures. I have a question mark because that is a hint for saying that prologue doesn't have mutability.

---

![slides/scene_0019.png](slides/scene_0019.png)
_t = 1258.1s -- 1328.0s_

It doesn't have support for references or anything. But we can encode things that look like mutable data structures in a very clever way just by using unifications. Right. And you'll see that in this in this class. Yeah. So last class, we looked at prologue. This class looked at simulating mutable data structures in prologue. So. So far, right, in our exploration of prologue so far, we've used variables. We've used variables in many places. We've used variables in particular only in queries or classes. So when we query, we might use a variable or when we write down the prologue program, we use variables. But we have not used variables in actual objects. We've not used variables within functions.  Functions as in functions according to what prologue defines as functions. But not in compound terms, essentially. So let's see an example. So here is here is the list. So where I say L is unified with this list where oops.

---

![slides/scene_0020.png](slides/scene_0020.png)
_t = 1328.0s -- 1397.9s_

Where it has one and two and the tail is going to be X. And what I get back is L is one to X. So in prologue terms, we call this an open list. And the idea is that it has to be one comma two. Let me change this. So this is called an open list because this is some list which has one comma two as a prefix.  And the suffixes are not defined. So we actually leave the suffix to be a variable. So it could be anything at all. So this is useful. Right. We can pretend to extend the list by unifying X with something else. So by unifying X with some other list, we can pretend to make the list have more structure. In particular, let's take this example.  So my L is going to be one comma two bar X. And then I say X is three comma three bar Y.

---

![slides/scene_0021.png](slides/scene_0021.png)
_t = 1397.9s -- 1467.8s_

Right. Now these two variables get unified. So L now happens to be one, two, three Y. Right. The prefix is one, two, three. And the suffix is Y. X is three, three Y. So of course we are not doing mutations here.  This is not what is happening here. But if you sort of just focus on this, right, I'll happen to have one comma two. If you ignore the tail for the moment, I'll happen to have one comma two. Now I'll happens to have one, two, three. Of course, the suffix is different. We'll come back to that. So this we are going to just play around with this idea of looking just at the prefix of lists. Right. And we are going to, we are going to pretend as if the list initial list has one comma two. And now the list has one, two, three. And what we've done by unification is extend the list. We've added one element to the list. Right. And this sort of reading is known as open list. Of course, this reading is sort of just giving you a hint. It is not a precise definition of what the list is. But that's the idea that we are going to use in this lecture.

---

![slides/scene_0022.png](slides/scene_0022.png)
_t = 1467.8s -- 1537.6s_

Any questions on this so far? Okay. No questions. Okay. So let me continue. So, so one thing that the Jupyter interface to prologue does badly is deal with open lists. So if I let me do this one thing, so I'll restart the kernel. And observe that the query that they have is L equals one comma two X, right? I should have L to be one comma two with the tail X, right? But if you run it in the, in the Jupyter notebook, what you have is an incorrect list, right? It says L is the list, the closed list one comma two. L precisely has one comma two and X is some variable. This is not correct. Right. This is incorrect. This is just a failure with the Jupyter notebook interface.

---

![slides/scene_0023.png](slides/scene_0023.png)
_t = 1537.6s -- 1607.5s_

The result should have been L equals one comma two X, right? Again, this is not correct. So for this lecture, what we will do is we will not use the, we'll not write code examples in the Jupyter notebooks because it is not correctly representing open lists. We'll directly do everything with the prologue interpreter. Okay. So what we'll do is if you say, let me open a terminal. Let me make it bigger. So if I do L, L equals one comma two X. Oops. So now the prologue interpreter correctly tells me that L is one comma two X, right? So this is what I expect, but the Jupyter notebook does not give me the right answer. So I'm going to not focus on the Jupyter notebook for the code examples in this, in this particular lecture. Okay. So let's continue with that.

---

![slides/scene_0024.png](slides/scene_0024.png)
_t = 1607.5s -- 1677.4s_

Okay. So what we will do is we will use open lists to represent queues. Okay. So we are going to deal with queues mainly in this lecture. So what is a queue queue has first and last out, right? If you put in something, it comes out of the front last. Yeah. So a queue will represent a queue with this compound term with the top function sub the queue, right? Which has arity too. And we'll have two parameters here, right? Both of which are lists, right? L will be an open list. Okay. So, L is an open list and E is some suffix of L, right? E will always be some suffix of L. So the way we will read this queue is this is just a notational thing, right? The way we will read this queue is the contents of the queue are all the elements in L that are not in E, right?

---

![slides/scene_0025.png](slides/scene_0025.png)
_t = 1677.4s -- 1747.3s_

So here is an example. So if I write down queue is one, two, three and three. So the way to read the queue is that the queue contains elements one comma two, right? The definition is that you take the initial list and you remove the suffix that is represented by the second argument. The suffix that we have here is three. So we will remove the suffix. So three goes away. So the queue's content is one comma two. So we will read this as queue has element one comma two, right? And this is the notation that we will use for the rest of the lecture. So these are, this is how we will encode queues. This is a very particular form of representation. We will, it sort of, it is not intuitive at first, but it sort of lets us explore this idea of open lists further. So when I write a queue one, two, three, three, observe that the prefix, the original queue, the first element has one, the first component has one, two, three.

---

![slides/scene_0026.png](slides/scene_0026.png)
_t = 1747.3s -- 1817.2s_

The second component is the suffix that is removed from the first component. So three goes away. So the list contains one comma two. Questions on this one. How we do this? This is just a notation that we will stick for the rest of the lecture. Okay, no questions. Okay, let me continue further. So what, what operations do we have for queue, right? We have push and pop. So we will use the predicate's enter and leave for representing push and pop. So the idea is that enter and leave captures the idea of elements entering into the queue and leaving the queue. Right. And both enter and leave have already three and the way to read enter a QR is that when an element a enters the queue queue, we get the QR.  So a way to read the other way to read this is if you push a into queue, you get the R out.

---

![slides/scene_0027.png](slides/scene_0027.png)
_t = 1817.2s -- 1887.1s_

And leave says that when an element a leaves queue, you get R. So this is also can be read as if you pop queue, you get a and the resultant queue is going to be R. Right. So that's the enter and leave. So here is the definition of so we have two more things here. So, so we have this idea called set up and wrap up. Right. So the idea is that set up is meant to initialize a queue. So that's an empty queue. Right. So an empty queue is represented by some variable a some variable X and then the suffix is also the same variable. So going back to our definition, right. We say the content of the queue is the content of the first component minus removing the suffix.  And because the suffix is the same as the first component, this queue does not have any elements. So that's the way you will read it. So we initially set up the queue.

---

![slides/scene_0028.png](slides/scene_0028.png)
_t = 1887.1s -- 1957.0s_

So this is sort of initializing the empty queue. Right. And then wrap up is meant to hold only on queues which have both empties. Right. So this is meant to sort of unify with the term where the queue is completely empty. Empty in the sense both of these queues are empty. The initial queue here is also empty. This is also empty. The idea here is rather than using a variable, we are actually using an empty list. Right. So I think that's the only difference here. But this is useful to say we've sort of consumed everything from the queue. Right. So that's the idea here. So we have set up and wrap up. So we will use the set up and wrap up later. But here is the definition of leave.  So what does leave say leave is like a pop operation. Right. So you're going to take an element of a queue and the resultant queue is going to be the third component. Right. So when when the variable A leaves this queue, which is queue x, z, you get queue y, z.

---

![slides/scene_0029.png](slides/scene_0029.png)
_t = 1957.0s -- 2026.9s_

And A has left A has left the original queue.  Which means we are going to take an element from the first queue. So and the way we represent that is x is one element A added to y. Right. So x has a y and if you remove A, you get y out. Right. And that's what we are representing here. So the queue has an element. The the front element that we have is A. Right. And if A leaves this queue, then what you end up with this queue y, z, where y is basically A consed with sorry, x is basically A consed with y.  Questions on this one. I might have not explained it in the most natural way. But any questions on this one?

---

![slides/scene_0030.png](slides/scene_0030.png)
_t = 2026.9s -- 2096.8s_

All we are doing is we are popping an element. Right. When you pop an element out, we say that we named that element A, A goes away and we are left with y, z. Right. And x happens to be A consed to y. Okay. Maybe this is obvious. But the next one is a little bit strange.  So enter, right. Enter is pushed into the queue and the difficulty here is this is an open list usually.  So we cannot because it's an open list, the suffix is not defined. We cannot push to the end of the queue. We have to play this little trick and the trick that we play is. So assume that y, this y happens to have an element A in the front and the tail is z. So recall that the second component of this queue data structure is meant for the elements that are being removed from the queue.  So why is the set of all elements that is not present in that is going to be removed from x and that will be the elements that are presented to you.

---

![slides/scene_0031.png](slides/scene_0031.png)
_t = 2096.8s -- 2166.7s_

So what we are actually doing is we are removing an element from y. Right. And that becomes z. So we are removing an element from the second component, the suffix, so that an element actually enters. Right. So this is. So we are we are taking off an element from the suffix, which will be the list of elements that will not be present in x. If you take an element out of this y, you will have one element into x. And that is what we represent here. So in order to in order for A to enter into this queue. You X comma y y has to be easy. Right. And you drop a from the second component. And that becomes the by dropping an element from this, this is at the subtraction side. Right. By dropping one element, you happen to magically have one more element here. And that's the idea here.

---

![slides/scene_0032.png](slides/scene_0032.png)
_t = 2166.7s -- 2236.6s_

It's a bit strange. So if you look at the examples, it will work out. So let me. Let me actually run this example and become a little bit clear. So. So here is the all the. All the. Queue definitions. Right. And then what I'm going to do is I'm going to copy this. Set up and then enter. So when I. Let me exit again and do it again.  You sir. So. And then if I first to set up you. Right. So if you do set up you. Observe that all set up does is it says that there are some variables X X. Right. And this just happens to be Q is just unified with that.

---

![slides/scene_0033.png](slides/scene_0033.png)
_t = 2236.6s -- 2306.5s_

So Q happens to be some variable underscore nine one seven two some variable underscore nine one seven two. So that's fine. We've set up a queue. If you do set up, that is all you get that everything is satisfied. If you now actually take this empty queue set up and then. Push zero if zero enters the queue then you get out. Let's see what that does. So now you see that. Q is actually unified differently now. The queue is an initial list. Which is empty. So the way it is empty is quite strange. We say that the first component has a zero and some suffix. And the second component is the same component. Because these are the same. This queue is empty.  And all enter does is it drops the zero from the second component. Right. That is what entered us. And if you drop the second component what happens is you get this are.

---

![slides/scene_0034.png](slides/scene_0034.png)
_t = 2306.5s -- 2376.4s_

Where the first component has a zero followed by nine five nine two. Right. And the second component is just nine five nine two. So the actual content of the queue is zero. Right by dropping a value from the second component we actually. Make an element appear in the first component. Right so this queue has one element this queue has zero elements even though zero is there. Right because of unification we happen to have zero here. And this queue has just one element. It's a singleton queue with the value zero.  This is a little bit. Different from what you will have seen earlier. So I'm sure you have questions if you have questions interrupt me.  And. There there are no dumb questions. I think this is like what people say all the time. Any question is a good question.  If you have questions do interrupt me. And.

---

![slides/scene_0035.png](slides/scene_0035.png)
_t = 2376.4s -- 2446.3s_

We'll see we'll see we'll proceed and then we'll see but do interrupt me even if I'm talking right just post the questions and then we'll get back to it. So what is happening here is we are removing zero from the second component. Right. And that makes this queue actually have one element. So that's the that's the way we simulate adding an element in the queue. So in turn the way to read this is that leave. Removes an element from the prefix right leave. X has an element a and that element is removed. So leave removes an element from the prefix and enter is the dual right. But it happens to remove an element from the suffix. So why happens to be easy and enter happens to remove an element from the suffix because because the suffix is the center wall elements that will be removed. If you remove an element from the suffix element gets added. So it's like it's a very funny thing that happens here. But it's it's the exact dual of what entered us.

---

![slides/scene_0036.png](slides/scene_0036.png)
_t = 2446.3s -- 2516.1s_

Sorry leave does and and we are just choosing the position to remove an element. OK so let me proceed. Let me actually proceed. So here is there is an example. I'll. What I'll do is. I will do this example one step at a time. So let's work with some queue right. So when you set up a queue all you say is this queue gets unified with the center. So we have the variable X here. So this initial queue is empty right. And let's say we are pushing one element into the queue. Right. If you push I have the initial queue queue and I say a inters queue to give me the queue are so observe that the initial queue. Now is unified with this. term which has a in the front but the suffix also has a so this this queue still has no elements. This queue still has no elements but are has one element right.

---

![slides/scene_0037.png](slides/scene_0037.png)
_t = 2516.1s -- 2586.0s_

There is an a. The suffix is there but this is the suffix that will be removed. So are has one element. Let's put push one more element into the queue. Right. So if you do this what we are saying is. Push B into R if B enters are you will get S. So observe that the initial definition also has changed but queue still has zero elements because these two terms are the same are has one element a. Right. So this is there but the suffix is the same as the one here. So are has one element a. S has two elements right a comma b because this suffix is the one that is here. That will be removed. And then what do you have you have what we are going to do is pop one element from the queue so queue has a comma b the thing that you will pop will be a right. So I say let me pop an element S sorry X from S.

---

![slides/scene_0038.png](slides/scene_0038.png)
_t = 2586.0s -- 2655.9s_

This is the last queue that we were working with if you pop an element from S. Let's call that element X you will get T. So we expect that X to be a. So let's see whether that is the case X is a right. And you are left with a queue which has just a B right. And this T happens to have just B because the suffix is the same this suffix is the same. And if you pop one more element you'll get B. Right. And we say I'm going to name that element as Y. So we see that X is a and Y is B. The second element that we pop is B. And what you end up with we push two elements we pop two elements. So we end up with the queue Y sorry queue you. Right. Where these two components are the same. So you has no elements at all. You has no elements at all. And we can wrap up this. Right. We say this queue has no elements. Let me just wrap it up. And if you wrap it up all wrap up does is it unifies this variable with empty list and that

---

![slides/scene_0039.png](slides/scene_0039.png)
_t = 2655.9s -- 2725.8s_

unification sort of replaces all the 9 9 8 with empty list. Right. And you get this. So initial queue happens to be empty. When you push an element you get a when you push B you get B. When you pop you get a initially and the queue is B when you pop again you get B and the queue last queue is empty. That is what we have here. So here is a short quiz.  Right. So we have Q the QSQRSTU.  What are the lengths of QRSTU. You can type the answer in the chat window. Yeah. Right. So 0 1 2 1 and 0. OK good. Yeah I should have more quizzes. I'll do that for the next following lectures.

---

![slides/scene_0040.png](slides/scene_0040.png)
_t = 2725.8s -- 2795.7s_

I think this mode is sort of very bad for not having any feedback. I'll see some nodding heads if you are in the class are like starting faces which will give me some feedback. But anyway so the answer is 0 1 2 1 0. So a strange thing with this implementation is because these enter and leave are duels right. Unlike regular queues where you need to push before you pop here you can pop from an empty queue with the contract that you'll push the same element.  So here is a very strange use of queues. But this is perfectly fine in prologue. Right. We say we start with the empty queue. I push I pop an element out. I name that element to be X. I pop one more element out. I name that element to be Y. Right. And then I enter a and enter B. Right. Then I push A and B. And then I wrap up. So let's see what happens when we do these three. Just these three.

---

![slides/scene_0041.png](slides/scene_0041.png)
_t = 2795.7s -- 2865.6s_

First. Yeah. What I'm saying is this queue will be empty.  And then I pop an element. I pop one more element here. Let's see what happens. So it says that the initial queue is empty because these two are the same. And then this says oh I've lost. I've lost X here. Right. This is sort of very strange. The suffix actually has one more element than sorry. The second component has one more element X than the first component. What this says is there is some X which needs to be filled in later. And similarly if I if I leave again if I pop again all I say is I will add a contract for later which says that for the suffix has two more elements than what the first component has. So if you fill in these two components right I will consume those. So it's like a negative queue that way. So if you now enter A here.

---

![slides/scene_0042.png](slides/scene_0042.png)
_t = 2865.6s -- 2935.5s_

Right. So now it says it unifies that with A here. Right. So what happens is it happened to be the case that this was this had two negative elements right. And because we've entered this is going to fill in the first element. So X is going to be A and you can do the same thing for B. Right. Just to complete the argument there is still minus one element here. Right. There is some way which is not there in the pick. So if you enter again that element is going to be filled.  And that way happens to be B now. So I pushed B. So I happens to be B. So I happens to be B here and the queue has become empty. Right. So you is empty so I can wrap up the queue. So this is quite a strange way of looking at use but in a purely declarative fashion this works. Right. So we are not actually manipulating things in operational way.

---

![slides/scene_0043.png](slides/scene_0043.png)
_t = 2935.5s -- 3005.4s_

We are actually doing it completely degraded. Dictoratively. What this means is you can take elements from an empty queue with the contract that you will add the element status. Right. So if you wrap up that is what you get. Right. When you wrap up you get initially it is. Yeah. You know what is happening here. So here is a question again. Right. This is the same example. The code is the same as previously.  And what are the lengths of Q R S T U now. Yeah. So that's the answer. I already got it right. So initially it was zero and this one has negative one element. Right. R has negative one element. This is negative two elements. And this happens to have negative one. And this is zero. So really push and pop are not very different. If you think about I mean this is really curious right at a high level.

---

![slides/scene_0044.png](slides/scene_0044.png)
_t = 3005.4s -- 3075.3s_

So if you sort of even imagine a functional version of QS take lists. Right. I can always cons onto a list. Right. But I can't always get the tail of a list because the list could be empty. So there is something that is not exactly mirror image. The push and pop is not mirror image. Right. You can always push into any queue at all. You will just get one more element. But you can't pop an element from any queue because you can't pop an element from empty queue. So this this this even though push and pop are the duals of each other. They sort of break down at this empty queue. Right. But that is gone here. So the thing that happens here is you can pop from empty queue. We just happen to have a contract which you have to satisfy later. It's a really curious way of thinking about push and pop that are completely duals here. That's the high level takeaway here.  Let me format it better. OK. So I hope you got the point of this. Right. So even though this looks like push and pop but they are really push and pop in the declarative sense.

---

![slides/scene_0045.png](slides/scene_0045.png)
_t = 3075.3s -- 3145.2s_

They are really mirror images of each other. Unlike say push and pop that we have on say imperative or functional languages. Zero minus one minus two minus one zero. So last quiz I'll stop here. So what is the result of this query. So I set up I leave an element I pop an element and then I wrap up. Yeah. So the answer is false because wrap up will only work with. Just to show you what happens. So wrap up only unifies with the empty list.  And what happens in this example is Q has zero elements.  And has minus one elements. You can't wrap up a queue with length minus one. You get wrap up queues with the length zero. And that is what happens here.   OK. That happens to be one more. Maybe I'll stop here. So we've looked at queues right.

---

![slides/scene_0046.png](slides/scene_0046.png)
_t = 3145.2s -- 3215.1s_

So queues is first and last. What is the end of the. Last and first stack. Yeah. So two is the answer. So we are not so stacked is much less interesting because we are not playing this negative game. So all we are saying is we are going to we are not going to push element at the end. We are going to push at the front. So so if you enter a into this stack. Which has X as the prefix then you get Y where Y happens to be a constricts. So this is much less interesting. Right. But otherwise if you just change the enter then all of this will work. And also this you can do you can play these negative games with the stack as well. You can leave keep leaving and then keep pushing. So that will happen. You are. Yeah. That's the answer. So I'll stop here and then we'll continue tomorrow. Thank you.

---

![slides/scene_0047.png](slides/scene_0047.png)
_t = 3215.1s -- 3215.1s_

_(silence)_

---
