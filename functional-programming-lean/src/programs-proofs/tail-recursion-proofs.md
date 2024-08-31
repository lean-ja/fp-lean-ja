<!--
# Proving Equivalence
-->

# 同値の証明

<!--
Programs that have been rewritten to use tail recursion and an accumulator can look quite different from the original program.
The original recursive function is often much easier to understand, but it runs the risk of exhausting the stack at run time.
After testing both versions of the program on examples to rule out simple bugs, proofs can be used to show once and for all that the programs are equivalent.
-->

あるプログラムを末尾再帰とアキュムレータを使うように書き直すと、元のプログラムとはかなり異なった見た目になることがあります。オリジナルの再帰関数の方が大抵理解しやすいですが、実行時にスタックを使い果たしてしまう危険性があります。両方のバージョンのプログラムをいくつかの例でテストして単純なバグを取り除いた後に、証明を使ってこれらのプログラムが同値であることをはっきりと示すことができます。

<!--
## Proving `sum` Equal
-->

## `sum` の等価の証明

<!--
To prove that both versions of `sum` are equal, begin by writing the theorem statement with a stub proof:
-->

`sum` についてこの両方のバージョンが等しいことを証明するには、まずスタブの証明で定理の文を書き始めます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq0}}
```
<!--
As expected, Lean describes an unsolved goal:
-->

想定されるようにLeanは未解決のゴールを表示します：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq0}}
```

<!--
The `rfl` tactic cannot be applied here, because `NonTail.sum` and `Tail.sum` are not definitionally equal.
Functions can be equal in more ways than just definitional equality, however.
It is also possible to prove that two functions are equal by proving that they produce equal outputs for the same input.
In other words, \\( f = g \\) can be proved by proving that \\( f(x) = g(x) \\) for all possible inputs \\( x \\).
This principle is called _function extensionality_.
Function extensionality is exactly the reason why `NonTail.sum` equals `Tail.sum`: they both sum lists of numbers.
-->

`NonTail.sum` と `Tail.sum` は定義上同値ではないため、ここでは `rfl` タクティクを使うことはできません。しかし、関数が等しいと言えるのは定義上の同値だけではありません。同じ入力に対して同じ出力を生成することを証明することで、2つの関数が等しいことを証明することも可能です。言い換えると、\\( f = g \\) はすべての可能な入力 \\( x \\) に対して \\( f(x) = g(x) \\) を示すことで証明できます。この原理は **関数の外延性** （function extensionality）と呼ばれます。関数の外延性はまさに `NonTail.sum` が `Tail.sum` と等しいことを説明します：どちらも数値のリストを合計を計算するからです。

<!--
In Lean's tactic language, function extensionality is invoked using `funext`, followed by a name to be used for the arbitrary argument.
The arbitrary argument is added as an assumption to the context, and the goal changes to require a proof that the functions applied to this argument are equal:
-->

Leanのタクティク言語では、関数の外延性は `funext` を使うことで呼び出され、その後に任意の引数に使われる名前が続きます。この任意の引数はコンテキスト中に仮定として追加され、ゴールはこの引数に適用される関数が等しいことの証明を要求するものへと変化します：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq1}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq1}}
```

<!--
This goal can be proved by induction on the argument `xs`.
Both `sum` functions return `0` when applied to the empty list, which serves as a base case.
Adding a number to the beginning of the input list causes both functions to add that number to the result, which serves as an induction step.
Invoking the `induction` tactic results in two goals:
-->

このゴールは引数 `xs` の帰納法によって証明できます。どちらの `sum` 関数も、空のリストに適用すると基本ケースに対応する `0` を返します。入力リストの先頭に数値を追加すると、両方の関数でその数値を計算結果に加算します。これは帰納法のステップに対応します。`induction` タクティクを実行すると、2つのゴールが得られます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq2a}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq2a}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq2b}}
```

<!--
The base case for `nil` can be solved using `rfl`, because both functions return `0` when passed the empty list:
-->

`nil` に対応する基本ケースは `rfl` を使って解決できます。というのも、どちらの関数も空のリストを渡すと `0` を返すからです：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq3}}
```

<!--
The first step in solving the induction step is to simplify the goal, asking `simp` to unfold `NonTail.sum` and `Tail.sum`:
-->

帰納法のステップを解く最初のステップはゴールを単純化することで、`simp` によって `NonTail.sum` と `Tail.sum` を展開します：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq4}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq4}}
```
<!--
Unfolding `Tail.sum` revealed that it immediately delegates to `Tail.sumHelper`, which should also be simplified:
-->

`Tail.sum` を展開することで処理が `Tail.sumHelper` に即座に委譲されていることがわかり、これもまた単純化されるべきです：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq5}}
```
<!--
In the resulting goal, `sumHelper` has taken a step of computation and added `y` to the accumulator:
-->

これらによって、ゴールでは `sumHelper` の計算のステップが進み、アキュムレータに `y` が加算されます：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq5}}
```
<!--
Rewriting with the induction hypothesis removes all mentions of `NonTail.sum` from the goal:
-->

帰納法の仮定で書き換えを行うことで、ゴールから `NonTail.sum` のすべての言及が削除されます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq6}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq6}}
```
<!--
This new goal states that adding some number to the sum of a list is the same as using that number as the initial accumulator in `sumHelper`.
For the sake of clarity, this new goal can be proved as a separate theorem:
-->

この新しいゴールは、あるリストの和にある数を加えることは、`sumHelper` の最初のアキュムレータとしてその数を使うことと同じであるということを述べています。わかりやすくするために、この新しいゴールは別の定理として証明することができます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEqHelperBad0}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEqHelperBad0}}
```
<!--
Once again, this is a proof by induction where the base case uses `rfl`:
-->

繰り返しになりますが、これは帰納法による証明であり、基本ケースは `rfl` を使っています：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEqHelperBad1}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEqHelperBad1}}
```
<!--
Because this is an inductive step, the goal should be simplified until it matches the induction hypothesis `ih`.
Simplifying, using the definitions of `Tail.sum` and `Tail.sumHelper`, results in the following:
-->

これは帰納法のステップであるため、ゴールは帰納法の仮定 `ih` と一致するまで単純化する必要があります。`Tail.sum` と `Tail.sumHelper` の定義を使って単純化すると、以下のようになります：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEqHelperBad2}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEqHelperBad2}}
```
<!--
Ideally, the induction hypothesis could be used to replace `Tail.sumHelper (y + n) ys`, but they don't match.
The induction hypothesis can be used for `Tail.sumHelper n ys`, not `Tail.sumHelper (y + n) ys`.
In other words, this proof is stuck.
-->

理想的には、帰納法の仮定を使って `Tail.sumHelper (y + n) ys` を置き換えることができますが、両者は一致しません。この帰納法の仮定は `Tail.sumHelper n ys` には使えますが、`Tail.sumHelper (y + n) ys` には使えません。つまり、この証明は行き詰ってしまいます。

<!--
## A Second Attempt
-->

## 再挑戦

<!--
Rather than attempting to muddle through the proof, it's time to take a step back and think.
Why is it that the tail-recursive version of the function is equal to the non-tail-recursive version?
Fundamentally speaking, at each entry in the list, the accumulator grows by the same amount as would be added to the result of the recursion.
This insight can be used to write an elegant proof.
Crucially, the proof by induction must be set up such that the induction hypothesis can be applied to _any_ accumulator value.
-->

この方針でなんとか頑張る代わりに、ここで一歩引いて考えてみましょう。なぜこの関数の末尾再帰バージョンと非末尾再帰バージョンは等しいのでしょうか？根本的に言えばリストの各要素について、再帰版の結果に加算されるのと同じ量だけアキュムレータが増えます。この洞察によってエレガントな証明を書くことができます。重要なのは、帰納法による証明は帰納法の仮定を **任意の** アキュムレータ値に適用できるように設定しなければならないということです。

<!--
Discarding the prior attempt, the insight can be encoded as the following statement:
-->

先ほどの試みは置いておいて、上記の洞察は次の文にエンコードされます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper0}}
```
<!--
In this statement, it's very important that `n` is part of the type that's after the colon.
The resulting goal begins with `∀ (n : Nat)`, which is short for "For all `n`":
-->

この文において、`n` がコロンの後にある型の一部であることが非常に重要です。この結果、ゴールは「全ての `n` について～」の略である `∀ (n : Nat)` で始まります。

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper0}}
```
<!--
Using the induction tactic results in goals that include this "for all" statement:
-->

帰納法のタクティクを用いると、この「全ての～について～」という文を含んだゴールができます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper1a}}
```
<!--
In the `nil` case, the goal is:
-->

`nil` のケースでは、ゴールは次のようになります：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper1a}}
```
<!--
For the induction step for `cons`, both the induction hypothesis and the specific goal contain the "for all `n`":
-->

`cons` の帰納法のステップでは、帰納法の仮定と具体的なゴールの両方に「全ての `n` について～」が含まれます：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper1b}}
```
<!--
In other words, the goal has become more challenging to prove, but the induction hypothesis is correspondingly more useful.
-->

言い換えると、ゴールの証明はより難しくなりましたが、これに応じて帰納法の仮定はより有用なものになったということです。

<!--
A mathematical proof for a statement that beings with "for all \\( x \\)" should assume some arbitrary \\( x \\), and prove the statement.
"Arbitrary" means that no additional properties of \\( x \\) are assumed, so the resulting statement will work for _any_ \\( x \\).
In Lean, a "for all" statement is a dependent function: no matter which specific value it is applied to, it will return evidence of the proposition.
Similarly, the process of picking an arbitrary \\( x \\) is the same as using ``fun x => ...``.
In the tactic language, this process of selecting an arbitrary \\( x \\) is performed using the `intro` tactic, which produces the function behind the scenes when the tactic script has completed.
The `intro` tactic should be provided with the name to be used for this arbitrary value.
-->

「全ての \\( x \\) について～」で始まる文の数学的な証明はある任意の \\( x \\) を仮定してその文を証明します。ここで「任意」という言葉は \\( x \\) について追加の性質を何も仮定しないことを意味し、これによって文は **どんな** \\( x \\) について成立します。Leanでは、「全ての～について～」文は依存型の関数です：これに適用されるどんな値に対しても、この命題の根拠を返します。同様に、任意の \\( x \\) を選ぶプロセスは ``fun x => ...`` を使うことと同じです。タクティク言語においては、任意の \\( x \\) を選ぶこの処理は `intro` タクティクを使って実行されます。これは裏ではタクティクのスクリプトが完成したタイミングで関数を生成します。`intro` タクティクにはこの任意の値に使用する名前を指定します。

<!--
Using the `intro` tactic in the `nil` case removes the `∀ (n : Nat),` from the goal, and adds an assumption `n : Nat`:
-->

`nil` のケースで `intro` タクティクを使うことでゴールから `∀ (n : Nat),` が取り除かれ、仮定 `n : Nat` が追加されます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper2}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper2}}
```
<!--
Both sides of this propositional equality are definitionally equal to `n`, so `rfl` suffices:
-->

この命題の同値の両辺は、定義上 `n` に同値であるため、`rfl` で十分です：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper3}}
```
<!--
The `cons` goal also contains a "for all":
-->

`cons` のゴールにも「全ての～について～」が含まれます：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper3}}
```
<!--
This suggests the use of `intro`.
-->

このことから `intro` を使う必要があります。

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper4}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper4}}
```
<!--
The proof goal now contains both `NonTail.sum` and `Tail.sumHelper` applied to `y :: ys`.
The simplifier can make the next step more clear:
-->

これでこの証明のゴールは `NonTail.sum` と `Tail.sumHelper` の両方を `y :: ys` に適用したものとなります。単純化することで次のステップをより明確にすることができます。

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper5}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper5}}
```
<!--
This goal is very close to matching the induction hypothesis.
There are two ways in which it does not match:
-->

このゴールは帰納法の仮定に非常に近いです。一致しない点は2つです：

 <!--
 * The left-hand side of the equation is `n + (y + NonTail.sum ys)`, but the induction hypothesis needs the left-hand side to be a number added to `NonTail.sum ys`.
   In other words, this goal should be rewritten to `(n + y) + NonTail.sum ys`, which is valid because addition of natural numbers is associative.
 * When the left side has been rewritten to `(y + n) + NonTail.sum ys`, the accumulator argument on the right side should be `n + y` rather than `y + n` in order to match.
   This rewrite is valid because addition is also commutative.
-->

 * この等式の左辺は `n + (y + NonTail.sum ys)` ですが、帰納法の仮定では左辺は `NonTail.sum ys` に何かしらの数値を足した数であることが求められています。言い換えれば、このゴールは `(n + y) + NonTail.sum ys` と書き直されるべきで、これは自然数の足し算が結合的であることから成り立ちます。
 * 左辺を `(y + n) + NonTail.sum ys` と書き換えた場合、右辺のアキュムレータの引数は `y + n` ではなく `n + y` とする必要があります。足し算は可換でもあるため、この書き換えも成り立ちます。

<!--
The associativity and commutativity of addition have already been proved in Lean's standard library.
The proof of associativity is named `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddAssoc}}`, and its type is `{{#example_out Examples/ProgramsProofs/TCO.lean NatAddAssoc}}`, while the proof of commutativity is called `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddComm}}` and has type `{{#example_out Examples/ProgramsProofs/TCO.lean NatAddComm}}`.
Normally, the `rw` tactic is provided with an expression whose type is an equality.
However, if the argument is instead a dependent function whose return type is an equality, it attempts to find arguments to the function that would allow the equality to match something in the goal.
There is only one opportunity to apply associativity, though the direction of the rewrite must be reversed because the right side of the equality in `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddAssoc}}` is the one that matches the proof goal:
-->

足し算の結合性と可換性はLeanの標準ライブラリですでに証明されています。結合性の証明は `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddAssoc}}` という名前で `{{#example_out Examples/ProgramsProofs/TCO.lean NatAddAssoc}}` という型を持ち、可換性の証明は `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddComm}}` という名前で `{{#example_out Examples/ProgramsProofs/TCO.lean NatAddComm}}` という型を持ちます。通常、`rw` タクティクには型が同値である式を指定します。しかし、引数が等式を返す依存型の関数である場合、等式がゴールの何かとマッチするようにその関数の引数を見つけようとします。ここでは結合性が適用できる可能性のある個所はただ1つですが、等式 `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddAssoc}}` の右辺が証明のゴールにマッチするため、書き換えの方向は逆にしなければなりません：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper6}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper6}}
```
<!--
Rewriting directly with `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddComm}}`, however, leads to the wrong result.
The `rw` tactic guesses the wrong location for the rewrite, leading to an unintended goal:
-->

しかし、`{{#example_in Examples/ProgramsProofs/TCO.lean NatAddComm}}` で直接書き換えすると間違った結果になります。ここでの `rw` タクティクは間違った書き換え場所を推測しており、意図しないゴールに導きます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper7}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper7}}
```
<!--
This can be fixed by explicitly providing `y` and `n` as arguments to `Nat.add_comm`:
-->

これは `Nat.add_comm` の引数として `y` と `n` を明示的に提示することで解決します：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper8}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper8}}
```
<!--
The goal now matches the induction hypothesis.
In particular, the induction hypothesis's type is a dependent function type.
Applying `ih` to `n + y` results in exactly the desired type.
The `exact` tactic completes a proof goal if its argument has exactly the desired type:
-->

これでゴールは帰納法の仮定にマッチするようになりました。特に、帰納法の仮定の型は依存型の関数型です。`ih` を `n + y` に適用すると、期待していた型そのものになります。`exact` タクティクはその引数が正確に望みの型である場合、証明のゴールを完成させます：

```leantac
{{#example_decl Examples/ProgramsProofs/TCO.lean nonTailEqHelperDone}}
```

<!--
The actual proof requires only a little additional work to get the goal to match the helper's type.
The first step is still to invoke function extensionality:
-->

実際の証明では、ゴールをこのような補助的な定義の型と一致させるためにはさらにほんの少しだけ追加作業が必要になります。最初のステップは、ここでも関数の外延性を呼び出すことです：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqReal0}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqReal0}}
```
<!--
The next step is unfold `Tail.sum`, exposing `Tail.sumHelper`:
-->

次のステップは `Tail.sum` を展開し、`Tail.sumHelper` を公開することです：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqReal1}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqReal1}}
```
<!--
Having done this, the types almost match.
However, the helper has an additional addend on the left side.
In other words, the proof goal is `NonTail.sum xs = Tail.sumHelper 0 xs`, but applying `non_tail_sum_eq_helper_accum` to `xs` and `0` yields the type `0 + NonTail.sum xs = Tail.sumHelper 0 xs`.
Another standard library proof, `{{#example_in Examples/ProgramsProofs/TCO.lean NatZeroAdd}}`, has type `{{#example_out Examples/ProgramsProofs/TCO.lean NatZeroAdd}}`.
Applying this function to `NonTail.sum xs` results in an expression with type `{{#example_out Examples/ProgramsProofs/TCO.lean NatZeroAddApplied}}`, so rewriting from right to left results in the desired goal:
-->


こうすることで、型はほとんど一致します。しかし、補助定義では左辺に追加で加算を行っています。言い換えると、証明のゴールは `NonTail.sum xs = Tail.sumHelper 0 xs` ですが、`non_tail_sum_eq_helper_accum` を `xs` と `0` に適用すると `0 + NonTail.sum xs = Tail.sumHelper 0 xs` という型が得られます。ここで標準ライブラリには `{{#example_out Examples/ProgramsProofs/TCO.lean NatZeroAdd}}` という型を持つ `{{#example_in Examples/ProgramsProofs/TCO.lean NatZeroAdd}}` という証明があります。この関数を `NonTail.sum xs` に適用すると式は `{{#example_out Examples/ProgramsProofs/TCO.lean NatZeroAddApplied}}` という型になり、これで右辺から左辺への書き換えによって望みの型が得られます：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqReal2}}
```
```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqReal2}}
```
<!--
Finally, the helper can be used to complete the proof:
-->

最終的に、この補助定義によって証明が完成します：

```leantac
{{#example_decl Examples/ProgramsProofs/TCO.lean nonTailEqRealDone}}
```

<!--
This proof demonstrates a general pattern that can be used when proving that an accumulator-passing tail-recursive function is equal to the non-tail-recursive version.
The first step is to discover the relationship between the starting accumulator argument and the final result.
For instance, beginning `Tail.sumHelper` with an accumulator of `n` results in the final sum being added to `n`, and beginning `Tail.reverseHelper` with an accumulator of `ys` results in the final reversed list being prepended to `ys`.
The second step is to write down this relationship as a theorem statement and prove it by induction.
While the accumulator is always initialized with some neutral value in practice, such as `0` or `[]`, this more general statement that allows the starting accumulator to be any value is what's needed to get a strong enough induction hypothesis.
Finally, using this helper theorem with the actual initial accumulator value results in the desired proof.
For example, in `non_tail_sum_eq_tail_sum`, the accumulator is specified to be `0`.
This may require rewriting the goal to make the neutral initial accumulator values occur in the right place.

-->

この証明はアキュムレータを渡す版の末尾再帰関数が非末尾再帰版と等しいことを証明する時に使用できる一般的なパターンを示しています。最初のステップでは、開始時のアキュムレータの引数と最終結果の関係を発見することです。例えば、`Tail.sumHelper` を `n` のアキュムレータで開始すると、最終的な合計に `n` が加算され、`Tail.reverseHelper` を `ys` のアキュムレータで開始すると、最終的な反転されたリストが `ys` の前に追加されます。2つ目のステップは、この関係を定理として書き出し、帰納法によって証明することです。実際にはアキュムレータは常に `0` や `[]` などの中立な値で初期化されますが、開始時のアキュムレータを任意の値にすることができるこの一般的な文は、十分に強力な帰納法の仮定を得るために必要なものです。最後に、この補助定理を実際のアキュムレータの初期値で使用すると望ましい証明が得られます。例えば、`non_tail_sum_eq_tail_sum` ではアキュムレータは `0` が指定されます。この場合、中立的なアキュムレータの初期値が適切な場所で発生するようにゴールを書き換える必要があるかもしれません。

<!--
## Exercise
-->

## 演習問題

<!--
### Warming Up
-->

### 準備運動

<!--
Write your own proofs for `Nat.zero_add`, `Nat.add_assoc`, and `Nat.add_comm` using the `induction` tactic.
-->

`Nat.zero_add` ・`Nat.add_assoc` ・`Nat.add_comm` の証明を `induction` タクティクを使って自分で書いてみましょう。

<!--
 
### More Accumulator Proofs
-->

### アキュムレータについて他の証明

<!--
#### Reversing Lists
-->

#### リストの反転

<!--
Adapt the proof for `sum` into a proof for `NonTail.reverse` and `Tail.reverse`.
The first step is to think about the relationship between the accumulator value being passed to `Tail.reverseHelper` and the non-tail-recursive reverse.
Just as adding a number to the accumulator in `Tail.sumHelper` is the same as adding it to the overall sum, using `List.cons` to add a new entry to the accumulator in `Tail.reverseHelper` is equivalent to some change to the overall result.
Try three or four different accumulator values with pencil and paper until the relationship becomes clear.
Use this relationship to prove a suitable helper theorem.
Then, write down the overall theorem.
Because `NonTail.reverse` and `Tail.reverse` are polymorphic, stating their equality requires the use of `@` to stop Lean from trying to figure out which type to use for `α`.
Once `α` is treated as an ordinary argument, `funext` should be invoked with both `α` and `xs`:
-->

`sum` についての証明を `NonTail.reverse` と `Tail.reverse` の証明に適用してください。最初のステップは `Tail.reverseHelper` に渡されるアキュムレータの値と非末尾再帰的な反転の間の関係を考えることです。ちょうど `Tail.sumHelper` でアキュムレータに数値を追加することが全体の合計に追加することと同じように、`Tail.reverseHelper` でアキュムレータに新しい要素を追加するために `List.cons` を使用することは全体の結果に何らかの変更を加えることと同じです。関係性がはっきりするまで、紙と鉛筆を使って3，4例の異なるアキュムレータの値を試してください。この関係を使って適切な補助定理を証明してください。それから全体の証明を書き下してください。`NonTail.reverse` と `Tail.reverse` は多相であるため、両者が等価であることを示すにはLeanが `α` にどのような型を使うべきかを考えさせないために `@` を使う必要があります。いったん `α` が通常の引数として扱われると、`funext` は `α` と `xs` の両方で呼び出されるようになります：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean reverseEqStart}}
```
<!--
This results in a suitable goal:
-->

これによって適切なゴールが生まれます：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean reverseEqStart}}
```


<!--
#### Factorial
-->

#### 階乗

<!--
Prove that `NonTail.factorial` from the exercises in the previous section is equal to your tail-recursive solution by finding the relationship between the accumulator and the result and proving a suitable helper theorem.
-->

アキュムレータと結果の関係を見つけ、適切な補助定理を証明することによって、前の節の練習問題で出てきた `NonTail.factorial` が読者の末尾再帰版の解答と等しいことを証明してください。
