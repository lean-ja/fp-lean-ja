<!--
# Summary
-->

# まとめ

<!--
## Dependent Types
-->

## 依存型

<!--
Dependent types, where types contain non-type code such as function calls and ordinary data constructors, lead to a massive increase in the expressive power of a type system.
The ability to _compute_ a type from the _value_ of an argument means that the return type of a function can vary based on which argument is provided.
This can be used, for example, to have the result type of a database query depend on the database's schema and the specific query issued, without needing any potentially-failing cast operations on the result of the query.
When the query changes, so does the type that results from running it, enabling immediate compile-time feedback.
-->

依存型とは型が関数呼び出しや通常のデータコンストラクタのような型ではないコードを含むものであり、型システムの表現力を飛躍的に高めてくれます。引数の **値** から型を **計算** できるということは、関数の戻り値の型を引数の値によって変えることができるということです。これは例えば、データベースのクエリの結果の型を、潜在的に失敗するかもしれないキャスト操作などの必要無しに、データベースのスキーマと発行された特定のクエリに依存させるために使用することができます。クエリが変更されると、それを実行した結果の型も変更されるため、コンパイル時に即座にフィードバックを得ることができます。

<!--
When a function's return type depends on a value, analyzing the value with pattern matching can result in the type being _refined_, as a variable that stands for a value is replaced by the constructors in the pattern.
The type signature of a function documents the way that the return type depends on the argument value, and pattern matching then explains how the return type can be fulfilled for each potential argument.
-->

関数の戻り値の型が値に依存する場合、パターンマッチで値を分析すると、値を表す変数がパターン内のコンストラクタで置き換えられるため型が **絞り込まれる** ことがあります。関数の型シグネチャは戻り値の型が引数の値に依存する方法を文書化したものであり、パターンマッチは戻り値の型が各引数の可能性に対してどのように満たされるかを説明するものです。

<!--
Ordinary code that occurs in types is run during type checking, though `partial` functions that might loop infinitely are not called.
Mostly, this computation follows the rules of ordinary evaluation that were introduced in [the very beginning of this book](../getting-to-know/evaluating.md), with expressions being progressively replaced by their values until a final value is found.
Computation during type checking has an important difference from run-time computation: some values in types may be _variables_ whose values are not yet known.
In these cases, pattern-matching gets "stuck" and does not proceed until or unless a particular constructor is selected, e.g. by pattern matching.
Type-level computation can be seen as a kind of partial evaluation, where only the parts of the program that are sufficiently known need to be evaluated and other parts are left alone.
-->

型の中で発生する通常のコードは型チェック中に実行されますが、無限にループする可能性のある `partial` 関数は呼び出されません。ほとんどの場合、この計算は [本書の冒頭](../getting-to-know/evaluating.md) で紹介した通常の評価のルールに従い、最終的な値が見つかるまで式は逐次値を置き換えられていきます。型チェック中の計算には実行時の計算と異なる重要な点があります：型の中のいくつかの値はその時点では値がわからない **変数** である場合があります。このような場合、パターンマッチは「詰まり」、例えばパターンマッチによって特定のコンストラクタが選択されるまで、あるいは選択されない限り処理を続行しません。型レベルの計算は一種の部分評価と見なすことができ、プログラム中の十分既知の部分だけが評価され、それ以外の部分は放置されます。

<!--
## The Universe Pattern
-->

## ユニバースパターン

<!--
A common pattern when working with dependent types is to section off some subset of the type system.
For example, a database query library might be able to return varying-length strings, fixed-length strings, or numbers in certain ranges, but it will never return a function, a user-defined datatype, or an `IO` action.
A domain-specific subset of the type system can be defined by first defining a datatype with constructors that match the structure of the desired types, and then defining a function that interprets values from this datatype into honest-to-goodness types.
The constructors are referred to as _codes_ for the types in question, and the entire pattern is sometimes referred to as a _universe à la Tarski_, or just as a _universe_ when context makes it clear that universes such as `Type 3` or `Prop` are not what's meant.
-->

依存型を使う際によくあるパターンは、型システムのサブセットを切り出すことです。例えば、データベースのクエリライブラリは可変長の文字列や固定長の文字列、特定の範囲の数値を返すかもしれませんが、関数やユーザ定義のデータ型、`IO` アクションなどは決して返しません。型システムのドメイン固有のサブセットの定義は、まず希望する型の構造にマッチするコンストラクタを持つデータ型を定義し、次にこのデータ型からの値を正真正銘の型に解釈する関数を定義することで行えます。コンストラクタは問題の対象の型の **コード** と呼ばれ、パターン全体は **Tarski流ユニバース** と呼ばれたり、文脈から `Type 3` や `Prop` のような宇宙を意味するものではないことが明らかな場合は単に **ユニバース** と呼ばれたりします。

<!--
Custom universes are an alternative to defining a type class with instances for each type of interest.
Type classes are extensible, but extensibility is not always desired.
Defining a custom universe has a number of advantages over using the types directly:
-->

カスタムのユニバースは関心のあるタイプごとにインスタンスを持つ型クラスを定義することの代替手段です。型クラスは拡張可能ですが、拡張性が常に望まれるとは限りません。カスタムユニバースを定義すると、型を直接扱うよりも多くの利点があります：

 <!--
 * Generic operations that work for _any_ type in the universe, such as equality testing and serialization, can be implemented by recursion on codes.
 -->
 * 等値性の検査や直列化など、宇宙の **あらゆる** 型に対して機能する汎用的な操作はコードの再帰によって実装することができます。
 <!--
 * The types accepted by external systems can be represented precisely, and the definition of the code datatype serves to document what can be expected.
 -->
 * 外部システムが受け入れる型を正確に表現することができ、コードによるデータ型の定義は何が期待されるかを文書化する役割を果たします。
 <!--
 * Lean's pattern matching completeness checker ensures that no codes are forgotten, while solutions based on type classes defer missing instance errors to client code.
 -->
 * Leanのパターンマッチの完全性についてのチェッカはコードの取り忘れがないことを保証しますが、一方で型クラスによる解決策ではインスタンスが無いことによるエラーはクライアントコードに先送りにされます。


<!--
## Indexed Families
-->

## 添字族

<!--
Datatypes can take two separate kinds of arguments: _parameters_ are identical in each constructor of the datatype, while _indices_ may vary between constructors.
For a given choice of index, only some constructors of the datatype are available.
As an example, `Vect.nil` is available only when the length index is `0`, and `Vect.cons` is available only when the length index is `n+1` for some `n`.
While parameters are typically written as named arguments before the colon in a datatype declaration, and indices as arguments in a function type after the colon, Lean can infer when an argument after the colon is used as a parameter.
-->

データ型は2種類の異なる引数を取ることができます：**パラメータ** はデータ型の各コンストラクタで同一の値ですが、**添字** はそれぞれのコンストラクタで異なる場合があります。与えられた添字の選択によって、データ型のコンストラクタの中で利用可能なものが限定されます。例として、`Vect.nil` は長さの添字が `0` の場合にのみ利用可能であり、`Vect.cons` は長さの添字が `n` に対して `n + 1` の場合にのみ利用可能です。通常、パラメータはデータ宣言のコロンの前に名前付き引数として記述され、添字はコロンの後に関数型の引き数として記述されますが、Leanはコロンの後にある引数がパラメータとして使用されるケースを推測することができます。

<!--
Indexed families allow the expression of complicated relationships between data, all checked by the compiler.
The datatype's invariants can be encoded directly, and there is no way to violate them, not even temporarily.
Informing the compiler about the datatype's invariants brings a major benefit: the compiler can now inform the programmer about what must be done to satisfy them.
The strategic use of compile-time errors, especially those resulting from underscores, can make it possible to offload some of the programming thought process to Lean, freeing up the programmer's mind to worry about other things.
-->

添字族によってデータ間の複雑な関係を式にすることができ、すべてコンパイラによってチェックされます。データ型の不変量は直接エンコードすることができ、一時的であってもそれを変更することはできません。コンパイラがデータ型の不変量を知ることには大きな利点があります：コンパイラはプログラマにそれらを満たすために何をすべきかを知らせることができるようになります。コンパイル時のエラー、特にアンダースコアに起因するエラーを戦略的に利用することで、プログラミングの思考プロセスの一部をLeanに委ねることが可能になり、プログラマはほかのことに気を配ることができるようになります。

<!--
Encoding invariants using indexed families can lead to difficulties.
First off, each invariant requires its own datatype, which then requires its own support libraries.
`List.append` and `Vect.append` are not interchangeable, after all.
This can lead to code duplication.
Secondly, convenient use of indexed families requires that the recursive structure of functions used in types match the recursive structure of the programs being type checked.
Programming with indexed families is the art of arranging for the right coincidences to occur.
While it's possible to work around missing coincidences with appeals to equality proofs, it is difficult, and it leads to programs littered with cryptic justifications.
Thirdly, running complicated code on large values during type checking can lead to compile-time slowdowns.
Avoiding these slowdowns for complicated programs can require specialized techniques.
-->

添字族を使って不変量をエンコードすると困難が生じる可能性があります。まず、それぞれの不変量は独自のデータ型を必要とし、そのデータ型は独自のサポートのためのライブラリを必要とします。つまるところ、`List.append` と `Vect.append` は互換性が無いということです。これはコードの重複につながります。第二に、添字族を便利に使用するには、型の中で使用される関数の再帰構造が型チェックされるプログラムの再帰構造と一致する必要があります。添字族によるプログラミングはこのように適切な一致を起こせるように手配する技術なのです。一致のミスの回避のために等式の証明に訴えることは可能ですが、これは難しく、難解な正当化がちりばめられたプログラムとなってしまいます。第三に、型チェック中に大きな値に対して複雑なコードを実行すると、コンパイル時の速度低下を招く可能性があります。複雑なプログラムでこのような速度低下を避けるには特殊なテクニックが必要になります。

<!--
## Definitional and Propositional Equality
-->

## 定義上と命題の同値

<!--
Lean's type checker must, from time to time, check whether two types should be considered interchangeable.
Because types can contain arbitrary programs, it must therefore be able to check arbitrary programs for equality.
However, there is no efficient algorithm to check arbitrary programs for fully-general mathematical equality.
To work around this, Lean contains two notions of equality:
-->

Leanの型チェッカは2つの型が交換可能かどうかを、時々ではありますがチェックしなければなりません。型は任意のプログラムを含むことができるため、型チェッカは任意のプログラムの同値性をチェックできなければなりません。しかし、任意のプログラムについて完全に一般的な数学的な同値をチェックする効率的なアルゴリズムは存在しません。これを回避するために、Leanは2つの同値の概念を含んでいます：

 <!--
 * _Definitional equality_ is an underapproximation of equality that essentially checks for equality of syntactic representation modulo computation and renaming of bound variables. Lean automatically checks for definitional equality in situations where it is required.
 -->

 * **定義上の同値** とは、同値性の下位の近似であり、基本的にはモジュロ計算と束縛変数の名前の変更の構文表現の同値性をチェックします。Leanは定義上の同値が必要とされる状況では、自動的に定義上の同値をチェックします。

 <!--
 * _Propositional equality_ must be explicitly proved and explicitly invoked by the programmer. In return, Lean automatically checks that the proofs are valid and that the invocations accomplish the right goal.
 -->

 * **命題の同値** はプログラマによって明示的に証明され、明示的に呼び出されなければなりません。その見返りとして、Leanは証明が有効であること、そして呼び出しが正しいゴールを達成することを自動的にチェックします。

<!--
The two notions of equality represent a division of labor between programmers and Lean itself.
Definitional equality is simple, but automatic, while propositional equality is manual, but expressive.
Propositional equality can be used to unstick otherwise-stuck programs in types.
-->

この2つの同値の概念はプログラマとLean自身の間の分業を表しています。定義上の同値は単純ですが自動的であり、命題の同値は手動ですが、表現力豊かです。命題の同値は型にはまり込んだプログラムを解きほぐすことに使えます。

<!--
However, the frequent use of propositional equality to unstick type-level computation is typically a code smell.
It typically means that coincidences were not well-engineered, and it's usually a better idea to either redesign the types and indices or to use a different technique to enforce the needed invariants.
When propositional equality is instead used to prove that a program meets a specification, or as part of a subtype, there is less reason to be suspicious.
-->

しかし、型レベルの計算を解くために命題の同値を多用することは一般的にコードの臭いとなります。これは通常、型の一致がうまく設計されていないことを意味し、型と添字を再設計するか、必要な不変量を強制するために別のテクニックを使用する方が良い考えです。命題の同値がプログラムの仕様を満たしていることを証明するためであったり、部分型の一部として使われる分には違和感はあまりありません。
