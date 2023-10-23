# Hello, World!

<!--
While Lean has been designed to have a rich interactive environment in which programmers can get quite a lot of feedback from the language without leaving the confines of their favorite text editor, it is also a language in which real programs can be written.
This means that it also has a batch-mode compiler, a build system, a package manager, and all the other tools that are necessary for writing programs.
-->

Lean には豊かな対話的環境があり，プログラマはお気に入りのテキストエディタを離れることなく，多くのフィードバックを得ることができます．また，Lean は実用的なプログラムを記述することができる言語でもあります．つまり，バッチモードのコンパイラ，ビルドシステム，パッケージマネージャなど，プログラムを書くために不可欠なツールもすべて備えているということです．

<!--
While the [previous chapter](./getting-to-know.md) presented the basics of functional programming in Lean, this chapter explains how to start a programming project, compile it, and run the result.
Programs that run and interact with their environment (e.g. by reading input from standard input or creating files) are difficult to reconcile with the understanding of computation as the evaluation of mathematical expressions.
In addition to a description of the Lean build tools, this chapter also provides a way to think about functional programs that interact with the world.
-->

[前の章](./getting-to-know.md)では，Lean における関数型プログラミングの基本を紹介しましたが，この章ではプロジェクトを作成し，コンパイルして，その結果を実行する一連の方法を説明します．環境と相互作用するプログラム（例えば，標準入力を読み取ったりファイルを作成したりすること）と，計算を「数学的な式の評価」と解釈する関数型プログラミングは，整合させることが難しいものです．この章では Lean のビルドツールの説明に加え，関数型プログラミングにおいて世界と相互作用するようなプログラムをどのように扱うかについても説明します．