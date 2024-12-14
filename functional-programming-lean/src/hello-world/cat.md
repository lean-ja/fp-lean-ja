<!-- # Worked Example: `cat` -->

# 実例：`cat`

<!-- The standard Unix utility `cat` takes a number of command-line options, followed by zero or more input files.
If no files are provided, or if one of them is a dash (`-`), then it takes the standard input as the corresponding input instead of reading a file.
The contents of the inputs are written, one after the other, to the standard output.
If a specified input file does not exist, this is noted on standard error, but `cat` continues concatenating the remaining inputs.
A non-zero exit code is returned if any of the input files do not exist. -->

Unix の標準ユーティリティである `cat` はいくつかのコマンドラインオプションと、それに続く0個以上の入力ファイルを受け付けます。ファイルが指定されないか、指定したファイルのうち1つがダッシュ（`-`）の場合、ファイルを読む代わりに標準入力を対応する入力として受け付けます。入力の内容は次々に標準出力に書き出されます。指定した入力ファイルが存在しない場合、そのことが標準エラー出力に表示されますが、`cat` は入力を連結し続けます。存在しない入力ファイルがあったとき、0以外の終了コードが返されます。

<!-- This section describes a simplified version of `cat`, called `feline`.
Unlike commonly-used versions of `cat`, `feline` has no command-line options for features such as numbering lines, indicating non-printing characters, or displaying help text.
Furthermore, it cannot read more than once from a standard input that's associated with a terminal device. -->

この節では、`feline` と呼ばれる `cat` の簡易版について説明します。一般的なバージョンの `cat` と異なり、`feline` は行番号表示や非印字文字の表示、ヘルプテキストの表示といった機能のコマンドラインオプションはありません。さらに、端末デバイスに関連付けられた標準入力から複数回読み込むこともできません。

<!-- To get the most benefit from this section, follow along yourself.
It's OK to copy-paste the code examples, but it's even better to type them in by hand.
This makes it easier to learn the mechanical process of typing in code, recovering from mistakes, and interpreting feedback from the compiler. -->

この節で最大限の効果を得るには、自分自身でコードを書いてください。コード例をコピーペーストしてもかまいませんが、手書きで入力することを推奨します。そうすることで、コードを入力し、ミスから回復し、コンパイラからのフィードバックを解釈するという機械的なプロセスを学びやすくなります。

<!-- ## Getting started -->

## はじめる

<!-- The first step in implementing `feline` is to create a package and decide how to organize the code.
In this case, because the program is so simple, all the code will be placed in `Main.lean`.
The first step is to run `lake new feline`.
Edit the Lakefile to remove the library, and delete the generated library code and the reference to it from `Main.lean`.
Once this has been done, `lakefile.lean` should contain: -->

`feline` 実装の最初のステップは、パッケージを作成し、コードをどのように整理するかを決めることです。今回の場合、プログラムは非常に簡単なので、すべてのコードは `Main.lean` に書きます。最初のステップは `lake new feline` を実行することです。Lakefile を編集してライブラリを削除し、生成されたライブラリコードとその参照を `Main.lean` も削除します。これが完了すると、`lakefile.lean` は次のようになります：

```lean
{{#include ../../../examples/feline/1/lakefile.lean}}
```

<!-- and `Main.lean` should contain something like: -->

そして `Main.lean` も次のようになります：

```lean
{{#include ../../../examples/feline/1/Main.lean}}
```
<!-- Alternatively, running `lake new feline exe` instructs `lake` to use a template that does not include a library section, making it unnecessary to edit the file. -->

あるいは、`lake new feline exe` を実行すると `lake` にライブラリセクションを含まないテンプレートを使用するように指示されるため、ファイルを編集する必要がなくなります。

<!-- Ensure that the code can be built by running `{{#command {feline/1} {feline/1} {lake build} }}`. -->

`{{#command {feline/1} {feline/1} {lake build} }}` を実行してコードがビルドできることを確認してください。

<!-- ## Concatenating Streams -->

## ストリームの連結

<!-- Now that the basic skeleton of the program has been built, it's time to actually enter the code.
A proper implementation of `cat` can be used with infinite IO streams, such as `/dev/random`, which means that it can't read its input into memory before outputting it.
Furthermore, it should not work one character at a time, as this leads to frustratingly slow performance.
Instead, it's better to read contiguous blocks of data all at once, directing the data to the standard output one block at a time. -->

プログラムの基本的な骨組みができたので、実際にコードを入力するときがきました。`cat` の適切な実装は `/dev/random` のような無限の IO ストリームに使うことができます。これは出力する前に入力をメモリに読み込むことができないことを意味します。さらに、`cat` は一度に1文字ずつ処理すべきではありません。これは非常に遅いパフォーマンスにつながるためです。代わりに、一度に連続したデータブロックを読み取り、そのデータを標準出力に1ブロックずつ送るのがよいでしょう。

<!-- The first step is to decide how big of a block to read.
For the sake of simplicity, this implementation uses a conservative 20 kilobyte block.
`USize` is analogous to `size_t` in C—it's an unsigned integer type that is big enough to represent all valid array sizes. -->

最初のステップはどのくらいの大きさのブロックを読み取るかを決めることです。簡単にするため、この実装では控えめに20キロバイトのブロックを使用します。`USize` は C 言語の `size_t` に類似しており、すべての有効な配列サイズを表すのに十分な大きさの符号なし整数型です。

```lean
{{#include ../../../examples/feline/2/Main.lean:bufsize}}
```

<!-- ### Streams -->

### ストリーム

<!-- The main work of `feline` is done by `dump`, which reads input one block at a time, dumping the result to standard output, until the end of the input has been reached: -->

`feline` の主な処理は `dump` によって行われます。`dump` は一度に1ブロックずつ入力を読み込み、その結果を標準出力に出力し、入力の終わりに達するまでこれを繰り返します。

```lean
{{#include ../../../examples/feline/2/Main.lean:dump}}
```
<!-- The `dump` function is declared `partial`, because it calls itself recursively on input that is not immediately smaller than an argument.
When a function is declared to be partial, Lean does not require a proof that it terminates.
On the other hand, partial functions are also much less amenable to proofs of correctness, because allowing infinite loops in Lean's logic would make it unsound.
However, there is no way to prove that `dump` terminates, because infinite input (such as from `/dev/random`) would mean that it does not, in fact, terminate.
In cases like this, there is no alternative to declaring the function `partial`. -->

`dump` 関数は `partial` 関数（部分関数）として宣言されています。これは、引数が即座に小さくならない入力に対して再帰的に自分自身を呼び出すためです。関数が部分関数として定義されると、Lean はその終了を証明する必要がなくなります。一方で、部分関数は無限ループを許容するため、Lean の論理が不健全になる可能性があり、正しさの証明が非常に困難になります。しかし、`dump` が終了することを証明する方法はありません。なぜなら、無限の入力（例えば `/dev/random` からの入力）は実際に終了しないからです。このような場合、関数を `partial` 関数として宣言する以外の選択肢はありません。

<!-- The type `IO.FS.Stream` represents a POSIX stream.
Behind the scenes, it is represented as a structure that has one field for each POSIX stream operation.
Each operation is represented as an IO action that provides the corresponding operation: -->

`IO.FS.Stream` 型は POSIX ストリームを返します。内部的には、各 POSIX ストリーム操作のフィールドを持つ構造体です。各操作は対応する操作を提供する IO アクションとして表現されます。

```lean
{{#example_decl Examples/Cat.lean Stream}}
```
<!-- The Lean compiler contains `IO` actions (such as `IO.getStdout`, which is called in `dump`) to get streams that represent standard input, standard output, and standard error.
These are `IO` actions rather than ordinary definitions because Lean allows these standard POSIX streams to be replaced in a process, which makes it easier to do things like capturing the output from a program into a string by writing a custom `IO.FS.Stream`. -->

Lean コンパイラには、標準入力、標準出力、標準エラー出力を表すストリームを取得するための `IO` アクションが含まれています（例えば `dump` で呼び出される `IO.getStdout`）。これらは通常の定義ではなく `IO` アクションである理由は、Lean がプロセス内でこれらの標準 POSIX ストリームを置き換えることを許可しているためです。これにより、カスタムの `IO.FS.Stream` を作成してプログラムの出力を文字列にキャプチャするなどの操作が容易になります。

<!-- The control flow in `dump` is essentially a `while` loop.
When `dump` is called, if the stream has reached the end of the file, `pure ()` terminates the function by returning the constructor for `Unit`.
If the stream has not yet reached the end of the file, one block is read, and its contents are written to `stdout`, after which `dump` calls itself directly.
The recursive calls continue until `stream.read` returns an empty byte array, which indicates that the end of the file has been reached. -->

`dump` の制御フローは本質的には `while` ループです。`dump` が呼び出されたとき、もしストリームがファイルの終端に達していたなら、`pure ()` によって関数が終了します。このとき、`pure ()` は Unit コンストラクタを返します。ストリームがファイルの終端に達していない場合は、1ブロック分のデータが読み込まれ、その内容が標準出力（`stdout`）に書き出されます。その後、`dump` は再帰的に自分自身を呼び出します。この再帰呼び出しは、`stream.read` が空のバイト配列を返すまで続きます。空のバイト配列が返されることは、ファイルの終端に達したことを意味します。

<!-- When an `if` expression occurs as a statement in a `do`, as in `dump`, each branch of the `if` is implicitly provided with a `do`.
In other words, the sequence of steps following the `else` are treated as a sequence of `IO` actions to be executed, just as if they had a `do` at the beginning.
Names introduced with `let` in the branches of the `if` are visible only in their own branches, and are not in scope outside of the `if`. -->

`dump` のように、`do` の中で `if` 式が使用される場合、`if` の各分岐には暗黙的に `do` が付与されます。つまり、`else` に続く一連の手順は、あたかも先頭に `do` があるかのような一連の `IO` アクションとして扱われます。また、`if` の分岐内で `let` によって導入された名前は、それぞれの分岐内でのみ有効であり、`if` の外側ではスコープに入らないことに注意してください。

<!-- There is no danger of running out of stack space while calling `dump` because the recursive call happens as the very last step in the function, and its result is returned directly rather than being manipulated or computed with.
This kind of recursion is called _tail recursion_, and it is described in more detail [later in this book](../programs-proofs/tail-recursion.md).
Because the compiled code does not need to retain any state, the Lean compiler can compile the recursive call to a jump. -->

`dump` を呼び出してもスタック領域が不足する心配はありません。これは、再帰呼び出しが関数内での最後の処理として実行され、その結果が直接返されるだけで、追加の操作や計算が行われないためです。このような再帰は**末尾再帰**（tail recursion）と呼ばれ、[この本の後半](../programs-proofs/tail-recursion.md)でより詳しく説明されています。また、コンパイルされたコードが状態を保持する必要がないため、Lean コンパイラはこの再帰呼び出しを単なるジャンプ命令に変換できます。

<!-- If `feline` only redirected standard input to standard output, then `dump` would be sufficient.
However, it also needs to be able to open files that are provided as command-line arguments and emit their contents.
When its argument is the name of a file that exists, `fileStream` returns a stream that reads the file's contents.
When the argument is not a file, `fileStream` emits an error and returns `none`. -->

`feline` が単に標準入力を標準出力にリダイレクトするだけであれば、`dump` だけで十分です。しかし、`feline` には、コマンドライン引数として与えられたファイルを開き、その内容を出力する機能も必要です。引数が存在するファイル名である場合、`fileStream` はそのファイルの内容を読み取るストリームを返します。一方で、引数がファイルではない場合、`fileStream` はエラーを出力し、`none` を返します。

```lean
{{#include ../../../examples/feline/2/Main.lean:fileStream}}
```

<!-- Opening a file as a stream takes two steps.
First, a file handle is created by opening the file in read mode.
A Lean file handle tracks an underlying file descriptor.
When there are no references to the file handle value, a finalizer closes the file descriptor.
Second, the file handle is given the same interface as a POSIX stream using `IO.FS.Stream.ofHandle`, which fills each field of the `Stream` structure with the corresponding `IO` action that works on file handles. -->

ファイルをストリームとして開くには、2つのステップが必要です。まず、ファイルを読み取りモードで開くことでファイルハンドルが作成されます。Lean のファイルハンドルは、基盤となるファイルディスクリプタを追跡します。ファイルハンドル値への参照がなくなると、ファイナライザがファイルディスクリプタを閉じます。次に、そのファイルハンドルに POSIX ストリームと同じインターフェースを与えます。これは `IO.FS.Stream.ofHandle` を使用して行われます。この関数は、`Stream` 構造体の各フィールドに、ファイルハンドル上で動作する対応する `IO` アクションを埋め込みます。

<!-- ### Handling Input -->

### 入力の処理

<!-- The main loop of `feline` is another tail-recursive function, called `process`.
In order to return a non-zero exit code if any of the inputs could not be read, `process` takes an argument `exitCode` that represents the current exit code for the whole program.
Additionally, it takes a list of input files to be processed. -->

`feline` のメインループは、もう一つの末尾再帰関数である `process` です。`process` は、入力のいずれかが読み取れなかった場合にゼロではない終了コードを返すため、プログラム全体の現在の終了コードを表す `exitCode` を引数として受け取ります。さらに、処理する入力ファイルのリストも引数として受け取ります。

```lean
{{#include ../../../examples/feline/2/Main.lean:process}}
```
<!-- Just as with `if`, each branch of a `match` that is used as a statement in a `do` is implicitly provided with its own `do`. -->

`if` と同様に、`do` の中で使用される `match` の各分岐には、暗黙的にそれぞれ独自の `do` が付与されます。

<!-- There are three possibilities.
One is that no more files remain to be processed, in which case `process` returns the error code unchanged.
Another is that the specified filename is `"-"`, in which case `process` dumps the contents of the standard input and then processes the remaining filenames.
The final possibility is that an actual filename was specified.
In this case, `fileStream` is used to attempt to open the file as a POSIX stream.
Its argument is encased in `⟨ ... ⟩` because a `FilePath` is a single-field structure that contains a string.
If the file could not be opened, it is skipped, and the recursive call to `process` sets the exit code to `1`.
If it could, then it is dumped, and the recursive call to `process` leaves the exit code unchanged. -->

ここでは3つの可能性があります。1つ目は、処理するファイルがもう残っていない場合で、このとき `process` はエラーコードを変更せずにそのまま返します。2つ目は、指定されたファイル名が `"-"` の場合で、このとき `process` は標準入力の内容をダンプした後、残りのファイル名を処理します。3つ目は、実際のファイル名が指定された場合です。このときは `fileStream` を使用してそのファイルを POSIX ストリームとして開こうとします。引数は `⟨ ... ⟩` で囲まれていますが、これは `FilePath` が文字列を含む単一フィールドの構造体だからです。もしファイルが開けなかった場合、そのファイルはスキップされ、`process` の再帰呼び出しで終了コードが `1` に設定されます。ファイルが開けた場合、ファイルの内容がダンプされ、その後の `process` の再帰呼び出しでは終了コードは変更されません。

<!-- `process` does not need to be marked `partial` because it is structurally recursive.
Each recursive call is provided with the tail of the input list, and all Lean lists are finite.
Thus, `process` does not introduce any non-termination. -->

`process` は構造的に再帰であるため、`partial` としてマークする必要はありません。すべての Lean のリストは有限で、各再帰呼び出しには入力リストの末尾が渡されます。そのため、`process` は終了しないことはありません。

<!-- ### Main -->

### Main の処理

<!-- The final step is to write the `main` action.
Unlike prior examples, `main` in `feline` is a function.
In Lean, `main` can have one of three types:
 * `main : IO Unit` corresponds to programs that cannot read their command-line arguments and always indicate success with an exit code of `0`,
 * `main : IO UInt32` corresponds to `int main(void)` in C, for programs without arguments that return exit codes, and
 * `main : List String → IO UInt32` corresponds to `int main(int argc, char **argv)` in C, for programs that take arguments and signal success or failure. -->

最後のステップは　`main` アクションを記述することです。以前の例とは異なり、`feline` の `main` は関数です。Lean における `main` には、次の3つの種類があります：
* `main : IO Unit` は、コマンドライン引数を読み取ることができず、常に終了コード `0` で成功を示すプログラムに対応します。
* `main : IO UInt32` は、C 言語の `int main(void)` に対応し、引数をとらず終了コードを返します。
* `main : List String → IO UInt32` は、C 言語の `int main(int argc, char **argv)` に対応し、引数を受け取り、成功または失敗を示す終了コードを返します。

<!-- If no arguments were provided, `feline` should read from standard input as if it were called with a single `"-"` argument.
Otherwise, the arguments should be processed one after the other. -->

引数がない場合、`feline` は標準入力から読み取るようにします。このとき、`"-"` 引数が1つ渡されたかのように扱います。引数が提供されている場合は、それぞれの引数を順番に処理します。

```lean
{{#include ../../../examples/feline/2/Main.lean:main}}
```


<!-- ## Meow! -->

## ニャー！

<!-- To check whether `feline` works, the first step is to build it with `{{#command {feline/2} {feline/2} {lake build} }}`.
First off, when called without arguments, it should emit what it receives from standard input.
Check that -->

`feline` が正しく動作するか確認するための最初のステップは、コマンドラインで `{{#command {feline/2} {feline/2} {lake build} }}` を実行してビルドすることです。まず、引数なしで呼び出した場合、標準入力から受け取った内容をそのまま出力するはずです。次のように実行すると、

```
{{#command {feline/2} {feline/2} {echo "It works!" | ./build/bin/feline} }}
```
<!-- emits `{{#command_out {feline/2} {echo "It works!" | ./build/bin/feline} }}`. -->

`{{#command_out {feline/2} {echo "It works!" | ./build/bin/feline} }}` が出力されます。

<!-- Secondly, when called with files as arguments, it should print them.
If the file `test1.txt` contains -->

次に、引数を渡して呼び出すと、それらのファイルの内容が出力されるはずです。例えば `test1.txt` が、

```
{{#include ../../../examples/feline/2/test1.txt}}
```

<!-- and `test2.txt` contains -->

として、`test2.txt` が、

```
{{#include ../../../examples/feline/2/test2.txt}}
```

<!-- then the command -->

のとき、次のコマンドを実行すると、

```
{{#command {feline/2} {feline/2} {./build/bin/feline test1.txt test2.txt} }}
```

<!-- should emit -->

以下のような出力になるはずです。

```
{{#command_out {feline/2} {./build/bin/feline test1.txt test2.txt} {feline/2/expected/test12.txt} }}
```

<!-- Finally, the `-` argument should be handled appropriately. -->

最後に、`-` の引数が適切に処理されることを確認します。

```
{{#command {feline/2} {feline/2} {echo "and purr" | ./build/bin/feline test1.txt - test2.txt} }}
```

<!-- should yield -->

結果は次のようになるはずです。

```
{{#command_out {feline/2} {echo "and purr" | ./build/bin/feline test1.txt - test2.txt} {feline/2/expected/test1purr2.txt}}}
```

<!-- ## Exercise -->

## 演習問題

<!-- Extend `feline` with support for usage information.
The extended version should accept a command-line argument `--help` that causes documentation about the available command-line options to be written to standard output. -->

`feline` が使用方法の情報をサポートするように拡張しましょう。拡張したバージョンでは、`--help` 引数を受け取るようにします。この引数が渡された場合、`feline` で使用できるコマンドラインオプションについてのドキュメントが標準出力に表示されるようにします。
