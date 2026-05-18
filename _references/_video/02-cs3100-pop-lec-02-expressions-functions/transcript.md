# 02-cs3100-pop-lec-02-expressions-functions

**CS3100 POP - Lec 02 - Expressions + Functions**  
id: `mtrzgNqL_A8`  
duration: 3201s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Let's start from where we left off, isolate. So we are looking at expressions. Okay. Okay.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

So can someone confirm that you can see the screen and get my voice? Okay, wonderful. Okay, so we were looking at expressions in OCaml. And in particular, we were looking at how expressions have syntax and semantics.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

And how the semantics itself is of two kinds. One is the static semantics, which is the type of the expression, essentially, which is done at compile time. And the second one is the dynamic semantics, what the expression evaluates to when you run the program, right? And in OCaml, there is a strong distinction between static and dynamic. In JavaScript, there is no static semantics. You start executing the program, whatever you write,

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

as long as it is syntactically valid JavaScript, you start running the program. But in OCaml and other strongly typed languages, this is not just specific to OCaml. You can also think about Java as an example of this. If your program does not type check, then the compiler wouldn't let you actually run the program. You might also ask yourself at this point, okay, why is Java being cited as an example and not C?

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

Of course, C also has this static and dynamic check, right? So you write some C program. If you have wrong type of arguments sent over, C will complain. But C is sort of relaxed, quite relaxed, right? If you have a string and you can always cast it to some integer, right? And C will say, okay, if that's what you want, I will just allow that to happen. This leads to memory errors like crashes, sickfalls, whatnot.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

If you've written any sort of linked list programming, I'm sure you would have faced this problem where when you run the program, C crashes, right? Of course, languages like Python and JavaScript don't crash with a memory error, but they throw exceptions at runtime. The advantage of the static versus dynamic distinction, which is very strongly done in OCaml and other functional programming languages like Haskell

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

and also languages like Java, Scala, and say Rust even. So there, the idea is that you want to catch many of the errors that you could potentially catch during compile time and only let a few of the errors to be done at runtime, right? Again, I'm sort of quantificating here, but sort of bear with me.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

The idea is that the distinction where you draw the line between static and dynamic is quite a spectrum. For example, in JavaScript and Python, there is no static, but C does some of these things statically, but a lot of things are dynamic. In OCaml, you sort of take more things to be done statically, catch static errors and fewer things to be dynamic.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

So it's like a complete spectrum. So you cannot sort of say one language is completely statically typed and another one is completely dynamically typed. You can sort of put them in boxes, but this distinction of where you catch errors is quite flexible and different languages do it at different times. We will come back to this idea over and over again. Don't worry if this isn't quite clear right now, but here is an example that we saw yesterday

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

so in OCaml, one of this is a static error. The other one is a dynamic error. The first one, we are saying whether 23 the integer is equal to 45 the floating point number. Here OCaml will just not let you run this program, right? So it will just complain saying I am expecting an integer and you're giving me a floating point number. So this is a static error and this is a dynamic check that phase. It's not an error here. We are

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

saying whether 23 is equal to 45 both sides are integers. So OCaml is going to say okay, this is fine, but when you they are not equal right it evaluates the expression and it evaluates it all the way to a value. The expression has type bool. The value also has type bool. The value is a false value. Okay, so moving on. So we have seen simple expressions. Now let's look at

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

if expressions here. So it's very simple, but the key takeaways here is in C and Java if is a statement right here if is an expression. What do I mean by that? Just go back to the definition and expression has some syntax right and it also has static and dynamic semantics. The idea is that

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

you will take an expression. It will have some type right that's the static semantics and we can evaluate that expression down to a value. It's not like a structured block of code where you sort of do multiple operations together right. So we are sort of we have a different way of looking at this here. So the static semantics so the expression itself you write it as if some expression E1 then expression E2 else expression E3. The whole thing is also an expression right.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So each one is an expression. The whole thing is also an expression. Static semantics places some rules on what is a valid expression. The checks are this so static semantics looks at E1 and says whether E1 has type Boolean right even has to evaluate to a type Boolean and then the next check it does is it checks the type of E2

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

right and the type of E3. If both of them evaluate to some type T2. We don't care what this type is. If them both of them evaluate to the type T2 then the whole expression has type T2 right. So it's the important bit is this right. So because we are going to assign a single type to the entire if expression if say the true branch returns an integer it is expected that the false branch

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

also return an integer right and only then can you say this whole if expression evaluates to some integer and the dynamic semantics is obvious here right. So if E1 evaluates to true then you do E2 else you do E3 okay. So this should be fairly dynamic semantics should be fairly simple. So here is an example right. So I have if 32 equals 31 then hello else world of course this is false.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

So you are going to get world here right and the second example that I have is if true then 13 else 13.4 let's apply a static semantics rule right. Oh this is a Boolean that's fine true is a Boolean. It looks at the type of the true branch that's an integer right 13 is an integer

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

and the else is a floating point number. So our rule here says that both E2 and E3 have to be the same type right here they are not the same type. So 13 is an integer 13.4 is a floating point number. So OCaml says I cannot give this expression a type if it is true then you will get an integer if it is false then you'll get a floating point as a expression type. This is not

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

something that OCaml allows you to do. So if you run this expression you will get an error it says the type that was expected here this expression has type float but an expression was expected of type integer right. It looked at the true branch and it said okay if this is a two branch I'm going to expect the same type for the false branch if it it is not because it is obviously a floating point number. So OCaml is complaining and of course if you change it to an integer this would work

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

right. So this is quite different from what you might have seen in say C or Java where the if is a statement. So this is sort of how OCaml encodes if expressions. So we can sort of encode this more formally right we will look at this formal encoding over and over

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

again. So in this course we are going to look at precise notion of defining the meaning of pieces of programs right expressions and statements and so on. So the way we do that is through what is known as inference rules right. An inference rule is just a easy way of writing down what you want convey which is it has this long bar right and above the bar there could be multiple premises.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

So you can say if premise one holds and premise two holds and premise three holds up to premise n then you can conclude that the conclusion holds right. So this is this is a standard way of writing semantics these are known as inference rules. We will look at more inference rules as we go on. So we can define the static semantics of if expression using an inference rule. So we are

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

all we are doing is we are taking the English language statement here right and we are sort of writing it down in a more succinct fashion. So what we are doing is we are saying if e1 has type bool and e2 has type t e3 has some type t then this whole expression if e1 then e2 lz3 has type t right. This is of course omitting a few details but that's not important. So you can sort

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

of read this you can sort of read this inference rule exactly as you would read this English language statement okay. Okay so that's the that's sort of a more formal definition of the static semantics of if. You can also use the same technique to describe the dynamic semantics of if. So what is the dynamic semantics? It's very simple right if e1 evaluates to true then we are going

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

to do e2 otherwise we are going to do e3. So the rule here we have two rules here the first thing to notice is we have two rules one for true and one for false right. The true rule says that if e1 evaluates to true right then if e2 evaluates to b then the whole expression evaluates to b right. This is this is very natural this is what we are sort of the intuitive semantics is that but we

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

are also making it more concrete and similarly for the false case right if you say oh if e1 evaluates to false then you don't care about e2 at all we are not going to evaluate it. If e3 evaluates to b then this whole expression also evaluates to b. So you sort of read this arrow as evaluating to okay so again I'm sort of throwing in certain ideas here but we'll come back to inference rules and

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

so on a little bit more. So the key takeaway in this slide is the inference rules and the split between static and dynamic semantics gives us a vocabulary to talk precisely about the meaning of certain expressions in a language right. We might not have dealt with this level of precision in other languages we sort of look at examples and then say oh this is how it

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

works but here in languages like OCaml and even other languages to some extent we can sort of define precisely what the meaning of a particular expression or a complete program is right and this is quite useful because you can completely understand what goes on not in terms of just examples right oh these examples work but there is also this corner case. No there is no corner case this is precisely how the if expression works right. So that's the benefit of reasoning

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

formally about these things so that you get a deeper understanding of how expressions work. So that was if expression and OCaml also has the ability to define let expressions. These are sort of you can sort of think about this is a new way to define a way to define variables.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

So a let expression as these parts right you typically write let some variable x equals some expression e1 in expression e2. So the way you sort of look at the components is x is the identifier right and e1 is the binding expression and e2 is the body of the expression and the whole thing itself is an expression. So what we are saying is the intuitive understanding

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

is evaluate e1 right just take e1 which could be a complex expression evaluate e1 store the result in x right and e2 can refer to x and wherever you see x in e2 just substitute the value of x there so this is the intuitive meaning here is even it gets easier if you look at examples.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

So here is a simple let expression and all it's doing is saying let x equals 5 I am just going to say x is 5 in x plus 5 and it says that wherever you find x here you substitute the value of evaluating the expression e1 which is just 5 a value is an expression so you take 5 you substitute here and this whole expression has the value value 5 plus 5. So if you evaluate it

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

you get 10 right let is also an expression so the static semantics is that the whole thing evaluates to an integer and the dynamic semantics the actual evaluation uses the value 10 right. So yeah this should be you'll sort of use this very extensively you'll start using this extensively but the essence of this is very simple so all you have is a binding a binder right a variable

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

some expression on the right hand side of equality right which you evaluate to take that value you say x is now that value in the other expression which can refer to x right so all that is happening is that intuitive understanding of course you can sort of keep extending this so because we

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

have written let expression in this way where we have e2 is also an expression and this whole thing is also an expression right so e2 could also involve a let and you can keep doing this recursively so let x equals e1 in let y equals e2 in let z equals e3 and so on until in something else so this is precisely what is happening here just look at the intuitive meaning

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

right we are saying let x equals 5 so let let's say x is 5 let y equals 10 let's say y is 10 and this whole expression is x plus y so all we are saying is take 5 take 10 and then add them together here we are just giving names for the result of evaluating these expressions these are just plain values here so you sort of see what it will get right again the point I'm stressing here is it's not a special kind of construct right this is just applying the same

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

rule again so we have the whole thing as an expression it has a static semantics integer and the dynamic semantics is 3 so one thing to note is x is not a variable here right so in the sense of what what the term variable means when I say variable right variable is something

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

that varies but here these these are sort of you sort of look at these as just constant constant values so what do I mean by that so I can the intuitive meaning is that these variables cannot be changed right but here is a strange example let's just keep that in the back of the mind here is a strange example I say

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

let x equals 5 in let x equals 10 in x so if you evaluate this you get a warning let's ignore the warning for the moment right and it says that the expression evaluates to 10 so the idea here is that we have one variable sorry we have one binder here which binds x equals 5

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

in this expression this whole expression here and what that expression does is it again binds x it says x is now 10 I don't care what the previous x was x is just now 10 this is not changing the variable value it's just defining a new x right it's just saying oh here is a new x now in this body expression where the x is now going to be done so this this particular expression is not even

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

going to be used right so we have these two are two different x's and that is why the compiler is complaining saying oh you are using the second x this x is being used here right which is the reason why we get the result 10 but the original x which is x equals 5 is not being used and the compiler is handily pointing out that oh here is a warning you are not using this x right so

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

so yeah so the main idea that I want you to take away is we are not changing the value of x we are just defining a new x right so we are just naming a new thing and the name happens to clash with the previous one we just go with the second one and this nicely sort of gives you this idea of scopes

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

and shadowing so OCaml is a lexically scoped language so wherever you see expressions we take the scope to be just the scope where as how the program is defined right program syntax is defined so when OCaml looks at x equals 5 and let x equals 10 and x it is really sort of parsing this example as let x equals 5 in some expression

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

that expression happens to be let x equals 10 and x so it just happens so that the body expression this expression happens to use the same variable name so the previous one does not get used used so the the important takeaway is x is not mutated here right we are not changing x this is not like we declare a int x equals 5 and then we said x equals 10 we are not doing that we are actually

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

doing int x equals 5 and then we are declaring again int x equals 10 so there are actually two different x's and two different scopes right what is happening is the inner x this inner x is shadowing the outer x you will not see when you define a binder with the same name as the previous one it just shadows the previous one it is not saying wherever you refer to x in this body

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

it is going to refer to this x and you cannot refer to the outer x right so that's the meaning of what is happening here so what do I mean by shadowing what is what is happening so the the notion of shadowing is really what it means right when you have some shadow if you sort of take away the object that

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

is creating the shadow the original object is still there right and that is what is happening here so it does not mean that the original object is gone right it's just shadowed for that particular scope if you remove if you remove the thing that is that it is shadowing it comes back in scope so here is an example so we say that x equals 5 so x is 5 and then we define y right we we sort of

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

say we are going to define y in and the way we define y is we are saying that x equals 10 in x this is quite silly you might even ask why are you doing this we can just do 10 directly here but there is a reason for doing this right when I say that x equals 10 here so this x shadows the previous one okay so in this scope this expression the body of just this

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

expression the x is going to refer to the x here which is shadowing the previous x right so the value of x here would be 10 because this inner definition shadows the outer definition okay but now when this expression is complete right and but now but now when I refer to x here

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

this is a lexically scoped expression right this is the whole thing is an expression right and this definition this binding here is only visible within this expression so when I refer to x here it is going to refer to the original x and this is an artificial example we are not going to sort of

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

write real programs like this just bear with me right so we are sort of going through this in painful details just so that I get the point across so you will find the strange behavior when you write real programs I'm just going to try to preempt that by giving you some idea so this whole expression within its body defines an x right which shadows the outer definition in this scope right this scope where you define refer to x is being referring to this x

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

but the scope is this definition is outer scope here in this x right it's sort of sitting within the body of this definition here this expression here so when you refer to this x it's going to refer to the closest in that scope the closest reference in the scope is the original

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

x right so y happens to be 10 right this will be 10 and this x happens to be the one that is defined in the outer scope in the closest scope for this expression which is x equals 5 so the whole expression evaluates to sorry the whole expression evaluates to 15 right so if you can understand what is going on in this particular

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

slide you'll be you'll save a lot of pain right so is the indentation important no the indentation is not important so I can write it as so there was a question on question on the chat if you have questions I can see the chat window so just post something I might not get to everything but I can I can if I see it within time I'll try to answer

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

it though the indentation is not important so it's not like python yeah so you can write very bad syntax like this right it's sort of unparsable can you please clarify about extra space what is the extra space are you referring to the indentation so you had a question

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

so we just happened to write it like this because it's convenient right so I can like I can write y equals yeah that that's also not important you can play around with it right so this is also not important and the right hand side of the variable declaration yeah so you can do that

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

let's say y equals x plus y yeah you can do that right so let me add a new expression here just so that x plus y yeah you can do this sorry I need a in yeah so you can do that let x equals x plus y is also good question so you can do this right so

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

no this Krishna Gopal Sharma has a very nice question so the question is what happens when I define x equals x plus y that's a really good question so so this is this is the question right it's a good question so essentially this is what I

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

yeah I should have included this example thanks for asking this so here we defined x equals y right and when we are writing x x plus 5 here this x is going to refer to its outer scope right the x here is going to refer to this x this x is not defined yet right so the x here is not going

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

to refer to this x it's just going to refer to the x here yeah so that's going to just lie let me just so that I'll show that I'm not so I can write x plus 5 thanks so what will be the result of this it'll be 10 right because what is happening here we define x plus 5 this is going to be just an expression

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

right and that expression is going to refer to the variables in its scope and the variable in the it refers to x and x is previously defined x equals 5 right so this whole thing becomes 5 plus 5 essentially right and we are defining x again so that x becomes 10 and this x is going to

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

refer to the innermost one right so the closest one is this x which happens to be 10 okay so really good question any other questions you can quickly type or just shout out it's I mean I like a lot of interaction I don't mind not covering the material but I think without interaction it just seems like I'm talking to a wall right so really glad

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

that you're asking questions okay yeah so just play around with this right so one thing I would strongly recommend is I like jupyter notebooks because I can actually type things out and see what the result would be so I encourage doing all of this yourself right if you have a question just start writing that it's and then finding out answers yourself so this again I said we won't

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

complain about syntax but the syntax might be a bit weird when you start looking at the syntax initially but you'll get used to it eventually so all you need to think about is let has a variable binder right some expression here it could be as complicated as expression is allowed in some other expression here right and this pattern is really the pattern the same pattern here right

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

so you can sort of interpret this as this one where you say let x equals 5 in this whole thing is an expression again okay good question solar off so I think I'll put it back to what it was yeah okay so okay so that was net expressions you can also have let at the top level so

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

what does that mean so far we've seen let with let binder equals expression one in expression two you don't need this in all the time but this form is only allowed at the top level of the program text so so unlike c right where every piece of code that you execute needs to be within a function or even java right um ocamel in that sense is like python where you can just write pieces of

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

code and it will start executing all of that you don't need a main function we won't have a main function so essentially the ocamel compiler just goes through the definitions that are defined in the program and then evaluates each one in the order in which they appear just like just like python right and the way to define expressions at the top level is you can do let x equals e

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

right and that sort of implicitly says oh this let binding holds for the entire rest of the program text right so if you have a file where you've defined that it sort of says I'm going to define x and this is going to be the value of x in the rest of the program in that particular file okay so why is this useful here is an example observe that I'm not using in so that's

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

the first thing that I want to take away I'm defining two strings here a equals hello and b equals world okay so of course it says a equals string and hello b equals the string and world and observe that I am defining another top level let definition where I say c equals a this symbol carat symbol b this symbol is what we use for string concatenation in ocamel okay so this

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

is how you take two strings and put them together so when you do this we define a new string which happens to be a hello world so you can you can of course make it sensible something like this right so these are not I'm not defining each one as let in so I've defined a I've defined b I've defined c I can refer to a b and c in the rest of the program right so these are these are known as

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

definitions yeah okay so and let's move on so definitions are top level let equals x equals e without this in right so whenever you do that you are sort of defining you're essentially giving a name to a value so right hand side evaluates to some value right we know that expressions

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

the dynamics matrixes you sort of reduce them and if they reduce to a value then that value will be bound to x right and the definitions just give name to a value definitions are not expressions are vice versa right definitions are a different class of things so you have expressions we saw values definitions sort of sit outside here but the definitions syntactically contain expressions right so this this thing is an expression here this whole thing is a definition

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

e is an expression okay so that's definitions for you we can also try to give precise definition of the semantics of the lit expression right we'll just do that here so the syntax for let is what we saw earlier right we said let x equals e 1 and e 2 we have to give when we define semantics we have to define both static

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

semantics and dynamic semantics what does the compiler see and expect and what is the result of running that expression right so the static semantics is this right so the way to read this if e 1 has some type t 1 let's say e 1 has some type t 1 we are going to evaluate e 1 to get a value of type t 1 and we are saying x is now referring to that value right so it must be the

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

case that x is also of type the same type right assume that if e 1 is of type t 1 and x is of type t 1 if e 2 is of type t 2 right with the assumption that x is t 1 in that body then this whole expression right let x equals e 1 and e 2 this whole expression has type t 2 right so that's that's the static semantics and we are sort of omitting some detail but that's not

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

important so if you sort of get the high level idea of what is happening here then you'll be fine then the dynamic semantics is going to say precisely what we had seen in the examples right take e 1 first and then evaluate it you will evaluate it to some value right let's call it b 1 and in e 2 wherever you find the variable reference to x substitute the value v 1 for it

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

right if i say e 2 is just x plus 1 and v 1 happens to be 0 then that becomes 0 plus 1 right and then evaluate the substituted expression to some v 2 right and that's the result of this whole net expression right so if you take this net expression if e 1 evaluates to v 1 and substituting v 1 for x in e 2 evaluates to v 2 then this whole

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

expression evaluates to v 2 okay so this is again i'm sort of glossing over some detail which will make it concrete later but this is just to give you a feeling for how we will tend to define the semantics of expressions in a formal way in a very precise way

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

right so once we this is not yet fully formal but once we formalize this by which we completely write the meaning of this net expression the compiler will follow it right if you understand that one rule you can know how the net expression works in every instance right there is no deviation there is no corner case but here i'm not doing that it's still not there yet but we will refine it later okay so yeah this is an exercise for you you can play around with it and find it out

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

so in no camel we cannot use plus for floating point addition right if i use plus it complains right but if i use plus dot which is very strange right if i use plus dot it works exists it gives you the right answer just using plus doesn't work so i want you to find out why using plus if you do this you will get an error right i'll just leave it at that i'm not going to

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

run that code i just want you to run that code and see what happens right if you just run plus it will complain and instead we have to use plus dot and that works just just find out why that is the case right you can just play around with it the answer is going to be very simple um but play around with it and find it out and once you find it out i want you to write down the

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

static semantics for plus and plus dot just the by static semantics i mean something like this right so um yeah you'll you'll you'll sort of see what i mean again these exercises i'm not going to evaluate you don't have to send it to me this is just for your understanding right but if i if i tell you there is some exercise just try to think about it right after the class

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

because i think these are like leading questions and these are the sort of questions i might ask in the final exam right so let's just put it that way sir do lit expressions always return values yes they always return value right so there is a question on the chat i'm looking at the chat so yeah this this whole thing is just evaluating to 15 right there is no return

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

yeah so there is no notion of return in um in expressions but you can sort of think about the whole expression i'm reading in the chat evaluates to a value and in this case this particular example which is let x equals 5 and let x equals 10 and x plus y evaluates to um evaluates to 15 oh does okay this is a good

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

question so does y equals 10 and x plus y return something like x plus 10 no so here is uh um okay here is an example so the question is that y equals 10 in x plus y return something like x plus 10 uh let me change the variable name just because uh my scopes will not um i might have

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

an x in scope so what is going to happen here right so um when you look at uh certain expressions and you refer to um variables those variables have to be in scope right if the variables are not in scope then the compiler cannot tell you anything about what that expression will be so you just get this unbound value x1

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

okay so that's the answer good question um the reason is that you can sort of uh you can sort of look at a deeper reason for this right the deeper reason is that uh i don't know what x1 is i can't give you the static semantics of this right x1 could be an integer and x1 could be a banana i can't add banana plus an integer so the compiler just says i don't know what i can do

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

with this so i'll just say the values are known okay good question um okay so that is what i have for expressions i'll delete this thing okay so let's start the next lecture and uh i think uh in the remaining few minutes i'll just maybe give a brief introduction of what uh i'm going to deal with

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

so the next thing we are going to see is functions okay so um the thing we said we are doing is functional programming um so obviously there has to be some functions in it so here is functions for you um the way i deal with functions will be sort of from ground up right so again we are the

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

we are studying um paradigms here we are not just looking at how to program so it will take a strange way of dealing with functions but this is sort of taking some abstractions and then taking it apart right taking it down to the essence and looking at what they actually mean so we will sort of go through that step by step so previously we saw syntax semantics a bunch of expressions if and

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

and definitions today we will look at functions so okml has support for the anonymous functions anonymous function expressions right um for people who have sort of programmed in python and say the recent java versions anonymous functions the hot term today is lambdas right

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

so when you say lambda you're sort of defining a function but you're not giving it a name you're just defining a function uh without uh giving it a name so what does it mean without giving it a name you can sort of uh define the arguments to the function and the body of the function right but you don't name it and uh this uh this predates all of this um fascination new form fascination with lambdas in recent languages right um all of the modern

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

languages have lambdas so python has lambda jarstilt has lambdas um java 8 has lambda c plus plus has lambdas right so these are sort of becoming a essential toolkit in all of these languages and lambdas sort of form the basis of functional programming languages right so um we don't call it lambdas because lambdas is just a term we just call them by what they are

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

they're just anonymous functions anonymous because we don't give it a name so the syntax is this right so you sort of write fun binders several binders so you can have x1 x2 x3 x4 x5 to xn right they could also be other binder names and then we have this minus um greater than so which is you interpret that as a narrow and then some expression

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

right and uh and that is the syntax and uh when you define an anonymous function anonymous function is just a value there is no further combination to do you don't start evaluating anonymous function because you don't have the arguments to evaluate it right in particular we don't we can't evaluate e until all of these arguments are applied this is just like uh what you would have in c right so you define a function that that's just a thing in order to start evaluating the body of the function you need to supply the arguments

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

and similarly uh that's a fact here except that uh unlike c where you don't um the typical c functions are definitions right but anonymous function here is just a value so it's just a value uh with no further computation so wherever you can write values you can write anonymous functions um so by extending the definition values are expressions so wherever

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

you find the expressions you can write uh uh anonymous functions okay so here is an example so here is an anonymous function that takes one argument x and then in the body does x plus 1 right so um and uh all it's doing is is takes a value and then adds one to it right and uh

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

the static semantics the type of this function is being told as int arrow int right what does that mean this arrow in the type signifies it's a function type okay and the function type takes one argument integer and then returns one result which is also an integer right so obviously this expects one argument which is an integer you can give it any integer and then it returns x plus 1 and that expression is also going to have type integer right so that's what we defined here

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

and uh yeah so this is what i just mentioned the function type is int arrow int takes one integer yeah so someone is uh uh actually seeing ahead so there is a comment from shartak kapur who says if you change it uh yeah so you have to

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

so the question was if i just changed the plus to plus dot will the type be float it's a really good question it won't be because it will be a type error because what is happening here is this one is an integer right that has to be a floating point number plus dot is a function that takes a floating point and then adds it with another floating point one is not a floating point number it's an integer right so that's why the error

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

message says this expression has type integer right this expression one but an expression was type expected of type float did you mean one dot okay man has this weird notation right you can write one point oh but you can also write one dot this will be the same thing so yes or no um yes uh the comment uh yes the comment is that if you change it to plus dot the type will be expected

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

to be floating point number and no you have to change the one as well so so that it becomes float error float this is type inference at work right so it's sort of uh we haven't specified what the type of uh this function should be just by changing the body we are expecting a different type and the same for doing this right so i am using string concatenation here and a string

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

so okml is automatically saying this is a stringer of string function so this becomes quite handy you don't have to um yeah you don't have to specify that i'll stop here i think i'm already really good questions i would like the class to be like this right so please do ask questions otherwise you won't challenge me put me in a spot right so only then i will sort of give my best if you just don't uh i'll just like read the slides and walk away so ask questions really

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

good questions today okay so i'll talk to you on friday on friday what we'll do is i'll sort of run through my docker setup and basic git commands right so that you can play around with the jupyter notebooks um i will also i have uploaded for those who have windows home or windows student right docker for windows does not work on windows student it does work on windows home but anyway i've made a ubuntu virtual box image which has all the um setup already done

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

if you if you don't if you can't install docker then i recommend doing that it has docker installed and um i need to code so it's already on the course web page so if you go down to resources yeah so you will see that just point to that this is

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

so if you go to resources you go all the way down um yeah there is a virtual box this image um with some instructions as well so you can sort of uh it lets you get started it'll cover some of this i mean it's it's quite large but anyway uh you can slowly download it and play around with it we'll cover some of this in the next class and uh yeah so try to have questions ready right so

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3193.0s_

give give this docker installation and getting the notebook setup uh tomorrow and come with questions on Friday and then we'll we'll see those questions okay thanks very much talk to you on Friday

---
