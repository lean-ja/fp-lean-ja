

<!-- Lean is an interactive theorem prover developed at Microsoft Research, based on dependent type theory.
Dependent type theory unites the worlds of programs and proofs; thus, Lean is also a programming language.
Lean takes its dual nature seriously, and it is designed to be suitable for use as a general-purpose programming language—Lean is even implemented in itself.
This book is about writing programs in Lean. -->

Leanはマイクロソフト・リサーチで開発された，dependent type theory (従属型理論) に基づく対話型証明支援系である．従属型理論はプログラムと証明の世界を結びつける：したがって，Lean はプログラミング言語でもある．Lean はその両面を重視しており，汎用プログラミング言語として使用できるように設計されている．ーー Lean は Lean 自身で実装されている．本書は，Lean でプログラムを書くことをテーマにしている．

<!-- When viewed as a programming language, Lean is a strict pure functional language with dependent types.
A large part of learning to program with Lean consists of learning how each of these attributes affects the way programs are written, and how to think like a functional programmer.
_Strictness_ means that function calls in Lean work similarly to the way they do in most languages: the arguments are fully computed before the function's body begins running.
_Purity_ means that Lean programs cannot have side effects such as modifying locations in memory, sending emails, or deleting files without the program's type saying so.
Lean is a _functional_ language in the sense that functions are first-class values like any other and that the execution model is inspired by the evaluation of mathematical expressions.
_Dependent types_, which are the most unusual feature of Lean, make types into a first-class part of the language, allowing types to contain programs and programs to compute types. -->

プログラミング言語として見た場合，Lean は従属型を持つ strict (正格)な純粋関数型言語である．Lean でのプログラミングを学ぶには，これらの特徴がそれぞれプログラムの書き方にどのような影響を与えるか，そして関数型プログラマーがどのように考えるかを学ぶ必要がある．正格性は，Lean における関数呼び出しが，ほとんどの言語と同様に機能することを意味する：つまり，関数本体の実行が始まる前に，引数が完全に計算される．純粋性は，型で明記されていない限り，Lean のプログラムがメモリ内で場所を変更したり，電子メールを送信したり，ファイルを削除したりといった副作用を起こさないことを意味する．Lean は関数型言語であり，ほかの関数型言語と同様，関数は第一級の値であり，数学的な式の評価から実行モデルの着想を得ている．依存型は Lean の最も珍しい特徴であり，型を言語の第一級の部分にすることで，型がプログラムを含み，プログラムが型を計算することを可能にする．

<!-- This book is intended for programmers who want to learn Lean, but who have not necessarily used a functional programming language before.
Familiarity with functional languages such as Haskell, OCaml, or F# is not required.
On the other hand, this book does assume knowledge of concepts like loops, functions, and data structures that are common to most programming languages.
While this book is intended to be a good first book on functional programming, it is not a good first book on programming in general. -->

本書は，Lean を学びたいが，必ずしも関数型言語を使ったことがないプログラマーを対象としている．Haskell、OCaml、F# などの関数型言語に精通していることは必須ではない．一方，本書はループ・関数・データ構造など，ほとんどのプログラミング言語に共通する概念の知識を前提としている．本書は関数型プログラミングの最初の一冊としては好適だが，プログラミング全般の最初の一冊としては不適切だ．

<!-- Mathematicians who are using Lean as a proof assistant will likely need to write custom proof automation tools at some point.
This book is also for them.
As these tools become more sophisticated, they begin to resemble programs in functional languages, but most working mathematicians are trained in languages like Python and Mathematica.
This book can help bridge the gap, empowering more mathematicians to write maintainable and understandable proof automation tools. -->

Lean を証明アシスタントとして使っている数学者は，いずれ自前の証明自動化ツールが必要になるだろう．この本はそのような人たちのためのものでもある．これらのツールは洗練されるにつれ関数型言語のプログラムに似てくるが，現役の数学者のほとんどは Python や Mathematica のような言語で訓練を受けている．本書は，より多くの数学者が保守可能で理解しやすい証明自動化ツールを書けるように，そのギャップを埋める助けとなるだろう．

<!-- This book is intended to be read linearly, from the beginning to the end.
Concepts are introduced one at a time, and later sections assume familiarity with earlier sections.
Sometimes, later chapters will go into depth on a topic that was only briefly addressed earlier on.
Some sections of the book contain exercises.
These are worth doing, in order to cement your understanding of the section.
It is also useful to explore Lean as you read the book, finding creative new ways to use what you have learned. -->

本書は最初から最後まで，直線的に読むことを意図している．概念は1つずつ導入され，後のセクションは前のセクションを理解していることを前提としている．時には，先の章では簡単にしか触れなかったトピックについて，後の章で深く掘り下げることもある．本書のいくつかのセクションには練習問題が含まれている．演習問題は，そのセクションの理解を深めるために取り組む価値がある．また，本を読みながら Lean を探求し，学んだことを使う創造的な新しい方法を見つけることも有効である．

<!-- # Getting Lean -->
# Lean のインストール

<!-- Before writing and running programs written in Lean, you'll need to set up Lean on your own computer.
The Lean tooling consists of the following: -->

Lean でプログラムを書いて実行する前に, 自分のコンピューターに Lean をセットアップする必要がある．Lean のツール構成は下記の通り：

 <!-- * `elan` manages the Lean compiler toolchains, similarly to `rustup` or `ghcup`. -->
 * `elan` は Lean のツールチェーンのインストーラで，`rustup` や `ghcup` と同様．
 <!-- * `lake` builds Lean packages and their dependencies, similarly to `cargo`, `make`, or Gradle. -->
 * `lake` は, `cargo` や `make`, Gradle と同様に, Lean パッケージとその依存関係をビルドする．
 <!-- * `lean` type checks and compiles individual Lean files as well as providing information to programmer tools about files that are currently being written.
   Normally, `lean` is invoked by other tools rather than directly by users. -->
 * `Lean` は、個々の Lean ファイルを型チェックし, コンパイルするだけでなく, プログラマー・ツールに現在書かれているファイルに関する情報を提供する. 通常, Lean はユーザーが直接呼び出すのではなく, 他のツールによって呼び出される.
 <!-- * Plugins for editors, such as Visual Studio Code or Emacs, that communicate with `lean` and present its information conveniently. -->
 * Visual Studio Code や Emacs などのエディタ用のプラグインで，`lean` と通信し, lean の情報を便利に表示することができる.

<!-- Please refer to the [Lean manual](https://leanprover.github.io/lean4/doc/quickstart.html) for up-to-date instructions for installing Lean. -->

Lean の最新のインストール方法については, [Lean のマニュアル](https://leanprover.github.io/lean4/doc/quickstart.html)を参照のこと．

<!-- # Typographical Conventions -->
# 表記法

<!-- Code examples that are provided to Lean as _input_ are formatted like this: -->

Lean に入力として提供されるコード例は，このような書式とする：

```lean
{{#example_decl Examples/Intro.lean add1}}

{{#example_in Examples/Intro.lean add1_7}}
```

<!-- The last line above (beginning with `#eval`) is a command that instructs Lean to calculate an answer.
Lean's replies are formatted like this: -->

上の最後の行（`#eval`で始まる行）は, Lean に答えを計算するように指示するコマンドだ．Lean の返事は以下のような書式とする：

```output info
{{#example_out Examples/Intro.lean add1_7}}
```

<!-- Error messages returned by Lean are formatted like this: -->

Lean が返すエラーメッセージは下記のような書式とする：

```output error
{{#example_out Examples/Intro.lean add1_string}}
```

<!-- Warnings are formatted like this: -->

警告は次のような書式で表示する：

```output warning
declaration uses 'sorry'
```

<!-- # Unicode -->
# Unicode

<!-- Idiomatic Lean code makes use of a variety of Unicode characters that are not part of ASCII.
For instance, Greek letters like `α` and `β` and the arrow `→` both occur in the first chapter of this book.
This allows Lean code to more closely resemble ordinary mathematical notation. -->

慣用的な Lean コードは，ASCII には含まれないさまざまな Unicode 文字を使用する．例えば，ギリシャ文字の `α` や `β`，矢印の `→` が，いずれも本書の第1章に登場する．これにより, Lean のコードは通常の数学表記により近くなる．

<!-- With the default Lean settings, both Visual Studio Code and Emacs allow these characters to be typed with a backslash (`\`) followed by a name.
For example, to enter `α`, type `\alpha`.
To find out how to type a character in Visual Studio Code, point the mouse at it and look at the tooltip.
In Emacs, use `C-c C-k` with point on the character in question. -->

デフォルトの Lean の設定では，Visual Studio Code も Emacs も，バックスラッシュ(`\`)の後に名前を続けることでこれらの文字を入力することができる. たとえば `α` と入力するには `\alpha` とタイプする．Visual Studio Code で文字の入力方法を調べるには，マウスをその文字に向けてツールチップを見ればよい．Emacs の場合、`C-c C-k` を問題の文字にポイントして使う．