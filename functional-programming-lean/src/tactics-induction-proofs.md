<!--
# Interlude: Tactics, Induction, and Proofs
-->

# 休憩：タクティク・帰納法・証明

<!--
## A Note on Proofs and User Interfaces
-->

## 証明とユーザインタフェースについての注意

<!--
This book presents the process of writing proofs as if they are written in one go and submitted to Lean, which then replies with error messages that describe what remains to be done.
The actual process of interacting with Lean is much more pleasant.
Lean provides information about the proof as the cursor is moved through it and there are a number of interactive features that make proving easier.
Please consult the documentation of your Lean development environment for more information.
-->

本書では証明の書き方について、あたかも一度に書いてLeanに提出し、Leanがエラーメッセージを返して残りの作業を説明するものであるかのように紹介しました。Leanとのやりとりは実際にはもっと楽しいものです。Leanはカーソルが移動するたびに証明に関する情報を提供し、証明を簡単にする対話的な機能も多数存在します。詳細についてはLean開発環境のドキュメントを参照してください。

<!--
The approach in this book that focuses on incrementally building a proof and showing the messages that result demonstrates the kinds of interactive feedback that Lean provides while writing a proof, even though it is much slower than the process used by experts.
At the same time, seeing incomplete proofs evolve towards completeness is a useful perspective on proving.
As your skill in writing proofs increases, Lean's feedback will come to feel less like errors and more like support for your own thought processes.
Learning the interactive approach is very important.
-->

本書での、証明の段階的な構築とその結果得られるメッセージの表示に焦点を当てたアプローチは、Leanのエキスパートが使う手順よりはるかに遅いとはいえ、証明を書いている最中にLeanが提供してくれる種類の対話的なフィードバックを示しています。同時に、不完全な証明が完全なものへと進化していく過程を見ることは、証明する上で有益な視点となります。証明を書くスキルが上がるにつれて、Leanのフィードバックはエラーではなく、読者自身の思考プロセスをサポートするものであると感じられるようになるでしょう。対話的なアプローチを学ぶことはとても重要です。

<!--
## Recursion and Induction
-->

## 再帰と帰納法

<!--
The functions `plusR_succ_left` and `plusR_zero_left` from the preceding chapter can be seen from two perspectives.
On the one hand, they are recursive functions that build up evidence for a proposition, just as other recursive functions might construct a list, a string, or any other data structure.
On the other, they also correspond to proofs by _mathematical induction_.
-->

前章の関数 `plusR_succ_left` と `plusR_zero_left` は2つの観点から見ることができます。一方からは、他の再帰関数がリストや文字列などのデータ構造を構築するのと同じように、命題の根拠を構築する再帰関数となります。他方からは、これは **数学的帰納法** （mathematical induction）による証明でもあります。

<!--
Mathematical induction is a proof technique where a statement is proven for _all_ natural numbers in two steps:
-->

数学的帰納法はある文が以下の2つのステップによって **すべての** 自然数について証明されるという証明技法です：

 <!--
 1. The statement is shown to hold for \\( 0 \\). This is called the _base case_.
 2. Under the assumption that the statement holds for some arbitrarily chosen number \\( n \\), it is shown to hold for \\( n + 1 \\). This is called the _induction step_. The assumption that the statement holds for \\( n \\) is called the _induction hypothesis_.
-->

 1. その文が \\( 0 \\) について成り立つことを示す。これは **基本ケース** （base case）と呼ばれます。
 2. その文がとある任意に選ばれた整数 \\( n \\) について成り立つという仮定の下で \\( n + 1 \\) について成り立つことを示す。これは **帰納法のステップ** （induction step）と呼ばれます。その文が \\( n \\) について成り立つという仮定は **帰納法の仮定** （induction hypothesis）と呼ばれます。

<!--
Because it's impossible to check the statement for _every_ natural number, induction provides a means of writing a proof that could, in principle, be expanded to any particular natural number.
For example, if a concrete proof were desired for the number 3, then it could be constructed by using first the base case and then the induction step three times, to show the statement for 0, 1, 2, and finally 3.
Thus, it proves the statement for all natural numbers.
-->

その文を **すべての** 自然数についてチェックすることは不可能であるため、帰納法は原理的にはどのような自然数にも拡張できる証明を書く手段を提供します。例えば、3という値について具体的な証明が必要な場合、まず基本ケースを使い、次に帰納法のステップを3回使うことで、0・1・2、そして最後に3について証明することができます。こうして、すべての自然数についての証明ができます。

<!--
## The Induction Tactic
-->

## 帰納法のタクティク

<!--
Writing proofs by induction as recursive functions that use helpers such as `congrArg` does not always do a good job of expressing the intentions behind the proof.
While recursive functions indeed have the structure of induction, they should probably be viewed as an _encoding_ of a proof.
Furthermore, Lean's tactic system provides a number of opportunities to automate the construction of a proof that are not available when writing the recursive function explicitly.
Lean provides an induction _tactic_ that can carry out an entire proof by induction in a single tactic block.
Behind the scenes, Lean constructs the recursive function that corresponds the use of induction.
-->

`congrArg` のような補助関数を使用する再帰関数として帰納法による証明を書くことは、証明の背後にある意図を表現するにあたっては必ずしも良い仕事ではありません。再帰関数は確かに帰納法の構造を持っていますが、これは証明を **エンコード** したものと見なすべきでしょう。さらに、Leanのタクティクシステムは、再帰関数を明示的に記述する時には利用できない、証明の構築を自動化する多くの機会を提供します。Leanは1つのタクティクブロックで帰納法による証明全体を実行できる **induction** タクティクを提供しています。裏では、Leanは帰納法の使用に対応する再帰関数を構築しています。

<!--
To prove `plusR_zero_left` with the induction tactic, begin by writing its signature (using `theorem`, because this really is a proof).
Then, use `by induction k` as the body of the definition:
-->

帰納法のタクティクで `plusR_zero_left` を証明するには、まずそのシグネチャを書くことから始めます（これは正真正銘の証明であるため、`theorem` を使います）。続いて、`by induction k` を定義の本体として使います：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_1}}
```
<!--
The resulting message states that there are two goals:
-->

出力されるメッセージでは2つのゴールが示されます：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_1}}
```
<!--
A tactic block is a program that is run while the Lean type checker processes a file, somewhat like a much more powerful C preprocessor macro.
The tactics generate the actual program.
-->

タクティクブロックはLeanの型チェッカがファイルを処理する間に実行されるプログラムであり、C言語のプリプロセッサマクロをより強力にしたようなものです。これらのタクティクは実際のプログラムを生成します。

<!--
In the tactic language, there can be a number of goals.
Each goal consists of a type together with some assumptions.
These are analogous to using underscores as placeholders—the type in the goal represents what is to be proved, and the assumptions represent what is in-scope and can be used.
In the case of the goal `case zero`, there are no assumptions and the type is `Nat.zero = Nat.plusR 0 Nat.zero`—this is the theorem statement with `0` instead of `k`.
In the goal `case succ`, there are two assumptions, named `n✝` and `n_ih✝`.
Behind the scenes, the `induction` tactic creates a dependent pattern match that refines the overall type, and `n✝` represents the argument to `Nat.succ` in the pattern.
The assumption `n_ih✝` represents the result of calling the generated function recursively on `n✝`.
Its type is the overall type of the theorem, just with `n✝` instead of `k`.
The type to be fulfilled as part of the goal `case succ` is the overall theorem statement, with `Nat.succ n✝` instead of `k`.
-->

タクティク言語ではゴールは複数になることがあります。それぞれのゴールは型といくつかの仮定から構成されます。これらはアンダースコアをプレースホルダとして使った場合と似ています。すなわち、ゴールの型は証明されるものを、仮定はスコープ内で使用できるものをそれぞれ表します。ゴール `case zero` の場合、仮定は無く、型は `Nat.zero = Nat.plusR 0 Nat.zero` となり、これは定理の `k` を `0` に置き換えた文です。ゴール `case succ` では、`n✝` と `n_ih✝` という2つの仮定があります。裏では、`induction` タクティクによって全体の型を絞り込む依存パターンマッチが作成され、`n✝` はそのパターンにおける `Nat.succ` の引数を表しています。仮定 `n_ih✝` は生成された関数を `n✝` に対して再帰的に呼び出した結果を表します。その型は定理の全体的な型に対して、ただ `k` の代わりに `n✝` にしただけのものです。ゴール `case succ` の一部として満たされる型は、定理全体の型に対して、`k` の代わりに `Nat.succ n✝` にしたものです。

<!--
The two goals that result from the use of the `induction` tactic correspond to the base case and the induction step in the description of mathematical induction.
The base case is `case zero`.
In `case succ`, `n_ih✝` corresponds to the induction hypothesis, while the whole of `case succ` is the induction step.
-->

`induction` タクティクを使用した結果得られた2つのゴールは数学的帰納法の説明における基本ケースと帰納法のステップに相当します。基本ケースは `case zero` です。`case succ` では、`n_ih✝` が帰納法の仮定に、`case succ` の全体が帰納法のステップにそれぞれ相当します。

<!--
The next step in writing the proof is to focus on each of the two goals in turn.
Just as `pure ()` can be used in a `do` block to indicate "do nothing", the tactic language has a statement `skip` that also does nothing.
This can be used when Lean's syntax requires a tactic, but it's not yet clear which one should be used.
Adding `with` to the end of the `induction` statement provides a syntax that is similar to pattern matching:
-->

この証明の記述にあたっての次のステップは2つのゴールに対して順番に焦点を当てることです。`do` ブロックにおいて `pure ()` を使うことで「何もしない」ことを示すことができるように、タクティク言語には `skip` という文があり、これも何もしません、これはLeanの構文がタクティクを要求しているものの、まだどれを使うべきか明確でない場合に使うことができます。`with` を `induction` 文の最後に追加すると、パターンマッチに似た構文になります：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_2a}}
```
<!--
Each of the two `skip` statements has a message associated with it.
The first shows the base case:
-->

2つの `skip` 文にはそれぞれメッセージが関連付けられます。1つ目は基本ケースについて示しています：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_2a}}
```
<!--
The second shows the induction step:
-->

2つ目は帰納法のステップについて示しています：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_2b}}
```
<!--
In the induction step, the inaccessible names with daggers have been replaced with the names provided after `succ`, namely `n` and `ih`.
-->

帰納法のステップにて、ダガーが付いたアクセスできない名前は `succ` の後に置いた名前、すなわち `n` と `ih` によって置き換えられています。

<!--
The cases after `induction ... with` are not patterns: they consist of the name of a goal followed by zero or more names.
The names are used for assumptions introduced in the goal; it is an error to provide more names than the goal introduces:
-->

`induction ... with` の後にあるこれらのケースはパターンではありません：これらは0個以上の名前を伴うゴールの名前です。この名前はゴールで導入される仮定に使われます；ゴールが導入する以上の名前を指定するとエラーになります：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_3}}
```
```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_3}}
```

<!--
Focusing on the base case, the `rfl` tactic works just as well inside of the `induction` tactic as it does in a recursive function:
-->

基本ケースに焦点を当てると、再帰関数の中での場合と同じように、`rfl` タクティクが `induction` タクティクの中でもうまく機能します：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_4}}
```
<!--
In the recursive function version of the proof, a type annotation made the expected type something that was easier to understand.
In the tactic language, there are a number of specific ways to transform a goal to make it easier to solve.
The `unfold` tactic replaces a defined name with its definition:
-->

この証明の再帰関数によるものでは、型注釈によって期待される型が理解しやすいものになっていました。タクティク言語ではゴールを解きやすくするための具体的な変換方法がいくつもあります。`unfold` タクティクは定義された名前をその定義に置き換えます：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_5}}
```
<!--
Now, the right-hand side of the equality in the goal has become `Nat.plusR 0 n + 1` instead of `Nat.plusR 0 (Nat.succ n)`:
-->

これで、ゴールの等式の右辺は `Nat.plusR 0 (Nat.succ n)` ではなく `Nat.plusR 0 n + 1` になりました：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_5}}
```

<!--
Instead of appealing to functions like `congrArg` and operators like `▸`, there are tactics that allow equality proofs to be used to transform proof goals.
One of the most important is `rw`, which takes a list of equality proofs and replaces the left side with the right side in the goal.
This almost does the right thing in `plusR_zero_left`:
-->

`congrArg` のような関数や `▸` のような演算子に訴える代わりに、証明のゴールを等号の証明によって変換することができるタクティクがあります。最も重要なものの1つが `rw` で、これは等号の証明のリストを受け取り、各等式の左辺に対応するゴールの式を右辺で置き換えます。これは `plusR_zero_left` にてほとんど正しく機能します：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_6}}
```
<!--
However, the direction of the rewrite was incorrect.
Replacing `n` with `Nat.plusR 0 n` made the goal more complicated rather than less complicated:
-->

しかし、書き換えの方向性が誤っていました。`n` を `Nat.plusR 0 n` に置き換えたことでゴールの複雑性は減るどころかむしろ増えました：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_6}}
```
<!--
This can be remedied by placing a left arrow before `ih` in the call to `rewrite`, which instructs it to replace the right-hand side of the equality with the left-hand side:
-->

これは `rewrite` の呼び出しで `ih` の前に左向き矢印を置くことで改善されます。これは等式の右辺を左辺で置き換えるよう指示します：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_done}}
```
<!--
This rewrite makes both sides of the equation identical, and Lean takes care of the `rfl` on its own.
The proof is complete.
-->

この書き換えによって等式の両辺が同一になり、Leanはこれをもって `rfl` を処理します。これで証明は完了です。

<!--
## Tactic Golf
-->

## タクティクゴルフ

<!--
So far, the tactic language has not shown its true value.
The above proof is no shorter than the recursive function; it's merely written in a domain-specific language instead of the full Lean language.
But proofs with tactics can be shorter, easier, and more maintainable.
Just as a lower score is better in the game of golf, a shorter proof is better in the game of tactic golf.
-->

ここまでのところ、タクティク言語はその真価をまだ発揮していません。上記の証明は再帰関数より短くありません；これは完全なLeanの言語ではなく、ドメイン固有の言語で書かれているに過ぎません。しかし、タクティクを使った証明はより短く、より簡単で、より保守しやすいものになります。ゴルフでスコアが低い方が良いように、タクティクゴルフでは証明が短い方が良いです。

<!--
The induction step of `plusR_zero_left` can be proved using the simplification tactic `simp`.
Using `simp` on its own does not help:
-->

`plusR_zero_left` の帰納法のステップは単純化のためのタクティク `simp` を使って証明することができます。`simp` を単独で使っても役に立ちません：

```leantac
{{#example_in Examples/Induction.lean plusR_zero_left_golf_1}}
```
```output error
{{#example_out Examples/Induction.lean plusR_zero_left_golf_1}}
```
<!--
However, `simp` can be configured to make use of a set of definitions.
Just like `rw`, these arguments are provided in a list.
Asking `simp` to take the definition of `Nat.plusR` into account leads to a simpler goal:
-->

しかし、`simp` は定義の集まりを使用するように設定することができます。`rw` と同様に、これらの引数はリストで提供します。`simp` に `Nat.plusR` の定義を考慮するよう依頼すると、よりシンプルなゴールにたどり着きます：

```leantac
{{#example_in Examples/Induction.lean plusR_zero_left_golf_2}}
```
```output error
{{#example_out Examples/Induction.lean plusR_zero_left_golf_2}}
```
<!--
In particular, the goal is now identical to the induction hypothesis.
In addition to automatically proving simple equality statements, the simplifier automatically replaces goals like `Nat.succ A = Nat.succ B` with `A = B`.
Because the induction hypothesis `ih` has exactly the right type, the `exact` tactic can indicate that it should be used:
-->

特に、このゴールは帰納法の仮定と同じものになりました。単純な等式を自動的に証明するだけでなく、単純化は `Nat.succ A = Nat.succ B` のようなゴールを `A = B` に自動的に置き換えます。帰納法の仮定 `ih` はまさに（exactly）正しい型を持っているため、`exact` タクティクによってその仮定を使うべきであることを示すことができます：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_3}}
```

<!--
However, the use of `exact` is somewhat fragile.
Renaming the induction hypothesis, which may happen while "golfing" the proof, would cause this proof to stop working.
The `assumption` tactic solves the current goal if _any_ of the assumptions match it:
-->

しかし、`exact` の使用はやや脆弱です。証明を「ゴルフ」している最中に帰納法の仮定の名前の変更があり得るため、この証明が機能しなくなる原因になります。`assumption` タクティクは仮定のうちの **どれか** がゴールにマッチすれば、それによって現在のゴールを解決します：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_4}}
```

<!--
This proof is no shorter than the prior proof that used unfolding and explicit rewriting.
However, a series of transformations can make it much shorter, taking advantage of the fact that `simp` can solve many kinds of goals.
The first step is to drop the `with` at the end of `induction`.
For structured, readable proofs, the `with` syntax is convenient.
It complains if any cases are missing, and it shows the structure of the induction clearly.
But shortening proofs can often require a more liberal approach.
-->

この証明は展開と明示的な書き換えを行った以前の証明よりも短くありません。しかし、`simp` が多くの種類のゴールを解決できるという事実を利用して、一連の変換を変換をより短くすることができます。最初のステップは `induction` の後ろの `with` を削除することです。構造化された読みやすい証明のためには、`with` 構文は便利です。ケースが欠けていれば文句を言い、帰納法の構造を明確に示すことができます。しかし、証明を短くするには、もっと自由なアプローチが必要になることがよくあります。

<!--
Using `induction` without `with` simply results in a proof state with two goals.
The `case` tactic can be used to select one of them, just as in the branches of the `induction ... with` tactic.
In other words, the following proof is equivalent to the prior proof:
-->

`with` 無しの `induction` を使用すると証明の状態は単純に2つのゴールを持ったものになります。`induction ... with` タクティクの分岐と同じように、`case` タクティクをそのどちらかのゴールを選択するために使うことができます。言い換えると、次の証明は前の証明と等価です：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_5}}
```

<!--
In a context with a single goal (namely, `k = Nat.plusR 0 k`), the `induction k` tactic yields two goals.
In general, a tactic will either fail with an error or take a goal and transform it into zero or more new goals.
Each new goal represents what remains to be proved.
If the result is zero goals, then the tactic was a success, and that part of the proof is done.
-->

ゴールを1つ持つコンテキスト（つまり `k = Nat.plusR 0 k` ）では、`induction k` タクティクは2つのゴールを生成します。一般的には、タクティクはエラーで失敗するかあるゴールを0個以上の新しいゴールに変換します。それぞれの新しいゴールは証明すべきことが残っていることを表します。もしその結果ゴールが0個になれば、そのタクティクは成功であり、その部分の証明は終わったことになります。

<!--
The `<;>` operator takes two tactics as arguments, resulting in a new tactic.
`T1 <;> T2` applies `T1` to the current goal, and then applies `T2` in _all_ goals created by `T1`.
In other words, `<;>` enables a general tactic that can solve many kinds of goals to be used on multiple new goals all at once.
One such general tactic is `simp`.
-->

`<;>` 演算子は2つのタクティクを引数に取り、新しいタクティクを生成します。`T1 <;> T2` は `T1` を現在のゴールに適用し、続いて `T2` を `T1` が作成した **すべての** ゴールに適用します。言い換えると、`<;>` は多くの種類のゴールを解決することができる一般的なタクティクを、一度に複数のゴールに使用することを可能にします。そのような一般的なタクティクの1つが `simp` です。

<!--
Because `simp` can both complete the proof of the base case and make progress on the proof of the induction step, using it with `induction` and `<;>` shortens the proof:
-->

`simp` はこの証明の基本ケースの完成と帰納法のステップを進めることの両方を行うことができるため、`induction` と `<;>` と一緒に使うことで証明を短縮することができます：

```leantac
{{#example_in Examples/Induction.lean plusR_zero_left_golf_6a}}
```
<!--
This results in only a single goal, the transformed induction step:
-->

この結果、ゴールはただ1つ、変換された帰納法のステップだけとなります：

```output error
{{#example_out Examples/Induction.lean plusR_zero_left_golf_6a}}
```
<!--
Running `assumption` in this goal completes the proof:
-->

このゴールで `assumption` を実行すれば証明が完了します：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_6}}
```
<!--
Here, `exact` would not have been possible, because `ih` was never explicitly named.
-->

ここで `ih` が明示的に名付けられていないため、`exact` は使えないでしょう。

<!--
For beginners, this proof is not easier to read.
However, a common pattern for expert users is to take care of a number of simple cases with powerful tactics like `simp`, allowing them to focus the text of the proof on the interesting cases.
Additionally, these proofs tend to be more robust in the face of small changes to the functions and datatypes involved in the proof.
The game of tactic golf is a useful part of developing good taste and style when writing proofs.
-->

初心者にとって、この証明は読みやすくはありません。しかし、熟練したユーザにとって `simp` のような強力なタクティクで多くの単純なケースを処理し、証明のテキストを興味深いケースに集中させることはよくあるパターンです。さらに、このような証明は、証明に関係する関数やデータ型の小さな変更に対して頑強である傾向があります。タクティクゴルフゲームは、証明を書く時のセンスとスタイルを磨くことに役立ちます。

<!--
## Induction on Other Datatypes
-->

## 他のデータ型への帰納法

<!--
Mathematical induction proves a statement for natural numbers by providing a base case for `Nat.zero` and an induction step for `Nat.succ`.
The principle of induction is also valid for other datatypes.
Constructors without recursive arguments form the base cases, while constructors with recursive arguments form the induction steps.
The ability to carry out proofs by induction is the very reason why they are called _inductive_ datatypes.
-->

数学的帰納法は `Nat.zero` の基本ケースと `Nat.succ` の帰納法のステップを提供することで自然数についての文を証明します。帰納法の原理はほかのデータ型でも有効です。再帰引数を持たないコンストラクタが基本ケースを形成し、再帰引数を持つコンストラクタが帰納法のステップを形成します。帰納法によって証明を実行できるこの能力がまさにこれらのデータ型を **帰納的** データ型と呼ぶ所以です。

<!--
One example of this is induction on binary trees.
Induction on binary trees is a proof technique where a statement is proven for _all_ binary trees in two steps:
-->

その一例が二分木に対する帰納法です。二分木に対する帰納法は、ある文が以下の2つのステップによって **すべての** 二分木について証明されるという証明技法です：

 <!--
 1. The statement is shown to hold for `BinTree.leaf`. This is called the base case.
 2. Under the assumption that the statement holds for some arbitrarily chosen trees `l` and `r`, it is shown to hold for `BinTree.branch l x r`, where `x` is an arbitrarily-chosen new data point. This is called the _induction step_. The assumptions that the statement holds for `l` and `r` are called the _induction hypotheses_.
-->

 1. その文が `BinTree.leaf` について成り立つことを示す。これは基本ケースと呼ばれます。
 2. その文がとある任意に選ばれた木 `l` と `r` について成り立つという仮定の下で `BinTree.branch l x r` について成り立つことを示す。ここで `x` は任意に選ばれた新しいデータの点です。これは **帰納法のステップ** と呼ばれます。その文が `l` と `r` について成り立つという仮定は **帰納法の仮定** と呼ばれます。

<!--
`BinTree.count` counts the number of branches in a tree:
-->

`BinTree.count` は木にある枝の数を数えます：

```lean
{{#example_decl Examples/Induction.lean BinTree_count}}
```
<!--
[Mirroring a tree](monads/conveniences.md#leading-dot-notation) does not change the number of branches in it.
This can be proven using induction on trees.
The first step is to state the theorem and invoke `induction`:
-->

[木のコピー](monads/conveniences.md#leading-dot-notation) は木の枝の数を変えません。これは木に対する帰納法を使って証明できます。最初のステップは定義を述べて `induction` を呼び出すことです：

```leantac
{{#example_in Examples/Induction.lean mirror_count_0a}}
```
<!--
The base case states that counting the mirror of a leaf is the same as counting the leaf:
-->

基本ケースは葉のコピーの数の計上は、もとの葉の数の計上と同じということを述べています：

```output error
{{#example_out Examples/Induction.lean mirror_count_0a}}
```
<!--
The induction step allows the assumption that mirroring the left and right subtrees won't affect their branch counts, and requests a proof that mirroring a branch with these subtrees also preserves the overall branch count:
-->

帰納法のステップでは、左と右の部分木のコピーをしても枝の数に影響がないという仮定を許し、これらの部分木を含んだ木をコピーしても全体の枝の数が保たれるという証明を要求します：

```output error
{{#example_out Examples/Induction.lean mirror_count_0b}}
```


<!--
The base case is true because mirroring `leaf` results in `leaf`, so the left and right sides are definitionally equal.
This can be expressed by using `simp` with instructions to unfold `BinTree.mirror`:
-->

基本ケースは真です。というのも `leaf` をコピーすると `leaf` になり、式の左右は定義上同値になるからです。これは `simp` を使って `BinTree.mirror` を展開する命令で表現できます：

```leantac
{{#example_in Examples/Induction.lean mirror_count_1}}
```
<!--
In the induction step, nothing in the goal immediately matches the induction hypotheses.
Simplifying using the definitions of `BinTree.count` and `BinTree.mirror` reveals the relationship:
-->

帰納法のステップでは、ゴールの中に帰納法の仮定とすぐに一致するものはありません。`BinTree.count` と `BinTree.mirror` の定義を使って単純化すると、関係性が明らかになります：

```leantac
{{#example_in Examples/Induction.lean mirror_count_2}}
```
```output error
{{#example_out Examples/Induction.lean mirror_count_2}}
```
<!--
Both induction hypotheses can be used to rewrite the left-hand side of the goal into something almost like the right-hand side:
-->

帰納法の仮定がどちらもゴールの左辺を右辺の近いものに書き換えるために使うことができます：

```leantac
{{#example_in Examples/Induction.lean mirror_count_3}}
```
```output error
{{#example_out Examples/Induction.lean mirror_count_3}}
```

<!--
The `simp_arith` tactic, a version of `simp` that can use additional arithmetic identities, is enough to prove this goal, yielding:
-->

`simp_arith` タクティクは `simp` に追加で算術的な等式を使用できるようにしたもので、この目標を証明するにあたって十分であり、以下を出力します：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_4}}
```

<!--
In addition to definitions to be unfolded, the simplifier can also be passed names of equality proofs to use as rewrites while it simplifies proof goals.
`BinTree.mirror_count` can also be written:
-->

展開される定義に加えて、単純化器は証明ゴールを単純化する間に書き換えとして使用する等式証明の名前を渡すこともできます。`BinTree.mirror_count` は以下のように書くこともできます：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_5}}
```
<!--
As proofs grow more complicated, listing assumptions by hand can become tedious.
Furthermore, manually writing assumption names can make it more difficult to re-use proof steps for multiple subgoals.
The argument `*` to `simp` or `simp_arith` instructs them to use _all_ assumptions while simplifying or solving the goal.
In other words, the proof could also be written:
-->

証明が複雑になると、手作業で仮定を列挙することは面倒になります。さらに、手作業で仮定の名前を書くと複数のサブゴールの証明ステップでの再利用が難しくなります。`simp` や `simp_arith` に `*` という引数を与えることで、ゴールを単純化したり解いたりする際に、**全ての** 仮定を使用するように指示することができます。つまり、証明は以下のようにも書けます：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_6}}
```
<!--
Because both branches are using the simplifier, the proof can be reduced to:
-->

どちらの分岐も単純化器を使用しているため、証明は以下のように簡約されます：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_7}}
```


<!--
## Exercises
-->

## 演習問題

 <!--
 * Prove `plusR_succ_left` using the `induction ... with` tactic.
 * Rewrite the proof of `plus_succ_left` to use `<;>` in a single line.
 * Prove that appending lists is associative using induction on lists: `theorem List.append_assoc (xs ys zs : List α) : xs ++ (ys ++ zs) = (xs ++ ys) ++ zs`
-->

 * `induction ... with` タクティクを使って `plusR_succ_left` を証明してください。
 * `plus_succ_left` の証明を `<;>` を使って一行になるよう書き換えてください。
 * リストについての帰納法を使って、リストの連結が結合的であることを証明してください：`theorem List.append_assoc (xs ys zs : List α) : xs ++ (ys ++ zs) = (xs ++ ys) ++ zs`