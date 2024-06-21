<!-- # Monads -->

# モナド

<!-- In C# and Kotlin, the `?.` operator is a way to look up a property or call a method on a potentially-null value.
If the receiver is `null`, the whole expression is null.
Otherwise, the underlying non-`null` value receives the call.
Uses of `?.` can be chained, in which case the first `null` result terminates the chain of lookups.
Chaining null-checks like this is much more convenient than writing and maintaining deeply nested `if`s. -->

C#とKotlinでは，`?.` 演算子でnullの可能性がある値に対してプロパティを検索したりメソッドを呼び出したりすることができます．レシーバが `null` の場合，式全体がnullになります．それ以外の場合，もとの `null` でない値が呼び出しを受けます．`?.` は連鎖して使用することができ，この場合一番初めに現れる `null` の結果によって一連の処理が終了します．このようにnullチェックの連鎖させ方は，ネストの深い `if` 文を書いたりメンテしたりするよりもずっと便利です．

<!-- Similarly, exceptions are significantly more convenient than manually checking and propagating error codes.
At the same time, logging is easiest to accomplish by having a dedicated logging framework, rather than having each function return both its log results and its return value.
Chained null checks and exceptions typically require language designers to anticipate this use case, while logging frameworks typically make use of side effects to decouple code that logs from the accumulation of the logs. -->

同様に，例外はエラーコードを手作業でチェックしたり伝播させたりするよりもはるかに便利です．また，ロギングは各関数がログの結果と戻り値の両方を返すのではなく，専用のロギングフレームワークを持つことで最も簡単に実現できます．連鎖したnullチェックと例外は，通常，言語設計者側にこのユースケースを予測する必要がある一方で，ロギングフレームワークでは通常，ログの蓄積からロギングを行うコードを切り離すために副作用を利用します．

<!-- All these features and more can be implemented in library code as instances of a common API called `Monad`.
Lean provides dedicated syntax that makes this API convenient to use, but can also get in the way of understanding what is going on behind the scenes.
This chapter begins with the nitty-gritty presentation of manually nesting null checks, and builds from there to the convenient, general API.
Please suspend your disbelief in the meantime. -->

これらの機能やその他はすべて，`Monad` と呼ばれる共通のAPIのインスタンスとしてライブラリ化することができます．LeanはこのAPIを使うための専用の構文を提供しますが，裏で何が起こっているのかを理解するのを阻害してもいます．この章では，手作業によるnullチェックのネストに関する細かい説明から始まり，そこから便利で一般的なAPIへと発展していきます．信じがたい読者においては，ぜひその疑念を抱いたまま読み進めてください．

<!-- ## Checking for `none`: Don't Repeat Yourself -->

## `none` チェック：DRY原則

<!-- In Lean, pattern matching can be used to chain checks for null.
Getting the first entry from a list can just use the optional indexing notation: -->

Leanにおいて，nullチェックをパターンマッチで連鎖させることができます．リストの最初の要素の取得は，ただインデックス記法を使うだけで可能です：

```lean
{{#example_decl Examples/Monads.lean first}}
```
<!-- The result must be an `Option` because empty lists have no first entry.
Extracting the first and third entries requires a check that each is not `none`: -->

空のリストは最初の要素を持たないため，この結果は `Option` 型となります．最初と3番目の要素を取り出すには，それぞれ `none` ではないことをチェックする必要があります：

```lean
{{#example_decl Examples/Monads.lean firstThird}}
```
<!-- Similarly, extracting the first, third, and fifth entries requires more checks that the values are not `none`: -->

同様に，1番目と3番目，5番目の要素の取得ではさらに `none` でないことのチェックが増えます：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifth}}
```
<!-- And adding the seventh entry to this sequence begins to become quite unmanageable: -->

そしてこの流れで7番目の要素の取得を追加するといよいよ手に負えなくなってきます：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventh}}
```


<!-- The fundamental problem with this code is that it addresses two concerns: extracting the numbers and checking that all of them are present, but the second concern is addressed by copying and pasting the code that handles the `none` case.
It is often good style to lift a repetitive segment into a helper function: -->

このコードでは，数字の抽出と数字がすべて存在していることのチェックという2つの関心事に対処しようとしています．しかし，2つ目の関心事には `none` のケースを処理するコードをコピペすることで対処しています．これがこのコードの根本的な問題です．プログラミングにおいて，一般的に繰り返し処理をヘルパー関数として抽出することは良い習慣です：

```lean
{{#example_decl Examples/Monads.lean andThenOption}}
```
<!-- This helper, which is used similarly to `?.` in C# and Kotlin, takes care of propagating `none` values.
It takes two arguments: an optional value and a function to apply when the value is not `none`.
If the first argument is `none`, then the helper returns `none`.
If the first argument is not `none`, then the function is applied to the contents of the `some` constructor. -->

このヘルパーはC#やKotlinの `?.` と同じように使用され，`none` 値の伝播を行います．この関数は2つの引数を取ります：オプション値と，値が `none` でない場合に適用する関数です．第一引数が `none` の場合，このヘルパーは `none` を返します．第一引数が `none` でない場合，第二引数の関数が `some` コンストラクタの中身に適用されます．

<!-- Now, `firstThird` can be rewritten to use `andThen` instead of pattern matching: -->

これで，`firstThird` はパターンマッチの代わりに `andThen` を使って書き換えることができます：

```lean
{{#example_decl Examples/Monads.lean firstThirdandThen}}
```
<!-- In Lean, functions don't need to be enclosed in parentheses when passed as arguments.
The following equivalent definition uses more parentheses and indents the bodies of functions: -->

Leanで関数に引数を渡す際には括弧を付ける必要はありません．以下は括弧と関数の本体にインデントを付けた同等の定義です：

```lean
{{#example_decl Examples/Monads.lean firstThirdandThenExpl}}
```
<!-- The `andThen` helper provides a sort of "pipeline" through which values flow, and the version with the somewhat unusual indentation is more suggestive of this fact.
Improving the syntax used to write `andThen` can make these computations even easier to understand. -->

`andThen` ヘルパーは値が流れる「パイプライン」のようなものを提供します．この事実は上記のやや変わったインデントバージョンでよりはっきりします．`andThen` を記述する構文を改善することで，これらの計算をさらに理解しやすくすることができます．

<!-- ### Infix Operators -->

### 中置演算子

<!-- In Lean, infix operators can be declared using the `infix`, `infixl`, and `infixr` commands, which create (respectively) non-associative, left-associative, and right-associative operators.
When used multiple times in a row, a _left associative_ operator stacks up the opening parentheses on the left side of the expression.
The addition operator `+` is left associative, so `{{#example_in Examples/Monads.lean plusFixity}}` is equivalent to `{{#example_out Examples/Monads.lean plusFixity}}`.
The exponentiation operator `^` is right associative, so `{{#example_in Examples/Monads.lean powFixity}}` is equivalent to `{{#example_out Examples/Monads.lean powFixity}}`.
Comparison operators such as `<` are non-associative, so `x < y < z` is a syntax error and requires manual parentheses. -->

Leanでは，`infix` ，`infixl` ，`infixr` コマンドを使って，それぞれ非結合，左結合，右結合演算子を宣言することができます．**左結合** 演算子が連続して複数回使用されると，式の左側に括弧が積みあがっていきます．加算演算子 `+` は左結合であるため，`{{#example_in Examples/Monads.lean plusFixity}}` は `{{#example_out Examples/Monads.lean plusFixity}}` と同等です．指数演算子 `^` は右結合であるため，`{{#example_in Examples/Monads.lean powFixity}}` は `{{#example_out Examples/Monads.lean powFixity}}` と同等です．`<` などの比較演算子は非結合演算子であるため，`x < y < z` は構文エラーであり，手作業で括弧を入れる必要があります．

<!-- The following declaration makes `andThen` into an infix operator: -->

以下の宣言によって `andThen` は中置演算子となります：

```lean
{{#example_decl Examples/Monads.lean andThenOptArr}}
```
<!-- The number following the colon declares the _precedence_ of the new infix operator.
In ordinary mathematical notation, `{{#example_in Examples/Monads.lean plusTimesPrec}}` is equivalent to `{{#example_out Examples/Monads.lean plusTimesPrec}}` even though both `+` and `*` are left associative.
In Lean, `+` has precedence 65 and `*` has precedence 70.
Higher-precedence operators are applied before lower-precedence operators.
According to the declaration of `~~>`, both `+` and `*` have higher precedence, and thus apply first.
Typically, figuring out the most convenient precedences for a group of operators requires some experimentation and a large collection of examples. -->

コロンの後ろの数字は新しい中置演算子の **優先順位** を宣言しています．通常の数学表記において `+` と `*` はどちらも左結合ですが，`{{#example_in Examples/Monads.lean plusTimesPrec}}` は `{{#example_out Examples/Monads.lean plusTimesPrec}}` と等価です．Leanでは，`+` の優先順位は65で，`*` の優先順位は70です．優先順位の高い演算子は低い演算子よりも前に適用されます．`~~>` の宣言から，`+` と `*` はどちらもこの演算子よりも優先順位が高いため，`+` と `*` が先に適用されます．一般的に，演算子の集まりに対して最も便利な優先順位を定義するには，いろんなパターンを何度も試して経験値をためる必要があります．

<!-- Following the new infix operator is a double arrow `=>`, which specifies the named function to be used for the infix operator.
Lean's standard library uses this feature to define `+` and `*` as infix operators that point at `HAdd.hAdd` and `HMul.hMul`, respectively, allowing type classes to be used to overload the infix operators.
Here, however, `andThen` is just an ordinary function. -->

新しい中置演算子の後ろに続くのは二重矢印 `=>` で，これは中置演算子に使用する名前付き関数を指定します．Leanの標準ライブラリはこの機能を使って `+` と `*` をそれぞれ `HAdd.hAdd` と `HMul.hMul` を指し示す中置演算子として定義しており，型クラスを使ってこれらの中置演算子をオーバーロードできるようにしています．しかし，ここでは `andThen` は普通の関数です．

<!-- Having defined an infix operator for `andThen`, `firstThird` can be rewritten in a way that brings the "pipeline" feeling of `none`-checks front and center: -->

`andThen` のために中置演算子を定義することで，`firstThird` は `none` チェックの「パイプライン」感を前面に押し出した形で書き直すことができます：

```lean
{{#example_decl Examples/Monads.lean firstThirdInfix}}
```
<!-- This style is much more concise when writing larger functions: -->

このスタイルの方は大きな関数の記述をより簡潔にします：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventInfix}}
```

<!-- ## Propagating Error Messages -->

## エラーメッセージの伝播

<!-- Pure functional languages such as Lean have no built-in exception mechanism for error handling, because throwing or catching an exception is outside of the step-by-step evaluation model for expressions.
However, functional programs certainly need to handle errors.
In the case of `firstThirdFifthSeventh`, it is likely relevant for a user to know just how long the list was and where the lookup failed. -->

Leanのような純粋関数型言語には，エラー処理のための例外アルゴリズムが組み込まれていません．なぜなら，例外をスローしたりキャッチしたりすることは式のステップバイステップな評価モデルの範囲外であるからです．しかし，関数型プログラムでもエラー処理は必要です．`firstThirdFifthSeventh` の場合，リストがどれくらいの長さで，どこで検索に失敗したかを知ることはユーザにとって重要でしょう．

<!-- This is typically accomplished by defining a datatype that can be either an error or a result, and translating functions with exceptions into functions that return this datatype: -->

この実現方法として，エラーと計算結果のどちらにもなりうるデータ型を定義し，例外を持つ関数をこのデータ型を返す関数に変換することが通例です：

```lean
{{#example_decl Examples/Monads.lean Except}}
```
<!-- The type variable `ε` stands for the type of errors that can be produced by the function.
Callers are expected to handle both errors and successes, which makes the type variable `ε` play a role that is a bit like that of a list of checked exceptions in Java. -->

型変数 `ε` は関数が発生させる可能性のあるエラーの型を表します．呼び出し元はエラーと成功の両方を処理することが期待されているため，型変数 `ε` はJavaのチェックされた例外のリストのような役割を果たします．

<!-- Similarly to `Option`, `Except` can be used to indicate a failure to find an entry in a list.
In this case, the error type is a `String`: -->

`Option` と同様に，`Except` はリスト内のエントリが見つからなかった場合に使用することができます．この場合のエラーの型は `String` です：

```lean
{{#example_decl Examples/Monads.lean getExcept}}
```
<!-- Looking up an in-bounds value yields an `Except.ok`: -->

範囲内の値の検索は `Except.ok` を出力します：

```lean
{{#example_decl Examples/Monads.lean ediblePlants}}

{{#example_in Examples/Monads.lean success}}
```
```output info
{{#example_out Examples/Monads.lean success}}
```
<!-- Looking up an out-of-bounds value yields an `Except.error`: -->

範囲外の値の検索は `Except.error` を出力します：

```lean
{{#example_in Examples/Monads.lean failure}}
```
```output info
{{#example_out Examples/Monads.lean failure}}
```

<!-- A single list lookup can conveniently return a value or an error: -->

1回のリストの検索はこれで結果かエラーの返却を便利にします：

```lean
{{#example_decl Examples/Monads.lean firstExcept}}
```
<!-- However, performing two list lookups requires handling potential failures: -->

しかし，2回の検索となると潜在的なエラーの対応が要求されます：

```lean
{{#example_decl Examples/Monads.lean firstThirdExcept}}
```
<!-- Adding another list lookup to the function requires still more error handling: -->

リストの検索を追加すると，必要なエラー処理も増えます：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthExcept}}
```
<!-- And one more list lookup begins to become quite unmanageable: -->

ここにまたリスト検索を追加するとかなり手に負えなくなってきます：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventhExcept}}
```

<!-- Once again, a common pattern can be factored out into a helper.
Each step through the function checks for an error, and only proceeds with the rest of the computation if the result was a success.
A new version of `andThen` can be defined for `Except`: -->

繰り返しになりますが，よくあるパターンをヘルパーに因数分解することができます．関数の各ステップでエラーチェックが行われ，成功した場合のみ後続の計算が行われます．`Except` のために `andThen` の新しいバージョンを以下のように定義することができます：

```lean
{{#example_decl Examples/Monads.lean andThenExcept}}
```
<!-- Just as with `Option`, this version of `andThen` allows a more concise definition of `firstThird`: -->

`Option` とまったく同じように，このバージョンの `andThen` は `firstThird` のより簡潔な定義を提供します：

```lean
{{#example_decl Examples/Monads.lean firstThirdAndThenExcept}}
```

<!-- In both the `Option` and `Except` case, there are two repeating patterns: there is the checking of intermediate results at each step, which has been factored out into `andThen`, and there is the final successful result, which is `some` or `Except.ok`, respectively.
For the sake of convenience, success can be factored out into a helper called `ok`: -->

`Option` と `Except` のどちらの場合も，2つのパターンが繰り返されています：1つは各ステップでの中間結果のチェックで，これは `andThen` にくくりだされています．もう1つは最終的な成功結果であり，それぞれ `some` と `Except.ok` で表されます．便宜上，成功は `ok` というヘルパーにくくりだすことができます：

```lean
{{#example_decl Examples/Monads.lean okExcept}}
```
<!-- Similarly, failure can be factored out into a helper called `fail`: -->

同じように，失敗も `fail` というヘルパーにくくりだすことが可能です：

```lean
{{#example_decl Examples/Monads.lean failExcept}}
```
<!-- Using `ok` and `fail` makes `get` a little more readable: -->

`ok` と `fail` を使うことで，`get` はもうちょっと読みやすくなります：

```lean
{{#example_decl Examples/Monads.lean getExceptEffects}}
```


<!-- After adding the infix declaration for `andThen`, `firstThird` can be just as concise as the version that returns an `Option`: -->

`andThen` のための中置演算子を追加することで，`firstThird` は `Option` を返すバージョンと同じくらい簡潔になります：

```lean
{{#example_decl Examples/Monads.lean andThenExceptInfix}}

{{#example_decl Examples/Monads.lean firstThirdInfixExcept}}
```
<!-- The technique scales similarly to larger functions: -->

このテクニックはより大きい関数に対しても同様にスケールアップします：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventInfixExcept}}
```

<!-- ## Logging -->

## ロギング

<!-- A number is even if dividing it by 2 leaves no remainder: -->

ある数値が偶であるとは，2で割った時に余りがないことです：

```lean
{{#example_decl Examples/Monads.lean isEven}}
```
<!-- The function `sumAndFindEvens` computes the sum of a list while remembering the even numbers encountered along the way: -->

関数 `sumAndFindEvens` は総和を計算しつつ，リストを進みながら偶数のみを記憶します：

```lean
{{#example_decl Examples/Monads.lean sumAndFindEvensDirect}}
```
<!-- This function is a simplified example of a common pattern.
Many programs need to traverse a data structure once, while both computing a main result and accumulating some kind of tertiary extra result.
One example of this is logging: a program that is an `IO` action can always log to a file on disk, but because the disk is outside of the mathematical world of Lean functions, it becomes much more difficult to prove things about logs based on `IO`.
Another example is a function that computes the sum of all the nodes in a tree with an inorder traversal, while simultaneously recording each nodes visited: -->

この関数はプログラミングにおけるよくあるパターンのシンプルな例です．多くのプログラムはデータ構造を一度走査し，メインの結果を計算しながら脇役的な結果を蓄積する必要があります．この例の1つがロギングです：`IO` アクションであるプログラムは常にログをディスク上のファイルに記録することができますが，ディスクはLeanの関数の数学的世界の外側にあるため，`IO` に基づくログについて証明することは非常に難しくなります．別の例として，木に含まれるすべてのノードの総和を通りがけ順で計算しながら，同時に通過した各ノードを記録するような関数があります：

```lean
{{#example_decl Examples/Monads.lean inorderSum}}
```

<!-- Both `sumAndFindEvens` and `inorderSum` have a common repetitive structure.
Each step of computation returns a pair that consists of a list of data that have been saved along with the primary result.
The lists are then appended, and the primary result is computed and paired with the appended lists.
The common structure becomes more apparent with a small rewrite of `sumAndFindEvens` that more cleanly separates the concerns of saving even numbers and computing the sum: -->

`sumAndFindEvens` と `inorderSum` のどちらも共通の繰り返し構造を持ちます．計算の各ステップはメインの結果とそれに沿って貯めたデータのリストからなるペアを返却します．その後これらのリストは結合され，計算されたメインの結果とペアにされます．`sumAndFindEvens` を少し書き換えるだけで偶数の保存と合計の計算をよりきれいに分けた共通の構造がよりはっきりします：

```lean
{{#example_decl Examples/Monads.lean sumAndFindEvensDirectish}}
```

<!-- For the sake of clarity, a pair that consists of an accumulated result together with a value can be given its own name: -->

この明確さのおかげで，値と蓄積された結果からなるペアには固有の名前を与えることできます：

```lean
{{#example_decl Examples/Monads.lean WithLog}}
```
<!-- Similarly, the process of saving a list of accumulated results while passing a value on to the next step of a computation can be factored out into a helper, once again named `andThen`: -->

同様に，計算の次のステップへ値を渡す際に蓄積された結果のリストを保存するプロセスは，再び `andThen` という名前のヘルパーにくくりだすことができます：

```lean
{{#example_decl Examples/Monads.lean andThenWithLog}}
```
<!-- In the case of errors, `ok` represents an operation that always succeeds.
Here, however, it is an operation that simply returns a value without logging anything: -->

結果がエラーである場合，`ok` は常に成功する操作を表します．しかし，ここではログに何も記録せずにそのまま値を返す操作です：

```lean
{{#example_decl Examples/Monads.lean okWithLog}}
```
<!-- Just as `Except` provides `fail` as a possibility, `WithLog` should allow items to be added to a log.
This has no interesting return value associated with it, so it returns `Unit`: -->

`Except` が処理の不確実さとして `fail` を提供するように，`WithLog` はアイテムをログに追加できるようにします．この操作には特に意味のある戻り値がないため，`Unit` を返却します：

```lean
{{#example_decl Examples/Monads.lean save}}
```

<!-- `WithLog`, `andThen`, `ok`, and `save` can be used to separate the logging concern from the summing concern in both programs: -->

`WithLog` と `andThen` ，`ok` ，`save` によってロギングという関心事から総和の関心事の分離を以下のプログラムによって実現できます：

```lean
{{#example_decl Examples/Monads.lean sumAndFindEvensAndThen}}

{{#example_decl Examples/Monads.lean inorderSumAndThen}}
```
<!-- And, once again, the infix operator helps put focus on the correct steps: -->

ここでもまた，中置演算子が正しいステップに焦点を合わせるのに役立ちます：

```lean
{{#example_decl Examples/Monads.lean infixAndThenLog}}

{{#example_decl Examples/Monads.lean withInfixLogging}}
```

<!-- ## Numbering Tree Nodes -->

## 木構造のノードへの採番

<!-- An _inorder numbering_ of a tree associates each data point in the tree with the step it would be visited at in an inorder traversal of the tree.
For example, consider `aTree`: -->

木の **通り順** （inorder numbering）は木の中の各データポイントに，その木を通り順に訪れた際の各ステップを割り当てます．例として以下の木 `aTree` を考えてみましょう：

```lean
{{#example_decl Examples/Monads.lean aTree}}
```
<!-- Its inorder numbering is: -->

これの通り順は以下のようになります：

```output info
{{#example_out Examples/Monads.lean numberATree}}
```

<!-- Trees are most naturally processed with recursive functions, but the usual pattern of recursion on trees makes it difficult to compute an inorder numbering.
This is because the highest number assigned anywhere in the left subtree is used to determine the numbering of a node's data value, and then again to determine the starting point for numbering the right subtree.
In an imperative language, this issue can be worked around by using a mutable variable that contains the next number to be assigned.
The following Python program computes an inorder numbering using a mutable variable: -->

木は再帰関数で処理することが最も自然ですが，木における通常の再帰パターンでは通り順の採番を計算することは難しいです．これは，木の左側の部分木のどこかに割り当てられる最大の番号がノードのデータ値の採番を決定することに使われ，さらに右の部分木の採番の開始位置を決定することに使われるからです．命令型言語では，この問題は次に割り当てる番号を格納する可変変数を使用することで回避できます．次のPythonプログラムでは，可変変数を使って通り順の採番を計算します：

```python
{{#include ../../examples/inorder_python/inordernumbering.py:code}}
```
<!-- The numbering of the Python equivalent of `aTree` is: -->

`aTree` に相当するPythonの採番対象は以下のようになり：

```python
{{#include ../../examples/inorder_python/inordernumbering.py:a_tree}}
```
<!-- and its numbering is: -->

これの採番結果は以下になります：

```
>>> {{#command {inorder_python} {inorderpy} {python inordernumbering.py} {number(a_tree)}}}
{{#command_out {inorderpy} {python inordernumbering.py} {inorder_python/expected} }}
```


<!-- Even though Lean does not have mutable variables, a workaround exists.
From the point of view of the rest of the world, the mutable variable can be thought of as having two relevant aspects: its value when the function is called, and its value when the function returns.
In other words, a function that uses a mutable variable can be seen as a function that takes the mutable variable's starting value as an argument, returning a pair of the variable's final value and the function's result.
This final value can then be passed as an argument to the next step. -->

Leanには可変変数が無いにもかかわらず，回避策が存在します．違う視点から見てみると，可変変数は2つの関連した側面を持っていると考えることができます：すなわち，関数が呼び出された時の値とその関数が終了した時点での値です．言い換えれば，可変変数を使う関数は，可変変数の初期値を引数として取り，その変数の最終結果と関数の結果のペアを返す関数とみなすことができます．この最終値は次のステップの引数として渡すことができます．

<!-- Just as the Python example uses an outer function that establishes a mutable variable and an inner helper function that changes the variable, a Lean version of the function uses an outer function that provides the variable's starting value and explicitly returns the function's result along with an inner helper function that threads the variable's value while computing the numbered tree: -->

Pythonの例で可変変数を宣言している外部関数と，その変数を更新する内部ヘルパー関数が使われているように，この関数は，変数の初期値を提供し，採番された木の計算中に変数の値をスレッドする内部ヘルパー関数の結果を明示的に返す外部関数としてLean上で実装できます：

```lean
{{#example_decl Examples/Monads.lean numberDirect}}
```
<!-- This code, like the `none`-propagating `Option` code, the `error`-propagating `Except` code, and the log-accumulating `WithLog` code, commingles two concerns: propagating the value of the counter, and actually traversing the tree to find the result.
Just as in those cases, an `andThen` helper can be defined to propagate state from one step of a computation to another.
The first step is to give a name to the pattern of taking an input state as an argument and returning an output state together with a value: -->

このコードは `none` を伝播する `Option` コードと `error` を伝播する `Except` コード，ログを蓄積する `WithLog` コードと同じように2つの関心事が混在しています：カウンタの値の伝播と，実際に木を走査して結果を見つけることです．これらの場合と同じように，`andThen` ヘルパーを定義することで，計算のあるステップから別のステップに状態を伝播させることができます．このためにまず初めに行うことは，引数として入力状態を受け取り，値と一緒に出力状態を返すパターンに名前を付けることです：

```lean
{{#example_decl Examples/Monads.lean State}}
```

<!-- In the case of `State`, `ok` is a function that returns the input state unchanged, along with the provided value: -->

`State` の場合，`ok` は入力状態を変更せずに，与えられた値と一緒に返却する関数です：

```lean
{{#example_decl Examples/Monads.lean okState}}
```
<!-- When working with a mutable variable, there are two fundamental operations: reading the value and replacing it with a new one.
Reading the current value is accomplished with a function that places the input state unmodified into the output state, and also places it into the value field: -->

可変変数を扱う場合，値の読み取りと新しい値での更新との2つの基本的な演算があります．現在の値の読み取りは，入力状態を変更せずに出力状態に置き，さらにその値を値フィールドに置く関数として実装できます：

```lean
{{#example_decl Examples/Monads.lean get}}
```
<!-- Writing a new value consists of ignoring the input state, and placing the provided new value into the output state: -->

新しい値の書き込みは，入力状態を無視し，与えられた値を出力状態に設定することで構成されます：

```lean
{{#example_decl Examples/Monads.lean set}}
```
<!-- Finally, two computations that use state can be sequenced by finding both the output state and return value of the first function, then passing them both into the next function: -->

最終的に，状態を使用する2つの計算は，まず最初の関数の出力状態と戻り値を取得し，それらを次の関数に渡すことでつなげることができます：

```lean
{{#example_decl Examples/Monads.lean andThenState}}
```

<!-- Using `State` and its helpers, local mutable state can be simulated: -->

`State` とそのヘルパーを使うことで，局所的な可変変数をシミュレートすることができます：

```lean
{{#example_decl Examples/Monads.lean numberMonadicish}}
```
<!-- Because `State` simulates only a single local variable, `get` and `set` don't need to refer to any particular variable name. -->

`State` は1つの可変変数のみをシミュレートするため，`get` と `set` の呼び出しで特定の変数名を指定する必要がありません．

<!-- ## Monads: A Functional Design Pattern -->

## モナド：関数的デザインパターン

<!-- Each of these examples has consisted of: -->

これらの例は以下のようにまとめられます：

 <!-- * A polymorphic type, such as `Option`, `Except ε`, `WithLog logged`, or `State σ` -->
 * `Option` や `Except ε` ，`WithLog logged` ，`State σ` などの多相型
 <!-- * An operator `andThen` that takes care of some repetitive aspect of sequencing programs that have this type -->
 * この型を持つプログラム列における繰り返される側面のケアを行う `andThen` 演算
 <!-- * An operator `ok` that is (in some sense) the most boring way to use the type -->
 * この型を扱う中で（ある意味で）もっとも退屈な方法である `ok` 演算
 <!-- * A collection of other operations, such as `none`, `fail`, `save`, and `get`, that name ways of using the type -->
 * その他，この型を用いる `none` や `fail` ，`save` ，`get` などの演算のあつまり

<!-- This style of API is called a _monad_.
While the idea of monads is derived from a branch of mathematics called category theory, no understanding of category theory is needed in order to use them for programming.
The key idea of monads is that each monad encodes a particular kind of side effect using the tools provided by the pure functional language Lean.
For example, `Option` represents programs that can fail by returning `none`, `Except` represents programs that can throw exceptions, `WithLog` represents programs that accumulate a log while running, and `State` represents programs with a single mutable variable. -->

このAPIのスタイルは **モナド** （monad）と呼ばれます．モナドの考え方は圏論と呼ばれる数学の1分野から派生したものですが，プログラミングで用いるにあたって圏論の理解は必要ありません．モナドの重要な考え方は，純粋関数型言語であるLeanが提供するツールを用いることで，それぞれのモナドが特定の種類の副作用をエンコードするということです．例えば，`Option` は `none` を返して失敗するプログラムを表し，`Except` は例外を投げるプログラムを，`WithLog` は実行中にログを蓄積するプログラムを，`State` は単一の可変変数を持つプログラムをそれぞれ表します．
