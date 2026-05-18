# 09-cs3100-pop-lec-09-exceptions

**CS3100 POP - Lec 09 - Exceptions**  
id: `Z-K29Qln4IY`  
duration: 3224s  

![slides/interval_0001.png](slides/interval_0001.png)
_t = 0.0s -- 30.0s_

Before we begin, what I've done is I've released both assignment 0 and assignment 1. The point of assignment 0 is just to make sure that all of you have your notebook set up. The assignment 0 is going to be considered to be part of this 1% class participation grade. I'm not going to evaluate it, I'm just going to see whether you've submitted something.

---

![slides/interval_0002.png](slides/interval_0002.png)
_t = 30.0s -- 60.0s_

It's literally one line of code. The code was actually discussed in the lecture, so you just need to copy paste it and submit it. It's only there so that it will give you an excuse to set up your notebooks if you haven't done it yet. That is due this Friday night at 11.59. I've also released assignment 1.

---

![slides/interval_0003.png](slides/interval_0003.png)
_t = 60.0s -- 90.0s_

Assignment 1 will be evaluated and it's one of those seven assignments that will be released as part of this course. It tests your knowledge on basic data types and pattern matching and list manipulation and so on. In particular, I haven't covered the material for the assignment 1, which will be covered hopefully in this class in the next one. I will finish it.

---

![slides/interval_0004.png](slides/interval_0004.png)
_t = 90.0s -- 120.0s_

That is due on the 31st, so you have a bit of time for completing that. Having done a similar assignment last year, it should take you half a day. If you have been following the lectures, you sit on your computer, it should not take you more than a few hours. But I mean it varies. Don't worry if it takes a long time. If you have questions, do ask on the Slack channel.

---

![slides/interval_0005.png](slides/interval_0005.png)
_t = 120.0s -- 150.0s_

I will be there. I'll be happy to answer questions. If you don't understand any of the concepts, do ping me. I'm happy to answer questions. There are a few challenging problems there, but most of the problems are going to be very straightforward. It shouldn't take you a long time. But do start early. There will be some concepts that you think you might understand.

---

![slides/interval_0006.png](slides/interval_0006.png)
_t = 150.0s -- 180.0s_

But once you start programming, you need to flex your mind a little bit. If you start it early, have a look at the problem and then come back, it will be easier. Rather than starting, say, one hour before the deadline and then trying to finish. Both of those assignments have been released as part of the course repository. So if you go to your clone of the repository, Git pull, you should see all of the assignments there. The submission instructions is also included there. Follow the submission instructions.

---

![slides/interval_0007.png](slides/interval_0007.png)
_t = 180.0s -- 210.0s_

All you need to do is to rename the file to your roll number dot ipynb and then submit it through modal. Okay. I think that is that is for the assignment. And okay, so let's let's let's continue from where we left off. So we were looking at exceptions. Right. And you had mentioned that you had seen exceptions in C++ earlier in your course.

---

![slides/interval_0008.png](slides/interval_0008.png)
_t = 210.0s -- 240.0s_

Exceptions in OCaml are similar in terms of runtime semantics. The static semantics is a little bit different. As we saw, they are mostly variants in OCaml. Right. They are mostly just variants. And here we are declaring a new exception called my exception, which is parameterized with the string. You can think of this as the exception constructor.  When you use my exception, it's just a constructor which takes a string and it produces a new exception. Right.

---

![slides/interval_0009.png](slides/interval_0009.png)
_t = 240.0s -- 270.0s_

And these exception values are just usual values. And what do we know about values? Values are sort of special expressions that have been fully evaluated. There is no. So these are these are so C doesn't have exceptions. C++ has exceptions in OCaml. So we will go through some examples. I'm not going to just skip over the material. I just wanted to get an idea of whether you've seen exceptions previously.

---

![slides/interval_0010.png](slides/interval_0010.png)
_t = 270.0s -- 300.0s_

I will cover the details. So what are we doing here? We are just declaring exceptions. We are just saying exception is a value.  So when I create an exception, all I'm creating is just another value. And what is special about this value? This value is of type exception. That is the only thing that is of distinction here. Right. When compared to regular data types, regular data types have particular type which you've defined. All the exceptions are of type exception.

---

![slides/interval_0011.png](slides/interval_0011.png)
_t = 300.0s -- 330.0s_

EXN type. There is nothing different until this point. And basically the EXN type is an inbuilt type in OCaml. So you can keep adding exceptions. All of the exceptions are going to be of type EXN. Okay. So far we've just created a value whose type is an exception. Right.

---

![slides/interval_0012.png](slides/interval_0012.png)
_t = 330.0s -- 360.0s_

And what can you do with this exception? See the basic reason why you want exceptions in code is as the name suggests. Right. So it is meant to signify exceptional conditions. Let's say you have a function which accepts values from 0 to 100. And then you get a value which is minus 1. So this is an exceptional condition which you want to signify to the client of the library. So whoever is calling that function.

---

![slides/interval_0013.png](slides/interval_0013.png)
_t = 360.0s -- 390.0s_

In C what you will do is you will, we don't have exceptions in C just to, because Naaman had asked, I don't remember exceptions in C. We don't have exceptions in C. In C if you were to do that thing, you have to sort of do it in terms of the return value. Right. You will, you will return minus 1 or some error condition. That's all you can do in C plus plus exceptions. Let you a different return path essentially. So they say, oh, raise this exception.

---

![slides/interval_0014.png](slides/interval_0014.png)
_t = 390.0s -- 420.0s_

So exception will bubble up in your program and you have to handle the exception. We will see some of that. So there are two, two aspects to using exceptions. Right. So we saw the static semantics, the dynamic semantics is there are two operation. You can raise an exception in which case it simply throws the exception, which you built up a program stack. Right. It sort of keeps on minding the program stack until you hit a handler. Let's just look at race here. So there is no handler here.

---

![slides/interval_0015.png](slides/interval_0015.png)
_t = 420.0s -- 450.0s_

So when I just say, raise this exception that I just created, I created the exception here. Right. My exception. Hello. When I raise this exception, I just get a top level message that says that, oh, some something bad happened. Right. Exceptions are meant to signify bad cases. Something bad happened. The exception is my exception. Hello. Right. And where was it called from? It was called from top loop top level.

---

![slides/interval_0016.png](slides/interval_0016.png)
_t = 450.0s -- 480.0s_

This is not very significant here. But essentially, when you write OCaml programs, you can sort of know where the exception was originally raised from. So what is the point of this? If a function throws an exception, right, you can know which line in the source code the exception came from. And that's the idea there. We are just raising the exception here. This sort of terminates the execution of the program.

---

![slides/interval_0017.png](slides/interval_0017.png)
_t = 480.0s -- 510.0s_

Obviously, this is not the only thing that you want to do. It is not always good to say, oh, if you send a value which is out of bounds of what the function will accept, I don't want to terminate the program. I just want to give a error path in your function. And the way to sort of do something more interesting is handling the exception.

---

![slides/interval_0018.png](slides/interval_0018.png)
_t = 510.0s -- 540.0s_

And the exception is very similar to pattern matching. So what is happening here is I'm using the syntax for handling exceptions. Recall that the pattern matching syntax is match with. Here I'm using private. And within this, it could be arbitrary expressions. I'm just using directly this raise expression here, raise this exception.

---

![slides/interval_0019.png](slides/interval_0019.png)
_t = 540.0s -- 570.0s_

And similar to pattern matching, right, what you can do here is you can pattern match on the exception because the exception has a constructor. My exception, I pattern match on my exception. And H is bound to whatever the value that is carried by the exception. Because we know that my exception carries a value of string type, I'm just printing the value here.

---

![slides/interval_0020.png](slides/interval_0020.png)
_t = 570.0s -- 600.0s_

So you can sort of read this similar to I'm writing it in a different way, but you can sort of read this in similar to how we've written pattern matches. Instead of match with, I'm using private. And all that is happening is if private handles exceptions, it catches the exceptions and then it rips it apart and sees what sort of exception it is using pattern matching. And once you match the pattern, you can print it. So the behavior of this particular expression, all of this is still expression, right?

---

![slides/interval_0021.png](slides/interval_0021.png)
_t = 600.0s -- 630.0s_

When you run this expression, we no longer get the top level error, right? Here we used to get the top level error, which said, oh, something bad happened. Here we are not getting the top level error. What is happening is this particular expression is just printing the string, right? H, which happens to be hello. And that's it. The exception is no longer. It's sort of eaten up by this handler, right? So you sort of handle the exception in some way.

---

![slides/interval_0022.png](slides/interval_0022.png)
_t = 630.0s -- 660.0s_

And then you continue. So this whole expression has type unit, right? Because this thing has unit, this whole expression has type unit. So what we've seen is how do you raise an exception, right? Raise an exception is using this raise primitive. And how do you handle exceptions? Handing exceptions is similar to this private pattern, right?

---

![slides/interval_0023.png](slides/interval_0023.png)
_t = 660.0s -- 690.0s_

And pattern matching is similar to what we saw in regular pattern matching. And the thing you can do is you can also make it more expressive, right? So after you handle the exception, it is not necessary that you just hide the exceptions. What you can do instead is I'm introducing two concepts here. I'll just explain the second concept and then come to the first concept.

---

![slides/interval_0024.png](slides/interval_0024.png)
_t = 690.0s -- 720.0s_

So this line is similar to this line, right? And just like pattern matching, I can pattern match. This pattern is going to match any exception. I'm just giving a variable. This variable matches with any exception. This is just standard pattern matching. And what I'm doing here is I'm handling the exception. I'm sort of saying, catch the exception. And I'm doing something here.

---

![slides/interval_0025.png](slides/interval_0025.png)
_t = 720.0s -- 750.0s_

Let's ignore this for now. And then I'm re-raising the exception. So I'm doing some logging or something. And I'm re-raising the exception so that the outer function call can handle it. So you have a stack, right? I'm simply handling the exception at some point. I'm logging something. And then I'm re-raising the exception so that it goes to the outer functions. And what am I actually doing in this particular line?

---

![slides/interval_0026.png](slides/interval_0026.png)
_t = 750.0s -- 780.0s_

So OCaml has this way of allowing you to print, convert the exception to a string. So it is in a module called print exec. So don't worry about the details now. So this function is a way to take any exception and then convert it to a string. And so the result of this is going to be a string. And I'm just printing that string.

---

![slides/interval_0027.png](slides/interval_0027.png)
_t = 780.0s -- 810.0s_

And the idea here is this will handle not just my exception exception, but arbitrary exception. Any exception will be caught by this handler, which will just print the exception to the screen and then re-raise the exception. So let's look at what will happen here. So if you run this program, so we get both of the behaviors, right? We get the exception printed because of this line. And we also have the exception handled at the top level.

---

![slides/interval_0028.png](slides/interval_0028.png)
_t = 810.0s -- 840.0s_

The top level is also complaining that this exception escaped all the way through. And this is similar to the previous one that we saw. This is similar to this one. And the reason is that we are handling the exception. We are handling the exception here. We are printing the exception. And we are re-raising it. So that's why we see both the log message and the exception handled at the top level.

---

![slides/interval_0029.png](slides/interval_0029.png)
_t = 840.0s -- 870.0s_

So try is basically evaluating this expression. And if this expression raises an exception, it is going to handle the exception. So I'm sort of making it very simple, but it could be more complicated. So it could be arbitrary function like this, which calls bar and say let bar equals.

---

![slides/interval_0030.png](slides/interval_0030.png)
_t = 870.0s -- 900.0s_

So this could be arbitrarily deep. Let me just just to show you, this could be. So whatever try does, what try does is this, right? Try takes the expression, that is between try and with, evaluates the expression. So what is going to happen? So I'm going to call foo 5, which is going to call bar of 6.

---

![slides/interval_0031.png](slides/interval_0031.png)
_t = 900.0s -- 930.0s_

What bar does is just raise the exception. And the semantics of try is, if an exception is thrown by this particular expression e, then it will pattern match with whatever exception that is thrown. So here, this is an arbitrary pattern match. I could make it more specific. I could just make it my exception.

---

![slides/interval_0032.png](slides/interval_0032.png)
_t = 930.0s -- 960.0s_

In which case it will only match with my exception, which will be the case here. I need, yeah, so I need to change this as well.

---

![slides/interval_0033.png](slides/interval_0033.png)
_t = 960.0s -- 990.0s_

RAC, oh, I don't have RAC anymore. OK, so here is a different function. The point is that try with is sort of evaluating whatever expression is given between try and with. And if it raises an exception, then we handle the exception with whatever pattern is given here. And this pattern could be arbitrary patterns. You can match on any exceptions. You can match on a subset of exceptions.

---

![slides/interval_0034.png](slides/interval_0034.png)
_t = 990.0s -- 1020.0s_

If you match, if you have 10 exceptions and you match on just one, if the exception raised is that particular exception, then the strivth will handle it. Otherwise, it will just let it go through. We will look at, does that, OK, which part is pattern matched with? Is this the expression? No, no, just the exception. Good question. So we are not pattern matching on foo 5. We are not pattern matching on the value written by foo. Right.

---

![slides/interval_0035.png](slides/interval_0035.png)
_t = 1020.0s -- 1050.0s_

Really nice question. OK, so let me try to do this. Let's say this also gets in and then I do n plus 1. And I will change this to e. And. So I put it back to what it was and then try to see.

---

![slides/interval_0036.png](slides/interval_0036.png)
_t = 1050.0s -- 1080.0s_

Right. So in this particular function, in this particular piece of code, no exception is raised.  So foo 5 is going to return an integer. So because integer is just a value, it's not an exception that is being raised. This pattern match will not be invoked at all. So if you run this, you just get the value. But let's say something different.

---

![slides/interval_0037.png](slides/interval_0037.png)
_t = 1080.0s -- 1110.0s_

So if if n is greater than 10, then raise my exception greater than 10. Else. And this formatted better. OK, so now this is fine.

---

![slides/interval_0038.png](slides/interval_0038.png)
_t = 1110.0s -- 1140.0s_

Right. But if I do say 10 here. This will raise an exception. Right. You see what is happening. So if I give one, then this will be foo of one. Which is the bar of two bar of two will be checking whether n is greater than 10. And it's not greater than 10. So it's just going to return n plus one, which is three that returns here that returns here. And the sole expression just returns three. Right.

---

![slides/interval_0039.png](slides/interval_0039.png)
_t = 1140.0s -- 1170.0s_

But if I give n to be 10, then foo of 10, which will be bar of 11 bar of 11, 11 is greater than 10. So we raise an exception in that case. Right. And the exception that is being raised is my exception with some message. The message happens to be greater than 10 here. And that because it is raising an exception, this driver is going to handle the exception here. And that is what we are printing here.

---

![slides/interval_0040.png](slides/interval_0040.png)
_t = 1170.0s -- 1200.0s_

So if you run this program, we get my exception greater than 10. Does that make sense, Shreesha? Okay. Okay. So let's move on. So, okay. So I've told you. I told you our own way of describing exceptions, right? Declaring exceptions.

---

![slides/interval_0041.png](slides/interval_0041.png)
_t = 1200.0s -- 1230.0s_

Let me make it bigger. An example is how we declared exceptions. Here. So I am these are user defined exceptions. You can define your own exceptions, but there are also built in exceptions. And these are some of the things that you've previously seen. Okay.  Assert one equals two. Whenever we write assert one equals two. What is happening internally is assert is not a magic thing. It's also just a regular function that happens to raise an exception.

---

![slides/interval_0042.png](slides/interval_0042.png)
_t = 1230.0s -- 1260.0s_

So when I said one equals two, I'm asking whether I'm asking the OCaml to accept. One is equal to two. It is, of course, not true. And hence, what I said is doing is it is simply checking whether this value, this expression value is to value, right? It is simply checking whether this value is true. If not, it is going to raise an assert failure exception.

---

![slides/interval_0043.png](slides/interval_0043.png)
_t = 1260.0s -- 1290.0s_

And that is all assert is doing. And in particular, because I know the exception name, right, I can handle assets. So what I'm doing is I am wrapping this with a driver and I'm handling assert. And I'm ignoring the argument. I don't I don't care about the argument for now. I'm just printing end line, so assert failure. So when you run this function, this whole expression returns unit, right?

---

![slides/interval_0044.png](slides/interval_0044.png)
_t = 1290.0s -- 1320.0s_

Because this thing returns unit and I just see the message. So in turn, assert is also just implemented simply as a function that raises an exception. For example, you could even. No. OK. We tried to do this differently.

---

![slides/interval_0045.png](slides/interval_0045.png)
_t = 1320.0s -- 1350.0s_

So I thought so you could write your own assert function assert prime, right? Some it's going to take some Boolean value. If B then unit else raise assert failure of assertion failure. It's doing a little bit more because it is also printing the line number at which something fails.

---

![slides/interval_0046.png](slides/interval_0046.png)
_t = 1350.0s -- 1380.0s_

But essentially assert implementation is doing something like this, right? It takes a Boolean value. If the Boolean value is true, then it does nothing. It returns unit. Otherwise, it raises the assertion failure exception. Right. So that's the semantics of assert. There is a little bit of magic going on, but really this is all it's doing.

---

![slides/interval_0047.png](slides/interval_0047.png)
_t = 1380.0s -- 1410.0s_

Yeah, it takes different arguments because it is also storing the line numbers. And just for now, I'm just going to. The idea is that assertion gives you the file name, the line number and the column number in the line.

---

![slides/interval_0048.png](slides/interval_0048.png)
_t = 1410.0s -- 1440.0s_

But I'm just making things up here. But I'm just I just want to show you that this is how assert is actually implemented internally, except that it knows how to get the file name, line number and column number. But that's not the important point here. OK, so that is so the high level takeaway is assert in turn generates assert failure exception. That's the high level takeaway here. And just to put it back and sometimes.

---

![slides/interval_0049.png](slides/interval_0049.png)
_t = 1440.0s -- 1470.0s_

What we do when we want to build large programs is that we will start writing just the function names. And then we will just describe the signature. You will be will just describe the API for that function. We won't actually implement the details of the function. What we will say is I want to start modeling this function before I even implement the details.

---

![slides/interval_0050.png](slides/interval_0050.png)
_t = 1470.0s -- 1500.0s_

I know this function will have some behavior, but I want to see how my program can use these functions. So, for example, in your in all of your assignments, I do this pattern where I will just describe the function name. I might write the types explicitly out. So I'm defining a Fibonacci function. And then I'm saying Fibonacci takes an end, which is an integer and returns an integer.

---

![slides/interval_0051.png](slides/interval_0051.png)
_t = 1500.0s -- 1530.0s_

But I don't want to implement the function now. So OCaml has this primitive called fail with. And typically what we do is fail. You will start with fail with not implemented. Right. The idea is that this function is defined now, except that if you actually call this function now, we will get an error saying, oh, failure not implemented. The benefit of doing this is twofold. Right.

---

![slides/interval_0052.png](slides/interval_0052.png)
_t = 1530.0s -- 1560.0s_

You can actually start prototyping your function API and start using that API to see whether the application that you want to build is doable with that API, assuming certain invariance about what it does and so on. But you don't want to fully implement all the functions and then see whether the API is useful. So this is a common pattern that we find. So you write the function name, you sort of leave your unimplemented parts to be just to fail with not implemented and you fill the details in later.

---

![slides/interval_0053.png](slides/interval_0053.png)
_t = 1560.0s -- 1590.0s_

And all that is happening here is fail with is raising an exception called failure. Right. And this is a very useful pattern because sometimes when you are working on really complex code, there might be several cases, right? Maybe you implement three of the seven cases and you want to test just those three cases for the other seven cases. You will just say failure not implemented, failure not implemented.

---

![slides/interval_0054.png](slides/interval_0054.png)
_t = 1590.0s -- 1620.0s_

And that way, at least you can start testing the function for those three cases and the rest of the cases you can do later. So this is a very handy pattern when you build larger programs and you will see this pattern used in the assignment. So all of your assignments will have the function name and I will write failure not implemented. What I want you to do in the assignment is delete this thing and start implementing the Fibonacci function, for example.

---

![slides/interval_0055.png](slides/interval_0055.png)
_t = 1620.0s -- 1650.0s_

Yeah. OK, so. OK, so just to show that failure is not implemented is also just an exception. You can, of course, handle it. So try with right. I'm calling Fibonacci of 10, which is going to raise the failure exception. So I'm handling the failure exception and I'm just printing not implemented. I'm writing it this way, but it doesn't matter, right? You can write it in any different way.

---

![slides/interval_0056.png](slides/interval_0056.png)
_t = 1650.0s -- 1680.0s_

White space doesn't matter. It's just a matter of organization. You can feel free to write it in any way. Don't worry about how to write the syntax and all of that in this course. We have automated tools in OCaml that can solve that problem. So don't worry about how to organize your code in a pretty way. So what is this underscore for? OK, so good question.

---

![slides/interval_0057.png](slides/interval_0057.png)
_t = 1680.0s -- 1710.0s_

So if I do this, right. Failure is a constructor that expects one argument and it is applied to zero argument here. Actually, there is one argument. I don't care about what the argument is. So I am sort of sort of read this as a pattern like this. Does that make sense? Thank you. Yeah, do it like this. No.

---

![slides/interval_0058.png](slides/interval_0058.png)
_t = 1710.0s -- 1740.0s_

OK, OK. Yeah, OK. So that is the first question. I think that answers the question. I think that but here I am actually I actually wanted to tell you something different. So observe that we did something similar here, right? I had an asset which raised an asset failure and then I implemented this asset failure. I just printed end line and this one worked right.

---

![slides/interval_0059.png](slides/interval_0059.png)
_t = 1740.0s -- 1770.0s_

This worked as I wanted, which is it printed this asset failure and return the unit value. But observe that when I do the same thing here. Right. I know that Fibonacci of 10 is going to raise the failure exception. I handle the failure exception. I print end line. And then if I run this OCaml actually complains. What is OCaml complaining?

---

![slides/interval_0060.png](slides/interval_0060.png)
_t = 1770.0s -- 1800.0s_

OCaml is complaining that this expression has type unit, but an expression was expected of type integer. You can sort of see what's going on. The question you have to ask is. Look at this entire expression. This entire expression. Right. What is the type of this expression?

---

![slides/interval_0061.png](slides/interval_0061.png)
_t = 1800.0s -- 1830.0s_

If you so how can we know the type of this expression? One way is to say it its type should be the same as whatever the return type of Fibonacci is. Right. Because in the regular case if Fibonacci of 10 does not throw an exception Fibonacci returns an integer. Right. So the entire expression should have type integer. But on the other hand if Fibonacci does throw an exception.

---

![slides/interval_0062.png](slides/interval_0062.png)
_t = 1830.0s -- 1860.0s_

Then the control is going to come here. It's going to pattern match on this failure. And I'm just going to print end line print print print end line not implemented. And the return value is a is a unit value.  Print end line always takes a string and just returns a unit. And the return value unit is not compatible with integer return value of Fibonacci. Right. So every expression in OCaml should have a unique type.

---

![slides/interval_0063.png](slides/interval_0063.png)
_t = 1860.0s -- 1890.0s_

Right. It has to have a single type. It cannot be the case that when the function does not raise an exception it is an integer. But when it does raise an exception it is a unit. That wouldn't make sense. Right. If I just write let V equals this whole thing. I cannot give a sensible type for V because I don't know whether it is a integer or a unit value.

---

![slides/interval_0064.png](slides/interval_0064.png)
_t = 1890.0s -- 1920.0s_

So the type checking rule for the exception handlers is this right. Each of those handler expressions should also match the type of whatever expression that is being handled. So whatever expression that is within Trivath. So in the case of Fibonacci we have explicitly said that is an integer type. Right.

---

![slides/interval_0065.png](slides/interval_0065.png)
_t = 1920.0s -- 1950.0s_

So if this is going to be an integer type it better be the case that when the exception was also raised it is an integer type. Right. And so here is one way of fixing the type. So the exception handler return value return sorry exception handler should return the same value as the computation being handled. What I mean by this this this pattern which is handling the exception should have the same type as the exception being handled.

---

![slides/interval_0066.png](slides/interval_0066.png)
_t = 1950.0s -- 1980.0s_

And because the exception the computation here the expression between Trivath is going to return an integer it better be the case that this whole expression return an integer. I'm just making it for whatever reason I'm just going to return minus one here so that I can pacify the type checker. But this is not a good pattern. Right. Because because you minus one does not have semantics there are better ways to organize this but this will make the error go away.

---

![slides/interval_0067.png](slides/interval_0067.png)
_t = 1980.0s -- 2010.0s_

OK. So now we see that it prints end line not implemented but also returns minus one. There are a few concepts going on here. I will pause for a minute so that you can ask questions. You want does it you understand what's going on here.

---

![slides/interval_0068.png](slides/interval_0068.png)
_t = 2010.0s -- 2040.0s_

If not you can ask questions and I can sort of try to clarify. Yeah so but previously we had an effects if then else. So let let me first answer the first question but previously we had an if then else expression on raising an exception handler. Another raising an integer. Good question. So let's go back to that.

---

![slides/interval_0069.png](slides/interval_0069.png)
_t = 2040.0s -- 2070.0s_

Let me change this. Yeah OK. So here. Yeah so. The difference is this good question. So what is the type of. What is the type of work. So you can always ask this idea of types. You can drill down and sort of look at the type of an individual expression and then slowly build it up.

---

![slides/interval_0070.png](slides/interval_0070.png)
_t = 2070.0s -- 2100.0s_

Let's just look at it this way right. We know how the type checking rule for if works for if both the else branch. Sorry the true branch and the false branch should have the same type.  So. And we know for a fact that because I'm doing n plus 1 here. This is an integer.

---

![slides/interval_0071.png](slides/interval_0071.png)
_t = 2100.0s -- 2130.0s_

So. If this program type checks which it does right OCaml is able to give the type of inter event for this. It must be the case that this expression. As type integer. And that is quite surprising. Why should raise exception. I said option have an integer type. It can because. It is not a regular expression.

---

![slides/interval_0072.png](slides/interval_0072.png)
_t = 2130.0s -- 2160.0s_

It is going to actually throw the exception out. So we are not going to. While my exception greater than 10 is of type ex in when you raise the exception. It gets a polymorphic type. So let me actually show you the type. It is clear. What is the type of race. So the type of race.

---

![slides/interval_0073.png](slides/interval_0073.png)
_t = 2160.0s -- 2190.0s_

Is it takes an exception right and raises it and raises it is sort of not within the usual realms of just returning a value reducing to a value right. So it gets a polymorphic type actually so it can unify with any type. And what is happening here is because this branch has type integer. This polymorphic type this alpha is being unified with the integer that and that is why we can give the type for bar as into it.

---

![slides/interval_0074.png](slides/interval_0074.png)
_t = 2190.0s -- 2220.0s_

So let me delete everything else. And you can see that it gets the type into it. Does that answer this question. The important bit is this right. So the very crucial bit is this race as a type which takes an exception right.

---

![slides/interval_0075.png](slides/interval_0075.png)
_t = 2220.0s -- 2250.0s_

It does take an exception because this is an exception type and then returns. Like the return type is a polymorphic type. Yeah that that's the reason why we can unify this alpha with an integer and then we can substitute integer for the alpha. OK so let me what integer does race return actually race does not return an integer. Good question.

---

![slides/interval_0076.png](slides/interval_0076.png)
_t = 2250.0s -- 2280.0s_

It does not return an integer because we never we never save the value right. It has to always be handled with a driver. We don't care about what integer it returns because it doesn't matter. So I can always say for example just to give you an example of why it doesn't matter. Right. If I say. If I write write something like this.

---

![slides/interval_0077.png](slides/interval_0077.png)
_t = 2280.0s -- 2310.0s_

Right. I'm saying sorry I should be it should be something like this. I'm saying oh race my exception. Hello. I'm going to take this thing and I'm going to say the value that is returned here is an integer but it doesn't return a value. That's the whole point. They sort of raises the exception which can only be handled by this handler. So I can give arbitrary type. It should just work because see this exception is handled at the top level but that is besides the point.

---

![slides/interval_0078.png](slides/interval_0078.png)
_t = 2310.0s -- 2340.0s_

I never bind the value of V. There is no integer because the control never comes to oh I finished evaluation I'm going to bind this value here. It simply raises all the way to the top level. I can give it arbitrary type right. I can give it string type that should work. I can give it float type that should also work because it does not matter. It's not it's not getting the value at that point. It is sort of like if you think about this as a stack of things it is just unbinding the stack.

---

![slides/interval_0079.png](slides/interval_0079.png)
_t = 2340.0s -- 2370.0s_

And then raising the exception all the way to the top level. And the only thing that can stop this unbinding is this exception handler. So it doesn't matter. Good question. OK so sir in a previous slide there was a function bar. OK I think it's the same question. OK good. So exception exceptions are kind of a little bit magic because they have semantics which can only be.

---

![slides/interval_0080.png](slides/interval_0080.png)
_t = 2370.0s -- 2400.0s_

Which can only be explained by the actual call stack. OK. Abhinav has a question. After the exception is handled will we have a value. So that's where the interesting thing comes right. So if I say something like this. Where will you handle the exception. That's the question. So if I say try raise e with.

---

![slides/interval_0081.png](slides/interval_0081.png)
_t = 2400.0s -- 2430.0s_

With my exception. And then I say unit. So will this work. This wouldn't work because what I'm saying is. So just look at the types right. So this expression has a polymorphic type. So it's a type alpha. Right. And and this is going to raise an exception.

---

![slides/interval_0082.png](slides/interval_0082.png)
_t = 2430.0s -- 2460.0s_

So this thing is going to handle the exception.  Exceptions handle that's fine. After I handle the exception I just return a unit value. So this return type of this expression is also going to be unit. So this whole thing is going to have type unit and that does not match with float. And that's why it wouldn't work if I run this. That is exactly what it's saying right. This expression has type unit but an expression was expected of type float.

---

![slides/interval_0083.png](slides/interval_0083.png)
_t = 2460.0s -- 2490.0s_

But if I change this to say 10.0. What. Let me change it to 10.5 or something. This should work. Why is it working. It's working because let me also remove this. This is not necessary. It is working because this whole thing right has. Is inferred to be floating point type but that is not actually used.

---

![slides/interval_0084.png](slides/interval_0084.png)
_t = 2490.0s -- 2520.0s_

What is happening is this raises an exception which is handled here. And that handler right this handler thing. This expression has type floating point. And hence the whole expression should have type floating point. And that is what we do here. If we say let's try to make it a little bit more complicated. So if I say.

---

![slides/interval_0085.png](slides/interval_0085.png)
_t = 2520.0s -- 2550.0s_

My exception and I also have assert failure underscore 10. This wouldn't work. Right. Because what I'm doing here is I'm handing more than one exception. This is an example where I'm handling two exceptions. If this expression raises my exception it will be handled or assert failure it will be handled.

---

![slides/interval_0086.png](slides/interval_0086.png)
_t = 2550.0s -- 2580.0s_

But the point is each of the expressions right should have the same type which should match the type of the expression being handled. And then the expression will be evaluated. Whatever expression is here that should have the same type as this expression and this expression. This has polymorphic type so that's fine. We will sort of leave it for now. We know this is a floating point number. So we will specialize this to say it has floating point. And then this is an integer.

---

![slides/interval_0087.png](slides/interval_0087.png)
_t = 2580.0s -- 2610.0s_

And the integer is not a floating point. So that's why it's saying expression has type integer but an expression was expected of type floating point. And if I change it to something else say 10.4 this should work. And it works because and the value is 10.5 because I raised my exception which is handled here this goes here. And if I change it to say assert failure. Yeah. Okay. So this requires two other arguments.

---

![slides/interval_0088.png](slides/interval_0088.png)
_t = 2610.0s -- 2640.0s_

This is 10.4 right because we raised assert failure here which got handled here and that returned 10.4. So this whole expression evaluates to 10.4. That's the answer to your question. Okay. So a lot to sort of think about.

---

![slides/interval_0089.png](slides/interval_0089.png)
_t = 2640.0s -- 2670.0s_

Exceptions are very powerful because they have this polymorphic type. So I'm sort of showing you several patterns here. Right. So I. Yeah. So I think you won't use exceptions in a deep fashion in your programming assignments but it's sort of useful to find useful to fit them in a framework of this values and types because everything in OCaml has to fit this framework of value and types.

---

![slides/interval_0090.png](slides/interval_0090.png)
_t = 2670.0s -- 2700.0s_

And exceptions have this interesting return type which is what makes them sort of suitable in places where it would look very strange but still everything fits within values and types. Okay. I don't know when much further than. Okay. So what else do I have. Okay. So here is some.

---

![slides/interval_0091.png](slides/interval_0091.png)
_t = 2700.0s -- 2730.0s_

A semi real example of how you can use exceptions. So what I'm doing here is I'm going to give you a list of shapes right which I've defined previously in the last lecture. Given a list of shapes return a point whose color is green otherwise raise no green point exception. So you're going to get a list of shapes. Right. And the shapes can be subtle rectangle or a point. And if there is a green point then we return the point otherwise we return we raise the no green point exception.

---

![slides/interval_0092.png](slides/interval_0092.png)
_t = 2730.0s -- 2760.0s_

We should doesn't expression to running an alpha type sort of contradictory to the fact that function must have a unique data type. So it doesn't contradict right. It is sort of a placeholder. It is not saying I can return several different types at the same time. It is only there saying

---

![slides/interval_0093.png](slides/interval_0093.png)
_t = 2760.0s -- 2790.0s_

We can like can we define other functions which can return any type. Yes you can. Okay. So let me not go into this. Let me actually answer good questions by Teresa. So let me make it bigger. So when we say something is polymorphic right. So here is the usual polymorphic function.

---

![slides/interval_0094.png](slides/interval_0094.png)
_t = 2790.0s -- 2820.0s_

Right. And identity function is a polymorphic function that takes an X and returns an X. It has type alpha to alpha. Right. Would you call it a function which can return any type. Right. So that is I would argue that that is the wrong way to read this type. It returns a type right which is the same as the argument type. Of course you can apply this function. Let's say ID of 10 gives you 10 right and ID of

---

![slides/interval_0095.png](slides/interval_0095.png)
_t = 2820.0s -- 2850.0s_

ID of 10.5 gives you 10.5. Right. But but this doesn't mean that it is returning different types like it is actually returning the type that is given by the argument. It's not making up types out of the net. Right. Unlike what race is doing race is in fact making types out of the net because it doesn't have to show the value.

---

![slides/interval_0096.png](slides/interval_0096.png)
_t = 2850.0s -- 2880.0s_

But here it is just saying whatever the type of this alpha is I'm just going to return the same alpha. One way to reconcile what is happening here is this function is not returning any type. It is actually there is actually you can imagine that there is one ID for every type. Right. That is not how it is implemented but you can abstractly imagine that there is an ID for integer. There is an ID for float. There is an ID for string.

---

![slides/interval_0097.png](slides/interval_0097.png)
_t = 2880.0s -- 2910.0s_

There is an ID for other type types that you can define. And when I call ID of 10 you call that function which has ID for the integer type. Right. And this gets specialized. Right. So if I say let's let's for example call this ID prime function to be an inter-oint function. Right. I am specializing this. Right. And now I can say ID prime of 10. So this works but this doesn't work.

---

![slides/interval_0098.png](slides/interval_0098.png)
_t = 2910.0s -- 2940.0s_

Right. When I type 10 it works because it is an inter-oint that works. When I type 10.5 doesn't work because the expected types are different. And this is what is happening underneath. Essentially whenever you apply ID to a particular type value for that instance. Right. You specialize ID. But there can be other specializations as well. Just like here. Right.

---

![slides/interval_0099.png](slides/interval_0099.png)
_t = 2940.0s -- 2970.0s_

I specialize this ID to ID prime where it is an inter-oint. But I can of course call it on a floating point number. This is different from that's just an instance of specialization. Let's sort of answer your question Shreesha. So we cannot have other functions which take in one type and determine. Good question. So we cannot. It's a really good question. Yeah. Yeah. So

---

![slides/interval_0100.png](slides/interval_0100.png)
_t = 2970.0s -- 3000.0s_

you're sort of seeing through some advanced types. Essentially you cannot have a function. If you ignore the exceptions for the moment right. I cannot have a function which says goes from let me think of a useful thing.

---

![slides/interval_0101.png](slides/interval_0101.png)
_t = 3000.0s -- 3030.0s_

You cannot have a function that goes from say you cannot write this function because this function does not make sense. Right. Because the return. So DC realize what is DC realize doing. So you have a you're sending values over the wire. Right.

---

![slides/interval_0102.png](slides/interval_0102.png)
_t = 3030.0s -- 3060.0s_

And you got a string representation of the value. And now you want to based on the string representation. Return whatever type that is. This is not a function that you can write in OCaml. Right. Because what is this type. Right. We cannot make things up just by looking at the better presentation because the type of

---

![slides/interval_0103.png](slides/interval_0103.png)
_t = 3060.0s -- 3090.0s_

the argument is actually dependent on the contents of whatever is in the string. Right. The contents could be an integer representation. The content could be a float representation or whatnot. But this is not something that we can decide statically. So it doesn't make sense to even write this function. So this is this is something that you cannot write. And exceptions are special. You can of course always fill in this with fail with.

---

![slides/interval_0104.png](slides/interval_0104.png)
_t = 3090.0s -- 3120.0s_

I mean it has to take a string. So I'm just doing this one. With not implemented this is cheating. Right. So I'm sort of defining this function but I'm actually not defining it at all because I'm whenever you call this function with anything it will just raise that exception. Right.

---

![slides/interval_0105.png](slides/interval_0105.png)
_t = 3120.0s -- 3150.0s_

The serialize of say hello. It will just raise that exception. So in OCaml you cannot write this particular type. Actually there is a very deep reason for the non-existence of this type which we will which we will study. There is a so after after a little bit of OCaml we will study Lambda calculus and there I will give you a logical reason why this type cannot exist. But I will save it for later. I think I'll stop here. I already overtime but really good questions.

---

![slides/interval_0106.png](slides/interval_0106.png)
_t = 3150.0s -- 3180.0s_

I think there is a little bit more here and then we will go into higher order programming tomorrow and then after that you can actually start doing the assignment one. Okay I'll stop here. Hello. Sir I just wanted to request you for one thing.  Can you please postpone assignment one by two to three days.

---

![slides/interval_0107.png](slides/interval_0107.png)
_t = 3180.0s -- 3213.6s_

Postpone. Because we are having our interviews from 30th of August. Okay so that's fine. Yeah I can I think it's on Monday. Would it be okay if I do it by Wednesday. Is it fine. Bednesdays will be September 2 right. Yeah it's fine fine. Okay that's fine. Yeah okay that's fine. I'll just do it now. Okay. Yeah no problem. I'll talk to you tomorrow. Bye bye.

---
