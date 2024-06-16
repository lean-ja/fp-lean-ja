<!-- # Coercions -->

# 型強制

<!-- In mathematics, it is common to use the same symbol to stand for different aspects of some object in different contexts.
For example, if a ring is referred to in a context where a set is expected, then it is understood that the ring's underlying set is what's intended.
In programming languages, it is common to have rules to automatically translate values of one type into values of another type.
For instance, Java allows a `byte` to be automatically promoted to an `int`, and Kotlin allows a non-nullable type to be used in a context that expects a nullable version of the type. -->

数学では，同じ記号を異なる文脈の何かしらの対象の異なる側面について表すということがよくあります．例えば，集合が期待されている場面で環に言及する場合，環の台集合を意図していると理解されます．プログラミング言語では，ある型の値を別の型の値に自動的に変換する規則が一般的に備わっています．例えば，Javaでは `byte` 型を自動的に `int` 型に昇格させることができ，Kotlinではnullable型を期待するコンテキストでnon-nullable型を使用することができます．

<!-- In Lean, both purposes are served by a mechanism called _coercions_.
When Lean encounters an expression of one type in a context that expects a different type, it will attempt to coerce the expression before reporting a type error.
Unlike Java, C, and Kotlin, the coercions are extensible by defining instances of type classes. -->

Leanでは，この2つの目的は **型強制** （coercion）という機構で提供されています．ある型についての式について，コンテキスト中では異なる型が期待されている場合，Leanは型エラーを報告する前にその式の型を強制することを試みます．JavaやC，Kotlinと異なり，型強制は型クラスのインスタンスの定義によって拡張可能です．

<!-- ## Positive Numbers -->

## 正の整数

For example, every positive number corresponds to a natural number.
The function `Pos.toNat` that was defined earlier converts a `Pos` to the corresponding `Nat`:

例えば，すべての正の整数には自然数が対応します．以前定義した関数 `Pos.toNat` は `Pos` を対応する `Nat` に変換します：

```lean
{{#example_decl Examples/Classes.lean posToNat}}
```
<!-- The function `List.drop`, with type `{{#example_out Examples/Classes.lean drop}}`, removes a prefix of a list.
Applying `List.drop` to a `Pos`, however, leads to a type error: -->

型 `{{#example_out Examples/Classes.lean drop}}` の関数 `List.drop` はリストの先頭から指定数の要素を削除します．しかし，`List.drop` に `Pos` を適用すると，型エラーが発生します：

```lean
{{#example_in Examples/Classes.lean dropPos}}
```
```output error
{{#example_out Examples/Classes.lean dropPos}}
```
<!-- Because the author of `List.drop` did not make it a method of a type class, it can't be overridden by defining a new instance. -->

`List.drop` の作者はこのメソッドを型クラスのメソッドにしなかったため，新しいいんすたんすを定義してオーバーロードすることはできません．

<!-- The type class `Coe` describes overloaded ways of coercing from one type to another: -->

型クラス `Coe` は，ある型から別の型へ強制するオーバーロードされる方法を記述します：

```lean
{{#example_decl Examples/Classes.lean Coe}}
```
<!-- An instance of `Coe Pos Nat` is enough to allow the prior code to work: -->

`Coe Pos Nat` のインスタンスを定義するだけで先ほどのコードは動くようになります：

```lean
{{#example_decl Examples/Classes.lean CoePosNat}}

{{#example_in Examples/Classes.lean dropPosCoe}}
```
```output info
{{#example_out Examples/Classes.lean dropPosCoe}}
```
<!-- Using `#check` shows the result of the instance search that was used behind the scenes: -->

`#check` を使うと，この裏側で行われたインスタンス検索の結果を見ることができます：

```lean
{{#example_in Examples/Classes.lean checkDropPosCoe}}
```
```output info
{{#example_out Examples/Classes.lean checkDropPosCoe}}
```

<!-- ## Chaining Coercions -->

## 型強制の連鎖

<!-- When searching for coercions, Lean will attempt to assemble a coercion out of a chain of smaller coercions.
For example, there is already a coercion from `Nat` to `Int`.
Because of that instance, combined with the `Coe Pos Nat` instance, the following code is accepted: -->

Leanが型強制を検索する時，小さい強制の連鎖から強制を組み立てようとします．例えば，`Nat` から `Int` への強制が標準で実装されています．このインスタンスと `Coe Pos Nat` インスタンスを組み合わせると，以下のようなコードがコンパイラに受理されます：

```lean
{{#example_decl Examples/Classes.lean posInt}}
```
<!-- This definition uses two coercions: from `Pos` to `Nat`, and then from `Nat` to `Int`. -->

この定義は `Pos` から `Nat` へのものと，`Nat` から `Int` へのものの2つの強制を使用しています．

<!-- The Lean compiler does not get stuck in the presence of circular coercions.
For example, even if two types `A` and `B` can be coerced to one another, their mutual coercions can be used to find a path: -->

Leanのコンパイラは循環的な強制があってもはまってしまうことはありません．例えば，2つの型 `A` と `B` が互いに強制することができても，その相互の強制を使って以下の強制の筋道を見つけることができます：

```lean
{{#example_decl Examples/Classes.lean CoercionCycle}}
```
<!-- Remember: the double parentheses `()` is short for the constructor `Unit.unit`.
After deriving a `Repr B` instance, -->

注意：括弧だけの式 `()` は `Unit.unit` のコンストラクタの短縮形です．`Repr B` のインスタンスを導出すると，

```lean
{{#example_in Examples/Classes.lean coercedToBEval}}
```
<!-- results in: -->

は以下の結果になります：

```output info
{{#example_out Examples/Classes.lean coercedToBEval}}
```

<!-- The `Option` type can be used similarly to nullable types in C# and Kotlin: the `none` constructor represents the absence of a value.
The Lean standard library defines a coercion from any type `α` to `Option α` that wraps the value in `some`.
This allows option types to be used in a manner even more similar to nullable types, because `some` can be omitted.
For instance, the function `List.getLast?` that finds the last entry in a list can be written without a `some` around the return value `x`: -->

`Option` 型はC#とKotlinのnullable型と同じように扱えます：`none` コンストラクタは値がないことを表しています．Leanの標準ライブラリは任意の型 `α` から値を `some` で包む `Option α` への型強制が定義されています．これにより，オプション型は `some` を省略することができるため，よりnullable型に似た方法で使うことができます．例えば，リストの最後の要素を見つける関数 `List.getLast?` は戻り値 `x` を `some` で囲むことなく記述することができます：

```lean
{{#example_decl Examples/Classes.lean lastHuh}}
```
<!-- Instance search finds the coercion, and inserts a call to `coe`, which wraps the argument in `some`.
These coercions can be chained, so that nested uses of `Option` don't require nested `some` constructors: -->

インスタンス検索がこの強制を見つけ，引数を `some` で包む `coe` の呼び出しを挿入します．これらの強制は連鎖させることができるので，`Option` をネストして使用しても，ネストした `some` コンストラクタを必要としません：

```lean
{{#example_decl Examples/Classes.lean perhapsPerhapsPerhaps}}
```

<!-- Coercions are only activated automatically when Lean encounters a mismatch between an inferred type and a type that is imposed from the rest of the program.
In cases with other errors, coercions are not activated.
For example, if the error is that an instance is missing, coercions will not be used: -->

型強制が自動的に有効になるのは，Leanが推論した型とプログラムの他の部分から要求された型との間にミスマッチが発生した場合だけです．そのほかのエラーの場合，強制は作動しません．例えば，インスタンスが見つからないというエラーの場合，強制は使用されません：

```lean
{{#example_in Examples/Classes.lean ofNatBeforeCoe}}
```
```output error
{{#example_out Examples/Classes.lean ofNatBeforeCoe}}
```

<!-- This can be worked around by manually indicating the desired type to be used for `OfNat`: -->

これは `OfNat` に使用する型を手動で指定することで回避できます：

```lean
{{#example_decl Examples/Classes.lean perhapsPerhapsPerhapsNat}}
```
<!-- Additionally, coercions can be manually inserted using an up arrow: -->

さらに，強制は上向き矢印によって手動で挿入することもできます：

```lean
{{#example_decl Examples/Classes.lean perhapsPerhapsPerhapsNatUp}}
```
<!-- In some cases, this can be used to ensure that Lean finds the right instances.
It can also make the programmer's intentions more clear. -->

いくつかのケースにおいて，これはLeanが正しいインスタンスを見つけることができるようにするために使用できます．また，プログラマの意図をより明確にすることもできます．

<!-- ## Non-Empty Lists and Dependent Coercions -->

## 空でないリストと依存強制

<!-- An instance of `Coe α β` makes sense when the type `β` has a value that can represent each value from the type `α`.
Coercing from `Nat` to `Int` makes sense, because the type `Int` contains all the natural numbers.
Similarly, a coercion from non-empty lists to ordinary lists makes sense because the `List` type can represent every non-empty list: -->

`Coe α β` のインスタンスは，`β` 型が `α` 型の各値を表現できる値を持っているときに意味を成します．`Nat` から　`Int` への強制は，`Int` 型がすべての自然数を保持しているため意味を為します．同様に，`List` 型はすべての空でないリストを表すことができるので，空でないリストから普通のリストへの強制は意味があります：

```lean
{{#example_decl Examples/Classes.lean CoeNEList}}
```
<!-- This allows non-empty lists to be used with the entire `List` API. -->

これによって空でないリストに `List` のすべてのAPIの利用が許可されます．

<!-- On the other hand, it is impossible to write an instance of `Coe (List α) (NonEmptyList α)`, because there's no non-empty list that can represent the empty list.
This limitation can be worked around by using another version of coercions, which are called _dependent coercions_.
Dependent coercions can be used when the ability to coerce from one type to another depends on which particular value is being coerced.
Just as the `OfNat` type class takes the particular `Nat` being overloaded as a parameter, dependent coercion takes the value being coerced as a parameter: -->

一方で， `Coe (List α) (NonEmptyList α)` のインスタンスを書くことは不可能です．なぜなら，空でないリストは空リストを表現できないからです．この制限は **依存強制** （dependent coercions）と呼ばれる別バージョンの強制を使うことで回避できます．依存強制は，ある型から別の型への強制が特定の値の強制がどのように行われるかということに依存する場合に使用できます．ちょうど，`OfNat` 型クラスがオーバーロードされる特定の `Nat` をパラメータとして受け取るように，依存強制は強制される値をパラメータとして受け取ります：

```lean
{{#example_decl Examples/Classes.lean CoeDep}}
```
<!-- This is a chance to select only certain values, either by imposing further type class constraints on the value or by writing certain constructors directly.
For example, any `List` that is not actually empty can be coerced to a `NonEmptyList`: -->

これにより，値にさらに型クラスの制約を課すか，特定のコンストラクタを直接書くことによって特定の値だけを選択できることができます．例えば，実際には空でない `List` は `NonEmptyList` に強制することができます：

```lean
{{#example_decl Examples/Classes.lean CoeDepListNEList}}
```

<!-- ## Coercing to Types -->

## 型への強制

<!-- In mathematics, it is common to have a concept that consists of a set equipped with additional structure.
For example, a monoid is some set _S_, an element _s_ of _S_, and an associative binary operator on _S_, such that _s_ is neutral on the left and right of the operator.
_S_ is referred to as the "carrier set" of the monoid.
The natural numbers with zero and addition form a monoid, because addition is associative and adding zero to any number is the identity.
Similarly, the natural numbers with one and multiplication also form a monoid.
Monoids are also widely used in functional programming: lists, the empty list, and the append operator form a monoid, as do strings, the empty string, and string append: -->

数学では，集合に付加的な構造を持たせた概念を持つことが一般的です．例えば，モノイドとは，ある集合 _S_ と _S_ の要素 _s_ ，_S_ 上の結合的な二項演算子で _s_ が演算子の左右に対して中立であるようなものです．_S_ はモノイドの「台集合」と呼ばれます．足し算は結合的であり，任意の数への0の加算は恒等であるため，0と足し算を備えた自然数はモノイドを形成します．同様に，1と掛け算を備えた自然数もモノイドを形成します．モノイドは関数型プログラミングでも広く用いられています：リスト，空リスト，append演算子はモノイドを形成し，文字列，空文字列，文字列のappendもモノイドを形成します．

```lean
{{#example_decl Examples/Classes.lean Monoid}}
```
<!-- Given a monoid, it is possible to write the `foldMap` function that, in a single pass, transforms the entries in a list into a monoid's carrier set and then combines them using the monoid's operator.
Because monoids have a neutral element, there is a natural result to return when the list is empty, and because the operator is associative, clients of the function don't have to care whether the recursive function combines elements from left to right or from right to left. -->

モノイドが与えられると，一度の走査でリストの要素をモノイドの台集合に変換し，モノイドの演算子を使ってそれらを結合する `foldMap` 関数を書くことができます．モノイドは中立的な要素を持つので，リストが空の時に対応する値が自然に存在し，また演算子が結合的であるため，関数の利用者は再帰関数が左から右へか，右から左へ要素を結合するかを気にする必要はありません．

```lean
{{#example_decl Examples/Classes.lean firstFoldMap}}
```

<!-- Even though a monoid consists of three separate pieces of information, it is common to just refer to the monoid's name in order to refer to its set.
Instead of saying "Let A be a monoid and let _x_ and _y_ be elements of its carrier set", it is common to say "Let _A_ be a monoid and let _x_ and _y_ be elements of _A_".
This practice can be encoded in Lean by defining a new kind of coercion, from the monoid to its carrier set. -->

モノイドは3つの個別の情報から構成されているにも関わらず，その集合を参照する際にはモノイドの名前だけを参照するのが一般的です．「A をモノイドとし， _x_ と _y_ をその台集合の要素とする」というよりも「 _A_ をモノイドとし， _x_ と _y_ を _A_ の要素とする」と言う方が一般的です．この慣習は，モノイドからその台集合への新しい種類の強制を定義することでLeanで実装することができます．

<!-- The `CoeSort` class is just like the `Coe` class, with the exception that the target of the coercion must be a _sort_, namely `Type` or `Prop`.
The term _sort_ in Lean refers to these types that classify other types—`Type` classifies types that themselves classify data, and `Prop` classifies propositions that themselves classify evidence of their truth.
Just as `Coe` is checked when a type mismatch occurs, `CoeSort` is used when something other than a sort is provided in a context where a sort would be expected. -->

`CoeSort` クラスは `Coe` クラスと似ていますが，強制の対象は `Type` や `Prop` といった **ソート** （sort）でなければなりません．Leanにおいて **ソート** という用語は型自体を分類する型を指します．ここで分類される型は，それ自体がデータを分類する型を分類する `Type` と，それ自体が根拠の真偽を分類する命題を分類する `Prop` です．型の不一致が発生した時に `Coe` がチェックされるように，`CoeSort` はソートが期待されるコンテキストでソート以外のものが提示されたときに使用されます．

<!-- The coercion from a monoid into its carrier set extracts the carrier: -->

モノイドからその台集合への強制はその台の展開で行われます：

```lean
{{#example_decl Examples/Classes.lean CoeMonoid}}
```
<!-- With this coercion, the type signatures become less bureaucratic: -->

この強制により，型注釈はいくぶん仰々しさが軽減されます：

```lean
{{#example_decl Examples/Classes.lean foldMap}}
```

<!-- Another useful example of `CoeSort` is used to bridge the gap between `Bool` and `Prop`.
As discussed in [the section on ordering and equality](standard-classes.md#equality-and-ordering), Lean's `if` expression expects the condition to be a decidable proposition rather than a `Bool`.
Programs typically need to be able to branch based on Boolean values, however.
Rather than have two kinds of `if` expression, the Lean standard library defines a coercion from `Bool` to the proposition that the `Bool` in question is equal to `true`: -->

`CoeSort` のもう一つ便利な例は，`Bool` と `Prop` の間のギャップを埋めるために使用されます．[順序と同値についての節](standard-classes.md#equality-and-ordering) で説明したように，Leanの `if` 式は条件が `Bool` ではなく，決定可能な命題であることを期待します．しかし，プログラムは通常，真偽値に基づいて分岐する必要があります．2種類の `if` 式を用意する代わりに，Leanの標準ライブラリは `Bool` から問題の `Bool` が `true` に等しいという命題への強制を定義しています：

```lean
{{#example_decl Examples/Classes.lean CoeBoolProp}}
```
In this case, the sort in question is `Prop` rather than `Type`.

ここで，問題のソートは `Type` ではなく `Prop` です．

<!-- ## Coercing to Functions -->

## 関数への強制

<!-- Many datatypes that occur regularly in programming consist of a function along with some extra information about it.
For example, a function might be accompanied by a name to show in logs or by some configuration data.
Additionally, putting a type in a field of a structure, similarly to the `Monoid` example, can make sense in contexts where there is more than one way to implement an operation and more manual control is needed than type classes would allow.
For example, the specific details of values emitted by a JSON serializer may be important because another application expects a particular format.
Sometimes, the function itself may be derivable from just the configuration data. -->

プログラミングでよく使われるデータ型の多くは，関数とその関数に関する追加情報で構成されています．例えば，関数はログに表示するための名前や，何かしらの設定データを伴っているかもしれません．さらに，`Monoid` の例と同じように，構造体のフィールドに型を置くことは，ある演算を実装する方法が複数あり，型クラスが許可するよりも手動で制御する必要があるような状況で意味を持つことがあります．例えば，JSONシリアライザが出力する値について他のアプリケーションにて特定のフォーマットを期待することがあるため，その場合は詳細が重要になります．時には関数自体が設定データだけから導出可能な場合もあります．

<!-- A type class called `CoeFun` can transform values from non-function types to function types.
`CoeFun` has two parameters: the first is the type whose values should be transformed into functions, and the second is an output parameter that determines exactly which function type is being targeted. -->

`CoeFun` と呼ばれる型クラスは，値を非関数型から関数型に変換することができます．`CoeFun` には2つのパラメータがあります：1つ目は関数に変換したい値の型で，2つ目は出力パラメータで対象となる関数型を正確に決定するものです．

```lean
{{#example_decl Examples/Classes.lean CoeFun}}
```
<!-- The second parameter is itself a function that computes a type.
In Lean, types are first-class and can be passed to functions or returned from them, just like anything else. -->

2番目のパラメータは，それ自体が型を計算する関数です．Leanでは，型は第一級であり，他のものと同じように関数に渡したり関数から返したりすることができます．

<!-- For example, a function that adds a constant amount to its argument can be represented as a wrapper around the amount to add, rather than by defining an actual function: -->

例えば，引数に定数を加算する関数は，実際の関数を定義する代わりに，加算する量のラッパーとして表現することができます：

```lean
{{#example_decl Examples/Classes.lean Adder}}
```
<!-- A function that adds five to its argument has a `5` in the `howMuch` field: -->

引数に5を加える関数は，`howMuch` フィールドに `5` を持ちます：

```lean
{{#example_decl Examples/Classes.lean add5}}
```
<!-- This `Adder` type is not a function, and applying it to an argument results in an error: -->

この `Adder` 型は関数ではないので，引数に適用するとエラーになります：

```lean
{{#example_in Examples/Classes.lean add5notfun}}
```
```output error
{{#example_out Examples/Classes.lean add5notfun}}
```
<!-- Defining a `CoeFun` instance causes Lean to transform the adder into a function with type `Nat → Nat`: -->

`CoeFun` インスタンスを定義すると，Leanはこの加算器を `Nat → Nat` 型の関数に変換します：

```lean
{{#example_decl Examples/Classes.lean CoeFunAdder}}

{{#example_in Examples/Classes.lean add53}}
```
```output info
{{#example_out Examples/Classes.lean add53}}
```
<!-- Because all `Adder`s should be transformed into `Nat → Nat` functions, the argument to `CoeFun`'s second parameter was ignored. -->

すべての `Adder` は `Nat → Nat` 関数に変換されるべきなので，`CoeFun` の2番目のパラメータの引数は無視されています．

<!-- When the value itself is needed to determine the right function type, then `CoeFun`'s second parameter is no longer ignored.
For example, given the following representation of JSON values: -->

正しい関数型を決定するために値そのものが必要な場合，`CoeFun` の2番目のパラメータは無視されなくなります．例えば，以下のようなJSON値の表現があるとします：

```lean
{{#example_decl Examples/Classes.lean JSON}}
```
<!-- a JSON serializer is a structure that tracks the type it knows how to serialize along with the serialization code itself: -->

JSONのシリアライザは，シリアライズするコードそのものとともにシリアライズ方法についての型を格納する構造体です：

```lean
{{#example_decl Examples/Classes.lean Serializer}}
```
<!-- A serializer for strings need only wrap the provided string in the `JSON.string` constructor: -->

文字列用のシリアライザは，渡された文字列を `JSON.string` コンストラクタでつつむだけです：

```lean
{{#example_decl Examples/Classes.lean StrSer}}
```
<!-- Viewing JSON serializers as functions that serialize their argument requires extracting the inner type of serializable data: -->

JSONシリアライザを，引数をシリアライズする関数として見るには，シリアライズ可能なデータの内部方を抽出する必要があります：

```lean
{{#example_decl Examples/Classes.lean CoeFunSer}}
```
<!-- Given this instance, a serializer can be applied directly to an argument: -->

このインスタンスにより，シリアライザを引数に直接適用することができます：

```lean
{{#example_decl Examples/Classes.lean buildResponse}}
```
<!-- The serializer can be passed directly to `buildResponse`: -->

このシリアライザは `buildResponse` に直接渡すことができます：

```lean
{{#example_in Examples/Classes.lean buildResponseOut}}
```
```output info
{{#example_out Examples/Classes.lean buildResponseOut}}
```

<!-- ### Aside: JSON as a String -->

### 余談：文字列としてのJSON

<!-- It can be a bit difficult to understand JSON when encoded as Lean objects.
To help make sure that the serialized response was what was expected, it can be convenient to write a simple converter from `JSON` to `String`.
The first step is to simplify the display of numbers.
`JSON` doesn't distinguish between integers and floating point numbers, and the type `Float` is used to represent both.
In Lean, `Float.toString` includes a number of trailing zeros: -->

LeanのオブジェクトとしてエンコードされたJSONを理解するのは少し難しいかもしれません．シリアライズされたレスポンスが期待されたものであることを確認するために，`JSON` から `String` への簡単なコンバータを書くと便利です．最初のステップは，数値の表示を単純化することです．`JSON` は整数と浮動小数点数を区別しないため，`Float` 型は両方を表現するために使用されます．Leanでは，`Float.toString` は末尾に0を含みます：

```lean
{{#example_in Examples/Classes.lean fiveZeros}}
```
```output info
{{#example_out Examples/Classes.lean fiveZeros}}
```
<!-- The solution is to write a little function that cleans up the presentation by dropping all trailing zeros, followed by a trailing decimal point: -->

この解決策は，0をすべて削除し，小数点以下を削除することで表示を綺麗にする小さな関数を書くことです：

```lean
{{#example_decl Examples/Classes.lean dropDecimals}}
```
<!-- With this definition, `{{#example_in Examples/Classes.lean dropDecimalExample}}` yields `{{#example_out Examples/Classes.lean dropDecimalExample}}`, and `{{#example_in Examples/Classes.lean dropDecimalExample2}}` yields `{{#example_out Examples/Classes.lean dropDecimalExample2}}`. -->

この定義によって，`{{#example_in Examples/Classes.lean dropDecimalExample}}` は `{{#example_out Examples/Classes.lean dropDecimalExample}}` を出力し，`{{#example_in Examples/Classes.lean dropDecimalExample2}}` は `{{#example_out Examples/Classes.lean dropDecimalExample2}}` を出力します．

<!-- The next step is to define a helper function to append a list of strings with a separator in between them: -->

次のステップは，区切り文字を挟んだ文字列のリストを追加するヘルパー関数を定義することです：

```lean
{{#example_decl Examples/Classes.lean Stringseparate}}
```
<!-- This function is useful to account for comma-separated elements in JSON arrays and objects.
`{{#example_in Examples/Classes.lean sep2ex}}` yields `{{#example_out Examples/Classes.lean sep2ex}}`, `{{#example_in Examples/Classes.lean sep1ex}}` yields `{{#example_out Examples/Classes.lean sep1ex}}`, and `{{#example_in Examples/Classes.lean sep0ex}}` yields `{{#example_out Examples/Classes.lean sep0ex}}`. -->

この関数はJSON配列とオブジェクト中のコンマ区切り要素に対して有用です．`{{#example_in Examples/Classes.lean sep2ex}}` は `{{#example_out Examples/Classes.lean sep2ex}}` を，`{{#example_in Examples/Classes.lean sep1ex}}` は `{{#example_out Examples/Classes.lean sep1ex}}` を， `{{#example_in Examples/Classes.lean sep0ex}}` は `{{#example_out Examples/Classes.lean sep0ex}}` をそれぞれ出力します．

<!-- Finally, a string escaping procedure is needed for JSON strings, so that the Lean string containing `"Hello!"` can be output as `"\"Hello!\""`.
Fortunately, the Lean compiler contains an internal function for escaping JSON strings already, called `Lean.Json.escape`.
To access this function, add `import Lean` to the beginning of your file. -->

最後に，JSON文字列のための文字列エスケープ手順が必要です．幸いなことに，Leanのコンパイラには，`Lean.Json.escape` というJSON文字列をエスケープする内部関数がすでに用意されています．この関数を使用する際には，ファイルの先頭に `import Lean` を追加してください．

<!-- The function that emits a string from a `JSON` value is declared `partial` because Lean cannot see that it terminates.
This is because recursive calls to `asString` occur in functions that are being applied by `List.map`, and this pattern of recursion is complicated enough that Lean cannot see that the recursive calls are actually being performed on smaller values.
In an application that just needs to produce JSON strings and doesn't need to mathematically reason about the process, having the function be `partial` is not likely to cause problems. -->

`JSON` の値から文字列を出力する関数が `partial` と宣言されているのは，Leanがその関数の終了を確認できないためです．これは，`asString` への再帰呼び出しが，`List.map` によって適用される関数の中で発生するためです．この再帰呼び出しの仕方が複雑であるために，Leanは再帰的呼び出しがちゃんと小さい値に対して実行されていることを確認できません．JSON文字列を生成するだけでよく，その処理について数学的に推論する必要がないアプリケーションでは，関数が `partial` であってもめったに問題になることはありません．

```lean
{{#example_decl Examples/Classes.lean JSONasString}}
```
<!-- With this definition, the output of serialization is easier to read: -->

この定義により，シリアライズされた結果は読みやすくなります：

```lean
{{#example_in Examples/Classes.lean buildResponseStr}}
```
```output info
{{#example_out Examples/Classes.lean buildResponseStr}}
```


<!-- ## Messages You May Meet -->

## 見るかもしれないメッセージ

<!-- Natural number literals are overloaded with the `OfNat` type class.
Because coercions fire in cases where types don't match, rather than in cases of missing instances, a missing `OfNat` instance for a type does not cause a coercion from `Nat` to be applied: -->

自然数リテラルは `OfNat` 型クラスでオーバーロードされます．強制はインスタンスが見つからない場合ではなく，型が一致しない場合に発生するため，型の `OfNat` インスタンスが見つからなくても `Nat` からの強制が適用されることはない：

```lean
{{#example_in Examples/Classes.lean ofNatBeforeCoe}}
```
```output error
{{#example_out Examples/Classes.lean ofNatBeforeCoe}}
```

<!-- ## Design Considerations -->

## 設計上の考慮事項

<!-- Coercions are a powerful tool that should be used responsibly.
On the one hand, they can allow an API to naturally follow the everyday rules of the domain being modeled.
This can be the difference between a bureaucratic mess of manual conversion functions and a clear program.
As Abelson and Sussman wrote in the preface to _Structure and Interpretation of Computer Programs_ (MIT Press, 1996), -->

強制は強力なツールであるが，責任をもって使用すべきです．一方で，モデル化したいドメインにおける日常的なルールにAPIを自然に従わせることが可能です．これは手動で変換を行う関数の官僚的な濫用と，明確なプログラムとの違いになり得ます．AbelsonとSussmanは _Structure and Interpretation of Computer Programs_ (MIT Press, 1996)の序文でこのように書いています．

<!-- > Programs must be written for people to read, and only incidentally for machines to execute. -->

> プログラムは人間が読むために書かれ，機械が実行するために付随的に書かれなければならない．
（Programs must be written for people to read, and only incidentally for machines to execute.）

<!-- Coercions, used wisely, are a valuable means of achieving readable code that can serve as the basis for communication with domain experts.
APIs that rely heavily on coercions have a number of important limitations, however.
Think carefully about these limitations before using coercions in your own libraries. -->

賢く使用される型強制は，ドメインのエキスパートとの対話の基礎となる，読みやすいコードを実現する貴重な手段です．しかし，強制に大きく依存するAPIには，いくつかの重要な制限があります．読者がライブラリで強制を利用したい際には，その前にこれらの制限についてよく考えてください．

<!-- First off, coercions are only applied in contexts where enough type information is available for Lean to know all of the types involved, because there are no output parameters in the coercion type classes. This means that a return type annotation on a function can be the difference between a type error and a successfully applied coercion.
For example, the coercion from non-empty lists to lists makes the following program work: -->

まず第一に，型強制はLeanが関係するすべての型を知るのに十分な型情報が利用可能なコンテキストでのみ適用されます．というのも強制の型クラスには出力パラメータが無いからです．これは関数の戻り値の型注釈が，型エラーとうまく適用された強制との違いになることを意味します．例えば，空でないリストからリストへの強制は以下のプログラムを動作させます：

```lean
{{#example_decl Examples/Classes.lean lastSpiderA}}
```
<!-- On the other hand, if the type annotation is omitted, then the result type is unknown, so Lean is unable to find the coercion: -->

一方で，型注釈が省略された場合，結果の型が不明であるため，Leanは強制を見つけることができません：

```lean
{{#example_in Examples/Classes.lean lastSpiderB}}
```
```output error
{{#example_out Examples/Classes.lean lastSpiderB}}
```
<!-- More generally, when a coercion is not applied for some reason, the user receives the original type error, which can make it difficult to debug chains of coercions. -->

より一般的には，何らかの理由で強制が適用されなかった場合，ユーザには元の型エラーが返され，強制の連鎖のデバッグを難しくします．

<!-- Finally, coercions are not applied in the context of field accessor notation.
This means that there is still an important difference between expressions that need to be coerced and those that don't, and this difference is visible to users of your API. -->

最後に，フィールドのアクセサ記法のコンテキストでは，強制は適用されません．つまり，強制する必要がある式とそうでない式の間にはまだ重要な違いがあり，この違いはAPIの利用者にも見えるということです．

