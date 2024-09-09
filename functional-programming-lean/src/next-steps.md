<!--
# Next Steps
-->

# 次のステップ

<!--
This book introduces the very basics of functional programming in Lean, including a tiny amount of interactive theorem proving.
Using dependently-typed functional languages like Lean is a deep topic, and much can be said.
Depending on your interests, the following resources might be useful for learning Lean 4.
-->

本書は、ごくわずかの対話的定理証明を含めたLeanによる関数型プログラミングのごく基本的なことについて紹介しています。Leanのような依存型関数型言語の使用は深いトピックであり、語るべきことはまだまだあります。読者の興味に応じて、以下のリソースがLean4の学習に役立つでしょう。

<!--
## Learning Lean
-->

## Lean自体の学習

<!--
Lean 4 itself is described in the following resources:
-->

Lean4そのものについては以下のリソースで記述されています：

 <!--
 * [Theorem Proving in Lean 4](https://leanprover.github.io/theorem_proving_in_lean4/) is a tutorial on writing proofs using Lean.
 * [The Lean 4 Manual](https://leanprover.github.io/lean4/doc/) provides a reference for the language and its features. At the time of writing, it is still incomplete, but it describes many aspects of Lean in greater detail than this book.
 * [How To Prove It With Lean](https://djvelleman.github.io/HTPIwL/) is a Lean-based accompaniment to the well-regarded textbook [_How To Prove It_](https://www.cambridge.org/highereducation/books/how-to-prove-it/6D2965D625C6836CD4A785A2C843B3DA#overview) that provides an introduction to writing paper-and-pencil mathematical proofs.
 * [Metaprogramming in Lean 4](https://github.com/arthurpaulino/lean4-metaprogramming-book) provides an overview of Lean's extension mechanisms, from infix operators and notations to macros, custom tactics, and full-on custom embedded languages.
 * [Functional Programming in Lean](https://leanprover.github.io/functional_programming_in_lean/) may be interesting to readers who enjoy jokes about recursion.
-->

 * [Theorem Proving in Lean 4](https://leanprover.github.io/theorem_proving_in_lean4/) はLeanで証明を書くためのチュートリアルです。[^fn1]
 * [The Lean 4 Manual](https://leanprover.github.io/lean4/doc/) はLean言語とその機能のリファレンスを提供しています。本書執筆時点ではまだ不完全ですが、本書よりもLeanの多くの側面が詳細に記述されています。
 * [How To Prove It With Lean](https://djvelleman.github.io/HTPIwL/) は [_How To Prove It_](https://www.cambridge.org/highereducation/books/how-to-prove-it/6D2965D625C6836CD4A785A2C843B3DA#overview) という定評のある教科書のLeanベースの付録であり、紙と鉛筆で数学的証明を書くための入門書です。
 * [Metaprogramming in Lean 4](https://github.com/arthurpaulino/lean4-metaprogramming-book) は中置演算子や記法などからマクロ・カスタムのタクティク・完全にカスタムな組み込み言語まで、Leanの拡張メカニズムの概要を提供しています。
 * [Functional Programming in Lean](https://leanprover.github.io/functional_programming_in_lean/) は再帰に関するジョークが好きな読者には面白いかもしれません。

<!--
However, the best way to continue learning Lean is to start reading and writing code, consulting the documentation when you get stuck.
Additionally, the [Lean Zulip](https://leanprover.zulipchat.com/) is an excellent place to meet other Lean users, ask for help, and help others.
-->

しかし、Leanを学び続ける最善の方法はコードを読み、実際に書いてみて、行き詰った時にはドキュメントを参照することです。さらに、[Lean Zulip](https://leanprover.zulipchat.com/) はほかのLeanユーザに会ったり、助けを求めたり、他の人を助けたりするのに最適な場所です。

<!--
## The Standard Library
-->

## 標準ライブラリ

<!--
Out of the box, Lean itself includes a fairly minimal library.
Lean is self-hosted, and the included code is just enough to implement Lean itself.
For many applications, a larger standard library is needed.
-->

いざふたを開けてみると、Lean自体にはかなり最小限のライブラリしか含まれていません。Leanはセルフホスティッドであり、含まれているコードはLean自身を十分実装しうるものです。多くのアプリケーションではより大きな標準ライブラリが必要です。

<!--
[std4](https://github.com/leanprover/std4) is an in-progress standard library that includes many data structures, tactics, type class instances, and functions that are out of scope for the Lean compiler itself.
To use `std4`, the first step is to find a commit in its history that's compatible with the version of Lean 4 that you're using (that is, one in which the `lean-toolchain` file matches the one in your project).
Then, add the following to the top level of your `lakefile.lean`, where `COMMIT_HASH` is the appropriate version:
```lean
require std from git
  "https://github.com/leanprover/std4/" @ "COMMIT_HASH"
```
-->

[batteries](https://github.com/leanprover-community/batteries) [^fn2] は現在進行形で開発されている標準ライブラリであり、Leanのコンパイラ自体のスコープから外れた多くのデータ構造・タクティク・型クラスのインスタンス・関数を保持しています。`batteries` を使用するにはまず、使用しているLean4のバージョンと互換性のあるコミットを探します（つまり、`lean-toolchain` ファイルが読者のプロジェクトのものと一致するものです）。次に、`lakefile.lean` のトップレベルに以下を追加します。ここで `COMMIT_HASH` は適切なバージョンを指します：
```lean
require batteries from git
  "https://github.com/leanprover-community/batteries" @ "COMMIT_HASH"
```


<!--
## Mathematics in Lean
-->

## Leanによる数学

<!--
Most resources for mathematicians are written for Lean 3.
A wide selection are available at [the community site](https://leanprover-community.github.io/learn.html).
To get started doing mathematics in Lean 4, it is probably easiest to participate in the process of porting the mathematics library `mathlib` from Lean 3 to Lean 4.
Please see the [`mathlib4` README](https://github.com/leanprover-community/mathlib4) for further information.
-->

数学者のためのリソースのほとんどはLean3用に書かれています。[コミュニティサイト](https://leanprover-community.github.io/learn.html) では幅広い分野があります。Lean4で数学を始めるには、数学ライブラリ `mathlib` をLean3からLean4に移植するプロセスに参加することが一番簡単でしょう。詳しくは [`mathlib4` README](https://github.com/leanprover-community/mathlib4) を参照してください。

<!--
## Using Dependent Types in Computer Science
-->

## 計算機科学における依存型の利用

<!--
Coq is a language that has a lot in common with Lean.
For computer scientists, the [Software Foundations](https://softwarefoundations.cis.upenn.edu/) series of interactive textbooks provides an excellent introduction to applications of Coq in computer science.
The fundamental ideas of Lean and Coq are very similar, and skills are readily transferable between the systems.
-->

CoqはLeanと多くの共通点を持つ言語です。計算機科学者にとっては対話的な教科書 [Software Foundations](https://softwarefoundations.cis.upenn.edu/) シリーズは計算機科学におけるCoqの応用について優れた入門書を提供しています。LeanとCoqの基本的な考え方は非常に似ており、言語に対するスキルはシステム間で容易に移行可能です。

<!--
## Programming with Dependent Types
-->

## 依存型によるプログラミング

<!--
For programmers who are interested in learning to use indexed families and dependent types to structure programs, Edwin Brady's [_Type Driven Development with Idris_](https://www.manning.com/books/type-driven-development-with-idris) provides an excellent introduction.
Like Coq, Idris is a close cousin of Lean, though it lacks tactics.
-->

プログラムを構造化するために添字族と依存型を使うことを学びたいと思っているプログラマにとって、Edwin Bradyの [_Type Driven Development with Idris_](https://www.manning.com/books/type-driven-development-with-idris) は素晴らしい入門書となります。Coqと同様、IdrisはLeanの親戚ですが、タクティクはありません。

<!--
## Understanding Dependent Types
-->

## 依存型の理解

<!--
[_The Little Typer_](https://thelittletyper.com/) is a book for programmers who haven't formally studied logic or the theory of programming languages, but who want to build an understanding of the core ideas of dependent type theory.
While all of the above resources aim to be as practical as possible, _The Little Typer_ presents an approach to dependent type theory where the very basics are built up from scratch, using only concepts from programming.
Disclaimer: the author of _Functional Programming in Lean_ is also an author of _The Little Typer_.
-->

[_The Little Typer_](https://thelittletyper.com/) は論理学やプログラミング言語の理論を正式に学んだことはないが、依存型理論の核となる考え方について理解を深めたいと考えているプログラマのための本です。上記のすべてのリソースが可能な限り実用的であることを目指しているのに対し、_The Little Typer_ はプログラミングの概念のみを用いて0から基本を構築する依存型理論へのアプローチを提示しています。免責事項：_Functional Programming in Lean_ の著者は _The Little Typer_ の著者でもあります。

[^fn1]: 日本語訳は https://aconite-ac.github.io/theorem_proving_in_lean4_ja/

[^fn2]: 原文が書かれた当時は `std4` という名前でしたが、改名されたことに合わせて日本語訳の文章を修正しています。