<!-- Lean is an interactive theorem prover developed at Microsoft Research, based on dependent type theory.
Dependent type theory unites the worlds of programs and proofs; thus, Lean is also a programming language.
Lean takes its dual nature seriously, and it is designed to be suitable for use as a general-purpose programming language—Lean is even implemented in itself.
This book is about writing programs in Lean. -->

Lean はマイクロソフトリサーチで開発された、**依存型理論**（dependent type theory）に基づく対話型証明支援系です。依存型理論はプログラムと証明の世界を結びつけます：したがって、Lean はプログラミング言語でもあります。Lean はその両面を重視していて、汎用プログラミング言語として使用できるように設計されています。ーー Lean は Lean 自身で実装されています。本書は、Lean でプログラムを書くことをテーマにしています。

<!-- When viewed as a programming language, Lean is a strict pure functional language with dependent types.
A large part of learning to program with Lean consists of learning how each of these attributes affects the way programs are written, and how to think like a functional programmer.
_Strictness_ means that function calls in Lean work similarly to the way they do in most languages: the arguments are fully computed before the function's body begins running.
_Purity_ means that Lean programs cannot have side effects such as modifying locations in memory, sending emails, or deleting files without the program's type saying so.
Lean is a _functional_ language in the sense that functions are first-class values like any other and that the execution model is inspired by the evaluation of mathematical expressions.
_Dependent types_, which are the most unusual feature of Lean, make types into a first-class part of the language, allowing types to contain programs and programs to compute types. -->

プログラミング言語として見た場合、Lean は依存型を持つ正格（strict）な純粋関数型言語です。Lean でのプログラミングを学ぶには、これらの特徴がそれぞれプログラムの書き方に与える影響と、関数型プログラマのように考える方法を学ぶ必要があります。**正格性**（strictness）は、Lean における関数呼び出しが、ほとんどの言語と同様に機能することを意味します：つまり、関数本体の実行が始まる前に、引数が完全に計算されます。**純粋性**（purity）は、副作用を起こしうることがプログラムの型に明記されていない限り、Lean のプログラムがメモリ内で場所を変更したり、電子メールを送信したり、ファイルを削除したりといった副作用を起こしえないことを意味します。Lean は**関数型**言語であり、これは他の値と同様に関数が第一級の値であることと、プログラムの実行モデルが数式の評価から着想を得ていることを意味します。**依存型**（dependent types）は Lean の最も珍しい特徴であり、型すらも言語の第一級の部分にすることで、型がプログラムを含むことと、プログラムが型を計算することを可能にします。

<!-- This book is intended for programmers who want to learn Lean, but who have not necessarily used a functional programming language before.
Familiarity with functional languages such as Haskell, OCaml, or F# is not required.
On the other hand, this book does assume knowledge of concepts like loops, functions, and data structures that are common to most programming languages.
While this book is intended to be a good first book on functional programming, it is not a good first book on programming in general. -->

本書は、Lean を学びたいが、必ずしも関数型言語を使ったことがないプログラマを対象としています。Haskell・OCaml・F# などの関数型言語に精通している必要はありません。一方、本書はループ・関数・データ構造など、ほとんどのプログラミング言語に共通する概念の知識を前提としています。本書は関数型プログラミングを学ぶ最初の一冊としては好適ですが、プログラミング全般を学ぶ最初の一冊としては不適切です。

<!-- Mathematicians who are using Lean as a proof assistant will likely need to write custom proof automation tools at some point.
This book is also for them.
As these tools become more sophisticated, they begin to resemble programs in functional languages, but most working mathematicians are trained in languages like Python and Mathematica.
This book can help bridge the gap, empowering more mathematicians to write maintainable and understandable proof automation tools. -->

Lean を証明支援系として使っている数学者は、いずれ自前の証明自動化ツールが必要になるでしょう。この本はそのような人たちのためのものでもあります。これらのツールは洗練されるにつれ関数型言語のプログラムに似てきますが、現役の数学者のほとんどは Python や Mathematica のような言語で訓練を受けています。本書は、より多くの数学者が保守可能で理解しやすい証明自動化ツールを書けるように、このような言語と関数型言語のギャップを埋める助けとなるでしょう。

<!-- This book is intended to be read linearly, from the beginning to the end.
Concepts are introduced one at a time, and later sections assume familiarity with earlier sections.
Sometimes, later chapters will go into depth on a topic that was only briefly addressed earlier on.
Some sections of the book contain exercises.
These are worth doing, in order to cement your understanding of the section.
It is also useful to explore Lean as you read the book, finding creative new ways to use what you have learned. -->

本書は最初から最後まで直線的に、つまり飛ばさず読むことを意図しています。概念は1つずつ導入され、後の節は前の節を理解していることを前提としています。時には、先の章では簡単にしか触れなかったトピックについて、後の章で深く掘り下げることもあります。本書のいくつかの節には演習問題が含まれています。演習問題は、その節の理解を深めるために取り組む価値があります。また、本を読みながら Lean を実際に使い、学んだことを使う創造的な新しい方法を見つけることも有効です。

<!-- # Getting Lean -->
# Lean のインストール

<!-- Before writing and running programs written in Lean, you'll need to set up Lean on your own computer.
The Lean tooling consists of the following: -->

Lean でプログラムを書いて実行する前に、自分のコンピュータに Lean をセットアップする必要があります。Lean のツール構成は下記の通りです：

 <!-- * `elan` manages the Lean compiler toolchains, similarly to `rustup` or `ghcup`. -->
 * `elan` は、`rustup` や `ghcup` と同様に、Lean のツールチェーンを管理します。
 <!-- * `lake` builds Lean packages and their dependencies, similarly to `cargo`, `make`, or Gradle. -->
 * `lake` は、`cargo`・`make`・Gradle と同様に、Lean パッケージとその依存関係をビルドします。
 <!-- * `lean` type checks and compiles individual Lean files as well as providing information to programmer tools about files that are currently being written.
   Normally, `lean` is invoked by other tools rather than directly by users. -->
 * `lean`（シェルコマンド）は、個々の Lean ファイルを型検査し、コンパイルするだけでなく、編集中のファイルに関する情報をプログラマツールに提供します。通常、`lean` はユーザが直接呼び出すのではなく、他のツールによって呼び出されます。
 <!-- * Plugins for editors, such as Visual Studio Code or Emacs, that communicate with `lean` and present its information conveniently. -->
 * Visual Studio Code や Emacs などのエディタ用のプラグイン（拡張機能）は、`lean` と情報交換し、その情報を便利な形で表示します。

<!-- Please refer to the [Lean manual](https://leanprover.github.io/lean4/doc/quickstart.html) for up-to-date instructions for installing Lean. -->

Lean の最新のインストール方法については、[Lean Manual](https://leanprover.github.io/lean4/doc/quickstart.html)を参照してください。

<!-- # Typographical Conventions -->
# 本書の書式

<!-- Code examples that are provided to Lean as _input_ are formatted like this: -->

Lean に**入力**（input）として提供されるコード例は、このような書式とします：

```lean
{{#example_decl Examples/Intro.lean add1}}

{{#example_in Examples/Intro.lean add1_7}}
```

<!-- The last line above (beginning with `#eval`) is a command that instructs Lean to calculate an answer.
Lean's replies are formatted like this: -->

上の最後の行（`#eval` で始まる行）は、Lean に答えを計算するように指示するコマンドです。Lean の返事はこのような書式とします：

```output info
{{#example_out Examples/Intro.lean add1_7}}
```

<!-- Error messages returned by Lean are formatted like this: -->

Lean が返すエラーメッセージはこのような書式とします：

```output error
{{#example_out Examples/Intro.lean add1_string}}
```

<!-- Warnings are formatted like this: -->

警告はこのような書式とします：

```output warning
declaration uses 'sorry'
```

<!-- # Unicode -->
# Unicode

<!-- Idiomatic Lean code makes use of a variety of Unicode characters that are not part of ASCII.
For instance, Greek letters like `α` and `β` and the arrow `→` both occur in the first chapter of this book.
This allows Lean code to more closely resemble ordinary mathematical notation. -->

慣用的な Lean のコードには、ASCII には含まれないさまざまな Unicode 文字が使用されます。例えば、ギリシャ文字の `α` や `β`、矢印の `→` が、いずれも本書の第1章に登場します。Unicode 文字により、Lean のコードは通常の数学的表記により近くなります。

<!-- With the default Lean settings, both Visual Studio Code and Emacs allow these characters to be typed with a backslash (`\`) followed by a name.
For example, to enter `α`, type `\alpha`.
To find out how to type a character in Visual Studio Code, point the mouse at it and look at the tooltip.
In Emacs, use `C-c C-k` with point on the character in question. -->

デフォルトの Lean の設定では、Visual Studio Code でも Emacs でも、バックスラッシュ（`\`）の後に名前を続けることで Unicode 文字を入力することができます。例えば、`α` と入力するには `\alpha` とタイプします。Visual Studio Code で文字の入力方法を調べるには、マウスでその文字をポイントしてツールチップを見ればよいです。Emacs の場合、問題の文字をポイントしてから `C-c C-k` を使えばよいです。
