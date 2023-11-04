<!--
# Running a Program

The simplest way to run a Lean program is to use the `--run` option to the Lean executable.
Create a file called `Hello.lean` and enter the following contents:
-->
# プログラムの実行

Leanプログラムを実行する最も簡単な方法は，Leanの実行ファイルに`--run`オプションを使用することです．`Hello.lean`という名前のファイルを作成し，以下の内容を入力してみましょう．
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
このプログラムは`{{#command_out {hello} {lean --run Hello.lean} }}`を表示して終了します．

<!--
## Anatomy of a Greeting

When Lean is invoked with the `--run` option, it invokes the program's `main` definition.
In programs that do not take command-line arguments, `main` should have type `IO Unit`.
This means that `main` is not a function, because there are no arrows (`→`) in its type.
Instead of being a function that has side effects, `main` consists of a description of effects to be carried out.
-->
## 挨拶の構造

Leanを`--run`オプション付きで実行すると，プログラムの`main`定義が呼び出されます．コマンドライン引数を取らないプログラムの場合，`main`の型は`IO Unit`であるべきです．この型には矢印（`→`）が含まれていないため，`main`は関数ではないことを意味します．つまり，`main`は副作用を持つ関数ではなく，実行される作用の説明から成り立っています．

<!--
As discussed in [the preceding chapter](../getting-to-know/polymorphism.md), `Unit` is the simplest inductive type.
It has a single constructor called `unit` that takes no arguments.
Languages in the C tradition have a notion of a `void` function that does not return any value at all.
In Lean, all functions take an argument and return a value, and the lack of interesting arguments or return values can be signaled by using the `Unit` type instead.
If `Bool` represents a single bit of information, `Unit` represents zero bits of information.
-->
[前の章](../getting-to-know/polymorphism.md)で議論したように，`Unit`は最も単純な依存型です．`unit`という引数を取らない単一のコンストラクタを持っています．C言語系のプログラミング言語には，何の値も返さない`void`関数の概念があります．一方Leanでは，すべての関数が引数を取り，値を返します．興味深い引数や返り値がないことは，代わりに`Unit`型を使用して示すことができます．`Bool`が情報の1ビットを表すとすると，`Unit`は情報の0ビットを表します．

<!--
`IO α` is the type of a program that, when executed, will either throw an exception or return a value of type `α`.
During execution, this program may have side effects.
These programs are referred to as `IO` _actions_.
Lean distinguishes between _evaluation_ of expressions, which strictly adheres to the mathematical model of substitution of values for variables and reduction of sub-expressions without side effects, and _execution_ of `IO` actions, which rely on an external system to interact with the world.
`IO.println` is a function from strings to `IO` actions that, when executed, write the given string to standard output.
Because this action doesn't read any interesting information from the environment in the process of emitting the string, `IO.println` has type `String → IO Unit`.
If it did return something interesting, then that would be indicated by the `IO` action having a type other than `Unit`.
-->
`IO α`は，実行されると例外をスローするか，型`α`の値を返すプログラムの型です．実行中，このプログラムには副作用が発生する可能性があります．これらのプログラムは`IO` **アクション**　と呼ばれます．Leanは，数学的な「変数への値の代入」と「副作用のない部分式の簡約」に厳密に従う **評価** と，世界と対話するために外部システムを使用する **実行** の区別をしています．`IO.println`は文字列から`IO`アクションへの関数で，実行すると指定された文字列を標準出力に書き込みます．このアクションは文字列を出力する過程で環境から興味深い情報を読み取らないため，`IO.println`の型は`String → IO Unit`です．もし何か興味深いものを返す場合，それは`IO`アクションの型が`Unit`以外であることで示されるでしょう．

<!--
## Functional Programming vs Effects

Lean's model of computation is based on the evaluation of mathematical expressions, in which variables are given exactly one value that does not change over time.
The result of evaluating an expression does not change, and evaluating the same expression again will always yield the same result.
-->
## 関数型プログラミングと作用

Leanの計算モデルは数学的な式の評価に基づいており，変数は時間の経過とともに変わることがなく，正確に1つの値を持っています．式を評価した結果も変わることがなく，同じ式を評価するたびに常に同じ結果が得られます．

<!--
On the other hand, useful programs must interact with the world.
A program that performs neither input nor output can't ask a user for data, create files on disk, or open network connections.
Lean is written in itself, and the Lean compiler certainly reads files, creates files, and interacts with text editors.
How can a language in which the same expression always yields the same result support programs that read files from disk, when the contents of these files might change over time?
-->
一方で，有用なプログラムは世界と対話する必要があります．入力や出力を行わないプログラムは，ユーザからデータを要求したり，ディスクにファイルを作成したり，ネットワーク接続を開いたりすることはできません．LeanはLean自身で記述されていますが，Leanコンパイラはファイルを読み込んだり，ファイルを作成したり，テキストエディタと対話したりします．このような時間の経過とともに内容の変化する可能性があるファイルをディスクから読み込むというプログラムを，同じ式は常に同じ結果を返すという性質を持つ言語ではどのようにサポートするのでしょうか？

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
この明らかな矛盾は，副作用について少し異なる考え方をすることで解決できます．コーヒーやサンドイッチを販売するカフェを想像してみてください．このカフェには2人の従業員がいます．注文を満たす料理人と，顧客と対話し注文伝票を出すカウンターの従業員です．料理人は外部の世界と接触することを好まないぶっきらぼうな人間なものの，カフェで有名な料理と飲み物を一貫して提供するのが得意です．しかし，これを行うためには料理人は平和と静けさが必要で，会話で邪魔されてはいけません．カウンターの従業員はフレンドリーな人間ですが，キッチンの仕事は全くできません．顧客はカウンターの従業員と対話し，カウンターの従業員はすべての調理を料理人に委任します．料理人が顧客に質問がある場合（例えばアレルギーなどを確認する場合），カウンターの従業員に小さなメモを送り，カウンターの従業員が顧客とやり取りし，結果をメモで料理人に返します．

<!--
In this analogy, the cook is the Lean language.
When provided with an order, the cook faithfully and consistently delivers what is requested.
The counter worker is the surrounding run-time system that interacts with the world and can accept payments, dispense food, and have conversations with customers.
Working together, the two employees serve all the functions of the restaurant, but their responsibilities are divided, with each performing the tasks that they're best at.
Just as keeping customers away allows the cook to focus on making truly excellent coffee and sandwiches, Lean's lack of side effects allows programs to be used as part of formal mathematical proofs.
It also helps programmers understand the parts of the program in isolation from each other, because there are no hidden state changes that create subtle coupling between components.
The cook's notes represent `IO` actions that are produced by evaluating Lean expressions, and the counter worker's replies are the values that are passed back from effects.
-->

このアナロジーでは，料理人はLean言語を表しています．注文が与えられると，料理人は忠実で一貫性のあるサービスを提供します．カウンターの従業員は，世界と対話し，支払いを受け取り，食事を提供し，顧客との対話を行う周囲のランタイムシステムです．2人の従業員は協力して，レストランのすべての機能を提供しますが，彼らの責任は分かれており，それぞれが得意なタスクを実行します．顧客を遠ざけることで，料理人は美味しいコーヒーとサンドイッチを作ることに集中できるのと同様に，Leanの副作用のなさはプログラムが形式的な数学的証明の一部として使用できるようにします．また，隠れた状態の変化がコンポーネント間の微妙な結合を作成することがないため，プログラムの部分を互いに分離して理解するのを助けます．料理人のメモは，Lean式を評価して生成される`IO`アクションを表し，カウンターの従業員の返答は作用結果から渡される値です．

<!--
This model of side effects is quite similar to how the overall aggregate of the Lean language, its compiler, and its run-time system (RTS) work.
Primitives in the run-time system, written in C, implement all the basic effects.
When running a program, the RTS invokes the `main` action, which returns new `IO` actions to the RTS for execution.
The RTS executes these actions, delegating to the user's Lean code to carry out computations.
From the internal perspective of Lean, programs are free of side effects, and `IO` actions are just descriptions of tasks to be carried out.
From the external perspective of the program's user, there is a layer of side effects that create an interface to the program's core logic.
-->
この副作用のモデルは，Lean言語全体，そのコンパイラ，およびランタイムシステム（RTS）の総合的な動作方法とかなり類似しています．ランタイムシステム内のプリミティブな部分はCで書かれており，すべての基本的な作用を実装しています．プログラムを実行する際，RTSは`main`アクションを呼び出し，新しい`IO`アクションを実行するためにRTSに返します．RTSはこれらのアクションを実行し，ユーザのLeanコードに計算を実行するよう委任します．Leanの内部の視点からは，プログラムには副作用がなく，`IO`アクションは実行されるべきタスクの説明にすぎません．プログラムのユーザの外部の視点からは，プログラムのコアロジックへのインターフェースを作成する副作用のレイヤーが存在します．

<!--
## Real-World Functional Programming

The other useful way to think about side effects in Lean is by considering `IO` actions to be functions that take the entire world as an argument and return a value paired with a new world.
In this case, reading a line of text from standard input _is_ a pure function, because a different world is provided as an argument each time.
Writing a line of text to standard output is a pure function, because the world that the function returns is different from the one that it began with.
Programs do need to be careful to never re-use the world, nor to fail to return a new world—this would amount to time travel or the end of the world, after all.
Careful abstraction boundaries can make this style of programming safe.
If every primitive `IO` action accepts one world and returns a new one, and they can only be combined with tools that preserve this invariant, then the problem cannot occur.
-->
## 現実世界の関数型プログラミング

Leanにおける副作用について考えるもう一つの有用な方法は，`IO`アクションを，世界全体を引数として受け取り，新しい世界と値を返す関数と考えることです．この場合，標準入力からテキストを読み取ることは純粋な関数です．なぜなら，異なる世界が引数として都度渡されるからです．標準出力にテキストを書き込むことも純粋な関数です．なぜなら，関数が返す世界は開始時のものと異なるからです．プログラムは世界を再利用しないように注意し，新しい世界を返さないようにする必要があります．それは結局，タイムトラベルまたは世界の終了につながることになるからです．注意深い抽象性の境界によって，このプログラミングスタイルは安全になります．すべてのプリミティブな`IO`アクションが一つの世界を受け入れ，新しい世界を返し，この不変条件を保つツールとしか組み合わせることができない場合，問題は発生しないのです．

<!--
This model cannot be implemented.
After all, the entire universe cannot be turned into a Lean value and placed into memory.
However, it is possible to implement a variation of this model with an abstract token that stands for the world.
When the program is started, it is provided with a world token.
This token is then passed on to the IO primitives, and their returned tokens are similarly passed to the next step.
At the end of the program, the token is returned to the operating system.
-->
このモデルは実装できません．結局のところ，宇宙全体をLeanの値に変えてメモリに配置することはできません．ただし，このモデルのバリエーションを，世界を表す抽象トークンを使用して実装することは可能です．プログラムが開始するとき，世界のトークンが渡されます．その後，このトークンはIOプリミティブに渡され，返されたトークンも同様に次のステップに渡されます．プログラムの終了時には，トークンはオペレーティングシステムに返されます．

<!--
This model of side effects is a good description of how `IO` actions as descriptions of tasks to be carried out by the RTS are represented internally in Lean.
The actual functions that transform the real world are behind an abstraction barrier.
But real programs typically consist of a sequence of effects, rather than just one.
To enable programs to use multiple effects, there is a sub-language of Lean called `do` notation that allows these primitive `IO` actions to be safely composed into a larger, useful program.
-->
この副作用のモデルは，Lean内部でRTSによって実行されるタスクの説明としての`IO`アクションがどのように表現されているかを良く説明しています．実際の世界を変える関数は抽象性の壁の背後に隠れています．しかし，実際のプログラムは通常，1つだけでなく一連の作用から成り立っています．プログラムが複数の作用を働かせられるようにするため，`do`表記と呼ばれるLeanのサブ言語があり，これらの基本的な`IO`アクションを安全に組み合わせて大規模で有用なプログラムに構築できるようになります．


<!--
## Combining `IO` Actions

Most useful programs accept input in addition to producing output.
Furthermore, they may take decisions based on input, using the input data as part of a computation.
The following program, called `HelloName.lean`, asks the user for their name and then greets them:
-->
## `IO`アクションの結合

ほとんどの有用なプログラムは，出力の生成に加えて入力も受け付けます．さらに，それらは入力に基づいて決定を下すことがあり，入力データを計算の一部として使用することがあります．次のプログラム，`HelloName.lean`は，ユーザに名前を尋ね，それから挨拶をします．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:all}}
```

<!--
In this program, the `main` action consists of a `do` block.
This block contains a sequence of _statements_, which can be both local variables (introduced using `let`) and actions that are to be executed.
Just as SQL can be thought of as a special-purpose language for interacting with databases, the `do` syntax can be thought of as a special-purpose sub-language within Lean that is dedicated to modeling imperative programs.
`IO` actions that are built with a `do` block are executed by executing the statements in order.
-->
このプログラムでは，`main`アクションは`do`ブロックで構成されています．このブロックには，**ステートメント** のシーケンスが含まれます．ステートメントは，ローカル変数（`let`を使用して導入）と実行されるアクションの両方である可能性があります．SQLがデータベースと対話するための特別な目的の言語と考えることができるように，`do`構文は，Lean内で命令型プログラムをモデル化するために専用のサブ言語と考えることができます．`do`ブロックで構築された`IO`アクションは，ステートメントを順番に実行することで実行されます．

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
型のシグネチャ行は，`Hello.lean`のものと同じです．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:sig}}
```
<!--
The only difference is that it ends with the keyword `do`, which initiates a sequence of commands.
Each indented line following the keyword `do` is part of the same sequence of commands.
-->
唯一の違いは，キーワード`do`で終わることで，コマンドのシーケンスを開始します．`do`のキーワードに続くインデントされた各行は，同じコマンドのシーケンスの一部です．

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
これらの行は，ライブラリアクション`IO.getStdin`および`IO.getStdout`を実行して`stdin`と`stdout`のハンドルを取得します．`do`ブロックでは，通常の式とは異なり，`let`にはやや異なる意味があります．通常，`let`で導入されたローカル定義は，すぐにそのローカル定義に続く式でしか使用できません．`do`ブロックでは，`let`によって導入されたローカル束縛は，次の式だけでなく，`do`ブロックの残りのすべてのステートメントで使用できます．さらに，通常，`let`は名前を定義の右側に`:=`を使用しますが，`do`の一部の`let`束縛では，代わりに左矢印(`←`または`<-`)を使用します．矢印を使用すると，式の右側の値が実行されるべき`IO`アクションで，そのアクションの結果がローカル変数に保存されます．言い換えれば，矢印の右側の式が型`IO α`を持つ場合，その変数は`do`ブロックの残りの部分で型`α`を持ちます．`IO.getStdin`および`IO.getStdout`は`stdin`と`stdout`をプログラム内でローカルに上書きできるようにするために`IO`アクションです．これは便利なことです．Cのようにグローバル変数であった場合，これらを上書きする有意義な方法はありませんが，`IO`アクションは実行されるたびに異なる値を返すことができます．

<!--
The next part of the `do` block is responsible for asking the user for their name:
-->
`do`ブロックの次の部分は，ユーザに名前を尋ねます．
```lean
{{#include ../../../examples/hello-name/HelloName.lean:question}}
```
<!--
The first line writes the question to `stdout`, the second line requests input from `stdin`, and the third line removes the trailing newline (plus any other trailing whitespace) from the input line.
The definition of `name` uses `:=`, rather than `←`, because `String.dropRightWhile` is an ordinary function on strings, rather than an `IO` action.
-->
最初の行は質問を`stdout`に書き込み，2番目の行は`stdin`から入力をリクエストし，3番目の行は入力行から末尾の改行（および他の末尾の空白）を削除します．`name`の定義では，`String.dropRightWhile`は`IO`アクションではなく，通常の文字列関数であるため，`:=`ではなく`←`を使用しています．

<!--
Finally, the last line in the program is:
-->
最後に，プログラムの最終行は以下のようなものです．
```
{{#include ../../../examples/hello-name/HelloName.lean:answer}}
```
<!--
It uses [string interpolation](../getting-to-know/conveniences.md#string-interpolation) to insert the provided name into a greeting string, writing the result to `stdout`.
-->
この行は，提供された名前を挨拶の文字列に挿入するために[文字列補間](../getting-to-know/conveniences.md#string-interpolation)を使用し，その結果を`stdout`に書き込みます．

