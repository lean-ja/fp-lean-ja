<!-- # Evaluating Expressions -->
# 式の評価

<!-- The most important thing to understand as a programmer learning Lean
is how evaluation works. Evaluation is the process of finding the
value of an expression, just as one does in arithmetic. For instance,
the value of 15 - 6 is 9 and the value of 2 × (3 + 1) is 8.
To find the value of the latter expression, 3 + 1 is first replaced by 4, yielding 2 × 4, which itself can be reduced to 8.
Sometimes, mathematical expressions contain variables: the value of _x_ + 1 cannot be computed until we know what the value of _x_ is.
In Lean, programs are first and foremost expressions, and the primary way to think about computation is as evaluating expressions to find their values. -->

Lean を学ぶプログラマが理解すべき最も重要なことは，評価の仕組みです．評価とは，算数で行うような式の値を求めるプロセスのことです．例えば，15-6 の値は 9，2×(3＋1) の値は 8 です．後者の式の値を求めるとき，まず 3＋1 が 4 に置き換えられて 2×4 となります．これは簡約して 8 にできます．数式に変数が含まれることがあります：x+1 の値は，x の値がわかるまで計算できません．Lean では，プログラムはまず第一に式であり，計算を考える第一の方法は，式を評価して値を求めることです．

<!-- Most programming languages are _imperative_, where a program consists
of a series of statements that should be carried out in order to find
the program's result. Programs have access to mutable memory, so the
value referred to by a variable can change over time. In addition to mutable state, programs may have other side
effects, such as deleting files, making outgoing network connections,
throwing or catching exceptions, and reading data from a
database. "Side effects" is essentially a catch-all term for
describing things that may happen in a program that don't follow the
model of evaluating mathematical expressions. -->

ほとんどのプログラミング言語は**命令型**であり，プログラムは，プログラムの結果を求めるために実行されるべき一連の文で構成されています．プログラムは可変なメモリにアクセスできるので，変数が参照する値は時間とともに変化する可能性があります．可変な状態に加えて，プログラムには，ファイルの削除・ネットワーク接続の発信・例外のスローまたはキャッチ・データベースからのデータの読み込みなど，他の副作用があるかもしれません．「副作用」とは，本質的に，数学的な式を評価するモデルに従わないプログラム内で起こりうることの総称です．

<!-- In Lean, however, programs work the same way as mathematical
expressions. Once given a value, variables cannot be reassigned. Evaluating an expression cannot have side effects. If two
expressions have the same value, then replacing one with the other
will not cause the program to compute a different result. This does
not mean that Lean cannot be used to write `Hello, world!` to the
console, but performing I/O is not a core part of the experience of
using Lean in the same way. Thus, this chapter focuses on how to
evaluate expressions interactively with Lean, while the next chapter
describes how to write, compile, and run the `Hello, world!` program. -->

しかし Lean では，プログラムは数式と同じように機能します．一度値が与えられた変数は，再代入できません．式を評価しても副作用はありません．2つの式が同じ値を持つ場合，一方を他方に置き換えても，プログラムが異なる結果を計算することはありません．これは，Lean を使ってコンソールに `Hello, world！` と書くことができないという意味ではありません．しかし I/O の実行は Lean を扱う経験の核心部分ではないとは言えるでしょう．そこで，この章では Lean を使って対話的に式を評価する方法に焦点を当て，次の章で `Hello, world！` プログラムの書き方，コンパイル方法，実行方法について説明します．

<!-- To ask Lean to evaluate an expression, write `#eval` before it in your
editor, which will then report the result back. Typically, the result
is found by putting the cursor or mouse pointer over `#eval`. For
instance, -->

Lean に式の評価をしてもらいたいとき，エディタで式の前に `#eval` と書けば結果を報告してくれます．通常，カーソルやマウスポインタを `#eval` の上に置くと結果が表示されます．例えば，

```lean
#eval {{#example_in Examples/Intro.lean three}}
```

<!-- yields the value `{{#example_out Examples/Intro.lean three}}`. -->

と書くと `{{#example_out Examples/Intro.lean three}}` と表示されます．

<!-- Lean obeys the ordinary rules of precedence and associativity for
arithmetic operators. That is, -->

Lean は通常の算術演算子の優先順位と結合法則に従います．つまり，

```lean
{{#example_in Examples/Intro.lean orderOfOperations}}
```
<!-- yields the value `{{#example_out Examples/Intro.lean orderOfOperations}}` rather than
`{{#example_out Examples/Intro.lean orderOfOperationsWrong}}`. -->

は `{{#example_out Examples/Intro.lean orderOfOperationsWrong}}` ではなく `{{#example_out Examples/Intro.lean orderOfOperations}}` を返します．

<!-- While both ordinary mathematical notation and the majority of
programming languages use parentheses (e.g. `f(x)`) to apply a function to its
arguments, Lean simply writes the function next to its
arguments (e.g. `f x`). Function application is one of the most common operations,
so it pays to keep it concise. Rather than writing -->

通常の数学的表記法でも，大半のプログラミング言語でも，関数をその引数に適用する際には括弧を使います（例：`f(x)`）が，Lean は単に関数をその引数の横に書きます (例：`f x`)．関数の使用は最も一般的な操作のひとつであるため，簡潔であることが重要なのです．`{{#example_out Examples/Intro.lean stringAppendHello}}` を計算するには，

```lean
#eval String.append("Hello, ", "Lean!")
```
<!-- to compute `{{#example_out Examples/Intro.lean stringAppendHello}}`,
one would instead write -->

と書く代わりに，関数の2つの引数を単に空白区切りで隣に書いて

``` Lean
{{#example_in Examples/Intro.lean stringAppendHello}}
```
<!-- where the function's two arguments are simply written next to
it with spaces. -->
とします．

<!-- Just as the order-of-operations rules for arithmetic demand
parentheses in the expression `(1 + 2) * 5`, parentheses are also
necessary when a function's argument is to be computed via another
function call. For instance, parentheses are required in -->

算術の演算順序規則で，`(1 + 2) * 5` という式に括弧が必要なように，関数の引数を別の関数呼び出しで計算する場合にも括弧が必要です．例えば次の式では括弧が必要です．

``` Lean
{{#example_in Examples/Intro.lean stringAppendNested}}
```
<!-- because otherwise the second `String.append` would be interpreted as
an argument to the first, rather than as a function being passed
`"oak "` and `"tree"` as arguments. The value of the inner `String.append`
call must be found first, after which it can be appended to `"great "`,
yielding the final value `{{#example_out Examples/Intro.lean stringAppendNested}}`. -->

そうしないと，2番目の `String.append` は，`"oak "` と `"tree "` を引数として渡された関数としてではなく，最初の `String.append` の引数として解釈されてしまうからです．最初に `String.append` の内部呼び出しの値が評価され，その値を `"great "` に追加することで，最終的な値 `"great oak tree "` を得ることができます．

<!-- Imperative languages often have two kinds of conditional: a
conditional _statement_ that determines which instructions to carry
out based on a Boolean value, and a conditional _expression_ that
determines which of two expressions to evaluate based on a Boolean
value. For instance, in C and C++, the conditional statement is
written using `if` and `else`, while the conditional expression is
written with a ternary operator `?` and `:`. In Python, the
conditional statement begins with `if`, while the conditional
expression puts `if` in the middle.
Because Lean is an expression-oriented functional language, there are no conditional statements, only conditional expressions.
They are written using `if`, `then`, and `else`. For
instance, -->

命令形言語には，しばしば2種類の条件分岐があります：Bool 値に基づいてどの命令を実行するかを決定する条件**文**と，Bool 値に基づいて2つの式のうちどちらを評価するかを決定する条件**式**です．たとえば C や C++ では，条件文は `if` と `else` を使って書かれ，条件式は三項演算子 `?` `:` を使って書かれます．Python では，条件文は `if` で始まりますが，条件式は `if` を真ん中に置きます．Lean はというと式指向の関数型言語ですから，条件文はありません．条件式のみです．条件式は `if`，`then`，`else` を使って書かれます．例えば，

``` Lean
{{#example_eval Examples/Intro.lean stringAppend 0}}
```
<!-- evaluates to -->
は次のように評価されます．
``` Lean
{{#example_eval Examples/Intro.lean stringAppend 1}}
```
<!-- which evaluates to -->
これはさらに次のように評価され，
```lean
{{#example_eval Examples/Intro.lean stringAppend 2}}
```
<!-- which finally evaluates to `{{#example_eval Examples/Intro.lean stringAppend 3}}`. -->

最終的に `{{#example_eval Examples/Intro.lean stringAppend 3}}` と評価されます．

<!-- For the sake of brevity, a series of evaluation steps like this will sometimes be written with arrows between them: -->

簡潔にするために，このような一連の評価ステップを矢印で区切って書くことがあります：

```lean
{{#example_eval Examples/Intro.lean stringAppend}}
```

<!-- ## Messages You May Meet -->
## よくあるエラー

<!-- Asking Lean to evaluate a function application that is missing an argument will lead to an error message.
In particular, the example -->

Lean に引数のない関数適用の評価を依頼すると，エラーメッセージが表示されます．たとえば，特に

```lean
{{#example_in Examples/Intro.lean stringAppendReprFunction}}
```
<!-- yields a quite long error message: -->

とすると，かなり長いエラーメッセージを出力します：

```output error
{{#example_out Examples/Intro.lean stringAppendReprFunction}}
```

<!-- This message occurs because Lean functions that are applied to only some of their arguments return new functions that are waiting for the rest of the arguments.
Lean cannot display functions to users, and thus returns an error when asked to do so. -->

このメッセージは，一部の引数のみ与えられた Lean 関数が，残りの引数を待つ新しい関数を返すために発生します．Lean はユーザに関数を表示することができないため，表示するように要求されるとエラーを返すのです．

<!-- ## Exercises -->
## 演習問題

<!-- What are the values of the following expressions? Work them out by hand,
then enter them into Lean to check your work. -->

次の式の値はなんでしょうか？答えを予想してから，Lean に入力してチェックしてみましょう．

 * `42 + 19`
 * `String.append "A" (String.append "B" "C")`
 * `String.append (String.append "A" "B") "C"`
 * `if 3 == 3 then 5 else 7`
 * `if 3 == 4 then "equal" else "not equal"`
