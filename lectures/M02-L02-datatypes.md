---
title: "Data Types and Pattern Matching"
lecture_no: 2
week: 2
duration_target_min: 145
concepts: []
keywords: []
reading:
  - title: "The OCaml manual, Data types section"
    url: https://ocaml.org/manual/5.5/coreexamples.html#s%3Adatatypes
  - title: "Cornell CS3110, Basics chapter (index)"
    url: https://cs3110.github.io/textbook/chapters/data/intro.html
---

# Data types and pattern matching

OCaml has a concise and expressive system for creating new
datatypes. It also supports pattern matching to naturally express
deconstruction of these data types.

## Type aliases

OCaml allows you to define aliases for existing types using the
`type` keyword:

```ocaml
type int_pair = int * int
```

The above defines a type `int_pair` which is an alias to the pair
of ints type (`int * int`).

You can constrain the type of an expression using the `:` operator.
Here we create an identity function which is constrained to only
work on pairs of ints:

```ocaml
let id x = (x : int_pair)
```

You can also constrain the type of a variable binding, so our `id`
function could also be written as:

```ocaml
let id (x : int_pair) = x
```

## Records

### Record types

Records in OCaml represent a collection of named elements. A
simple example is a `point` record containing `x`, `y` and `z`
fields:

```ocaml
type point = {
  x : int;
  y : int;
  z : int;
}
```

We can create instances of our `point` type using `{ ... }`, and
access the elements of a point using the '.' operator:

:::slide

## Creating and accessing records

```ocaml
let origin = { x = 0; y = 0; z = 0 }

let get_y r = r.y

let o = get_y origin
```

- Records represent a collection of named elements.
- Create instances using `{ ... }`.
- Access elements using the `.` operator.

:::

### Functional update

New records can also be created from existing records using the
`with` keyword. For example, we can create a new `point` which is
the same as `origin` except with the value of its `z` field
changed to `10`:

:::slide

## Functional update

```ocaml
let p = { origin with z = 10 }
```

- New records can be created from existing records using the
  `with` keyword.
- The new record is the same as `origin` except the `z` field is
  changed to `10`.

:::

### Field punning

Another useful trick with records is *field punning*, which allows
you to replace:

```ocaml
let mk_point x y z = { x = x; y = y; z = z }
```

with

```ocaml
let mk_point x y z = { x; y; z }
```

## Mutability

OCaml has first-class support for mutability. There are several
langauge features that support mutability in OCaml. One of them is
mutable record fields. Let us make a mutable point datatype.

```ocaml
type mpoint = {mutable x : int; mutable y : int; mutable z: int}
```

Notice that the type says that the fields are `mutable`. Just like
the point datatype defined previously, you can create a value of
`mpoint` type and read it.

```ocaml
let morigin = {x=0;y=0;z=0}

let p = {morigin with z = 10}

let p_z = p.z
```

However, unlike the immutable record fields, the mutable fields can
be updated.

:::slide

## Mutable record fields

```ocaml
let () = p.z <- 20

let p_z = p.z
```

- Unlike immutable record fields, mutable fields can be updated.
- Updates use the `<-` operator.

:::

### References

It is sometimes useful to create single mutable value. OCaml
provides reference cells for this purpose

```ocaml
let x = ref 0
```

`x` is a reference cell which holds a value of type integer and
its current value is 0. Reference cells can be read using `!` and
updated using `:=`.

```ocaml
let () = x := !x + 1

let v = !x
```

(* ### Exercise

Implement a function that takes two mutable variable and swaps
their values:

```ocaml
let swap x y = failwith "for you to implement"
```

```ocaml skip
let x = ref 10
let y = ref 20

let () = swap x y
```

```ocaml skip
assert ((20,10) = (!x,!y))
```
*)

## Variants

### Variant types

Variants in OCaml represent data which can be in one of a number
of forms. A very simple example is a type representing one of
three colours:

```ocaml
type colour =
  | Red
  | Green
  | Blue
```

We can create a `colour` using one of its constructors:

```ocaml
let red = Red
```

### Constructor arguments

Variant constructors can also have arguments. This allows variants
to contain different types of data depending on which constructor
was used. For example, we can create a type which contains either
a `point` or a `colour`:

:::slide

## Constructor arguments

```ocaml
type t =
  | Point of point
  | Colour of colour
  
let p_or_c cond pnt col = if cond then Point pnt else Colour col

let p = p_or_c (1 > 0) origin red
```

- Variant constructors can have arguments.
- This allows a variant to contain different types of data
  depending on which constructor was used.

:::

### Multiple constructor arguments

Variants constructors can contain multiple arguments seperated by
the `*` symbol:

```ocaml
type s =
| ThreePoints of point * point * point
| TwoColours of colour * colour
```

Creating these constructors with multiple arguments require
parentheses:

```ocaml
let s = TwoColours(Red, Green)
```

## Pattern matching

Before we go on, let us define a handy print function to print
stuff to the notebook.

```ocaml skip
#require "jupyter.notebook";;

let show s = ignore (Jupyter_notebook.display "text/html" ("<h3 style='color:red'>"^s^"</h3>"))
```

Now we can print things to screen

```ocaml skip
show "Hello, world!"
```

### Inspecting variants

So far we have created some values of variant types, but how do we
get the data back out of them? The answer is *pattern matching*.
Using a `match` statement we can deconstruct a variant type and
retrieve its constructor's arguments:

```ocaml skip
let print_t t =
  match t with
  | Point p -> show (Printf.sprintf "Point: %d %d %d\n" p.x p.y p.z)
  | Colour c -> show (Printf.sprintf "Colour\n")
  
let () = print_t (Point { x = 5; y = 9; z = 0 })

let () = print_t (Colour Blue)
```

Here `Point p` and `Colour c` are not expressions but *patterns*.
They describe the shape of the data and bind variables to
different parts of it. Note that the `p` in `Point p` does not
refer to an existing `p` variable, instead it is creating a new
`p` variable bound to the argument of the `Point` constructor.

### Nested patterns

We can nest patterns within other patterns to do pattern matching
on the constructor arguments. For example, we can print the names
of the different colours in our `print_t` function:

```ocaml skip
let print_t t =
  match t with
  | Point p -> show (Printf.sprintf "Point: %d %d %d\n" p.x p.y p.z)
  | Colour Red -> show (Printf.sprintf "Red\n")
  | Colour Green -> show (Printf.sprintf "Green\n")
  | Colour Blue -> show (Printf.sprintf "Blue\n")
  
let () = print_t (Colour Red)

let () = print_t (Colour Blue)
```

### Matching records

We can also match on record data using the same syntax as to
create records, including field punning. So our `print_t` can be
further refined to:

```ocaml skip
let print_t t =
  match t with
  | Point { x; y; z } -> show (Printf.sprintf "Point: %d %d %d\n" x y z)
  | Colour Red -> show (Printf.sprintf "Red\n")
  | Colour Green -> show (Printf.sprintf "Green\n")
  | Colour Blue -> show (Printf.sprintf "Blue\n")
```

### Exhaustiveness

A key feature of pattern matching, which can help prevent many
errors especially when refactoring, is that the compiler will warn
you if you forget to handle a particular case. For example, if we
had forgotten the `Colour Green` case in the above definition:

```ocaml skip
let print_t_ t =
  match t with
  | Point { x; y; z } -> show (Printf.sprintf "Point: %d %d %d\n" x y z)
  | Colour Red -> show (Printf.sprintf "Red\n")
  | Colour Blue -> show (Printf.sprintf "Blue\n")
```

### The `_` pattern

Sometimes, you do not care about the value of a constructor, in
this case you can use the `_` pattern which will match any
constructor:

:::slide

## The `_` pattern

```ocaml
let is_colour_red t =
  match t with
  | Colour Red -> true
  | _ -> false
```

- Sometimes you do not care about the value of a constructor.
- The `_` pattern matches any constructor.

:::

### Match ordering

Note that patterns are matched from top to bottom: if a value
matches multiple patterns then the first of those patterns will be
selected. For example, in the following code the second case will
never be matched:

```ocaml
let is_colour_red t =
  match t with
  | _ -> false
  | Colour Red -> true
```
```mdx-error
Line 4, characters 7-17:
Warning 11 [redundant-case]: this match case is unused.
```

## Parameterised types

Types in OCaml can be parameterised by other types. For example,
the `option` type which may or may not contain a value:

```ocaml
type 'a option =
| None
| Some of 'a
```

In the above the `'a` is a *type variable*, which can be
substituted by any type. For instance a we can create a value of
type `int option` or a value of type `colour option`:

```ocaml
let io = Some 6

let co = Some Green
```

We can define a printer for `t option` type as follows:

```ocaml skip
let print_t_opt t = 
  match t with
  | None -> show ("None")
  | Some t -> print_t t
```

```ocaml skip
let () = print_t_opt (Some (Colour Red))

let () = print_t_opt None
```

### Polymorphic values

These type variables also appear when creating *polymorphic*
values. For example, the following function has type
`'a option -> 'a list` which means it can be applied to any
`option` type:

```ocaml
let opt_to_list o =
  match o with
  | Some x -> [x]
  | None -> []
  
let l = opt_to_list (Some 9)

let m = opt_to_list (Some Red)
```

### Polymorphic constructors

Constructors of parameterised types which do not include the type
parameter, such as `None` in the optional type, are also examples
of polymorphic values:

```ocaml
let n = None

let a = [ Some 3; n ]

let b = [ n; Some Blue ]
```

## Recursive data types

Data types in OCaml can also be recursive. This allows us to
create recursive structures such as trees and lists. The following
defines a parametric binary tree type:

:::slide

## Recursive data types

```ocaml
type 'a binary_tree =
  | Leaf
  | Tree of 'a binary_tree * 'a * 'a binary_tree
```

- Data types in OCaml can be recursive.
- This allows creating recursive structures such as trees and
  lists.

:::

As you can see the `Tree` constructor of `binary_tree` contains
other `binary_tree`s as its arguments.

### Inspecting recursive data types

We can write recursive functions to handle these recursive data
types. For example, the following function returns the maximum
depth of a binary tree:

```ocaml
let rec depth tr =
  match tr with
  | Leaf -> 1
  | Tree(left, _, right) ->
      1 + (max (depth left) (depth right))

let tree : colour binary_tree = 
  Tree(Tree(Leaf,
            Blue,
            Tree(Leaf,
                 Red,
                 Leaf)),
       Red,
       Tree(Leaf,
            Green,
            Leaf))

let d = depth tree
```

## Lists

### Constructing lists

A particularly common built-in data type in OCaml is the `list`
type. `list` is actually a parameterised recursive variant type.
It has two constructors `::` (called cons) and `[]` (called nil).
`[]` represents an empty list and `::` adds an element to the
front of the list:

:::slide

## Constructing lists

```ocaml
let l = 1 :: 2 :: 3 :: []
```

- `list` is a parameterised recursive variant type with two
  constructors, `::` (cons) and `[]` (nil).
- `[]` represents an empty list; `::` adds an element to the front
  of the list.

:::

OCaml also provides a short-hand syntax for lists: `[ ..; .. ]`.
Our `l` value above could instead have been defined:

```ocaml
let l = [1; 2; 3]
```

### Matching lists

Like all constructors, the list constructors can be used as
patterns in pattern matching. The following function sums all the
elements of an `int list`:

```ocaml
let rec sum il =
  match il with
  | [] -> 0
  | i :: rest -> i + (sum rest)
  
let s = sum l
```

(* ### Exercise

Write a function `min_list` to compute the minimum element in an
integer list. If the list is empty then it should return `None`.
If the minimum element is `e`, then the function returns `Some e`.

```ocaml
let rec min_list_helper cur_min l =
  match l with
  | [] -> cur_min
  | x::xs ->
      match cur_min with
      | None -> failwith "for you to implement"
      | Some m -> failwith "for you to implement"
  
let min_list l = min_list_helper None l
```

```ocaml
assert (min_list [] = None)
```

```ocaml skip
assert (min_list [3;1;2] = Some 1)
```
*)

(* ### Exercise

Write a function to return the list of elements of a binary in
postfix order. Use the list append function `@`:

```ocaml
[1;2;3] @ [4;5;6]
```

```ocaml
let rec postfix t = failwith "for you to implement"
```

```ocaml skip
assert ([0; 5; 4; 1] = postfix (Tree (Tree (Leaf, 0, Leaf), 1, Tree (Tree (Leaf, 5, Leaf), 4, Leaf))))
```
*)

(* ### Exercise

Write a function to reverse a list. Use the list append function
is `@`:

```ocaml
let rec rev_list l = failwith "for you to implement"
```

```ocaml skip
assert (rev_list ([1;2;3]) = [3;2;1])
```
*)
