<!--
# Summary
-->

# まとめ

<!--
## Type Classes and Structures
-->

## 型クラスと構造体

<!--
Behind the scenes, type classes are represented by structures.
Defining a class defines a structure, and additionally creates an empty table of instances.
Defining an instance creates a value that either has the structure as its type or is a function that can return the structure, and additionally adds an entry to the table.
Instance search consists of constructing an instance by consulting the instance tables.
Both structures and classes may provide default values for fields (which are default implementations of methods).
-->

型クラスは内部的には構造体として表現されます。クラスを定義することで対応する構造体が定義され、さらにインスタンスデータベースに空のテーブルが作成されます。インスタンスの定義によって構造体を型として持つか、その構造体を返す関数のどちらかの値が作成され、さらにテーブルにレコードが追加されます。インスタンス検索はインスタンステーブルを参照してインスタンスを構築します。構造体のクラスどちらでもフィールドのデフォルト値（メソッドの場合はデフォルト実装）を提供することができます。

<!--
## Structures and Inheritance
-->

## 構造体と継承

<!--
Structures may inherit from other structures.
Behind the scenes, a structure that inherits from another structure contains an instance of the original structure as a field.
In other words, inheritance is implemented with composition.
When multiple inheritance is used, only the unique fields from the additional parent structures are used to avoid a diamond problem, and the functions that would normally extract the parent value are instead organized to construct one.
Record dot notation takes structure inheritance into account.
-->

構造体はほかの構造体を継承することができます。その裏側では、他の構造体を継承した構造体は、元の構造体のインスタンスをフィールドとして含んでいます。言い換えると、継承は合成で実装されています。多重継承の場合、菱形継承問題を回避するために、親構造体に対して継承時に追加されたユニークなフィールドのみがその構造体のフィールドとして使用され、通常であれば親構造体の値を抽出する関数が、代わりに親の値を構築するために組み込まれます。レコードのドット記法は構造体の継承にも対応しています。

<!--
Because type classes are just structures with some additional automation applied, all of these features are available in type classes.
Together with default methods, this can be used to create a fine-grained hierarchy of interfaces that nonetheless does not impose a large burden on clients, because the small classes that the large classes inherit from can be automatically implemented.
-->

型クラスは単に構造体にいくつかの自動化が施されたものであるため、これらのすべての機能は型クラスで利用できます。デフォルトメソッドと組み合わせることで、きめ細かいインタフェースの階層を作ることができます。これはクライアントに実装にあたっての負荷を軽減します。というのも、大きなクラスが継承するデフォルトメソッドを含むような小さなクラスは自動的に実装されるからです。

<!--
## Applicative Functors
-->

## アプリカティブ関手

<!--
An applicative functor is a functor with two additional operations:
-->

アプリカティブ関手は関手に以下の2つの演算子を追加したものです：

 <!--
 * `pure`, which is the same operator as that for `Monad`
 * `seq`, which allows a function to be applied in the context of the functor.
-->
 * `pure` 、これは `Monad` の演算子と同じものです
 * `seq` は関手のコンテキストのもとで関数をできるようにします
 
<!--
While monads can represent arbitrary programs with control flow, applicative functors can only run function arguments from left to right.
Because they are less powerful, they provide less control to programs written against the interface, while the implementor of the method has a greater degree of freedom.
Some useful types can implement `Applicative` but not `Monad`.
-->

モナドが制御フローを持つ任意のプログラムを表現できるのに対し、アプリカティブ関手は関数の引数を左から右にしか実行できません。アプリカティブ関手はモナドほど強力ではないためインタフェースに反して書かれたプログラムをそこまで制御できませんが、その代わりにメソッドの実装の自由度が増します。いくつかの便利な型では `Applicative` を実装できる一方で `Monad` を実装することができません。

<!--
In fact, the type classes `Functor`, `Applicative`, and `Monad` form a hierarchy of power.
Moving up the hierarchy, from `Functor` towards `Monad`, allows more powerful programs to be written, but fewer types implement the more powerful classes.
Polymorphic programs should be written to use as weak of an abstraction as possible, while datatypes should be given instances that are as powerful as possible.
This maximizes code re-use.
The more powerful type classes extend the less powerful ones, which means that an implementation of `Monad` provides implementations of `Functor` and `Applicative` for free.
-->

実は、型クラス `Functor` ・`Applicative` ・`Monad` は階層を構成しています。`Functor` から `Monad` へと階層が上がるにつれてより強力なプログラムを書けるようになりますが、より強力なクラスを実装できる型は限られてきます。多相なプログラムはできるだけ弱い抽象を使うように書くべきであり、データ型はできるだけ強力なインスタンスを与えるべきです。これはコードの再利用を最大化します。より強力な空クラスはより強力でない型を継承します。つまり、`Monad` の実装は `Functor` と `Applicative` の実装をタダで提供します。

<!--
Each class has a set of methods to be implemented and a corresponding contract that specifies additional rules for the methods.
Programs that are written against these interfaces expect that the additional rules are followed, and may be buggy if they are not.
The default implementations of `Functor`'s methods in terms of `Applicative`'s, and of `Applicative`'s in terms of `Monad`'s, will obey these rules.
-->

各クラスには実装すべきメソッドの集合と、それに対応するメソッドに関する追加のルールを規定する約定があります。これらのインタフェースに対して書かれたプログラムは追加のルールが満たされていることを期待し、さもなければバグが発生する可能性があります。`Functor` のメソッドを `Applicative` のメソッドとして実装する場合、または `Applicative` のメソッドを `Monad` のメソッドとして実装する場合、デフォルトではこれらのルールに従います。

<!--
## Universes
-->

## 宇宙

<!--
To allow Lean to be used as both a programming language and a theorem prover, some restrictions on the language are necessary.
This includes restrictions on recursive functions that ensure that they all either terminate or are marked as `partial` and written to return types that are not uninhabited.
Additionally, it must be impossible to represent certain kinds of logical paradoxes as types.
-->

Leanをプログラミング言語と定理証明器のどちらとしても使えるようにするためには、言語に対していくつかの制限が必要になります。これにはすべての再帰関数がちゃんと終了するか、`partial` とマークされ、空ではない型を返すことを保証するかのどちらかでなければならないという制限が含まれます。さらに、ある種の論理的なパラドックスを型として表現することは不可能でなければなりません。

<!--
One of the restrictions that rules out certain paradoxes is that every type is assigned to a _universe_.
Universes are types such as `Prop`, `Type`, `Type 1`, `Type 2`, and so forth.
These types describe other types—just as `0` and `17` are described by `Nat`, `Nat` is itself described by `Type`, and `Type` is described by `Type 1`.
The type of functions that take a type as an argument must be a larger universe than the argument's universe.
-->

このようなパラドックスを排除するための制約の1つに、すべての型が **宇宙** に割り当てられているというものがあります。宇宙とは `Prop` ・`Type` ・`Type 1` ・`Type 2` などの型のことです。これらの型はほかの型を記述します。ちょうど `0` と `17` が `Nat` によって記述されるように、`Nat` 自身が `Type` に、`Type` が `Type 1` によって記述されます。型を引数に取る関数の型は引数の型よりも大きな宇宙でなければなりません。

<!--
Because each declared datatype has a universe, writing code that uses types like data would quickly become annoying, requiring each polymorphic type to be copy-pasted to take arguments from `Type 1`.
A feature called _universe polymorphism_ allows Lean programs and datatypes to take universe levels as arguments, just as ordinary polymorphism allows programs to take types as arguments.
Generally speaking, Lean libraries should use universe polymorphism when implementing libraries of polymorphic operations.
-->

宣言されたデータ型はそれぞれ宇宙を持つため、データ型をデータのように使うコードを書くとそれぞれの多相型を `Type 1` から引数を取るようにコピペする必要があり、すぐに面倒なことになります。**宇宙多相** と呼ばれる機能により、通常の多相でプログラムが型を引数としてとることができるように、Leanのプログラムとデータ型が宇宙レベルを引数として取ることができるようになります。一般的に、Leanにて多相的な操作のライブラリを実装する場合は宇宙多相を使うべきです。

