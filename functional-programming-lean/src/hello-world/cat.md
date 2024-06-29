<!-- # Worked Example: `cat` -->

# 実例：`cat`

<!-- The standard Unix utility `cat` takes a number of command-line options, followed by zero or more input files.
If no files are provided, or if one of them is a dash (`-`), then it takes the standard input as the corresponding input instead of reading a file.
The contents of the inputs are written, one after the other, to the standard output.
If a specified input file does not exist, this is noted on standard error, but `cat` continues concatenating the remaining inputs.
A non-zero exit code is returned if any of the input files do not exist. -->

Unix の標準ユーティリティである `cat` はいくつかのコマンドラインオプションと，それに続く0個以上の入力ファイルを受け付けます．ファイルが指定されないか，指定したファイルのうち1つがダッシュ（`-`）の場合，ファイルを読む代わりに標準入力を対応する入力として受け付けます．入力の内容は次々に標準出力に書き出されます．指定した入力ファイルが存在しない場合，そのことが標準エラー出力に表示されますが，`cat` は入力を連結し続けます．存在しない入力ファイルがあったとき，0以外の終了コードが返されます．

<!-- This section describes a simplified version of `cat`, called `feline`.
Unlike commonly-used versions of `cat`, `feline` has no command-line options for features such as numbering lines, indicating non-printing characters, or displaying help text.
Furthermore, it cannot read more than once from a standard input that's associated with a terminal device. -->

この節では，`feline` と呼ばれる `cat` の簡易版について説明します．一般的なバージョンの `cat` と異なり，`feline` は行番号表示や非印字文字の表示，ヘルプテキストの表示といった機能のコマンドラインオプションはありません．さらに，端末デバイスに関連付けられた標準入力から複数回読み込むこともできません．

<!-- To get the most benefit from this section, follow along yourself.
It's OK to copy-paste the code examples, but it's even better to type them in by hand.
This makes it easier to learn the mechanical process of typing in code, recovering from mistakes, and interpreting feedback from the compiler. -->

この節で最大限の効果を得るには，自分自身でコードを書いてください．コード例をコピーペーストしてもかまいませんが，手書きで入力することを推奨します．そうすることで，コードを入力し，ミスから回復し，コンパイラからのフィードバックを解釈するという機械的なプロセスを学びやすくなります．

<!-- ## Getting started -->

## はじめる

<!-- The first step in implementing `feline` is to create a package and decide how to organize the code.
In this case, because the program is so simple, all the code will be placed in `Main.lean`.
The first step is to run `lake new feline`.
Edit the Lakefile to remove the library, and delete the generated library code and the reference to it from `Main.lean`.
Once this has been done, `lakefile.lean` should contain: -->

`feline` 実装の最初のステップは，パッケージを作成し，コードをどのように整理するかを決めることです．今回の場合，プログラムは非常に簡単なので，すべてのコードは `Main.lean` に書きます．最初のステップは `lake new feline` を実行することです．Lakefile を編集してライブラリを削除し，生成されたライブラリコードとその参照を `Main.lean` も削除します．
これが完了すると，`lakefile.lean` は次のようになります：

```lean
{{#include ../../../examples/feline/1/lakefile.lean}}
```

<!-- and `Main.lean` should contain something like: -->

そして `Main.lean` も次のようになります：

```lean
{{#include ../../../examples/feline/1/Main.lean}}
```
<!-- Alternatively, running `lake new feline exe` instructs `lake` to use a template that does not include a library section, making it unnecessary to edit the file. -->

あるいは，`lake new feline exe` を実行すると `lake` にライブラリセクションを含まないテンプレートを使用するように指示されるため，ファイルを編集する必要がなくなります．

<!-- Ensure that the code can be built by running `{{#command {feline/1} {feline/1} {lake build} }}`. -->

`{{#command {feline/1} {feline/1} {lake build} }}` を実行してコードがビルドできることを確認してください．

<!-- ## Concatenating Streams -->

## ストリームの連結

<!-- Now that the basic skeleton of the program has been built, it's time to actually enter the code.
A proper implementation of `cat` can be used with infinite IO streams, such as `/dev/random`, which means that it can't read its input into memory before outputting it.
Furthermore, it should not work one character at a time, as this leads to frustratingly slow performance.
Instead, it's better to read contiguous blocks of data all at once, directing the data to the standard output one block at a time. -->

プログラムの基本的な骨組みができたので，実際にコードを入力するときがきました．`cat` の適切な実装は `/dev/random` のような無限の IO ストリームに使うことができます。これは出力する前に入力をメモリに読み込むことができないことを意味します．さらに，`cat` は一度に1文字ずつ処理すべきではありません．これは非常に遅いパフォーマンスにつながるためです．代わりに，一度に連続したデータブロックを読み取り，そのデータを標準出力に1ブロックずつ送るのがよいでしょう．

<!-- The first step is to decide how big of a block to read.
For the sake of simplicity, this implementation uses a conservative 20 kilobyte block.
`USize` is analogous to `size_t` in C—it's an unsigned integer type that is big enough to represent all valid array sizes. -->

最初のステップはどのくらいの大きさのブロックを読み取るかを決めることです．簡単にするため，この実装では控えめに20キロバイトのブロックを使用します．`USize` は C 言語の `size_t` に類似しており，すべての有効な配列サイズを表すのに十分な大きさの符号なし整数型です．

```lean
{{#include ../../../examples/feline/2/Main.lean:bufsize}}
```

<!-- ### Streams -->

### ストリーム

<!-- The main work of `feline` is done by `dump`, which reads input one block at a time, dumping the result to standard output, until the end of the input has been reached: -->

`feline` の主な処理は `dump` によって行われます．`dump` は一度に1ブロックずつ入力を読み込み，その結果を標準出力に出力し，入力の終わりに達するまでこれを繰り返します．

```lean
{{#include ../../../examples/feline/2/Main.lean:dump}}
```
<!-- The `dump` function is declared `partial`, because it calls itself recursively on input that is not immediately smaller than an argument.
When a function is declared to be partial, Lean does not require a proof that it terminates.
On the other hand, partial functions are also much less amenable to proofs of correctness, because allowing infinite loops in Lean's logic would make it unsound.
However, there is no way to prove that `dump` terminates, because infinite input (such as from `/dev/random`) would mean that it does not, in fact, terminate.
In cases like this, there is no alternative to declaring the function `partial`. -->

`dump` 関数は `partial` 関数（部分関数）として宣言されています．これは，引数が即座に小さくならない入力に対して再帰的に自分自身を呼び出すためです．関数が部分関数として定義されると，Lean はその終了を証明する必要がなくなります．一方で，部分関数は無限ループを許容するため，Lean の論理が不健全になる可能性があり，正しさの証明が非常に困難になります．しかし，`dump` が終了することを証明する方法はありません．なぜなら，無限の入力（例えば `/dev/random` からの入力）は実際に終了しないからです．このような場合，関数を `partial` 関数として宣言する以外の選択肢はありません．

<!-- The type `IO.FS.Stream` represents a POSIX stream.
Behind the scenes, it is represented as a structure that has one field for each POSIX stream operation.
Each operation is represented as an IO action that provides the corresponding operation: -->

`IO.FS.Stream` 型は POSIX ストリームを返します．内部的には，各 POSIX ストリーム操作のフィールドを持つ構造体です．各操作は対応する操作を提供する IO アクションとして表現されます．

```lean
{{#example_decl Examples/Cat.lean Stream}}
```
<!-- The Lean compiler contains `IO` actions (such as `IO.getStdout`, which is called in `dump`) to get streams that represent standard input, standard output, and standard error.
These are `IO` actions rather than ordinary definitions because Lean allows these standard POSIX streams to be replaced in a process, which makes it easier to do things like capturing the output from a program into a string by writing a custom `IO.FS.Stream`. -->

Lean コンパイラには，標準入力，標準出力，標準エラー出力を表すストリームを取得するための IO アクションが含まれています（例えば `dump` で呼び出される `IO.getStdout`）．これらは通常の定義ではなく `IO` アクションである理由は，Lean がプロセス内でこれらの標準 POSIX ストリームを置き換えることを許可しているためです．これにより，カスタムの `IO.FS.Stream` を作成してプログラムの出力を文字列にキャプチャするなどの操作が容易になります．

The control flow in `dump` is essentially a `while` loop.
When `dump` is called, if the stream has reached the end of the file, `pure ()` terminates the function by returning the constructor for `Unit`.
If the stream has not yet reached the end of the file, one block is read, and its contents are written to `stdout`, after which `dump` calls itself directly.
The recursive calls continue until `stream.read` returns an empty byte array, which indicates that the end of the file has been reached.

When an `if` expression occurs as a statement in a `do`, as in `dump`, each branch of the `if` is implicitly provided with a `do`.
In other words, the sequence of steps following the `else` are treated as a sequence of `IO` actions to be executed, just as if they had a `do` at the beginning.
Names introduced with `let` in the branches of the `if` are visible only in their own branches, and are not in scope outside of the `if`.

There is no danger of running out of stack space while calling `dump` because the recursive call happens as the very last step in the function, and its result is returned directly rather than being manipulated or computed with.
This kind of recursion is called _tail recursion_, and it is described in more detail [later in this book](../programs-proofs/tail-recursion.md).
Because the compiled code does not need to retain any state, the Lean compiler can compile the recursive call to a jump.

If `feline` only redirected standard input to standard output, then `dump` would be sufficient.
However, it also needs to be able to open files that are provided as command-line arguments and emit their contents.
When its argument is the name of a file that exists, `fileStream` returns a stream that reads the file's contents.
When the argument is not a file, `fileStream` emits an error and returns `none`.
```lean
{{#include ../../../examples/feline/2/Main.lean:fileStream}}
```
Opening a file as a stream takes two steps.
First, a file handle is created by opening the file in read mode.
A Lean file handle tracks an underlying file descriptor.
When there are no references to the file handle value, a finalizer closes the file descriptor.
Second, the file handle is given the same interface as a POSIX stream using `IO.FS.Stream.ofHandle`, which fills each field of the `Stream` structure with the corresponding `IO` action that works on file handles.

### Handling Input

The main loop of `feline` is another tail-recursive function, called `process`.
In order to return a non-zero exit code if any of the inputs could not be read, `process` takes an argument `exitCode` that represents the current exit code for the whole program.
Additionally, it takes a list of input files to be processed.
```lean
{{#include ../../../examples/feline/2/Main.lean:process}}
```
Just as with `if`, each branch of a `match` that is used as a statement in a `do` is implicitly provided with its own `do`.

There are three possibilities.
One is that no more files remain to be processed, in which case `process` returns the error code unchanged.
Another is that the specified filename is `"-"`, in which case `process` dumps the contents of the standard input and then processes the remaining filenames.
The final possibility is that an actual filename was specified.
In this case, `fileStream` is used to attempt to open the file as a POSIX stream.
Its argument is encased in `⟨ ... ⟩` because a `FilePath` is a single-field structure that contains a string.
If the file could not be opened, it is skipped, and the recursive call to `process` sets the exit code to `1`.
If it could, then it is dumped, and the recursive call to `process` leaves the exit code unchanged.

`process` does not need to be marked `partial` because it is structurally recursive.
Each recursive call is provided with the tail of the input list, and all Lean lists are finite.
Thus, `process` does not introduce any non-termination.

### Main

The final step is to write the `main` action.
Unlike prior examples, `main` in `feline` is a function.
In Lean, `main` can have one of three types:
 * `main : IO Unit` corresponds to programs that cannot read their command-line arguments and always indicate success with an exit code of `0`,
 * `main : IO UInt32` corresponds to `int main(void)` in C, for programs without arguments that return exit codes, and
 * `main : List String → IO UInt32` corresponds to `int main(int argc, char **argv)` in C, for programs that take arguments and signal success or failure.

If no arguments were provided, `feline` should read from standard input as if it were called with a single `"-"` argument.
Otherwise, the arguments should be processed one after the other.
```lean
{{#include ../../../examples/feline/2/Main.lean:main}}
```


## Meow!

To check whether `feline` works, the first step is to build it with `{{#command {feline/2} {feline/2} {lake build} }}`.
First off, when called without arguments, it should emit what it receives from standard input.
Check that
```
{{#command {feline/2} {feline/2} {echo "It works!" | ./build/bin/feline} }}
```
emits `{{#command_out {feline/2} {echo "It works!" | ./build/bin/feline} }}`.

Secondly, when called with files as arguments, it should print them.
If the file `test1.txt` contains
```
{{#include ../../../examples/feline/2/test1.txt}}
```
and `test2.txt` contains
```
{{#include ../../../examples/feline/2/test2.txt}}
```
then the command
```
{{#command {feline/2} {feline/2} {./build/bin/feline test1.txt test2.txt} }}
```
should emit
```
{{#command_out {feline/2} {./build/bin/feline test1.txt test2.txt} {feline/2/expected/test12.txt} }}
```

Finally, the `-` argument should be handled appropriately.
```
{{#command {feline/2} {feline/2} {echo "and purr" | ./build/bin/feline test1.txt - test2.txt} }}
```
should yield
```
{{#command_out {feline/2} {echo "and purr" | ./build/bin/feline test1.txt - test2.txt} {feline/2/expected/test1purr2.txt}}}
```

## Exercise

Extend `feline` with support for usage information.
The extended version should accept a command-line argument `--help` that causes documentation about the available command-line options to be written to standard output.
