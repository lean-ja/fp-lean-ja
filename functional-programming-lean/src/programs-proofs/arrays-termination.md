<!--
# Arrays and Termination
-->

# 配列と関数の停止

<!--
To write efficient code, it is important to select appropriate data structures.
Linked lists have their place: in some applications, the ability to share the tails of lists is very important.
However, most use cases for a variable-length sequential collection of data are better served by arrays, which have both less memory overhead and better locality.
-->

効率的なコードを書くためには、適切なデータ構造を選択することが重要です。連結リストには利点があります：アプリケーションによっては、リストの末尾を共有できることが非常に重要な場合もあります。しかし、可変長のシーケンシャルなデータコレクションを使用する場合、メモリのオーバーヘッドが少なく、局所性にも優れた配列の方が大体の場合において適しています。

<!--
Arrays, however, have two drawbacks relative to lists:
-->

しかし、配列はリストに対して2つの欠点を持っています：

 <!--
 1. Arrays are accessed through indexing, rather than by pattern matching, which imposes [proof obligations](../props-proofs-indexing.md) in order to maintain safety.
 2. A loop that processes an entire array from left to right is a tail-recursive function, but it does not have an argument that decreases on each call.
-->
 
 1. 配列はパターンマッチではなくインデックスによってアクセスされます。これにあたっては安全性を維持するために [証明の義務](../props-proofs-indexing.md) が課せられます。
 2. 配列全体を左から右に処理するループは末尾再帰関数ですが、呼び出すたびに減少する引数を持ちません。

<!--
Making effective use of arrays requires knowing how to prove to Lean that an array index is in bounds, and how to prove that an array index that approaches the size of the array also causes the program to terminate.
Both of these are expressed using an inequality proposition, rather than propositional equality.
-->

配列を効果的に使うには、配列のインデックスが範囲内にあることをLeanに証明する方法と、配列のインデックスが配列のサイズに到達した際にプログラムが終了することの証明の方法を知る必要があります。これらはどちらも命題の等式ではなく、不等式の命題を使って表現されます。

<!--
## Inequality
-->

## 不等式

<!--
Because different types have different notions of ordering, inequality is governed by two type classes, called `LE` and `LT`.
The table in the section on [standard type classes](../type-classes/standard-classes.md#equality-and-ordering) describes how these classes relate to the syntax:
-->

型によって順序の概念が異なるため、不等式は `LE` と `LT` と呼ばれる2つの型クラスによって管理されています。[標準型クラス](../type-classes/standard-classes.md#equality-and-ordering) の節での表は、これらのクラスが以下の構文とどのように関係しているかを説明します：

<!--
| Expression | Desugaring | Class Name |
-->

| 式 | 脱糖後の式 | 型クラス名 |
|------------|------------|------------|
| `{{#example_in Examples/Classes.lean ltDesugar}}` | `{{#example_out Examples/Classes.lean ltDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean leDesugar}}` | `{{#example_out Examples/Classes.lean leDesugar}}` | `LE` |
| `{{#example_in Examples/Classes.lean gtDesugar}}` | `{{#example_out Examples/Classes.lean gtDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean geDesugar}}` | `{{#example_out Examples/Classes.lean geDesugar}}` | `LE` |

<!--
In other words, a type may customize the meaning of the `<` and `≤` operators, while `>` and `≥` derive their meanings from `<` and `≤`.
The classes `LT` and `LE` have methods that return propositions rather than `Bool`s:
-->

言い換えると、ある型において `<` と `≤` 演算子の意味をカスタマイズすることができ、`>` と `≥` は `<` と `≤` から意味を派生させることができます。クラス `LT` と `LE` は `Bool` 値ではなく命題を返すメソッドを持ちます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean less}}
```

<!--
The instance of `LE` for `Nat` delegates to `Nat.le`:
-->

`LE` の `Nat` についてのインスタンスは `Nat.le` に委譲されています：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean LENat}}
```
<!--
Defining `Nat.le` requires a feature of Lean that has not yet been presented: it is an inductively-defined relation.
-->

`Nat.le` を定義するにはまだ紹介していないLeanの特徴が必要です：帰納的に定義された関係です。

<!--
### Inductively-Defined Propositions, Predicates, and Relations
-->

### 帰納的に定義された命題・述語・関係

<!--
`Nat.le` is an _inductively-defined relation_.
Just as `inductive` can be used to create new datatypes, it can also be used to create new propositions.
When a proposition takes an argument, it is referred to as a _predicate_ that may be true for some, but not all, potential arguments.
Propositions that take multiple arguments are called _relations_.
-->

`Nat.le` は **帰納的に定義された関係** （inductively-defined relation）です。`inductive` は新しいデータ型を作ることに使われるのと同じように、これは新しい命題を作るのにも使われます。命題が引数を取る場合、これは **述語** （predicate）とよばれ、引数に対して真であるものが全てでなくいくつかだけだったりします。複数の引数を取る命題は **関係** （relation）と呼ばれます。

<!--
Each constructor of an inductively defined proposition is a way to prove it.
In other words, the declaration of the proposition describes the different forms of evidence that it is true.
A proposition with no arguments that has a single constructor can be quite easy to prove:
-->

帰納的に定義された命題の各コンストラクタは、その命題を証明するための方法です。言い換えれば、命題の宣言はそれが真であることを証明する様々な形式を記述しています。1つのコンストラクタを持つ引数のない命題の証明は非常に簡単です：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean EasyToProve}}
```
<!--
The proof consists of using its constructor:
-->

この証明は以下のコンストラクタから構成されます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean fairlyEasy}}
```
<!--
In fact, the proposition `True`, which should always be easy to prove, is defined just like `EasyToProve`:
-->

命題 `True` もまた簡単に証明できますが、実は `EasyToProve` と同じように定義されています：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean True}}
```

<!--
Inductively-defined propositions that don't take arguments are not nearly as interesting as inductively-defined datatypes.
This is because data is interesting in its own right—the natural number `3` is different from the number `35`, and someone who has ordered 3 pizzas will be upset if 35 arrive at their door 30 minutes later.
The constructors of a proposition describe ways in which the proposition can be true, but once a proposition has been proved, there is no need to know _which_ underlying constructors were used.
This is why most interesting inductively-defined types in the `Prop` universe take arguments.
-->

引数を取らない帰納的に定義された命題は帰納的に定義されたデータ型よりは面白みに欠けます。というのもデータはそれ自体の正しさに興味があるからです。例えば自然数 `3` と `35` は異なりますし、ピザを3枚注文して、30分後に35枚届いたら腹が立つでしょう。命題のコンストラクタはその命題が真になりうる方法を記述していますが、命題が証明されてしまえば、**どの** コンストラクタが使われたかを知る必要はありません。これが `Prop` の宇宙で興味深い帰納的に定義される型のほとんどが引数を取る理由です。

<!--
The inductively-defined predicate `IsThree` states that its argument is three:
-->

帰納的に定義された述語 `IsThree` はその引数が3であることを示します：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean IsThree}}
```
<!--
The mechanism used here is just like [indexed families such as `HasCol`](../dependent-types/typed-queries.md#column-pointers), except the resulting type is a proposition that can be proved rather than data that can be used.
-->

ここで使用されるメカニズムは [`HasCol` のような添字族](../dependent-types/typed-queries.md#column-pointers) と同様ですが、結果として得られる型は利用可能なデータではなく証明可能な命題です。

<!--
Using this predicate, it is possible to prove that three is indeed three:
-->

この述語を使って、3が本当に3であることを証明できます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean threeIsThree}}
```
<!--
Similarly, `IsFive` is a predicate that states that its argument is `5`:
-->

同様に、`IsFive` は引数が `5` であることを示す述語です：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean IsFive}}
```

<!--
If a number is three, then the result of adding two to it should be five.
This can be expressed as a theorem statement:
-->

もしある数値が3であるなら、これに2を加えると結果は5になるはずです。これは定理の文として表すことができます：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive0}}
```
<!--
The resulting goal has a function type:
-->

結果のゴールは関数型を持ちます：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive0}}
```
<!--
Thus, the `intro` tactic can be used to convert the argument into an assumption:
-->

そのため、`intro` タクティクによって引数を仮定に変換できます：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1}}
```
```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1}}
```
<!--
Given the assumption that `n` is three, it should be possible to use the constructor of `IsFive` to complete the proof:
-->

`n` が3であるという仮定を使って、`IsFive` のコンストラクタを使って証明を完成させることができるはずです：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1a}}
```
<!--
However, this results in an error:
-->

しかし、これはエラーになります：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1a}}
```
<!--
This error occurs because `n + 2` is not definitionally equal to `5`.
In an ordinary function definition, dependent pattern matching on the assumption `three` could be used to refine `n` to `3`.
The tactic equivalent of dependent pattern matching is `cases`, which has a syntax similar to that of `induction`:
-->

このエラーは `n + 2` が `5` と定義上等しくないために起こります。通常の関数定義では、仮定 `three` への依存パターンマッチによって `n` を `3` に絞り込むことができます。依存パターンマッチに相当するタクティクは `cases` で、これは `induction` と似た構文を持っています：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive2}}
```
<!--
In the remaining case, `n` has been refined to `3`:
-->

これによって得られるケースにおいて `n` は `3` に絞り込まれます：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive2}}
```
<!--
Because `3 + 2` is definitionally equal to `5`, the constructor is now applicable:
-->

`3 + 2` は `5` に定義上等しいため、これでこのコンストラクタを適用可能です：

```leantac
{{#example_decl Examples/ProgramsProofs/Arrays.lean threePlusTwoFive3}}
```

<!--
The standard false proposition `False` has no constructors, making it impossible to provide direct evidence for.
The only way to provide evidence for `False` is if an assumption is itself impossible, similarly to how `nomatch` can be used to mark code that the type system can see is unreachable.
As described in [the initial Interlude on proofs](../props-proofs-indexing.md#connectives), the negation `Not A` is short for `A → False`.
`Not A` can also be written `¬A`.
-->

標準的な偽についての命題 `False` はコンストラクタを持ちません。これによって偽を証明するために直接根拠を提供することは不可能になっています。`False` の根拠を提供する唯一の方法は、仮定自体が不可能である場合です。これは `nomatch` を使って、到達不可能であることが型システムによってわかっているコードをマークすることができることと同様です。[証明に関する最初の幕間](../props-proofs-indexing.md#connectives) で説明したように、否定 `Not A` は `A → False` の略です。`Not A` は `¬A` と書くこともできます。

<!--
It is not the case that four is three:
-->

4は3ではありません：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean fourNotThree0}}
```
<!--
The initial proof goal contains `Not`:
-->

証明の初期のゴールは `Not` を含みます：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean fourNotThree0}}
```
<!--
The fact that it's actually a function type can be exposed using `simp`:
-->

これが実際には関数型であることは `simp` を使って明らかにできます：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean fourNotThree1}}
```
```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean fourNotThree1}}
```
<!--
Because the goal is a function type, `intro` can be used to convert the argument into an assumption.
There is no need to keep `simp`, as `intro` can unfold the definition of `Not` itself:
-->

ゴールは関数型であるため、`intro` を使って引数を仮定に変換することができます。`intro` は `Not` の定義をのものを展開することができるため、`simp` を使う必要はありません。

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean fourNotThree2}}
```
```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean fourNotThree2}}
```
<!--
In this proof, the `cases` tactic solves the goal immediately:
-->

この証明では、`cases` タクティクによってゴールが即座に解決されます：

```leantac
{{#example_decl Examples/ProgramsProofs/Arrays.lean fourNotThreeDone}}
```
<!--
Just as a pattern match on a `Vect String 2` doesn't need to include a case for `Vect.nil`, a proof by cases over `IsThree 4` doesn't need to include a case for `isThree`.
-->

`Vect String 2` のパターンマッチに `Vect.nil` のケースを含める必要がないように、`IsThree 4` のケースによる証明に `isThree` のケースを含める必要はありません。

<!--
### Inequality of Natural Numbers
-->

### 整数の不等式

<!--
The definition of `Nat.le` has a parameter and an index:
-->

`Nat.le` の定義にはパラメータと添字が含まれます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean NatLe}}
```
<!--
The parameter `n` is the number that should be smaller, while the index is the number that should be greater than or equal to `n`.
The `refl` constructor is used when both numbers are equal, while the `step` constructor is used when the index is greater than `n`.
-->

パラメータ `n` は小さい方の数であり、添字は `n` 以上となるはずの数です。両方の数値が等しい場合は `refl` コンストラクタを使用し、添字が `n` より大きい場合は `step` コンストラクタを使用します。

<!--
From the perspective of evidence, a proof that \\( n \leq k \\) consists of finding some number \\( d \\) such that \\( n + d = m \\).
In Lean, the proof then consists of a `Nat.le.refl` constructor wrapped by \\( d \\) instances of `Nat.le.step`.
Each `step` constructor adds one to its index argument, so \\( d \\) `step` constructors adds \\( d \\) to the larger number.
For example, evidence that four is less than or equal to seven consists of three `step`s around a `refl`:
-->

根拠の観点からすると、 \\( n \leq k \\) の証明は \\( n + d = k \\) [^1]となるような \\( d \\) である数を見つけることから構成されます。Leanでは、この証明は `Nat.le.step` の \\( d \\) についてのインスタンスでラップされた `Nat.le.refl` コンストラクタから構成されます。各 `step` コンストラクタはその添字引数に1を加えるため、 \\( d \\) 回の `step` コンストラクタは大きい数に \\( d \\) を加算します。例えば、4が7以下である根拠は `refl` を囲む3つの `step` で構成されます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean four_le_seven}}
```

<!--
The strict less-than relation is defined by adding one to the number on the left:
-->

未満関係は左の数字に1を足すことで定義されます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean NatLt}}
```
<!--
Evidence that four is strictly less than seven consists of two `step`'s around a `refl`:
-->

4が7未満であるという根拠は `refl` の周りにある2つの `step` で構成されます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean four_lt_seven}}
```
<!--
This is because `4 < 7` is equivalent to `5 ≤ 7`.
-->

これは `4 < 7` が `5 ≤ 7` と等しい訳です。

<!--
## Proving Termination
-->

## 停止性の証明

<!--
The function `Array.map` transforms an array with a function, returning a new array that contains the result of applying the function to each element of the input array.
Writing it as a tail-recursive function follows the usual pattern of delegating to a function that passes the output array in an accumulator.
The accumulator is initialized with an empty array.
The accumulator-passing helper function also takes an argument that tracks the current index into the array, which starts at `0`:
-->

関数 `Array.map` は配列を関数で変換し、入力配列の各要素に関数を適用した結果を含んだ新しい配列を返します。これを末尾再帰関数として書くと、出力配列をアキュムレータに渡すような関数に委譲するといういつものパターンになります。アキュムレータは空の配列で初期化されます。アキュムレータを渡す補助関数は配列の現在のインデックスを追跡する引数を取り、これは `0` から始まります：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayMap}}
```

<!--
The helper should, at each iteration, check whether the index is still in bounds.
If so, it should loop again with the transformed element added to the end of the accumulator and the index incremented by `1`.
If not, then it should terminate and return the accumulator.
An initial implementation of this code fails because Lean is unable to prove that the array index is valid:
-->

補助関数は各繰り返しにて、インデックスがまだ範囲内にあるかどうかをチェックする必要があります。もし範囲内であれば、変換された要素をアキュムレータの最後に追加し、インデックスを `1` だけ加算して再度ループする必要があります。そうでない場合は終了してアキュムレータを返します。このコードの初期実装ではLeanが配列のインデックスが有効であることを証明できないため失敗します：

```lean
{{#example_in Examples/ProgramsProofs/Arrays.lean mapHelperIndexIssue}}
```
```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean mapHelperIndexIssue}}
```
<!--
However, the conditional expression already checks the precise condition that the array index's validity demands (namely, `i < arr.size`).
Adding a name to the `if` resolves the issue, because it adds an assumption that the array indexing tactic can use:
-->

しかし、この条件式ではすでに配列のインデックスの有効性が要求する正確な条件（すなわち `i < arr.size` ）をチェックしています。`if` に名前を追加することで、配列のインデックスのタクティクが使用できる仮定が追加されるため、問題は解決します：

```lean
{{#example_in Examples/ProgramsProofs/Arrays.lean arrayMapHelperTermIssue}}
```
<!--
Lean does not, however, accept the modified program, because the recursive call is not made on an argument to one of the input constructors.
In fact, both the accumulator and the index grow, rather than shrinking:
-->

しかし、Leanはこの修正されたプログラムを受け付けません。なぜなら、再帰呼び出しが入力コンストラクタの1つの引数に対して行われていないからです。実際、アキュムレータもインデックスも縮小するのではなく、むしろ増大します：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean arrayMapHelperTermIssue}}
```
<!--
Nevertheless, this function terminates, so simply marking it `partial` would be unfortunate.
-->

とはいえこの関数は停止するため、単に `partial` とマークするのはあまりに残念です。

<!--
Why does `arrayMapHelper` terminate?
Each iteration checks whether the index `i` is still in bounds for the array `arr`.
If so, `i` is incremented and the loop repeats.
If not, the program terminates.
Because `arr.size` is a finite number, `i` can be incremented only a finite number of times.
Even though no argument to the function decreases on each call, `arr.size - i` decreases toward zero.
-->

なぜ `arrayMapHelper` は停止するのでしょうか？各繰り返しはインデックス `i` が配列 `arr` の範囲内にあるかどうかをチェックします。もし真であれば、`i` が加算され、ループが繰り返されます。そうでなければプログラムは終了します。`arr.size` は有限な値であるため、`i` を加算できる回数も有限回です。関数を呼び出すたびに引数が減らない場合でも、`arr.size -i` は0に向かって減っていきます。

<!--
Lean can be instructed to use another expression for termination by providing a `termination_by` clause at the end of a definition.
The `termination_by` clause has two components: names for the function's arguments and an expression using those names that should decrease on each call.
For `arrayMapHelper`, the final definition looks like this:
-->

Leanは定義の最後に `termination_by` 節を記述することで、停止について別の式を使うように指示することができます。`termination_by` 節には2つの要素があります：関数の引数の名前と、その名前を使っており各呼び出しのたびに値が減るべき式です。`arrayMapHelper` の場合、最終的な定義は以下のようになります：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayMapHelperOk}}
```

<!--
A similar termination proof can be used to write `Array.find`, a function that finds the first element in an array that satisfies a Boolean function and returns both the element and its index:
-->

同様の停止証明を使って、ある真偽値関数を満たす配列の最初の要素を見つけ、その要素をインデックスの両方を返す関数 `Array.find` を書くことができます：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayFind}}
```
<!--
Once again, the helper function terminates because `arr.size - i` decreases as `i` increases:
-->

ここでもまた、`i` が増加すると `arr.size - i` が減少するのでここでも補助関数は終了します：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayFindHelper}}
```

<!--
Not all termination arguments are as quite as simple as this one.
However, the basic structure of identifying some expression based on the function's arguments that will decrease in each call occurs in all termination proofs.
Sometimes, creativity can be required in order to figure out just why a function terminates, and sometimes Lean requires additional proofs in order to accept the termination argument.

-->

すべての停止引数がこれほど単純であるとは限りません。しかし、関数の引数に基づいで呼び出しのたびに減少する式を特定するという基本的な構造は、全ての停止証明で発生します。時には関数が停止する理由を解明するために想像力が要求されることもありますし、またLeanが停止引数を受け入れるために追加の証明を必要とすることもあります。

<!--
## Exercises
-->

## 演習問題

 <!--
 * Implement a `ForM (Array α)` instance on arrays using a tail-recursive accumulator-passing function and a `termination_by` clause.
 * Implement a function to reverse arrays using a tail-recursive accumulator-passing function that _doesn't_ need a `termination_by` clause.
 * Reimplement `Array.map`, `Array.find`, and the `ForM` instance using `for ... in ...` loops in the identity monad and compare the resulting code.
 * Reimplement array reversal using a `for ... in ...` loop in the identity monad. Compare it to the tail-recursive function.
-->

 * 末尾再帰のアキュムレータを渡す関数と `termination_by` 節を使って配列に対して `ForM (Array α)` インスタンスを定義してください。
 * `termination_by` を **必要としない** 末尾再帰のアキュムレータを渡す関数を使用して配列を反転させる関数を実装してください。
 * 恒等モナドの `for ... in ...` ループを使って `Array.map` ・`Array.find` ・`ForM` インスタンスを再実装し、結果のコードを比較してください。
 * 配列の反転を恒等モナドの `for ... in ...` ループを使って再実装してください。またそれを末尾再帰版と比較してください。

[^1]: 原文では \\( n + d = m \\) となっていたが、mとkの書き間違いと思われる。