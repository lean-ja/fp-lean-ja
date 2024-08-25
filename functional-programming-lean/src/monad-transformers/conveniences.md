<!--
# Additional Conveniences
-->

# その他の便利な機能

<!--
## Pipe Operators
-->

## パイプ演算子

<!--
Functions are normally written before their arguments.
When reading a program from left to right, this promotes a view in which the function's _output_ is paramount—the function has a goal to achieve (that is, a value to compute), and it receives arguments to support it in this process.
But some programs are easier to understand in terms of an input that is successively refined to produce the output.
For these situations, Lean provides a _pipeline_ operator which is similar to the that provided by F#.
Pipeline operators are useful in the same situations as Clojure's threading macros.
-->

関数は通常、引数の前に書かれます。これはプログラムを左から右に読む際に、関数の **出力** が最重要だという見方を助長します。つまり、関数は達成すべきゴール（つまり計算すべき値）を持っており、そのプロセスをサポートするために引数を受け取るという視点です。しかし、プログラムの中には出力の生成のために入力が逐次的に改良されていく、という観点のほうが理解しやすいものも存在します。このような状況に対して、LeanはF#にあるものと似た **パイプライン** 演算子を提供しています。パイプライン演算子はClojureのスレッディングマクロと同じ状況化で有用です。

<!--
The pipeline `{{#example_in Examples/MonadTransformers/Conveniences.lean pipelineShort}}` is short for `{{#example_out Examples/MonadTransformers/Conveniences.lean pipelineShort}}`.
For example, evaluating:
-->

パイプライン `{{#example_in Examples/MonadTransformers/Conveniences.lean pipelineShort}}` は `{{#example_out Examples/MonadTransformers/Conveniences.lean pipelineShort}}` の省略形です。例えば、以下を評価すると：

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean some5}}
```
<!--
results in:
-->

以下の結果になります：

```output info
{{#example_out Examples/MonadTransformers/Conveniences.lean some5}}
```
<!--
While this change of emphasis can make some programs more convenient to read, pipelines really come into their own when they contain many components.
-->

このように強調箇所を変えることでより読みやすくなるプログラムもありますが、多くのコンポーネントを含む場合にパイプラインはその本領を発揮します。

<!--
With the definition:
-->

以下の定義に対して：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean times3}}
```
<!--
the following pipeline:
-->

以下のパイプラインは：

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean itIsFive}}
```
<!--
yields:
-->

以下を出力します：

```output info
{{#example_out Examples/MonadTransformers/Conveniences.lean itIsFive}}
```
<!--
More generally, a series of pipelines `{{#example_in Examples/MonadTransformers/Conveniences.lean pipeline}}` is short for nested function applications `{{#example_out Examples/MonadTransformers/Conveniences.lean pipeline}}`.
-->

より一般的には、パイプラインの列 `{{#example_in Examples/MonadTransformers/Conveniences.lean pipeline}}` は関数適用のネスト `{{#example_out Examples/MonadTransformers/Conveniences.lean pipeline}}` の省略形です。

<!--
Pipelines may also be written in reverse.
In this case, they do not place the subject of data transformation first; however, in cases where many nested parentheses pose a challenge for readers, they can clarify the steps of application.
The prior example could be equivalently written as:
-->

パイプラインは反対向きに書くこともできます。この場合、変換する対象のデータを先に持ってきません；しかし、入れ子になった括弧が多くて読者が困るような場合にはパイプラインによって適用のステップを明確にすることができます。先ほどの例は以下の記述と等価です：

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean itIsAlsoFive}}
```
<!--
which is short for:
-->

これは以下の短縮形です：

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean itIsAlsoFiveParens}}
```

<!--
Lean's method dot notation that uses the name of the type before the dot to resolve the namespace of the operator after the dot serves a similar purpose to pipelines.
Even without the pipeline operator, it is possible to write `{{#example_in Examples/MonadTransformers/Conveniences.lean listReverse}}` instead of `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverse}}`.
However, the pipeline operator is also useful for dotted functions when using many of them.
`{{#example_in Examples/MonadTransformers/Conveniences.lean listReverseDropReverse}}` can also be written as `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverseDropReverse}}`.
This version avoids having to parenthesize expressions simply because they accept arguments, and it recovers the convenience of a chain of method calls in languages like Kotlin or C#.
However, it still requires the namespace to be provided by hand.
As a final convenience, Lean provides the "pipeline dot" operator, which groups functions like the pipeline but uses the name of the type to resolve namespaces.
With "pipeline dot", the example can be rewritten to `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverseDropReversePipe}}`.
-->

Leanのメソッドのドット記法は、ドットの前の型名を使ってドットの後ろの演算子の名前空間を解決するもので、パイプラインと似た目的を提供しています。仮にパイプライン演算子が無くとも、`{{#example_in Examples/MonadTransformers/Conveniences.lean listReverse}}` の代わりに `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverse}}` と書くことは可能です。しかし、パイプライン演算子はドットを付けた関数をたくさん使う場合でも便利です。`{{#example_in Examples/MonadTransformers/Conveniences.lean listReverseDropReverse}}` は `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverseDropReverse}}` と書くこともできます。この書き方では、ただ引数を受け取るという理由だけで式を括弧で囲む必要がなく、KotlinやC#のような言語での便利なメソッドチェーンを再現しています。ただし、この場合は名前空間を手動で指定する必要があります。そこで究極的な便利機能として、Leanは「パイプラインドット」演算子を提供しています。これは関数をパイプラインのようにグループ化しますが、名前空間を解決するために型名を使用します。「パイプラインドット」を使用すると、上記の例は `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverseDropReversePipe}}` と書き換えることができます。

<!--
## Infinite Loops
-->

## 無限ループ

<!--
Within a `do`-block, the `repeat` keyword introduces an infinite loop.
For example, a program that spams the string `"Spam!"` can use it:
-->

`do` ブロックの中で、`repeat` キーワードを使うと無限ループを作れます。例えば、`"Spam!"` という文字列を連投するプログラムで以下のように使われます：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean spam}}
```
<!--
A `repeat` loop supports `break` and `continue`, just like `for` loops.
-->

`repeat` ループは `for` ループと同じように `break` と `continue` をサポートしています。

<!--
The `dump` function from the [implementation of `feline`](../hello-world/cat.md#streams) uses a recursive function to run forever:
-->

[`feline` の実装](../hello-world/cat.md#streams) における `dump` 関数は再帰関数を使って永遠に実行していました：

```lean
{{#include ../../../examples/feline/2/Main.lean:dump}}
```
<!--
This function can be greatly shortened using `repeat`:
-->

この関数は `repeat` を使うことで劇的に短縮できます：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean dump}}
```

<!--
Neither `spam` nor `dump` need to be declared as `partial` because they are not themselves infinitely recursive.
Instead, `repeat` makes use of a type whose `ForM` instance is `partial`.
Partiality does not "infect" calling functions.
-->

`spam` も `dump` も、それ自体が無限再帰ではないため `partial` として宣言する必要はありません。その代わりに、`repeat` は `ForM` インスタンスが `partial` である型を使用します。関数の部分性は、関数の呼び出し時に「感染」することはありません。

<!--
## While Loops
-->

## whileループ

<!--
When programming with local mutability, `while` loops can be a convenient alternative to `repeat` with an `if`-guarded `break`:
-->

局所的な可変性を使ってプログラムを書く場合、`while` ループは `if` で `break` をガードするような `repeat` よりも便利です：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean dumpWhile}}
```
<!--
Behind the scenes, `while` is just a simpler notation for `repeat`.
-->

裏では、`while` は `repeat` をよりシンプルにした表記にすぎません。
