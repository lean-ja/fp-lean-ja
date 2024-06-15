<!-- # Standard Classes -->

# 標準クラス

<!-- This section presents a variety of operators and functions that can be overloaded using type classes in Lean.
Each operator or function corresponds to a method of a type class.
Unlike C++, infix operators in Lean are defined as abbreviations for named functions; this means that overloading them for new types is not done using the operator itself, but rather using the underlying name (such as `HAdd.hAdd`). -->

この節では，Leanの型クラスを使ってオーバーロードできるさまざまな演算子や関数を紹介します．各演算子や関数は型クラスのメソッドに対応します．C++とは異なり，Leanの中置演算子は名前のある関数の省略形として定義されています：これの意味するところは，新しい型に対する演算子のオーバーロードは演算子そのものによる処理ではなく，その裏側にある名前（例えば `HAdd.hAdd` ）を使って行っているということです．

<!-- ## Arithmetic -->

## 算術演算

<!-- Most arithmetic operators are available in a heterogeneous form, where the arguments may have different type and an output parameter decides the type of the resulting expression.
For each heterogeneous operator, there is a corresponding homogeneous version that can found by removing the letter `h`, so that `HAdd.hAdd` becomes `Add.add`.
The following arithmetic operators are overloaded: -->

ほとんどの算術演算子は異なる型上の演算子として利用可能で，引数の型が異なる場合があり，また出力パラメータがその演算結果の型を決定します．各異なる型上の演算子それぞれに，型クラスとメソッドから `h` を取り除いた同じ型上の演算子が存在します．例えば `HAdd.hAdd` に対応するものとして，`Add.add` が定義されています．Leanでは以下の算術演算子がオーバーロードされています：

<!-- | Expression | Desugaring | Class Name | -->
| 式 | 脱糖後の式 | 型クラス名 |
|------------|------------|------------|
| `{{#example_in Examples/Classes.lean plusDesugar}}` | `{{#example_out Examples/Classes.lean plusDesugar}}` | `HAdd` |
| `{{#example_in Examples/Classes.lean minusDesugar}}` | `{{#example_out Examples/Classes.lean minusDesugar}}` | `HSub` |
| `{{#example_in Examples/Classes.lean timesDesugar}}` | `{{#example_out Examples/Classes.lean timesDesugar}}` | `HMul` |
| `{{#example_in Examples/Classes.lean divDesugar}}` | `{{#example_out Examples/Classes.lean divDesugar}}` | `HDiv` |
| `{{#example_in Examples/Classes.lean modDesugar}}` | `{{#example_out Examples/Classes.lean modDesugar}}` | `HMod` |
| `{{#example_in Examples/Classes.lean powDesugar}}` | `{{#example_out Examples/Classes.lean powDesugar}}` | `HPow` |
| `{{#example_in Examples/Classes.lean negDesugar}}` | `{{#example_out Examples/Classes.lean negDesugar}}` | `Neg` |


<!-- ## Bitwise Operators -->

## ビット演算子

<!-- Lean contains a number of standard bitwise operators that are overloaded using type classes.
There are instances for fixed-width types such as `{{#example_in Examples/Classes.lean UInt8}}`, `{{#example_in Examples/Classes.lean UInt16}}`, `{{#example_in Examples/Classes.lean UInt32}}`, `{{#example_in Examples/Classes.lean UInt64}}`, and `{{#example_in Examples/Classes.lean USize}}`.
The latter is the size of words on the current platform, typically 32 or 64 bits.
The following bitwise operators are overloaded: -->

Leanには型クラスを使用してオーバーロードされる標準のビット演算子がたくさんあります．例えば固定幅の型に対するインスタンスとして，`{{#example_in Examples/Classes.lean UInt8}}` や `{{#example_in Examples/Classes.lean UInt16}}` ，`{{#example_in Examples/Classes.lean UInt32}}` ，`{{#example_in Examples/Classes.lean UInt64}}` ，`{{#example_in Examples/Classes.lean USize}}` などがあります．最後のものは実行環境の1文字に対応するサイズで，通常は32ビットか64ビットです．以下のビット演算子がオーバーロードされています：

<!-- | Expression | Desugaring | Class Name | -->
| 式 | 脱糖後の式 | 型クラス名 |
|------------|------------|------------|
| `{{#example_in Examples/Classes.lean bAndDesugar}}` | `{{#example_out Examples/Classes.lean bAndDesugar}}` | `HAnd` |
| <code class="hljs">x &#x7c;&#x7c;&#x7c; y </code> | `{{#example_out Examples/Classes.lean bOrDesugar}}` | `HOr` |
| `{{#example_in Examples/Classes.lean bXorDesugar}}` | `{{#example_out Examples/Classes.lean bXorDesugar}}` | `HXor` |
| `{{#example_in Examples/Classes.lean complementDesugar}}` | `{{#example_out Examples/Classes.lean complementDesugar}}` | `Complement` |
| `{{#example_in Examples/Classes.lean shrDesugar}}` | `{{#example_out Examples/Classes.lean shrDesugar}}` | `HShiftRight` |
| `{{#example_in Examples/Classes.lean shlDesugar}}` | `{{#example_out Examples/Classes.lean shlDesugar}}` | `HShiftLeft` |

<!-- Because the names `And` and `Or` are already taken as the names of logical connectives, the homogeneous versions of `HAnd` and `HOr` are called `AndOp` and `OrOp` rather than `And` and `Or`. -->

同じ型上の演算子について，`And` と `Or` という名前は論理結合子としてもうすでに取られてしまっているため，同じ型上の演算子バージョンの `HAnd` と `HOr` はそれぞれ `AndOp` と `OrOp` と名付けられています．

<!-- ## Equality and Ordering -->

## 同値と順序

<!-- Testing equality of two values typically uses the `BEq` class, which is short for "Boolean equality".
Due to Lean's use as a theorem prover, there are really two kinds of equality operators in Lean: -->

2つの値の同値性を評価するには，通常 `BEq` クラスを使用します．これは「Boolan equality」の省略形です．Leanは定理証明器として使用されるため，Leanには2種類の同値演算子が存在します：

 <!-- * _Boolean equality_ is the same kind of equality that is found in other programming languages. It is a function that takes two values and returns a `Bool`. Boolean equality is written with two equals signs, just as in Python and C#. Because Lean is a pure functional language, there's no separate notions of reference vs value equality—pointers cannot be observed directly. -->
 * **真偽値の同値** （Boolean equality）は他のプログラミング言語にも存在する等号と同じです．これは2つの値を取り，`Bool` 値を返す関数です．PythonやC#と同じように，真偽値の同値は等号を2つ用いて書かれます．Leanは純粋な関数型言語であるため，参照の同値と値の同値という個別の概念はありません．ポインタの中身は直接見ることができません．
 <!-- * _Propositional equality_ is the mathematical statement that two things are equal. Propositional equality is not a function; rather, it is a mathematical statement that admits proof. It is written with a single equals sign. A statement of propositional equality is like a type that classifies evidence of this equality. -->
 * **命題の同値** （Propositional equality）は2つのものが等しいということの数学的な文です．命題の同値は関数ではありません；むしろ証明可能な数学的な文です．これは等号を1つ使って記述されます．命題の同値の文は，この等式の根拠を分類する型のようなものです．
 
<!-- Both notions of equality are important, and used for different purposes.
Boolean equality is useful in programs, when a decision needs to be made about whether two values are equal.
For example, `{{#example_in Examples/Classes.lean boolEqTrue}}` evaluates to `{{#example_out Examples/Classes.lean boolEqTrue}}`, and `{{#example_in Examples/Classes.lean boolEqFalse}}` evaluates to `{{#example_out Examples/Classes.lean boolEqFalse}}`.
Some values, such as functions, cannot be checked for equality.
For example, `{{#example_in Examples/Classes.lean functionEq}}` yields the error: -->

これらの等号の概念はどちらも重要であり，それぞれ異なる目的で用いられます．ある判断が2つの値が等しいかどうかということから構成される必要がある場合，そのプログラムでは真偽値の同値が有効です．例えば，`{{#example_in Examples/Classes.lean boolEqTrue}}` は `{{#example_out Examples/Classes.lean boolEqTrue}}` と評価され，`{{#example_in Examples/Classes.lean boolEqFalse}}` は `{{#example_out Examples/Classes.lean boolEqFalse}}` と評価されます．一方で関数のようないくつかの値については等しいかどうかのチェックができません．例えば `{{#example_in Examples/Classes.lean functionEq}}` は以下のエラーを出力します：

```output error
{{#example_out Examples/Classes.lean functionEq}}
```
<!-- As this message indicates, `==` is overloaded using a type class.
The expression `{{#example_in Examples/Classes.lean beqDesugar}}` is actually shorthand for `{{#example_out Examples/Classes.lean beqDesugar}}`. -->

このメッセージが示している通り，`==` は型クラスによるオーバーロードされた演算子です．そのため，式 `{{#example_in Examples/Classes.lean beqDesugar}}` は `{{#example_out Examples/Classes.lean beqDesugar}}` の省略形です．

<!-- Propositional equality is a mathematical statement rather than an invocation of a program.
Because propositions are like types that describe evidence for some statement, propositional equality has more in common with types like `String` and `Nat → List Int` than it does with Boolean equality.
This means that it can't automatically be checked.
However, the equality of any two expressions can be stated in Lean, so long as they have the same type.
The statement `{{#example_in Examples/Classes.lean functionEqProp}}` is a perfectly reasonable statement.
From the perspective of mathematics, two functions are equal if they map equal inputs to equal outputs, so this statement is even true, though it requires a two-line proof to convince Lean of this fact. -->

命題の同値は，プログラムの呼び出しではなく，数学的な文です．命題はある文の根拠を記述する型のようなものであるため，真偽値の同値よりも `String` や `Nat → List Int` などのような型との共通点が多いです．このため，この同値は自動的にチェックすることができません．しかし，2つの式の同値性は，その2つが同じ型である限りLeanで記述することはできます．したがって `{{#example_in Examples/Classes.lean functionEqProp}}` は文として完全に妥当に成立しています．数学の観点において，2つの関数が同値であるとは同じ入力から同じ出力に写す場合のことであるため，先ほどの文は真となります．にもかかわらずこの事実をLeanに納得させるためには2行の証明が必要になります．

<!-- Generally speaking, when using Lean as a programming language, it's easiest to stick to Boolean functions rather than propositions.
However, as the names `true` and `false` for `Bool`'s constructors suggest, this difference is sometimes blurred.
Some propositions are _decidable_, which means that they can be checked just like a Boolean function.
The function that checks whether the proposition is true or false is called a _decision procedure_, and it returns _evidence_ of the truth or falsity of the proposition.
Some examples of decidable propositions include equality and inequality of natural numbers, equality of strings, and "ands" and "ors" of propositions that are themselves decidable. -->

一般的に，Leanを定理証明ではなくプログラミング言語として用いる場合には命題よりも真偽値の関数に頼ることが一番簡単です．しかし，`Bool` のコンストラクタに `true` と `false` という名前が付けられているため，この違いは時として曖昧です．またいくつかの命題はブール関数と同じようにチェックすることができ，これを **決定可能** （decidable）と呼びます．命題が真か偽かをチェックする関数は **決定手続き** （decision procedure）と呼ばれ，命題の真偽の **根拠** を返します．決定可能な命題の例としては，自然数か文字列の等式と不等式，そしてそれ自体が決定可能な命題同士を「かつ」と「または」で組み合わせたものなどがあります．

<!-- In Lean, `if` works with decidable propositions.
For example, `2 < 4` is a proposition: -->

Leanでは，`if` は決定可能な命題と組み合わせることができます．例えば，`2 < 4` は以下のように命題になります：

```lean
{{#example_in Examples/Classes.lean twoLessFour}}
```
```output info
{{#example_out Examples/Classes.lean twoLessFour}}
```
<!-- Nonetheless, it is perfectly acceptable to write it as the condition in an `if`.
For example, `{{#example_in Examples/Classes.lean ifProp}}` has type `Nat` and evaluates to `{{#example_out Examples/Classes.lean ifProp}}`. -->

このように命題であるにもかかわらず，`if` の条件として用いても全く問題ありません．例えば，`{{#example_in Examples/Classes.lean ifProp}}` は `Nat` 型を持ち，`{{#example_out Examples/Classes.lean ifProp}}` と評価されます．

<!-- Not all propositions are decidable.
If they were, then computers would be able to prove any true proposition just by running the decision procedure, and mathematicians would be out of a job.
More specifically, decidable propositions have an instance of the `Decidable` type class which has a method that is the decision procedure.
Trying to use a proposition that isn't decidable as if it were a `Bool` results in a failure to find the `Decidable` instance.
For example, `{{#example_in Examples/Classes.lean funEqDec}}` results in: -->

すべての命題が決定可能ではありません．仮にそうだとすると，コンピュータは決定手続きを実行するだけでどんな真である命題でも証明できることとなり，数学者は失業してしまうでしょう．より具体的に言うと，決定可能な命題はメソッドとして決定手続きを有する `Decidable` 型クラスのインスタンスを持っています．決定可能でない命題を `Bool` のように使おうとすると，`Decidable` のインスタンスの検索に失敗してしまいます．例えば，`{{#example_in Examples/Classes.lean funEqDec}}` の結果は次のようになります：

```output error
{{#example_out Examples/Classes.lean funEqDec}}
```

<!-- The following propositions, that are usually decidable, are overloaded with type classes: -->

以下の命題（通常は決定可能である）はそれぞれ下記の型クラスでオーバーロードされています：

<!-- | Expression | Desugaring | Class Name | -->
| 式 | 脱糖後の式 | 型クラス名 |
|------------|------------|------------|
| `{{#example_in Examples/Classes.lean ltDesugar}}` | `{{#example_out Examples/Classes.lean ltDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean leDesugar}}` | `{{#example_out Examples/Classes.lean leDesugar}}` | `LE` |
| `{{#example_in Examples/Classes.lean gtDesugar}}` | `{{#example_out Examples/Classes.lean gtDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean geDesugar}}` | `{{#example_out Examples/Classes.lean geDesugar}}` | `LE` |

<!-- Because defining new propositions hasn't yet been demonstrated, it may be difficult to define new instances of `LT` and `LE`. -->

新しい命題の定義の仕方についてはまだ披露していないため，`LT` と `LE` の新しいインスタンスを定義するのは難しいかもしれません．

<!-- Additionally, comparing values using `<`, `==`, and `>` can be inefficient.
Checking first whether one value is less than another, and then whether they are equal, can require two traversals over large data structures.
To solve this problem, Java and C# have standard `compareTo` and `CompareTo` methods (respectively) that can be overridden by a class in order to implement all three operations at the same time.
These methods return a negative integer if the receiver is less than the argument, zero if they are equal, and a positive integer if the receiver is greater than the argument.
Rather than overload the meaning of integers, Lean has a built-in inductive type that describes these three possibilities: -->

ところで，`<` と `==` ，`>`を使った値の比較は効率的ではありません．ある値が別の値未満かどうかをチェックし，次にそれらが等しいかどうかのチェックをするとなると，同じデータ全体を2回走査する必要があり，大きなデータ構造では時間がかかってしまいます．この問題を解決するために，JavaとC#には標準でそれぞれ `compareTo` と `CompareTo` メソッドがあり，これをクラスでオーバーライドすることで，3つの操作を同時に実装することができます．これらのメソッドは，受け取るオブジェクトが引数未満の場合は負の整数を返し，等しい場合は0を返し，引数より大きい場合は正の整数を返します．Leanではこのように整数を使った手法のオーバーロードではなく，これら3つのケースを記述する組み込みの帰納型を持っています：

```lean
{{#example_decl Examples/Classes.lean Ordering}}
```
<!-- The `Ord` type class can be overloaded to produce these comparisons.
For `Pos`, an implementation can be: -->

`Ord` 型クラスをオーバーロードすることでこれらの比較を実現できます．`Pos` に対して，インスタンスの実装は以下のように書けます：

```lean
{{#example_decl Examples/Classes.lean OrdPos}}
```
<!-- In situations where `compareTo` would be the right approach in Java, use `Ord.compare` in Lean. -->

Leanにおいて，Javaでの `compareTo` のアプローチが有効であるようなシチュエーションでは，`Ord.compare` を使いましょう．

<!-- ## Hashing -->

## ハッシュ化

<!-- Java and C# have `hashCode` and `GetHashCode` methods, respectively, that compute a hash of a value for use in data structures such as hash tables.
The Lean equivalent is a type class called `Hashable`: -->

JavaとC#ではそれぞれ `hashCode` と `GetHashCode` メソッドを有しており，ハッシュテーブルのようなデータ構造で使用する値のハッシュを計算します．Leanにおいて `Hashale` 型クラスがこれに相当します：

```lean
{{#example_decl Examples/Classes.lean Hashable}}
```
<!-- If two values are considered equal according to a `BEq` instance for their type, then they should have the same hashes.
In other words, if `x == y` then `hash x == hash y`.
If `x ≠ y`, then `hash x` won't necessarily differ from `hash y` (after all, there are infinitely more `Nat` values than there are `UInt64` values), but data structures built on hashing will have better performance if unequal values are likely to have unequal hashes.
This is the same expectation as in Java and C#. -->

もし2つの値がその型の `BEq` インスタンスのもとで等しいとみなされるなら，それらは同じハッシュを持つべきです．言い換えると，もし `x == y` ならば，`hash x == hash y` となります．もし `x ≠ y` ならば，`hash x` と `hash y` は必ずしも異なるとは限りません（というのも，`UInt64` に属する値の数よりも `Nat` の方が無限に多いためです）が，ハッシュで構築されたデータ構造は等しくない値が等しくないハッシュを持つ可能性が高い方がパフォーマンスが向上します．このような期待はJavaやC#でも同様です．

<!-- The standard library contains a function `{{#example_in Examples/Classes.lean mixHash}}` with type `{{#example_out Examples/Classes.lean mixHash}}` that can be used to combine hashes for different fields for a constructor.
A reasonable hash function for an inductive datatype can be written by assigning a unique number to each constructor, and then mixing that number with the hashes of each field.
For example, a `Hashable` instance for `Pos` can be written: -->

標準ライブラリには `{{#example_out Examples/Classes.lean mixHash}}` 型の関数 `{{#example_in Examples/Classes.lean mixHash}}` があり，コンストラクタの異なるフィールドのハッシュを結合するために使用できます．各コンストラクタに一意な番号を割り当て，その番号と各フィールドのハッシュを融合することで，帰納的なデータ型のための合理的なハッシュ関数を書くことができます．例えば，`Pos` に対する `Hashable` インスタンスは次のように書けます：

```lean
{{#example_decl Examples/Classes.lean HashablePos}}
```
<!-- `Hashable` instances for polymorphic types can use recursive instance search.
Hashing a `NonEmptyList α` is only possible when `α` can be hashed: -->

多相型に対する `Hashable` インスタンスは再帰的なインスタンス検索が可能です．`NonEmptyList α` のハッシュ化は `α` がハッシュ化できる場合にのみ可能です：

```lean
{{#example_decl Examples/Classes.lean HashableNonEmptyList}}
```
Binary trees use both recursion and recursive instance search in the implementations of `BEq` and `Hashable`:

二分木は再帰と `BEq` と `Hashable` の実装に対するインスタンスの再帰的な検索の両方を利用します：

```lean
{{#example_decl Examples/Classes.lean TreeHash}}
```


<!-- ## Deriving Standard Classes -->

## 標準の型クラスの自動的な導出

<!-- Instance of classes like `BEq` and `Hashable` are often quite tedious to implement by hand.
Lean includes a feature called _instance deriving_ that allows the compiler to automatically construct well-behaved instances of many type classes.
In fact, the `deriving Repr` phrase in the definition of `Point` in the [section on structures](../getting-to-know/structures.md) is an example of instance deriving. -->

`BEq` や `Hashable` のようなクラスのインスタンスを手作業で実装するのは非常に面倒です．Leanには **インスタンス導出** （instance deriving）と呼ばれる機能があり，コンパイラが自動的に多くの型クラスに対して行儀のよい（well-behaved）インスタンスを構築することができます．実は，[構造体の節](../getting-to-know/structures.md) の `Point` の定義にある `deriving Repr` というフレーズはインスタンス導出の一例です．

<!-- Instances can be derived in two ways.
The first can be used when defining a structure or inductive type.
In this case, add `deriving` to the end of the type declaration followed by the names of the classes for which instances should be derived.
For a type that is already defined, a standalone `deriving` command can be used.
Write `deriving instance C1, C2, ... for T` to derive instances of `C1, C2, ...` for the type `T` after the fact. -->

インスタンスは2つの方法で導出することができます．1つ目は構造体や帰納型を定義する時です．この場合，型宣言の最後に `deriving` を追加し，その後にインスタンスを導出させるクラスの名前を追加します．すでに定義されている型の場合は，単独の `deriving` コマンドを使用することができます．`deriving instance C1, C2, ... for T` と書くことで，`T` 型に対して `C1, C2, ...` のインスタンスを後から導出させることができます．

<!-- `BEq` and `Hashable` instances can be derived for `Pos` and `NonEmptyList` using a very small amount of code: -->

`Pos` と `NonEmptyList` に対しての `BEq` と `Hashable` のインスタンスは非常に少ないコード量で導出することができます：

```lean
{{#example_decl Examples/Classes.lean BEqHashableDerive}}
```

<!-- Instances can be derived for at least the following classes: -->

このほか，例えば以下のクラスに対してもインスタンスの導出が可能です：
 * `Inhabited`
 * `BEq`
 * `Repr`
 * `Hashable`
 * `Ord`

<!-- In some cases, however, the derived `Ord` instance may not produce precisely the ordering desired in an application.
When this is the case, it's fine to write an `Ord` instance by hand.
The collection of classes for which instances can be derived can be extended by advanced users of Lean. -->

しかし場合によっては，`Ord` インスタンスの導出がアプリケーションで必要とされる順序とならないことがあります．このような場合では，手作業で `Ord` インスタンスを書いても問題はありません．インスタンスを導出させることができるクラスのコレクションの拡張はLeanに精通したユーザでないと難しいでしょう．

<!-- Aside from the clear advantages in programmer productivity and code readability, deriving instances also makes code easier to maintain, because the instances are updated as the definitions of types evolve.
Changesets involving updates to datatypes are easier to read without line after line of formulaic modifications to equality tests and hash computation. -->

プログラマの生産性とコードの可読性という明確な利点のほかに，インスタンスの導出はコードの保守を容易にします．なぜなら導出されたインスタンスは型の定義に付随して更新されるからです．データ型の更新を伴う変更セットは，同値テストやハッシュ計算について各行ごとに形式的な修正をいちいちする必要がなく，読みやすくなります．

<!-- ## Appending -->

## 結合

<!-- Many datatypes have some sort of append operator.
In Lean, appending two values is overloaded with the type class `HAppend`, which is a heterogeneous operation like that used for arithmetic operations: -->

多くのデータ型には，ある種のデータの結合のための演算子があります．Leanにおいて2つの値の結合は `HAppend` という型クラスでオーバーロードされます．これは算術演算に使われるような異なる型上の演算です：

```lean
{{#example_decl Examples/Classes.lean HAppend}}
```
<!-- The syntax `{{#example_in Examples/Classes.lean desugarHAppend}}` desugars to `{{#example_out Examples/Classes.lean desugarHAppend}}`.
For homogeneous cases, it's enough to implement an instance of `Append`, which follows the usual pattern: -->

構文 `{{#example_in Examples/Classes.lean desugarHAppend}}` は `{{#example_out Examples/Classes.lean desugarHAppend}}` と脱糖されます．同じ型上のケースにおいては，下記のような通常のパターンに従った `Append` のインスタンスを実装するだけで充分です：

```lean
{{#example_decl Examples/Classes.lean AppendNEList}}
```

<!-- After defining the above instance, -->

上記のインスタンスを定義することで：

```lean
{{#example_in Examples/Classes.lean appendSpiders}}
```
<!-- has the following output: -->

は以下の出力になります：

```output info
{{#example_out Examples/Classes.lean appendSpiders}}
```

<!-- Similarly, a definition of `HAppend` allows non-empty lists to be appended to ordinary lists: -->

同様に，`HAppend` の定義によって，空でないリストを普通にリストに追加することができます：

```lean
{{#example_decl Examples/Classes.lean AppendNEListList}}
```
<!-- With this instance available, -->

このインスタンスによって以下が可能になり，

```lean
{{#example_in Examples/Classes.lean appendSpidersList}}
```
<!-- results in -->

以下の出力になります．

```output info
{{#example_out Examples/Classes.lean appendSpidersList}}
```

<!-- ## Functors -->

## 関手

<!-- A polymorphic type is a _functor_ if it has an overload for a function named `map` that transforms every element contained in it by a function.
While most languages use this terminology, C#'s equivalent to `map` is called `System.Linq.Enumerable.Select`.
For example, mapping a function over a list constructs a new list in which each entry from the starting list has been replaced by the result of the function on that entry.
Mapping a function `f` over an `Option` leaves `none` untouched, and replaces `some x` with `some (f x)`. -->

多相型 **関手** （functor）とは，その型に格納されているすべての要素を何かしらの関数で変換する `map` という名前の関数のオーバーロードを持ちます．ほとんどの言語でこの用語が使われており，例えばC#では `System.Linq.Enumerable.Select` と呼ばれるものがこの `map` に相当します．例えば，関数 `f` をリスト全体にマッピングすると，入力のリストの各要素がその関数の結果で置き換えられた新しいリストが作成されます．関数 `f` を `Option` にマッピングすると，`none` はそのままにし，`some x` を `some (f x)` に置き換えます．

<!-- Here are some examples of functors and how their `Functor` instances overload `map`: -->

以下が関手の例と，`Functor` インスタンスが `map` をどのようにオーバーロードしているかの例です：

 <!-- * `{{#example_in Examples/Classes.lean mapList}}` evaluates to `{{#example_out Examples/Classes.lean mapList}}` -->
 * `{{#example_in Examples/Classes.lean mapList}}` の評価は `{{#example_out Examples/Classes.lean mapList}}`
 <!-- * `{{#example_in Examples/Classes.lean mapOption}}` evaluates to `{{#example_out Examples/Classes.lean mapOption}}` -->
 * `{{#example_in Examples/Classes.lean mapOption}}` の評価は `{{#example_out Examples/Classes.lean mapOption}}`
 <!-- * `{{#example_in Examples/Classes.lean mapListList}}` evaluates to `{{#example_out Examples/Classes.lean mapListList}}` -->
 * `{{#example_in Examples/Classes.lean mapListList}}` の評価は `{{#example_out Examples/Classes.lean mapListList}}`

<!-- Because `Functor.map` is a bit of a long name for this common operation, Lean also provides an infix operator for mapping a function, namely `<$>`.
The prior examples can be rewritten as follows: -->

このような一般的な演算に対して `Functor.map` という名前は少々長いため，Leanは関数をマッピングするための中置演算子を提供しており， `<$>` と書かれます．これにより先ほどの例は次のように書き換えることができます：

 <!-- * `{{#example_in Examples/Classes.lean mapInfixList}}` evaluates to `{{#example_out Examples/Classes.lean mapInfixList}}` -->
 * `{{#example_in Examples/Classes.lean mapInfixList}}` の評価は `{{#example_out Examples/Classes.lean mapInfixList}}`
 <!-- * `{{#example_in Examples/Classes.lean mapInfixOption}}` evaluates to `{{#example_out Examples/Classes.lean mapInfixOption}}` -->
 * `{{#example_in Examples/Classes.lean mapInfixOption}}` の評価は `{{#example_out Examples/Classes.lean mapInfixOption}}`
 <!-- * `{{#example_in Examples/Classes.lean mapInfixListList}}` evaluates to `{{#example_out Examples/Classes.lean mapInfixListList}}` -->
 * `{{#example_in Examples/Classes.lean mapInfixListList}}` の評価は `{{#example_out Examples/Classes.lean mapInfixListList}}`

An instance of `Functor` for `NonEmptyList` requires specifying the `map` function.

`NonEmptyList` に対する `Functor` のインスタンスは `map` 関数の設定を必要とします．

```lean
{{#example_decl Examples/Classes.lean FunctorNonEmptyList}}
```
<!-- Here, `map` uses the `Functor` instance for `List` to map the function over the tail.
This instance is defined for `NonEmptyList` rather than for `NonEmptyList α` because the argument type `α` plays no role in resolving the type class.
A `NonEmptyList` can have a function mapped over it _no matter what the type of entries is_.
If `α` were a parameter to the class, then it would be possible to make versions of `Functor` that only worked for `NonEmptyList Nat`, but part of being a functor is that `map` works for any entry type. -->

ここで，後続のリストに対しては `List` に対する `Functor` インスタンスの `map` を使用してマッピングしています．このインスタンスは `NonEmptyList α` ではなく `NonEmptyList` に対して定義されています．というのも，引数の型として `α` はこの型クラスの構成に何の関与もないからです．`NonEmptyList` は要素の型が何であろうと，関数をマッピングすることができます．もし `α` がクラスのパラメータであれば，`NonEmptyList Nat` に対してのみ動作する `Functor` のバージョンを作ることは可能ですが，`map` がどのような要素の型に対しても動作するという性質は関手であることの一部になっています．

<!-- Here is an instance of `Functor` for `PPoint`: -->

以下が `PPoint` に対する `Functor` のインスタンスです：

```lean
{{#example_decl Examples/Classes.lean FunctorPPoint}}
```
<!-- In this case, `f` has been applied to both `x` and `y`. -->

このケースにおいて，`f` は `x` と `y` の両方に適用されます．

<!-- Even when the type contained in a functor is itself a functor, mapping a function only goes down one layer.
That is, when using `map` on a `NonEmptyList (PPoint Nat)`, the function being mapped should take `PPoint Nat` as its argument rather than `Nat`. -->

関手に含まれる型自体が関手である場合でも，関数のマッピングは1つ下の階層にしか行きません．つまり，`NonEmptyList (PPoint Nat)` に対して `map` を使用する場合，マッピングされる関数は `Nat` ではなく `PPoint Nat` を引数に取る必要があります．

<!-- The definition of the `Functor` class uses one more language feature that has not yet been discussed: default method definitions.
Normally, a class will specify some minimal set of overloadable operations that make sense together, and then use polymorphic functions with instance implicit arguments that build on the overloaded operations to provide a larger library of features.
For example, the function `concat` can concatenate any non-empty list whose entries are appendable: -->

`Functor` クラスの定義では，まだ紹介していないもう一つの言語機能である，デフォルトのメソッド定義を使用しています．通常，クラスは相互に関連するようなオーバーロード可能な演算の最小セットを指定し，より大きな機能のライブラリを提供するために，インスタンスの暗黙引数を持つ多相関数を使用します．例えば，関数 `concat` は要素が追加可能な空でないリストを連結することができます：

```lean
{{#example_decl Examples/Classes.lean concat}}
```
<!-- However, for some classes, there are operations that can be more efficiently implemented with knowledge of the internals of a datatype. -->

しかし，クラスによってはデータ型の内部を知っていた方が効率的に実装できるような演算も存在します．

<!-- In these cases, a default method definition can be provided.
A default method definition provides a default implementation of a method in terms of the other methods.
However, instance implementors may choose to override this default with something more efficient.
Default method definitions contain `:=` in a `class` definition. -->

このような場合，デフォルトのメソッド定義を提供することができます．デフォルトのメソッド定義は，ほかのメソッドから見たメソッドのデフォルトの実装を提供します．しかし，インスタンスを実装する際には，このデフォルト実装より効率的なものがあれば，それを用いてオーバーライドすることもできます．デフォルトのメソッド定義は `class` 定義の中で `:=` を用いて行われます．

<!-- In the case of `Functor`, some types have a more efficient way of implementing `map` when the function being mapped ignores its argument.
Functions that ignore their arguments are called _constant functions_ because they always return the same value.
Here is the definition of `Functor`, in which `mapConst` has a default implementation: -->

`Functor` の場合，マッピングされる関数が引数を無視する時，より効率的な `map` の実装方法を持つ型があります．引数を無視する関数は常に同じ値を返すので， **定数関数** （constant function）と呼ばれます．以下は `mapConst` がデフォルトで実装されている `Functor` の定義です：

```lean
{{#example_decl Examples/Classes.lean FunctorDef}}
```

<!-- Just as a `Hashable` instance that doesn't respect `BEq` is buggy, a `Functor` instance that moves around the data as it maps the function is also buggy.
For example, a buggy `Functor` instance for `List` might throw away its argument and always return the empty list, or it might reverse the list.
A bad instance for `PPoint` might place `f x` in both the `x` and the `y` fields.
Specifically, `Functor` instances should follow two rules: -->

`BEq` を考慮しない `Hashable` インスタンスがバグをはらむように，関数をマッピングする際にデータを移動する `Functor` インスタンスもバグを生みます．例えば，`List` に対するバグを含む `Functor` インスタンスは，引数を捨てて常にリストを返したり，リストを反転させたりするものなどです．また，`PPoint` のまずいインスタンスは `x` と `y` の両方のフィールドに `f x` を置いたりするものもあるでしょう．具体的には，`Functor` インスタンスは次の2つのルールに従う必要があります：

 <!-- 1. Mapping the identity function should result in the original argument. -->
 1. 恒等関数のマッピングはもともとの引数をそのまま返さなければならない．
 <!-- 2. Mapping two composed functions should have the same effect as composing their mapping. -->
 2. 2つの関数を合成した関数のマッピングはそれぞれをマッピングしたものを合成したものと同じ作用を持たなければならない．

<!-- More formally, the first rule says that `id <$> x` equals `x`.
The second rule says that `map (fun y => f (g y)) x` equals `map f (map g x)`.
The composition `{{#example_out Examples/Classes.lean compDef}}` can also be written `{{#example_in Examples/Classes.lean compDef}}`.
These rules prevent implementations of `map` that move the data around or delete some of it. -->

より正式には，最初のルールは `id <$> x` が `x` に等しいことを指します．2番目のルールは `map (fun y => f (g y)) x` が `map f (map g x)` に等しいことを述べています．合成 `{{#example_out Examples/Classes.lean compDef}}` は `{{#example_in Examples/Classes.lean compDef}}` とも書くことができます．これらのルールは `map` の実装がデータを移動したり，一部を削除したりしてしまうことを防ぎます．

<!-- ## Messages You May Meet -->

## 見るかもしれないメッセージ

<!-- Lean is not able to derive instances for all classes.
For example, the code -->

Leanはすべてのクラスのインスタンスを導出させることはできません．例えば，次のコードは

```lean
{{#example_in Examples/Classes.lean derivingNotFound}}
```
<!-- results in the following error: -->

以下のエラーを引き起こします：

```output error
{{#example_out Examples/Classes.lean derivingNotFound}}
```
<!-- Invoking `deriving instance` causes Lean to consult an internal table of code generators for type class instances.
If the code generator is found, then it is invoked on the provided type to create the instance.
This message, however, means that no code generator was found for `ToString`. -->

`deriving instance` を呼び出すと，Leanは型クラスのインスタンスに対するコードジェネレータの内部テーブルを参照します．もし対応するコードジェネレータが見つかれば，インスタンスを生成するために指定された型に対してそのコードジェネレータが呼び出されます．しかし，このメッセージは `ToString` のコードジェネレータが見つからなかったことを意味します．

<!-- ## Exercises -->

## 演習問題

 <!-- * Write an instance of `HAppend (List α) (NonEmptyList α) (NonEmptyList α)` and test it. -->
 * `HAppend (List α) (NonEmptyList α) (NonEmptyList α)` のインスタンスを記述し，動作を確認してください．
 <!-- * Implement a `Functor` instance for the binary tree datatype. -->
 * 二分木のデータ型に対して `Functor` インスタンスを実装してください．
