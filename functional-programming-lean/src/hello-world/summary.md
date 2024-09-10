<!--
# Summary
-->

# まとめ

<!--
## Evaluation vs Execution
-->

## 評価 vs 実行

<!--
Side effects are aspects of program execution that go beyond the evaluation of mathematical expressions, such as reading files, throwing exceptions, or triggering industrial machinery.
While most languages allow side effects to occur during evaluation, Lean does not.
Instead, Lean has a type called `IO` that represents _descriptions_ of programs that use side effects.
These descriptions are then executed by the language's run-time system, which invokes the Lean expression evaluator to carry out specific computations.
Values of type `IO α` are called _`IO` actions_.
The simplest is `pure`, which returns its argument and has no actual side effects.
-->

副作用とはファイルの読み込み・例外の発生・産業機械の起動など、数式の評価を超えたプログラムの実行についての側面です。ほとんどの言語では評価中に副作用が発生することを許可していますが、Leanでは許可していません。その代わりに、Leanには `IO` という型があり、副作用を使用するプログラムの **記述** を表現します。これらの記述は言語のランタイムシステムによって実行されます。このランタイムシステムはLeanの式の評価器を呼び出して特定の計算を実行します。`IO α` 型の値は **`IO` アクション** と呼ばれます。最も単純なものは `pure` で、これは引数をそのまま返し、実際の副作用を持ちません。

<!--
`IO` actions can also be understood as functions that take the whole world as an argument and return a new world in which the side effect has occurred.
Behind the scenes, the `IO` library ensures that the world is never duplicated, created, or destroyed.
While this model of side effects cannot actually be implemented, as the whole universe is too big to fit in memory, the real world can be represented by a token that is passed around through the program.
-->

`IO` アクションは世界全体を引数として受け取り、副作用が発生した新しい世界を返す関数として理解することもできます。その裏では、`IO` ライブラリは世界が決して複製されたり、新しく作られたり、破壊されたりしないことを保証しています。全宇宙は大きすぎてメモリに収まらないため、この副作用のモデルを実際に実装することはできませんが、現実の世界をプログラム中で受け渡されるトークンとして表現することができます。

<!--
An `IO` action `main` is executed when the program starts.
`main` can have one of three types:
-->

`IO` アクション `main` はプログラムが開始された時に実行されます。`main` は以下3つのうちどれかの型を持ちます：

 <!--
 * `main : IO Unit` is used for simple programs that cannot read their command-line arguments and always return exit code `0`,
 * `main : IO UInt32` is used for programs without arguments that may signal success or failure, and
 * `main : List String → IO UInt32` is used for programs that take command-line arguments and signal success or failure.
-->

 * `main : IO Unit` はコマンドライン引数を読むことができず、常に終了コード `0` を返す単純なプログラムに使われます。
 * `main : IO UInt32` は成功または失敗を知らせる引数のないプログラムに使われます。
 * `main : List String → IO UInt32` はコマンドライン引数を取り、成功または失敗を知らせるプログラムに使われます。

<!--
## `do` Notation
-->

## `do` 記法

<!--
The Lean standard library provides a number of basic `IO` actions that represent effects such as reading from and writing to files and interacting with standard input and standard output.
These base `IO` actions are composed into larger `IO` actions using `do` notation, which is a built-in domain-specific language for writing descriptions of programs with side effects.
A `do` expression contains a sequence of _statements_, which may be:
-->

Leanの標準ライブラリは、ファイルからの読み込みや書き込み、標準入出力とのやり取りなどの作用を表す基本的な `IO` アクションを数多く提供しています。これらの基本的な `IO` アクションは、副作用を持つプログラムを書くための組み込みドメイン固有言語である `do` 記法を使ってより翁 `IO` アクションにまとめることができます。`do` 記法は以下のような一連の **文** を含んでいます：

 <!--
 * expressions that represent `IO` actions,
 * ordinary local definitions with `let` and `:=`, where the defined name refers to the value of the provided expression, or
 * local definitions with `let` and `←`, where the defined name refers to the result of executing the value of the provided expression.
-->

 * `IO` アクションを表す式
 * `let` と `:=` を使った通常のローカル定義で、定義された名前は渡された式の値を指します。
 * `let` と `←` を使ったローカル定義で、定義された名前は渡された式の値を実行した結果を指します。

<!--
`IO` actions that are written with `do` are executed one statement at a time.
-->

`do` で記述された `IO` 一度に1文ずつ実行されます。
 
<!--
Furthermore, `if` and `match` expressions that occur immediately under a `do` are implicitly considered to have their own `do` in each branch.
Inside of a `do` expression, _nested actions_ are expressions with a left arrow immediately under parentheses.
The Lean compiler implicitly lifts them to the nearest enclosing `do`, which may be implicitly part of a branch of a `match` or `if` expression, and gives them a unique name.
This unique name then replaces the origin site of the nested action.
-->

さらに、`do` の直下にある `if` 式と `match` 式は、暗黙的にそれぞれの分岐に `do` があると見なされます。`do` 式の内部では、**ネストされたアクション** は括弧の直下にある左矢印で記述された式です。Leanコンパイラは、暗黙的にそれらを最も近い `do` （`match` や `if` の分岐に暗黙的にあるものも含みます）に結び付け、一意な名前を付けます。この一意な名前によってネストされたアクションのもともとの位置を置き換えます。

<!--
## Compiling and Running Programs
-->

## プログラムのコンパイルと実行

<!--
A Lean program that consists of a single file with a `main` definition can be run using `lean --run FILE`.
While this can be a nice way to get started with a simple program, most programs will eventually graduate to a multiple-file project that should be compiled before running.
-->

`lean --run FILE` というコマンドで `main` 定義を持つ単一ファイルで構成されるLeanプログラムを実行することができます。これは簡単なプログラムの実行には良い方法ですが、ほとんどのプログラムは最終的に複数のファイルを持つプロジェクトへと成長するので、実行する前にコンパイルする必要があります。

<!--
Lean projects are organized into _packages_, which are collections of libraries and executables together with information about dependencies and a build configuration.
Packages are described using Lake, a Lean build tool.
Use `lake new` to create a Lake package in a new directory, or `lake init` to create one in the current directory.
Lake package configuration is another domain-specific language.
Use `lake build` to build a project.
-->

Leanのプロジェクトは、依存関係やビルド構成に関する情報とともにライブラリや実行可能ファイルのコレクションである **パッケージ** へと編成されます。パッケージはLeanのビルドツールであるLakeを使って記述します。新しいディレクトリにLakeパッケージを作成するには `lake new` を、現在のディレクトリに作成するには `lake init` を使用します。Lakeのパッケージ構成もドメイン固有言語です。プロジェクトをビルドするには `lake build` を使用します。

<!--
## Partiality
-->

## 部分性

<!--
One consequence of following the mathematical model of expression evaluation is that every expression must have a value.
This rules out both incomplete pattern matches that fail to cover all constructors of a datatype and programs that can fall into an infinite loop.
Lean ensures that all `match` expressions cover all cases, and that all recursive functions are either structurally recursive or have an explicit proof of termination.
-->

式評価の数学的モデルに従うことから導かれる結論の1つとして、すべての式が値を持たなければならないということがあります。これにより、データ型のすべてのコンストラクタをカバーできない不完全なパターンマッチと無限ループに陥る可能性のあるプログラムの両方が除外されます。Leanはすべての `match` 式がすべてのケースをカバーすること、すべての再帰関数は構造的に再帰的であるか停止の明示的な証明があることを保証します。

<!--
However, some real programs require the possibility of looping infinitely, because they handle potentially-infinite data, such as POSIX streams.
Lean provides an escape hatch: functions whose definition is marked `partial` are not required to terminate.
This comes at a cost.
Because types are a first-class part of the Lean language, functions can return types.
Partial functions, however, are not evaluated during type checking, because an infinite loop in a function could cause the type checker to enter an infinite loop.
Furthermore, mathematical proofs are unable to inspect the definitions of partial functions, which means that programs that use them are much less amenable to formal proof.
-->

しかし、実際のプログラムの中にはPOSIXのストリームのように無限ループする可能性のあるデータを扱うために、無限ループの可能性を必要とするものがあります。これに対してLeanは逃げ道を用意しています：定義が `partial` とマークされた関数は停止する必要がありません。これには代償が伴います。型はLean言語の第一級であるため、関数は型を返すことができます。しかし、関数が無限ループに入ると型チェッカが無限ループも入る可能性があるため、部分関数は型チェック中に評価されません。さらに、数学的な証明では部分関数の定義を検査することができないため、部分関数を使用するプログラムは形式的な証明にあまり適していません。
