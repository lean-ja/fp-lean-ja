<!-- # Polymorphism -->
# 多相性

<!-- Just as in most languages, types in Lean can take arguments.
For instance, the type `List Nat` describes lists of natural numbers, `List String` describes lists of strings, and `List (List Point)` describes lists of lists of points.
This is very similar to `List<Nat>`, `List<String>`, or `List<List<Point>>` in a language like C# or Java.
Just as Lean uses a space to pass an argument to a function, it uses a space to pass an argument to a type. -->

ほとんどの言語と同じように，Leanの型も引数を取ることができます．例えば，`List.Nat`型は自然数のリストを意味し，`List.String`型は文字列のリストを，`List (List Point)`型は点のリストのリストを意味します．これはC#やJavaのような言語における型の書き方である`List<Nat>`，`List<String>`，`List<List<Point>>`に非常に似ています．Leanが関数に引数を渡すときにスペースを使うように，型に引数を渡すときにもスペースを使います．

<!-- In functional programming, the term _polymorphism_ typically refers to datatypes and definitions that take types as arguments.
This is different from the object-oriented programming community, where the term typically refers to subclasses that may override some behavior of their superclass.
In this book, "polymorphism" always refers to the first sense of the word.
These type arguments can be used in the datatype or definition, which allows the same datatype or definition to be used with any type that results from replacing the arguments' names with some other types. -->

関数型プログラミングでは，_polymorphism_(多相性)という用語は通常，引数にとるデータ型や定義を指します．これは多相性をスーパークラスのふるまいをオーバーライドするサブクラスのことを指すオブジェクト指向プログラミングのコミュニティとは異なる点です．本書では，「多相性」は常に最初の意味を指します．これらの型引数はデータ型や定義で使用することができ，引数の名前をほかの型に置き換えることで，同じデータ型や定義を任意の型で使用できるようになります．

<!-- The `Point` structure requires that both the `x` and `y` fields are `Float`s.
There is, however, nothing about points that require a specific representation for each coordinate.
A polymorphic version of `Point`, called `PPoint`, can take a type as an argument, and then use that type for both fields: -->

`Point`構造体は`x`と`y`フィールドの両方が`Float`型である必要があります．しかし，点について各座標の表現に特化している必要はありません．`Point`の多相バージョン``PPoint`は，型を引数として受け取り，その型を両方のフィールドに使用することができます:

```lean
{{#example_decl Examples/Intro.lean PPoint}}
```
<!-- Just as a function definition's arguments are written immediately after the name being defined, a structure's arguments are written immediately after the structure's name.
It is customary to use Greek letters to name type arguments in Lean when no more specific name suggests itself.
`Type` is a type that describes other types, so `Nat`, `List String`, and `PPoint Int` all have type `Type`. -->

関数定義の引数が定義された関数名の直後に書かれるように，構造体の引数も構造体名の直後に書かれます．引数自体から示唆される具体的な名前がない場合には，Leanの型引数名にはギリシャ文字を使うのが通例です．型`Type`はほかの型を記述する型であるため，`Nat`や`List String`，`Point Int`はすべて`Type`型を持ちます．

<!-- Just like `List`, `PPoint` can be used by providing a specific type as its argument: -->

`List`型のように，`PPoint`も引数に特定の型を指定することで使用できます:

```lean
{{#example_decl Examples/Intro.lean natPoint}}
```
<!-- In this example, both fields are expected to be `Nat`s.
Just as a function is called by replacing its argument variables with its argument values, providing `PPoint` with the type `Nat` as an argument yields a structure in which the fields `x` and `y` have the type `Nat`, because the argument name `α` has been replaced by the argument type `Nat`.
Types are ordinary expressions in Lean, so passing arguments to polymorphic types (like `PPoint`) doesn't require any special syntax. -->

この例では，両方のフィールドが`Nat`であることが期待されます．関数が引数の変数を引数の値に置き換えて呼び出されるのと同じように，`PPoint`に`Nat`型を引数として与えると，引数名`α`が引数の型`Nat`に置き換えられることでフィールド`x`と`y`が`Nat`型を持つ構造体が生成されます．型はLeanでは普通の式なので，（`PPoint`型のような）多相型に引数を渡すときに特別な構文は必要ありません．

<!-- Definitions may also take types as arguments, which makes them polymorphic.
The function `replaceX` replaces the `x` field of a `PPoint` with a new value.
In order to allow `replaceX` to work with _any_ polymorphic point, it must be polymorphic itself.
This is achieved by having its first argument be the type of the point's fields, with later arguments referring back to the first argument's name. -->

定義は引数として型を取ることもでき，それによって多相なものになります．`replaceX`は`PPoint`の`x`フィールドを新しい値に置き換える関数です．`replaceX`が _任意の_多相な点で動作するようにするには，`replaceX`自身が多相でなければなりません．これは，最初の引数をポイントのフィールドの型とし，それ以降の引数は最初の引数の名前を参照することで実現されます．

```lean
{{#example_decl Examples/Intro.lean replaceX}}
```
<!-- In other words, when the types of the arguments `point` and `newX` mention `α`, they are referring to _whichever type was provided as the first argument_.
This is similar to the way that function argument names refer to the values that were provided when they occur in the function's body. -->

言い換えると，引数`point`と`newX`の型が`α`を参照している場合，それらは_最初の引数として提供されたいずれかの型_を参照していることになります．これは，関数の引数名が関数内に現れたときに，提供された値を参照する方法と似ています．

<!-- This can be seen by asking Lean to check the type of `replaceX`, and then asking it to check the type of `replaceX Nat`. -->

この事実は`replaceX`の型をチェックし，次に`replaceX Nat`の型をチェックすることで確認できます．

```lean
{{#example_in Examples/Intro.lean replaceXT}}
```
```output info
{{#example_out Examples/Intro.lean replaceXT}}
```
<!-- This function type includes the _name_ of the first argument, and later arguments in the type refer back to this name.
Just as the value of a function application is found by replacing the argument name with the provided argument value in the function's body, the type of a function application is found by replacing the argument's name with the provided value in the function's return type.
Providing the first argument, `Nat`, causes all occurrences of `α` in the remainder of the type to be replaced with `Nat`: -->

この関数型には最初の引数の_名前_が含まれ，その後に続く引数ではこの名前を参照します．関数適用の値が関数本体の引数名を提供された引数の値に置き換えることで導出されるのと同じように，関数適用の型は，引数名を関数の戻り値の型で与えられる値に置き換えることで導かれます．最初の引数に`Nat`を指定すると，残りの型に含まれるすべての`α`が`Nat`に置き換えられます:

```lean
{{#example_in Examples/Intro.lean replaceXNatT}}
```
```output info
{{#example_out Examples/Intro.lean replaceXNatT}}
```
<!-- Because the remaining arguments are not explicitly named, no further substitution occurs as more arguments are provided: -->

`α`以降の残りの引数には明示的に名前が付けられていないので，引数が増えてもそれ以上の置換は起きません:

```lean
{{#example_in Examples/Intro.lean replaceXNatOriginT}}
```
```output info
{{#example_out Examples/Intro.lean replaceXNatOriginT}}
```
```lean
{{#example_in Examples/Intro.lean replaceXNatOriginFiveT}}
```
```output info
{{#example_out Examples/Intro.lean replaceXNatOriginFiveT}}
```
<!-- The fact that the type of the whole function application expression was determined by passing a type as an argument has no bearing on the ability to evaluate it. -->

関数適用の式全体の型が引数に型を渡すことによって決定されるという事実は，その式を評価する機能には関係がありません．

```lean
{{#example_in Examples/Intro.lean replaceXNatOriginFiveV}}
```
```output info
{{#example_out Examples/Intro.lean replaceXNatOriginFiveV}}
```

<!-- Polymorphic functions work by taking a named type argument and having later types refer to the argument's name.
However, there's nothing special about type arguments that allows them to be named.
Given a datatype that represents positive or negative signs: -->

多相関数は名前付きの型引数を取り，その後の引数の型が当該の引数の名前を参照することで機能します．しかし，型引数について名前を付けられたことによる特別なことは何もありません．例えば正負の符号を表すデータ型が与えられたとします:

```lean
{{#example_decl Examples/Intro.lean Sign}}
```
<!-- it is possible to write a function whose argument is a sign.
If the argument is positive, the function returns a `Nat`, while if it's negative, it returns an `Int`: -->

ここで引数が符号である関数を書くことができます．もし引数が正なら，この関数は`Nat`を返し，負なら`Int`を返します:

```lean
{{#example_decl Examples/Intro.lean posOrNegThree}}
```
<!-- Because types are first class and can be computed using the ordinary rules of the Lean language, they can be computed by pattern-matching against a datatype.
When Lean is checking this function, it uses the fact that the `match`-expression in the function's body corresponds to the `match`-expression in the type to make `Nat` be the expected type for the `pos` case and to make `Int` be the expected type for the `neg` case. -->

型は第一級であり，Leanの言語として通常のルールで計算することができるため，データ型に対するパターンマッチで計算することができます．Leanがこの関数をチェックするとき，関数本体の`match`式がデータ型の`match`式に対応することを利用して，`pos`の場合は`Nat`を，`neg`の場合は`Int`を期待される型にします．

<!-- Applying `posOrNegThree` to `Sign.pos` results in the argument name `s` in both the body of the function and its return type being replaced by `Sign.pos`.
Evaluation can occur both in the expression and its type: -->

`posOrNegThree`を`Sign.pos`に適用すると，関数本体と戻り値の型の両方の引数名`s`が`Sign.pos`に置き換えられます．評価は式と型の両方で行われます:

```lean
{{#example_eval Examples/Intro.lean posOrNegThreePos}}
```

<!-- ## Linked Lists -->

## 連結リスト

<!-- Lean's standard library includes a canonical linked list datatype, called `List`, and special syntax that makes it more convenient to use.
Lists are written in square brackets.
For instance, a list that contains the prime numbers less than 10 can be written: -->

Leanの標準ライブラリには，`List`と呼ばれる標準的な連結リストのデータ型と，それをより便利に使うための特別な構文が含まれています．リストを記述するには角括弧を使います．例えば10未満の素数が格納されたリストは次のように書くことができます:

```lean
{{#example_decl Examples/Intro.lean primesUnder10}}
```

<!-- Behind the scenes, `List` is an inductive datatype, defined like this: -->

この裏側では，`List`は帰納的データ型として次のような感じで定義されています:

```lean
{{#example_decl Examples/Intro.lean List}}
```
<!-- The actual definition in the standard library is slightly different, because it uses features that have not yet been presented, but it is substantially similar.
This definition says that `List` takes a single type as its argument, just as `PPoint` did.
This type is the type of the entries stored in the list.
According to the constructors, a `List α` can be built with either `nil` or `cons`.
The constructor `nil` represents empty lists and the constructor `cons` is used for non-empty lists.
The first argument to `cons` is the head of the list, and the second argument is its tail.
A list that contains \\( n \\) entries contains \\( n \\) `cons` constructors, the last of which has `nil` as its tail. -->

標準ライブラリでの実際の定義は，まだ発表されていない機能を使用しているため若干異なりますが，実質的には似たものになっています．この定義によると，`List`は`PPoint`と同様に引数として型を1つ取ります．この型はリストに格納される要素の型です．コンストラクタによれば，`List α`は`nil`または`cons`のどちらかで構築することができます．コンストラクタ`nil`は空のリストを，コンストラクタ`cons`は空でないリストを表します．`cons`の第1引数はリストの先頭で，第2引数はその後ろに連なるリストです．\\( n \\)個の要素を含むリストには\\( n \\)個の`cons`コンストラクタが含まれ，最後の`cons`コンストラクタの後ろには`nil`が続きます．

<!-- The `primesUnder10` example can be written more explicitly by using `List`'s constructors directly: -->

`primesUnder10`の例は，`List`のコンストラクタを直接使うことでより明示的に書くことができます．

```lean
{{#example_decl Examples/Intro.lean explicitPrimesUnder10}}
```
These two definitions are completely equivalent, but `primesUnder10` is much easier to read than `explicitPrimesUnder10`.

これら2つの定義は完全に等価ですが，`explicitPrimesUnder10`よりも`primesUnder10`の方がはるかに読みやすいでしょう．

<!-- Functions that consume `List`s can be defined in much the same way as functions that consume `Nat`s.
Indeed, one way to think of a linked list is as a `Nat` that has an extra data field dangling off each `succ` constructor.
From this point of view, computing the length of a list is the process of replacing each `cons` with a `succ` and the final `nil` with a `zero`.
Just as `replaceX` took the type of the fields of the point as an argument, `length` takes the type of the list's entries.
For example, if the list contains strings, then the first argument is `String`: `{{#example_eval Examples/Intro.lean length1EvalSummary 0}}`.
It should compute like this: -->

`List`を受け付けるような関数は`Nat`を取る関数と同じように定義することができます．実際，連結リストは，各`succ`コンストラクタに余分なデータフィールドがぶら下がったような`Nat`と考えることもできます．この観点からすると，リストの長さを計算することは，各`cons`を`succ`に置き換え，最後の`nil`を`zero`に置き換える処理です．`replaceX`が点のフィールドの型を引数に取ったように，`length`はリストの要素の型を引数に取ります．例えば，リストに文字列が含まれている場合，最初の引数は`String`: `{{#example_eval Examples/Intro.lean length1EvalSummary 0}}`です．これは次のように計算されます:

```
{{#example_eval Examples/Intro.lean length1EvalSummary}}
```

<!-- The definition of `length` is both polymorphic (because it takes the list entry type as an argument) and recursive (because it refers to itself).
Generally, functions follow the shape of the data: recursive datatypes lead to recursive functions, and polymorphic datatypes lead to polymorphic functions. -->

`length`の定義は多相的であり（リストの要素の型を引数にとるため），また再帰的です（自分自身を参照するため）．一般的に，関数はデータの形に従います: 再帰的なデータ型は再帰的な関数を導き，多相的なデータ型は多相的な関数を導きます．

```lean
{{#example_decl Examples/Intro.lean length1}}
```

<!-- Names such as `xs` and `ys` are conventionally used to stand for lists of unknown values.
The `s` in the name indicates that they are plural, so they are pronounced "exes" and "whys" rather than "x s" and "y s". -->

`xs`や`ys`といった名前は，未知の値のリストを表すために慣例的に使用されます．名前の中の`s`は複数形であることを示すので，「x s(エックスス)」や「y s(ワイス)」ではなく，「エクセズ(exes)」や「ワイズ(whys)」と発音されます．

<!-- To make it easier to read functions on lists, the bracket notation `[]` can be used to pattern-match against `nil`, and an infix `::` can be used in place of `cons`: -->

リスト上の関数を読みやすくするために，`[]`という括弧記法を使って`nil`に対してパターンマッチを行うことができ，`cons`の代わりに`::`という中置記法を使うことができます．

```lean
{{#example_decl Examples/Intro.lean length2}}
```

<!-- ## Implicit Arguments -->

## 暗黙の引数

<!-- Both `replaceX` and `length` are somewhat bureaucratic to use, because the type argument is typically uniquely determined by the later values.
Indeed, in most languages, the compiler is perfectly capable of determining type arguments on its own, and only occasionally needs help from users.
This is also the case in Lean.
Arguments can be declared _implicit_ by wrapping them in curly braces instead of parentheses when defining a function.
For instance, a version of `replaceX` with an implicit type argument looks like this: -->

`replaceX`と`length`はどちらも使うにはややお役所的です，というのも型引数は一般的にその後の引数の値で一意に決まるからです．実際，たいていの言語では，コンパイラが型引数を自分で決定する完璧な能力を備えており，ユーザの助けが必要になることはまれです．これはLeanでも同様です．関数を定義するときに，丸括弧の代わりに波括弧で囲むことで引数を _暗黙的に_ 宣言することができます．例えば，暗黙の型引数を持つバージョンの`replaceX`は次のようになります:

```lean
{{#example_decl Examples/Intro.lean replaceXImp}}
```
<!-- It can be used with `natOrigin` without providing `Nat` explicitly, because Lean can _infer_ the value of `α` from the later arguments: -->

この関数は`natOrigin`に用いる際に`Nat`を明示的に渡すことなく使えます，なぜならLeanは後の引数から`α`の値を _推測_ することができるからです:

```lean
{{#example_in Examples/Intro.lean replaceXImpNat}}
```
```output info
{{#example_out Examples/Intro.lean replaceXImpNat}}
```

<!-- Similarly, `length` can be redefined to take the entry type implicitly: -->

同様に，`length`も暗黙的に要素の型を取るように再定義できます:

```lean
{{#example_decl Examples/Intro.lean lengthImp}}
```
<!-- This `length` function can be applied directly to `primesUnder10`: -->

この`length`関数は`primesUnder10`に直接適用できます:

```lean
{{#example_in Examples/Intro.lean lengthImpPrimes}}
```
```output info
{{#example_out Examples/Intro.lean lengthImpPrimes}}
```

<!-- In the standard library, Lean calls this function `List.length`, which means that the dot syntax that is used for structure field access can also be used to find the length of a list: -->

標準ライブラリにて，この関数は`List.length`と呼ばれています．つまり，構造体フィールドへのアクセスに使われるドット構文がリストの長さを求めるのにも使えるということです:

```lean
{{#example_in Examples/Intro.lean lengthDotPrimes}}
```
```output info
{{#example_out Examples/Intro.lean lengthDotPrimes}}
```


<!-- Just as C# and Java require type arguments to be provided explicitly from time to time, Lean is not always capable of finding implicit arguments.
In these cases, they can be provided using their names.
For instance, a version of `List.length` that only works for lists of integers can be specified by setting `α` to `Int`: -->

C#やJavaなどにおいて時折，型引数を明示的に提供することを要求するように，Leanが暗黙の引数がなんであるかわかるとは限りません．このような場合，引数をその名前を使って指定することができます．例えば，`List.length`を整数のリストに対してのみ動作するようにするには，`α`に`Int`を設定します:

```lean
{{#example_in Examples/Intro.lean lengthExpNat}}
```
```output info
{{#example_out Examples/Intro.lean lengthExpNat}}
```

<!-- ## More Built-In Datatypes -->

## その他の組み込みのデータ型

<!-- In addition to lists, Lean's standard library contains a number of other structures and inductive datatypes that can be used in a variety of contexts. -->

リストに加えて，Leanの標準ライブラリには，様々なコンテキストで使用できる構造や帰納的データ型が数多く含まれています．

### `Option`
<!-- Not every list has a first entry—some lists are empty.
Many operations on collections may fail to find what they are looking for.
For instance, a function that finds the first entry in a list may not find any such entry.
It must therefore have a way to signal that there was no first entry. -->

すべてのリストに先頭の要素があるとは限りません．空のリストも存在します．データの集まりに対する操作においては探しているものが見つけられないことが多々あります．例えば，リストの先頭の要素を見つける関数は，該当する要素を見つけられないかもしれません．そのため，先頭の要素がないことを知らせる方法が必要です．

<!-- Many languages have a `null` value that represents the absence of a value.
Instead of equipping existing types with a special `null` value, Lean provides a datatype called `Option` that equips some other type with an indicator for missing values.
For instance, a nullable `Int` is represented by `Option Int`, and a nullable list of strings is represented by the type `Option (List String)`.
Introducing a new type to represent nullability means that the type system ensures that checks for `null` cannot be forgotten, because an `Option Int` can't be used in a context where an `Int` is expected. -->

多くの言語には，値がないことを表す`null`という値があります．既存の型に特別な`null`値を持たせる代わりに，Leanでは`Option`と呼ばれる何かしらの型に値がないことを示すものを合わせた型が提供されています．例えば，nullを許容する`Int`は`Option Int`で，nullを許容する文字列のリストは`Option (List String)`型で表現されます．nullの許容を表すために新しい型を導入するということは，型システムが`null`のチェックを忘れえないことを意味します．なぜなら`Option Int`は`Int`が期待されるコンテキストで使うことができないからです．

<!-- `Option` has two constructors, called `some` and `none`, that respectively represent the non-null and null versions of the underlying type.
The non-null constructor, `some`, contains the underlying value, while `none` takes no arguments: -->

`Option`には`some`と`none`という2つのコンストラクタがあり，それぞれベースとなる型の非null版とnull版を表します．非null版のコンストラクタ`some`にはベースとなる値が格納され，`none`には引数は渡されません:

```lean
{{#example_decl Examples/Intro.lean Option}}
```

<!-- The `Option` type is very similar to nullable types in languages like C# and Kotlin, but it is not identical.
In these languages, if a type (say, `Boolean`) always refers to actual values of the type (`true` and `false`), the type `Boolean?` or `Nullable<Boolean>` additionally admits the `null` value.
Tracking this in the type system is very useful: the type checker and other tooling can help programmers remember to check for null, and APIs that explicitly describe nullability through type signatures are more informative than ones that don't.
However, these nullable types differ from Lean's `Option` in one very important way, which is that they don't allow multiple layers of optionality.
`{{#example_out Examples/Intro.lean nullThree}}` can be constructed with `{{#example_in Examples/Intro.lean nullOne}}`, `{{#example_in Examples/Intro.lean nullTwo}}`, or `{{#example_in Examples/Intro.lean nullThree}}`.
C#, on the other hand, forbids multiple layers of nullability by only allowing `?` to be added to non-nullable types, while Kotlin treats `T??` as being equivalent to `T?`.
This subtle difference is rarely relevant in practice, but it can matter from time to time. -->

`Option`型はC#やKotlinなどの言語のnullable型に非常に似ていますが，同じではありません．これらの言語では，ある型（例えば`Boolean`）が常にその型の実際の値（`true`と`false`）を参照する場合，`Boolean?`型または`Nullable<Boolean>`型は`null`値を元の型に追加する形で許容します．それらの型システムにおいてこの型をなぞるのは非常に有用です: 型チェッカやそのほかのツールはプログラマがnullのチェックを忘れないようにするのに役立ちますし，型シグネチャで明示的にnull許容性を記述しているAPIはそうでないAPIよりも有益です．しかし，これらのnull許容な型はLeanの`Option`とは非常に重要な点で異なります．`{{#example_out Examples/Intro.lean nullThree}}`は`{{#example_in Examples/Intro.lean nullOne}}`か`{{#example_in Examples/Intro.lean nullTwo}}`，`{{#example_in Examples/Intro.lean nullThree}}`で構築できます．一方でC#はnull許容ではない型に対して`?`を1つだけつけることを許容しており，複数層のnull許容型を禁じています．またKotlinでは`T??`は`T?`と同じものとして取り扱われます．この微妙な違いは実際にはほとんど関係ありませんが，時折問題になることがあります．

<!-- To find the first entry in a list, if it exists, use `List.head?`.
The question mark is part of the name, and is not related to the use of question marks to indicate nullable types in C# or Kotlin.
In the definition of `List.head?`, an underscore is used to represent the tail of the list.
In patterns, underscores match anything at all, but do not introduce variables to refer to the matched data.
Using underscores instead of names is a way to clearly communicate to readers that part of the input is ignored. -->

リストの先頭の要素を探すには，もし存在するなら`List.head?`を使用します．はてなマークは名前の一部であり，C#やKotlinでnull可能な型を示すためにはてなマークを使用することとは無関係です．`List.head?`の定義では，リストの後続を表すためにアンダースコアが使われています．この場合，アンダースコアはあらゆるものにマッチしますが，マッチしたデータを参照する変数を導入することはできません．名前の代わりにアンダースコアを使うことで，読者に入力の一部が無視されることを明確に伝えることができます．

```lean
{{#example_decl Examples/Intro.lean headHuh}}
```
<!-- A Lean naming convention is to define operations that might fail in groups using the suffixes `?` for a version that returns an `Option`, `!` for a version that crashes when provided with invalid input, and `D` for a version that returns a default value when the operation would otherwise fail.
For instance, `head` requires the caller to provide mathematical evidence that the list is not empty, `head?` returns an `Option`, `head!` crashes the program when passed an empty list, and `headD` takes a default value to return in case the list is empty.
The question mark and exclamation mark are part of the name, not special syntax, as Lean's naming rules are more liberal than many languages. -->

Leanの命名規則として失敗する可能性のある操作について，`Option`を返すものには`?`を，無効な入力が渡されたらクラッシュするものには`!`を，失敗するときにデフォルト値を返すものには`D`を接尾辞としてそれぞれ定義します．例えば，`head`は呼び出し元に対して，渡されたリストが空でないという数学的な証拠の提示を要求します．`head?`は`Option`を返し，`head!`は空のリストを渡されたときにプログラムをクラッシュさせ，`headD`はリストが空の場合に返すデフォルト値を取ります．はてなマークとビックリマークは名前の一部であり，特別な構文ではありません．このようにLeanの命名規則は多くの言語に比べて自由です．

<!-- Because `head?` is defined in the `List` namespace, it can be used with accessor notation: -->

`head?`は`List`名前空間で定義されているため，アクセサ記法を使うことができます:

```lean
{{#example_in Examples/Intro.lean headSome}}
```
```output info
{{#example_out Examples/Intro.lean headSome}}
```
<!-- However, attempting to test it on the empty list leads to two errors: -->

しかし，これを空リストで試そうとすると，以下の2つのエラーを出します:

```lean
{{#example_in Examples/Intro.lean headNoneBad}}
```
```output error
{{#example_out Examples/Intro.lean headNoneBad}}

{{#example_out Examples/Intro.lean headNoneBad2}}
```
<!-- This is because Lean was unable to fully determine the expression's type.
In particular, it could neither find the implicit type argument to `List.head?`, nor could it find the implicit type argument to `List.nil`.
In Lean's output, `?m.XYZ` represents a part of a program that could not be inferred.
These unknown parts are called _metavariables_, and they occur in some error messages.
In order to evaluate an expression, Lean needs to be able to find its type, and the type was unavailable because the empty list does not have any entries from which the type can be found.
Explicitly providing a type allows Lean to proceed: -->

これはLeanが式の型を完全に決定できなかったためです．特に，`List.head?`の暗黙の型引数だけでなく，`List.nil`の暗黙の型引数も見つけることができていません．Leanの出力での`?m.XYZ`は推論できなかったプログラムの一部を表しています．これらの未知の部分は _メタ変数_ と呼ばれ，エラーメッセージに時折現れます．式を評価するために，Leanはその型を見つけられる必要がありますが，空リストは1つも要素を持たないことから型が見つからないため，上記の式の型を得ることができません．型を明示的に指定することで，Leanは処理を進めることができます:

```lean
{{#example_in Examples/Intro.lean headNone}}
```
```output info
{{#example_out Examples/Intro.lean headNone}}
```
<!-- The type can also be provided with a type annotation: -->

この型は型注釈で与えることも可能です:

```lean
{{#example_in Examples/Intro.lean headNoneTwo}}
```
```output info
{{#example_out Examples/Intro.lean headNoneTwo}}
```
<!-- The error messages provide a useful clue.
Both messages use the _same_ metavariable to describe the missing implicit argument, which means that Lean has determined that the two missing pieces will share a solution, even though it was unable to determine the actual value of the solution. -->

エラーメッセージは有用な手がかりを与えてくれます．どちらのメッセージも，足りない暗黙の引数を記述するために， _同じ_ メタ変数を使用しています．これはLeanが解の実際の値を決定できなかったにもかかわらず，2つの足りない部分が解を共有するだろうと判断したことを意味します．

### `Prod`

<!-- The `Prod` structure, short for "Product", is a generic way of joining two values together.
For instance, a `Prod Nat String` contains a `Nat` and a `String`.
In other words, `PPoint Nat` could be replaced by `Prod Nat Nat`.
`Prod` is very much like C#'s tuples, the `Pair` and `Triple` types in Kotlin, and `tuple` in C++.
Many applications are best served by defining their own structures, even for simple cases like `Point`, because using domain terminology can make it easier to read the code.
Additionally, defining structure types helps catch more errors by assigning different types to different domain concepts, preventing them from being mixed up. -->

`Prod`構造は「Product」の略で，2つの値を結合する一般的な方法です．例えば，`Prod Nat String`は`Nat`と`String`を含みます．つまり，`PPoint Nat`は`Prod Nat Nat`に置き換えることができます．`Prod`はC#のタプル，Kotlinの`Pair`型と`Triple`型，C++の`tuple`によく似ています．実用に際しては，`Point`のような単純な場合であってももっぱら独自の構造体を定義するのが最善です．というのもこのような固有の用語がコードを読みやすくするからです．さらに，構造体型を定義することで，異なるドメイン概念に異なる型を割り当て，それらが混在することを防ぐことでより多くのエラーを検出できます．

<!-- On the other hand, there are some cases where it is not worth the overhead of defining a new type.
Additionally, some libraries are sufficiently generic that there is no more specific concept than "pair".
Finally, the standard library contains a variety of convenience functions that make it easier to work with the built-in pair type. -->

一方，新しい型を定義するオーバーヘッドに見合わないケースもあります．加えて，いくつかのライブラリは「ペア」以上の具体的な概念がないほど十分汎用的です．そして最後に，標準ライブラリには様々な便利関数が含まれており，組み込みのペア型をより簡単に扱うことができます．

<!-- The standard pair structure is called `Prod`. -->

標準的なペアの構造は`Prod`と呼ばれます．

```lean
{{#example_decl Examples/Intro.lean Prod}}
```
<!-- Lists are used so frequently that there is special syntax to make them more readable.
For the same reason, both the product type and its constructor have special syntax.
The type `Prod α β` is typically written `α × β`, mirroring the usual notation for a Cartesian product of sets.
Similarly, the usual mathematical notation for pairs is available for `Prod`.
In other words, instead of writing: -->

リストは頻繁に使われるため，読みやすくなる特別な構文があります．同じ理由で，積の型とコンストラクタも特別な構文を持っています．`Prod α β`型は通常`α × β`と表記されます．これは集合のデカルト積の通常の表記を反映したものです．同様に，ペアを表す通常の数学的記法が`Prod`でも利用できます．つまり，以下のように書く代わりに:

```lean
{{#example_decl Examples/Intro.lean fivesStruct}}
```
<!-- it suffices to write: -->

次のように書けます:

```lean
{{#example_decl Examples/Intro.lean fives}}
```

<!-- Both notations are right-associative.
This means that the following definitions are equivalent: -->

どちらの記法も右結合です．つまり，以下の定義は等価です:

```lean
{{#example_decl Examples/Intro.lean sevens}}

{{#example_decl Examples/Intro.lean sevensNested}}
```
<!-- In other words, all products of more than two types, and their corresponding constructors, are actually nested products and nested pairs behind the scenes. -->

言い換えれば，2つ以上の型を持つすべての積とそれに対応するコンストラクタは，実際には裏でネストされた積とネストされたペアなのです．

### `Sum`

<!-- The `Sum` datatype is a generic way of allowing a choice between values of two different types.
For instance, a `Sum String Int` is either a `String` or an `Int`.
Like `Prod`, `Sum` should be used either when writing very generic code, for a very small section of code where there is no sensible domain-specific type, or when the standard library contains useful functions.
In most situations, it is more readable and maintainable to use a custom inductive type. -->

`Sum`データ型は，2つの異なる型の値を選択できるようにする汎用的な方法です．例えば，`Sum String Int`は`String`か`Int`のどちらかです．`Prod`と同様に，`Sum`は非常に汎用的なコードを書く時や，ドメイン固有の型が無いような非常に小さなコードで使用するか，標準ライブラリに便利な関数があるときに使用します．たいていの場合，カスタムの帰納型を使用する方が読みやすく，保守性も高くなります．

<!-- Values of type `Sum α β` are either the constructor `inl` applied to a value of type `α` or the constructor `inr` applied to a value of type `β`: -->

`Sum α β`型の値は，コンストラクタ`inl`を`α`型の値に適用したものか，コンストラクタ`inr`を`β`型の値に適用したかのどちらかです:

```lean
{{#example_decl Examples/Intro.lean Sum}}
```
<!-- These names are abbreviations for "left injection" and "right injection", respectively.
Just as the Cartesian product notation is used for `Prod`, a "circled plus" notation is used for `Sum`, so `α ⊕ β` is another way to write `Sum α β`.
There is no special syntax for `Sum.inl` and `Sum.inr`. -->

これらの名前はそれぞれ「左埋め込み(left injection)」と「右埋め込み(right injection)」の略です．`Prod`にデカルト積の記法が使われるように，`Sum`には「丸で囲んだプラス」記法が使われ，`Sum α β`は`α ⊕ β`とも書き表されます．`Sum.inl`と`Sum.inr`には特別な構文はありません．

<!-- For instance, if pet names can either be dog names or cat names, then a type for them can be introduced as a sum of strings: -->

例えば，ペットの名前に犬の名前と猫の名前のどちらもあり得る場合，それらを表す型を文字列の和として導入することができます．

```lean
{{#example_decl Examples/Intro.lean PetName}}
```
<!-- In a real program, it would usually be better to define a custom inductive datatype for this purpose with informative constructor names.
Here, `Sum.inl` is to be used for dog names, and `Sum.inr` is to be used for cat names.
These constructors can be used to write a list of animal names: -->

実際のプログラムでは通常，このような目的のためには情報量の多いコンストラクタ名でカスタムの帰納的データ型を定義する方がよいでしょう．ここでは犬の名前には`Sum.inl`を，猫の名前には`Sum.inr`を使用します．これらのコンストラクタを使用して，動物の名前のリストを書くことができます:

```lean
{{#example_decl Examples/Intro.lean animals}}
```
<!-- Pattern matching can be used to distinguish between the two constructors.
For instance, a function that counts the number of dogs in a list of animal names (that is, the number of `Sum.inl` constructors) looks like this: -->

2つのコンストラクタを区別するために，パターンマッチを使うことができます．例えば，動物の名前のリストに含まれる犬の数（つまり，`Sum.inl`コンストラクタの数）を数える関数は次のようになります:

```lean
{{#example_decl Examples/Intro.lean howManyDogs}}
```
<!-- Function calls are evaluated before infix operators, so `howManyDogs morePets + 1` is the same as `(howManyDogs morePets) + 1`.
As expected, `{{#example_in Examples/Intro.lean dogCount}}` yields `{{#example_out Examples/Intro.lean dogCount}}`. -->

関数呼び出しは中置演算子の前に評価されるので，`howManyDogs morePets + 1`は`(howManyDogs morePets) + 1`と同じです．予想通り，`{{#example_in Examples/Intro.lean dogCount}}`は`{{#example_out Examples/Intro.lean dogCount}}`を返します．

### `Unit`

<!-- `Unit` is a type with just one argumentless constructor, called `unit`.
In other words, it describes only a single value, which consists of said constructor applied to no arguments whatsoever.
`Unit` is defined as follows: -->

`Unit`は`unit`と呼ばれる引数のないコンストラクタを1つだけもつ型です．つまり，引数のないコンストラクタを適用した単一の値のみを記述します．`Unit`は以下のように定義されます:

```lean
{{#example_decl Examples/Intro.lean Unit}}
```

<!-- On its own, `Unit` is not particularly useful.
However, in polymorphic code, it can be used as a placeholder for data that is missing.
For instance, the following inductive datatype represents arithmetic expressions: -->

単体では`Unit`は特に役に立ちません．しかし，多相なプログラムでは，足りないデータのプレースホルダとして使用することができます．例えば，以下の帰納的データ型は算術式を表します:

```lean
{{#example_decl Examples/Intro.lean ArithExpr}}
```
<!-- The type argument `ann` stands for annotations, and each constructor is annotated.
Expressions coming from a parser might be annotated with source locations, so a return type of `ArithExpr SourcePos` ensures that the parser put a `SourcePos` at each subexpression.
Expressions that don't come from the parser, however, will not have source locations, so their type can be `ArithExpr Unit`. -->

型引数の`ann`は注釈を表し，各コンストラクタは注釈されています．パースされた結果の式はソース中の位置で注釈されているかもしれないので，`ArithExpr SourcePos`の戻り値の型はパーサがそれぞれの部分式に`SourcePos`を置くことを保証します．しかし，パーサから来ない式はソース中の位置を持たないため，その型は`ArithExpr Unit`となります．

<!-- Additionally, because all Lean functions have arguments, zero-argument functions in other languages can be represented as functions that take a `Unit` argument.
In a return position, the `Unit` type is similar to `void` in languages derived from C.
In the C family, a function that returns `void` will return control to its caller, but it will not return any interesting value.
By being an intentionally uninteresting value, `Unit` allows this to be expressed without requiring a special-purpose `void` feature in the type system.
Unit's constructor can be written as empty parentheses: `{{#example_in Examples/Intro.lean unitParens}} : {{#example_out Examples/Intro.lean unitParens}}`. -->

さらに，すべてのLeanでの関数は引数を持つので，ほかの言語での引数が無い関数は，Leanでは`Unit`引数を取る関数として表すことができます．戻り値の観点では，`Unit`型はC言語から派生した言語での`void`型に似ています．C言語ファミリーでは，`void`を返す関数は呼び出し元に制御を返すが，興味深い値を返すことはありません．`Unit`は意図的に興味のない値であることで，型システムの中に特別な目的の`void`機能を必要とすることなく，これを表現することができます．`Unit`のコンストラクタは空の括弧で書くことができます: `{{#example_in Examples/Intro.lean unitParens}} : {{#example_out Examples/Intro.lean unitParens}}`

### `Empty`

<!-- The `Empty` datatype has no constructors whatsoever.
Thus, it indicates unreachable code, because no series of calls can ever terminate with a value at type `Empty`. -->

`Empty`データ型はコンストラクタを一切持ちません．よってこれは到達不可能なコードを意味します．なぜなら，どんな関数呼び出しの列も`Empty`型の値で終了することは無いからです．

<!-- `Empty` is not used nearly as often as `Unit`.
However, it is useful in some specialized contexts.
Many polymorphic datatypes do not use all of their type arguments in all of their constructors.
For instance, `Sum.inl` and `Sum.inr` each use only one of `Sum`'s type arguments.
Using `Empty` as one of the type arguments to `Sum` can rule out one of the constructors at a particular point in a program.
This can allow generic code to be used in contexts that have additional restrictions. -->

`Empty`は`Unit`ほど頻繁には使われません．しかし，特殊なコンテキストでは役に立ちます．多くの多相データ型では，すべてのコンストラクタですべての型引数を使用するわけではありません．たとえば，`Sum.inl`と`Sum.inr`はそれぞれ`Sum`の型引数を1つしか使用しません．`Empty`を`Sum`の型引数の1つとして使用することで，プログラムの特定の時点でコンストラクタの1つを除外することができます．これにより，追加の制限があるコンテキストでジェネリックなコードを使用することができます．

<!-- ### Naming: Sums, Products, and Units -->

### 名前について: 和(Sum)，積(Product)，単位(Unit)

<!-- Generally speaking, types that offer multiple constructors are called _sum types_, while types whose single constructor takes multiple arguments are called _product types_.
These terms are related to sums and products used in ordinary arithmetic.
The relationship is easiest to see when the types involved contain a finite number of values.
If `α` and `β` are types that contain \\( n \\) and \\( k \\) distinct values, respectively, then `α ⊕ β` contains \\( n + k \\) distinct values and `α × β` contains \\( n \times k \\) distinct values.
For instance, `Bool` has two values: `true` and `false`, and `Unit` has one value: `Unit.unit`.
The product `Bool × Unit` has the two values `(true, Unit.unit)` and `(false, Unit.unit)`, and the sum `Bool ⊕ Unit` has the three values `Sum.inl true`, `Sum.inl false`, and `Sum.inr unit`.
Similarly, \\( 2 \times 1 = 2 \\), and \\( 2 + 1 = 3 \\). -->

一般的に，複数のコンストラクタを持つ型は _直和型_ と呼ばれ，単一のコンストラクタが複数の引数を取る型は _直積型_ と呼ばれます．これらの用語は，通常の算術で使われる和と積に関連しています．この関係は，関係する型が有限個の値を含む場合に最もわかりやすいでしょう．`α`と`β`がそれぞれ \\( n \\) 個と \\( k \\) 個の異なる値を含む型だとすると，`α ⊕ β`は \\( n + k \\) 個の異なる値を含み，`α × β`は \\( n \times k \\) 個の異なる値を含みます．たとえば`Bool`は`true`と`false`の2つの値を持ち，`Unit`には`Unit.unit`という1つの値があります．積`Bool × Unit`は2つの値`(true, Unit.unit)`と`(false, Unit.unit)`を持ち，和`Bool ⊕ Unit`は3つの値`Sum.inl true`と`Sum.inl false`，`Sum.inr unit`を持ちます．これと同様に，\\( 2 \times 1 = 2 \\) と \\( 2 + 1 = 3 \\) となります．

<!-- ## Messages You May Meet -->

## 見るかもしれないメッセージ

<!-- Not all definable structures or inductive types can have the type `Type`.
In particular, if a constructor takes an arbitrary type as an argument, then the inductive type must have a different type.
These errors usually state something about "universe levels".
For example, for this inductive type: -->

すべての定義可能な構造体や帰納的型が`Type`型を持つわけではありません．特に，コンストラクタが引数として任意の型を取る場合，帰納的型は異なる型を持たなければなりません．これらのエラーは通常，「universe levels」について述べています．例えば，この帰納的型について:

```lean
{{#example_in Examples/Intro.lean TypeInType}}
```
<!-- Lean gives the following error: -->

Leanは以下のエラーを出します:

```output error
{{#example_out Examples/Intro.lean TypeInType}}
```
<!-- A later chapter describes why this is the case, and how to modify definitions to make them work.
For now, try making the type an argument to the inductive type as a whole, rather than to the constructor. -->

後の章では，なぜそうなるか，どのように定義を修正すればうまくいくのかを説明します．今の時点では，型をコンストラクタの引数ではなく，帰納的型全体の引数にしてみてください．

<!-- Similarly, if a constructor's argument is a function that takes the datatype being defined as an argument, then the definition is rejected.
For example: -->

同様に，コンストラクタの引数が定義されているデータ型を引数とする関数である場合，その定義は却下されます．例えば以下の定義について:

```lean
{{#example_in Examples/Intro.lean Positivity}}
```
<!-- yields the message: -->

このようなメッセージが出力されます:

```output error
{{#example_out Examples/Intro.lean Positivity}}
```
<!-- For technical reasons, allowing these datatypes could make it possible to undermine Lean's internal logic, making it unsuitable for use as a theorem prover. -->

技術的な理由から，このようなデータ型を許可すると，Leanの内部論理が損なわれる可能性があり，定理証明として使用するのに適さなくなります．

<!-- Forgetting an argument to an inductive type can also yield a confusing message.
For example, when the argument `α` is not passed to `MyType` in `ctor`'s type: -->

帰納的な型の引数を忘れると，混乱を招くメッセージになることもあります．例えば，`ctor`の型の`MyType`に引数`α`が渡されていない場合です:

```lean
{{#example_in Examples/Intro.lean MissingTypeArg}}
```
<!-- Lean replies with the following error: -->

Leanはこれに対して以下のエラーを返します:

```output error
{{#example_out Examples/Intro.lean MissingTypeArg}}
```
<!-- The error message is saying that `MyType`'s type, which is `Type → Type`, does not itself describe types.
`MyType` requires an argument to become an actual honest-to-goodness type. -->

このエラーメッセージは`MyType`の型は`Type → Type`であり，型そのものを記述していないと言っています．`MyType`が実際の正真正銘の型になるためには，引数を必要とします．

<!-- The same message can appear when type arguments are omitted in other contexts, such as in a type signature for a definition: -->

定義の型シグネチャなど，ほかのコンテキストで型引数が省略された場合にも，同じメッセージが表示されることがあります:

```lean
{{#example_decl Examples/Intro.lean MyTypeDef}}

{{#example_in Examples/Intro.lean MissingTypeArg2}}
```

<!-- ## Exercises -->

## 演習問題

 <!-- * Write a function to find the last entry in a list. It should return an `Option`. -->
 * リストの最後の要素を探す関数を書いてください．これは`Option`を返すべきです．
 <!-- * Write a function that finds the first entry in a list that satisfies a given predicate. Start the definition with `def List.findFirst? {α : Type} (xs : List α) (predicate : α → Bool) : Option α :=` -->
 * リストの中で与えられた述語を満たす最初の要素を探す関数を書いてください．定義は`def List.findFirst? {α : Type} (xs : List α) (predicate : α → Bool) : Option α :=`から始めてください．
 <!-- * Write a function `Prod.swap` that swaps the two fields in a pair. Start the definition with `def Prod.swap {α β : Type} (pair : α × β) : β × α :=` -->
 * ペアの2つのフィールドを入れ替える関数`Prod.swap`を書いてください．定義は`def Prod.swap {α β : Type} (pair : α × β) : β × α :=`から始めてください．
 <!-- * Rewrite the `PetName` example to use a custom datatype and compare it to the version that uses `Sum`. -->
 * カスタムのデータ型を使って`PetName`の例を書き換えて，`Sum`のバージョンを比較してください．
 <!-- * Write a function `zip` that combines two lists into a list of pairs. The resulting list should be as long as the shortest input list. Start the definition with `def zip {α β : Type} (xs : List α) (ys : List β) : List (α × β) :=`. -->
 * 2つのリストのペアを紐づける関数`zip`を書いてください．出力されるリストは入力のリストのうち短い方と同じ長さにしてください．定義は`def zip {α β : Type} (xs : List α) (ys : List β) : List (α × β) :=`から始めてください．
 <!-- * Write a polymorphic function `take` that returns the first \\( n \\) entries in a list, where \\( n \\) is a `Nat`. If the list contains fewer than `n` entries, then the resulting list should be the input list. `{{#example_in Examples/Intro.lean takeThree}}` should yield `{{#example_out Examples/Intro.lean takeThree}}`, and `{{#example_in Examples/Intro.lean takeOne}}` should yield `{{#example_out Examples/Intro.lean takeOne}}`. -->
 * リストの先頭から \\( n \\) 個の要素を返す多相関数`take`を書いてください．ここで \\( n \\) は`Nat`です．もしリストの要素が`n`個未満の場合，出力のリストは入力のリストにしてください．また`{{#example_in Examples/Intro.lean takeThree}}`は`{{#example_out Examples/Intro.lean takeThree}}`を出力し，`{{#example_in Examples/Intro.lean takeOne}}`は`{{#example_out Examples/Intro.lean takeOne}}`を出力させてください．
 <!-- * Using the analogy between types and arithmetic, write a function that distributes products over sums. In other words, it should have type `α × (β ⊕ γ) → (α × β) ⊕ (α × γ)`. -->
 * 型と算術の間の類似を使って，直積を直和に分配する関数を書いてください．言い換えると，この型は`α × (β ⊕ γ) → (α × β) ⊕ (α × γ)`になります．
 * Using the analogy between types and arithmetic, write a function that turns multiplication by two into a sum. In other words, it should have type `Bool × α → α ⊕ α`.
 * 型と算術の間の類似を使って，2倍が和になる関数を書いてください．言い換えると，この方は`Bool × α → α ⊕ α`になります．
