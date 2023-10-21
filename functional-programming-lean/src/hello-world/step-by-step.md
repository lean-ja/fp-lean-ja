<!--
# Step By Step

A `do` block can be executed one line at a time.
Start with the program from the prior section:
-->
# ステップ・バイ・ステップ

`do`ブロックは1行ずつ実行できます．まず，前のセクションのプログラムから始めましょう．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:block1}}
```

<!--
## Standard IO

The first line is `{{#include ../../../examples/hello-name/HelloName.lean:line1}}`, while the remainder is:
-->
## 標準入出力

最初の行は `{{#include ../../../examples/hello-name/HelloName.lean:line1}}` で，残りは次のとおりです．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:block2}}
```

<!--
To execute a `let` statement that uses a `←`, start by evaluating the expression to the right of the arrow (in this case, `IO.getStdIn`).
Because this expression is just a variable, its value is looked up.
The resulting value is a built-in primitive `IO` action.
The next step is to execute this `IO` action, resulting in a value that represents the standard input stream, which has type `IO.FS.Stream`.
Standard input is then associated with the name to the left of the arrow (here `stdin`) for the remainder of the `do` block.
-->
`←` を使用する `let` 文を実行する際は，矢印の右側の式（この場合 `IO.getStdIn`）を評価することから始まります．この式は変数であるため，その値が調べられます．その結果の値は，組み込みのプリミティブな `IO` アクションです．次に，この `IO` アクションを実行し，標準入力ストリームを表す値が得られます．この値の型は `IO.FS.Stream` です．
その後，標準入力は矢印の左側の名前（ここでは `stdin`）と紐付けられ，`do`ブロックの残りの部分で使用できるようになります．

<!--
Executing the second line, `{{#include ../../../examples/hello-name/HelloName.lean:line2}}`, proceeds similarly.
First, the expression `IO.getStdout` is evaluated, yielding an `IO` action that will return the standard output.
Next, this action is executed, actually returning the standard output.
Finally, this value is associated with the name `stdout` for the remainder of the `do` block.
-->
2行目の`{{#include ../../../examples/hello-name/HelloName.lean:line2}}` を実行する際も同様に進みます．まず，式 `IO.getStdout` を評価し，標準出力を返す `IO` アクションが生成されます．次に，このアクションが実行され，実際の標準出力を返します．
最後に，この値は `stdout` という名前に紐付けられ，`do` ブロックの残りの部分で使用できるようになります．


<!--
## Asking a Question

Now that `stdin` and `stdout` have been found, the remainder of the block consists of a question and an answer:
-->
## 質問する

ここまでで，`stdin` と `stdout` が分かりました．ブロックの残りは質問と回答から成ります．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:block3}}
```

<!--
The first statement in the block, `{{#include ../../../examples/hello-name/HelloName.lean:line3}}`, consists of an expression.
To execute an expression, it is first evaluated.
In this case, `IO.FS.Stream.putStrLn` has type `IO.FS.Stream → String → IO Unit`.
This means that it is a function that accepts a stream and a string, returning an `IO` action.
The expression uses [accessor notation](../getting-to-know/structures.md#behind-the-scenes) for a function call.
This function is applied to two arguments: the standard output stream and a string.
The value of the expression is an `IO` action that will write the string and a newline character to the output stream.
Having found this value, the next step is to execute it, which causes the string and newline to actually be written to `stdout`.
Statements that consist only of expressions do not introduce any new variables.
-->
ブロックの最初の文，`{{#include ../../../examples/hello-name/HelloName.lean:line3}}` は式から成ります．式を実行するには，まず評価されます．ここでは，`IO.FS.Stream.putStrLn` の型は `IO.FS.Stream → String → IO Unit` です．これは，ストリームと文字列を受け入れて `IO` アクションを返す関数です．この式は関数呼び出しのための [アクセサー表記](../getting-to-know/structures.md#behind-the-scenes) を使用しています．この関数には，標準出力ストリームと文字列，2つの引数が適用されています．この式の値は，文字列と改行文字を出力ストリームに書き込む `IO` アクションです．この値を見つけ，それを実行し，文字列と改行が実際に `stdout` に書き込まれるようにします．式だけから成る文には新しい変数が導入されないことに注意してください．

<!--
The next statement in the block is `{{#include ../../../examples/hello-name/HelloName.lean:line4}}`.
`IO.FS.Stream.getLine` has type `IO.FS.Stream → IO String`, which means that it is a function from a stream to an `IO` action that will return a string.
Once again, this is an example of accessor notation.
This `IO` action is executed, and the program waits until the user has typed a complete line of input.
Assume the user writes "`David`".
The resulting line (`"David\n"`) is associated with `input`, where the escape sequence `\n` denotes the newline character.
-->
ブロック内の次の文は `{{#include ../../../examples/hello-name/HelloName.lean:line4}}` です．`IO.FS.Stream.getLine` の型は `IO.FS.Stream → IO String` で，これはストリームから文字列を返す `IO` アクションを表す関数です．
これもまた，アクセサー表記の例です．この `IO` アクションが実行され，プログラムはユーザーが完全な入力行を入力するのを待ちます．ユーザーが `"David"` と入力したとしましょう．生成された行（`"David\n"`）は `input` に関連付けられ，ここでエスケープシーケンス `\n` は改行文字を示します．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:block5}}
```

<!--
The next line, `{{#include ../../../examples/hello-name/HelloName.lean:line5}}`, is a `let` statement.
Unlike the other `let` statements in this program, it uses `:=` instead of `←`.
This means that the expression will be evaluated, but the resulting value need not be an `IO` action and will not be executed.
In this case, `String.dropRightWhile` takes a string and a predicate over characters and returns a new string from which all the characters at the end of the string that satisfy the predicate have been removed.
For example,
-->
次の行，`{{#include ../../../examples/hello-name/HelloName.lean:line5}}` は `let` 文です．このプログラム内の他の `let` 文とは異なり，こちらは `:=` を使用しています．
これは，式は評価されるものの，その結果の値は `IO` アクションである必要はなく，実行されないということを意味します．ここでは，`String.dropRightWhile` は文字列と文字の述語を取り，述語を満たす文字を持つ文字列の末尾から削除された新しい文字列を返します．例えば
```lean
{{#example_in Examples/HelloWorld.lean dropBang}}
```
<!--
yields
-->
は
```output info
{{#example_out Examples/HelloWorld.lean dropBang}}
```
<!--
and
-->
となり，
```lean
{{#example_in Examples/HelloWorld.lean dropNonLetter}}
```
<!--
yields
-->
は
```output info
{{#example_out Examples/HelloWorld.lean dropNonLetter}}
```
<!--
in which all non-alphanumeric characters have been removed from the right side of the string.
In the current line of the program, whitespace characters (including the newline) are removed from the right side of the input string, resulting in `"David"`, which is associated with `name` for the remainder of the block.
-->
となります．これらの例では，文字列の右側から非英数字文字が削除されています．プログラムの現在の行では，空白文字（改行を含む）が入力文字列の右側から削除され，`"David"` となり，これはブロックの残りの部分において `name` に紐付けられます．


<!--
## Greeting the User

All that remains to be executed in the `do` block is a single statement:
-->

## ユーザに挨拶する（Greeting the User）

`do` ブロックで実行する必要のあるものは，次の 1 つの文だけです．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:line6}}
```
<!--
The string argument to `putStrLn` is constructed via string interpolation, yielding the string `"Hello, David!"`.
Because this statement is an expression, it is evaluated to yield an `IO` action that will print this string with a newline to standard output.
Once the expression has been evaluated, the resulting `IO` action is executed, resulting in the greeting.
-->
`putStrLn` に渡される文字列の引数は文字列補間を使用して構築され，文字列 `"Hello, David!"` が生成されます．この文は式であるため，この文字列を新しい行と共に標準出力に出力する `IO` アクションを生成するために評価されます．式が評価されると，生成された `IO` アクションが実行され，挨拶が表示されます．


<!--
## `IO` Actions as Values

In the above description, it can be difficult to see why the distinction between evaluating expressions and executing `IO` actions is necessary.
After all, each action is executed immediately after it is produced.
Why not simply carry out the effects during evaluation, as is done in other languages?
-->
## 値としての `IO` アクション

上記の説明では，なぜ式の評価と `IO` アクションの実行の区別が必要なのかが分かりにくいかもしれません．結局のところ，各アクションは生成された直後に実行されています．なぜ他の言語で行われているように，評価中に作用を実行しないのでしょうか？

<!--
The answer is twofold.
First off, separating evaluation from execution means that programs must be explicit about which functions can have side effects.
Because the parts of the program that do not have effects are much more amenable to mathematical reasoning, whether in the heads of programmers or using Lean's facilities for formal proof, this separation can make it easier to avoid bugs.
Secondly, not all `IO` actions need be executed at the time that they come into existence.
The ability to mention an action without carrying it out allows ordinary functions to be used as control structures.
-->
その答えは二つあります．まず，評価と実行を分離することで，プログラムはどの関数が副作用を持つことができるかについて明示的であることになります．副作用のないプログラムとなっている部分は，数学的な推論に非常に適しており，プログラマの頭の中で行うか，Leanの形式的な証明のための仕組みを用いるかに関係なく，この分離はバグを回避しやすくすることができます．さらに，生成された瞬間にすぐに実行される必要のない `IO` アクションもあります．アクションを実行せずに言及できる能力は，通常の関数を制御構造として使用できるようにします．

<!--
For instance, the function `twice` takes an `IO` action as its argument, returning a new action that will execute the first one twice.
-->
たとえば，関数 `twice` は，その引数として `IO` アクションを受け取り，最初のアクションを2回実行する新しいアクションを返します．
```lean
{{#example_decl Examples/HelloWorld.lean twice}}
```
<!--
For instance, executing
-->
具体的には，次のコードを実行すると，
```lean
{{#example_in Examples/HelloWorld.lean twiceShy}}
```
<!--
results in
-->
次の結果が表示されます．
```output info
{{#example_out Examples/HelloWorld.lean twiceShy}}
```
<!--
being printed.
This can be generalized to a version that runs the underlying action any number of times:
-->
これは，アクションを任意の回数実行するバージョンに一般化できます．
```lean
{{#example_decl Examples/HelloWorld.lean nTimes}}
```

<!--
In the base case for `Nat.zero`, the result is `pure ()`.
The function `pure` creates an `IO` action that has no side effects, but returns `pure`'s argument, which in this case is the constructor for `Unit`.
As an action that does nothing and returns nothing interesting, `pure ()` is at the same time utterly boring and very useful.
In the recursive step, a `do` block is used to create an action that first executes `action` and then executes the result of the recursive call.
Executing `{{#example_in Examples/HelloWorld.lean nTimes3}}` causes the following output:
-->
`Nat.zero` の基本ケースでは，結果は `pure ()` です．`pure` 関数は，副作用のない `IO` アクションを作成し，ただし，このアクションは `pure` の引数である `Unit` のコンストラクタを返します．何もしないし，面白みのないアクションとして，`pure ()` は非常に退屈であると同時に，非常に便利です．再帰ステップでは，`do` ブロックを使用して，最初に `action` を実行し，再帰呼び出しの結果を実行するアクションを作成します．`{{#example_in Examples/HelloWorld.lean nTimes3}}` を実行すると，次の出力が生成されます．
```output info
{{#example_out Examples/HelloWorld.lean nTimes3}}
```

<!--
In addition to using functions as control structures, the fact that `IO` actions are first-class values means that they can be saved in data structures for later execution.
For instance, the function `countdown` takes a `Nat` and returns a list of unexecuted `IO` actions, one for each `Nat`:
-->
関数を制御構造として使用することに加えて，`IO` アクションがファーストクラスの値であるという事実は，それらを後で利用するためにデータ構造に保存できることを意味します．たとえば，関数 `countdown` は `Nat` を受け取り，各 `Nat` に対して実行されていない `IO` アクションのリストを返します．
```lean
{{#example_decl Examples/HelloWorld.lean countdown}}
```

<!--
This function has no side effects, and does not print anything.
For example, it can be applied to an argument, and the length of the resulting list of actions can be checked:
-->
この関数は副作用を持たず，何も印刷しません．たとえば，引数に適用でき，結果のアクションのリストの長さを確認できます．
```lean
{{#example_decl Examples/HelloWorld.lean from5}}
```

<!--
This list contains six elements (one for each number, plus a `"Blast off!"` action for zero):
-->
このリストには 6 つの要素が含まれています（要素が0のときのための `"Blast off!"` アクションを含む，各数値用のアクションがあります）．

```lean
{{#example_in Examples/HelloWorld.lean from5length}}
```
```output info
{{#example_out Examples/HelloWorld.lean from5length}}
```

<!--
The function `runActions` takes a list of actions and constructs a single action that runs them all in order:
-->
関数 `runActions` はアクションのリストを受け取り，それらをすべて順番に実行する単一のアクションを構築します．
```lean
{{#example_decl Examples/HelloWorld.lean runActions}}
```

<!--
Its structure is essentially the same as that of `nTimes`, except instead of having one action that is executed for each `Nat.succ`, the action under each `List.cons` is to be executed.
Similarly, `runActions` does not itself run the actions.
It creates a new action that will run them, and that action must be placed in a position where it will be executed as a part of `main`:
-->
その構造は基本的に `nTimes` と同じですが，各 `List.cons` の下に実行されるアクションがあります．同様に，`runActions` それ自身はアクションを実行しません．`runActions` は実行される新しいアクションを作成し，そのアクションは `main` の一部として実行される位置に配置する必要があります．

```lean
{{#example_decl Examples/HelloWorld.lean main}}
```
<!--
Running this program results in the following output:
-->
このプログラムを実行すると，次の出力が得られます．
```output info
{{#example_out Examples/HelloWorld.lean countdown5}}
```

<!--
What happens when this program is run?
The first step is to evaluate `main`. That occurs as follows:
-->
このプログラムを実行すると何が起こるのでしょうか？最初のステップは `main` を評価することです．その手順は次のとおりです．
```lean
{{#example_eval Examples/HelloWorld.lean evalMain}}
```

<!--
The resulting `IO` action is a `do` block.
Each step of the `do` block is then executed, one at a time, yielding the expected output.
The final step, `pure ()`, does not have any effects, and it is only present because the definition of `runActions` needs a base case.
-->
生成された `IO` アクションは `do` ブロックです．その後，`do` ブロックの各ステップが一度に実行され，予想される出力が生成されます．最後のステップである `pure ()` には副作用がなく，単に `runActions` の基本ケースが必要であるため存在しています．

<!--
## Exercise

Step through the execution of the following program on a piece of paper:
-->
## 練習

紙に次のプログラムの実行をステップ・バイ・ステップで書いてください．
```lean
{{#example_decl Examples/HelloWorld.lean ExMain}}
```

<!--
While stepping through the program's execution, identify when an expression is being evaluated and when an `IO` action is being executed.
When executing an `IO` action results in a side effect, write it down.
After doing this, run the program with Lean and double-check that your predictions about the side effects were correct.
-->
プログラムの実行をステップ・バイ・ステップで進めながら，式が評価されている時と `IO` アクションが実行されている時を特定してください．`IO` アクションを実行することで副作用が発生する場合，それを書き留めてください．これを行った後，Leanでプログラムを実行し，副作用に関する予測が正しいか確認してください．
