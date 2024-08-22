<!-- # Step By Step -->

# ステップ・バイ・ステップ

<!-- A `do` block can be executed one line at a time.
Start with the program from the prior section: -->

`do` ブロックは一行ずつ実行できます。前の節のプログラムから始めましょう：

```lean
{{#include ../../../examples/hello-name/HelloName.lean:block1}}
```

<!-- ## Standard IO -->

## 標準入出力

<!-- The first line is `{{#include ../../../examples/hello-name/HelloName.lean:line1}}`, while the remainder is: -->

最初の行は `{{#include ../../../examples/hello-name/HelloName.lean:line1}}` で残りの部分は以下の通りです：

```lean
{{#include ../../../examples/hello-name/HelloName.lean:block2}}
```
<!-- To execute a `let` statement that uses a `←`, start by evaluating the expression to the right of the arrow (in this case, `IO.getStdIn`).
Because this expression is just a variable, its value is looked up.
The resulting value is a built-in primitive `IO` action.
The next step is to execute this `IO` action, resulting in a value that represents the standard input stream, which has type `IO.FS.Stream`.
Standard input is then associated with the name to the left of the arrow (here `stdin`) for the remainder of the `do` block. -->

`←` を使った `let` 文を実行するには、まず矢印の右側にある式（この場合は `IO.getStdIn`）を評価します。この式は単なる変数なので、その値が参照されます。結果として得られる値は組み込みのプリミティブな `IO` アクションです。次のステップはこの `IO` アクションを実行し、標準入力ストリームを表す値を得ることです。この値は `IO.FS.Stream` 型です。標準入力はその後、矢印の左側の名前（ここでは `stdin`）に関連付けられ、`do` ブロックの残りの部分で使用されます。

<!-- Executing the second line, `{{#include ../../../examples/hello-name/HelloName.lean:line2}}`, proceeds similarly.
First, the expression `IO.getStdout` is evaluated, yielding an `IO` action that will return the standard output.
Next, this action is executed, actually returning the standard output.
Finally, this value is associated with the name `stdout` for the remainder of the `do` block. -->

2行目の `{{#include ../../../examples/hello-name/HelloName.lean:line2}}` の実行も同様に進みます。まず、`IO.getStdout` という式が評価され、標準出力を返す `IO` アクションが得られます。次に、このアクションが実行され、実際に標準出力が返されます。最後に、この値が `stdout` という名前に関連付けられ、`do` ブロックの残りの部分で使用されます。

<!-- ## Asking a Question -->

## 質問をする

<!-- Now that `stdin` and `stdout` have been found, the remainder of the block consists of a question and an answer: -->

`stdin` と `stdout` が定まったので、ブロックの残りの部分は質問と答えから構成されます：

```lean
{{#include ../../../examples/hello-name/HelloName.lean:block3}}
```

<!-- The first statement in the block, `{{#include ../../../examples/hello-name/HelloName.lean:line3}}`, consists of an expression.
To execute an expression, it is first evaluated.
In this case, `IO.FS.Stream.putStrLn` has type `IO.FS.Stream → String → IO Unit`.
This means that it is a function that accepts a stream and a string, returning an `IO` action.
The expression uses [accessor notation](../getting-to-know/structures.md#behind-the-scenes) for a function call.
This function is applied to two arguments: the standard output stream and a string.
The value of the expression is an `IO` action that will write the string and a newline character to the output stream.
Having found this value, the next step is to execute it, which causes the string and newline to actually be written to `stdout`.
Statements that consist only of expressions do not introduce any new variables. -->

ブロックの最初の文である `{{#include ../../../examples/hello-name/HelloName.lean:line3}}` は式から成り立っています。式を実行するにはまず評価します。今回の場合、`IO.FS.Stream.putStrLn` は `IO.FS.Stream → String → IO Unit` 型を持ちます。これはストリームと文字列を受け取り、`IO` アクションを返す関数であることを意味します。この式は関数呼び出しのために[アクセサ記法](../getting-to-know/structures.md#behind-the-scenes)を使用しています。呼び出された関数には標準出力ストリームと文字列の2つの引数が適用されます。よってこの式の値は文字列と改行文字を出力ストリームに書き込む `IO` アクションです。値が決まった後、次のステップでそれを実行することにより、実際に文字列と改行文字が `stdout` に書き込まれます。式だけで構成される文は新しい変数を導入しません。

<!-- The next statement in the block is `{{#include ../../../examples/hello-name/HelloName.lean:line4}}`.
`IO.FS.Stream.getLine` has type `IO.FS.Stream → IO String`, which means that it is a function from a stream to an `IO` action that will return a string.
Once again, this is an example of accessor notation.
This `IO` action is executed, and the program waits until the user has typed a complete line of input.
Assume the user writes "`David`".
The resulting line (`"David\n"`) is associated with `input`, where the escape sequence `\n` denotes the newline character. -->

次の文は `{{#include ../../../examples/hello-name/HelloName.lean:line4}}` です。`IO.FS.Stream.getLine` は `IO.FS.Stream → IO String` 型を持ちます。これはストリームを受け取り、文字列を返す `IO` アクションであることを意味します。これもアクセサ記法の一例です。この `IO` アクションが実行されると、プログラムはユーザが入力を完了するまで待機します。ユーザが `"David"` と入力したとすると、結果として得られる文字列（`"David\n"`）は `input` に関連付けられます（`\n` はエスケープシーケンスでここでは改行文字を表します）。

```lean
{{#include ../../../examples/hello-name/HelloName.lean:block5}}
```

<!-- The next line, `{{#include ../../../examples/hello-name/HelloName.lean:line5}}`, is a `let` statement.
Unlike the other `let` statements in this program, it uses `:=` instead of `←`.
This means that the expression will be evaluated, but the resulting value need not be an `IO` action and will not be executed.
In this case, `String.dropRightWhile` takes a string and a predicate over characters and returns a new string from which all the characters at the end of the string that satisfy the predicate have been removed.
For example, -->

次の行 `{{#include ../../../examples/hello-name/HelloName.lean:line5}}` は `let` 文です。このプログラムの他の `let` 文とは異なり、`←` ではなく `:=` を使用しています。これは、式が評価されるものの、その結果の値は `IO` アクションである必要はなく、実行もされないことを意味します。今回の場合、`String.dropRightWhile` は文字列と文字に対する述語を受け取り、述語を満たす文字を末尾から全て削除した新しい文字列を返します。例えば、

```lean
{{#example_in Examples/HelloWorld.lean dropBang}}
```

<!-- yields -->

は次の文字列を返し、

```output info
{{#example_out Examples/HelloWorld.lean dropBang}}
```
<!-- and -->

また、

```lean
{{#example_in Examples/HelloWorld.lean dropNonLetter}}
```

<!-- yields -->

は次の文字列を返します。

```output info
{{#example_out Examples/HelloWorld.lean dropNonLetter}}
```
<!-- in which all non-alphanumeric characters have been removed from the right side of the string.
In the current line of the program, whitespace characters (including the newline) are removed from the right side of the input string, resulting in `"David"`, which is associated with `name` for the remainder of the block. -->

このように文字列の右側から英数字ではない文字を全て削除します。現在のプログラムの行では、空白文字（空白文字として改行文字も含まれる）が入力文字列の右側から削除され、その結果得られる `"David"` がこのブロックの残りの部分で `name` に関連付けられます。

<!-- ## Greeting the User -->

## ユーザへの挨拶

<!-- All that remains to be executed in the `do` block is a single statement: -->

`do` ブロック内で実行される残りの文は以下の1行です：

```lean
{{#include ../../../examples/hello-name/HelloName.lean:line6}}
```
<!-- The string argument to `putStrLn` is constructed via string interpolation, yielding the string `"Hello, David!"`.
Because this statement is an expression, it is evaluated to yield an `IO` action that will print this string with a newline to standard output.
Once the expression has been evaluated, the resulting `IO` action is executed, resulting in the greeting. -->

`putStrLn` への文字列引数は文字列補完によって構築され、`"Hello, David!"` という文字列になります。この文は式なので、評価されると、文字列を改行とともに標準出力に表示する `IO` アクションが得られます。この式が評価されると、結果として得られる `IO` アクションが実行され、挨拶が表示されます。

<!-- ## `IO` Actions as Values -->

## 値としての `IO` アクション

<!-- In the above description, it can be difficult to see why the distinction between evaluating expressions and executing `IO` actions is necessary.
After all, each action is executed immediately after it is produced.
Why not simply carry out the effects during evaluation, as is done in other languages? -->

上記の説明では、式の評価と `IO` アクションの実行の区別がなぜ必要なのかわかりにくいかもしれません。結局のところ、各アクションは生成された直後に実行されます。他の言語のように、評価中に作用を実行しないのはなぜでしょうか？

<!-- The answer is twofold.
First off, separating evaluation from execution means that programs must be explicit about which functions can have side effects.
Because the parts of the program that do not have effects are much more amenable to mathematical reasoning, whether in the heads of programmers or using Lean's facilities for formal proof, this separation can make it easier to avoid bugs.
Secondly, not all `IO` actions need be executed at the time that they come into existence.
The ability to mention an action without carrying it out allows ordinary functions to be used as control structures. -->

答えは2つあります。まず、評価と実行を分離することで、プログラムはどの関数が副作用を持つか明示的に示す必要があります。副作用を持たないプログラムの部分は数学的な推論がしやすいため、プログラマが頭の中で考える場合でも Lean の形式証明の機能を使う場合でも、この分離はバグを回避しやすくします。次に、すべての `IO` アクションが生成された時点で実行される必要はありません。アクションを実行せずに記述できる機能により、通常の関数を制御構造として使用できるようになります。


<!-- For instance, the function `twice` takes an `IO` action as its argument, returning a new action that will execute the first one twice. -->

例えば、`twice` 関数は `IO` アクションを引数にとり、最初のアクションを2回実行する新しいアクションを返します。

```lean
{{#example_decl Examples/HelloWorld.lean twice}}
```
<!-- For instance, executing -->

例えば、以下を実行すると、

```lean
{{#example_in Examples/HelloWorld.lean twiceShy}}
```
<!-- results in -->

結果は、

```output info
{{#example_out Examples/HelloWorld.lean twiceShy}}
```
<!-- being printed.
This can be generalized to a version that runs the underlying action any number of times: -->

のように出力されます。これは、基礎となるアクションを任意の回数実行するバージョンに一般化できます：

```lean
{{#example_decl Examples/HelloWorld.lean nTimes}}
```
<!-- In the base case for `Nat.zero`, the result is `pure ()`.
The function `pure` creates an `IO` action that has no side effects, but returns `pure`'s argument, which in this case is the constructor for `Unit`.
As an action that does nothing and returns nothing interesting, `pure ()` is at the same time utterly boring and very useful.
In the recursive step, a `do` block is used to create an action that first executes `action` and then executes the result of the recursive call.
Executing `{{#example_in Examples/HelloWorld.lean nTimes3}}` causes the following output: -->

基底ケースである `Nat.zero` では、結果は `pure()` です。`pure` 関数は副作用のない `IO` アクションを作成し、引数（この場合 `Unit` のコンストラクタ）を返します。何もせず何の興味深いものも返さないアクションである `pure()` はとても退屈であると同時に非常に便利です。再帰的なステップでは、`do` ブロックを使って、最初に `action` を実行した後にその再帰呼び出しの結果を実行するアクションを作成します。

```output info
{{#example_out Examples/HelloWorld.lean nTimes3}}
```

<!-- In addition to using functions as control structures, the fact that `IO` actions are first-class values means that they can be saved in data structures for later execution.
For instance, the function `countdown` takes a `Nat` and returns a list of unexecuted `IO` actions, one for each `Nat`: -->

制御構造として関数を使うことに加えて、`IO` アクションが第一級の値であるということは、後で実行するためにその値をデータ構造として保存できることを意味します。例えば、`countdown` 関数は `Nat` を引数にとり、未実行の `Nat` ごとの `IO` アクションのリストを返します：

```lean
{{#example_decl Examples/HelloWorld.lean countdown}}
```
<!-- This function has no side effects, and does not print anything.
For example, it can be applied to an argument, and the length of the resulting list of actions can be checked: -->

この関数は副作用がなく、何も出力しません。
例えば、引数にこの関数を適用して、結果として得られるアクションのリストの長さを確認することができます：

```lean
{{#example_decl Examples/HelloWorld.lean from5}}
```
<!-- This list contains six elements (one for each number, plus a `"Blast off!"` action for zero): -->

このリストは6つの要素を含みます（各数値ごとのアクションに加えて、ゼロのときの `"Blast off!"`）：

```lean
{{#example_in Examples/HelloWorld.lean from5length}}
```
```output info
{{#example_out Examples/HelloWorld.lean from5length}}
```

<!-- The function `runActions` takes a list of actions and constructs a single action that runs them all in order: -->

`runActions` 関数はアクションのリストを受け取り、それらを順番に実行する一つのアクションを構築します：

```lean
{{#example_decl Examples/HelloWorld.lean runActions}}
```
<!-- Its structure is essentially the same as that of `nTimes`, except instead of having one action that is executed for each `Nat.succ`, the action under each `List.cons` is to be executed.
Similarly, `runActions` does not itself run the actions.
It creates a new action that will run them, and that action must be placed in a position where it will be executed as a part of `main`: -->

これは `nTimes` と同じ構造ですが、`Nat.succ` ごとに実行されるアクションが1つずつあるのではなく、`List.cons` ごとに実行されるアクションがあります。同様に、`runActions` はそれ自体ではアクションを実行しません。アクションを実行する新しいアクションを作成し、そのアクションは `main` の一部として実行される位置に置かなければいけません：

```lean
{{#example_decl Examples/HelloWorld.lean main}}
```
<!-- Running this program results in the following output: -->

このプログラムを実行すると、以下のような出力が得られます：

```output info
{{#example_out Examples/HelloWorld.lean countdown5}}
```

<!-- What happens when this program is run?
The first step is to evaluate `main`. That occurs as follows: -->

プログラムを実行したときに何が起こっているのでしょうか？最初のステップは `main` の評価です。以下のように実行されます：

```lean
{{#example_eval Examples/HelloWorld.lean evalMain}}
```
<!-- The resulting `IO` action is a `do` block.
Each step of the `do` block is then executed, one at a time, yielding the expected output.
The final step, `pure ()`, does not have any effects, and it is only present because the definition of `runActions` needs a base case. -->

`IO` アクションの結果は `do` ブロックです。`do` ブロックの各ステップが1つずつ実行され、期待する出力が得られます。最後のステップである `pure()` は何の作用もなく、`runActions` の定義として基底ケースが必要なため存在しています。

<!-- ## Exercise -->

## 演習問題

<!-- Step through the execution of the following program on a piece of paper: -->

次のプログラムの実行を、紙の上でステップ実行してください：

```lean
{{#example_decl Examples/HelloWorld.lean ExMain}}
```
<!-- While stepping through the program's execution, identify when an expression is being evaluated and when an `IO` action is being executed.
When executing an `IO` action results in a side effect, write it down.
After doing this, run the program with Lean and double-check that your predictions about the side effects were correct. -->

プログラムをステップ実行しながら、いつ式が評価されて、いつ `IO` アクションが実行されるかを確認してください。`IO` アクションを実行した結果、副作用が発生したときは、それを書き留めます。紙の上での実行が終わった後、Lean を使ってプログラムを実行し、副作用に関するあなたの予想が正しかったかを再確認してください。
