<!-- # The Complete Definitions -->

# 完全な定義

<!-- Now that all the relevant language features have been presented, this section describes the complete, honest definitions of `Functor`, `Applicative`, and `Monad` as they occur in the Lean standard library.
For the sake of understanding, no details are omitted. -->

ようやく関連する言語機能をすべて紹介したので，本節ではLeanの標準ライブラリにある `Functor` と `Applicative` ，`Monad` の正真正銘完全な定義について説明します．理解促進のために細部に至るまで省略しません．

<!-- ## Functor -->

## 関手

<!-- The complete definition of the `Functor` class makes use of universe polymorphism and a default method implementation: -->

`Functor` クラスの完全な定義では，宇宙多相とデフォルトメソッドの実装が用いられています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean HonestFunctor}}
```
<!-- In this definition, `Function.comp` is function composition, which is typically written with the `∘` operator.
`Function.const` is the _constant function_, which is a two-argument function that ignores its second argument.
Applying this function to only one argument produces a function that always returns the same value, which is useful when an API demands a function but a program doesn't need to compute different results for different arguments.
A simple version of `Function.const` can be written as follows: -->

この定義において，`Function.comp` は関数合成のことで，よく `∘` という演算子として記述されます．`Function.const` は **定数関数** （constant function）で，引数を2つ取り，2つ目を無視する関数です．この関数に1つだけ引数を適用することで常に同じ値を返す関数が出来上がります．これは関数を要求するAPIに対して，プログラムとしては引数ごとに異なる計算結果を返す必要がない場合に有用です．`Function.const` の定義を簡潔にすると以下のようになります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean simpleConst}}
```
<!-- Using it with one argument as the function argument to `List.map` demonstrates its utility: -->

この関数に1つ引数を適用した上で `List.map` の関数の引数として使うとその便利さがよくわかるでしょう：

```lean
{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConst}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConst}}
```
<!-- The actual function has the following signature: -->

この関数は実際には以下のシグネチャを持ちます：

```output info
{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean FunctionConstType}}
```
<!-- Here, the type argument `β` is an explicit argument, so the default definition of `Functor.mapConst` provides an `_` argument that instructs Lean to find a unique type to pass to `Function.const` that would cause the program to type check.
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldCompConst}}` is equivalent to `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldCompConst}}`. -->

ここでは型引数 `β` は明示的な引数であるため，`Functor.mapConst` のデフォルトの定義ではこの引数に `_` を与えることでプログラムの型チェックが通るような `Function.const` に渡される一意な型を見つけるようにLeanに指示します．`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldCompConst}}` は `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldCompConst}}` と等価です．

<!-- The `Functor` type class inhabits a universe that is the greater of `u+1` and `v`.
Here, `u` is the level of universes accepted as arguments to `f`, while `v` is the universe returned by `f`.
To see why the structure that implements the `Functor` type class must be in a universe that's larger than `u`, begin with a simplified definition of the class: -->

`Functor` クラスは `u+1` と `v` のうち大きい方の宇宙に存在します．ここで， `u` は `f` の引数として受け入れられる宇宙レベルで，`v` は `f` が返す宇宙です．`Functor` 型クラスを実装する構造体が何故 `u` よりも大きな宇宙に存在しなければならないかということを説明するために，まず簡略化したクラス定義から始めます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean FunctorSimplified}}
```
<!-- This type class's structure type is equivalent to the following inductive type: -->

この型クラスの構造体型は以下の帰納型と等価です：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean FunctorDatatype}}
```
<!-- The implementation of the `map` method that is passed as an argument to `Functor.mk` contains a function that takes two types in `Type u` as arguments.
This means that the type of the function itself is in `Type (u+1)`, so `Functor` must also be at a level that is at least `u+1`.
Similarly, other arguments to the function have a type built by applying `f`, so it must also have a level that is at least `v`.
All the type classes in this section share this property. -->

`Functor.mk` の引数として渡される `map` メソッドの実装には `Type u` 上の2つの型を引数に取る関数を含みます．これは関数自体の型が `Type (u+1)` 上にあることを意味するため，`Functor` も少なくとも `u+1` のレベルでなければなりません．同様に，関数の他の引数は `f` を適用して作られた型を持つことから，`Functor` も少なくとも `v` のレベルでなければなりません．本節のすべての型クラスはこの性質を共有しています．

<!-- ## Applicative -->

## アプリカティブ関手

<!-- The `Applicative` type class is actually built from a number of smaller classes that each contain some of the relevant methods.
The first are `Pure` and `Seq`, which contain `pure` and `seq` respectively: -->

`Applicative` 型クラスは実際にはいくつかの小さなクラスから構成されており，それぞれに関連するメソッドが含まれています．最初は `Pure` と `Seq` で，それぞれ `pure` と `seq` を含んでいます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Pure}}

{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Seq}}
```

<!-- In addition to these, `Applicative` also depends on `SeqRight` and an analogous `SeqLeft` class: -->

これらに加えて，`Applicative` は　`SeqRight` とこれに似た `SeqLeft` クラスにも依存しています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean SeqRight}}

{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean SeqLeft}}
```

<!-- The `seqRight` function, which was introduced in the [section about alternatives and validation](alternative.md), is easiest to understand from the perspective of effects.
`{{#example_in Examples/FunctorApplicativeMonad.lean seqRightSugar}}`, which desugars to `{{#example_out Examples/FunctorApplicativeMonad.lean seqRightSugar}}`, can be understood as first executing `E1`, and then `E2`, resulting only in `E2`'s result.
Effects from `E1` may result in `E2` not being run, or being run multiple times.
Indeed, if `f` has a `Monad` instance, then `E1 *> E2` is equivalent to `do let _ ← E1; E2`, but `seqRight` can be used with types like `Validate` that are not monads. -->

[オルタナティブとバリデーションについての節](alternative.md) で紹介した `seqRight` 関数は作用の観点から理解するのが最も簡単です．`{{#example_in Examples/FunctorApplicativeMonad.lean seqRightSugar}}` は脱糖すると `{{#example_out Examples/FunctorApplicativeMonad.lean seqRightSugar}}` となります．これは最初に `E1` ，次に `E2` を実行し，`E2` の結果のみを返却するものとして理解できます．`E1` から発生する作用によって `E2` が実行されなかったり，複数回実行されることがあり得ます．実際，`f` が `Monad` インスタンスを持つ場合，`E1 *> E2` は `do let _ ← E1; E2` と等価ですが，`seqRight` は　`Validate` のようなモナドではない型でも使用できます．

<!-- Its cousin `seqLeft` is very similar, except the leftmost expression's value is returned.
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}` desugars to `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}`.
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftType}}` has type `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftType}}`, which is identical to that of `seqRight` except for the fact that it returns `f α`.
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}` can be understood as a program that first executes `E1`, and then `E2`, returning the original result for `E1`.
If `f` has a `Monad` instance, then `E1 <* E2` is equivalent to `do let x ← E1; _ ← E2; pure x`.
Generally speaking, `seqLeft` is useful for specifying extra conditions on a value in a validation or parser-like workflow without changing the value itself. -->

これのいとこである `seqLeft` は一番左の式の値を返すという点を除けば非常に似ています．`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}` は `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}` に脱糖されます．`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftType}}` は `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftType}}` 型を持ち，これが `f α` を返すことを除けば `seqRight` とそっくりです．`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}` は最初に `E1` を，次に `E2` を実行し，最初の `E1` の結果を返すプログラムだと理解できます．もし `f` が `Monad` インスタンスを持つ場合，`E1 <* E2` は `do let x ← E1; _ ← E2; pure x` と等価です．一般的に，`seqLeft` はバリデーションやパーサのような処理にて，値そのものを変化させずに値に対する追加の条件を指定するのに便利です．

<!-- The definition of `Applicative` extends all these classes, along with `Functor`: -->

`Applicative` の定義は `Functor` に加えてこれらすべてのクラスを継承しています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Applicative}}
```
<!-- A complete definition of `Applicative` requires only definitions for `pure` and `seq`.
This is because there are default definitions for all of the methods from `Functor`, `SeqLeft`, and `SeqRight`.
The `mapConst` method of `Functor` has its own default implementation in terms of `Functor.map`.
These default implementations should only be overridden with new functions that are behaviorally equivalent, but more efficient.
The default implementations should be seen as specifications for correctness as well as automatically-created code. -->

`Applicative` の完全な定義には `pure` と `seq` の定義だけが必要です．というのも `Functor` ，`SeqLeft` ，`SeqRight` のすべてのメソッドにデフォルトの定義があるからです．`Functor` の `mapConst` メソッドには `Functor.map` によるデフォルトの実装があります．これらのデフォルト実装をオーバーライドして良いのは，挙動が同じなのにより効率的な新しい関数がある場合のみとすべきです．デフォルト実装はその実装について，自動生成コードと同じ正しさを持つことへの仕様とみなすべきでしょう．

<!-- The default implementation for `seqLeft` is very compact.
Replacing some of the names with their syntactic sugar or their definitions can provide another view on it, so: -->

`seqLeft` のデフォルト実装はとてもコンパクトです．いくつかの名前を糖衣構文や定義に置き換えると，別の視点が見えてきます．以下のデフォルト実装：

```lean
{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldMapConstSeqLeft}}
```
<!-- becomes -->

は以下になります：

```lean
{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldMapConstSeqLeft}}
```
<!-- How should `(fun x _ => x) <$> a` be understood?
Here, `a` has type `f α`, and `f` is a functor.
If `f` is `List`, then `{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstList}}` evaluates to `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstList}}`.
If `f` is `Option`, then `{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstOption}}` evaluates to `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstOption}}`.
In each case, the values in the functor are replaced by functions that return the original value, ignoring their argument.
When combined with `seq`, this function discards the values from `seq`'s second argument. -->

`(fun x _ => x) <$> a` はどう解釈したらよいでしょうか？ここで，`a` は `f α` 型で，`f` は関手です．もし `f` が `List` の場合，`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstList}}` は `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstList}}` に評価されます．もし `f` が `Option` の場合，`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstOption}}` は `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstOption}}` に評価されます．どちらの場合も，関手の中の値は引数を無視してもとの値を返す関数に置き換えられます．これを `seq` と組み合わせると，この関数は `seq` の第2引数を破棄します．

<!-- The default implementation for `seqRight` is very similar, except `const` has an additional argument `id`.
This definition can be understood similarly, by first introducing some standard syntactic sugar and then replacing some names with their definitions: -->

`seqRight` のデフォルト実装は，`const` に追加の引数 `id` があることを除けば `seqLeft` に非常によく似ています．この定義も，最初に標準的な糖衣構文を導入し，次にいくつかの名前をその定義に置き換えることで同じように理解できます：

```lean
{{#example_eval Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldMapConstSeqRight}}
```
<!-- How should `(fun _ x => x) <$> a` be understood?
Once again, examples are useful.
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdList}}` is equivalent to `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdList}}`, and `{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdOption}}` is equivalent to `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdOption}}`.
In other words, `(fun _ x => x) <$> a` preserves the overall shape of `a`, but each value is replaced by the identity function.
From the perspective of effects, the side effects of `a` occur, but the values are thrown out when it is used with `seq`. -->

`(fun _ x => x) <$> a` はどう解釈したらよいでしょうか？ここでも例が役に立ちます．`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdList}}` は `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdList}}` に評価され，`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdOption}}` は `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdOption}}` に評価されます．言い換えると，`(fun _ x => x) <$> a` は `a` の全体的な形を保ちつつ，しかし各値を恒等関数に置き換えます．作用の観点からは，`a` の副作用は発生しますが，`seq` と一緒に使われることで，値が捨てられます．

<!-- ## Monad -->

## モナド

<!-- Just as the constituent operations of `Applicative` are split into their own type classes, `Bind` has its own class as well: -->

`Applicative` を構成する操作がそれぞれの型クラスに分かれているように，`Bind` も独自のクラスを持ちます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Bind}}
```
<!-- `Monad` extends `Applicative` with `Bind`: -->

`Monad` は `Bind` と共に `Applicative` を継承しています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Monad}}
```
<!-- Tracing the collection of inherited methods and default methods from the entire hierarchy shows that a `Monad` instance requires only implementations of `bind` and `pure`.
In other words, `Monad` instances automatically yield implementations of `seq`, `seqLeft`, `seqRight`, `map`, and `mapConst`.
From the perspective of API boundaries, any type with a `Monad` instance gets instances for `Bind`, `Pure`, `Seq`, `Functor`, `SeqLeft`, and `SeqRight`. -->

クラスの階層全体から継承したメソッドとデフォルトのメソッドを走査すると，`Monad` インスタンスに必要な実装は `bind` と `pure` だけであることがわかります．つまり，`Monad` インスタンスは自動的に `seq` ，`seqLeft` ，`seqRight` ，`map` ，`mapConst` の実装を生成します．APIの教会から見ると，`Monad` インスタンスを持つ型は `Bind` ，`Pure` ，`Seq` ，`Functor` ，`SeqLeft` ，`SeqRight` のインスタンスを持つことになります．

<!-- ## Exercises -->

## 演習問題

 <!-- 1. Understand the default implementations of `map`, `seq`, `seqLeft`, and `seqRight` in `Monad` by working through examples such as `Option` and `Except`. In other words, substitute their definitions for `bind` and `pure` into the default definitions, and simplify them to recover the versions `map`, `seq`, `seqLeft`, and `seqRight` that would be written by hand. -->
 1. `Option` や `Except` などを例にして，`Monad` の `map` ，`seq` ，`seqLeft` ，`seqRight` のデフォルト実装を解釈してください．つまり， `bind` と `pure` の定義をデフォルトの定義に置き換えて，`map` ，`seq` ，`seqLeft` ，`seqRight` を手で書けるように単純化してください．
 <!-- 2. On paper or in a text file, prove to yourself that the default implementations of `map` and `seq` satisfy the contracts for `Functor` and `Applicative`. In this argument, you're allowed to use the rules from the `Monad` contract as well as ordinary expression evaluation. -->
 2. `map` と `seq` のデフォルト実装が `Functor` と `Applicative` の約定を満たすことを手書き，もしくはテキストファイルで証明してください．この際には，通常の式の評価と同様に `Monad` の約定のルールを使用しても構いません．
