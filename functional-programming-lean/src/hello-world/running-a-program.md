<!-- # Running a Program -->
# プログラムの実行

<!--
The simplest way to run a Lean program is to use the `--run` option to the Lean executable.
Create a file called `Hello.lean` and enter the following contents:
-->

Lean プログラムを実行する最も簡単な方法は，Lean の実行ファイルに `--run` オプションを使用することです．`Hello.lean` という名前のファイルを作成し，以下の内容を入力してみましょう．

```lean
{{#include ../../../examples/simple-hello/Hello.lean}}
```

<!--
Then, from the command line, run:
-->

次に，コマンドラインから以下を実行してください．

```
{{#command {simple-hello} {hello} {lean --run Hello.lean} }}
```

<!--
The program displays `{{#command_out {hello} {lean --run Hello.lean} }}` and exits.
-->

このプログラムは `{{#command_out {hello} {lean --run Hello.lean} }}` を表示して終了します．

<!-- ## Anatomy of a Greeting -->
## 挨拶の構造

<!--
When Lean is invoked with the `--run` option, it invokes the program's `main` definition.
In programs that do not take command-line arguments, `main` should have type `IO Unit`.
This means that `main` is not a function, because there are no arrows (`→`) in its type.
Instead of being a function that has side effects, `main` consists of a description of effects to be carried out.
-->

Lean を `--run` オプション付きで実行すると，プログラムの `main` 定義が呼び出されます．コマンドライン引数を取らないプログラムの場合，`main` の型は `IO Unit` であるべきです．この型には矢印（`→`）が含まれていません．これは `main` が関数でないことを意味します．つまり，`main` は副作用を持つ関数ではなく，実行される作用の説明から成り立っています．

<!--
As discussed in [the preceding chapter](../getting-to-know/polymorphism.md), `Unit` is the simplest inductive type.
It has a single constructor called `unit` that takes no arguments.
Languages in the C tradition have a notion of a `void` function that does not return any value at all.
In Lean, all functions take an argument and return a value, and the lack of interesting arguments or return values can be signaled by using the `Unit` type instead.
If `Bool` represents a single bit of information, `Unit` represents zero bits of information.
-->
[前の章](../getting-to-know/polymorphism.md)で議論したように，`Unit` は最も単純な帰納型です．`Unit` のコンストラクタは一つだけで，`unit` という引数を取らない関数です．C言語系のプログラミング言語には，何の値も返さない`void`関数の概念があります．一方 Lean では，すべての関数が引数を取り，値を返します．引数や返り値がないことは，代わりに `Unit` 型を使用して示すことができます．`Bool` が1ビットの情報を表すなら，`Unit` が表すのは0ビットの情報です．

<!--
`IO α` is the type of a program that, when executed, will either throw an exception or return a value of type `α`.
During execution, this program may have side effects.
These programs are referred to as `IO` _actions_.
Lean distinguishes between _evaluation_ of expressions, which strictly adheres to the mathematical model of substitution of values for variables and reduction of sub-expressions without side effects, and _execution_ of `IO` actions, which rely on an external system to interact with the world.
`IO.println` is a function from strings to `IO` actions that, when executed, write the given string to standard output.
Because this action doesn't read any interesting information from the environment in the process of emitting the string, `IO.println` has type `String → IO Unit`.
If it did return something interesting, then that would be indicated by the `IO` action having a type other than `Unit`.
-->
`IO α` は，「実行されると型 `α` の値を返すか，または例外をスローするようなプログラム」の型です．`IO α` 型を持つプログラムは，実行中に副作用を発生させる可能性があり，**IO アクション**と呼ばれます．これらのプログラムは **IO アクション**と呼ばれます．Lean は，変数への値の代入と副作用のない部分式の簡約という数学的モデルに厳密に従う「式の**評価**」と，外部システムに依存して世界と相互作用する「IOアクションの**実行**」を区別します．`IO.println` は文字列から IO アクションへの関数で，実行すると指定された文字列を標準出力に書き込みます．この IO アクションは文字列を出力する過程で環境から情報を読み取らないため，`IO.println` の型は `String → IO Unit` です．もし何か値を返すなら，返り値の型は `IO Unit` ではなくなります．

<!-- ## Functional Programming vs Effects -->
## 関数型プログラミングと作用

<!--
Lean's model of computation is based on the evaluation of mathematical expressions, in which variables are given exactly one value that does not change over time.
The result of evaluating an expression does not change, and evaluating the same expression again will always yield the same result.
-->

Lean の計算モデルは数学的な式の評価に基づいています．変数は正確に1つの値を持ち，時間が経っても変化することはありません．式を評価した結果も変わることがなく，同じ式を評価するたびに常に同じ結果が得られます．

<!--
On the other hand, useful programs must interact with the world.
A program that performs neither input nor output can't ask a user for data, create files on disk, or open network connections.
Lean is written in itself, and the Lean compiler certainly reads files, creates files, and interacts with text editors.
How can a language in which the same expression always yields the same result support programs that read files from disk, when the contents of these files might change over time?
-->
一方で，実用上プログラムは世界と相互作用する必要があります．入力や出力を行わないプログラムは，ユーザからデータを要求したり，ディスクにファイルを作成したり，ネットワーク接続を開いたりすることはできません．Lean は Lean 自身で記述されていますが，Lean コンパイラはファイルを読み込んだり，ファイルを作成したり，テキストエディタと対話したりします．ファイルの内容は時間によって変化しうるにも関わらず，「同じ式は常に同じ結果を返す」ような言語で，どうやって「ファイルをディスクから読み込む」というプログラムを実現しているのでしょうか？

<!--
This apparent contradiction can be resolved by thinking a bit differently about side effects.
Imagine a café that sells coffee and sandwiches.
This café has two employees: a cook who fulfills orders, and a worker at the counter who interacts with customers and places order slips.
The cook is a surly person, who really prefers not to have any contact with the world outside, but who is very good at consistently delivering the food and drinks that the café is known for.
In order to do this, however, the cook needs peace and quiet, and can't be disturbed with conversation.
The counter worker is friendly, but completely incompetent in the kitchen.
Customers interact with the counter worker, who delegates all actual cooking to the cook.
If the cook has a question for a customer, such as clarifying an allergy, they send a little note to the counter worker, who interacts with the customer and passes a note back to the cook with the result.
-->
この明らかな矛盾は，副作用について少し異なる考え方をすることで解決できます．とあるカフェを想像してみてください．コーヒーとサンドイッチを販売していて，従業員が2人います．このカフェには2人の従業員がいます．注文された料理を作るコックと，客と話して注文を取るカウンターの従業員の2人です．コックは不愛想な人物で，外の世界と接触したくないというのが本音ですが，そのカフェの名物である料理とドリンクを一貫して提供するのはとても得意です．しかし，そのためにはコックには平穏と静けさが必要で，会話で邪魔されてはいけません．カウンターの従業員はフレンドリーな人間ですが，キッチンの仕事は全くできません．客はカウンターの従業員と話し，カウンターの従業員はすべての調理をコックに任せます．コックが客に質問がある場合（アレルギーの確認など），カウンターの従業員に小さなメモを送り，その従業員が客とやり取りし，返事を書いたメモをコックに返します．

<!--
In this analogy, the cook is the Lean language.
When provided with an order, the cook faithfully and consistently delivers what is requested.
The counter worker is the surrounding run-time system that interacts with the world and can accept payments, dispense food, and have conversations with customers.
Working together, the two employees serve all the functions of the restaurant, but their responsibilities are divided, with each performing the tasks that they're best at.
Just as keeping customers away allows the cook to focus on making truly excellent coffee and sandwiches, Lean's lack of side effects allows programs to be used as part of formal mathematical proofs.
It also helps programmers understand the parts of the program in isolation from each other, because there are no hidden state changes that create subtle coupling between components.
The cook's notes represent `IO` actions that are produced by evaluating Lean expressions, and the counter worker's replies are the values that are passed back from effects.
-->

これは例え話で，コックは Lean 言語を表しています．注文が入ると，コックは一貫して注文されたものを忠実に提供します．カウンターの従業員は，世界と相互作用する周囲のランタイムシステムです．支払いを受け取り，食事を運び，お客さんと話をします．2人の従業員は協力して，レストランのすべての機能を提供しますが，彼らの責任は分かれており，それぞれが得意なタスクを実行します．客を遠ざけることでコックが本当においしいコーヒーやサンドイッチを作ることに集中できるのと同じように，Lean は副作用を隔離することで，プログラムを正式な数学的証明の一部として使うことができます．副作用がないことには，プログラムが理解しやすくなるという利点もあります．コンポーネント間の微妙な結合を生み出す隠れた状態変化がないため，プログラムを互いに切り離された部分の集まりとして理解できるからです．コックのメモは，Lean 式を評価して生成される IO アクションを表し，カウンターの従業員の返事は，実行結果から渡される値です．

<!--
This model of side effects is quite similar to how the overall aggregate of the Lean language, its compiler, and its run-time system (RTS) work.
Primitives in the run-time system, written in C, implement all the basic effects.
When running a program, the RTS invokes the `main` action, which returns new `IO` actions to the RTS for execution.
The RTS executes these actions, delegating to the user's Lean code to carry out computations.
From the internal perspective of Lean, programs are free of side effects, and `IO` actions are just descriptions of tasks to be carried out.
From the external perspective of the program's user, there is a layer of side effects that create an interface to the program's core logic.
-->
この副作用のモデルは，Lean 言語全体，コンパイラ，およびランタイムシステム（RTS）の総合的な動作方法とかなり類似しています．ランタイムシステム内のプリミティブな部分はCで書かれており，すべての基本的な作用を実装しています．プログラムを実行する際，RTSは `main` アクションを呼び出します．呼び出された `main` アクションは，実行されるべき新しい IO アクションをRTSに返します．RTS はこれらのアクションを実行し，ユーザの Lean コードに計算を実行させます．Lean という内部の視点からは，プログラムに副作用はなく，IO アクションは実行されるべきタスクの説明にすぎません．プログラムのユーザという外部の視点からは，副作用のレイヤが存在していて，プログラムのコアロジックへのインターフェースを形成しているように見えます．

<!-- ## Real-World Functional Programming -->
## 現実世界の関数型プログラミング

<!--
The other useful way to think about side effects in Lean is by considering `IO` actions to be functions that take the entire world as an argument and return a value paired with a new world.
In this case, reading a line of text from standard input _is_ a pure function, because a different world is provided as an argument each time.
Writing a line of text to standard output is a pure function, because the world that the function returns is different from the one that it began with.
Programs do need to be careful to never re-use the world, nor to fail to return a new world—this would amount to time travel or the end of the world, after all.
Careful abstraction boundaries can make this style of programming safe.
If every primitive `IO` action accepts one world and returns a new one, and they can only be combined with tools that preserve this invariant, then the problem cannot occur.
-->

Lean における副作用について考えるもう一つの有用な方法は，IO アクションを，世界全体を引数として受け取り，値と新しい世界の組を返す関数と考えることです．この場合，標準入力からテキストを読み取ることは純粋な関数です．なぜなら，異なる世界が引数として都度渡されるからです．標準出力にテキストを書き込むことも純粋な関数です．なぜなら，関数が返す世界は実行開始時のものと異なるからです．プログラムは世界を再利用しないように，新しい世界を返し損ねないように，よくよく注意する必要があります．それは結局，タイムトラベルまたは世界の終了を意味するからです．注意深い抽象化で副作用を隔離することにより，Lean は安全なプログラミングスタイルを実現しています．世界が与えられたら常に新しい世界を返すようなプリミティブ `IO` アクションを，その条件を保つツールとだけ組み合わせている限り，問題は発生しないのです．

<!--
This model cannot be implemented.
After all, the entire universe cannot be turned into a Lean value and placed into memory.
However, it is possible to implement a variation of this model with an abstract token that stands for the world.
When the program is started, it is provided with a world token.
This token is then passed on to the IO primitives, and their returned tokens are similarly passed to the next step.
At the end of the program, the token is returned to the operating system.
-->
このモデルは実装できません．結局のところ，宇宙全体を Lean の値に変えてメモリに配置することはできません．ただし，このモデルのバリエーションを，世界を表す抽象トークンを使用して実装することは可能です．プログラムが開始するとき，世界のトークンが渡されます．その後，このトークンは IO プリミティブに渡され，返されたトークンも同様に次のステップに渡されます．プログラムの終了時には，トークンは OS に返されます．

<!--
This model of side effects is a good description of how `IO` actions as descriptions of tasks to be carried out by the RTS are represented internally in Lean.
The actual functions that transform the real world are behind an abstraction barrier.
But real programs typically consist of a sequence of effects, rather than just one.
To enable programs to use multiple effects, there is a sub-language of Lean called `do` notation that allows these primitive `IO` actions to be safely composed into a larger, useful program.
-->
この副作用のモデルは，Lean 内部で RTS によって実行されるタスクの説明としての `IO` アクションがどのように表現されているかを良く説明しています．実際の世界を変える関数は抽象性の壁の背後に隠れています．しかし，実際のプログラムは通常，1つだけでなく一連の作用から成り立っています．プログラムが複数の作用を利用できるようにするために，Lean には `do` 記法と呼ばれるサブ言語があり，プリミティブな IO アクションを安全に組み合わせて，より大きく有用なプログラムを作ることができます．


<!-- ## Combining `IO` Actions -->
## `IO`アクションの結合

<!--
Most useful programs accept input in addition to producing output.
Furthermore, they may take decisions based on input, using the input data as part of a computation.
The following program, called `HelloName.lean`, asks the user for their name and then greets them:
-->

ほとんどの有用なプログラムは，出力を生成するだけでなく，入力を受け付けます．さらに，入力データをもとに計算を行い，決定を下すこともあります．次のプログラム，`HelloName.lean` は，ユーザに名前を尋ね，それから挨拶をします．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:all}}
```

<!--
In this program, the `main` action consists of a `do` block.
This block contains a sequence of _statements_, which can be both local variables (introduced using `let`) and actions that are to be executed.
Just as SQL can be thought of as a special-purpose language for interacting with databases, the `do` syntax can be thought of as a special-purpose sub-language within Lean that is dedicated to modeling imperative programs.
`IO` actions that are built with a `do` block are executed by executing the statements in order.
-->
このプログラムでは，`main`アクションは`do`ブロックで構成されています．do ブロックには，一連の**文**(statement)が含まれています．それぞれの文は，`let` によるローカル変数の定義だったり，実行されるアクションであったりします．SQL がデータベースと対話するための特別な目的の言語と考えることができるように， `do` 構文は，Lean 内で命令型プログラムをモデル化するための専用のサブ言語だと考えることができます．`do` ブロックで構築された IO アクションは，文を順番に実行することで実行されます．

<!--
This program can be run in the same manner as the prior program:
-->
このプログラムは，前のプログラムと同じ方法で実行できます．
```
{{#command {hello-name} {hello-name} {./run} {lean --run HelloName.lean}}}
```
<!--
If the user responds with `David`, a session of interaction with the program reads:
-->
ユーザが`David`と応答する場合，プログラムとの対話セッションが次のように表示されます．
```
{{#command_out {hello-name} {./run} }}
```

<!--
The type signature line is just like the one for `Hello.lean`:
-->
型のシグネチャ行は，`Hello.lean` のものと同じです．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:sig}}
```
<!--
The only difference is that it ends with the keyword `do`, which initiates a sequence of commands.
Each indented line following the keyword `do` is part of the same sequence of commands.
-->
唯一の違いは，キーワード `do` で終わることです．`do` はコマンドのシーケンスを開始します．キーワード `do` に続くインデントされた各行は, 同じ一連のコマンドの一部です．

<!--
The first two lines, which read:
-->
最初の2行は，次のように記載されています．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:setup}}
```
<!--
retrieve the `stdin` and `stdout` handles by executing the library actions `IO.getStdin` and `IO.getStdout`, respectively.
In a `do` block, `let` has a slightly different meaning than in an ordinary expression.
Ordinarily, the local definition in a `let` can be used in just one expression, which immediately follows the local definition.
In a `do` block, local bindings introduced by `let` are available in all statements in the remainder of the `do` block, rather than just the next one.
Additionally, `let` typically connects the name being defined to its definition using `:=`, while some `let` bindings in `do` use a left arrow (`←` or `<-`) instead.
Using an arrow means that the value of the expression is an `IO` action that should be executed, with the result of the action saved in the local variable.
In other words, if the expression to the right of the arrow has type `IO α`, then the variable has type `α` in the remainder of the `do` block.
`IO.getStdin` and `IO.getStdout` are `IO` actions in order to allow `stdin` and `stdout` to be locally overridden in a program, which can be convenient.
If they were global variables as in C, then there would be no meaningful way to override them, but `IO` actions can return different values each time they are executed.
-->
これらの行は，ライブラリアクション `IO.getStdin` および `IO.getStdout` を実行して `stdin` と `stdout` のハンドルを取得します．`do` ブロックの中の `let` は，通常の式の中の `let` とはやや異なる意味を持ちます．通常，`let` で導入されたローカル定義は，すぐにそのローカル定義に続く式でしか使用できません．`do` ブロックでは，`let` によって導入されたローカル束縛は，次の式だけでなく，`do` ブロックの残りのすべての文で使用できます．さらに，通常 `let` は `:=` を使って定義される名前とその定義を結びつけますが，`do` 内部の `let` 束縛においては，代わりに左矢印（`←`または `<-`）を使うことがあります．矢印を使用するということは，式の値が IO アクションであり，そのアクションの実行結果をローカル変数に保存するということを意味します．言い換えれば，矢印の右側の式が型 `IO α` を持つ場合，その変数は `do` ブロックの残りの部分で型 `α` を持ちます．`IO.getStdin` および `IO.getStdout` は `stdin` と `stdout` をプログラム内でローカルに上書きできるようにするための便利な IO アクションです．C 言語のように `stdin` と `stdout` がグローバル変数であったら，（Lean では一度束縛した値は変更できないので）これを上書きすることはできませんが，IO アクションなら実行ごとに異なる値を返すことができます．

<!--
The next part of the `do` block is responsible for asking the user for their name:
-->
`do` ブロックの次の部分は，ユーザに名前を尋ねます．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:question}}
```
<!--
The first line writes the question to `stdout`, the second line requests input from `stdin`, and the third line removes the trailing newline (plus any other trailing whitespace) from the input line.
The definition of `name` uses `:=`, rather than `←`, because `String.dropRightWhile` is an ordinary function on strings, rather than an `IO` action.
-->
最初の行は質問を `stdout` に書き込み，2番目の行は `stdin` から入力をリクエストし，3番目の行は入力行から末尾の改行（および末尾の空白）を削除します．`name` の定義では，`String.dropRightWhile` は IO アクションではなく，通常の文字列関数であるため，`←` ではなく `:=` を使用しています．

<!--
Finally, the last line in the program is:
-->
最後に，プログラムの最終行は以下のようなものです．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:answer}}
```
<!--
It uses [string interpolation](../getting-to-know/conveniences.md#string-interpolation) to insert the provided name into a greeting string, writing the result to `stdout`.
-->
ここでは[文字列補間](../getting-to-know/conveniences.md#string-interpolation)を使って, 与えられた名前を挨拶の文字列に挿入し，その結果を `stdout` に書き込んでいます．
