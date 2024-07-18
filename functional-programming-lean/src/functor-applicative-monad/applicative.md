<!--
# Applicative Functors
-->

# アプリカティブ関手

<!--
An _applicative functor_ is a functor that has two additional operations available: `pure` and `seq`.
`pure` is the same operator used in `Monad`, because `Monad` in fact inherits from `Applicative`.
`seq` is much like `map`: it allows a function to be used in order to transform the contents of a datatype.
However, with `seq`, the function is itself contained in the datatype: `{{#example_out Examples/FunctorApplicativeMonad.lean seqType}}`.
Having the function under the type `f` allows the `Applicative` instance to control how the function is applied, while `Functor.map` unconditionally applies a function.
The second argument has a type that begins with `Unit →` to allow the definition of `seq` to short-circuit in cases where the function will never be applied.
-->

**アプリカティブ関手** （applicative functor）とは `pure` と `seq` の2つの追加の操作を持つ関手のことです．`pure` は `Monad` でも同じ演算子が用いられています．それもそのはずで，実は `Monad` は `Applicative` を継承しているからです．`seq` は `map` とよく似た演算子です：これによって，ある関数をデータ型の中身を変換するために使用することができます．しかし，`seq` では，関数自体がデータ型に含まれています：`{{#example_out Examples/FunctorApplicativeMonad.lean seqType}}` ．`Functor.map` が無条件に関数適用するのに対して，関数を `f` 型の下に持つことで，`Applicative` インスタンスは関数の適用方法を制御することができます．2番目の引数には `Unit →` で始まる型を指定することで，関数が適用されない場合に `seq` の定義をショートカットできるようにしています．

<!--
The value of this short-circuiting behavior can be seen in the instance of `Applicative Option`:
-->

この短絡的なふるまいの真価は，`Applicative Option` のインスタンスで見ることができます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeOption}}
```
<!--
In this case, if there is no function for `seq` to apply, then there is no need to compute its argument, so `x` is never called.
The same consideration informs the instance of `Applicative` for `Except`:
-->

このケースにおいて，`seq` に適用する関数が無ければ，引数を計算する必要もないので `x` が呼ばれることはありません．同じことが `Except` の `Applicative` インスタンスにも当てはまります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeExcept}}
```
<!--
This short-circuiting behavior depends only on the `Option` or `Except` structures that _surround_ the function, rather than on the function itself.
-->

この短絡的な挙動は関数自体というよりも，関数を **取り囲む** `Option` や `Except` の構造にのみ依存します．

<!--
Monads can be seen as a way of capturing the notion of sequentially executing statements into a pure functional language.
The result of one statement can affect which further statements run.
This can be seen in the type of `bind`: `{{#example_out Examples/FunctorApplicativeMonad.lean bindType}}`.
The first statement's resulting value is an input into a function that computes the next statement to execute.
Successive uses of `bind` are like a sequence of statements in an imperative programming language, and `bind` is powerful enough to implement control structures like conditionals and loops.
-->

モナドは文を順次実行するという概念を純粋関数型言語に取り込むための方法とみなすことができます．ある文の結果はそれ以降の文の実行に影響を及ぼすことができます．これは `bind` の型：`{{#example_out Examples/FunctorApplicativeMonad.lean bindType}}` に見ることができます．最初の文の結果の値は，次に実行する文を計算する関数への入力となります．`bind` の連続した使用は命令型プログラミング言語における文の列のようなものです．`bind` は強力であり，条件分岐やループのような制御構造を実装することも十分可能です．

<!--
Following this analogy, `Applicative` captures function application in a language that has side effects.
The arguments to a function in languages like Kotlin or C# are evaluated from left to right.
Side effects performed by earlier arguments occur before those performed by later arguments.
A function is not powerful enough to implement custom short-circuiting operators that depend on the specific _value_ of an argument, however.
-->

このアナロジーに従うと，`Applicative` は副作用を持つ言語での関数適用を捉えたものと言えます．KotlinやC#のような言語では，関数の引数は左から右に評価されます．先に評価された引数によって実行される副作用は，その後の引数によって実行される副作用よりも先に発生します．しかし，関数は引数の特定の **値** に依存するカスタムの短絡演算子を実装するほど強力ではありません．

<!--
Typically, `seq` is not invoked directly.
Instead, the operator `<*>` is used.
This operator wraps its second argument in `fun () => ...`, simplifying the call site.
In other words, `{{#example_in Examples/FunctorApplicativeMonad.lean seqSugar}}` is syntactic sugar for `{{#example_out Examples/FunctorApplicativeMonad.lean seqSugar}}`.
-->

通常，`seq` は直接呼び出されません．その代わりに `<*>` という演算子が使われます．この演算子は第二引数を `fun () => ...` で包み，`seq` の呼び出しを単純化します．つまり，`{{#example_in Examples/FunctorApplicativeMonad.lean seqSugar}}` は `{{#example_out Examples/FunctorApplicativeMonad.lean seqSugar}}` の構文糖衣です．

<!--
The key feature that allows `seq` to be used with multiple arguments is that a multiple-argument Lean function is really a single-argument function that returns another function that's waiting for the rest of the arguments.
In other words, if the first argument to `seq` is awaiting multiple arguments, then the result of the `seq` will be awaiting the rest.
For example, `{{#example_in Examples/FunctorApplicativeMonad.lean somePlus}}` can have the type `{{#example_out Examples/FunctorApplicativeMonad.lean somePlus}}`.
Providing one argument, `{{#example_in Examples/FunctorApplicativeMonad.lean somePlusFour}}`, results in the type `{{#example_out Examples/FunctorApplicativeMonad.lean somePlusFour}}`.
This can itself be used with `seq`, so `{{#example_in Examples/FunctorApplicativeMonad.lean somePlusFourSeven}}` has the type `{{#example_out Examples/FunctorApplicativeMonad.lean somePlusFourSeven}}`.
-->

`seq` を複数の引数で使えるようにする重要な特徴は，Leanでの複数の引数を持つ関数が，実際には「残りの引数を待つ別の関数」を返す「単一の引数を持つ関数」であるということです．言い換えると，`seq` の最初の引数が複数の引数を持っている場合， `seq` の結果は2個目以降の残りの引数を待っていることになります．例えば，`{{#example_in Examples/FunctorApplicativeMonad.lean somePlus}}` は `{{#example_out Examples/FunctorApplicativeMonad.lean somePlus}}` 型を持ちます．ここで引数を一つ与えると，`{{#example_in Examples/FunctorApplicativeMonad.lean somePlusFour}}` となり，型は `{{#example_out Examples/FunctorApplicativeMonad.lean somePlusFour}}` となります．これ自身も `seq` と一緒に使えるため，`{{#example_in Examples/FunctorApplicativeMonad.lean somePlusFourSeven}}` は `{{#example_out Examples/FunctorApplicativeMonad.lean somePlusFourSeven}}` 型を持ちます．

<!--
Not every functor is applicative.
`Pair` is like the built-in product type `Prod`:
-->

すべての関手がアプリカティブにはなりません．`Pair` は組み込みの直積型 `Prod` のようなものです：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Pair}}
```
<!--
Like `Except`, `{{#example_in Examples/FunctorApplicativeMonad.lean PairType}}` has type `{{#example_out Examples/FunctorApplicativeMonad.lean PairType}}`.
This means that `Pair α` has type `Type → Type`, and a `Functor` instance is possible:
-->

`Except` と同じように，`{{#example_in Examples/FunctorApplicativeMonad.lean PairType}}` は `{{#example_out Examples/FunctorApplicativeMonad.lean PairType}}` 型を持ちます．これは `Pair α` が `Type → Type` 型を持ち，`Functor` インスタンスの定義が可能であることを意味します：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FunctorPair}}
```
<!--
This instance obeys the `Functor` contract.
-->

これは `Functor` の約定に従います．

<!--
The two properties to check are that `{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId 0}} = {{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId 2}}` and that `{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp1 0}} = {{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp2 0}}`.
The first property can be checked by just stepping through the evaluation of the left side, and noticing that it evaluates to the right side:
-->

チェックする2つの特性は `{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId 0}} = {{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId 2}}` と `{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp1 0}} = {{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp2 0}}` です．最初の特性は，左辺の評価を逐一評価し，それが右辺の形に評価されることが確認できればOKです：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId}}
```
<!--
The second can be checked by stepping through both sides, and noting that they yield the same result:
-->

2つ目は，両辺を逐一評価し，同じ結果が得られることを確認します：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp1}}

{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp2}}
```

<!--
Attempting to define an `Applicative` instance, however, does not work so well.
It will require a definition of `pure`:
-->

しかし `Applicative` インスタンスを定義しようとしてもうまくいきません．`pure` の定義が必要になります：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean Pairpure}}
```
```output error
{{#example_out Examples/FunctorApplicativeMonad.lean Pairpure}}
```
<!--
There is a value with type `β` in scope (namely `x`), and the error message from the underscore suggests that the next step is to use the constructor `Pair.mk`:
-->

スコープ内に `β` 型の値（つまり `x` ）があり，アンダースコアからのエラーメッセージは，次のステップとしてコンストラクタ `Pair.mk` を使用することを示唆しています：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean Pairpure2}}
```
```output error
{{#example_out Examples/FunctorApplicativeMonad.lean Pairpure2}}
```
<!--
Unfortunately, there is no `α` available.
Because `pure` would need to work for _all possible types_ α to define an instance of `Applicative (Pair α)`, this is impossible.
After all, a caller could choose `α` to be `Empty`, which has no values at all.
-->

残念ながら，`α` 型を利用する余地はありません．なぜなら，`pure` は `Applicative (Pair α)` のインスタンスを定義するために，αとして **可能なすべての型** に対して機能する必要がありますが，これは不可能です．極端な話，呼び出し元は `α` を値を全く持たない `Empty` にすることもあるかもしれないのです．

<!--
## A Non-Monadic Applicative
-->

## 非モナドなアプリカティブ関手

<!--
When validating user input to a form, it's generally considered to be best to provide many errors at once, rather than one error at a time.
This allows the user to have an overview of what is needed to please the computer, rather than feeling badgered as they correct the errors field by field.
-->

フォームへのユーザ入力のバリデーションにあたっては，いちいち1つずつエラーを報告するのではなく，まとめて一度にエラーを出すことが一般的に最善と考えられています．これによってユーザはフィールドごとにエラーをうんざりしながら修正することなく，コンピュータに受け入れられるために何が必要かを概観することができます．

<!--
Ideally, validating user input will be visible in the type of the function that's doing the validating.
It should return a datatype that is specific—checking that a text box contains a number should return an actual numeric type, for instance.
A validation routine could throw an exception when the input does not pass validation.
Exceptions have a major drawback, however: they terminate the program at the first error, making it impossible to accumulate a list of errors.
-->

理想的には，ユーザ入力のバリデーションは，それを行う関数の型に現れます．この関数はチェックが行われたことを体現するデータ型を返却すべきです．例えば，テキストボックスに数値が含まれているかどうかをチェックする関数は，実際の数値型を返すべきです．バリデーションのルーチンは，入力がバリデーションを通過しなかったことを例外を投げることで表現できます．しかし，例外には大きな欠点があります：最初のエラーでプログラムが終了してしまうため，エラーのリストを蓄積することができないのです．

<!--
On the other hand, the common design pattern of accumulating a list of errors and then failing when it is non-empty is also problematic.
A long nested sequences of `if` statements that validate each sub-section of the input data is hard to maintain, and it's easy to lose track of an error message or two.
Ideally, validation can be performed using an API that enables a new value to be returned yet automatically tracks and accumulates error messages.
-->

一方で，エラーのリストを蓄積し，リストが空でなければ失敗にする一般的な設計パターンにも問題があります．入力データの各部分をバリデーションする `if` 文の長くネストされた列はメンテナンス性に欠け，出てきたエラーメッセージから何個かのエラーをいともたやすく見落とすでしょう．理想的には，バリデーションは新しい値を返しつつエラーメッセージを自動的に追跡して蓄積するようなAPIを使って動作するものであってほしいでしょう．

<!--
An applicative functor called `Validate` provides one way to implement this style of API.
Like the `Except` monad, `Validate` allows a new value to be constructed that characterizes the validated data accurately.
Unlike `Except`, it allows multiple errors to be accumulated, without a risk of forgetting to check whether the list is empty.
-->

`Validate` というアプリカティブ関手はまさにそんなAPIを実装する1つの方法を提供します．`Except` モナドのように，`Validate` によってバリデーションされたデータを正確に特徴づける新しい値を構築することができます．しかし一方で `Except` と異なり，リストが空かどうかをチェックし忘れるリスク無しに複数のエラーを蓄積することができます．

<!--
### User Input
-->

### ユーザ入力

<!--
As an example of user input, take the following structure:
-->

ユーザ入力の例として，次のような構造を考えてみましょう：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean RawInput}}
```
<!--
The business logic to be implemented is the following:
-->

実装ビジネスロジックは以下の通りです：

 <!--
 1. The name may not be empty
-->
 1. 名前は空であってはならない
 <!--
 2. The birth year must be numeric and non-negative
-->
 2. 誕生年は非負の数値でなければならない
 <!--
 3. The birth year must be greater than 1900, and less than or equal to the year in which the form is validated
-->
 3. 誕生年は1900より大きく，かつバリデーションを行った年以下でなければならない
 
<!--
Representing these as a datatype will require a new feature, called _subtypes_.
With this tool in hand, a validation framework can be written that uses an applicative functor to track errors, and these rules can be implemented in the framework.
-->

これらをデータ型として表現するには，**部分型** と呼ばれる新しい機能が必要になります．このツールがあれば，バリデーションのフレームワークをエラーを追跡するアプリカティブ関手を使って書くことができ，バリデーションルールもこのフレームワークで実装することができます．

<!--
### Subtypes
-->

### 部分型

<!--
Representing these conditions is easiest with one additional Lean type, called `Subtype`:
-->

これらの条件を表現するにあたって最も簡単なのは，`Subtype` と呼ばれるLeanの型を1つ追加することです：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Subtype}}
```
<!--
This structure has two type parameters: an implicit parameter that is the type of data `α`, and an explicit parameter `p` that is a predicate over `α`.
A _predicate_ is a logical statement with a variable in it that can be replaced with a value to yield an actual statement, like the [parameter to `GetElem`](../type-classes/indexing.md#overloading-indexing) that describes what it means for an index to be in bounds for a lookup.
In the case of `Subtype`, the predicate slices out some subset of the values of `α` for which the predicate holds.
The structure's two fields are, respectively, a value from `α` and evidence that the value satisfies the predicate `p`.
Lean has special syntax for `Subtype`.
If `p` has type `α → Prop`, then the type `Subtype p` can also be written `{{#example_out Examples/FunctorApplicativeMonad.lean subtypeSugar}}`, or even `{{#example_out Examples/FunctorApplicativeMonad.lean subtypeSugar2}}` when the type can be inferred automatically.
-->

この構造体には2つの型パラメータがあります：1つはデータの型を表す暗黙パラメータ `α` で，もう1つは `α` に対する述語を表す明示的なパラメータ `p` です．**述語** （predicate）とは実際の文を生成するために値に置き換えることができる変数を持つ論理的な文であり，[`GetElem` のパラメータ](../type-classes/indexing.md#overloading-indexing) が検索に用いる添え字が範囲内であることの意味を記述するのはその一例です．`Subtype` の場合，述語は `α` の値の中で述語が成り立つ部分集合を切り出します．この構造体の2つのフィールドはそれぞれ `α` の値と，その値が述語 `p` を満たす根拠です．Leanは `Subtype` に対して特別な構文を持っています．`p` が `α → Prop` 型を持つ場合，`Subtype p` 型は `{{#example_out Examples/FunctorApplicativeMonad.lean subtypeSugar}}` と書くこともでき，型が自動的に推論される場合は `{{#example_out Examples/FunctorApplicativeMonad.lean subtypeSugar2}}` と書くことさえもできます．

<!--
[Representing positive numbers as inductive types](../type-classes/pos.md) is clear and easy to program with.
However, it has a key disadvantage.
While `Nat` and `Int` have the structure of ordinary inductive types from the perspective of Lean programs, the compiler treats them specially and uses fast arbitrary-precision number libraries to implement them.
This is not the case for additional user-defined types.
However, a subtype of `Nat` that restricts it to non-zero numbers allows the new type to use the efficient representation while still ruling out zero at compile time:
-->

[正の整数を帰納的な型として表現すること](../type-classes/pos.md) は明快で，プログラムしやすいです．しかし，これには重要な欠点があります．`Nat` と `Int` はLeanプログラムにおいては普通の帰納型の構造を持っていますが，コンパイラはこれらを特別に扱い，高速な任意精度の数値ライブラリを使用して実装します．これは後から追加されるユーサ定義型には当てはまりません．しかし，`Nat` の部分型を0以外の数に制限することで，コンパイル時に0を除きながら効率的な表現を使用することができます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FastPos}}
```

<!--
The smallest fast positive number is still one.
Now, instead of being a constructor of an inductive type, it's an instance of a structure that's constructed with angle brackets.
The first argument is the underlying `Nat`, and the second argument is the evidence that said `Nat` is greater than zero:
-->

最も小さい正の整数はもちろん1です．さて，これは帰納型のコンストラクタではなく，角括弧で構成される構造体のインスタンスです．第一引数は基礎となる `Nat` で，第二引数はその `Nat` が0より大きいという根拠です：

```leantac
{{#example_decl Examples/FunctorApplicativeMonad.lean one}}
```
<!--
The `OfNat` instance is very much like that for `Pos`, except it uses a short tactic proof to provide evidence that `n + 1 > 0`:
-->

`OfNat` のインスタンスは `Pos` のインスタンスと非常によく似ていますが，`n + 1 > 0` という根拠を提供するために短いタクティクによる証明を使う点が異なります：

```leantac
{{#example_decl Examples/FunctorApplicativeMonad.lean OfNatFastPos}}
```
<!--
The `simp_arith` tactic is a version of `simp` that takes additional arithmetic identities into account.
-->

`simp_arith` タクティクは `simp` に算術的な等式を追加したバージョンです．

<!--
Subtypes are a two-edged sword.
They allow efficient representation of validation rules, but they transfer the burden of maintaining these rules to the users of the library, who have to _prove_ that they are not violating important invariants.
Generally, it's a good idea to use them internally to a library, providing an API to users that automatically ensures that all invariants are satisfied, with any necessary proofs being internal to the library.
-->

部分型は諸刃の剣です．これによってバリデーションルールの効率的な表現を可能にしますが，これらのルールを維持する負担をライブラリのユーザに移し，ユーザは重要な不変量に違反していないことを **証明** しなければなりません．一般的には，ライブラリの内部で使用し，すべての不変量が満たされていることを自動的に保障するAPIをユーザに提供し，必要な証明はライブラリの内部で行うのが良いでしょう．

<!--
Checking whether a value of type `α` is in the subtype `{x : α // p x}` usually requires that the proposition `p x` be decidable.
The [section on equality and ordering classes](../type-classes/standard-classes.md#equality-and-ordering) describes how decidable propositions can be used with `if`.
When `if` is used with a decidable proposition, a name can be provided.
In the `then` branch, the name is bound to evidence that the proposition is true, and in the `else` branch, it is bound to evidence that the proposition is false.
This comes in handy when checking whether a given `Nat` is positive:
-->

ある `α` 型の値が `{x : α // p x}` の部分型に含まれるかどうかを調べるには，通常 `p x` という命題が決定可能である必要があります．[等式と順序クラスについての節](../type-classes/standard-classes.md#equality-and-ordering) では，決定可能な命題を `if` と一緒に使用する方法について説明しました．`if` を決定可能な命題で使用する場合，名前を指定することができます．`then` ブランチでは，その名前は命題が真であることの根拠に束縛され，`else` ブランチでは命題が偽であることの根拠に束縛されます．これは，与えられた `Nat` が正であるかどうかをチェックする時に便利です：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean NatFastPos}}
```
<!--
In the `then` branch, `h` is bound to evidence that `n > 0`, and this evidence can be used as the second argument to `Subtype`'s constructor.
-->

`then` ブランチでは，`h` は `n > 0` という根拠に束縛され，この根拠は `Subtype` のコンストラクタの第二引数として使うことができます．

<!--
### Validated Input
-->

### 入力のバリデーション

<!--
The validated user input is a structure that expresses the business logic using multiple techniques:
-->

バリデーションされたユーザ入力は，以下の技術を駆使してビジネスロジックを表現した構造体です：

 <!--
 * The structure type itself encodes the year in which it was checked for validity, so that `CheckedInput 2019` is not the same type as `CheckedInput 2020`
-->
 * 構造体の型自体はバリデーションチェックが行われた年をエンコード．そのため `CheckedInput 2019` は `CheckedInput 2020` と同じ型ではありません．
 <!--
 * The birth year is represented as a `Nat` rather than a `String`
-->
 * 誕生年は `String` ではなく `Nat` で表現
 <!--
 * Subtypes are used to constrain the allowed values in the name and birth year fields
-->
 * 名前と誕生年のフィールドの許容される値を制約するために部分型を使用

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean CheckedInput}}
```

<!--
An input validator should take the current year and a `RawInput` as arguments, returning either a checked input or at least one validation failure.
This is represented by the `Validate` type:
-->

入力のバリデータは現在の年と `RawInput` を引数に取り，チェック済みの入力か，少なくとも1つのバリデーション失敗のどちらかを返すべきです．これは `Validate` 型で表されます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Validate}}
```
<!--
It looks very much like `Except`.
The only difference is that the `error` constructor may contain more than one failure.
-->

見た目は `Except` によく似ています．唯一の違いは，`error` コンストラクタに複数の失敗を含めることができる点です．

<!--
Validate is a functor.
Mapping a function over it transforms any successful value that might be present, just as in the `Functor` instance for `Except`:
-->

Validateは関手です．これに関数をマッピングすることで，`Except` の `Functor` インスタンスと同じように，成功した値の場合はその値が変換されます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FunctorValidate}}
```

<!--
The `Applicative` instance for `Validate` has an important difference from the instance for `Except`: while the instance for `Except` terminates at the first error encountered, the instance for `Validate` is careful to accumulate all errors from _both_ the function and the argument branches:
-->

`Validate` の `Applicative` インスタンスには `Except` のインスタンスと重要な違いがあります：`Except` のインスタンスは最初に遭遇したエラーで終了するのに対して，`Validate` のインスタンスは関数と引数のブランチの **両方** からのすべてのエラーを蓄積することに注意を払っています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeValidate}}
```

<!--
Using `.errors` together with the constructor for `NonEmptyList` is a bit verbose.
Helpers like `reportError` make code more readable.
In this application, error reports will consist of field names paired with messages:
-->

`.errors` を `NonEmptyList` のコンストラクタと一緒に使うと少し冗長になります．`reportError` のような補助関数によって可読性が上がります．このアプリケーションでは，エラーのレポートはフィールド名とメッセージの組み合わせで構成されます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Field}}

{{#example_decl Examples/FunctorApplicativeMonad.lean reportError}}
```

<!--
The `Applicative` instance for `Validate` allows the checking procedures for each field to be written independently and then composed.
Checking a name consists of ensuring that a string is non-empty, then returning evidence of this fact in the form of a `Subtype`.
This uses the evidence-binding version of `if`:
-->

`Validate` の `Applicative` インスタンスでは，各フィールドのチェック手順を個別に記述し，組み合わせることができます．名前のチェックでは，文字列が空でないことを確認し，その根拠を `Subtype` という形で返します．これは `if` の根拠による束縛のバージョンを使用しています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkName}}
```
<!--
In the `then` branch, `h` is bound to evidence that `name = ""`, while it is bound to evidence that `¬name = ""` in the `else` branch.
-->

`then` ブランチでは，`h` は `name = ""` という根拠に束縛され，`else` ブランチでは `¬name = ""` という根拠に束縛されます．

<!--
It's certainly the case that some validation errors make other checks impossible.
For example, it makes no sense to check whether the birth year field is greater than 1900 if a confused user wrote the word `"syzygy"` instead of a number.
Checking the allowed range of the number is only meaningful after ensuring that the field in fact contains a number.
This can be expressed using the function `andThen`:
-->

バリデーションエラーによってはほかのチェックが不可能になってしまうケースも存在します．例えば，混乱したユーザが誕生年として数字の代わりに `"syzygy"` と書いた場合，誕生年のフィールドが1900年より大きいかどうかをチェックしても無意味です．数値の許容範囲をチェックすることは，そもそもフィールドに実際に数値が含まれていることを確認した後でのみ意味があります．これは関数 `andThen` を使って表現することができます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ValidateAndThen}}
```
<!--
While this function's type signature makes it suitable to be used as `bind` in a `Monad` instance, there are good reasons not to do so.
They are described [in the section that describes the `Applicative` contract](applicative-contract.md#additional-stipulations).
-->

この関数の型シグネチャは `Monad` インスタンスの `bind` として使用するのに適していますが，そうしないのにはれっきとした理由があります．それについては [`Applicative` の約定を説明する節](applicative-contract.md#additional-stipulations) で説明します．

<!--
To check that the birth year is a number, a built-in function called `String.toNat? : String → Option Nat` is useful.
It's most user-friendly to eliminate leading and trailing whitespace first using `String.trim`:
-->

誕生年が数字であることを確認するには，`String.toNat? : String → Option Nat` という組み込み関数が便利です．先に `String.trim` を使って先頭と末尾の空白を除去するととてもユーザフレンドリーになります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkYearIsNat}}
```
<!--
To check that the provided year is in the expected range, nested uses of the evidence-providing form of `if` are in order:
-->

提供された年が予想される範囲内であることをチェックするには，`if` の根拠提供の形式をネストして使用します：

```leantac
{{#example_decl Examples/FunctorApplicativeMonad.lean checkBirthYear}}
```

<!--
Finally, these three components can be combined using `seq`:
-->

最後に，これら3つの要素を `seq` を使って結合します：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkInput}}
```

<!--
Testing `checkInput` shows that it can indeed return multiple pieces of feedback:
-->

`checkInput` をテストしてみると，実際に複数のフィードバックを返してくれることがわかるでしょう：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkDavid1984}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkDavid1984}}
```
```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkBlank2045}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkBlank2045}}
```
```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkDavidSyzygy}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkDavidSyzygy}}
```


<!--
Form validation with `checkInput` illustrates a key advantage of `Applicative` over `Monad`.
Because `>>=` provides enough power to modify the rest of the program's execution based on the value from the first step, it _must_ receive a value from the first step to pass on.
If no value is received (e.g. because an error has occurred), then `>>=` cannot execute the rest of the program.
`Validate` demonstrates why it can be useful to run the rest of the program anyway: in cases where the earlier data isn't needed, running the rest of the program can yield useful information (in this case, more validation errors).
`Applicative`'s `<*>` may run both of its arguments before recombining the results.
Similarly, `>>=` forces sequential execution.
Each step must complete before the next may run.
This is generally useful, but it makes it impossible to have parallel execution of different threads that naturally emerges from the program's actual data dependencies.
A more powerful abstraction like `Monad` increases the flexibility that's available to the API consumer, but it decreases the flexibility that is available to the API implementor.
-->

`checkInput` による入力のバリデーションは，`Monad` に対する `Applicative` の重要な利点を示しています．なぜなら，`>>=` は最初のステップの値に基づいて残りのプログラムを変更するのに十分なパワーを提供するため，最初のステップから渡される値を **受け取らなくてはならないからです** ．もし値を受け取らなかった場合（例えばエラーが発生した場合），`>>=` はプログラムの残りの部分を実行することができません．`Validate` はどんな時でもプログラムの残りの部分を実行することが有用である理由を示しています：それ以前のデータが不要なケースでは，プログラムの残りの部分を実行することで有用な情報（この場合はより多くのバリデーションエラー）を得ることができます．`Applicative` の `<*>` は結果を再結合する前に両方の引数を実行することができます．同様に，`>>=` は逐次実行を強制します．各ステップは，次のステップを実行する前に完了しなければなりません．一般的にはこれは便利ですが，プログラムの実際のデータ依存関係から自然に生まれる異なるスレッドの並列実行を不可能にしてしまいます．`Monad` のようなより強力な抽象化によって，API利用者が利用できる柔軟性は向上しますが，API実装者が利用できる柔軟性は低下します．
