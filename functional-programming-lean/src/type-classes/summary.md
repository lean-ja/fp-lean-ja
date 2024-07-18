<!--
# Summary
-->

# まとめ

<!--
## Type Classes and Overloading
-->

## 型クラスとオーバーロード

<!--
Type classes are Lean's mechanism for overloading functions and operators.
A polymorphic function can be used with multiple types, but it behaves in the same manner no matter which type it is used with.
For example, a polymorphic function that appends two lists can be used no matter the type of the entries in the list, but it is unable to have different behavior depending on which particular type is found.
An operation that is overloaded with type classes, on the other hand, can also be used with multiple types.
However, each type requires its own implementation of the overloaded operation.
This means that the behavior can vary based on which type is provided.
-->

型クラスは，関数や演算子をオーバーロードするための機構です．多相関数は複数の型で使用できますが，どの型で使用しても同じように動作します．例えば，2つのリストを結合する多相関数は，リスト内の要素の型に関係なく使用できますが，どの型が見つかったかによって異なる動作をすることはできません．一方で，型クラスでオーバーロードされる演算もまた複数の型で使用することができます．しかし，それぞれの型はオーバーロードされた演算の独自の実装を必要とします．つまり，与えられた型によって動作が異なる可能性があります．

<!--
A _type class_ has a name, parameters, and a body that consists of a number of names with types.
The name is a way to refer to the overloaded operations, the parameters determine which aspects of the definitions can be overloaded, and the body provides the names and type signatures of the overloadable operations.
Each overloadable operation is called a _method_ of the type class.
Type classes may provide default implementations of some methods in terms of the others, freeing implementors from defining each overload by hand when it is not needed.
-->

**型クラス** は名前とパラメータ，そしていくつかの名前と型からなる本体を持ちます．名前はオーバーロードされる演算を参照するためのもので，パラメータはオーバーロード可能な定義を決定し，そして本体はオーバーロードされる演算の名前と型シグネチャを提供します．オーバーロード可能な各演算は，型クラスの **メソッド** と呼ばれます．型クラスのいくつかのメソッドはほかのメソッドによるデフォルトの実装をされることもあり，実装者にとって必要がない場合はそれらを手で実装する必要はありません．

<!--
An _instance_ of a type class provides implementations of the methods for given parameters.
Instances may be polymorphic, in which case they can work for a variety of parameters, and they may optionally provide more specific implementations of default methods in cases where a more efficient version exists for some particular type.
-->

型クラスの **インスタンス** は，与えられたパラメータに対するメソッドの実装を提供します．インスタンスは多相的であることもあり．その場合はさまざまなパラメータに対して動作することができます．また，ある特定の型に対してより効率的なバージョンが存在する場合には，デフォルトメソッドのより具体的な実装を提供することもあります．

<!--
Type class parameters are either _input parameters_ (the default), or _output parameters_ (indicated by an `outParam` modifier).
Lean will not begin searching for an instance until all input parameters are no longer metavariables, while output parameters may be solved while searching for instances.
Parameters to a type class need not be types—they may also be ordinary values.
The `OfNat` type class, used to overload natural number literals, takes the overloaded `Nat` itself as a parameter, which allows instances to restrict the allowed numbers.
-->

型クラスのパラメータは **入力パラメータ** （デフォルト）か **出力パラメータ** （ `outParam` 修飾子で示されます）のどちらかです．Leanはすべての入力パラメータがメタ変数でなくなるまでインスタンスの検索を開始しませんが，出力パラメータはインスタンスの検索中に解決することができます．型クラスのパラメータは型である必要ではなく，通常の値も可能です．自然数リテラルをオーバーロードするために使用される `OfNat` 型クラスは，オーバーロードされた `Nat` 自身をパラメータとして受け取り，これによりインスタンスにその数値を限定させることができます．

<!--
Istances may be marked with a `@[default_instance]` attribute.
When an instance is a default instance, then it will be chosen as a fallback when Lean would otherwise fail to find an instance due to the presence of metavariables in the type.
-->

インスタンスには `@[default_instance]` 属性を付けることができます．インスタンス検索において型にメタ変数が存在してインスタンスを見つけることができない場合にはデフォルトインスタンスがフォールバックとして選択されます．

<!--
## Type Classes for Common Syntax
-->

## 通常の文法に対しての型クラス

<!--
Most infix operators in Lean are overridden with a type class.
For instance, the addition operator corresponds to a type class called `Add`.
Most of these operators have a corresponding heterogeneous version, in which the two arguments need not have the same type.
These heterogenous operators are overloaded using a version of the class whose name starts with `H`, such as `HAdd`.
-->

Leanのほとんどの中置演算子は型クラスでオーバーライドされています．例えば，加算演算子は `Add` という型クラスに対応しています．これらの演算子のほとんどには2つの引数が同じ型でなくても良い異なる型上の演算子が存在します．これらの異なる型上の演算子は `HAdd` のような `H` で始まるバージョンのクラスを使ってオーバーロードされます．

<!--
Indexing syntax is overloaded using a type class called `GetElem`, which involves proofs.
`GetElem` has two output parameters, which are the type of elements to be extracted from the collection and a function that can be used to determine what counts as evidence that the index value is in bounds for the collection.
This evidence is described by a proposition, and Lean attempts to prove this proposition when array indexing is used.
When Lean is unable to check that list or array access operations are in bounds at compile time, the check can be deferred to run time by appending a `?` to the indexing operation.
-->

インデックス構文は `GetElem` という型クラスを使ってオーバーロードされます．`GetElem` には2つの出力パラメータがあり，コレクションから抽出される要素の型と，添え字の値がコレクションの範囲内にあることの根拠となるものを決定するために使用できる関数の2つです．この根拠は命題として記述され，インデックス記法が使用されると，Leanはこの命題の証明を試みます．Leanがコンパイル時にリストや配列のアクセス操作が教会内にあることをチェックできない場合，インデックス操作に `?` を追加することでこのチェックを実行時に行うように遅延させることができます．

<!--
## Functors
-->

## 関手

<!--
A functor is a polymorphic type that supports a mapping operation.
This mapping operation transforms all elements "in place", changing no other structure.
For instance, lists are functors and the mapping operation may neither drop, duplicate, nor mix up entries in the list.
-->

関手とは，マッピング操作をサポートする多相型です．このマッピング操作は，すべての要素を「データ中のその位置で」変換し，ほかの構造は変更しません．例えば，リストは関手であり，マッピング操作はリスト内の要素を削除したり，重複させたり，並べ替えたりすることはできません．

<!--
While functors are defined by having `map`, the `Functor` type class in Lean contains an additional default method that is responsible for mapping the constant function over a value, replacing all values whose type are given by polymorphic type variable with the same new value.
For some functors, this can be done more efficiently than traversing the entire structure.
-->

関手は `map` を持つことで定義されますが，Leanの `Functor` 型クラスにはそれ以外にも，定数関数を値にマッピングするデフォルトメソッドが追加されており，多相型変数で与えられた型を持つすべての値を同じ新しい値で置き換えます．関手によっては，これは構造体全体を走査するよりも効率的に行うことができます．

<!--
## Deriving Instances
-->

## インスタンスの導出

<!--
Many type classes have very standard implementations.
For instance, the Boolean equality class `BEq` is usually implemented by first checking whether both arguments are built with the same constructor, and then checking whether all their arguments are equal.
Instances for these classes can be created _automatically_.
-->

多くの型クラスはとても標準的な実装を持っています．例えば，真偽値の同値クラス `BEq` は通常，まず両方の引数が同じコンストラクタでビルドされているかどうかをチェックし，次にすべての引数が等しいかどうかをチェックすることで実装されています．これらのクラスのインスタンスは **自動的に** 生成されます．

<!--
When defining an inductive type or a structure, a `deriving` clause at the end of the declaration will cause instances to be created automatically.
Additionally, the `deriving instance ... for ...` command can be used outside of the definition of a datatype to cause an instance to be generated.
Because each class for which instances can be derived requires special handling, not all classes are derivable.
-->

帰納型や構造体を定義するとき，宣言の最後に `deriving` 節を記述すると，自動的にインスタンスが生成されます．さらに `deriving instance ... for ...` コマンドをデータ型の定義の外側で使用すると，インスタンスを生成することができます．インスタンスを導出させることができるクラスはそれぞれ特別な処理を必要とするため，すべてのクラスが導出できるわけではありません．

<!--
## Coercions
-->

## 型強制

<!--
Coercions allow Lean to recover from what would normally be a compile-time error by inserting a call to a function that transforms data from one type to another.
For example, the coercion from any type `α` to the type `Option α` allows values to be written directly, rather than with the `some` constructor, making `Option` work more like nullable types from object-oriented languages.
-->

期待された型と異なる型を指定した際に，通常であればコンパイル時にエラーとなるところを，Leanではある型から別の型にデータを変換する関数への呼び出しを挿入する型強制によってエラーを回避できます．例えば，任意の型 `α` から `Option α` 型への強制は，`some` コンストラクタではなく，値を直接書くことを可能にし，`Option` をオブジェクト指向言語のnullable型のように使うことができます．

<!--
There are multiple kinds of coercion.
They can recover from different kinds of errors, and they are represented by their own type classes.
The `Coe` class is used to recover from type errors.
When Lean has an expression of type `α` in a context that expects something with type `β`, Lean first attempts to string together a chain of coercions that can transform `α`s into `β`s, and only displays the error when this cannot be done.
The `CoeDep` class takes the specific value being coerced as an extra parameter, allowing either further type class search to be done on the value or allowing constructors to be used in the instance to limit the scope of the conversion.
The `CoeFun` class intercepts what would otherwise be a "not a function" error when compiling a function application, and allows the value in the function position to be transformed into an actual function if possible.
-->

強制には複数の種類があります．これらは異なる種類のエラーから回復することができ，それぞれの型クラスで表現されます．`Coe` クラスは型エラーを回復するために使われます．Leanが `β` 型を期待するコンテキストに `α` 型の式を置くと，Leanはまず `α` 型を `β` 型に変換できるような強制の連鎖を通そうと試み，それができなかった場合にのみエラーを表示します．`CoeDep` クラスは，強制される特定の値を追加パラメータとして受け取り，その値に対してさらに型クラスの検索を行うか，インスタンス内でコンストラクタを使用して変換の範囲を限定することができます．`CoeFun` クラスは，関数適用をコンパイルする際に「not a function」エラーとなるような値を途中で捕まえ，可能であれば関数の位置の値を実際の関数に変換できるようにします．
