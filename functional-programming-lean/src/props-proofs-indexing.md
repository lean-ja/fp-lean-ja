<!-- # Interlude: Propositions, Proofs, and Indexing -->

# 休憩: 命題，証明，そしてリストの添え字アクセス

<!-- Like many languages, Lean uses square brackets for indexing into arrays and lists.
For instance, if `woodlandCritters` is defined as follows: -->

多くの言語と同様に，Leanは角括弧を配列とリストへの添え字アクセスに使います．例えば，`woodlandCitters` が以下のように定義されているとします:

```lean
{{#example_decl Examples/Props.lean woodlandCritters}}
```
<!-- then the individual components can be extracted: -->

ここで，各要素は次のようにして展開することができます:

```lean
{{#example_decl Examples/Props.lean animals}}
```
<!-- However, attempting to extract the fourth element results in a compile-time error, rather than a run-time error: -->

しかし，4番目の要素を取り出そうとすると，実行時エラーではなくコンパイル時エラーとなります:

```lean
{{#example_in Examples/Props.lean outOfBounds}}
```
```output error
{{#example_out Examples/Props.lean outOfBounds}}
```
<!-- This error message is saying Lean tried to automatically mathematically prove that `3 < List.length woodlandCritters`, which would mean that the lookup was safe, but that it could not do so.
Out-of-bounds errors are a common class of bugs, and Lean uses its dual nature as a programming language and a theorem prover to rule out as many as possible. -->

このエラーメッセージは，Leanが `3 < List.length woodlandCritters` を自動で数学的に証明しようとして（これはルックアップが安全であることを意味します），それができなかったというものです．リストの範囲外エラーはごくありふれたバグであり，Leanはプログラミング言語と定理証明器の2つの性質を利用して，できるだけ多くのエラーを除外します．

<!-- Understanding how this works requires an understanding of three key ideas: propositions, proofs, and tactics. -->

この仕組みを理解するには，命題，証明，タクティクという3つの重要な考え方を理解する必要があります．

<!-- ## Propositions and Proofs -->

## 命題と証明

<!-- A _proposition_ is a statement that can be true or false.
All of the following are propositions: -->

_命題(proposition)_ とは，真にも偽にもなりうる文のことです．以下はすべて命題です:

 * 1 + 1 = 2
 <!-- * Addition is commutative -->
 * 足し算は可換である
 <!-- * There are infinitely many prime numbers -->
 * 素数は無限に存在する
 * 1 + 1 = 15
 <!-- * Paris is the capital of France -->
 * パリはフランスの首都である
 <!-- * Buenos Aires is the capital of South Korea -->
 * ブエノスアイレスは韓国の首都である
 <!-- * All birds can fly -->
 * すべての鳥は飛ぶことができる

<!-- On the other hand, nonsense statements are not propositions.
None of the following are propositions: -->

一方で，無意味な文は命題ではありません．以下はどれも命題ではありません:

 <!-- * 1 + green = ice cream -->
 * 1 + 緑 = アイスクリーム
 <!-- * All capital cities are prime numbers -->
 * すべての首都は素数である
 <!-- * At least one gorg is a fleep -->
 * 少なくとも1つのホゲはフガである

<!-- Propositions come in two varieties: those that are purely mathematical, relying only on our definitions of concepts, and those that are facts about the world.
Theorem provers like Lean are concerned with the former category, and have nothing to say about the flight capabilities of penguins or the legal status of cities. -->

命題は2つに分類されます: 純粋に数学的なもので，私たちの概念の定義にのみ依存するものと，世界に関する事実であるものです．Leanのような定理証明器は前者のカテゴリを扱っており，ペンギンの飛行能力や都市の法的地位について語ることはありません．

<!-- A _proof_ is a convincing argument that a proposition is true.
For mathematical propositions, these arguments make use of the definitions of the concepts that are involved as well as the rules of logical argumentation.
Most proofs are written for people to understand, and leave out many tedious details.
Computer-aided theorem provers like Lean are designed to allow mathematicians to write proofs while omitting many details, and it is the software's responsibility to fill in the missing explicit steps.
This decreases the likelihood of oversights or mistakes. -->

_証明(proof)_ とは，ある命題が真であることを説得させる論証のことです．数学的命題の場合，これらの論証はそれに関連する概念の定義と論理的論証の規則を利用します．ほとんどの証明は人々が理解できるように書かれており，多くの面倒な詳細は省かれています．Leanのような計算機による定理証明支援器は，数学者が多くの詳細を省きながら証明を書けるように設計されており，欠落している明白なステップを埋めるのはソフトウェアの責任です．これにより見落としや間違いの可能性を減らすことができます．

<!-- In Lean, a program's type describes the ways it can be interacted with.
For instance, a program of type `Nat → List String` is a function that takes a `Nat` argument and produces a list of strings.
In other words, each type specifies what counts as a program with that type. -->

Leanでは，プログラムの型はそのプログラムがほかのプログラムとどのように相互作用できるかを記述したものです．例えば，`Nat → List String` という型のプログラムは，引数 `Nat` を受け取り，文字列のリストを生成する関数です．言い換えると，それぞれの型はその型を持つプログラムとしての大事なポイントを指定したものです．

<!-- In Lean, propositions are in fact types.
They specify what counts as evidence that the statement is true.
The proposition is proved by providing this evidence.
On the other hand, if the proposition is false, then it will be impossible to construct this evidence. -->

Leanにおいて，命題はまさに型です．命題はその文が真であることの根拠としての大事なポイントを指定します．この根拠を提示することで，命題が証明されます．一方で，命題が偽であれば，証明を構築することは不可能です．

<!-- For example, the proposition "1 + 1 = 2" can be written directly in Lean.
The evidence for this proposition is the constructor `rfl`, which is short for _reflexivity_: -->

例えば，「1 + 1 = 2」という命題はLeanでそのまま記述することができます．この命題の根拠はコンストラクタ `rfl` で，この名称は _反射性(reflexivity)_ の略です:

```lean
{{#example_decl Examples/Props.lean onePlusOneIsTwo}}
```
<!-- On the other hand, `rfl` does not prove the false proposition "1 + 1 = 15": -->

一方で，`rfl` は偽の命題「1 + 1 = 15」を証明しません:

```lean
{{#example_in Examples/Props.lean onePlusOneIsFifteen}}
```
```output error
{{#example_out Examples/Props.lean onePlusOneIsFifteen}}
```
<!-- This error message indicates that `rfl` can prove that two expressions are equal when both sides of the equality statement are already the same number.
Because `1 + 1` evaluates directly to `2`, they are considered to be the same, which allows `onePlusOneIsTwo` to be accepted.
Just as `Type` describes types such as `Nat`, `String`, and `List (Nat × String × (Int → Float))` that represent data structures and functions, `Prop` describes propositions. -->

このエラーメッセージから，`rfl` は等号についての文の両辺がすでに同じ数値である場合に2つの式が等しいことを証明できることがわかります．`1 + 1` は `2` に直接評価されるので両者は同じとみなされる， `onePlusOneIsTwo` がLeanに受け入れられます．`Type` が `Nat` や `String` ，`List (Nat × String × (Int → Float))` などのデータ構造や関数を表す型を記述するように命題を表す型 `Prop` を記述します．

<!-- When a proposition has been proven, it is called a _theorem_.
In Lean, it is conventional to declare theorems with the `theorem` keyword instead of `def`.
This helps readers see which declarations are intended to be read as mathematical proofs, and which are definitions.
Generally speaking, with a proof, what matters is that there is evidence that a proposition is true, but it's not particularly important _which_ evidence was provided.
With definitions, on the other hand, it matters very much which particular value is selected—after all, a definition of addition that always returns `0` is clearly wrong. -->

証明されると命題は _定理(theorem)_ と呼ばれます．Leanでは定理を宣言するときには `def` の代わりに `theorem` キーワードを使うのが一般的です．これにより，読者はどの宣言が数学的な証明であり，どの宣言が定義であるかがわかりやすくなります．一般論として，証明で重要なことは命題が真であるという根拠が存在するということであり， _どの_ 根拠が提示されたかということは特に重要ではありません．一方で，定義の場合，どの特定の値が選択されるかということは非常に重要です．なにしろ，足し算の定義として常に `0` を返すものは明らかに間違っているからです．

<!-- The prior example could be rewritten as follows: -->

前者の例は以下のように書くこともできます:

```lean
{{#example_decl Examples/Props.lean onePlusOneIsTwoProp}}
```

<!-- ## Tactics -->

## タクティク

<!-- Proofs are normally written using _tactics_, rather than by providing evidence directly.
Tactics are small programs that construct evidence for a proposition.
These programs run in a _proof state_ that tracks the statement that is to be proved (called the _goal_) along with the assumptions that are available to prove it.
Running a tactic on a goal results in a new proof state that contains new goals.
The proof is complete when all goals have been proven. -->

Leanにおける証明は通常，根拠を直接示すのではなく _タクティク(tactic)_ を用いて記述されます．タクティクは命題の根拠を構築する小さなプログラムのことです．これらのプログラムは証明したい文（ _ゴール(goal)_ とよばれます）と利用可能な仮定を用いて証明していく過程である _証明状態(proof state)_ の中で実行されます．ゴールに対してタクティクを実行すると，新しいゴールを含む新しい証明状態が生まれます．すべてのゴールが証明されたとき，証明が完了します．

<!-- To write a proof with tactics, begin the definition with `by`.
Writing `by` puts Lean into tactic mode until the end of the next indented block.
While in tactic mode, Lean provides ongoing feedback about the current proof state.
Written with tactics, `onePlusOneIsTwo` is still quite short: -->

タクティクを使って証明を書くには，定義を `by` で始めます．`by` と書くことでこれに続くインデントされたブロックが終わるところまでLeanがタクティクモードになります．タクティクモードでは，Leanは現在の証明状態について継続的なフィードバックを提供します．タクティクを用いた `onePlusOneIsTwo` もかなり短いものになります:

```leantac
{{#example_decl Examples/Props.lean onePlusOneIsTwoTactics}}
```
<!-- The `simp` tactic, short for "simplify", is the workhorse of Lean proofs.
It rewrites the goal to as simple a form as possible, taking care of parts of the proof that are small enough.
In particular, it proves simple equality statements.
Behind the scenes, a detailed formal proof is constructed, but using `simp` hides this complexity. -->

`simp` タクティクは「簡約(simplify)」の略で，Leanでの証明の主戦力です．これはゴールをできるだけ単純な形に書き直し，またこの工程の記述を十分小さいものにしてくれます．特に，単純な等号についての文を証明します．その裏では，詳細な形式的証明が構築されますが，`simp` を使うことでこの複雑さを隠すことができます．

<!-- Tactics are useful for a number of reasons: -->
タクティクは多くの理由から便利です:
 <!-- 1. Many proofs are complicated and tedious when written out down to the smallest detail, and tactics can automate these uninteresting parts. -->
 1. 多くの証明は細部に至るまで書き出すと複雑で面倒になりますが，タクティクはこうした面白くない部分を自動化してくれます．
 <!-- 2. Proofs written with tactics are easier to maintain over time, because flexible automation can paper over small changes to definitions. -->
 2. タクティクで書かれた証明は柔軟な自動化によって定義の小さな変更を吸収することができるため，長期にわたるメンテナンスが容易です．
 <!-- 3. Because a single tactic can prove many different theorems, Lean can use tactics behind the scenes to free users from writing proofs by hand. For instance, an array lookup requires a proof that the index is in bounds, and a tactic can typically construct that proof without the user needing to worry about it. -->
 3. 1つのタクティクで多くの異なる定理を証明することができるため，Leanが裏でタクティクを使うことでユーザが手で証明を書く手間を省くことができます．例えば，配列のルックアップにはインデックスが添え字の上限内にあることの証明が必要ですが，タクティクは通常ユーザの気を煩わすことなくその証明を構築することができます．

<!-- Behind the scenes, indexing notation uses a tactic to prove that the user's lookup operation is safe.
This tactic is `simp`, configured to take certain arithmetic identities into account. -->

裏側では，添え字アクセスの表記はユーザのルックアップ操作が安全であることを証明するためにタクティクを使用します．このタクティクは `simp` であり，ある種の算術的同一性を考慮するように設定されています．

<!-- ## Connectives -->

## 論理結合子

<!-- The basic building blocks of logic, such as "and", "or", "true", "false", and "not", are called _logical connectives_.
Each connective defines what counts as evidence of its truth.
For example, to prove a statement "_A_ and _B_", one must prove both _A_ and _B_.
This means that evidence for "_A_ and _B_" is a pair that contains both evidence for _A_ and evidence for _B_.
Similarly, evidence for "_A_ or _B_" consists of either evidence for _A_ or evidence for _B_. -->

論理の基本的な構成要素である「かつ」，「または」，「真」，「偽」，「～ではない」は _論理結合子(logical connectives)_ と呼ばれます．各結合子は，何がその心理の根拠となるかを定義します．例えば，「 _A_ かつ _B_ 」という文を証明するには， _A_ と _B_ の両方を証明しなければなりません．つまり，「 _A_ かつ _B_ 」の根拠とは， _A_ の根拠と _B_ の根拠の両方を含むペアのことです．同様に，「 _A_ または _B_ 」の根拠は， _A_ の根拠と _B_ の根拠のどちらか一方からなります．

<!-- In particular, most of these connectives are defined like datatypes, and they have constructors.
If `A` and `B` are propositions, then "`A` and `B`" (written `{{#example_in Examples/Props.lean AndProp}}`) is a proposition.
Evidence for `A ∧ B` consists of the constructor `{{#example_in Examples/Props.lean AndIntro}}`, which has the type `{{#example_out Examples/Props.lean AndIntro}}`.
Replacing `A` and `B` with concrete propositions, it is possible to prove `{{#example_out Examples/Props.lean AndIntroEx}}` with `{{#example_in Examples/Props.lean AndIntroEx}}`.
Of course, `simp` is also powerful enough to find this proof: -->

特に，これらの結合子のほとんどはデータ型のように定義され，コンストラクタを持ちます． _A_ と _B_ が命題である場合，「 `A` かつ `B` 」（ `{{#example_in Examples/Props.lean AndProp}}` と書かれます）は命題です．`A ∧ B` の根拠はコンストラクタ `{{#example_in Examples/Props.lean AndIntro}}` で構成され，これは `{{#example_out Examples/Props.lean AndIntro}}` という型を持ちます．`A` と `B` を具体的な命題に置き換えれば，`{{#example_out Examples/Props.lean AndIntroEx}}` を `{{#example_in Examples/Props.lean AndIntroEx}}` で証明することができます．もちろん，`simp` も以下のように十分強力に証明してくれます:

```leantac
{{#example_decl Examples/Props.lean AndIntroExTac}}
```

<!-- Similarly, "`A` or `B`" (written `{{#example_in Examples/Props.lean OrProp}}`) has two constructors, because a proof of "`A` or `B`" requires only that one of the two underlying propositions be true.
There are two constructors: `{{#example_in Examples/Props.lean OrIntro1}}`, with type `{{#example_out Examples/Props.lean OrIntro1}}`, and `{{#example_in Examples/Props.lean OrIntro2}}`, with type `{{#example_out Examples/Props.lean OrIntro2}}`. -->

同様に，「 `A` または `B` 」（ `{{#example_in Examples/Props.lean OrProp}}` と書かれます）には2つのコンストラクタがあります．なぜなら，「 `A` または `B` 」の証明には，2つの命題のうちどちらか1つが真であることしか要求していないからです．このコンストラクタは `{{#example_out Examples/Props.lean OrIntro1}}` 型の `{{#example_in Examples/Props.lean OrIntro1}}` と，`{{#example_out Examples/Props.lean OrIntro2}}` 型の `{{#example_in Examples/Props.lean OrIntro2}}` の2つです．

<!-- Implication (if _A_ then _B_) is represented using functions.
In particular, a function that transforms evidence for _A_ into evidence for _B_ is itself evidence that _A_ implies _B_.
This is different from the usual description of implication, in which `A → B` is shorthand for `¬A ∨ B`, but the two formulations are equivalent. -->

含意（もし _A_ ならば _B_ である）は関数を用いて表現されます．特に， _A_ の根拠を _B_ の根拠に変換する関数は，それ自体が _A_ ならば _B_ の根拠となります．また，`A → B` が `¬A ∨ B` の省略形です．これは通常の含意の記述とは異なりますが，2つの定式化は等価です．

<!-- Because evidence for an "and" is a constructor, it can be used with pattern matching.
For instance, a proof that _A_ and _B_ implies _A_ or _B_ is a function that pulls the evidence of _A_ (or of _B_) out of the evidence for _A_ and _B_, and then uses this evidence to produce evidence of _A_ or _B_: -->

「かつ」の根拠はコンストラクタであるため，パターンマッチに使用することができます．例えば，「 _A_ かつ _B_ ならば _A_ または _B_ 」の証明は， _A_ かつ _B_ の根拠から _A_ （もしくは _B_ ）の根拠を取り出し，これを使って _A_ または _B_ の根拠を生成する関数です:

```lean
{{#example_decl Examples/Props.lean andImpliesOr}}
```


<!-- | Connective      | Lean Syntax | Evidence     |
|-----------------|-------------|--------------|
| True            | `True`      | `True.intro : True` |
| False           | `False`     | No evidence  |
| _A_ and _B_     | `A ∧ B`     | `And.intro : A → B → A ∧ B` |
| _A_ or _B_      | `A ∨ B`     | Either `Or.inl : A → A ∨ B` or `Or.inr : B → A ∨ B` |
| _A_ implies _B_ | `A → B`     | A function that transforms evidence of _A_ into evidence of _B_ |
| not _A_         | `¬A`        | A function that would transform evidence of _A_ into evidence of `False` | -->

| 論理結合子      | Leanの記法 | 根拠     |
|-----------------|-------------|--------------|
| 真            | `True`      | `True.intro : True` |
| 偽           | `False`     | 根拠なし  |
| _A_ かつ _B_     | `A ∧ B`     | `And.intro : A → B → A ∧ B` |
| _A_ または _B_      | `A ∨ B`     | `Or.inl : A → A ∨ B` もしくは `Or.inr : B → A ∨ B` |
| _A_ ならば _B_ | `A → B`     | _A_ の根拠を _B_ の根拠に変換する関数 |
| _A_ ではない        | `¬A`        | _A_ の根拠を `False` の根拠に変換する関数 |

<!-- The `simp` tactic can prove theorems that use these connectives.
For example: -->

`simp` タクティクはこれらの結合子を使った定理を証明することができます．例えば以下のように使うことができます:

```leantac
{{#example_decl Examples/Props.lean connectives}}
```

<!-- ## Evidence as Arguments -->

## 引数に現れる根拠

<!-- While `simp` does a great job proving propositions that involve equalities and inequalities of specific numbers, it is not very good at proving statements that involve variables.
For instance, `simp` can prove that `4 < 15`, but it can't easily tell that because `x < 4`, it's also true that `x < 15`.
Because index notation uses `simp` behind the scenes to prove that array access is safe, it can require a bit of hand-holding. -->

`simp` はある種の数の等式や不等式を含む命題の証明は得意ですが，変数を含む文の証明は苦手です．例えば，`simp` は `4 < 15` を証明できますが，`x < 4` であるからといって `x < 15` も真であるということは `simp` にとっては簡単にはわかりません．インデックス記法は，配列へのアクセスが安全であることを証明するために裏で `simp` を使っているので，`simp` にちょっと手助けする必要があります．

<!-- One of the easiest ways to make indexing notation work well is to have the function that performs a lookup into a data structure take the required evidence of safety as an argument.
For instance, a function that returns the third entry in a list is not generally safe because lists might contain zero, one, or two entries: -->

インデックス記法をうまく機能させる最も簡単な方法のひとつは，データ構造へのルックアップを実行する関数に，必要な安全性の根拠を引数として取らせることです．例えば，リストの3番目の要素を返す関数は一般的には安全とは言えません．なぜなら要素の数が0，1，2個であるかもしれないからです:

```lean
{{#example_in Examples/Props.lean thirdErr}}
```
```output error
{{#example_out Examples/Props.lean thirdErr}}
```
<!-- However, the obligation to show that the list has at least three entries can be imposed on the caller by adding an argument that consists of evidence that the indexing operation is safe: -->

しかし，インデックス操作が安全であるという証拠からなる引数を追加することで，リストが少なくとも3つの要素を持たなければならないという制約を呼び出し側に課すことができます:

```lean
{{#example_decl Examples/Props.lean third}}
```
<!-- In this example, `xs.length > 2` is not a program that checks _whether_ `xs` has more than 2 entries.
It is a proposition that could be true or false, and the argument `ok` must be evidence that it is true. -->

この例では，`xs.length > 2` は `xs` が2つ以上の要素を _持つかどうか_ をチェックするプログラムではありません．これは真でも偽でもありうる命題であり，引数 `ok` はそれが真であることの証拠でなければなりません．

<!-- When the function is called on a concrete list, its length is known.
In these cases, `by simp` can construct the evidence automatically: -->

この関数が具体的なリストで呼ばれた場合，その長さはその時点で既知です．この場合，`by simp` は自動的にエビデンスを構築することができます:

```leantac
{{#example_in Examples/Props.lean thirdCritters}}
```
```output info
{{#example_out Examples/Props.lean thirdCritters}}
```

<!-- ## Indexing Without Evidence -->

## 根拠なしの添え字アクセス

<!-- In cases where it's not practical to prove that an indexing operation is in bounds, there are other alternatives.
Adding a question mark results in an `Option`, where the result is `some` if the index is in bounds, and `none` otherwise.
For example: -->

インデックス操作がリストの範囲内であることを証明することが現実的でない場合には，ほかの方法があります．はてなマークを付けると戻り値の型が `Option` となり，インデックスが範囲内にあれば `some` ，そうでなければ `none` となります．例えば以下のようにふるまいます:

```lean
{{#example_decl Examples/Props.lean thirdOption}}

{{#example_in Examples/Props.lean thirdOptionCritters}}
```
```output info
{{#example_out Examples/Props.lean thirdOptionCritters}}
```
```lean
{{#example_in Examples/Props.lean thirdOptionTwo}}
```
```output info
{{#example_out Examples/Props.lean thirdOptionTwo}}
```

<!-- There is also a version that crashes the program when the index is out of bounds, rather than returning an `Option`: -->

また，インデックスが範囲外になったときに `Option` を返すのではなく，プログラムをクラッシュさせるバージョンも存在します:

```lean
{{#example_in Examples/Props.lean crittersBang}}
```
```output info
{{#example_out Examples/Props.lean crittersBang}}
```
<!-- Be careful!
Because code that is run with `#eval` runs in the context of the Lean compiler, selecting the wrong index can crash your IDE. -->

注意！
`#eval` で実行されるコードはLeanのコンパイラのコンテキストで実行されるため，間違ったインデックスを選択するとIDEがクラッシュする可能性があります．

<!-- ## Messages You May Meet -->

## 見るかもしれないメッセージ

<!-- In addition to the error that occurs when Lean is unable to find compile-time evidence that an indexing operation is safe, polymorphic functions that use unsafe indexing may produce the following message: -->

Leanがインデックス操作の安全性の根拠をコンパイル時に見つけることができない場合に発生するエラーに加えて，安全でないインデックス操作を使用する多相関数は次のようなメッセージを生成することがあります:

```lean
{{#example_in Examples/Props.lean unsafeThird}}
```
```output error
{{#example_out Examples/Props.lean unsafeThird}}
```
<!-- This is due to a technical restriction that is part of keeping Lean usable as both a logic for proving theorems and a programming language.
In particular, only programs whose types contain at least one value are allowed to crash.
This is because a proposition in Lean is a kind of type that classifies evidence of its truth.
False propositions have no such evidence.
If a program with an empty type could crash, then that crashing program could be used as a kind of fake evidence for a false proposition. -->

これは，Leanを定理を証明するための論理としてもプログラミング言語としても使えるようにするための技術的な制限によるものです．特に，型が少なくとも1つは値を持つような型のプログラムだけがクラッシュすることが許可されています．これは，Leanにおける命題がその真理の根拠を分類する型の一種であるためです．偽の命題にはこのような根拠はありません．もし空である型を持つプログラムがクラッシュするとしたら，そのクラッシュしたプログラムは偽の命題のための偽の根拠の一種として使われている可能性があります．

<!-- Internally, Lean contains a table of types that are known to have at least one value.
This error is saying that some arbitrary type `α` is not necessarily in that table.
The next chapter describes how to add to this table, and how to successfully write functions like `unsafeThird`. -->

内部的には，Leanは少なくとも1つは値を持つことが知られている型のテーブルを保持しています．このエラーはある任意の型 `α` がその表にあるとは限らないと言っているのです．この表に追加する方法と，`unsafeThird` のような関数をうまく書く方法については次の章で説明します．

<!-- Adding whitespace between a list and the brackets used for lookup can cause another message: -->

リストのルックアップに使われる括弧の間にスペースを入れると，別のメッセージが表示されることがあります．

```lean
{{#example_in Examples/Props.lean extraSpace}}
```
```output error
{{#example_out Examples/Props.lean extraSpace}}
```
<!-- Adding a space causes Lean to treat the expression as a function application, and the index as a list that contains a single number.
This error message results from having Lean attempt to treat `woodlandCritters` as a function. -->

スペースを追加すると，Leanは式を関数適用として扱い，インデックスを1つの数値からなるリストとして扱います．このエラーメッセージは，Leanが `woodlandCritters` を関数として扱おうとした結果です．

## Exercises

<!-- * Prove the following theorems using `rfl`: `2 + 3 = 5`, `15 - 8 = 7`, `"Hello, ".append "world" = "Hello, world"`. What happens if `rfl` is used to prove `5 < 18`? Why? -->
* 次の定理を `rfl` を使って証明してください．また `5 < 18` に適用したら何が起きるでしょうか？そしてそれは何故でしょうか？
    * `2 + 3 = 5`
    * `15 - 8 = 7`
    * `"Hello, ".append "world" = "Hello, world"`
<!-- * Prove the following theorems using `by simp`: `2 + 3 = 5`, `15 - 8 = 7`, `"Hello, ".append "world" = "Hello, world"`, `5 < 18`. -->
* 上記の命題を `by simp` で証明してください．
<!-- * Write a function that looks up the fifth entry in a list. Pass the evidence that this lookup is safe as an argument to the function. -->
* リストの5番目の要素をルックアップする関数を書いてください．この関数の引数にはルックアップが安全であるという根拠を渡すようにしてください．
