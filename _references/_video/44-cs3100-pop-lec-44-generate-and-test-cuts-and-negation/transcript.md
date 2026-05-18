# 44-cs3100-pop-lec-44-generate-and-test-cuts-and-negation

**CS3100 POP - Lec 44 - Generate and Test + Cuts and Negation**  
id: `zquOqToUXVI`  
duration: 3309s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Okay, so what we are looking at the last class is this idea of generate and test. So the idea here is to, so this is a design pattern for logic programming, the idea is to generate a candidate solution, and then actually have a test which tests whether the

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

solution that the candidate solution that we've generated satisfies the property that we are looking for. So this is a design pattern for logic programming, we'll sort of see why this is useful and various ways of using it for some interesting examples. That's what we'll do. The idea itself is quite simple, but we will see the applications of this idea in multiple examples. Okay, so this is a famous problem that was formulaized by Dijkstra.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

I hope you know who Dijkstra is, right? So Dijkstra invented many of the core algorithms and ideas that underlies current computer science and he also happened to be a Dutch person. So he invented this problem called Dutch national flag. So the problem itself is very simple. So given a list of colors with red, white and blue, return a list such that all the

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

reds are at the first and then followed by white and then followed by blue, which matches the Dutch national black. So this is essentially a sorting problem. So we know how to do sorting. So this is a different way of achieving the same solution, but the methods are going to be very different. Okay, so that's the idea here. Yeah, okay, so we are going to use generate and test for this.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

So we have a procedure for generate, right? We generated this idea of permutations, right? That is the generation procedure and the test procedure is the correctness of the condition that we want, right? The condition that we want here is that in the given list, there must be all reds followed by all whites, followed by all blues. So we will implement this as a test. And the way we will do this is we will implement this predicate called check flag that takes

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

a list of colors and then checks whether they are in the order red, white and blue. So the way we've done this is check flag. Check flag is a clause, is a rule that holds on some list L if check red of L holds, right? And check red of L holds if the head is red and check red of tail holds, right?

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

So you sort of like pop one red element out. And we also need to transition to this checking the white. So check red also holds if the head happens to be white, right? And for the tail now, this predicate called check white holds. So we are now off to checking whether the rest of the flag is well formed, right? Check white of T holds. So similar idea for check white, right?

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

So check white holds if the head of the list is white and the tail of the list happens to be satisfying check white predicate. So this is going to keep checking, be accepted for multiple iterations of whites, right? Multiple occurrences of whites. And we need to transition to blue. So check white also holds if the head is blue and the tail happens to satisfy check blue predicate. And similarly for check blue, the head has to be blue. The tail has to satisfy check blue.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

So this will keep consuming multiple glues. And the flag should end, right? So check blue of empty list also holds. So essentially what we're doing is we are describing a state transition system, a state machine, right? So which recognizes reds followed by whites followed by blue. So if you run this and you check whether this flag is well formed. So assume that this is the flag, right? Which has red, white and blue.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

It is going to return true. But if you have white, red and blue, which is not a well formed flag, which is not a well formed dash flag, it's going to return false. Okay, so that's the idea here. So this is basically checking whether the given list is well formed. So here is a short quiz, right? So here is a quiz. So this is the same predicate list as defined earlier.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

So these three queries. So you can, of course, provide your answers in chat window. Two of these are easy. One of this is maybe a little bit dirty. Any answers? So I'm going to check flag. Okay, all true.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

Yeah, so I think many of you have gotten this right. True false false is the answer. So really, the way to solve this problem is the ask the intuitive question, right? The intuitive property that we are solving is Dutch flag. That six flag is does not have any colors at all. So it's going to go to check, right?

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

Check, right? If you look at check, check, right? Check it predicate. Ignore the colors for the woman check, right predicate only works on it unifies with the goal that has at least one color in the flag flag, right? So this particular third one is going to return false because we cannot unify empty list with an empty list. So that is going to return false for check flag blue. You see that the colors are red and white here, right?

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

Why am I doing this check flag goes to check it first. So there is red and white. This is going to fail, right? Because blue doesn't unify with red or white. These are just the atoms. But this one is a little bit interesting. So check flag white blue, right? If you look at these two, there is a white here, check red of white. And this goes to check white of T, which can, of course, satisfy with the check blue of T and check blue of T has an empty list that precisely satisfies the first one.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

So the answer, as many of you have correctly got, is true false, false. But this is not desirable, right? So we really want a Dutch flag. If you just have a white and blue, it's not a Dutch flag. How do we fix this? The way we fix this is we add one more state in the state transition system, right? Basically, we have a gatekeeper which makes sure that there is a red color before you can actually go on to it.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

So I introduced this idea of check red and check red too, right? So check red is a predicate, which is what check flag calls into. Check red has only one clause, right? And the only clause says the first color has to be red and the tail has to satisfy check red too. This is just a gatekeeper there. And check red too is the same as the previous check red.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

It consumes multiple reds and one white and goes on to check white, consumes multiple whites and then goes on to blue and everything else is the same. The only difference is this idea of splitting this red into two separate states. So now if you do white, blue, it returns false because check red has only one rule and the

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

head of the rule unifies only with a list that has red as a first color. This one doesn't. So this is the checking procedure. So we are going to use CHK flag for our checking procedure. Now the question is, the original problem said, OK, I will give you a list of colors and you have to give me a list that orders the colors in the right order.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

And the way we do this is using permutations. We use permutations to generate one of the possible alignments and then we check whether that particular ordering satisfies the check flag primitive. So make flag takes a list of colors and then returns you a flag F, which is one of the permutations of the given colors. And basically, this is just what I said. So it permutes the input with some F.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

Sorry, it permits the given list to get some list, which is F and we have check flag of F, which is just a test. So if we can generate one permutation that satisfies check flag, then we are done. So now, of course, this has many answers because blue and blue are equivalent. So if you reorder these, you'll get the same answer. So that's why I limit the results to one.

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

But here, the idea is that I have white, red, blue, blue, blue. So the answer would be red, white, blue, blue, blue. So this is what I have here. So this is the key idea behind the generate interest. So you permute the input to generate a candidate solution, which is F. And then you check that the candidate solution satisfies the property that you're looking for. And and yeah, and as you can see, right. So this is this is sorting.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

So we are sorting the colors according to some predetermined order. You can. Yeah, so this is what I mentioned. So generate a solution, test if it's valid. If it is not valid, then throw log automatically backtracks and writes another solution because permutation gives you all the permutations. So that is why it works. And if you if you stare at it, the problem is the same as sorting. So we can define a sorting procedure, a permutation sort, which sorts the input list of

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

numbers. Right. So here is the sorted property. So as usual, what you what you have to do is to define a test for sortedness and then you'll use permutation to generate the sortiness. So testing sortedness is much easier than actually generating the sorting procedure. I'm not claiming that this is efficient for sorting because there are we know that there are other efficient procedures, but this is just to get the point across. OK, so when do we call a list to be sorted?

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

An empty list is sorted. A single list is sorted. A list which has at least two elements is sorted if A is less than or equal to B. And the tail of the list here, right, which is B appended to tail is also sorted. So this is the procedure that you would write, say, and see if I were to tell you to write a procedure which says, given an input list, check whether it is sorted.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

So we have this sortedness procedure. So that's done. Now we can actually check whether something is sorted. Just to get the point across. One, two, three, four is sorted. So that goes through one, three, two, four is not sorted. That is false. So here is a sorting procedure that uses permutations. So given an input list, this predicate perm sort holds the way to read this is predicate

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

perm sort holds if given an input list, SL is a permutation of the input list and SL happens to be sorted. And this is precisely what we have written down here. So SL happens to be a permutation of well and SL happens to be sorted. So if you do this, then here is a simple example, which is one, three, five, two, four, six, which is not sorted. And then you can sort it using this procedure.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

So so this works out, but this is not the most efficient sorting procedure. It's a it's a terrible idea, right? We know we have better idea for the sorting. A better approach would be to divide and conquer. So this is you want n log n running time, don't you? So divide and conquer gives us the n log n running time. And just to make sure that you don't get the wrong idea that sorting is like a terrible

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

procedure in prologue, I'm giving you a quick sort. This is a bit of a digression from generate and test. So this is just a illustration of how you can do efficient algorithms in prologue. So what we are going to do is to implement a quick sort, which we know is an efficient sorting procedure. So we are going to partition the input list into based on a pivot, and then we are going to sort the sub lists and append them together.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

This is what we're going to do. So in order to do this, we need a procedure called partition. Right. And the partition predicate says that given a list L and an element X, which is the pivot, it gives you LES, which is the list of all elements which are less than or equal to X from L and G S, which is the list of all elements which are greater than greater than X from L.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

So this is this is partitioning the input list into less than or equal to and greater than. And how do we write this procedure? So if the given input list is empty and you have the pivot Y, then the partition is going to be empty, empty. So that's easy. So let's say the given list has a head X and a tail XS and the pivot is Y. Right.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

If X is X is less than or equal to Y, then X must be in the in the less than or equal to list. Right. So X will be part of the less than or equal to list. And RS is some list. So L S and RS is not defined here. They are defined as part of the recursive call. Right. So you basically say if X is less than Y, then X must be in the less than or equal to list. And how do you get L S and RS?

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

You recursively call partition on the tail of the list XS. Right. So XS is the tail of the list. You partition XS such that all the elements less than or equal to Y is in L S and greater than Y is in RS. And once you get that, you can just cons X to the front of the less than or equal to list. So this is this is for the less than or equal to case. And for the greater than case, you do the same thing.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

If X is greater than Y, then X will be part of X will be part of the greater than list. And we have a condition here which X so that X is greater than Y. OK, so this is partition. So to give you an example of partition, this is the input list, right, which has some list of numbers. And then you have the pivot to be four. We want X and Y.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

So all the elements that are less than or equal to X are in four are in the X list and elements greater than four are in Y lists. OK, so now that we've defined partition, we can easily define Wixort. So Wixort is the procedure.  What do we want for Wixort? Sort a quick quick sort. Holes basically the way to read the quick sort is given an input list.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

Quick sort of that is going to be the sort of list. So that's the reading. Sorting an empty list gives you an empty list. Sorting a non-empty list with the head H and tail T gives you a cell. Right. Where you pick H as the pivot, right, partition the tail into Ls and Rs. You recursively call a quick sort on the less than and greater than.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

So if you quick sort Ls, you get sorted Ls, SLS, quick sort the right hand side list, you get sorted Rs. So you've got sorted sub lists. All you need to do now is to append it such that the pivot sits in the middle. So which is what we are doing here. So SLS, pivot points to the Rs list and you get a sorted list. So this is a natural description of the quick sort algorithm.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

And here it just works fine. And this is efficient. So this is doing divided and conquer. So of course you can do these sort of algorithms. So let's any questions on this. So far. This is a digression, right? Quick sort again, quick sort doesn't use generate and this. I just want to show you an example of doing quick sort and go along.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

Okay. If there are no questions, let me proceed. So have you heard of the end Queens problem? The idea is that you'll be given n cross and chessboard and could be any number and you will have to take n Queens and place them on the

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

chessboard such that none of them threaten each other. So, you know, the rules for the Queen, right? So Queen is threatening another Queen of they are in the same row or the same column and the diagonals also. So diagonals also shouldn't have any threatening positions. So for and you can generalize this for any and so you can you can sort of say you can give it any end and there might exist a solution. There might exist many solutions that might exist one solution.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

But the idea is to find such assignments. Okay, so that's the goal of this procedure. And typically this is done for eight cross eight. Yeah, so this is a this is a problem for which backtracking is the right way to do it. So you sort of place one Queen at some position. You then try to place the next Queen in some other position. If they threaten, then backtrack and then try the other position.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

This is precisely how to solve this problem automatically and prologue is best place to solve this because backtracking and choice points are built into prologue. So if you had to implement this and see you would implement backtracking and choice points. So that's that's the point that I want to get across in this example. It is these are the problems are very natural to experience in prologue. Okay, so here is there is the idea behind the implementation.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

So one thing that you really want to do is if you think about generate and test, right, it is generating lots and lots of positions and then it is checking whether that position is safe. So if you want to make generate and test efficient, you must think about a good representation that rules out invalid states by construction. Right. So this is

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

I mean, this this this idea is sort of succinctly captured by this term called make invalid states under presentable. I think this this quote is attributed to Ron Minsky, who is one of the managing directors of Jane Street. So he mentioned this as part of why OCaml is nicer, right, because you have algebraic data types, you can precisely define what states are allowed. And by making other states not even possible to write down, you don't have to consider those states and this nicely applies here.

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

So what we will. So the application of this idea here is that what we'll try to do is to avoid having a construction where the queens are on the same row or the same column. So we won't even generate a candidate solution where the queens are in the same row or the same column. So that's the design principle that we'll start with.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

So by not even being able to represent a state where a queen may be two queens, maybe in the same row or the same column, we are not even going to generate those states. We we make the generation procedure very efficient. So this is what we are going to do. This is where mostly if you sort of have a good data structure, the algorithm becomes much simpler to implement. And this is one example of that. So here is the representation that we use for the position of queens on the board.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

OK, so we represent the position of queens on the board as a permutation of one to n. So if I am solving this for n cross n matrix, I will say that the assignment, a candidate solution is going to be a permutation of one, two, three, four up to n. And the way to read this is each number represents the position of the queen on that row.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

And one, two, three, four up to n says that the first queen is on one, one. The second queen is on two, two. Third queen is on three, three. Fourth queen is on four, four and so on. So by having by having one queen at each row, we rule out the case that two queens are on the same row. Right.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

And by having this as a permutation of distinct numbers one to n, we avoid the case that the two queens are on the same column. So if you want to represent two queens on the same column, these numbers should repeat. By ruling out that any number, any permutation of this, any permutation of this list is if you interpret that as a position of the queens, then two queens will not be on the same row or the same column.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

So we've ruled it out, but not every solution obviously is a correct one because this solution is wrong.  So if you think about this, the first queen is on one, one. The second queen is on two, two. The first queen is threatening the second queen in the diagonal. Actually, it's threatening all the queens on the diagonal. All the queens are on the on the on the main diagonal in the chessboard. Right. So this is not the solution, but if a candidate solution exists, it will have to be a permutation of this particular list.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

So that's the that's the key idea here, which makes it work.  Now all we have to do is the usual thing. We generate permutations. We need to implement a test which checks whether this permutation of this list is a valid assignment. So we have to check whether the queens threaten each other in this.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

So the way we do that is we implement a procedure called the check board. Check board takes a list and returns true or false. And the idea here is that this this this this is going to check whether the positions are valid. So what we are going to do, the high level idea is that we will iterate through each row. Right.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

And for each queen on that row, we will check whether the outgoing diagonals the diagonals this way. So for the first queen, we will check whether this diagonal does not have any queen. This diagonal does not have any queen. Of course, there is no possibility of queens here, but the outgoing V, right, the upward facing V does not have any queen. So we will do this for the first queen. If that is OK, we'll do this for the second queen. That is OK. We'll do this for the third queen. And fourth queen and so on.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

So for each of the for the board, we are going to iterate through each row for each of the row. We are going to take the position of the queen and we are going to check whether the upward V does not have have any queen. So this is the intuitive idea. The procedure itself is just translation of that idea. So what do we do here? Check board has two predicates. So if the board itself is empty, then the board is safe, right? The length is zero.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

So it is safe. It is going to be used because we are going to keep checking rows. So the important one is this check board rule here. It says, OK, H is the position of the current queen at some row. Now you need to check the upward facing V, right, for the tail. So we are going to look at the tail and we are going to see whether the upward facing row is void of any queens. So we are going to do that step by step.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

So for the so if if I'm considering the row one, right, for the row two, the upward facing V is the next both the previous column and the next column. So this one and this one. So which is what I'm computing by having L as H minus one. H gives me the position of the queen. L is H minus one, which is this position and R is H plus one, which is this position. Right.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

And I check queen here. So what I'm going to do is to call check queen, which takes the current position of the queen on that second row and checks whether the queen is not on L. The queen is not on R. So this is not equals arithmetic, not equals. So that we understand the syntax. This basically means H is not equal to L, H is not equal to R. So if both of these fold. So what do we know?

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

We know that in the next row, the queen doesn't threaten. The position of the next queen is not threatening. It is in some other row. In this case, it happens to be on the column F here. So we have to repeat the procedure for the same the same idea. Right. So if I checked L minus one and H plus one for the third row, I have to check L minus two and H plus two here, which is what I do here with the recursive

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

problem. So I say L next is L minus one. R next is R plus one. Right here and here. And I check that the next queen, the third row's queen is not in that position. And you keep doing this over and over. So for a given queen, this check queen checks whether there is no threatening queen on this V. And check board basically goes through and checks for the tail of the list.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

So this is the inner loop, essentially. And this is the recursive call to the outer loop. And the inner one is also a loop because the check queen calls another check queen. So there are two for loops, essentially. And that's the procedure that we want. So this is this is checking whether the queens are in the correct positions. So here is a satisfying solution for this one.

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

I think this is this is capturing this assignment one, six, eight, three, seven, four, two and five. And this is a valid assignment. So check board of this assignment gives me two. Any questions on this one? How we input this one?

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

OK, looks like there are no questions. So I'll continue. So we've designed the test procedure. Now we have to design the we have to combine the permutation and the test. So for N queens, we need to solve for arbitrary N. Right. And the and the starting solution is a list from one to N.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

So we write a simple procedure for generating a list from one to N. We use this procedure called make list. So the idea is that given some N, it forms the initial assignment, which is one, two, three, four up to N. So if it is zero, then just return an empty list. If it is some N, which is not, which is simply zero, but it doesn't make sense here. If it is N is greater than zero, then consider M to be N minus one.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

I make an initial assignment for M, which is one less. That's the recursive call. And then append the end to the end of the list. Right. So you will get an assignment, which is you say N is eight here, you will get one to seven here. And for one to seven, append eight to the end. So what you get is one to eight. Right.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So if you do this and run this, you'll get the assignments one to eight. So, OK, so given that now we can actually solve N queens. So the point of N queens is given any end, we are going to get the board assignment for the end. And the way we do that is we first generate the initial assignment for the end. We permute the assignment. Right. And we check whether that particular assignment satisfies the board property. That is N queens.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So here is one solution for N queens. So give me a solution for a queen's problem. Give me the board assignment for that. So if you run this, then you get one assignment here. Actually, there are if you look at Wikipedia, there is ninety two solutions for this eight means problem for eight means. There are more and more as you sort of increase the both sides. You can get all ninety two with the same procedure. You don't have to do anything because prologue has built in backtracking and choice points.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

So all we need to do is to ask this and you'll get all the solutions. I'm not going to go through this, but you can check that these are the solutions that are all valid solutions. So these are the problems which are backtracking and exploration. These are very naturally encoded and prologue compared to other languages. Any questions on this one so far?

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

OK, so that is all I have about generate and test. So let me move on to the next picture. Which is going to be on. Cut some negation.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

OK, so. So the title of this lecture should sort of kindle some interest in you because. The negation here.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

One thing that we sort of mentioned early on in when we studied the logical foundations of prologue is that we don't have any way of representing negative information in definite clause logic. And that's why every program has a model. So this this should this should sort of. Bring in some questions in your mind and we will see what those are. So previously we saw generated in this.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

Today we are going to see this idea of cuts. To give you a like a one line summary. Prologue is not a pure logic program, right? So it does essentially resolution. So it basically picks the goals in the order in which they are written down. That's the rule order. And there is also the goal order. So you pick the leftmost of goal to satisfy before you move on to the next one. So you have this search tree. Right. There's a deterministic procedure for going through the rules.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

And you get choice points, essentially. And cuts in prologue are this extra logical mechanism. So they are not pure logic. They are a way to prove prologue search trees. So you place it and make it more obvious. They are a mechanism for erasing out certain choice points.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

And it is quite useful for making your programs efficient. But you can also express properties which are not expressible. Just by your prologue without cut. So we will study the idea of red and green cuts. Green cut is going to again, just to give a summary. Green cut is taking the existing prologue program using a cut to make it perhaps faster, right? Red cut is actually changing the meaning of the program using a cut.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

Anyway, so that that's the intro to this lecture. And so we'll see we'll motivate why we need these cuts at all. Okay. So here is a simple interpreter and evaluator for arithmetic expressions. Right. And the arithmetic expressions that I have are plus a b. So we can construct terms which are plus a b, which means that a plus b.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

And you can have multi b multiplied by b and you can have ordinary constants. Okay. So one, two, three, four and so on. So the way we are going to evaluate this eval is the interpreter function. So it takes a term, right? An arithmetic expression, and then it's going to produce a integer value as a result.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

That's the meaning of evaluating that arithmetic expression. So what does this do? So eval of plus a b is C. If you evaluate a and you get the value of a, a is a number, right? Evaluating b, the arithmetic expression b gives you the value vb. And va and vb, we expect to be numbers and C is going to be va plus vb.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

And similarly for multiplication, evaluating a is va, evaluating b is vb and C is va times vb. And for everything else, we just say eval a holds. So this is expected to match with constants. So if I say plus one, two, the idea is that one will match this one. You get one. Two will match this one. The same rule. You'll get two.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

And plus one, two gives me three. That's the idea here. Of course, the point of having this introductory example is that it is going to be broken. And we are going to fix it. So we'll see how to fix it. So we've added three clauses. So here is here is the idea, right? So I have an arithmetic expression here, which is the same as one plus four times five. It says plus one, four, five.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

And if you ask for the first result of this, it gives me twenty one. So twenty four times five is twenty plus one is twenty one. But if you ask for the second result, it says the important one here is and this is an arithmetic error. So you can run this in the SWIPL interpreter and find that this is an arithmetic error. The problem here is that if you sort of look at this this goal,

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

this fact, our intention was that A will be a value, a constant, an atom. And if you give an atom, it will be an atom. That is what we expected. But the point is because because A is available, it unifies with anything at all. It unifies with any compound term and in particular, when we happen to call eval on this one, even this term, right,

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

this whole term unifies with A, right? And our program says that if you evaluate this compound term, if you unify with this goal, the result of evaluating that compound term is going to be the same thing, the compound term, which is plus one, sorry, plus one, multiple four times five. In particular, this occurs in the recursive call.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

So it turns out that we will get a call where we will try to evaluate a multiple four five, which is the multiple four five here. And the result will be multiple four five because of this particular fact. And as we know, right, when you get non-arithmetic, non-numerical terms here. So this is computation is going to fail actually, plus is going to fail as well. So it is going to numerically evaluate the term here.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

But because of our fact here, we get an expression here, which is not what we want. And that fails. So that is the reason for this failure here. So the question is, how do we fix this? So one way to fix this is to actually introduce a function called value. And the idea of a value is that you wrap all of the constants in this constructor call value. Right. So you imagine this this function value to be a constructor.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

And you say, if I have to use constants like one, two and so on. So you wrap this with value. And we change the evaluator. The only rule that changes is this rule. We say eval two of value of A is A. If you give me any other expressions, this won't unify. Right. And we have to take the example this way. So rather than directly using the constants one, four and five,

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

we have to wrap it in value of we have to wrap it in this function value of one value of four and value of five. Right. Now, this term, which is multi B, does not unify with value because the top function symbols are different. Right. So this one works fine. So there is only one solution for this. So it gives me 21. Right. So but if you sort of look at this, this is undesirable.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

We are sort of wrapping constants with functions just so that the unification does not causes any issues. The observation is this. We know that Prolog picks the rules in the order in which they are written down. If you if you unified with if you unified a particular term with plus AB this this head, you shouldn't go ahead and unify this with a value.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

Right. And similarly, if you unified with MUL, you shouldn't have to unify that with value because sorry, it says value here, but you shouldn't go further because there is only one rule that is applicable. So one way to actually say tell Prolog that if you happen to unify with this head, don't go and look for other choices, because if you look at other choices, then you are going to go wrong.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

And the way to express this is this idea called a cut.  Cut in Prolog is written down with this exclamation mark. So this is a goal. You read this cut as a goal, but it is it is extra logical. It is outside of your logic. The idea is that it proves the search trees. And in particular, it proves the search trees according to two rules.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

When you come across the goal cut in the rule, it is going to have two effects. All the subsequent choices like the branches in the head of the rule in the rule where it appears, all the subsequent choices are erased. Right. And all the possible choices and all the preceding subgoals. So you might have multiple subgoals. And that might appear somewhere in the middle of the body of the goal.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

So all the possible subsequent choices in the preceding subgoals are also erased in the same rule. It only applies for the same rule. I mean, this is a bit abstract, but we'll see more and more examples as we go along. But this is the precise description. We'll see how cut can help with our evaluator.  So. I am writing down an evaluator eval3 here. This is the same as the initial eval1.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

Observe that I am no longer using the value function, but I have introduced cuts here. And the way to read this is that if a goal matches unifies with the head of this rule, right? The natural behavior of prologue is to go ahead and say, OK, I will now try the recursively the the body of the rule, right, all of the subgoals in the body of the rule.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

The first subgoal happens to be cut. The idea is that if the control crosses this cut and goes on to the next subgoal, one effect that it has, which is what I've defined here, is to rule out all possible branches in the head of the rule. If there are other possibilities for matching, right, then you sort of rule out the rest of the explorations here. And the net effect of what is happening here is

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

that if if the given term matches plus, then you will not explore the rest of the rules. The given term matches mult because we have a cut here. If you cross over the cut, you will not match with eval3. And only if you don't match with unify with plus and you don't unify with mult will you actually unify with this particular fact. Right.

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

So what happens here? So you have eval3, right, which says plus one mult four or five. So this pattern this unifies with the head here and you cross the cut.  In without the cut, you would also have another possibility for unification. This whole term could be unified with just a here. This goal unifies with this fact.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

But because we have a cut here, we no longer explore it. And similarly, for the recursive call where you will have mult, right, because you have a cut here, if you cross this that point, you're no longer going to go ahead and try the rule here. So the only possibility for matching this fact is constants, right, because constants don't match with either plus or mult. They are the only ones that match here.

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

So that works out. So if you do if you do cut here. So we only get one answer. Unlike the initial case where we had more than one answer and that fail. And here we only have one answer and it happens to be in a natural form. But it's sort of pruning the search trees to give us the answer that we want. Any initial questions on this one before I proceed?

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

Yeah, it is it is extra logical because because it has side effects precisely because it is ruling out a certain choice points and choice points and all of this. If you look at the abstract interpreter, it didn't talk about choice points at all because it was naturally encoded in the non-deterministic that is available in the interpreter, but in order to even explain cut,

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

you cannot use that abstract interpreter because abstract interpreter is non-deterministic and cut is precisely ruling out a particular search tree which is based on a procedure. So, of course, yes, we call it extra logical because of the side effects. Any other question? That is a bit weird, so you have to be careful when you use that because it is

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

pruning search trees, right, so you'll see some if you put cut in a wrong place, you'll see some weird behaviors, you'll look at a bunch of weird behaviors that sort of prep you for what you can expect with the cut. OK, so. What is the second point? This this point. We haven't come across that one yet. You'll see an example in the subsequent slides. I've only shown you examples of this one. This is at the first position, right?

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

So we don't have any proceedings of goals. You come to that. OK, so. I think this this example succinctly captures all. Cut. So this is a very simple. This is meant to be just a way to explain the behavior of that. So there is a there is a fact called PA.

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

There's a fact called PB. There is a fact called RC. Right. And there is a rule that says Q X holds if P X holds and there is a cut here. Right. Let me clear the. Let me clear it so that. My I don't give away the answers. So and then we also have Q X. It says Q X holds if R X holds.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

Right. Right. So if he's not a star at it, what is going to be the result of Q X? So I query Q X here. I haven't actually explained the second point, which is what Venkat was asking. But given it right, what will be the result of this particular query?

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

Yeah. So. Yeah. Yeah, so exactly right.  yeah, so let me go through this step by step. What happens with Q X? So it goes through the first one. Actually, let's let's go through it. I think the answer might be interesting. So we have Q X that matches with the first goal here. OK, that's fine.

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

And it goes to P X. And P X says so it recursively goes ahead and then finds a. So P matches X unifies with A. Of course, there are there are more possibilities for Q X and more possibilities for P as well. Right. And because we we have a cut here, it proves out both of these choice points, right? There is a choice points here which allows the cut to proceed to the next one.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

There is a choice point here because this X is unified with A here, but X can also unify with B that is also cut. So if you run the result, it's only because we the presence of the cut here both proves out the choice point in the head of the rule and choice points that are possible for the the preceding sub goal.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

So this is precisely what Venkat was asking earlier. So this proves out the preceding sub goal as well. So as a result, you only get A. Let me look at let's look at one more example. So this is this is a so the second example is the same one. I just renamed everything. I just moved the cut to before this call to P. I call it B2 here. So what will be the result of this one now?

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

So the presence of cut here. Yeah, so A B is the answer. So the presence of the cut here rules out further exploration for for this goal. So we won't go into the second rule, but practice before B2, so we will explore both A and B. So the answer will be A and B.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3210.0s_

Just to complete the argument, if you don't have the cut, actually, I need to restart it because prologue will get confused. So if you don't have the cut, then you can see that the answer will be A, B, C. The presence of the cut here. We restart the kernel. The presence of the cut here.

---

![slides/interval_0108.png](slides/interval_0108.png)
_t = 3210.0s -- 3240.0s_

It's C. And if you understand these two examples, you've understood cuts. You use cuts to construct interesting patterns, but it's important that you understand how these two examples work. Yeah, OK, so I'll stop here.

---

![slides/interval_0109.png](slides/interval_0109.png)
_t = 3240.0s -- 3270.0s_

Questions on this so far. If you have any questions, I'll wait for a minute and then we can. We can stop. Try it out. So. See whether the idea matches. So as I said, there are only two. Two rules here.

---

![slides/interval_0110.png](slides/interval_0110.png)
_t = 3270.0s -- 3308.9s_

So see whether the understanding matches the examples that you wanted. I'm sort of different because I can't answer it off the top of my head. Any other questions? OK, good. So I'll stop here and then we will we will meet Friday. Thank you. So.

---
