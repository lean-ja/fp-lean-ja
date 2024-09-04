<!--
# More Inequalities
-->

# その他の不等式

<!--
Lean's built-in proof automation is sufficient to check that `arrayMapHelper` and `findHelper` terminate.
All that was needed was to provide an expression whose value decreases with each recursive call.
However, Lean's built-in automation is not magic, and it often needs some help.
-->

`arrayMapHelper` と `findHelper` が停止することをチェックするにはLeanの組み込みの証明自動化だけで十分です。必要なものは再帰的に呼び出すたびに値が減少する式を提供することだけです。しかし、Leanの組み込みの自動化は魔法ではないため、しばしば手助けが必要になります。

<!--
## Merge Sort
-->

## マージソート

<!--
One example of a function whose termination proof is non-trivial is merge sort on `List`.
Merge sort consists of two phases: first, a list is split in half.
Each half is sorted using merge sort, and then the results are merged using a function that combines two sorted lists into a larger sorted list.
The base cases are the empty list and the singleton list, both of which are already considered to be sorted.
-->

停止証明が自明でない関数の一例として、`List` のマージソートがあります。マージソートは2つのフェーズから構成されます。まずリストが半分に分割されます。半分になったそれぞれがマージソートでソートされ、その結果を結合してより大きなソート済みリストにする関数を使ってマージされます。基本ケースは空リストと要素が1つのリストで、どちらもすでにソート済みであると見なされます。

<!--
To merge two sorted lists, there are two basic cases to consider:
-->

2つのソート済みのリストをマージするには2つの基本ケースを考慮する必要があります：

 <!--
 1. If one of the input lists is empty, then the result is the other list.
 2. If both lists are non-empty, then their heads should be compared. The result of the function is the smaller of the two heads, followed by the result of merging the remaining entries of both lists.
-->

 1. どちらかのリストが空であれば、結果はもう片方のリストになります。
 2. どちらのリストも空でない場合、それらの先頭を比較します。この関数の結果は2つのリストのどちらか小さい方の先頭に両方のリストの残りの要素をマージした結果が続きます。

<!--
This is not structurally recursive on either list.
The recursion terminates because an entry is removed from one of the two lists in each recursive call, but it could be either list.
The `termination_by` clause uses the sum of the length of both lists as a decreasing value:
-->

これはどちらのリストに対しても構造的に再帰的ではありません。再帰呼び出しのたびに2つのリストのどちらかから1つの要素が削除されるため再帰は終了します。`termination_by` 節は両方のリストの長さの合計を減少する値として使用します：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean merge}}
```

<!--
In addition to using the lengths of the lists, a pair that contains both lists can also be provided:
-->

リストの長さを使うだけでなく、両方のリストを含むペアを提供することもできます：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean mergePairTerm}}
```
<!--
This works because Lean has a built-in notion of sizes of data, expressed through a type class called `WellFoundedRelation`.
The instance for pairs automatically considers them to be smaller if either the first or the second item in the pair shrinks.
-->

これはLeanが `WellFoundedRelation` という型クラスで表現されるデータのサイズに関する概念を組み込んでいるため機能します。この型クラスのペアへのインスタンスでは、ペアの1つ目か2つ目のアイテムのどちらかが縮小すると、自動的に小さくなったと見なされます。

<!--
A simple way to split a list is to add each entry in the input list to two alternating output lists:
-->

リストを分割する簡単な方法は、入力リストの各要素を2つの出力リストに楮に追加することです：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList}}
```

<!--
Merge sort checks whether a base case has been reached.
If so, it returns the input list.
If not, it splits the input, and merges the result of sorting each half:
-->

マージソートでは基本ケースに到達したかどうかをチェックします。もしそうであれば入力リストを返します。そうでない場合は、入力を分割し、それぞれの半分をソートした結果をマージします：

```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortNoTerm}}
```
<!--
Lean's pattern match compiler is able to tell that the assumption `h` introduced by the `if` that tests whether `xs.length < 2` rules out lists longer than one entry, so there is no "missing cases" error.
However, even though this program always terminates, it is not structurally recursive:
-->

Leanのパターンマッチのコンパイラは `xs.length < 2` かどうかをテストする `if` によって導入された仮定 `h` が、1つ以上の要素を除外していることを見分けることができます。そのため「場合分けの考慮もれ」エラーは発生しません。しかし、このプログラムは常に終了するにも関わらず、構造的には再帰的ではありません：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortNoTerm}}
```
<!--
The reason it terminates is that `splitList` always returns lists that are shorter than its input.
Thus, the length of `halves.fst` and `halves.snd` are less than the length of `xs`.
This can be expressed using a `termination_by` clause:
-->

これが停止する理由は `splitList` が常に入力よりも短いリストを返すからです。したがって、`halves.fst` と `halves.snd` の長さは `xs` の長さ未満となります。これは `termination_by` 節を使って表現することができます：

```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortGottaProveIt}}
```
<!--
With this clause, the error message changes.
Instead of complaining that the function isn't structurally recursive, Lean instead points out that it was unable to automatically prove that `(splitList xs).fst.length < xs.length`:
-->

この節によってエラーメッセージが変化します。Leanは関数が構造的に再帰的でないと文句を言う代わりに、`(splitList xs).fst.length < xs.length` を自動的に証明できなかった旨を指摘します：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortGottaProveIt}}
```

<!--
## Splitting a List Makes it Shorter
-->

## 分割によってリストが短くなること

<!--
It will also be necessary to prove that `(splitList xs).snd.length < xs.length`.
Because `splitList` alternates between adding entries to the two lists, it is easiest to prove both statements at once, so the structure of the proof can follow the algorithm used to implement `splitList`.
In other words, it is easiest to prove that `∀(lst : List), (splitList lst).fst.length < lst.length ∧ (splitList lst).snd.length < lst.length`.
-->

`(splitList xs).snd.length < xs.length` もまた証明する必要があります。`splitList` は2つのリストに交互に要素を追加するため、一度に両方の文を証明することが最も簡単であり、そのため証明の構造は `splitList` 実装に用いられたアルゴリズムに従います。つまり `∀(lst : List), (splitList lst).fst.length < lst.length ∧ (splitList lst).snd.length < lst.length` を証明することが最も簡単です。

<!--
Unfortunately, the statement is false.
In particular, `{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListEmpty}}` is `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListEmpty}}`. Both output lists have length `0`, which is not less than `0`, the length of the input list.
Similarly, `{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListOne}}` evaluates to `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListOne}}`, and `["basalt"]` is not shorter than `["basalt"]`.
However, `{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListTwo}}` evaluates to `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListTwo}}`, and both of these output lists are shorter than the input list.
-->

しかし残念なことに、この文は偽です。特に、`{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListEmpty}}` は `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListEmpty}}` となります。出力のリストはどちらも長さが `0` で、入力のリストの長さである `0` 未満ではありません。同様に、`{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListOne}}` は `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListOne}}` に評価され、`["basalt"]` の長さは `["basalt"]` 未満ではありません。しかし、`{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListTwo}}` は `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListTwo}}` に評価され、出力のリストは入力リストよりも短くなります。

<!--
It turns out that the lengths of the output lists are always less than or equal to the length of the input list, but they are only strictly shorter when the input list contains at least two entries.
It turns out to be easiest to prove the former statement, then extend it to the latter statement.
Begin with a theorem statement:
-->

したがって出力されるリストの長さは必ず入力リストの長さ以下である一方で、入力リストが2つ以上要素を持つときだけ出力リストの長さが入力リストより短くなることがわかります。前者を証明し、後者に拡張することが簡単です。まず次の定理から始めます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le0}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le0}}
```
<!--
Because `splitList` is structurally recursive on the list, the proof should use induction.
The structural recursion in `splitList` fits a proof by induction perfectly: the base case of the induction matches the base case of the recursion, and the inductive step matches the recursive call.
The `induction` tactic gives two goals:
-->

`splitList` はリスト上において構造的に再帰的であるため、証明は帰納法を使うべきです。`splitList` についての構造的な再帰は帰納法による証明に完璧に合致します：帰納法の基本ケースは再帰の基本ケースに、帰納法のステップは再帰呼び出しに一致します。`induction` タクティクは2つのゴールを与えます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le1a}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le1a}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le1b}}
```

<!--
The goal for the `nil` case can be proved by invoking the simplifier and instructing it to unfold the definition of `splitList`, because the length of the empty list is less than or equal to the length of the empty list.
Similarly, simplifying with `splitList` in the `cons` case places `Nat.succ` around the lengths in the goal:
-->

空リストの長さは空リストの長さ以下であるため、`nil` のケースについてのゴールは単純化器を起動して `splitList` の定義を展開するよう指示することで証明できます。同様に、`cons` の場合に `splitList` を用いて単純化するとゴールの長さを `Nat.succ` が包みます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le2}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le2}}
```
<!--
This is because the call to `List.length` consumes the head of the list `x :: xs`, converting it to a `Nat.succ`, in both the length of the input list and the length of the first output list.
-->

これは `List.length` の呼び出しがリストの先頭 `x :: xs` を消費し、入力リストの長さと最初の出力リストの長さの両方で `Nat.succ` に変換するからです。

<!--
Writing `A ∧ B` in Lean is short for `And A B`.
`And` is a structure type in the `Prop` universe:
-->

Leanにおいて `A ∧ B` は `And A B` の略記です。`And` は `Prop` 宇宙での構造体型です。

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean And}}
```
<!--
In other words, a proof of `A ∧ B` consists of the `And.intro` constructor applied to a proof of `A` in the `left` field and a proof of `B` in the `right` field.
-->

言いかえれば、`A ∧ B` の証明は `And.intro` コンストラクタを `left` フィールドの `A` の証明と `right` フィールドの `B` の証明に適用したものです。

<!--
The `cases` tactic allows a proof to consider each constructor of a datatype or each potential proof of a proposition in turn.
It corresponds to a `match` expression without recursion.
Using `cases` on a structure results in the structure being broken apart, with an assumption added for each field of the structure, just as a pattern match expression extracts the field of a structure for use in a program.
Because structures have only one constructor, using `cases` on a structure does not result in additional goals.
-->

`cases` タクティクを使うと、証明をデータ型の各コンストラクタや命題の各証明に対して順番に考慮することができます。これは再帰のない `match` 式に相当します。構造体に対して `cases` を使用すると、プログラムで使用するためにパターンマッチ式が構造体のフィールドを展開するのと同じように、構造体が分解され構造体の各フィールドに対して仮定が追加されます。構造体にはコンストラクタが1つしかないため、構造体に対して `cases` を使用してもゴールが追加されることはありません。

<!--
Because `ih` is a proof of `List.length (splitList xs).fst ≤ List.length xs ∧ List.length (splitList xs).snd ≤ List.length xs`, using `cases ih` results in an assumption that `List.length (splitList xs).fst ≤ List.length xs` and an assumption that `List.length (splitList xs).snd ≤ List.length xs`:
-->

`ih` は `List.length (splitList xs).fst ≤ List.length xs ∧ List.length (splitList xs).snd ≤ List.length xs` の証明であるため、`cases ih` を使うと仮定 `List.length (splitList xs).fst ≤ List.length xs` と仮定 `List.length (splitList xs).snd ≤ List.length xs` が得られます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le3}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le3}}
```

<!--
Because the goal of the proof is also an `And`, the `constructor` tactic can be used to apply `And.intro`, resulting in a goal for each argument:
-->

証明のゴールも `And` であるため、`constructor` タクティクを使って `And.intro` を適用し、各引数のゴールを得ることができます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le4}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le4}}
```

<!--
The `left` goal is very similar to the `left✝` assumption, except the goal wraps both sides of the inequality in `Nat.succ`.
Likewise, the `right` goal resembles the `right✝` assumption, except the goal adds a `Nat.succ` only to the length of the input list.
It's time to prove that these wrappings of `Nat.succ` preserve the truth of the statement.
-->

`left` のゴールは `left` の仮定にとてもよく似ていますが、ゴールでは不等式の両辺を `Nat.succ` が包んでいます。同様に、`right` のゴールは `right` に似ていますが、`Nat.succ` が入力リストの長さにのみ追加されています。これらの `Nat.succ` のラッピングが文の正しさを保持することを証明する時がきました。

<!--
### Adding One to Both Sides
-->

### 両辺に1を足す

<!--
For the `left` goal, the statement to prove is `Nat.succ_le_succ : n ≤ m → Nat.succ n ≤ Nat.succ m`.
In other words, if `n ≤ m`, then adding one to both sides doesn't change this fact.
Why is this true?
The proof that `n ≤ m` is a `Nat.le.refl` constructor with `m - n` instances of the `Nat.le.step` constructor wrapped around it.
Adding one to both sides simply means that the `refl` applies to a number that's one larger than before, with the same number of `step` constructors.
-->

`left` ゴールの場合、証明すべき文は `Nat.succ_le_succ : n ≤ m → Nat.succ n ≤ Nat.succ m` です。言い換えると、もし `n ≤ m` ならば両辺に1を足してもこの事実は変わらないということです。なぜそうなるのでしょうか？`n ≤ m` ということの証明は `Nat.le.refl` コンストラクタに `Nat.le.step` コンストラクタを `m - n` 個のインスタンスでくるんだものです。両辺に1を足すことは単純に `refl` が以前より1だけ大きい数に適用され、同じ数の `step` コンストラクタを持つことを意味します。

<!--
More formally, the proof is by induction on the evidence that `n ≤ m`.
If the evidence is `refl`, then `n = m`, so `Nat.succ n = Nat.succ m` and `refl` can be used again.
If the evidence is `step`, then the induction hypothesis provides evidence that `Nat.succ n ≤ Nat.succ m`, and the goal is to show that `Nat.succ n ≤ Nat.succ (Nat.succ m)`.
This can be done by using `step` together with the induction hypothesis.
-->

より形式的には、この証明は `n ≤ m` という根拠に対する帰納法で示されます。もし根拠が `refl` ならば、`n = m` であるため `Nat.succ n = Nat.succ m` となり、再び `refl` を使うことができます。もし根拠が `step` ならば、帰納法の仮定からは `Nat.succ n ≤ Nat.succ m` という根拠が提供され、ゴールは `Nat.succ n ≤ Nat.succ (Nat.succ m)` を示すことになります。これは `step` と帰納法の仮定を併用することで可能です。

<!--
In Lean, the theorem statement is:
-->

Leanにおいて、この定理は以下のように表現されます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ0}}
```
<!--
and the error message recapitulates it:
-->

そしてエラーメッセージがこの内容を要約しています：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ0}}
```

<!--
The first step is to use the `intro` tactic, bringing the hypothesis that `n ≤ m` into scope and giving it a name:
-->

最初のステップは `intro` タクティクを使うことで、これにより `n ≤ m` という仮定をスコープ内に導入し、名前を付けます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ1}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ1}}
```

<!--
Because the proof is by induction on the evidence that `n ≤ m`, the next tactic is `induction h`:
-->

この証明は `n ≤ m` についての根拠に対しての帰納法であるため、次に使うタクティクは `induction h` です：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ3}}
```
<!--
This results in two goals, once for each constructor of `Nat.le`:
-->

これによりゴールが `Nat.le` の各コンストラクタそれぞれに1つずつ、合計2つ作られます：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ3}}
```
<!--
The goal for `refl` can itself be solved using `refl`, which the `constructor` tactic selects.
The goal for `step` will also require a use of the `step` constructor:
-->

`refl` についてのゴールは `refl` を使って解くことができ、これは `constructor` タクティクによっても選ばれます。`step` についてのゴールも `step` コンストラクタを使用する必要があります：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ4}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ4}}
```
<!--
The goal is no longer shown using the `≤` operator, but it is equivalent to the induction hypothesis `ih`.
The `assumption` tactic automatically selects an assumption that fulfills the goal, and the proof is complete:
-->

このゴールはもはや `≤` 演算子を用いた表示でありませんが、これは帰納法の仮定 `ih` と等価です。`assumption` タクティクはゴールを埋める仮定を自動で選択し、これで証明が完了します：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean succ_le_succ5}}
```

<!--
Written as a recursive function, the proof is:
-->

この証明を再帰関数として書くと以下のようになります：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean succ_le_succ_recursive}}
```
<!--
It can be instructional to compare the tactic-based proof by induction with this recursive function.
Which proof steps correspond to which parts of the definition?
-->

帰納法によるタクティクベースの証明とこの再帰関数を比較することは学びになるでしょう。どの証明ステップがこの定義のどの部分に対応するでしょうか？

<!--
### Adding One to the Greater Side
-->

### 大きい辺に1を足す

<!--
The second inequality needed to prove `splitList_shorter_le` is `∀(n m : Nat), n ≤ m → n ≤ Nat.succ m`.
This proof is almost identical to `Nat.succ_le_succ`.
Once again, the incoming assumption that `n ≤ m` essentially tracks the difference between `n` and `m` in the number of `Nat.le.step` constructors.
Thus, the proof should add an extra `Nat.le.step` in the base case.
The proof can be written:
-->

`splitList_shorter_le` の証明に必要な2つめの不等式は `∀(n m : Nat), n ≤ m → n ≤ Nat.succ m` です。この証明はほとんど `Nat.succ_le_succ` と同じです。繰り返しになりますが、`n ≤ m` という仮定が導入されることで `Nat.le.step` コンストラクタの数によって `n` と `m` の差を本質的に追跡することができます。したがって、この証明は基本ケースに `Nat.le.step` を足す必要があります。この証明は次のように書かれます：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le}}
```

<!--
To reveal what's going on behind the scenes, the `apply` and `exact` tactics can be used to indicate exactly which constructor is being applied.
The `apply` tactic solves the current goal by applying a function or constructor whose return type matches, creating new goals for each argument that was not provided, while `exact` fails if any new goals would be needed:
-->

裏で何が起こっているかを明らかにするために、`apply` と `exact` タクティクを使用してどちらのコンストラクタが適用されているかを正確に示すことができます。`apply` タクティクは戻り値の型が現在のゴールに一致するような関数やコンストラクタを適用することで現在のゴールを解きます。もし関数などに引数を与えなかった場合は `exact` では失敗してしまいますが、`apply` では新たなゴールが作られます。：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le_apply}}
```

<!--
The proof can be golfed:
-->

この証明をゴルフすることができます：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le_golf}}
```
<!--
In this short tactic script, both goals introduced by `induction` are addressed using `repeat (first | constructor | assumption)`.
The tactic `first | T1 | T2 | ... | Tn` means to use try `T1` through `Tn` in order, using the first tactic that succeeds.
In other words, `repeat (first | constructor | assumption)` applies constructors as long as it can, and then attempts to solve the goal using an assumption.
-->

この短いタクティクのスクリプトでは、`induction` によって導入された両方のゴールに `repeat (first | constructor | assumption)` を使って対処しています。タクティク `first | T1 | T2 | ... | Tn` は `T1` から `Tn` まで順番に試してみて、最初に成功したタクティクを使うことを意味します。つまり、`repeat (first | constructor | assumption)` はできる限りコンストラクタを適用し、その後仮定を使ってゴールを解こうとします。

<!--
Finally, the proof can be written as a recursive function:
-->

最後に、この証明は再帰関数を使っても書くことができます：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le_recursive}}
```

<!--
Each style of proof can be appropriate to different circumstances.
The detailed proof script is useful in cases where beginners may be reading the code, or where the steps of the proof provide some kind of insight.
The short, highly-automated proof script is typically easier to maintain, because automation is frequently both flexible and robust in the face of small changes to definitions and datatypes.
The recursive function is typically both harder to understand from the perspective of mathematical proofs and harder to maintain, but it can be a useful bridge for programmers who are beginning to work with interactive theorem proving.
-->

証明についての各スタイルは適材適所です。詳細な証明のスクリプトは初心者がコードを読む場合や、証明のステップから何らかの洞察が得られるような場合に有用です。短く、高度に自動化された証明スクリプトは一般的に保守が容易です。なぜなら、自動化は定義やデータ型の小さな変更を柔軟に吸収し、かつロバストであることが多いからです。再帰関数は一般的に数学的証明の観点からは理解しにくく、保守もしづらいですが、対話型定理証明に取り組み始めたばかりのプログラマにとっては有用な橋渡しになります。

<!--
### Finishing the Proof
-->

### 証明を完成させる

<!--
Now that both helper theorems have been proved, the rest of `splitList_shorter_le` will be completed quickly.
The current proof state has two goals, for the left and right sides of the `And`:
-->

これで補助定理が両方とも証明されたため、`splitList_shorter_le` の残りの部分はすぐに完了します。現在の証明状態には、`And` の左辺と右辺の2つのゴールがあります：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le4}}
```

<!--
The goals are named for the fields of the `And` structure. This means that the `case` tactic (not to be confused with `cases`) can be used to focus on each of them in turn:
-->

これらのゴールは `And` 構造体のフィールド名が付けられています。つまり `case` タクティク（`cases` と混同しないように）を使ってそれぞれ順番に焦点を当てることができます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le5a}}
```
<!--
Instead of a single error that lists both unsolved goals, there are now two messages, one on each `skip`.
For the `left` goal, `Nat.succ_le_succ` can be used:
-->

両方の未解決ゴールを並べた1つのエラーから、それぞれ `skip` による2つのメッセージが表示されるようになります。`left` のゴールでは `Nat.succ_le_succ` を使うことができます：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le5a}}
```
<!--
In the right goal, `Nat.le_suc_of_le` fits:
-->

右のゴールでは `Nat.le_suc_of_le` が合致します：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le5b}}
```
<!--
Both theorems include the precondition that `n ≤ m`.
These can be found as the `left✝` and `right✝` assumptions, which means that the `assumption` tactic takes care of the final goals:
-->

どちらの定理も前提条件に `n ≤ m` を含みます。これは `left✝` と `right✝` という仮定として見つけることができ、`assumption` タクティクによって最終的なゴールが対処されることを意味します：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le}}
```

<!--
The next step is to return to the actual theorem that is needed to prove that merge sort terminates: that so long as a list has at least two entries, both results of splitting it are strictly shorter.
-->

次のステップはマージソートが終了することを証明するために必要な実際の定理に戻ることです：すなわち、リストが少なくとも2つの要素を持つ限り、それを分割した結果の長さは両方とももとのリスト未満という定理です。

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_start}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_start}}
```
<!--
Pattern matching works just as well in tactic scripts as it does in programs.
Because `lst` has at least two entries, they can be exposed with `match`, which also refines the type through dependent pattern matching:
-->

パターンマッチは通常のプログラムと同様にタクティクスクリプトでもうまく機能します。`lst` には少なくとも2つの要素があるため、`match` をつかって展開することができます。同時に依存パターンマッチによって型も絞り込まれます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_1}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_1}}
```
<!--
Simplifying using `splitList` removes `x` and `y`, resulting in the computed lengths of lists each gaining a `Nat.succ`:
-->

`splitList` を使って単純化すると、`x` と `y` が取り除かれ、それぞれ `Nat.succ` が増えたリストの長さが計算されます：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2}}
```
<!--
Replacing `simp` with `simp_arith` removes these `Nat.succ` constructors, because `simp_arith` makes use of the fact that `n + 1 < m + 1` implies `n < m`:
-->

`simp` を `simp_arith` に置き換えると、これらの `Nat.succ` コンストラクタは削除されます。なぜなら、`simp_arith` は `n + 1 < m + 1` が `n < m` を意味することを利用するからです：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2b}}
```
```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2b}}
```
<!--
This goal now matches `splitList_shorter_le`, which can be used to conclude the proof:
-->

これでこのゴールは `splitList_shorter_le` にマッチし、証明が完結します：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList_shorter}}
```

<!--
The facts needed to prove that `mergeSort` terminates can be pulled out of the resulting `And`:
-->

`mergeSort` が停止することを証明するために必要な事実は、結果として得られる `And` から引き出すことができます：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList_shorter_sides}}
```

<!--
## Merge Sort Terminates
-->

## マージソートが停止すること

<!--
Merge sort has two recursive calls, one for each sub-list returned by `splitList`.
Each recursive call will require a proof that the length of the list being passed to it is shorter than the length of the input list.
It's usually convenient to write a termination proof in two steps: first, write down the propositions that will allow Lean to verify termination, and then prove them.
Otherwise, it's possible to put a lot of effort into proving the propositions, only to find out that they aren't quite what's needed to establish that the recursive calls are on smaller inputs.
-->

マージソートは2つの再帰呼び出しを持ち、それぞれ `splitList` が返すサブリストに対して呼び出されます。それぞれの再帰呼び出しでは渡されるリストの長さが入力リストの長さよりも短いことを証明する必要があります。停止性の証明は通常2つのステップで書くと便利です：まずLeanが停止を検証できる命題を書き出し、それを証明します。そうでないと、命題の証明に多くの労力を費やした結果、それが再帰呼び出しの入力が小さくなることの証明に全く必要ないということだけが判明するということにもなりかねません。

<!--
The `sorry` tactic can prove any goal, even false ones.
It isn't intended for use in production code or final proofs, but it is a convenient way to "sketch out" a proof or program ahead of time.
Any definitions or theorems that use `sorry` are annotated with a warning.
-->

`sorry` タクティクはどのようなゴール、それこそ偽のものであっても証明することができます。これは本番のコードや最終的な証明に使うことは意図されていませんが、証明やプログラムを前もって「下書き」する便利な方法です。`sorry` を使った定義や定理には警告が付きます。

<!--
The initial sketch of `mergeSort`'s termination argument that uses `sorry` can be written by copying the goals that Lean couldn't prove into `have`-expressions.
In Lean, `have` is similar to `let`.
When using `have`, the name is optional.
Typically, `let` is used to define names that refer to interesting values, while `have` is used to locally prove propositions that can be found when Lean is searching for evidence that an array lookup is in-bounds or that a function terminates.
-->

`sorry` を使った `mergeSort` の停止引数についての最初のスケッチは、Leanが証明できなかったゴールを `have` 式にコピーすることから書き始められます。Leanにおいて、`have` は `let` に似ています。`have` を使う場合、名前を省略することができます。一般的に、`let` は興味の対象の値を参照する名前の定義のために使用され、`have` はLeanが何かしらの根拠を検索した際に見つかる命題を局所的に証明するために使用されます。この根拠は配列の検索が範囲内であることや関数が停止することなどです。

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortSorry}}
```
<!--
The warning is located on the name `mergeSort`:
-->

名前 `mergeSort` に対して警告が現れます：

```output warning
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortSorry}}
```
<!--
Because there are no errors, the proposed propositions are enough to establish termination.
-->

エラーは無いため、この命題の方向性は停止性の証明に十分です。

<!--
The proofs begin by applying the helper theorems:
-->

この証明はまず補助定理の適用からはじまります：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortNeedsGte}}
```
<!--
Both proofs fail, because `splitList_shorter_fst` and `splitList_shorter_snd` both require a proof that `xs.length ≥ 2`:
-->

`splitList_shorter_fst` と `splitList_shorter_snd` はどちらも `xs.length ≥ 2` の証明を必要とするため、どちらの証明も失敗します：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortNeedsGte}}
```
<!--
To check that this will be enough to complete the proof, add it using `sorry` and check for errors:
-->

これが証明を完成させることを確認するために、`sorry` を使いエラーになるかチェックします：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortGteStarted}}
```
<!--
Once again, there is only a warning.
-->

ここでも警告のみとなります。

```output warning
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortGteStarted}}
```

<!--
There is one promising assumption available: `h : ¬List.length xs < 2`, which comes from the `if`.
Clearly, if it is not the case that `xs.length < 2`, then `xs.length ≥ 2`.
The Lean library provides this theorem under the name `Nat.ge_of_not_lt`.
The program is now complete:
-->

ここで有力な仮定が1つあります：`if` によって得られる `h : ¬List.length xs < 2` です。明らかに、`xs.length < 2` でなければ `xs.length ≥ 2` となります。Leanのライブラリにはこの定理を `Nat.ge_of_not_lt` という名前で提供しています。これでプログラムが完成します：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean mergeSort}}
```

<!--
The function can be tested on examples:
-->

この関数は以下のような例でテストできます：

```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortRocks}}
```
```output info
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortRocks}}
```
```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortNumbers}}
```
```output info
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortNumbers}}
```

<!--
## Division as Iterated Subtraction
-->

## 割り算が引き算の繰り返しであること

<!--
Just as multiplication is iterated addition and exponentiation is iterated multiplication, division can be understood as iterated subtraction.
The [very first description of recursive functions in this book](../getting-to-know/datatypes-and-patterns.md#recursive-functions) presents a version of division that terminates when the divisor is not zero, but that Lean does not accept.
Proving that division terminates requires the use of a fact about inequalities.
-->

掛け算が足し算の繰り返しであり、累乗が掛け算の繰り返しであるように、割り算は引き算の繰り返しとして理解することができます。[本書における再帰関数の最初の説明](../getting-to-know/datatypes-and-patterns.md#recursive-functions) では、除数が0でないときに停止する割り算を紹介していますが、Leanはこれを受け入れません。割り算が終了することを証明するためには、不等式に関する事実を使用する必要があります。

<!--
The first step is to refine the definition of division so that it requires evidence that the divisor is not zero:
-->

最初のステップは割り算についての定義を改めることで、これによって除数が0でないことの根拠が求められます：

```lean
{{#example_in Examples/ProgramsProofs/Div.lean divTermination}}
```
<!--
The error message is somewhat longer, due to the additional argument, but it contains essentially the same information:
-->

このエラーメッセージは追加の引数によっていくぶん長いですが、本質的には以下と同じ内容です：

```output error
{{#example_out Examples/ProgramsProofs/Div.lean divTermination}}
```

<!--
This definition of `div` terminates because the first argument `n` is smaller on each recursive call.
This can be expressed using a `termination_by` clause:
-->

この `div` の定義は最初の引数 `n` が再帰呼び出しのたびに小さくなることから停止します。これは `termination_by` 節を使うことで表現されます：

```lean
{{#example_in Examples/ProgramsProofs/Div.lean divRecursiveNeedsProof}}
```
<!--
Now, the error is confined to the recursive call:
-->

これで、エラーは再帰呼び出しに限定されるようになります：

```output error
{{#example_out Examples/ProgramsProofs/Div.lean divRecursiveNeedsProof}}
```

<!--
This can be proved using a theorem from the standard library, `Nat.sub_lt`.
This theorem states that `{{#example_out Examples/ProgramsProofs/Div.lean NatSubLt}}` (the curly braces indicate that `n` and `k` are implicit arguments).
Using this theorem requires demonstrating that both `n` and `k` are greater than zero.
Because `k > 0` is syntactic sugar for `0 < k`, the only necessary goal is to show that `0 < n`.
There are two possibilities: either `n` is `0`, or it is `n' + 1` for some other `Nat` `n'`.
But `n` cannot be `0`.
The fact that the `if` selected the second branch means that `¬ n < k`, but if `n = 0` and `k > 0` then `n` must be less than `k`, which would be a contradiction.
This, `n = Nat.succ n'`, and `Nat.succ n'` is clearly greater than `0`.
-->

これは標準ライブラリの定理 `Nat.sub_lt` を使って証明することができます。この定理は `{{#example_out Examples/ProgramsProofs/Div.lean NatSubLt}}` ということを述べています（波括弧は `n` と `k` が暗黙の引数であることを示しています）。この定理を使うには `n` と `k` の両方が0よりも大きいことを証明する必要があります。`k > 0` は `0 < k` の糖衣構文であるため、必要なのは `0 < n` を示すことだけです。これには2つの場合があります：`n` が `0` であるか、ある他の `Nat` `n'` に対して `n' + 1` であるかです。しかし `n` は `0` ではありえません。`if` による2つ目の分岐は `¬ n < k` を意味しますが、もし `n = 0` で `k > 0` であれば `n` は `k` よりも小さいはずであり、これは矛盾になります。これにより `n = Nat.succ n'` であり、`Nat.succ n'` は明らかに `0` より大きくなります。

<!--
The full definition of `div`, including the termination proof, is:
-->

停止についての証明も含めた `div` の完全な定義は以下になります：

```leantac
{{#example_decl Examples/ProgramsProofs/Div.lean div}}
```


<!--
## Exercises
-->

## 演習問題

<!--
Prove the following theorems:
-->

以下の定理を証明してください：

 <!--
 * For all natural numbers \\( n \\), \\( 0 < n + 1 \\).
 * For all natural numbers \\( n \\), \\( 0 \\leq n \\).
 * For all natural numbers \\( n \\) and \\( k \\), \\( (n + 1) - (k + 1) = n - k \\)
 * For all natural numbers \\( n \\) and \\( k \\), if \\( k < n \\) then \\( n \neq 0 \\)
 * For all natural numbers \\( n \\), \\( n - n = 0 \\)
 * For all natural numbers \\( n \\) and \\( k \\), if \\( n + 1 < k \\) then \\( n < k \\)
-->

 * 全ての整数 \\( n \\) について \\( 0 < n + 1 \\) である。
 * 全ての整数 \\( n \\) について \\( 0 \\leq n \\) である。
 * 全ての整数 \\( n \\) と \\( k \\) について \\( (n + 1) - (k + 1) = n - k \\) である。
 * 全ての整数 \\( n \\) と \\( k \\) について、もし \\( k < n \\) ならば \\( n \neq 0 \\) である。
 * 全ての整数 \\( n \\) について \\( n - n = 0 \\) である。
 * 全ての整数 \\( n \\) と \\( k \\) について、もし \\( n + 1 < k \\) ならば \\( n < k \\) である。
