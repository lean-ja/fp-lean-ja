<!-- ## Example: Arithmetic in Monads -->

## 例：モナドにおける算術

<!-- Monads are a way of encoding programs with side effects into a language that does not have them.
It would be easy to read this as a sort of admission that pure functional programs are missing something important, requiring programmers to jump through hoops just to write a normal program.
However, while using the `Monad` API does impose a syntactic cost on a program, it brings two important benefits: -->

モナドは副作用のない言語で副作用のあるプログラムをエンコードする手段です．これをして純粋関数型言語で普通のプログラムを書くために大変面倒な手続きを踏まなければならないために，純粋関数型プログラムには重要なものが欠けていると認めているようなものだと考えるのは容易でしょう．しかし，`Monad` のAPIを使うことはプログラムに構文上のコストを課すことになる一方で2つの重要な利点をもたらします：

 <!-- 1. Programs must be honest about which effects they use in their types. A quick glance at a type signature describes _everything_ that the program can do, rather than just what it accepts and what it returns. -->
 1. プログラムはその型の中に，どの作用を使うか使うかについて表明しなければなりません．型シグネチャをざっと見ただけで，そのプログラムが何を受け入れ，何を返すかだけでなく，そのプログラムができることの **すべて** が記述されます．
 <!-- 2. Not every language provides the same effects. For example, only some language have exceptions. Other languages have unique, exotic effects, such as [Icon's searching over multiple values](https://www2.cs.arizona.edu/icon/) and Scheme or Ruby's continuations. Because monads can encode _any_ effect, programmers can choose which ones are the best fit for a given application, rather than being stuck with what the language developers provided. -->
 2. すべての言語で同じ作用が提供されているとは限りません．例えば，一部の言語だけが例外の機構を持ちます．他の言語には [Icon言語における複数値検索](https://www2.cs.arizona.edu/icon/) や，SchemeやRubyの継続などのようなユニークで独特な作用が存在します．モナドは **どんな** 作用でもエンコードできるため，プログラマは言語開発者が提供する作用に囚われることなく与えられたアプリケーションに最適な作用を選ぶことができます．

<!-- One example of a program that can make sense in a variety of monads is an evaluator for arithmetic expressions. -->

さまざまなモナドで意味をもつプログラムの一例として，算術式の評価器があります．

<!-- ### Arithmetic Expressions -->

### 算術式

<!-- An arithmetic expression is either a literal integer or a primitive binary operator applied to two expressions. The operators are addition, subtraction, multiplication, and division: -->

算術式は整数値のリテラルか2つの式に適用されるプリミティブな二項演算子です．演算子は加算，減算，乗算，除算からなります：

```lean
{{#example_decl Examples/Monads/Class.lean ExprArith}}
```
<!-- The expression `2 + 3` is represented: -->

`2 + 3` という式は以下のように表現されます：

```lean
{{#example_decl Examples/Monads/Class.lean twoPlusThree}}
```
<!-- and `14 / (45 - 5 * 9)` is represented: -->

また，`14 / (45 - 5 * 9)` は以下のように表現されます：

```lean
{{#example_decl Examples/Monads/Class.lean exampleArithExpr}}
```

<!-- ### Evaluating Expressions -->

### 式の評価

<!-- Because expressions include division, and division by zero is undefined, evaluation might fail.
One way to represent failure is to use `Option`: -->

式の中に除算が含まれ，かつ0による除算は未定義であるため，評価には失敗の可能性があります．失敗の表現の手段の1つとして，`Option` を使うことができます：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateOptionCommingled}}
```
<!-- This definition uses the `Monad Option` instance to propagate failures from evaluating both branches of a binary operator.
However, the function mixes two concerns: evaluating subexpressions and applying a binary operator to the results.
It can be improved by splitting it into two functions: -->

この定義では `Monad Option` のインスタンスを使用して，二項演算子の2つの分岐それぞれの評価による失敗を伝播します．しかし，この関数は部分式の評価と結果への二項演算子の適用という2つの関心事を混在させています．この状況は，この関数を2つの関数に分割することで改善することができます：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateOptionSplit}}
```

<!-- Running `{{#example_in Examples/Monads/Class.lean fourteenDivOption}}` yields `{{#example_out Examples/Monads/Class.lean fourteenDivOption}}`, as expected, but this is not a very useful error message.
Because the code was written using `>>=` rather than by explicitly handling the `none` constructor, only a small modification is required for it to provide an error message on failure: -->

`{{#example_in Examples/Monads/Class.lean fourteenDivOption}}` を実行すると期待通り `{{#example_out Examples/Monads/Class.lean fourteenDivOption}}` が出力されますが，これはあまり有用なエラーメッセージではありません．このコードは `none` コンストラクタを明示的に扱う代わりに `>>=` を使って書かれているため，失敗時にエラーメッセージを表示するために必要なのはわずかな修正だけです：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateExcept}}
```
<!-- The only difference is that the type signature mentions `Except String` instead of `Option`, and the failing case uses `Except.error` instead of `none`.
By making `evaluate` polymorphic over its monad and passing it `applyPrim` as an argument, a single evaluator becomes capable of both forms of error reporting: -->

変更点は，型シグネチャが `Option` ではなく `Except String` に言及していることと，失敗した場合に `none` ではなく `Except.error` を使用していることだけです．`evaluate` をモナドに対して多相にし，引数として `applyPrim` を渡すことで，1つの評価器で両方の形式でのエラー報告ができるようになります：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateM}}
```
<!-- Using it with `applyPrimOption` works just like the first version of `evaluate`: -->

これを `applyPrimOption` で使うとまさに `evaluate` の最初のバージョンと同じように動きます：

```lean
{{#example_in Examples/Monads/Class.lean evaluateMOption}}
```
```output info
{{#example_out Examples/Monads/Class.lean evaluateMOption}}
```
<!-- Similarly, using it with `applyPrimExcept` works just like the version with error messages: -->

同様に，`applyPrimExcept` を用いるとエラーメッセージのバージョンと同じように動作します：

```lean
{{#example_in Examples/Monads/Class.lean evaluateMExcept}}
```
```output info
{{#example_out Examples/Monads/Class.lean evaluateMExcept}}
```

<!-- The code can still be improved.
The functions `applyPrimOption` and `applyPrimExcept` differ only in their treatment of division, which can be extracted into another parameter to the evaluator: -->

このコードはさらに改善できます．関数 `applyPrimOption` と `applyPrimExcept` の違いは除算の扱いだけであるため，除算を評価器の別のパラメータとして抽出することができます：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateMRefactored}}
```

<!-- In this refactored code, the fact that the two code paths differ only in their treatment of failure has been made fully apparent. -->

このリファクタリングされたコードによって，2つのコードの実行の流れは失敗の扱いが異なるだけであるという事実がはっきりしました．

<!-- ### Further Effects -->

### さらなる作用

<!-- Failure and exceptions are not the only kinds of effects that can be interesting when working with an evaluator.
While division's only side effect is failure, adding other primitive operators to the expressions make it possible to express other effects. -->

評価器を扱うにあたって興味深いことは，失敗と例外だけにとどまりません．除算の唯一の副作用は失敗ですが，ほかのプリミティブな演算子を式に追加することで，ほかの作用を表現することが可能になります．

<!-- The first step is an additional refactoring, extracting division from the datatype of primitives: -->

追加のリファクタリングの最初のステップとして，プリミティブのデータ型から除算を抜き出します：

```lean
{{#example_decl Examples/Monads/Class.lean PrimCanFail}}
```
<!-- The name `CanFail` suggests that the effect introduced by division is potential failure. -->

`CanFail` という名前で，除算で導入される作用が潜在的な失敗であることを示唆します．

<!-- The second step is to broaden the scope of the division handler argument to `evaluateM` so that it can process any special operator: -->

第二のステップは，`evaluateM` に対する除算のハンドラの引数の範囲を広げて，どんな特殊演算子でも処理できるようにすることです：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateMMorePoly}}
```

<!-- #### No Effects -->

#### 作用なし

<!-- The type `Empty` has no constructors, and thus no values, like the `Nothing` type in Scala or Kotlin.
In Scala and Kotlin, `Nothing` can represent computations that never return a result, such as functions that crash the program, throw exceptions, or always fall into infinite loops.
An argument to a function or method of type `Nothing` indicates dead code, as there will never be a suitable argument value.
Lean doesn't support infinite loops and exceptions, but `Empty` is still useful as an indication to the type system that a function cannot be called.
Using the syntax `nomatch E` when `E` is an expression whose type has no constructors indicates to Lean that the current expression need not return a result, because it could never have been called.  -->

`Empty` 型はコンストラクタを持たないため，ScalaやKotlinの `Nothing` 型のように値を持ちません．ScalaとKotlinでは，`Nothing` 型はプログラムをクラッシュさせたり，例外を投げたり，常に無限ループに陥ったりする関数のような，決して結果を返さない計算の表現に用いることができます．関数やメソッドへの `Nothing` 型の引数は，適切な引数値が存在しないため，デッドコードを表します．Leanは無限ループや例外をサポートしていないものの，`Empty` は型システムに対して，関数を呼び出すことができないことを示すものとして有用です．`E` がコンストラクタを持たない型の式である時，`nomatch E` という構文を使うと，`E` を絶対に呼ぶことができないことを受けて，現在の式が結果を返す必要がないことをLeanに示します．

<!-- Using `Empty` as the parameter to `Prim` indicates that there are no additional cases beyond `Prim.plus`, `Prim.minus`, and `Prim.times`, because it is impossible to come up with a value of type `Empty` to place in the `Prim.other` constructor.
Because a function to apply an operator of type `Empty` to two integers can never be called, it doesn't need to return a result.
Thus, it can be used in _any_ monad: -->

`Prim` のパラメータとして `Empty` を使用することは，`Prim.plus` ，`Prim.minus` ，`Prim.times` 以外に追加のケースが無いことを意味します．2つの整数に `Empty` 型の演算子を適用する関数は決して呼び出すことができないため，この関数は結果を返す必要はありません．したがって，これは **任意の** モナドで使うことができます：

```lean
{{#example_decl Examples/Monads/Class.lean applyEmpty}}
```
<!-- This can be used together with `Id`, the identity monad, to evaluate expressions that have no effects whatsoever: -->

恒等モナドである `Id` と一緒に使うことで，何の作用も持たない式を評価することができます：

```lean
{{#example_in Examples/Monads/Class.lean evalId}}
```
```output info
{{#example_out Examples/Monads/Class.lean evalId}}
```

<!-- #### Nondeterministic Search -->

#### 非決定論探索

<!-- Instead of simply failing when encountering division by zero, it would also be sensible to backtrack and try a different input.
Given the right monad, the very same `evaluateM` can perform a nondeterministic search for a _set_ of answers that do not result in failure.
This requires, in addition to division, some means of specifying a choice of results.
One way to do this is to add a function `choose` to the language of expressions that instructs the evaluator to pick either of its arguments while searching for non-failing results. -->

0による除算に遭遇した際に単純に失敗させる代わりに，その計算を諦めて別の入力を試すのも賢い選択でしょう．適切なモナドがあれば，同じ `evaluateM` を使って失敗しない答えの **集合** を非決定論的に探索することができます．これには除算に加えて，結果の選択肢を指定する手段が必要になります．これを行う1つの方法は，失敗しない結果を探索している間に，評価者に引数のどちらかを選ぶように指示する関数 `choose` を式の言語に追加することです．

<!-- The result of the evaluator is now a multiset of values, rather than a single value.
The rules for evaluation into a multiset are: -->

これで評価器の結果は単一の値ではなく値の多重集合になります．多重集合への評価のルールは以下の通りです：

 <!-- * Constants \\( n \\) evaluate to singleton sets \\( \{n\} \\). -->
 * 定数 \\( n \\) は単集合 \\( \{n\} \\) に評価されます．
 <!-- * Arithmetic operators other than division are called on each pair from the Cartesian product of the operators, so \\( X + Y \\) evaluates to \\( \\{ x + y \\mid x ∈ X, y ∈ Y \\} \\). -->
 * 除算以外の算術演算子はオペランド[^1]のデカルト積から各ペアに対して呼び出されます．したがって \\( X + Y \\) は \\( \\{ x + y \\mid x ∈ X, y ∈ Y \\} \\) に評価されます．
 <!-- * Division \\( X / Y \\) evaluates to \\( \\{ x / y \\mid x ∈ X, y ∈ Y, y ≠ 0\\} \\). In other words, all \\( 0 \\) values in \\( Y \\)  are thrown out. -->
 * 除算 \\( X / Y \\) は \\( \\{ x / y \\mid x ∈ X, y ∈ Y, y ≠ 0\\} \\) に評価されます．つまり， \\( Y \\) に含まれるすべての \\( 0 \\) の値は捨てられます．
 <!-- * A choice \\( \\mathrm{choose}(x, y) \\) evaluates to \\( \\{ x, y \\} \\). -->
 * 選択 \\( \\mathrm{choose}(x, y) \\) は \\( \\{ x, y \\} \\) に評価されます．

<!-- For example, \\( 1 + \\mathrm{choose}(2, 5) \\) evaluates to \\( \\{ 3, 6 \\} \\), \\(1 + 2 / 0 \\) evaluates to \\( \\{\\} \\), and \\( 90 / (\\mathrm{choose}(-5, 5) + 5) \\) evaluates to \\( \\{ 9 \\} \\).
Using multisets instead of true sets simplifies the code by removing the need to check for uniqueness of elements. -->

例えば， \\( 1 + \\mathrm{choose}(2, 5) \\) は \\( \\{ 3, 6 \\} \\) に， \\(1 + 2 / 0 \\) は \\( \\{\\} \\) に， \\( 90 / (\\mathrm{choose}(-5, 5) + 5) \\) は \\( \\{ 9 \\} \\) にそれぞれ評価されます．集合ではなく多重集合を使うことで，要素の一意性チェックの必要性を除いてコードを単純化します．

<!-- A monad that represents this non-deterministic effect must be able to represent a situation in which there are no answers, and a situation in which there is at least one answer together with any remaining answers: -->

この非決定論的な作用を表現するモナドは答えが無い状況と，少なくとも1つの答えとそれ以外の答えがある状況を表現できなければなりません．

```lean
{{#example_decl Examples/Monads/Many.lean Many}}
```
<!-- This datatype looks very much like `List`.
The difference is that where `cons` stores the rest of the list, `more` stores a function that should compute the next value on demand.
This means that a consumer of `Many` can stop the search when some number of results have been found. -->

このデータ型は `List` にとってもそっくりです．異なる点として，リストでは `cons` で後続のリストを格納していたのに対して，`more` は必要に応じて後続の値を計算する関数を格納しています．つまり，`Many` の利用者は，ある程度の数の結果が見つかった時点で検索を停止することができます．

<!-- A single result is represented by a `more` constructor that returns no further results: -->

単一の結果はそれ以上の結果を返さない `more` コンストラクタで表されます：

```lean
{{#example_decl Examples/Monads/Many.lean one}}
```
<!-- The union of two multisets of results can be computed by checking whether the first multiset is empty.
If so, the second multiset is the union.
If not, the union consists of the first element of the first multiset followed by the union of the rest of the first multiset with the second multiset: -->

計算結果の2つの多重集合の和は1つ目の多重集合が空かどうかをチェックすることによって計算できます．もし空であれば，2番目の多重集合が和の結果になります．そうでない場合，和は1つ目の多重集合の最初の要素に，1つ目の残りと2つ目の多重集合の和を続けたもので構成されます：

```lean
{{#example_decl Examples/Monads/Many.lean union}}
```

<!-- It can be convenient to start a search process with a list of values.
`Many.fromList` converts a list into a multiset of results: -->

探索プロセスをリストから始めると便利です．`Many.fromList` はリストを結果の多重集合に変換します：

```lean
{{#example_decl Examples/Monads/Many.lean fromList}}
```
<!-- Similarly, once a search has been specified, it can be convenient to extract either a number of values, or all the values: -->

同様に，検索の実行結果に対して，そこから何個かの値の抽出，もしくはすべて抽出できると便利です：

```lean
{{#example_decl Examples/Monads/Many.lean take}}
```

<!-- A `Monad Many` instance requires a `bind` operator.
In a nondeterministic search, sequencing two operations consists of taking all possibilities from the first step and running the rest of the program on each of them, taking the union of the results.
In other words, if the first step returns three possible answers, the second step needs to be tried for all three.
Because the second step can return any number of answers for each input, taking their union represents the entire search space. -->

`Monad Many` インスタンスは `bind` 演算子を必要とします．非決定論的検索において，2つの演算の紐づけは，まず1つ目のステップからすべての可能性を取り出し，それらすべてについて後続のプログラムを走らせて，得られた結果の和を取ることで構成されます．言い換えると，例えば1つ目のステップで3つの可能性が返された場合，2つ目のステップではそれらすべてを試す必要があります．2つ目のステップでは各入力について任意の数の答えが返されるため，それらの和を取ることで探索空間全体を表現することになります．

```lean
{{#example_decl Examples/Monads/Many.lean bind}}
```

<!-- `Many.one` and `Many.bind` obey the monad contract.
To check that `Many.bind (Many.one v) f` is the same as `f v`, start by evaluating the expression as far as possible: -->

`Many.one` と `Many.bind` はモナドの約定に従います．`Many.bind (Many.one v) f` が `f v` と同じであることをチェックするには，式として取りうるものを可能な限り評価することから始めます：

```lean
{{#example_eval Examples/Monads/Many.lean bindLeft}}
```
<!-- The empty multiset is a right identity of `union`, so the answer is equivalent to `f v`.
To check that `Many.bind v Many.one` is the same as `v`, consider that `bind` takes the union of applying `Many.one` to each element of `v`.
In other words, if `v` has the form `{v1, v2, v3, ..., vn}`, then `Many.bind v Many.one` is `{v1} ∪ {v2} ∪ {v3} ∪ ... ∪ {vn}`, which is `{v1, v2, v3, ..., vn}`. -->

空の多重集合は `union` に対して右単位であるので，答えは `f v` に等しくなります．`Many.bind v Many.one` が `v` と等しいことをチェックするには，`bind` が `v` の各要素に `Many.one` を適用した和を取ることを考えてみましょう．言い換えると，もし `v` が `{v1, v2, v3, ..., vn}` の形式である場合，`Many.bind v Many.one` は `{v1} ∪ {v2} ∪ {v3} ∪ ... ∪ {vn}` であり，これは `{v1, v2, v3, ..., vn}` です．

<!-- Finally, to check that `Many.bind` is associative, check that `Many.bind (Many.bind bind v f) g` is the same as `Many.bind v (fun x => Many.bind (f x) g)`.
If `v` has the form `{v1, v2, v3, ..., vn}`, then: -->

最後に，`Many.bind` の結合性のチェックは，`Many.bind (Many.bind bind v f) g` が `Many.bind v (fun x => Many.bind (f x) g)` と同じであることを確かめましょう．もし `v` が `{v1, v2, v3, ..., vn}` の形式である場合，まず以下のようになり：

```lean
Many.bind v f
===>
f v1 ∪ f v2 ∪ f v3 ∪ ... ∪ f vn
```
<!-- which means that -->

これから以下が導かれ，

```lean
Many.bind (Many.bind bind v f) g
===>
Many.bind (f v1) g ∪
Many.bind (f v2) g ∪
Many.bind (f v3) g ∪
... ∪
Many.bind (f vn) g
```
<!-- Similarly, -->

また，同様に，

```lean
Many.bind v (fun x => Many.bind (f x) g)
===>
(fun x => Many.bind (f x) g) v1 ∪
(fun x => Many.bind (f x) g) v2 ∪
(fun x => Many.bind (f x) g) v3 ∪
... ∪
(fun x => Many.bind (f x) g) vn
===>
Many.bind (f v1) g ∪
Many.bind (f v2) g ∪
Many.bind (f v3) g ∪
... ∪
Many.bind (f vn) g
```
<!-- Thus, both sides are equal, so `Many.bind` is associative. -->

したがって，両辺は等しくなるため，`Many.bind` は結合的となります．

<!-- The resulting monad instance is: -->

結果としてモナドのインスタンスは次のようになります：

```lean
{{#example_decl Examples/Monads/Many.lean MonadMany}}
```
<!-- An example search using this monad finds all the combinations of numbers in a list that add to 15: -->

このモナドを使って，試しにリスト中の足し合わせたら15になるすべての組み合わせを計算してみます：

```lean
{{#example_decl Examples/Monads/Many.lean addsTo}}
```
<!-- The search process is recursive over the list.
The empty list is a successful search when the goal is `0`; otherwise, it fails.
When the list is non-empty, there are two possibilities: either the head of the list is greater than the goal, in which case it cannot participate in any successful searches, or it is not, in which case it can.
If the head of the list is _not_ a candidate, then the search proceeds to the tail of the list.
If the head is a candidate, then there are two possibilities to be combined with `Many.union`: either the solutions found contain the head, or they do not.
The solutions that do not contain the head are found with a recursive call on the tail, while the solutions that do contain it result from subtracting the head from the goal, and then attaching the head to the solutions that result from the recursive call. -->

探索プロセスはリストに対して再帰的に行われます．空のリストに対しては，ゴールが `0` であれば探索を成功とし，そうでなければ失敗とします．リストが空でない場合，2つの可能性があります：リストの先頭がゴールより大きい場合とそうでない場合であり，前者の場合はどんな成功した探索にも寄与することができず，対して後者は可能性があります．もしリストの先頭が候補 **ではない** 場合，探索は後続のリストに対して実行されます．もし先頭要素が候補である場合，`Many.union` で組み合わされる2つの可能性があります：すなわち解が先頭要素を含む場合とそうでない場合です．先頭を含まない解は後続のリストに対して再帰することで得られ，先頭を含む解はゴールから先頭の値を引き，それと後続のリストに対する再帰呼び出し結果にもとの先頭要素を付け加えることで得られます．

<!-- Returning to the arithmetic evaluator that produces multisets of results, the `both` and `neither` operators can be written as follows: -->

結果の多重集合を生成する算術の評価器に戻ると，`both` と `neither` 演算子は以下のように書くことができます：

```lean
{{#example_decl Examples/Monads/Class.lean NeedsSearch}}
```
<!-- Using these operators, the earlier examples can be evaluated: -->

これらの演算子を用いて，先ほどの例を評価することができます：

```lean
{{#example_decl Examples/Monads/Class.lean opening}}

{{#example_in Examples/Monads/Class.lean searchA}}
```
```output info
{{#example_out Examples/Monads/Class.lean searchA}}
```
```lean
{{#example_in Examples/Monads/Class.lean searchB}}
```
```output info
{{#example_out Examples/Monads/Class.lean searchB}}
```
```lean
{{#example_in Examples/Monads/Class.lean searchC}}
```
```output info
{{#example_out Examples/Monads/Class.lean searchC}}
```

<!-- #### Custom Environments -->

#### カスタムの環境

<!-- The evaluator can be made user-extensible by allowing strings to be used as operators, and then providing a mapping from strings to a function that implements them.
For example, users could extend the evaluator with a remainder operator or with one that returns the maximum of its two arguments.
The mapping from function names to function implementations is called an _environment_. -->

評価器は文字列を演算子として使えるようにし，文字列から演算子の実処理へのマッピングを提供することで，評価器をユーザが拡張できるようにすることができます．例えば，ユーザは剰余演算子や2つの引数に対して大きい方を返すものなどを評価器に拡張することができます．関数名から関数の実装へのマッピングは **環境** （environment）と呼ばれます．

<!-- The environments needs to be passed in each recursive call.
Initially, it might seem that `evaluateM` needs an extra argument to hold the environment, and that this argument should be passed to each recursive invocation.
However, passing an argument like this is another form of monad, so an appropriate `Monad` instance allows the evaluator to be used unchanged. -->

環境は各再帰呼び出しで渡される必要があります．知らない人からすると，`evaluateM` は環境を保持するために余分な引数を必要とし，この引数は呼び出しのたびに渡される必要があると思われるかもしれません．しかし，このように引数を渡すこともモナドの一種であるため，適切な `Monad` インスタンスを使用することで，評価器を変更せずに使用することができます．

<!-- Using functions as a monad is typically called a _reader_ monad.
When evaluating expressions in the reader monad, the following rules are used: -->

関数をモナドとして使用することは一般的に **reader** モナドと呼ばれます．readerモナドで式を評価する場合，以下のルールが用いられます：

 <!-- * Constants \\( n \\) evaluate to constant functions \\( λ e . n \\), -->
 * 定数 \\( n \\) は定数関数 \\( λ e . n \\) に評価され，
 <!-- * Arithmetic operators evaluate to functions that pass their arguments on, so \\( f + g \\) evaluates to \\( λ e . f(e) + g(e) \\), and -->
 * 算術演算子は引数をオペランドに渡す関数に評価され，したがって \\( f + g \\) が \\( λ e . f(e) + g(e) \\) に評価され，
 <!-- * Custom operators evaluate to the result of applying the custom operator to the arguments, so \\( f \\ \\mathrm{OP}\\ g \\) evaluates to -->
 * カスタム演算子はカスタム演算子を引数に適用した結果に評価され，したがって \\( f \\ \\mathrm{OP}\\ g \\) は未知の演算子に対してのフォールバックとして \\( 0 \\) を提供するようにして，以下のように評価されます．
   \\[
     λ e .
     \\begin{cases}
     h(f(e), g(e)) & \\mathrm{if}\\ e\\ \\mathrm{contains}\\ (\\mathrm{OP}, h) \\\\
     0 & \\mathrm{otherwise}
     \\end{cases}
   \\]
   <!-- with \\( 0 \\) serving as a fallback in case an unknown operator is applied. -->

<!-- To define the reader monad in Lean, the first step is to define the `Reader` type and the effect that allows users to get ahold of the environment: -->

Leanでreaderモナドを定義するには，まず `Reader` 型クラスとユーザが環境を把握するための作用を定義します：

```lean
{{#example_decl Examples/Monads/Class.lean Reader}}
```
<!-- By convention, the Greek letter `ρ`, which is pronounced "rho", is used for environments. -->

慣例として，環境はギリシャ文字 `ρ` （発音は「rho」）が用いられます．

<!-- The fact that constants in arithmetic expressions evaluate to constant functions suggests that the appropriate definition of `pure` for `Reader` is a a constant function: -->

算術式の定数が定数関数に評価されるという事実から `Reader` に対する `pure` の適切な定義が定数関数であることが示唆されます：

```lean
{{#example_decl Examples/Monads/Class.lean ReaderPure}}
```

<!-- On the other hand, `bind` is a bit tricker.
Its type is `{{#example_out Examples/Monads/Class.lean readerBindType}}`.
This type can be easier to understand by expanding the definitions of `Reader`, which yields `{{#example_out Examples/Monads/Class.lean readerBindTypeEval}}`.
It should take an environment-accepting function as its first argument, while the second argument should transform the result of the environment-accepting function into yet another environment-accepting function.
The result of combining these is itself a function, waiting for an environment. -->

他方，`bind` は少々トリッキーです．この関数の型は `{{#example_out Examples/Monads/Class.lean readerBindType}}` になります．この型は `Reader` の定義を展開した `{{#example_out Examples/Monads/Class.lean readerBindTypeEval}}` によって理解しやすくなります．これは第一引数として環境を受け入れる関数を受け取り，第二引数は環境を環境を受け入れる関数の結果を，さらに別の環境を受け入れる関数に変換しなければなりません．これらを組み合わせた結果自体が環境を待つような関数となります．

<!-- It's possible to use Lean interactively to get help writing this function.
The first step is to write down the arguments and return type, being very explicit in order to get as much help as possible, with an underscore for the definition's body: -->

Leanを対話的に使うことで，この関数を書く手助けを得ることができます．最初のステップは，できるだけ多くのヒントを得るために，引数と戻り値の型をアンダースコア付きで明示的に書くことです：

```lean
{{#example_in Examples/Monads/Class.lean readerbind0}}
```
<!-- Lean provides a message that describes which variables are available in scope, and the type that's expected for the result.
The `⊢` symbol, called a _turnstile_ due to its resemblance to subway entrances, separates the local variables from the desired type, which is `ρ → β` in this message: -->

Leanはスコープ内でどの変数が使用可能か，そしてその結果に期待される型を記述したメッセージを提示します．地下鉄の入り口に似ていることから **ターンスタイル** と呼ばれる記号 `⊢` は，このメッセージでは `ρ → β` であるようなローカル変数と期待される型を分離しています：

```output error
{{#example_out Examples/Monads/Class.lean readerbind0}}
```

<!-- Because the return type is a function, a good first step is to wrap a `fun` around the underscore: -->

戻り値の型が関数であるため，最初のステップとしてアンダースコアの前に `fun` を付けるのが良いでしょう：

```lean
{{#example_in Examples/Monads/Class.lean readerbind1}}
```
<!-- The resulting message now shows the function's argument as a local variable: -->

この結果で得られるメッセージには，関数の引数がローカル変数として表示されるようになります：

```output error
{{#example_out Examples/Monads/Class.lean readerbind1}}
```

<!-- The only thing in the context that can produce a `β` is `next`, and it will require two arguments to do so.
Each argument can itself be an underscore: -->

コンテキスト内で `β` を生成できるのは `next` のみですが，これを得るには引数が2つ必要です．それぞれの引数にもアンダースコアを設定してみます：

```lean
{{#example_in Examples/Monads/Class.lean readerbind2a}}
```
<!-- The two underscores have the following respective messages associated with them: -->

2つのアンダースコアは以下に示している，それぞれに関連したメッセージを持ちます：

```output error
{{#example_out Examples/Monads/Class.lean readerbind2a}}
```
```output error
{{#example_out Examples/Monads/Class.lean readerbind2b}}
```

<!-- Attacking the first underscore, only one thing in the context can produce an `α`, namely `result`: -->

1つ目のアンダースコアに取り掛かると，コンテキストで `α` を生み出すことができるのはただ1つだけ，すなわち `result` だけです：

```lean
{{#example_in Examples/Monads/Class.lean readerbind3}}
```
<!-- Now, both underscores have the same error: -->

ここで両方のアンダースコアは同じエラーになります：

```output error
{{#example_out Examples/Monads/Class.lean readerbind3}}
```
<!-- Happily, both underscores can be replaced by `env`, yielding: -->

嬉しいことに，どちらのアンダースコアも `env` で置き換えることができ，以下を得ます：

```lean
{{#example_decl Examples/Monads/Class.lean readerbind4}}
```

<!-- The final version can be obtained by undoing the expansion of `Reader` and cleaning up the explicit details: -->

最終的なバージョンは `Reader` の展開を元に戻し，明示的な詳細を掃除することで得られます：

```lean
{{#example_decl Examples/Monads/Class.lean Readerbind}}
```

<!-- It's not always possible to write correct functions by simply "following the types", and it carries the risk of not understanding the resulting program.
However, it can also be easier to understand a program that has been written than one that has not, and the process of filling in the underscores can bring insights.
In this case, `Reader.bind` works just like `bind` for `Id`, except it accepts an additional argument that it then passes down to its arguments, and this intuition can help in understanding how it works. -->

このような「型に従う」だけで正しい関数が書けるとは限らず，出来上がったプログラムを理解できないリスクもあります．しかし，書いていないプログラムよりも出来上がったプログラムの方が理解しやすいこともあり得ますし，アンダースコアを埋めていく過程で気づきを得ることもあります．今回の場合，`Reader.bind` は `Id` に対する `bind` と同じように動作しますが，追加の引数を受け取り，それを引数に渡すという点が異なり，この直観はこれがどう動くかということへの理解を助けます．

<!-- `Reader.pure`, which generates constant functions, and `Reader.bind` obey the monad contract.
To check that `Reader.bind (Reader.pure v) f` is the same as `f v`, it's enough to replace definitions until the last step: -->

定数関数を生成する `Reader.pure` と `Reader.bind` はモナドの約定に従います．`Reader.bind (Reader.pure v) f` が `f v` に等しいことを確認するには，最後のステップまで定義を置き換えれば十分です：

```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad1}}
```
<!-- For every function `f`, `fun x => f x` is the same as `f`, so the first part of the contract is satisfied.
To check that `Reader.bind r Reader.pure` is the same as `r`, a similar technique works: -->

すべての関数 `f` について，`fun x => f x` は `f` と同じであるため，約定の最初の部分が満たされます．`Reader.bind r Reader.pure` が `r` と同じであることを確認する場合にも同じテクニックが有効です：

```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad2}}
```
<!-- Because reader actions `r` are themselves functions, this is the same as `r`.
To check associativity, the same thing can be done for both `{{#example_eval Examples/Monads/Class.lean ReaderMonad3a 0}}` and `{{#example_eval Examples/Monads/Class.lean ReaderMonad3b 0}}`: -->

readerのアクション `r` はそれ自体が関数であるため，これは `r` と等しくなります．結合性をチェックするには，`{{#example_eval Examples/Monads/Class.lean ReaderMonad3a 0}}` と `{{#example_eval Examples/Monads/Class.lean ReaderMonad3b 0}}` の両方について同じことを行います：

```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad3a}}
```

```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad3b}}
```

<!-- Thus, a `Monad (Reader ρ)` instance is justified: -->

以上より，`Monad (Reader ρ)` インスタンスが成立します：

```lean
{{#example_decl Examples/Monads/Class.lean MonadReaderInst}}
```

<!-- The custom environments that will be passed to the expression evaluator can be represented as lists of pairs: -->

式評価器に渡されるカスタム環境はペアのリストとして表すことができます：

```lean
{{#example_decl Examples/Monads/Class.lean Env}}
```
<!-- For instance, `exampleEnv` contains maximum and modulus functions: -->

例えば，`exampleEnv` は最大値と剰余関数を保持します：

```lean
{{#example_decl Examples/Monads/Class.lean exampleEnv}}
```

<!-- Lean already has a function `List.lookup` that finds the value associated with a key in a list of pairs, so `applyPrimReader` needs only check whether the custom function is present in the environment. It returns `0` if the function is unknown: -->

Leanには，ペアのリストのキーに関連付けられた値を見つける関数 `List.lookup` がすでに存在するため，`applyPrimReader` はカスタム関数が環境に存在するかどうかをチェックするだけでよくなります．関数が不明な場合は `0` を返します：

```lean
{{#example_decl Examples/Monads/Class.lean applyPrimReader}}
```

<!-- Using `evaluateM` with `applyPrimReader` and an expression results in a function that expects an environment.
Luckily, `exampleEnv` is available: -->

`applyPrimReader` と式と一緒に `evaluateM` を使うと，環境が必要な関数になります．幸運なことに，`exampleEnv` が利用できます：

```lean
{{#example_in Examples/Monads/Class.lean readerEval}}
```
```output info
{{#example_out Examples/Monads/Class.lean readerEval}}
```

<!-- Like `Many`, `Reader` is an example of an effect that is difficult to encode in most languages, but type classes and monads make it just as convenient as any other effect.
The dynamic or special variables found in Common Lisp, Clojure, and Emacs Lisp can be used like `Reader`.
Similarly, Scheme and Racket's parameter objects are an effect that exactly correspond to `Reader`.
The Kotlin idiom of context objects can solve a similar problem, but they are fundamentally a means of passing function arguments automatically, so this idiom is more like the encoding as a reader monad than it is an effect in the language. -->

`Many` と同様に，`Reader` はほとんどの言語でエンコードすることが難しい作用の例ですが，型クラスとモナドによって他の作用と同じような利便性が提供されます．Common LispやClojure，Emacs Lispにある動的変数や特殊変数は `Reader` のように使うことができます．同様に，SchemeやRacketのパラメータオブジェクトは `Reader` に対応する作用です．Kotlinのイディオムであるコンテキストオブジェクトは似たような問題を解決することができますが，基本的には関数の引数を自動的に渡すための手段であるため，このイディオムは言語内の作用というよりはreaderモナドとしてエンコードされたものです．

<!-- ## Exercises -->

## 演習問題

<!-- ### Checking Contracts -->

### 約定のチェック

<!-- Check the monad contract for `State σ` and `Except ε`. -->

`State σ` と `Except ε` のモナドの約定をチェックしてください．


<!-- ### Readers with Failure -->

### 失敗付きのreader

<!-- Adapt the reader monad example so that it can also indicate failure when the custom operator is not defined, rather than just returning zero.
In other words, given these definitions: -->

readerモナドの例を修正して，カスタム演算子が定義されていない場合に単に0を返すのではなく，失敗を示すことができるようにしてください．つまり，以下の定義に対して：

```lean
{{#example_decl Examples/Monads/Class.lean ReaderFail}}
```
<!-- do the following: -->

以下を行ってください：

 <!-- 1. Write suitable `pure` and `bind` functions -->
 1. 適切な `pure` と `bind` 関数を書いてください．
 <!-- 2. Check that these functions satisfy the `Monad` contract -->
 2. これらの関数が `Monad` の約定を満たすことをチェックしてください．
 <!-- 3. Write `Monad` instances for `ReaderOption` and `ReaderExcept` -->
 3. `ReaderOption` と `ReaderExcept` に対しての `Monad` インスタンスを書いてください．
 <!-- 4. Define suitable `applyPrim` operators and test them with `evaluateM` on some example expressions -->
 4. 適切な `applyPrim` 演算子を定義し，いくつかの式に対して `evaluateM` を使ってテストしてください．

<!-- ### A Tracing Evaluator -->

### 評価器の追跡

<!-- The `WithLog` type can be used with the evaluator to add optional tracing of some operations.
In particular, the type `ToTrace` can serve as a signal to trace a given operator: -->

`WithLog` 型を評価器と一緒に用いることで，いくつかの演算の追跡をオプションで追加することができます．特に，`ToTrace` 型は与えられた演算子を追跡するためのシグナルを提供します：

```lean
{{#example_decl Examples/Monads/Class.lean ToTrace}}
```
<!-- For the tracing evaluator, expressions should have type `Expr (Prim (ToTrace (Prim Empty)))`.
This says that the operators in the expression consist of addition, subtraction, and multiplication, augmented with traced versions of each. The innermost argument is `Empty` to signal that there are no further special operators inside of `trace`, only the three basic ones. -->

追跡付きの評価器では，式は `Expr (Prim (ToTrace (Prim Empty)))` 型でなければなりません．これは，式の演算子が加算と減算，乗算で構成され，それぞれを追跡したもので補強していることを示します．一番内側の `Empty` によって，`trace` の内部には特別な演算子は無く，基本的な3つの演算子だけであることを示しています．

<!-- Do the following: -->

以下を行ってください：

 <!-- 1. Implement a `Monad (WithLog logged)` instance -->
 1. `Monad (WithLog logged)` インスタンスを実装してください．
 <!-- 2. Write an `{{#example_in Examples/Monads/Class.lean applyTracedType}}` function to apply traced operators to their arguments, logging both the operator and the arguments, with type `{{#example_out Examples/Monads/Class.lean applyTracedType}}` -->
 2. 追跡される演算子をその引数に適用し，演算子とその引数をログ出力するための `{{#example_in Examples/Monads/Class.lean applyTracedType}}` 関数を書いてください．型は `{{#example_out Examples/Monads/Class.lean applyTracedType}}` です．
 
<!-- If the exercise has been completed correctly, then -->

もし演習問題を正しく解けたのなら，

```lean
{{#example_in Examples/Monads/Class.lean evalTraced}}
```
<!-- should result in -->

は以下の結果になるはずです．

```output info
{{#example_out Examples/Monads/Class.lean evalTraced}}
```
 
 <!-- Hint: values of type `Prim Empty` will appear in the resulting log. In order to display them as a result of `#eval`, the following instances are required: -->
 ヒント：`Prim Empty` 型の値は結果のログに表示されます．それらを `#eval` の結果として表示するには，以下のインスタンスが必要です：
 ```lean
 {{#example_decl Examples/Monads/Class.lean ReprInstances}}
 ```

[^1]: 原文は`operators`だがオペランドのミス？