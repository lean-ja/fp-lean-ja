<!--
# Indices, Parameters, and Universe Levels
-->

# 添字、パラメータ、宇宙レベル

<!--
The distinction between indices and parameters of an inductive type is more than just a way to describe arguments to the type that either vary or do not between the constructors.
Whether an argument to an inductive type is a parameter or an index also matters when it comes time to determine the relationships between their universe levels.
In particular, an inductive type may have the same universe level as a parameter, but it must be in a larger universe than its indices.
This restriction is necessary to ensure that Lean can be used as a theorem prover as well as a programming language—without it, Lean's logic would be inconsistent.
Experimenting with error messages is a good way to illustrate these rules, as well as the precise rules that determine whether an argument to a type is a parameter or an index.
-->

帰納型の添字とパラメータの区別は、単にコンストラクタ間で型への引数が変化するか、もしくはしないかを記述する方法だけにとどまりません。帰納型の引数がパラメータか添字かは、それらの宇宙レベル間の関係を決定するときに重要になります。特に、帰納型はパラメータと同じ宇宙レベルを持つことが可能ですが、添字に対しては宇宙レベルは大きくなければなりません。この制約はLeanがプログラミング言語としてだけでなく、定理証明器としても使用できるようにするために必要です。こうしなければLeanの論理は一貫性が無くなることでしょう。型に対する引数がパラメータと添字のどちらにするべきかを決定する正確なルールと共に、これらのルールを説明するにはエラーメッセージを使って実験するのは良い方法です。

<!--
Generally speaking, the definition of an inductive type takes its parameters before a colon and its indices after the colon.
Parameters are given names like function arguments, whereas indices only have their types described.
This can be seen in the definition of `Vect`:
-->

一般的に、帰納型の定義ではパラメータはコロンの前、添字はコロンの後に取られます。パラメータには関数の引数のように名前が与えられる一方、添字には型のみが記述されます。これは `Vect` の定義で見ることができます：

```lean
{{#example_decl Examples/DependentTypes.lean Vect}}
```
<!--
In this definition, `α` is a parameter and the `Nat` is an index.
Parameters may be referred to throughout the definition (for example, `Vect.cons` uses `α` for the type of its first argument), but they must always be used consistently.
Because indices are expected to change, they are assigned individual values at each constructor, rather than being provided as arguments at the top of the datatype definition.
-->

この定義では、`α` はパラメータで `Nat` は添字です。パラメータは定義全体を通して参照することができますが（例えば、`Vect.cons` は第一引数の型として `α` を使用しています）、それらは常に一貫使用される必要があります。添字は変更されることが期待されるため、データ型の定義の先頭で引数として提供されるのではなく、コンストラクタごとに個別の値が割り当てられます。

<!--
A very simple datatype with a parameter is `WithParameter`:
-->

パラメータを使った非常にシンプルなデータ型として次の `WithParameter` を考えます：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameter}}
```
<!--
The universe level `u` can be used for both the parameter and for the inductive type itself, illustrating that parameters do not increase the universe level of a datatype.
Similarly, when there are multiple parameters, the inductive type receives whichever universe level is greater:
-->

宇宙レベル `u` は、パラメータと帰納型自体の両方に使用することができ、これはパラメータがデータ型の宇宙レベルを増大させないことを示します。同様に、複数のパラメータがある場合、帰納型はどちらか大きい方の宇宙レベルを受け取ります：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithTwoParameters}}
```
<!--
Because parameters do not increase the universe level of a datatype, they can be more convenient to work with.
Lean attempts to identify arguments that are described like indices (after the colon), but used like parameters, and turn them into parameters:
Both of the following inductive datatypes have their parameter written after the colon:
-->

パラメータはデータ型の宇宙レベルを増加させないため、より便利に扱うことができます。Leanは添字のように（コロンの後に）記述されるがパラメータのように用いられる引数を識別し、それらをパラメータに変えようとします：以下の帰納的データ型はどちらもコロンの後にパラメータが記述されています：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameterAfterColon}}

{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameterAfterColon2}}
```

<!--
When a parameter is not named in the initial datatype declaration, different names may be used for it in each constructor, so long as they are used consistently.
The following declaration is accepted:
-->

最初のデータ型の宣言でパラメータに名前が付けられていない場合、一貫して使用される限り各コンストラクタで異なる名前を使用しても良いです。次の宣言はLeanに受け入れられます：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameterAfterColonDifferentNames}}
```
<!--
However, this flexibility does not extend to datatypes that explicitly declare the names of their parameters:
-->

しかし、この柔軟性は、パラメータの名前を明示的に宣言するデータ型には適用されません：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean WithParameterBeforeColonDifferentNames}}
```
```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean WithParameterBeforeColonDifferentNames}}
```
<!--
Similarly, attempting to name an index results in an error:
-->

同様に、添字に名前を付けようとするとエラーになります：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean WithNamedIndex}}
```
```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean WithNamedIndex}}
```

<!--
Using an appropriate universe level and placing the index after the colon results in a declaration that is acceptable:
-->

適切な宇宙レベルを用い添字をコロンの後ろに置くことで、Leanに許容される宣言となります：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithIndex}}
```


<!--
Even though Lean can sometimes determine that an argument after the colon in an inductive type declaration is a parameter when it is used consistently in all constructors, all parameters are still required to come before all indices.
Attempting to place a parameter after an index results in the argument being considered an index itself, which would require the universe level of the datatype to increase:
-->

帰納型の宣言においてコロンの後にある引数がすべてのコンストラクタで一貫して使用されていればパラメータであるとLeanが判断できる場合もありますが、それでもすべてのパラメータはすべての添字より前に来る必要があります。添字の後にパラメータを置こうとすると、引数自体が添字と見なされ、データ型の宇宙レベルを上げる必要があります：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean ParamAfterIndex}}
```
```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean ParamAfterIndex}}
```

<!--
Parameters need not be types.
This example shows that ordinary datatypes such as `Nat` may be used as parameters:
-->

パラメータは型である必要はありません。次の例は `Nat` のような通常のデータ型をパラメータとして使用できることを示しています：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean NatParamFour}}
```
```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean NatParamFour}}
```
<!--
Using the `n` as suggested causes the declaration to be accepted:
-->

エラーメッセージの通りに `n` を使用すると、宣言が受理されます：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean NatParam}}
```




<!--
What can be concluded from these experiments?
The rules of parameters and indices are as follows:
-->

これらの実験から何が結論付けられるでしょうか？パラメータと添字のルールは以下の通りです：

 <!--
 1. Parameters must be used identically in each constructor's type.
 -->
 1. パラメータは各コンストラクタの型で同じものを使用しなければなりません。
 <!--
 2. All parameters must come before all indices.
 -->
 2. すべてのパラメータはすべての添字より前に来なければなりません。
 <!--
 3. The universe level of the datatype being defined must be at least as large as the largest parameter, and strictly larger than the largest index.
 -->
 3. 定義されるデータ型の宇宙レベルは最も低くても最大のパラメータのものと同じ大きさでなければならず、最大の添字より大きくなければなりません。
 <!--
 4. Named arguments written before the colon are always parameters, while arguments after the colon are typically indices. Lean may determine that the usage of arguments after the colon makes them into parameters if they are used consistently in all constructors and don't come after any indices.
 -->
 4. コロンの前に書かれた名前付きの引数は常にパラメータであり、コロンの後ろに書かれた引数は通常は添字です。コロンの後ろにある引数が一貫して使われ、かつ添字より後ろに来ないように使われている場合、それらをパラメータに変更するよう判断できます。

<!--
When in doubt, the Lean command `#print` can be used to check how many of a datatype's arguments are parameters.
For example, for `Vect`, it points out that the number of parameters is 1:
-->

どれがパラメータであるかわからない場合は、Leanのコマンド `#print` を使ってデータ型の引き数のうちいくつがパラメータなのかをチェックすることができます。例えば、`Vect` の場合、パラメータ数が1であることが示されます：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean printVect}}
```
```output info
{{#example_out Examples/DependentTypes/IndicesParameters.lean printVect}}
```

<!--
It is worth thinking about which arguments should be parameters and which should be indices when choosing the order of arguments to a datatype.
Having as many arguments as possible be parameters helps keep universe levels under control, which can make a complicated program easier to type check.
One way to make this possible is to ensure that all parameters come before all indices in the argument list.
-->

データ型の引き数の順番を決める際に、どの引数をパラメータにし、どの引数を添字にするかを考えることには価値があります。可能な限り多くの引数をパラメータにすることは宇宙レベルを制御し、複雑なプログラムの型チェックを容易にすることができます。これを可能にする1つの方法は、引数リストにおいてすべてのパラメータがすべての添字の前に来るようにすることです。

<!--
Additionally, even though Lean is capable of determining that arguments after the colon are nonetheless parameters by their usage, it's a good idea to write parameters with explicit names.
This makes the intention clear to readers, and it causes Lean to report an error if the argument is mistakenly used inconsistently across the constructors.
-->

さらに、Leanはコロンの後にある引数がなんであろうともその使われ方からパラメータであることを判断することができますが、パラメータを明示的な名前で書くことは良い考え方です。こうすることで読み手に意図が明確に伝わ子、コンストラクタ間で引数が誤って一貫しない使われ方をした際にLeanがエラーを報告するようになります。
