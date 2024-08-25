<!--
# The Universe Design Pattern
-->

# ユニバースによるデザインパターン

<!--
In Lean, types such as `Type`, `Type 3`, and `Prop` that classify other types are known as universes.
However, the term _universe_ is also used for a design pattern in which a datatype is used to represent a subset of Lean's types, and a function converts the datatype's constructors into actual types.
The values of this datatype are called _codes_ for their types.
-->

Leanにおいて、`Type` や `Type 3` 、`Prop` などの他の型を分類する型を宇宙（universe）と呼んでいます。しかし、**ユニバース** という用語は、Leanの型のサブセットを表すためのデータ型とデータ型のコンストラクタを実際の型に変換するための関数を使用するデザインパターンに対しても用いられます。このデータ型の値は、その型に対しての **コード** （code）と呼ばれます。

<!--
Just like Lean's built-in universes, the universes implemented with this pattern are types that describe some collection of available types, even though the mechanism by which it is done is different.
In Lean, there are types such as `Type`, `Type 3`, and `Prop` that directly describe other types.
This arrangement is referred to as _universes à la Russell_.
The user-defined universes described in this section represent all of their types as _data_, and include an explicit function to interpret these codes into actual honest-to-goodness types.
This arrangement is referred to as _universes à la Tarski_.
While languages such as Lean that are based on dependent type theory almost always use Russell-style universes, Tarski-style universes are a useful pattern for defining APIs in these languages.
-->

Lean組み込みの宇宙と同じように、このパターンで実装されたユニバースは利用可能な型のコレクションを記述する型ですが、これを実現するメカニズムは異なります。Leanにおいて、`Type` や `Type 3` 、`Prop` などの型があり、これらは他の型を直接記述します。このやり方は **Russell風宇宙** （universes à la Russell）と呼ばれます。本節で説明するユーザ定義のユニバースは対象の型すべてを **データ** として表し、これらのコードを正真正銘実際の型へと解釈する明示的な関数を含みます。このやり方は **Tarski風ユニバース** （universes à la Tarski）と呼ばれます。Leanのような依存型理論に基づく言語ではほとんどの場合Russell流の宇宙が使用されますが、これらの言語においてAPIを定義する場合にはTarski流のユニバースは有用なパターンです。

<!--
Defining a custom universe makes it possible to carve out a closed collection of types that can be used with an API.
Because the collection of types is closed, recursion over the codes allows programs to work for _any_ type in the universe.
One example of a custom universe has the codes `nat`, standing for `Nat`, and `bool`, standing for `Bool`:
-->

カスタムのユニバースを定義することで、APIで使用できる範囲に閉じた型のコレクションを切り出すことが可能になります。型のコレクションが閉じていることから、コードに対して再帰させることでユニバース内の **すべての** 型に対してプログラムを動作させることができます。カスタムユニバースの一例として、以下ではコード `nat` は `Nat` を、`bool` は `Bool` をそれぞれ表しています：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean NatOrBool}}
```
<!--
Pattern matching on a code allows the type to be refined, just as pattern matching on the constructors of `Vect` allows the expected length to be refined.
For instance, a program that deserializes the types in this universe from a string can be written as follows:
-->

`Vect` のコンストラクタのパターンマッチで期待される長さを絞り込めるように、コードのパターンマッチで型を絞り込むことができます。例えば、このユニバースの型を文字列からデシリアライズするプログラムは次のように書くことができます：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean decode}}
```
<!--
Dependent pattern matching on `t` allows the expected result type `t.asType` to be respectively refined to `NatOrBool.nat.asType` and `NatOrBool.bool.asType`, and these compute to the actual types `Nat` and `Bool`.
-->

`t` に対する依存パターンマッチにより、期待される結果の型 `t.asType` はそれぞれ `NatOrBool.nat.asType` と `NatOrBool.bool.asType` に精練され、これらは実際の型 `Nat` と `Bool` に計算されます。

<!--
Like any other data, codes may be recursive.
The type `NestedPairs` codes for any possible nesting of the pair and natural number types:
-->

他の一般的なデータと同じように、コードは再帰的である場合があります。`NestedPairs` 型は自然数型とあらゆる入れ子に対応したペアの型を実装しています：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean NestedPairs}}
```
<!--
In this case, the interpretation function `NestedPairs.asType` is recursive.
This means that recursion over codes is required in order to implement `BEq` for the universe:
-->

この場合、解釈関数 `NestedPairs.asType` は再帰的になります。これはユニバースに `BEq` を実装するためには、コードに対する再帰が必要になるということです：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean NestedPairsbeq}}
```

<!--
Even though every type in the `NestedPairs` universe already has a `BEq` instance, type class search does not automatically check every possible case of a datatype in an instance declaration, because there might be infinitely many such cases, as with `NestedPairs`.
Attempting to appeal directly to the `BEq` instances rather than explaining to Lean how to find them by recursion on the codes results in an error:
-->

たとえ `NestedPairs` ユニバースのすべての型がすでに `BEq` インスタンスを持っていたとしても、型クラス検索はインスタンス宣言のデータ型すべての可能なケースを自動的にチェックしません。これは `NestedPairs` のような場合において、この可能なケースが無限に存在してしまう可能性があるからです。コードに対する再帰によって `BEq` インスタンスを見つける方法をLeanに提示するのではなく、`BEq` インスタンスに直接表現しようとするとエラーになります：

```lean
{{#example_in Examples/DependentTypes/Finite.lean beqNoCases}}
```
```output error
{{#example_out Examples/DependentTypes/Finite.lean beqNoCases}}
```
<!--
The `t` in the error message stands for an unknown value of type `NestedPairs`.
-->

エラーメッセージの `t` は `NestedPairs` 型の未知の値を表しています。

<!--
## Type Classes vs Universes
-->

## 型クラス vs ユニバース

<!--
Type classes allow an open-ended collection of types to be used with an API as long as they have implementations of the necessary interfaces.
In most cases, this is preferable.
It is hard to predict all use cases for an API ahead of time, and type classes are a convenient way to allow library code to be used with more types than the original author expected.
-->

型クラスは必要なインタフェースの実装を持っている限りAPIとともにオープンエンドな型のコレクションを使用することができます。大体の場合、この方が望ましいです。APIのすべてのユースケースを事前に予測することは困難であり、型クラスはオリジナルの作者が予想したよりも多くの型でライブラリコードを使用できるようにする便利な方法です。

<!--
A universe à la Tarski, on the other hand, restricts the API to be usable only with a predetermined collection of types.
This is useful in a few situations:
-->

一方、Tarski風ユニバースは、APIがあらかじめ決められた型のコレクションでしか使えないように制限します。これはいくつかの状況で役に立ちます：

 <!--
 * When a function should act very differently depending on which type it is passed—it is impossible to pattern match on types themselves, but pattern matching on codes for types is allowed
 * When an external system inherently limits the types of data that may be provided, and extra flexibility is not desired
 * When additional properties of a type are required over and above the implementation of some operations
 -->
 * どの型が渡されるかによって関数の動作が大きく異なる場合。この場合、型そのものに対するパターンマッチは不可能ですが、型に対応したコードに対するパターンマッチは可能です
 * 外部システムが本質的に提供可能なデータの種類を制限しており、余分な柔軟性が望まれない場合
 * ある操作の実装以上に型へのプロパティ追加が必要な場合

<!--
Type classes are useful in many of the same situations as interfaces in Java or C#, while a universe à la Tarski can be useful in cases where a sealed class might be used, but where an ordinary inductive datatype is not usable.
-->

型クラスはJavaやC#のインタフェースと同じような状況の多くで役に立ちます。一方で、Tarski風ユニバースはsealed classは使えそうだが、通常の帰納的データ型が使えないようなケースで役に立ちます。

<!--
## A Universe of Finite Types
-->

## 有限の型に対するユニバース

<!--
Restricting the types that can be used with an API to a predetermined collection can enable operations that would be impossible for an open-ended API.
For example, functions can't normally be compared for equality.
Functions should be considered equal when they map the same inputs to the same outputs.
Checking this could take infinite amounts of time, because comparing two functions with type `Nat → Bool` would require checking that the functions returned the same `Bool` for each and every `Nat`.
-->

APIで使用できる型をあらかじめ決められたコレクションに制限することで、オープンエンドなAPIでは不可能な操作を可能にすることができます。例えば、関数は通常同値性を確かめることはできません。関数は同じ入力に対して同じ出力を写した時に等しいとみなせます。これは無限に時間がかかってしまう可能性があります。なぜなら、`Nat → Bool` 型を持つ2つの関数を比較するにはすべての各 `Nat` に対して関数が同じ `Bool` を返すかどうかをチェックする必要があるからです。

<!--
In other words, a function from an infinite type is itself infinite.
Functions can be viewed as tables, and a function whose argument type is infinite requires infinitely many rows to represent each case.
But functions from finite types require only finitely many rows in their tables, making them finite.
Two functions whose argument type is finite can be checked for equality by enumerating all possible arguments, calling the functions on each of them, and then comparing the results.
Checking higher-order functions for equality requires generating all possible functions of a given type, which additionally requires that the return type is finite so that each element of the argument type can be mapped to each element of the return type.
This is not a _fast_ method, but it does complete in finite time.
-->

言い換えれば、無限の型からの関数はそれ自体が無限です。関数は表として見ることができ、関数の引数の型が無限である場合はそれぞれのケースを表すために無限の行が必要になります。しかし有限の型からの関数はその表の行として有限個しか必要とせず、関数自体も有限となります。引数の型が有限である2つの関数は、すべての可能な引数を列挙し、それぞれの引数に対して関数を呼び出してその結果を比較することで関数同士が等しいかどうかをチェックすることができます。高階関数の同値チェックには与えられた型であるようなすべての関数を生成する必要があり、さらに引数の型の各要素を戻り値の各要素に写せるように戻り値の型が有限である必要があります。これは **速い** 方法ではありませんが、有限時間で完了します。

<!--
One way to represent finite types is by a universe:
-->

有限の型を表現する1つの方法としてユニバースを使うものがあります：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean Finite}}
```
<!--
In this universe, the constructor `arr` stands for the function type, which is written with an `arr`ow.
-->

このユニバースでは関数型が矢印（`arr`ow）で書かれることから、コンストラクタ `arr` が関数型を表しています。

<!--
Comparing two values from this universe for equality is almost the same as in the `NestedPairs` universe.
The only important difference is the addition of the case for `arr`, which uses a helper called `Finite.enumerate` to generate every value from the type coded for by `t1`, checking that the two functions return equal results for every possible input:
-->

このユニバースの2つの値の同値性を確かめるのは `NestedPairs` ユニバースの場合とほとんど同じです。唯一の重要な違いは `arr` のケースが追加されていることです。このケースでは `Finite.enumerate` という補助関数を使用して `t1` でコード化された型からすべての値を生成し、これによって2つの関数がすべての可能な入力に対して等しい結果を返すことをチェックします：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean FiniteBeq}}
```
<!--
The standard library function `List.all` checks that the provided function returns `true` on every entry of a list.
This function can be used to compare functions on the Booleans for equality:
-->

標準ライブラリにある関数 `List.all` は与えられた関数がリストのすべての要素で `true` を返すかどうかをチェックします。この関数は真偽値の関数の同値性を確かめるために使用できます：

```lean
{{#example_in Examples/DependentTypes/Finite.lean arrBoolBoolEq}}
```
```output info
{{#example_out Examples/DependentTypes/Finite.lean arrBoolBoolEq}}
```
<!--
It can also be used to compare functions from the standard library:
-->

また標準ライブラリの関数を比較するのにも使えます：

```lean
{{#example_in Examples/DependentTypes/Finite.lean arrBoolBoolEq2}}
```
```output info
{{#example_out Examples/DependentTypes/Finite.lean arrBoolBoolEq2}}
```
<!--
It can even compare functions built using tools such as function composition:
-->

関数合成などのツールを使って作られた関数でさえも比較することができます：

```lean
{{#example_in Examples/DependentTypes/Finite.lean arrBoolBoolEq3}}
```
```output info
{{#example_out Examples/DependentTypes/Finite.lean arrBoolBoolEq3}}
```
<!--
This is because the `Finite` universe codes for Lean's _actual_ function type, not a special analogue created by the library.
-->

これは `Finite` ユニバースのコードがライブラリによって作成される特別に用意された類似物などではなく、Leanの **実際の** 関数型を示すしているからです。

<!--
The implementation of `enumerate` is also by recursion on the codes from `Finite`.
-->

`enumerate` の実装も `Finite` のコードに対する再帰です。

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteAll}}
```
<!--
In the case for `Unit`, there is only a single value.
In the case for `Bool`, there are two values to return (`true` and `false`).
In the case for pairs, the result should be the Cartesian product of the values for the type coded for by `t1` and the values for the type coded for by `t2`.
In other words, every value from `t1` should be paired with every value from `t2`.
The helper function `List.product` can certainly be written with an ordinary recursive function, but here it is defined using `for` in the identity monad:
-->

`Unit` の場合、返される値は1つだけです。`Bool` の場合、返される値は2つ（`true` と `false` ）です。ペアの場合、戻り値は `t1` でコード化された型の値と `t2` でコード化された型の値のデカルト積になります。言い換えると、`t1` のすべての値は `t2` のすべての値をペアになります。補助関数 `List.product` は普通の再帰関数で書くこともできますが、ここでは恒等モナドの `for` を使って定義しています：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean ListProduct}}
```
<!--
Finally, the case of `Finite.enumerate` for functions delegates to a helper called `Finite.functions` that takes a list of all of the return values to target as an argument.
-->

最後に、関数に対する `Finite.enumerate` のケースは、対象のすべての戻り値のリストを引数として受け取る `Finite.functions` という補助関数に委譲されます。

<!--
Generally speaking, generating all of the functions from some finite type to a collection of result values can be thought of as generating the functions' tables.
Each function assigns an output to each input, which means that a given function has \\( k \\) rows in its table when there are \\( k \\) possible arguments.
Because each row of the table could select any of \\( n \\) possible outputs, there are \\( n ^ k \\) potential functions to generate.
-->

一般的に、ある有限の型から結果の値へのコレクションの関数をすべて生成することは、関数の表を生成することとして考えることができます。各関数は各入力に出力を割り当てるため、ある与えられた関数の引数が \\( k \\) 個の値がありうる場合、 \\( k \\) 行を表に持つことになります。表の各行は \\( n \\) 個の出力のいずれかを選択できるため、生成されうる関数は \\( n ^ k \\) 個になります。

<!--
Once again, generating the functions from a finite type to some list of values is recursive on the code that describes the finite type:
-->

繰り返しになりますが、有限の型から値へのリストへの関数の生成は、有限の型を記述するコードに対して再帰的に行われます：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionSigStart}}
```

<!--
The table for functions from `Unit` contains one row, because the function can't pick different results based on which input it is provided.
This means that one function is generated for each potential input.
-->

`Unit` からの関数の表は1行です。これは関数がどの入力が与えられるかによって異なる結果を選ぶことができないからです。つまり、1つの入力に対して1つの関数が生成されます。

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionUnit}}
```
<!--
There are \\( n^2 \\) functions from `Bool` when there are \\( n \\) result values, because each individual function of type `Bool → α` uses the `Bool` to select between two particular `α`s:
-->

戻り値が \\( n \\) 個ある場合、`Bool` からの関数は \\( n^2 \\) 個存在します。これは `Bool → α` 型の各関数が `Bool` を使って特定の2つの `α` を選択するからです：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionBool}}
```
<!--
Generating the functions from pairs can be achieved by taking advantage of currying.
A function from a pair can be transformed into a function that takes the first element of the pair and returns a function that's waiting for the second element of the pair.
Doing this allows `Finite.functions` to be used recursively in this case:
-->

ペアからの関数を生成するにはカリー化を利用します。ペアからの関数はペアの最初の要素を受け取り、ペアの2番目の要素を待つ関数を返す関数に変換できます。こうすることで `Finite.functions` を再帰的に使うことができます：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionPair}}
```

<!--
Generating higher-order functions is a bit of a brain bender.
Each higher-order function takes a function as its argument.
This argument function can be distinguished from other functions based on its input/output behavior.
In general, the higher-order function can apply the argument function to every possible argument, and it can then carry out any possible behavior based on the result of applying the argument function.
This suggests a means of constructing the higher-order functions:
-->

高階関数の生成はちょっと頭を使います。各高階関数は関数を引数に取ります。この引数の関数はその入出力の挙動に基づいて他の関数と区別することができます。一般的に、高階関数は引数の関数をあらゆる引数に適用することができ、その適用結果に基づいてあらゆる挙動を実行することができます。このことから高階関数の構成手段が示唆されます：

 <!--
 * Begin with a list of all possible arguments to the function that is itself an argument.
 * For each possible argument, construct all possible behaviors that can result from the observation of applying the argument function to the possible argument. This can be done using `Finite.functions` and recursion over the rest of the possible arguments, because the result of the recursion represents the functions based on the observations of the rest of the possible arguments. `Finite.functions` constructs all the ways of achieving these based on the observation for the current argument.
 * For potential behavior in response to these observations, construct a higher-order function that applies the argument function to the current possible argument. The result of this is then passed to the observation behavior.
 * The base case of the recursion is a higher-order function that observes nothing for each result value—it ignores the argument function and simply returns the result value.
 -->
 * 関数の引数として考えられるすべての引数のリストから始めます。
 * 各ありうる引数について、それらに引数の関数を適用することの観察から生じる可能な挙動すべてを構築します。これは `Finite.functions` と残りの可能な引数に対する再帰を使用して行うことができます。というのも再帰の結果は残りの可能な引数の関数に基づく関数を表すからです。
 * これらの観察に応答する潜在的な挙動に対して、引数の関数を現在の可能な引数に適用する高階関数を構築します。そしてその結果を観察の挙動に渡します。
 * 再帰のベースのケースは各結果の値に対して何も観察しない高階関数です。これは引数関数を無視し、ただ結果の値を返します。

<!--
Defining this recursive function directly causes Lean to be unable to prove that the whole function terminates.
However, using a simpler form of recursion called a _right fold_ can be used to make it clear to the termination checker that the function terminates.
A right fold takes three arguments: a step function that combines the head of the list with the result of the recursion over the tail, a default value to return when the list is empty, and the list being processed.
It then analyzes the list, essentially replacing each `::` in the list with a call to the step function and replacing `[]` with the default value:
-->

この再帰関数を直接定義しようとすると、Leanは関数全体が終了することを証明できません。しかし、**右畳み込み** （right fold）と呼ばれるより単純な再帰の形式を使用することで、関数が終了することを終了チェッカに明確に伝えることができます。右畳み込みは3つの引数を受け取ります：すなわち、リストの先頭と末尾の再帰結果を結合するステップ関数、リストが空の時に返すデフォルト値、そして処理対象のリストです。この処理は本質的にはリストを解析し、リストの各 `::` をステップ関数の呼び出しに置き換え、 `[]` をデフォルト値に置き換えます：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean foldr}}
```
<!--
Finding the sum of the `Nat`s in a list can be done with `foldr`:
-->

リストの `Nat` の合計を求めるには `foldr` を使用します：

```lean
{{#example_eval Examples/DependentTypes/Finite.lean foldrSum}}
```

<!--
With `foldr`, the higher-order functions can be created as follows:
-->

`foldr` を使うことで、高階関数は次のように作ることができます：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionArr}}
```
<!--
The complete definition of `Finite.Functions` is:
-->

`Finite.functions` の完全な定義は以下の通りです：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctions}}
```



<!--
Because `Finite.enumerate` and `Finite.functions` call each other, they must be defined in a `mutual` block.
In other words, right before the definition of `Finite.enumerate` is the `mutual` keyword:
-->

`Finite.enumerate` と `Finite.functions` がお互いに呼び合っているため、これらは `mutual` ブロック内で定義しなければなりません。つまり、`Finite.enumerate` の定義の直前に `mutual` キーワードが置かれます：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:MutualStart}}
```
<!--
and right after the definition of `Finite.functions` is the `end` keyword:
-->

そして `Finite.functions` の定義の直後に `end` キーワードが置かれます：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:MutualEnd}}
```

<!--
This algorithm for comparing functions is not particularly practical.
The number of cases to check grows exponentially; even a simple type like `((Bool × Bool) → Bool) → Bool` describes {{#example_out Examples/DependentTypes/Finite.lean nestedFunLength}} distinct functions.
Why are there so many?
Based on the reasoning above, and using \\( \\left| T \\right| \\) to represent the number of values described by the type \\( T \\), we should expect that
-->

比較関数についてのこのアルゴリズムは特別実用的というようなものではありません。というのもチェックのためのケースは指数関数的に増大するからです；`((Bool × Bool) → Bool) → Bool` のような単純な型でさえ {{#example_out Examples/DependentTypes/Finite.lean nestedFunLength}} 個の異なる関数を記述します。なぜこんなにたくさんになるのでしょうか？上記で行った推論および型 \\( T \\) で記述される値の数の表現として \\( \\left| T \\right| \\) を用いると、

\\[ \\left| \\left( \\left( \\mathtt{Bool} \\times \\mathtt{Bool} \\right) \\rightarrow \\mathtt{Bool} \\right) \\rightarrow \\mathtt{Bool} \\right| \\]
<!--
is 
-->

は

\\[ \\left|\\mathrm{Bool}\\right|^{\\left| \\left( \\mathtt{Bool} \\times \\mathtt{Bool} \\right) \\rightarrow \\mathtt{Bool} \\right| }, \\]
<!--
which is
-->

であり、これは

\\[ 2^{2^{\\left| \\mathtt{Bool} \\times \\mathtt{Bool} \\right| }}, \\]
<!--
which is
-->

となり、これはさらに

\\[ 2^{2^4} \\]
<!--
or 65536.
Nested exponentials grow quickly, and there are many higher-order functions.
-->

もしくは65536となると予想されます。入れ子になった指数は急速に大きくなり、結果として多くの高階関数が存在することになります。

<!--
## Exercises
-->

## 演習問題

 <!--
 * Write a function that converts any value from a type coded for by `Finite` into a string. Functions should be represented as their tables.
 * Add the empty type `Empty` to `Finite` and `Finite.beq`.
 * Add `Option` to `Finite` and `Finite.beq`.
 -->
 * `Finite` でコード化された型の任意の値を文字列に変換する関数を書いてください。関数はそれらの表として表現されなければなりません。
 * 空の型 `Empty` を `Finite` と `Finite.beq` に追加してください。
 * `Option` を `Finite` と `Finite.beq` に追加してください。

