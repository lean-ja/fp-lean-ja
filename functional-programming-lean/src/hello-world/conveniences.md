<!--
# Additional Conveniences
-->

# その他の便利機能

<!--
## Nested Actions
-->

## ネストされたアクション

<!--
Many of the functions in `feline` exhibit a repetitive pattern in which an `IO` action's result is given a name, and then used immediately and only once.
For instance, in `dump`:
-->

`feline` の関数の多くは `IO` アクションの結果に名前を付けてすぐ一度だけ使うというパターンを繰り返していました。例えば、`dump` の場合：

```lean
{{#include ../../../examples/feline/2/Main.lean:dump}}
```
<!--
the pattern occurs for `stdout`:
-->

`stdout` のところでこのパターンが発生しています：

```lean
{{#include ../../../examples/feline/2/Main.lean:stdoutBind}}
```
<!--
Similarly, `fileStream` contains the following snippet:
-->

同様に、`fileStream` も以下のコード片を含みます：

```lean
{{#include ../../../examples/feline/2/Main.lean:fileExistsBind}}
```

<!--
When Lean is compiling a `do` block, expressions that consist of a left arrow immediately under parentheses are lifted to the nearest enclosing `do`, and their results are bound to a unique name.
This unique name replaces the origin of the expression.
This means that `dump` can also be written as follows:
-->

Leanが `do` ブロックをコンパイルする時、括弧のすぐ下にある左矢印からなる式は、それを包含する最も近い `do` に持ち上げられ、その式の結果が一意な名前に束縛されます。この一意名でもともとの式が置き換えられます。つまり、`dump` は次のように書くこともできます：

```lean
{{#example_decl Examples/Cat.lean dump}}
```
<!--
This version of `dump` avoids introducing names that are used only once, which can greatly simplify a program.
`IO` actions that Lean lifts from a nested expression context are called _nested actions_.
-->

このバージョンの `dump` では、一度しか使わない名前の導入を避けることができるため、プログラムを大幅に簡略にすることができます。ネストされた式のコンテキストからLeanが持ち上げた `IO` アクションは **ネストされたアクション** と呼ばれます。

<!--
`fileStream` can be simplified using the same technique:
-->

`fileStream` も同じテクニックを使って簡略にできます：

```lean
{{#example_decl Examples/Cat.lean fileStream}}
```
<!--
In this case, the local name of `handle` could also have been eliminated using nested actions, but the resulting expression would have been long and complicated.
Even though it's often good style to use nested actions, it can still sometimes be helpful to name intermediate results.
-->

ここでは、`handle` というローカル名をネストされたアクションを使って削除することもできますが、その場合は式が長く複雑になってしまいます。ネストされたアクションを使うことが良い場合が多いとはいえ、中間的な結果に名前を付けておくと便利なこともあります。

<!--
It is important to remember, however, that nested actions are only a shorter notation for `IO` actions that occur in a surrounding `do` block.
The side effects that are involved in executing them still occur in the same order, and execution of side effects is not interspersed with the evaluation of expressions.
For an example of where this might be confusing, consider the following helper definitions that return data after announcing to the world that they have been executed:
-->

しかし、ネストされたアクションは `do` ブロックの中で起こる `IO` アクションの短縮表記に過ぎないことを覚えておくことが重要です。アクションの実行に伴う副作用は同じ順序で発生し、副作用の実行が式の評価と混在することはありません。これが混乱を招く可能性がある例として、実行されたことを世界に通知した後にデータを返す以下の補助的な定義を考えてみましょう：

```lean
{{#example_decl Examples/Cat.lean getNumA}}

{{#example_decl Examples/Cat.lean getNumB}}
```
<!--
These definitions are intended to stand in for more complicated `IO` code that might validate user input, read a database, or open a file.
-->

これらの定義はユーザ入力を検証したり、データベースを読み込んだり、ファイルを開いたりするようなより複雑な `IO` コードの代用を意図しています。

<!--
A program that prints `0` when number A is five, or number `B` otherwise, can be written as follows:
-->

数字Aが5の時は `0` を、それ以外の時は `B` の数値を表示するプログラムは次のように書けます：

```lean
{{#example_decl Examples/Cat.lean testEffects}}
```
<!--
However, this program probably has more side effects (such as prompting for user input or reading a database) than was intended.
The definition of `getNumA` makes it clear that it will always return `5`, and thus the program should not read number B.
However, running the program results in the following output:
-->

しかし、このプログラムはおそらく意図した以上の副作用（ユーザ入力のプロンプトやデータベースの読み取りなど）を持ちます。`getNumA` の定義では、常に `5` を返すことが明確になっているので、このプログラムではBの数値を読み込むべきではありません。しかし、プログラムを実行すると次のような出力が得られます：

```output info
{{#example_out Examples/Cat.lean runTest}}
```
`getNumB` was executed because `test` is equivalent to this definition:
```lean
{{#example_decl Examples/Cat.lean testEffectsExpanded}}
```
<!--
This is due to the rule that nested actions are lifted to the _closest enclosing_ `do` block.
The branches of the `if` were not implicitly wrapped in `do` blocks because the `if` is not itself a statement in the `do` block—the statement is the `let` that defines `a`.
Indeed, they could not be wrapped this way, because the type of the conditional expression is `Nat`, not `IO Nat`.
-->

これはネストされたアクションは **最も近い** `do` ブロックに持ち上げられるルールによるものです。なぜならここでの文は `a` を定義している `let` であって `if` は `do` ブロックの中の文ではないため、この `if` の分岐は暗黙的に `do` ブロックで囲まれないのです。実際、条件式の型は `IO Nat` ではなく `Nat` であるため、このようにラップすることはできません。

<!--
## Flexible Layouts for `do`
-->

## `do` の柔軟なレイアウト

<!--
In Lean, `do` expressions are whitespace-sensitive.
Each `IO` action or local binding in the `do` is expected to start on its own line, and they should all have the same indentation.
Almost all uses of `do` should be written this way.
In some rare contexts, however, manual control over whitespace and indentation may be necessary, or it may be convenient to have multiple small actions on a single line.
In these cases, newlines can be replaced with a semicolon and indentation can be replaced with curly braces.
-->

Leanでは `do` 式は空白に対して敏感です。`do` の各 `IO` アクションや局所的な束縛はそれぞれ独立した行で始まり、インデントも同じでなければなりません。ほとんどすべての `do` はこのように書くべきです。しかしまれに空白やインデントを手動で制御する必要や、複数の小さなアクションを1行に書くと便利な場合があります。このような場合、改行はセミコロンに、インデントは波括弧に置き換えることができます。

<!--
For instance, all of the following programs are equivalent:
-->

例えば、以下のプログラムはすべての等価です：

```lean
{{#example_decl Examples/Cat.lean helloOne}}

{{#example_decl Examples/Cat.lean helloTwo}}

{{#example_decl Examples/Cat.lean helloThree}}
```

<!--
Idiomatic Lean code uses curly braces with `do` very rarely.
-->

慣用的なLeanの `do` のコードでは波括弧を使うことはほとんどありません。

<!--
## Running `IO` Actions With `#eval`
-->

## `#eval` による `IO` アクションの実行

<!--
Lean's `#eval` command can be used to execute `IO` actions, rather than just evaluating them.
Normally, adding a `#eval` command to a Lean file causes Lean to evaluate the provided expression, convert the resulting value to a string, and provide that string as a tooltip and in the info window.
Rather than failing because `IO` actions can't be converted to strings, `#eval` executes them, carrying out their side effects.
If the result of execution is the `Unit` value `()`, then no result string is shown, but if it is a type that can be converted to a string, then Lean displays the resulting value.
-->

Leanの `#eval` コマンドは単に式の評価だけでなく、`IO` アクションを実行するために使用することができます。通常、`#eval` コマンドをLeanファイルに追加すると、Leanは指定された式を評価し、結果の値を文字列に変換して、その文字列をツールチップやinfoウィンドウに表示します。`IO` アクションは文字列に変換できないからといって失敗させるのではなく、`#eval` はそのアクションを実行し、その副作用を執り行います。実行結果が `Unit` 型の値 `()` の場合、結果の文字列は表示されませんが、文字列に変換できる型であればLeanは結果の値を表示します。

<!--
This means that, given the prior definitions of `countdown` and `runActions`,
-->

つまり、`countdown` と `runActions` の定義があらかじめ与えられているとした時：

```lean
{{#example_in Examples/HelloWorld.lean evalDoesIO}}
```
<!--
displays
-->

は以下を出力します。

```output info
{{#example_out Examples/HelloWorld.lean evalDoesIO}}
```
<!--
This is the output produced by running the `IO` action, rather than some opaque representation of the action itself.
In other words, for `IO` actions, `#eval` both _evaluates_ the provided expression and _executes_ the resulting action value.
-->

これは `IO` アクションを実行することによって生成される出力であり、アクション自体の不透明な表現ではありません。言い換えれば、`IO` アクションに対して `#eval` は指定された式を **実行** し、結果のアクションの値を **実行** します。

<!--
Quickly testing `IO` actions with `#eval` can be much more convenient that compiling and running whole programs.
However, there are some limitations.
For instance, reading from standard input simply returns empty input.
Additionally, the `IO` action is re-executed whenever Lean needs to update the diagnostic information that it provides to users, and this can happen at unpredictable times.
An action that reads and writes files, for instance, may do so at inconvenient times.
-->

`#eval` を使って `IO` アクションを素早くテストすることはプログラム全体をコンパイルして実行することよりもはるかに便利です。しかし、いくつかの制限があります。例えば、標準入力からの読み込みは単に空の入力を返すだけになります。さらに、`IO` アクションはLeanがユーザに提供する新参情報を更新する必要があるたびに再実行され、これによって実行タイミングが予測できなくなります。例えば、ファイルを読み書きするアクションは、都合の悪い時に実行される可能性があります。
