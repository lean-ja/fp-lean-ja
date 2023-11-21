<!-- # Functions and Definitions -->
# 関数と定義

<!-- In Lean, definitions are introduced using the `def` keyword. For instance, to define the name `{{#example_in Examples/Intro.lean helloNameVal}}` to refer to the string `{{#example_out Examples/Intro.lean helloNameVal}}`, write: -->

Lean では，定義は `def` というキーワードを使って導入されます．例えば, 文字列 `{{#example_out Examples/Intro.lean helloNameVal}}` を指す名前として `{{#example_in Examples/Intro.lean helloNameVal}}` を定義するには, こう書きます：

```lean
{{#example_decl Examples/Intro.lean hello}}
```

<!-- In Lean, new names are defined using the colon-equal operator`:=`
rather than `=`. This is because `=` is used to describe equalities
between existing expressions, and using two different operators helps
prevent confusion. -->

Lean では，新しい名前は `=` ではなくコロンと等号を組み合わせた記号 `:=` を使って定義されます．これは, `=` が既存の式同士の等式を表すのに使われるためで，異なる演算子を使うことで混乱を防ぐことができます．

<!-- In the definition of `{{#example_in Examples/Intro.lean helloNameVal}}`, the expression `{{#example_out Examples/Intro.lean helloNameVal}}` is simple enough that Lean is able to determine the definition's type automatically.
However, most definitions are not so simple, so it will usually be necessary to add a type.
This is done using a colon after the name being defined. -->

`{{#example_in Examples/Intro.lean helloNameVal}}` の定義の場合，`{{#example_out Examples/Intro.lean helloNameVal}}` という式は単純なので，Lean は定義の型を自動的に判断することができます．しかし，ほとんどの定義はそれほど単純ではないので，通常は型を注釈する必要があります．これは，定義する名前の後にコロンを使って行います．

```lean
{{#example_decl Examples/Intro.lean lean}}
```

<!-- Now that the names have been defined, they can be used, so -->

名前が定義されたら，それを使うことができます．

``` Lean
{{#example_in Examples/Intro.lean helloLean}}
```

<!-- outputs -->
上のコードは次を出力します．

``` Lean info
{{#example_out Examples/Intro.lean helloLean}}
```

<!-- In Lean, defined names may only be used after their definitions. -->

Lean では，定義されるまである名前を使うことはできません．

<!-- In many languages, definitions of functions use a different syntax than definitions of other values.
For instance, Python function definitions begin with the `def` keyword, while other definitions are defined with an equals sign.
In Lean, functions are defined using the same `def` keyword as other values.
Nonetheless, definitions such as `hello` introduce names that refer _directly_ to their values, rather than to zero-argument functions that return equivalent results each time they are called. -->

多くの言語では，関数の定義には他の値の定義とは異なる構文を使用します．例えば，Python の関数定義は `def` キーワードで始まりますが，他の定義は等号で定義されます．Lean では，関数も他の値と同じ `def` キーワードを使って定義されます．それにもかかわらず，`hello` のような定義は，呼び出されるたびに同等の結果を返すゼロ引数関数ではなく，その値を**直接**参照する名前を導入しています．

<!-- ## Defining Functions -->

## 関数の定義

<!-- There are a variety of ways to define functions in Lean. The simplest is to place the function's arguments before the definition's type, separated by spaces. For instance, a function that adds one to its argument can be written: -->

Lean で関数を定義するには様々な方法があります．最もシンプルな方法は，関数の引数を定義型の前にスペースで区切って置くことです．例えば，引数に1を加える関数はこう書けます：

```lean
{{#example_decl Examples/Intro.lean add1}}
```

<!-- Testing this function with `#eval` gives `{{#example_out Examples/Intro.lean add1_7}}`, as expected: -->

この関数を `#eval` でテストすると，予想通り `{{#example_out Examples/Intro.lean add1_7}}` が得られます：

```lean
{{#example_in Examples/Intro.lean add1_7}}
```

<!-- Just as functions are applied to multiple arguments by writing spaces between each argument, functions that accept multiple arguments are defined with spaces between the arguments' names and types. The function `maximum`, whose result is equal to the greatest of its two arguments, takes two `Nat` arguments `n` and `k` and returns a `Nat`. -->

関数が各引数の間にスペースを書くことで複数の引数に適用されるように, 複数の引数を受け付ける関数は, 引数の名前と型の間にスペースを入れることで定義されます．関数 `maximum` は，2つの引数の最大値を返すもので，2つの `Nat` 型引数 `n` と `k` を取り, `Nat` を返します．

```lean
{{#example_decl Examples/Intro.lean maximum}}
```

<!-- When a defined function like `maximum` has been provided with its arguments, the result is determined by first replacing the argument names with the provided values in the body, and then evaluating the resulting body. For example: -->

`maximum` のような定義された関数が引数とともに提供されると，結果は，まず引数名を与えられた値に置き換え，次に本体を評価するというように決定されます．例えば：

```lean
{{#example_eval Examples/Intro.lean maximum_eval}}
```

<!-- Expressions that evaluate to natural numbers, integers, and strings have types that say this (`Nat`, `Int`, and `String`, respectively).
This is also true of functions.
A function that accepts a `Nat` and returns a `Bool` has type `Nat → Bool`, and a function that accepts two `Nat`s and returns a `Nat` has type `Nat → Nat → Nat`. -->

自然数, 整数, 文字列を表す式は, それぞれ `Nat`, `Int`, `String` 型を持ちます．`Nat` を受け取って `Bool` を返す関数は `Nat → Bool` 型を持ち，2つの `Nat` を受け取って `Nat` を返す関数は `Nat → Nat → Nat` 型を持ちます．

<!-- As a special case, Lean returns a function's signature when its name is used directly with `#check`.
Entering `{{#example_in Examples/Intro.lean add1sig}}` yields `{{#example_out Examples/Intro.lean add1sig}}`.
However, Lean can be "tricked" into showing the function's type by writing the function's name in parentheses, which causes the function to be treated as an ordinary expression, so `{{#example_in Examples/Intro.lean add1type}}` yields `{{#example_out Examples/Intro.lean add1type}}` and `{{#example_in Examples/Intro.lean maximumType}}` yields `{{#example_out Examples/Intro.lean maximumType}}`.
This arrow can also be written with an ASCII alternative arrow `->`, so the preceding function types can be written `{{#example_out Examples/Intro.lean add1typeASCII}}` and `{{#example_out Examples/Intro.lean maximumTypeASCII}}`, respectively. -->

特別な場合として, Lean は関数名が `#check` で直接使われた場合, その関数のシグネチャを返します．`{{#example_in Examples/Intro.lean add1sig}}` と入力すると，`{{#example_out Examples/Intro.lean add1sig}}` が得られます．しかし，関数名を括弧で囲むことで関数の型を示すように Lean を「騙す」ことができます．したがって `{{#example_in Examples/Intro.lean add1type}}` は `{{#example_out Examples/Intro.lean add1type}}` という出力を返し，`{{#example_in Examples/Intro.lean maximumType}}` は `{{#example_out Examples/Intro.lean maximumType}}` という出力を返します．この矢印は ASCII の代替矢印 `->` で書くこともできるので，先の関数型はそれぞれ `{{#example_out Examples/Intro.lean add1typeASCII}}`，`{{#example_out Examples/Intro.lean maximumTypeASCII}}` と書くことができます．

<!-- Behind the scenes, all functions actually expect precisely one argument.
Functions like `maximum` that seem to take more than one argument are in fact functions that take one argument and then return a new function.
This new function takes the next argument, and the process continues until no more arguments are expected.
This can be seen by providing one argument to a multiple-argument function: `{{#example_in Examples/Intro.lean maximum3Type}}` yields `{{#example_out Examples/Intro.lean maximum3Type}}` and `{{#example_in Examples/Intro.lean stringAppendHelloType}}` yields `{{#example_out Examples/Intro.lean stringAppendHelloType}}`.
Using a function that returns a function to implement multiple-argument functions is called _currying_ after the mathematician Haskell Curry.
Function arrows associate to the right, which means that `Nat → Nat → Nat` should be parenthesized `Nat → (Nat → Nat)`. -->

舞台裏では，すべての関数は実際にはちょうど1つの引数を受け付けます．複数の引数を取るように見える `max` 関数などは, 実際には1つの引数を取って新しい関数を返す関数です．この新しい関数は次の引数を取り, その処理は引数がなくなるまで続きます．これは, 複数の引数を持つ関数に1つの引数を与えることでわかります：`{{#example_in Examples/Intro.lean maximum3Type}}` は `{{#example_out Examples/Intro.lean maximum3Type}}` を返し，`{{#example_in Examples/Intro.lean stringAppendHelloType}}` は `{{#example_out Examples/Intro.lean stringAppendHelloType}}` を返します.複数引数の関数を実装するために関数を返す関数を使うことを，数学者のハスケル・カリー(Haskell Curry)にちなんで**カリー化**(currying)と呼びます．矢印は右結合です．つまり, `Nat → Nat → Nat` に括弧を付けるなら `Nat → (Nat → Nat)` となります．

<!-- ### Exercises -->
### 演習

 <!-- * Define the function `joinStringsWith` with type `String -> String -> String -> String` that creates a new string by placing its first argument between its second and third arguments. `{{#example_eval Examples/Intro.lean joinStringsWithEx 0}}` should evaluate to `{{#example_eval Examples/Intro.lean joinStringsWithEx 1}}`. -->
 * 関数 `joinStringsWith` を `String -> String -> String -> String` 型の関数であって，その第一引数を第二引数と第三引数の間に配置して新しい文字列を作成するようなものとして定義してください．`{{#example_eval Examples/Intro.lean joinStringsWithEx 0}}` は `{{#example_eval Examples/Intro.lean joinStringsWithEx 1}}` に等しくなるはずです.
 <!-- * What is the type of `joinStringsWith ": "`? Check your answer with Lean. -->
 * `joinStringsWith ": "` の型は何でしょうか？ Lean で答えを確認してください．
 <!-- * Define a function `volume` with type `Nat → Nat → Nat → Nat` that computes the volume of a rectangular prism with the given height, width, and depth. -->
 * 与えられた高さ，幅，奥行きを持つ直方体の体積を計算する関数 `volume` を `Nat → Nat → Nat → Nat` 型の関数として定義してください．

<!-- ## Defining Types -->
## 型の定義

<!-- Most typed programming languages have some means of defining aliases for types, such as C's `typedef`.
In Lean, however, types are a first-class part of the language - they are expressions like any other.
This means that definitions can refer to types just as well as they can refer to other values. -->

ほとんどの型付きプログラミング言語には, C 言語の `typedef` のように, 型のエイリアスを定義する手段があります．しかし Lean では, 型は言語の第一級の部分であり, 他の式と同じように扱われます．これは, 定義が他の値を参照するのと同様に, 型を参照できることを意味します．

<!-- For instance, if ``String`` is too much to type, a shorter abbreviation ``Str`` can be defined: -->

例えば，`String` が入力するには長すぎる場合, より短い省略形 `Str` を定義することができます：

```lean
{{#example_decl Examples/Intro.lean StringTypeDef}}
```

<!-- It is then possible to use ``Str`` as a definition's type instead of ``String``: -->

そうすれば, `String` の代わりに `Str` を定義の型として使うことができます：

```lean
{{#example_decl Examples/Intro.lean aStr}}
```

<!-- The reason this works is that types follow the same rules as the rest of Lean.
Types are expressions, and in an expression, a defined name can be replaced with its definition.
Because ``Str`` has been defined to mean ``String``, the definition of ``aStr`` makes sense. -->

これが機能するのは，型が Lean の他の部分と同じルールに従うからです．型は式であり，式の中では，定義された名前はその定義に置き換えることができます．`Str` は `String` に等しいと定義されているので, `aStr` の定義は意味をなしています．

<!-- ### Messages You May Meet -->
### よくあるエラー

<!-- Experimenting with using definitions for types is made more complicated by the way that Lean supports overloaded integer literals.
If ``Nat`` is too short, a longer name ``NaturalNumber`` can be defined: -->

型を定義するとき，Lean がオーバーロードされた整数リテラルをサポートする方法との兼ね合いで，より複雑な挙動をすることがあります．`Nat` が短すぎる場合は，`NaturalNumber` という長い名前を定義することができます：

```lean
{{#example_decl Examples/Intro.lean NaturalNumberTypeDef}}
```

<!-- However, using ``NaturalNumber`` as a definition's type instead of ``Nat`` does not have the expected effect.
In particular, the definition: -->

しかし，`Nat` の代わりに `NaturalNumber` を定義の型として使っても，期待した効果は得られません．例えば，以下のように定義したとします：

```lean
{{#example_in Examples/Intro.lean thirtyEight}}
```

<!-- results in the following error: -->
これは次のようなエラーになります：

```output error
{{#example_out Examples/Intro.lean thirtyEight}}
```

<!-- This error occurs because Lean allows number literals to be _overloaded_.
When it makes sense to do so, natural number literals can be used for new types, just as if those types were built in to the system.
This is part of Lean's mission of making it convenient to represent mathematics, and different branches of mathematics use number notation for very different purposes.
The specific feature that allows this overloading does not replace all defined names with their definitions before looking for overloading, which is what leads to the error message above. -->

このエラーは, Lean が数値リテラルのオーバーロード(overload)を許可しているために発生します．自然数リテラルは，あたかもその型がシステムに組み込まれているかのように，新しい型に使用することができます．これは，数学の表現を便利にするという Lean の使命の一部です．数学でも分野によって，数字をまったく異なる概念を表すのに使っています．このオーバーロードを可能にするための機能は，定義された名前をすべてその定義に置き換える前に，オーバーロードを探します．それが上のエラーメッセージを引き起こします．

<!-- One way to work around this limitation is by providing the type `Nat` on the right-hand side of the definition, causing `Nat`'s overloading rules to be used for `38`: -->

このエラーを回避する1つの方法は，定義の右側に `Nat` 型を指定し，`Nat` のオーバーロード・ルールを `38` に使用させることです：

```lean
{{#example_decl Examples/Intro.lean thirtyEightFixed}}
```
<!-- The definition is still type-correct because `{{#example_eval Examples/Intro.lean NaturalNumberDef 0}}` is the same type as `{{#example_eval Examples/Intro.lean NaturalNumberDef 1}}`—by definition! -->

`{{#example_eval Examples/Intro.lean NaturalNumberDef 0}}` は定義から `{{#example_eval Examples/Intro.lean NaturalNumberDef 1}}` と同じ型なので，この定義は正しく型付けされています．

<!-- Another solution is to define an overloading for `NaturalNumber` that works equivalently to the one for `Nat`.
This requires more advanced features of Lean, however. -->

もう一つの解決策は, `Nat` と同等に機能する `NaturalNumber` のオーバーロードを定義することです．しかし, これには Lean のより高度な機能が必要です．

<!-- Finally, defining the new name for `Nat` using `abbrev` instead of `def` allows overloading resolution to replace the defined name with its definition.
Definitions written using `abbrev` are always unfolded.
For instance, -->

最後の解決策は，`def` の代わりに `abbrev` を使って `Nat` の新しい名前を定義することです．これで定義された名前をその定義に置き換えるオーバーロード解決が可能になります．`abbrev` を使って書かれた定義は常に展開されます．例えば

```lean
{{#example_decl Examples/Intro.lean NTypeDef}}
```
<!-- and -->
としたとき
```lean
{{#example_decl Examples/Intro.lean thirtyNine}}
```
<!-- are accepted without issue. -->
はエラーになりません．

<!-- Behind the scenes, some definitions are internally marked as being unfoldable during overload resolution, while others are not.
Definitions that are to be unfolded are called _reducible_.
Control over reducibility is essential to allow Lean to scale: fully unfolding all definitions can result in very large types that are slow for a machine to process and difficult for users to understand.
Definitions produced with `abbrev` are marked as reducible. -->

舞台裏では, オーバーロードの解決時に, 展開可能(unfoldable)であると内部でマークされる定義もあれば，そうでない定義もあります．展開される定義は *reducible* (簡約可能)と呼ばれます．Lean をスケールさせるためには，定義の展開可能性のコントロールが不可欠です：すべての定義を完全に展開すると, 型が非常に大きくなり, 機械が処理するのに時間がかかりますし, ユーザにとっても理解しづらいものになります．`abbrev` で生成された定義は reducible であるとマークされます．