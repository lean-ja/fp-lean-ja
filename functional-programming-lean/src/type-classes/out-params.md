<!--
# Controlling Instance Search
-->

# インスタンス探索の制御

<!--
An instance of the `Add` class is sufficient to allow two expressions with type `Pos` to be conveniently added, producing another `Pos`.
However, in many cases, it can be useful to be more flexible and allow _heterogeneous_ operator overloading, where the arguments may have different types.
For example, adding a `Nat` to a `Pos` or a `Pos` to a `Nat` will always yield a `Pos`:
-->

`Add` クラスのインスタンスは，2つの `Pos` 型の式を足して新たな `Pos` の生成を便利にする点においては十分です．しかし，多くの場合より柔軟性を持たせて，引数の型が異なるような **異なる型上** （heterogeneous）の演算子のオーバーロードを許可することが有用です．例えば，`Pos` に `Nat` を足したり，`Nat` に `Pos` を足した結果は常に `Pos` になります：

```lean
{{#example_decl Examples/Classes.lean addNatPos}}
```
<!--
These functions allow natural numbers to be added to positive numbers, but they cannot be used with the `Add` type class, which expects both arguments to `add` to have the same type.
-->

これらの関数は自然数と正の整数の足し算に使うことができますが，受け取る2つの型がどちらも同じであることを期待する `Add` 型クラスに用いることはできません．

<!--
## Heterogeneous Overloadings
-->

## 異なる型上の演算子についてのオーバーロード

<!--
As mentioned in the section on [overloaded addition](pos.md#overloaded-addition), Lean provides a type class called `HAdd` for overloading addition heterogeneously.
The `HAdd` class takes three type parameters: the two argument types and the return type.
Instances of `HAdd Nat Pos Pos` and `HAdd Pos Nat Pos` allow ordinary addition notation to be used to mix the types:
-->

[オーバーロードされた足し算](pos.md#overloaded-addition) の節で述べたように，Leanは異なる型上の加算をオーバーロードするために `HAdd` という型クラスを提供しています．`HAdd` クラスは3つの型パラメータを取ります：2つの引数の型と戻り値の型です．`HAdd Nat Pos Pos` と `HAdd Pos Nat Pos` のインスタンスでは，通常の加算記法を型が入り混じったものに使うことができます：

```lean
{{#example_decl Examples/Classes.lean haddInsts}}
```
<!--
Given the above two instances, the following examples work:
-->

上記の2つのインスタンスから，以下の例が通ります：

```lean
{{#example_in Examples/Classes.lean posNatEx}}
```
```output info
{{#example_out Examples/Classes.lean posNatEx}}
```
```lean
{{#example_in Examples/Classes.lean natPosEx}}
```
```output info
{{#example_out Examples/Classes.lean natPosEx}}
```

<!--
The definition of the `HAdd` type class is very much like the following definition of `HPlus` with the corresponding instances:
-->

`HAdd` 型クラスの定義は，以下の `HPlus` の定義と対応するインスタンスによく似たものになっています：

```lean
{{#example_decl Examples/Classes.lean HPlus}}

{{#example_decl Examples/Classes.lean HPlusInstances}}
```
<!--
However, instances of `HPlus` are significantly less useful than instances of `HAdd`.
When attempting to use these instances with `#eval`, an error occurs:
-->

しかし，`HPlus` のインスタンスは `HAdd` のインスタンスに比べるとかなり使い勝手が悪いです．これらのインスタンスを `#eval` で使用しようとすると，エラーが発生します：

```lean
{{#example_in Examples/Classes.lean hPlusOops}}
```
```output error
{{#example_out Examples/Classes.lean hPlusOops}}
```
<!--
This happens because there is a metavariable in the type, and Lean has no way to solve it.
-->

これは型にメタ変数があることが原因で，Leanはこれを解決することができません．

<!--
As discussed in [the initial description of polymorphism](../getting-to-know/polymorphism.md), metavariables represent unknown parts of a program that could not be inferred.
When an expression is written following `#eval`, Lean attempts to determine its type automatically.
In this case, it could not.
Because the third type parameter for `HPlus` was unknown, Lean couldn't carry out type class instance search, but instance search is the only way that Lean could determine the expression's type.
That is, the `HPlus Pos Nat Pos` instance can only apply if the expression should have type `Pos`, but there's nothing in the program other than the instance itself to indicate that it should have this type.
-->

[多相性についての最初の説明](../getting-to-know/polymorphism.md) で議論したように，メタ変数は推論できなかったプログラムの未知の部分を表します．`#eval` の後に式を書くと，Leanは自動で型を決定しようとします．今回のケースではこれができませんでした．`HPlus` の3番目の型パラメータが未知であったため，Leanは型クラスのインスタンス検索を行うことができません．しかしインスタンス検索はLeanがこの式の型を決定できる唯一の方法です．つまり，`HPlus Pos Nat Pos` インスタンスは式が `Pos` 型を持つ場合にのみ適用できますが，インスタンス自身以外に式がこの型であることを示す情報はプログラム中に存在しません．

<!--
One solution to the problem is to ensure that all three types are available by adding a type annotation to the whole expression:
-->

この問題の解決策の1つは，式全体に型注釈を追加することで，3つの型がすべて利用できるようにすることです：

```lean
{{#example_in Examples/Classes.lean hPlusLotsaTypes}}
```
```output info
{{#example_out Examples/Classes.lean hPlusLotsaTypes}}
```
<!--
However, this solution is not very convenient for users of the positive number library.
-->

しかしこの解決策は正の整数のライブラリを使う人にとってかなり不便です．

<!--
## Output Parameters
-->

## 出力パラメータ

<!--
This problem can also be solved by declaring `γ` to be an _output parameter_.
Most type class parameters are inputs to the search algorithm: they are used to select an instance.
For example, in an `OfNat` instance, both the type and the natural number are used to select a particular interpretation of a natural number literal.
However, in some cases, it can be convenient to start the search process even when some of the type parameters are not yet known, and use the instances that are discovered in the search to determine values for metavariables.
The parameters that aren't needed to start instance search are outputs of the process, which is declared with the `outParam` modifier:
-->

この問題は `γ` を **出力パラメータ** （output parameter）として宣言することで解決できます． ほとんどの型クラスのパラメータはインスタンスを選択するための探索アルゴリズムに入力されます．例えば，`OfNat` インスタンスでは，型と自然数の両方が自然数リテラルの特定の解釈を選択されるために使用されます．しかし，場合によっては，型パラメータのうちいくつかがまだわかっていない時でも検索プロセスを開始し，その結果発見されたインスタンスをメタ変数の値を決定するために使用することが便利であることがあります．インスタンス検索を開始するのに必要でないパラメータは `outParam` 修飾子で宣言によって実行される処理の出力結果の型になります：

```lean
{{#example_decl Examples/Classes.lean HPlusOut}}
```

<!--
With this output parameter, type class instance search is able to select an instance without knowing `γ` in advance.
For instance:
-->

この出力パラメータによって型クラスのインスタンス検索は事前に `γ` を知らなくてもインスタンスを選択することができます．例えば以下のように動作します：

```lean
{{#example_in Examples/Classes.lean hPlusWorks}}
```
```output info
{{#example_out Examples/Classes.lean hPlusWorks}}
```

<!--
It might be helpful to think of output parameters as defining a kind of function.
Any given instance of a type class that has one or more output parameters provides Lean with instructions for determining the outputs from the inputs.
The process of searching for an instance, possibly recursively, ends up being more powerful than mere overloading.
Output parameters can determine other types in the program, and instance search can assemble a collection of underlying instances into a program that has this type.
-->

出力パラメータは一種の関数を定義していると考えるとわかりやすいでしょう．1つ以上の出力パラメータを持つ型クラスの任意のインスタンスはLeanに入力から出力を決定する命令を提供します．このインスタンス検索のプロセスは時に再帰的にもなり，結果的にただのオーバーロードよりも強力になります．出力パラメータはプログラム内の他の型を決定することができ，インスタンス検索は基礎となるインスタンスの集まりをこの型を持つプログラムに組み込むことができます．

<!--
## Default Instances
-->

## デフォルトインスタンス

<!--
Deciding whether a parameter is an input or an output controls the circumstances under which Lean will initiate type class search.
In particular, type class search does not occur until all inputs are known.
However, in some cases, output parameters are not enough, and instance search should also occur when some inputs are unknown.
This is a bit like default values for optional function arguments in Python or Kotlin, except default _types_ are being selected.
-->

パラメータが入力か出かを決めることで，Leanが型クラス検索を開始する状況が制御されます．特に，型クラス検索はすべての入力が判明するまで行われません．しかし，場合によっては出力パラメータだけでは不十分な場合もあり，入力の一部が不明な場合にもインスタンス探索を行う必要があります．これはPythonやKotlinにある関数のオプショナル引数のデフォルト値のようなものです．ただ，ここではデフォルト **型** が選択されます．

<!--
_Default instances_ are instances that are available for instance search _even when not all their inputs are known_.
When one of these instances can be used, it will be used.
This can cause programs to successfully type check, rather than failing with errors related to unknown types and metavariables.
On the other hand, default instances can make instance selection less predictable.
In particular, if an undesired default instance is selected, then an expression may have a different type than expected, which can cause confusing type errors to occur elsewhere in the program.
Be selective about where default instances are used!
-->

**デフォルトインスタンス** は **すべての入力が既知でない場合でも** インスタンス検索に利用可能なインスタンスです．これらのインスタンスのうちどれか1つ使用できる場合，そのインスタンスが使用されます．これにより，未知の型やメタ変数に関連するエラーで失敗することなく，プログラムの型チェックを成功させることができます．一方，デフォルトインスタンスは，インスタンスの選択を予測しにくくします．特に，望ましくないデフォルトインスタンスが選択された場合，式が予想と異なる型になる可能性があり，プログラム中の別の個所で紛らわしい型エラーが発生する可能性があります．デフォルトインスタンスは使いどころに気を付けましょう！

<!--
One example of where default instances can be useful is an instance of `HPlus` that can be derived from an `Add` instance.
In other words, ordinary addition is a special case of heterogeneous addition in which all three types happen to be the same.
This can be implemented using the following instance:
-->

デフォルトインスタンスが役に立つ例として，`Add` インスタンスから派生される `HPlus` インスタンスがあります．言い換えると，通常の加算は異なる型の間の加算の中の3つの型がすべて同じである特殊なケースです．これは以下のインスタンスを使って実装できます：

```lean
{{#example_decl Examples/Classes.lean notDefaultAdd}}
```
<!--
With this instance, `hPlus` can be used for any addable type, like `Nat`:
-->

このインスタンスを使って，`Nat` のような足すことのできる任意の型に対して `hPlus` を使うことができます：

```lean
{{#example_in Examples/Classes.lean hPlusNatNat}}
```
```output info
{{#example_out Examples/Classes.lean hPlusNatNat}}
```

<!--
However, this instance will only be used in situations where the types of both arguments are known.
For example,
-->

しかし，このインスタンスは2つの引数の型が既知である場合にのみ使うことができます．例えば，

```lean
{{#example_in Examples/Classes.lean plusFiveThree}}
```
<!--
yields the type
-->

は以下の型を出力します．

```output info
{{#example_out Examples/Classes.lean plusFiveThree}}
```
<!--
as expected, but
-->

これは予想通りです．しかし，

```lean
{{#example_in Examples/Classes.lean plusFiveMeta}}
```
<!--
yields a type that contains two metavariables, one for the remaining argument and one for the return type:
-->

は2つのメタ変数を含んだ型を出力します．片方は残りの型で，もう片方は戻り値の型です：

```output info
{{#example_out Examples/Classes.lean plusFiveMeta}}
```

<!--
In the vast majority of cases, when someone supplies one argument to addition, the other argument will have the same type.
To make this instance into a default instance, apply the `default_instance` attribute:
-->

ほとんどの場合，足し算の一方の引数を与えると，もう一方の引数も同じ型になります．このインスタンスをデフォルトインスタンスにするには，`default_instance` 属性を適用します：

```lean
{{#example_decl Examples/Classes.lean defaultAdd}}
```
<!--
With this default instance, the example has a more useful type:
-->

このデフォルトインスタンスによって，先ほどの例は使いやすい型になります：

```lean
{{#example_in Examples/Classes.lean plusFive}}
```
<!--
yields
-->

は以下を出力します．

```output info
{{#example_out Examples/Classes.lean plusFive}}
```

<!--
Each operator that exists in overloadable heterogeneous and homogeneous versions follows the pattern of a default instance that allows the homogeneous version to be used in contexts where the heterogeneous is expected.
The infix operator is replaced with a call to the heterogeneous version, and the homogeneous default instance is selected when possible.
-->

オーバーロード可能でかつ異なる型および同じ型上での演算が定義されているような演算子においては，上記のようにデフォルトインスタンスによって異なる型上のものが期待されているコンテキストで同じ型上の演算を行うようにできます．中置演算子は異なる型上の呼び出しに置き換えられ，可能な場合は同じ型上のデフォルトインスタンスが選択されます．

<!--
Similarly, simply writing `{{#example_in Examples/Classes.lean fiveType}}` gives a `{{#example_out Examples/Classes.lean fiveType}}` rather than a type with a metavariable that is waiting for more information in order to select an `OfNat` instance.
This is because the `OfNat` instance for `Nat` is a default instance.
-->

同様に，単に `{{#example_in Examples/Classes.lean fiveType}}` と書くと `OfNat` インスタンスを選択するために，より多くの情報を持っているメタ変数を持つ型ではなく，`{{#example_out Examples/Classes.lean fiveType}}` が得られます．これは `Nat` の `OfNat` インスタンスがデフォルトのインスタンスであるためです．

<!--
Default instances can also be assigned _priorities_ that affect which will be chosen in situations where more than one might apply.
For more information on default instance priorities, please consult the Lean manual.
-->

複数のインスタンスが適用できるような場合において，デフォルトインスタンスに選ばれるインスタンスをコントロールする **優先順位** を割り当てることもできます．デフォルトインスタンスの優先順位についての詳細はLeanのマニュアルを参照してください．

<!--
## Exercises
-->

## 演習問題

<!--
Define an instance of `HMul (PPoint α) α (PPoint α)` that multiplies both projections by the scalar.
It should work for any type `α` for which there is a `Mul α` instance.
For example,
-->

`PPoint` の両方の射影にスカラー値を乗じる `HMul (PPoint α) α (PPoint α)` のインスタンスを定義してください．これは `Mul α` のインスタンスが存在する任意の型 `α` に対して機能できるべきです．例えば，

```lean
{{#example_in Examples/Classes.lean HMulPPoint}}
```
<!--
should yield
-->

は以下を出力するようにしてください．

```output info
{{#example_out Examples/Classes.lean HMulPPoint}}
```
