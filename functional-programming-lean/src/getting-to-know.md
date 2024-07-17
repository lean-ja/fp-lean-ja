<!-- According to tradition, a programming language should be introduced by
compiling and running a program that displays `"Hello, world!"` on the
console. This simple program ensures that the language tooling is
installed correctly and that the programmer is able to run the
compiled code. -->

伝統によれば，プログラミング言語は，コンソールに `"Hello, world!"` と表示するプログラムをコンパイルし，実行することで導入されるべきです．この単純なプログラムは，言語ツールが正しくインストールされ，プログラマがコンパイルされたコードを実行できることを保証します．

<!-- Since the 1970s, however, programming has changed. Today, compilers
are typically integrated into text editors, and the programming
environment offers feedback as the program is written. Lean is no
exception: it implements an extended version of the Language Server
Protocol that allows it to communicate with a text editor and provide
feedback as the user types. -->

しかし，1970年代以降，プログラミングは変わりました．今日，コンパイラは一般的にテキストエディタに統合されており，プログラミング環境はプログラムを書く際にフィードバックを提供してくれます．Lean も例外ではありません：Lean は言語サーバープロトコル（LSP：Language Server Protocol）の拡張版を実装していて，テキストエディタと情報交換し，ユーザが入力する際にフィードバックを提供することができます．

<!-- Languages as varied as Python, Haskell, and JavaScript offer a read-eval-print-loop (REPL), also known as an interactive toplevel or a browser console, in which expressions or statements can be entered.
The language then computes and displays the result of the user's input.
Lean, on the other hand, integrates these features into the interaction with the editor, providing commands that cause the text editor to display feedback integrated into the program text itself.
This chapter provides a short introduction to interacting with Lean in an editor, while [Hello, World!]() describes how to use Lean traditionally from the command line in batch mode. -->

Python・Haskell・JavaScript などのさまざまな言語が，REPL（read-eval-print-loop）を提供しています．REPL は対話的なトップレベル，あるいはブラウザコンソールとしても知られています．REPL 環境内では，ユーザが式や文を入力することができます．そして，プログラミング言語はユーザの入力に基づき計算を実行し，結果を表示します．一方 Lean は，これらの機能をエディタとの対話機能に統合し，プログラムテキスト自体に統合されたフィードバックをテキストエディタ上に表示させるコマンドを提供します．この章では，エディタで Lean を操作する方法を簡単に紹介します．[Hello, World!](hello-world.md)ではバッチモードでコマンドラインから Lean を使用する伝統的な方法を説明します．

<!-- It is best if you read this book with Lean open in your editor,
following along and typing in each example. Please play with the
examples, and see what happens! -->

この本は，Lean をエディタで開きながら，それぞれの例に沿って入力しながら読むのがベストです．例で遊んで，何が起こるか見てみましょう！
