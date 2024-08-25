<!--
# More do Features
-->

# さらなる `do` の機能

<!--
Lean's `do`-notation provides a syntax for writing programs with monads that resembles imperative programming languages.
In addition to providing a convenient syntax for programs with monads, `do`-notation provides syntax for using certain monad transformers.
-->

Leanの `do` 記法はモナドを使ったプログラムを書くにあたって命令型プログラミング言語と同じように書くための構文を提供しています。`do` 記法はモナドを使ったプログラムのための構文を提供するだけでなく、ある種のモナド変換子を使うための構文を提供しています。

<!--
## Single-Branched `if`
-->

## 分岐1つの `if`

<!--
When working in a monad, a common pattern is to carry out a side effect only if some condition is true.
For instance, `countLetters` contains a check for vowels or consonants, and letters that are neither have no effect on the state.
This is captured by having the `else` branch evaluate to `pure ()`, which has no effects:
-->

モナドを扱うときによくあるパターンはある条件が真である場合にのみ副作用を実行することです。例えば、`countLetters` は母音か子音かのチェックを含んでおり、どちらでもない文字は状態に影響を与えません。これは `else` ブランチが `pure ()` に評価されることで捕捉されます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLettersModify}}
```

<!--
When an `if` is a statement in a `do`-block, rather than being an expression, then `else pure ()` can simply be omitted, and Lean inserts it automatically.
The following definition of `countLetters` is completely equivalent:
-->

`if` が式ではなく、`do` ブロック内の文である場合、`else pure ()` は単に省略することができ、Leanは自動的に補完します。以下の `countLetters` の定義は完全に等価です：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countLettersNoElse}}
```
<!--
A program that uses a state monad to count the entries in a list that satisfy some monadic check can be written as follows:
-->

状態モナドを使ってあるモナド的なチェックを満たすリストの項目を数えるプログラムは次のように書くことができます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean count}}
```

<!--
Similarly, `if not E1 then STMT...` can instead be written `unless E1 do STMT...`.
The converse of `count` that counts entries that don't satisfy the monadic check can be written by replacing `if` with `unless`:
-->

同様に、`if not E1 then STMT...` は代わりに `unless E1 do STMT...` と書くことができます。モナドチェックを満たさない要素をカウントする `count` の逆は `if` を `unless` に置き換えて書くことができます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countNot}}
```

<!--
Understanding single-branched `if` and `unless` does not require thinking about monad transformers.
They simply replace the missing branch with `pure ()`.
The remaining extensions in this section, however, require Lean to automatically rewrite the `do`-block to add a local transformer on top of the monad that the `do`-block is written in.
-->

分岐1つの `if` と `unless` を理解するのに、モナド変換子について考える必要はありません。これらは単に足りない分岐を `pure ()` に置き換えるだけです。しかし本節の残りで紹介する拡張機能は、Leanが `do` ブロックを自動的に書き換えて、`do` ブロックが書かれているモナドの上にローカルな変換子を追加する必要があります。

<!--
## Early Return
-->

## 早期リターン

<!--
The standard library contains a function `List.find?` that returns the first entry in a list that satisfies some check.
A simple implementation that doesn't make use of the fact that `Option` is a monad loops over the list using a recursive function, with an `if` to stop the loop when the desired entry is found:
-->

標準ライブラリにはあるチェックを満たすリストの最初の要素を返す `List.find?` という関数があります。`Option` がモナドであることを利用しないシンプルな実装では、再帰関数を使ってリスト上をループし、お望みの要素のところで `if` でループを止めます。

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuhSimple}}
```

<!--
Imperative languages typically sport the `return` keyword that aborts the execution of a function, immediately returning some value to the caller.
In Lean, this is available in `do`-notation, and `return` halts the execution of a `do`-block, with `return`'s argument being the value returned from the monad.
In other words, `List.find?` could have been written like this:
-->

命令型言語では関数の実行を中断するのに通常 `return` キーワードを用いて呼び出し元に値を返します。Leanでは、これを `do` 記法で使用することができます。`return` は `do` ブロックの実行を停止し、`return` に渡された引数をそのモナドから返される値とします。つまり、`List.find?` は以下のように書くことができます。

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuhFancy}}
```

<!--
Early return in imperative languages is a bit like an exception that can only cause the current stack frame to be unwound.
Both early return and exceptions terminate execution of a block of code, effectively replacing the surrounding code with the thrown value.
Behind the scenes, early return in Lean is implemented using a version of `ExceptT`.
Each `do`-block that uses early return is wrapped in an exception handler (in the sense of the function `tryCatch`).
Early returns are translated to throwing the value as an exception, and the handlers catch the thrown value and return it immediately.
In other words, the `do`-block's original return value type is also used as the exception type.
-->

命令型言語の早期リターンは現在のスタックフレームを巻き戻すだけの例外に似ています。早期リターンと例外はどちらもコードブロックの実行を終了し、そのコードの結果を投げられた例外の値で効率的に置き換えます。裏側では、Leanにおいての早期リターンは `ExceptT` を用いて実装されています。早期リターンを用いる各 `do` ブロックは例外ハンドラ（関数 `tryCatch` において用いられる意味）でラップされています。早期リターンは例外として値を投げることに変換され、ハンドラは投げられた値をキャッチしてそのまま返します。言い換えると、`do` ブロックの元の戻り値の型は例外の型としても使われます。

<!--
Making this more concrete, the helper function `runCatch` strips a layer of `ExceptT` from the top of a monad transformer stack when the exception type and return type are the same:
-->

これをより具体的にすると、補助関数 `runCatch` は例外の型と戻り値の型が同じ時にモナド変換子のスタックの一番上から `ExceptT` の層を取り除きます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean runCatch}}
```
<!--
The `do`-block in `List.find?` that uses early return is translated to a `do`-block that does not use early return by wrapping it in a use of `runCatch`, and replacing early returns with `throw`:
-->

`List.find?` を `do` ブロックで早期リターンを使用する実装から使用しない実装に変換するには、`do` ブロックを `runCatch` で包み、早期リターンを `throw` に置き換えます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean desugaredFindHuh}}
```

<!--
Another situation in which early return is useful is command-line applications that terminate early if the arguments or input are incorrect.
Many programs begin with a section that validates arguments and inputs before proceeding to the main body of the program.
The following version of [the greeting program `hello-name`](../hello-world/running-a-program.md) checks that no command-line arguments were provided:
-->

早期リターンを用いた方が良い別のシチュエーションとして、引数や入力が正しくない場合に早期に終了するコマンドラインアプリがあります。多くのプログラムでは、プログラム本体に進む前に引数や入力を検証するセクションから始まります。次のバージョンの [挨拶プログラム `hello-name`](../hello-world/running-a-program.md) はコマンドライン引数が与えられていないことをチェックします：

```lean
{{#include ../../../examples/early-return/EarlyReturn.lean:main}}
```
<!--
Running it with no arguments and typing the name `David` yields the same result as the previous version:
-->

これを引数無しで実行し、`David` という名前を入力すると以前のものと同じ結果になります：

```
$ {{#command {early-return} {early-return} {./run} {lean --run EarlyReturn.lean}}}
{{#command_out {early-return} {./run} }}
```

<!--
Providing the name as a command-line argument instead of an answer causes an error:
-->

しかし入力待ちへの回答の代わりにコマンドライン引数として名前を指定するとエラーになります：

```
$ {{#command {early-return} {early-return} {./too-many-args} {lean --run EarlyReturn.lean David}}}
{{#command_out {early-return} {./too-many-args} }}
```

<!--
And providing no name causes the other error:
-->

そして名前を入力しない場合は別のエラーになります：

```
$ {{#command {early-return} {early-return} {./no-name} {lean --run EarlyReturn.lean}}}
{{#command_out {early-return} {./no-name} }}
```

<!--
The program that uses early return avoids needing to nest the control flow, as is done in this version that does not use early return:
-->

上記で見たように早期リターンを使うプログラムでは制御の流れをネストする必要が無くなりますが、これを早期リターンを使わないように実装すると以下のようになります：

```lean
{{#include ../../../examples/early-return/EarlyReturn.lean:nestedmain}}
```

<!--
One important difference between early return in Lean and early return in imperative languages is that Lean's early return applies only to the current `do`-block.
When the entire definition of a function is in the same `do` block, this difference doesn't matter.
But if `do` occurs underneath some other structures, then the difference becomes apparent.
For example, given the following definition of `greet`:
-->

早期リターンについてLeanと命令型言語でのそれの大きな違いは、Leanの早期リターンは現在の `do` ブロックのみに適用されるという点です。関数の定義全体が1つの同じ `do` ブロック内にある場合、この違いは問題になりません。しかし、`do` が他の構造体の中にある場合はその違いが明らかになります。例えば、`greet` の以下の定義について：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean greet}}
```
<!--
the expression `{{#example_in Examples/MonadTransformers/Do.lean greetDavid}}` evaluates to `{{#example_out Examples/MonadTransformers/Do.lean greetDavid}}`, not just `"David"`.
-->

式 `{{#example_in Examples/MonadTransformers/Do.lean greetDavid}}` を評価すると `David` ではなく `{{#example_out Examples/MonadTransformers/Do.lean greetDavid}}` になります。

<!--
## Loops
-->

## 繰り返し処理

<!--
Just as every program with mutable state can be rewritten to a program that passes the state as arguments, every loop can be rewritten as a recursive function.
From one perspective, `List.find?` is most clear as a recursive function.
After all, its definition mirrors the structure of the list: if the head passes the check, then it should be returned; otherwise look in the tail.
When no more entries remain, the answer is `none`.
From another perspective, `List.find?` is most clear as a loop.
After all, the program consults the entries in order until a satisfactory one is found, at which point it terminates.
If the loop terminates without having returned, the answer is `none`.
-->

可変状態を扱うような全てのプログラムが状態を引数として受け取るプログラムとして書けるように、すべての繰り返しは再帰関数として書くことができます。その観点で言えば、`List.find?` はまさに再帰関数として見ることができます。結論から言うと、その場合の定義はリストの構造を反映したものになっています：もし先頭がチェックを通過すればその要素が返されます；さもなくば後続のリストを見に行きます。もしリストに要素が1つも無ければ、結果は `none` になります。一方で見方を変えれば、`List.find?` は繰り返し処理の関数として見ることができます。この関数はとどのつまり、チェックを満たすものが見つかるまで順番に要素を調べ、見つかった時点で終了するものだからです。ループが戻らずに終了した場合、結果は `none` になります。

<!--
### Looping with ForM
-->

### `ForM` による繰り返し

<!--
Lean includes a type class that describes looping over a container type in some monad.
This class is called `ForM`:
-->

Leanにはコンテナ型に対する繰り返しをモナド上で行うことを記述する型クラスがあります。このクラスは `ForM` と呼ばれます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ForM}}
```
<!--
This class is quite general.
The parameter `m` is a monad with some desired effects, `γ` is the collection to be looped over, and `α` is the type of elements from the collection.
Typically, `m` is allowed to be any monad, but it is possible to have a data structure that e.g. only supports looping in `IO`.
The method `forM` takes a collection, a monadic action to be run for its effects on each element from the collection, and is then responsible for running the actions.
-->

この定義はとても汎用的です。パラメータ `m` は想定している作用を持つモナド、`γ` は繰り返しを行うコレクション、そして `α` はコレクションの要素の型です。通常、`m` はどんなモナドでも構いませんが、例えば `IO` での繰り返し処理のみをサポートするようなデータ構造とすることも可能です。メソッド `forM` はコレクションと各要素に作用を及ぼすモナドのアクションを受け取り、アクションの実行を担います。

<!--
The instance for `List` allows `m` to be any monad, it sets `γ` to be `List α`, and sets the class's `α` to be the same `α` found in the list:
-->

このクラスの `List` に対するインスタンスは `m` としてどんなモナドでも取ることができます。`γ` には `List α` を、クラスの `α` にはリストに渡しているものと同じ `α` を設定します：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ListForM}}
```
<!--
The [function `doList` from `doug`](reader-io.md#implementation) is `forM` for lists.
Because `forM` is intended to be used in `do`-blocks, it uses `Monad` rather than `Applicative`.
`forM` can be used to make `countLetters` much shorter:
-->

[`doug` で使った関数 `doList`](reader-io.md#implementation) はリスト用の `forM` です。`forM` は `do` ブロックで使われることを想定されているため、`Applicative` ではなく `Monad` を用います。`forM` を使うことで `countLetters` はさらに短くなります：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countLettersForM}}
```


<!--
The instance for `Many` is very similar:
-->

これの `Many` に対するインスタンスも同じようなものになります：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ManyForM}}
```

<!--
Because `γ` can be any type at all, `ForM` can support non-polymorphic collections.
A very simple collection is one of the natural numbers less than some given number, in reverse order:
-->

`γ` はどんな型でもよいため、`ForM` は多相的ではないコレクションもサポートしています。非常に単純なコレクションとして、与えられた数より小さい自然数を降順に並べたものを考えます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean AllLessThan}}
```
<!--
Its `forM` operator applies the provided action to each smaller `Nat`:
-->

これの `forM` 演算子は指定されたアクションをそれぞれの小さい `Nat` に適用します：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean AllLessThanForM}}
```
<!--
Running `IO.println` on each number less than five can be accomplished with `forM`:
-->

`IO.println` を5未満の各数値に適用することは `forM` で以下のように実装できます：

```lean
{{#example_in Examples/MonadTransformers/Do.lean AllLessThanForMRun}}
```
```output info
{{#example_out Examples/MonadTransformers/Do.lean AllLessThanForMRun}}
```

<!--
An example `ForM` instance that works only in a particular monad is one that loops over the lines read from an IO stream, such as standard input:
-->

特定のモナドでのみ動作する `ForM` インスタンスの例として、標準入力のようなIOストリームから読み込まれた行に対してループするものがあります：

```lean
{{#include ../../../examples/formio/ForMIO.lean:LinesOf}}
```
<!--
The definition of `forM` is marked `partial` because there is no guarantee that the stream is finite.
In this case, `IO.FS.Stream.getLine` works only in the `IO` monad, so no other monad can be used for looping.
-->

この `forM` の定義はストリームが有限である保証がないことから `partial` とマークされています。この場合、`IO.FS.Stream.getLine` は `IO` モナドのみで動作するため他のモナドをループに使用することができません。

<!--
This example program uses this looping construct to filter out lines that don't contain letters:
-->

次のサンプルプログラムではこの繰り返し構造を使って、文字を含まない行をフィルタリングします：

```lean
{{#include ../../../examples/formio/ForMIO.lean:main}}
```
<!--
The file `test-data` contains:
-->

`test-data` ファイルの中身が以下の場合：

```
{{#include ../../../examples/formio/test-data}}
```
<!--
Invoking this program, which is stored in `ForMIO.lean`, yields the following output:
-->

`ForMIO.lean` に格納されているこのプログラムを実行すると次のような出力が得られます：

```
$ {{#command {formio} {formio} {lean --run ForMIO.lean < test-data}}}
{{#command_out {formio} {lean --run ForMIO.lean < test-data} {formio/expected}}}
```

<!--
### Stopping Iteration
-->

### 繰り返し処理の停止

<!--
Terminating a loop early is difficult to do with `forM`.
Writing a function that iterates over the `Nat`s in an `AllLessThan` only until `3` is reached requires a means of stopping the loop partway through.
One way to achieve this is to use `forM` with the `OptionT` monad transformer.
The first step is to define `OptionT.exec`, which discards information about both the return value and whether or not the transformed computation succeeded:
-->

`forM` を使う場合、繰り返し処理の途中で早期に終了することは難しいです。`AllLessThan` 内の `Nat` を `3` に達するまで繰り返し処理する関数を書くには、繰り返しを途中で止める手段が必要になります。これを実現する1つの方法は、`OptionT` モナド変換子と一緒に `forM` を使うことです。そのためにまず `OptionT.exec` を定義して、戻り値と変換された計算が成功したかどうかの両方の情報を破棄します：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean OptionTExec}}
```
<!--
Then, failure in the `OptionT` instance of `Alternative` can be used to terminate looping early:
-->

そして `OptionT` の `Alternative` インスタンスで失敗させるようにすることで、繰り返し処理を早期に終了させることができます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean OptionTcountToThree}}
```
<!--
A quick test demonstrates that this solution works:
-->

以下の簡易的なテストで、この解決策が機能することが確認できます：

```lean
{{#example_in Examples/MonadTransformers/Do.lean optionTCountSeven}}
```
```output info
{{#example_out Examples/MonadTransformers/Do.lean optionTCountSeven}}
```

<!--
However, this code is not so easy to read.
Terminating a loop early is a common task, and Lean provides more syntactic sugar to make this easier.
This same function can also be written as follows:
-->

しかし、このコードはあまり読みやすくありません。繰り返し処理を早期に終了することは一般的なタスクであることから、Leanはこれを容易に実現できるよう追加の糖衣構文を用意しています。上記の関数は以下のようにも書けます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countToThree}}
```
<!--
Testing it reveals that it works just like the prior version:
-->

試しに動かしてみると前のものと同じように動作することがはっきりするでしょう：

```lean
{{#example_in Examples/MonadTransformers/Do.lean countSevenFor}}
```
```output info
{{#example_out Examples/MonadTransformers/Do.lean countSevenFor}}
```

<!--
At the time of writing, the `for ... in ... do ...` syntax desugars to the use of a type class called `ForIn`, which is a somewhat more complicated version of `ForM` that keeps track of state and early termination.
However, there is a plan to refactor `for` loops to use the simpler `ForM`, with monad transformers inserted as necessary.
In the meantime, an adapter is provided that converts a `ForM` instance into a `ForIn` instance, called `ForM.forIn`.
To enable `for` loops based on a `ForM` instance, add something like the following, with appropriate replacements for `AllLessThan` and `Nat`:
-->

この文章を書いている時点では、構文 `for ... in ... do ...` は `ForIn` という型クラスを使用したものに脱糖されます。このクラスは状態と早期リターンを担保した `ForM` をより複雑にしたものです。しかし、`for` ループをリファクタリングして、よりシンプルな `ForM` を使うようにする計画があります。それまでの間、`ForM.forIn` という `ForM` インスタンスを `ForIn` インスタンスに変換するアダプタが用意されています。`ForM` インスタンスに基づく `for` ループを使えるようにするには、以下のように `AllLessThan` と `Nat` を適切に置き換えて追加します：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ForInIOAllLessThan}}
```
<!--
Note, however, that this adapter only works for `ForM` instances that keep the monad unconstrained, as most of them do.
This is because the adapter uses `StateT` and `ExceptT`, rather than the underlying monad.
-->

ただし、このアダプタは（ほとんどのものがそうですが）モナドの制約を受けない `ForM` インスタンスにしか使えないことに注意してください。これは、このアダプタがベースのモナドではなく `StateT` と `ExceptT` を使用するためです。

<!--
Early return is supported in `for` loops.
The translation of `do` blocks with early return into a use of an exception monad transformer applies equally well underneath `forM` as the earlier use of `OptionT` to halt iteration does.
This version of `List.find?` makes use of both:
-->

早期リターンは `for` ループでサポートされています。早期リターンを伴う `do` ブロックを例外のモナド変換子を使うものに変換する流れは、`forM` の中でも以前の `OptionT` による繰り返しの停止と同じように適用できます。このバージョンの `List.find?` はどちらも用います：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuh}}
```

<!--
In addition to `break`, `for` loops support `continue` to skip the rest of the loop body in an iteration.
An alternative (but confusing) formulation of `List.find?` skips elements that don't satisfy the check:
-->

`break` に加え、`for` ループは繰り返し内でループ本体の残りをスキップするための `continue` をサポートしています。上記とは別の（しかしわかりづらい） `List.find?` の形式化はチェックを満たさない要素をスキップします：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuhCont}}
```

<!--
A `Range` is a structure that consists of a starting number, an ending number, and a step.
They represent a sequence of natural numbers, from the starting number to the ending number, increasing by the step each time.
Lean has special syntax to construct ranges, consisting of square brackets, numbers, and colons that comes in four varieties.
The stopping point must always be provided, while the start and the step are optional, defaulting to `0` and `1`, respectively:
-->

`Range` は開始番号、終了番号、ステップからなる構造体です。これは開始番号から始まり終了番号までステップずつ増えていく整数の数列を表しています。Leanではこの範囲を構成するための特別な記法を用意しており、角括弧と数値、そしてコロンを用いた4つの組み合わせによって記述できます。終点は必ず指定しなければなりませんが、始点とステップは任意で、デフォルトではそれぞれ `0` と `1` になります：

<!--
| Expression | Start      | Stop       | Step | As List |
-->

| 式 | 開始      | 終了       | ステップ | リストとしての値 |
|------------|------------|------------|------|---------|
| `[:10]` | `0` | `10` | `1` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStopContents}}` |
| `[2:10]` | `2` | `10` | `1` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStartStopContents}}` |
| `[:10:3]` | `0` | `10` | `3` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStopStepContents}}` |
| `[2:10:3]` | `2` | `10` | `3` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStartStopStepContents}}` |

<!--
Note that the starting number _is_ included in the range, while the stopping numbers is not.
All three arguments are `Nat`s, which means that ranges cannot count down—a range where the starting number is greater than or equal to the stopping number simply contains no numbers.
-->

開始番号が範囲に含まれて **いる** 一方で終了番号は含まれていないことに注意してください。3つの引数はすべて `Nat` であり、これは範囲を逆向きに数えることができないことを意味します。つまり開始番号が終了番号以上であるような範囲では、単に何の数値も含まなくなります。

<!--
Ranges can be used with `for` loops to draw numbers from the range.
This program counts even numbers from four to eight:
-->

範囲は `for` ループと一緒に使うことで範囲から数値を引き出すことができます。次のプログラムは4から8までの偶数を数えます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean fourToEight}}
```
<!--
Running it yields:
-->

実行すると次を得ます：

```output info
{{#example_out Examples/MonadTransformers/Do.lean fourToEightOut}}
```


<!--
Finally, `for` loops support iterating over multiple collections in parallel, by separating the `in` clauses with commas.
Looping halts when the first collection runs out of elements, so the declaration:
-->

最後に、`for` ループは `in` 節をカンマで区切ることで複数のコレクションを並列に繰り返し処理することができます。繰り返しは最初のコレクションの要素がなくなると停止するので、次の宣言：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean parallelLoop}}
```
<!--
produces three lines of output:
-->

は以下の3行を出力します：

```lean
{{#example_in Examples/MonadTransformers/Do.lean parallelLoopOut}}
```
```output info
{{#example_out Examples/MonadTransformers/Do.lean parallelLoopOut}}
```

<!--
## Mutable Variables
-->

## 可変変数

<!--
In addition to early `return`, `else`-less `if`, and `for` loops, Lean supports local mutable variables within a `do` block.
Behind the scenes, these mutable variables desugar to a use of `StateT`, rather than being implemented by true mutable variables.
Once again, functional programming is used to simulate imperative programming.
-->

早期の `return` 、`else` の無い `if` 、`for` ループに加えて、Leanは `do` ブロック内で使える局所可変変数をサポートしています。裏側では、これらの可変変数は、本当の意味での可変変数としての実装にではなく、`StateT` を使うように脱糖されます。繰り返しになりますが、関数プログラミングは命令型言語をシミュレートすることができます。

<!--
A local mutable variable is introduced with `let mut` instead of plain `let`.
The definition `two`, which uses the identity monad `Id` to enable `do`-syntax without introducing any effects, counts to `2`:
-->

局所可変変数はただの `let` の代わりに `let mut` で導入します。以下の定義 `two` は恒等モナド `Id` を使って作用を持ち込まない `do` 記法を利用しており、`2` になります：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean two}}
```
<!--
This code is equivalent to a definition that uses `StateT` to add `1` twice:
-->

このコードは `StateT` を使って `1` を2回加算する定義と同じです：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean twoStateT}}
```

<!--
Local mutable variables work well with all the other features of `do`-notation that provide convenient syntax for monad transformers.
The definition `three` counts the number of entries in a three-entry list:
-->

局所可変変数はモナド変換子のための便利な記法を提供する `do` 記法の他の全ての機能とうまく連動します。定義 `three` は要素数が3つの数値リストの数を数えます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean three}}
```
<!--
Similarly, `six` adds the entries in a list:
-->

同じように、`six` はリストの要素を足し合わせます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean six}}
```

<!--
`List.count` counts the number of entries in a list that satisfy some check:
-->

`List.count` はリスト内で何らかのチェックを満たす要素の数を数えます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ListCount}}
```

<!--
Local mutable variables can be more convenient to use and easier to read than an explicit local use of `StateT`.
However, they don't have the full power of unrestricted mutable variables from imperative languages.
In particular, they can only be modified in the `do`-block in which they are introduced.
This means, for instance, that `for`-loops can't be replaced by otherwise-equivalent recursive helper functions.
This version of `List.count`:
-->

局所可変変数は明示的にローカルで `StateT` を使用するよりも使いやすく、読みやすくなります。しかし、命令型言語での無制限な可変変数のような完全な力は持っていません。特に、これらは導入された `do` ブロックの中でしか変更できません。これは、例えば `for` ループを同じ機能を持つ再帰的な補助関数に置き換えることができないことを意味します。このバージョンの `List.count` ：

```lean
{{#example_in Examples/MonadTransformers/Do.lean nonLocalMut}}
```
<!--
yields the following error on the attempted mutation of `found`:
-->

は `found` を更新しようとした時に次のようなエラーを出します：

```output info
{{#example_out Examples/MonadTransformers/Do.lean nonLocalMut}}
```
<!--
This is because the recursive function is written in the identity monad, and only the monad of the `do`-block in which the variable is introduced is transformed with `StateT`.
-->

これは再帰関数が恒等モナドで記述され、変数が導入された `do` ブロックのモナドだけが `StateT` で変換されるからです。

<!--
## What counts as a `do` block?
-->

## どこまでを `do` ブロックとみなすか？

<!--
Many features of `do`-notation apply only to a single `do`-block.
Early return terminates the current block, and mutable variables can only be mutated in the block that they are defined in.
To use them effectively, it's important to know what counts as "the same block".
-->

`do` 記法の多くの機能は1つの `do` ブロックにのみ適用されます。早期リターンは現在のブロックを終了させ、可変変数はそれが定義されたブロックの中でしか可変にできません。これらを効果的に使うには、何をもって「同じブロック」であるのかを知ることが重要です。

<!--
Generally speaking, the indented block following the `do` keyword counts as a block, and the immediate sequence of statements underneath it are part of that block.
Statements in independent blocks that are nonetheless contained in a block are not considered part of the block.
However, the rules that govern what exactly counts as the same block are slightly subtle, so some examples are in order.
The precise nature of the rules can be tested by setting up a program with a mutable variable and seeing where the mutation is allowed.
This program has a mutation that is clearly in the same block as the mutable variable:
-->

一般的に言って、`do` キーワードにつづくインデントされたブロックはブロックとみなされ、その内部にある一連の文はブロックの一部となります。しかし、ブロックに含まれている独立したブロックの文は、含まれているにもかかわらず外側のブロックの一部とはみなされません。ただし、実際に何を同じブロックとみなすかはやや曖昧であるため、いくつかの例を挙げておきましょう。ルールの性質は可変変数を持つプログラムを用意し、どこで変数の更新が可能かをみることで正確にテストすることができます。以下のプログラムでは変数の更新が含まれており、このことからこの更新が可変変数と同じブロックの中にあることがはっきりします：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean sameBlock}}
```

<!--
When a mutation occurs in a `do`-block that is part of a `let`-statement that defines a name using `:=`, then it is not considered to be part of the block:
-->

`:=` を使った `let` 文の名前定義の一部が `do` ブロックで、そのブロック中で更新が起こった場合はこの更新は外側のブロックの一部とはみなされません：

```lean
{{#example_in Examples/MonadTransformers/Do.lean letBodyNotBlock}}
```
```output error
{{#example_out Examples/MonadTransformers/Do.lean letBodyNotBlock}}
```
<!--
However, a `do`-block that occurs under a `let`-statement that defines a name using `←` is considered part of the surrounding block.
The following program is accepted:
-->

しかし、`do` ブロックが `←` を使った `let` の名前定義内にある場合、これは外側のブロックの一部とみなされます。次のプログラムは正常に動きます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean letBodyArrBlock}}
```

<!--
Similarly, `do`-blocks that occur as arguments to functions are independent of their surrounding blocks.
The following program is not accepted:
-->

同じように、`do` ブロックが関数の引数に置かれている場合も外側のブロックから独立します。次のプログラムは正常に動きます：

```lean
{{#example_in Examples/MonadTransformers/Do.lean funArgNotBlock}}
```
```output error
{{#example_out Examples/MonadTransformers/Do.lean funArgNotBlock}}
```

<!--
If the `do` keyword is completely redundant, then it does not introduce a new block.
This program is accepted, and is equivalent to the first one in this section:
-->

`do` キーワードが完全に冗長である場合、新しいブロックは導入されません。次のプログラムは正常に動き、本節の最初のプログラムと等価です：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean collapsedBlock}}
```

<!--
The contents of branches under a `do` (such as those introduced by `match` or `if`) are considered to be part of the surrounding block, whether or not a redundant `do` is added.
The following programs are all accepted:
-->

`do` の下にある（`match` や `if` で導入されるような）分岐の内容は冗長な `do` の有無にかかわらず、外側のブロックの一部とみなされます。以下のプログラムはすべて正常に動きます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ifDoSame}}

{{#example_decl Examples/MonadTransformers/Do.lean ifDoDoSame}}

{{#example_decl Examples/MonadTransformers/Do.lean matchDoSame}}

{{#example_decl Examples/MonadTransformers/Do.lean matchDoDoSame}}
```
<!--
Similarly, the `do` that occurs as part of the `for` and `unless` syntax is just part of their syntax, and does not introduce a fresh `do`-block.
These programs are also accepted:
-->

同じように、`for` や `unless` 記法の一部として出てくる `do` は構文の一部に過ぎず、新しい `do` ブロックを導入するものではありません。以下のプログラムも正常に動きます：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean doForSame}}

{{#example_decl Examples/MonadTransformers/Do.lean doUnlessSame}}
```


<!--
## Imperative or Functional Programming?
-->

## 命令型か関数型か？

<!--
The imperative features provided by Lean's `do`-notation allow many programs to very closely resemble their counterparts in languages like Rust, Java, or C#.
This resemblance is very convenient when translating an imperative algorithm into Lean, and some tasks are just most naturally thought of imperatively.
The introduction of monads and monad transformers enables imperative programs to be written in purely functional languages, and `do`-notation as a specialized syntax for monads (potentially locally transformed) allows functional programmers to have the best of both worlds: the strong reasoning principles afforded by immutability and a tight control over available effects through the type system are combined with syntax and libraries that allow programs that use effects to look familiar and be easy to read.
Monads and monad transformers allow functional versus imperative programming to be a matter of perspective.
-->

Leanの `do` 記法がもたらす命令的な機能によって、多くのプログラムはRustやJava、C#のような言語によるそれと同等なプログラムと非常によく似たものになります。この類似性は命令型のアルゴリズムをLeanに翻訳する際に非常に便利です。実際にいくつかのタスクでは命令的に考えるほうがとても自然です。モナドとモナド変換子の導入により、命令型プログラムを純粋関数型言語で書くことができるようになり、モナドに特化した構文である `do` 記法（局所的に変換される可能性あり）により関数型プログラマは2つの長所を得ることができます：不変性と型システムを通じて利用可能な作用を厳密に制御することによって得られる強力な推論原理と、作用を使用するプログラムを見慣れたものにし読みやすくする構文とライブラリのコンビです。モナドとモナド変換子によって関数型プログラミングと命令型プログラミングの違いは見方の問題に帰着します。

<!--
## Exercises
-->

## 演習問題

 <!--
 * Rewrite `doug` to use `for` instead of the `doList` function. Are there other opportunities to use the features introduced in this section to improve the code? If so, use them!
 -->
 * `doug` を `doList` 関数の代わりに `for` を使って書き直してください。本節で紹介した機能を使ってコードを改善できそうな箇所はありそうでしょうか？あったらやってみましょう！

