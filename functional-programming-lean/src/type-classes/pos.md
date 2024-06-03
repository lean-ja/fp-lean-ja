<!-- # Positive Numbers -->

# 正の整数

<!-- In some applications, only positive numbers make sense.
For example, compilers and interpreters typically use one-indexed line and column numbers for source positions, and a datatype that represents only non-empty lists will never report a length of zero.
Rather than relying on natural numbers, and littering the code with assertions that the number is not zero, it can be useful to design a datatype that represents only positive numbers. -->

数値を扱うプログラムの中には，正の整数だけが意味を持つものもあります．例えば，コンパイラとインタプリタは通常，ソースコードの位置に対して1つの行番号と列番号によるインデックスを使用します．また，空でないリストのみを表すデータ型では，長さが0であると言ってくることはありません．このようなケースに対して自然数に依存して数値が0でないことをいちいちチェックしてコードを汚くしてしまうよりも，正の数だけを表すデータ型を設計する方が便利です．

<!-- One way to represent positive numbers is very similar to `Nat`, except with `one` as the base case instead of `zero`: -->

正の数を表現する1つの方法は，`0` の代わりに `1` を基本とすることを除けば，`Nat` によく似ています：

```lean
{{#example_decl Examples/Classes.lean Pos}}
```
<!-- This datatype represents exactly the intended set of values, but it is not very convenient to use.
For example, numeric literals are rejected: -->

このデータ型で意図した値の集合を正しく表すことができますが，使い勝手はあまりよくありません．例えば，数値リテラルを使おうとするとエラーになります：

```lean
{{#example_in Examples/Classes.lean sevenOops}}
```
```output error
{{#example_out Examples/Classes.lean sevenOops}}
```
<!-- Instead, the constructors must be used directly: -->

上記の代わりにコンストラクタを直接使わなければなりません：

```lean
{{#example_decl Examples/Classes.lean seven}}
```

<!-- Similarly, addition and multiplication are not easy to use: -->

同じように，足し算と掛け算も簡単には使えません：

```lean
{{#example_in Examples/Classes.lean fourteenOops}}
```
```output error
{{#example_out Examples/Classes.lean fourteenOops}}
```
```lean
{{#example_in Examples/Classes.lean fortyNineOops}}
```
```output error
{{#example_out Examples/Classes.lean fortyNineOops}}
```

<!-- Each of these error messages begins with `failed to synthesize instance`.
This indicates that the error is due to an overloaded operation that has not been implemented, and it describes the type class that must be implemented. -->

これらのエラーメッセージはどれも `failed to synthesize instance` から始まっています．これは実装されていないオーバーロードされた操作によるエラーであることを示し，実装しなければならない型クラスが記述されています．

<!-- ## Classes and Instances -->

## クラスとインスタンス

<!-- A type class consists of a name, some parameters, and a collection of _methods_.
The parameters describe the types for which overloadable operations are being defined, and the methods are the names and type signatures of the overloadable operations.
Once again, there is a terminology clash with object-oriented languages.
In object-oriented programming, a method is essentially a function that is connected to a particular object in memory, with special access to the object's private state.
Objects are interacted with via their methods.
In Lean, the term "method" refers to an operation that has been declared to be overloadable, with no special connection to objects or values or private fields. -->

型クラスの構成要素は名前，いくつかのパラメータ，そして **メソッド** （method）の集まりです．パラメータはオーバーロード可能な演算の対象となる型を，メソッドはオーバーロード可能な演算の名前と型シグネチャを表します．ここでもまたオブジェクト指向言語との用語の衝突があります．オブジェクト指向プログラミングでは，メソッドは基本的にメモリ上の特定のオブジェクトに接続され，そのオブジェクトのプライベート状態に特別にアクセスできる関数のことです．オブジェクトの操作はこうしたメソッドを通じて行われます．一方Leanでは，「メソッド」という用語はオーバーロード可能なものとして宣言された演算を指します．そこにはオブジェクトや値，プライベートのフィールドへの特別な接続は関係しません．

<!-- One way to overload addition is to define a type class named `Plus`, with an addition method named `plus`.
Once an instance of `Plus` for `Nat` has been defined, it becomes possible to add two `Nat`s using `Plus.plus`: -->

足し算をオーバーロードする1つの方法は，足し算メソッド `plus` を備えた `Plus` という型クラスを定義することです．ひとたび `Nat` に対する `Plus` のインスタンスが定義されると， `Plus.plus` を使って2つの `Nat` を足すことができるようになります：

```lean
{{#example_in Examples/Classes.lean plusNatFiveThree}}
```
```output info
{{#example_out Examples/Classes.lean plusNatFiveThree}}
```
<!-- Adding more instances allows `Plus.plus` to take more types of arguments. -->

他の型についてもインスタンスを追加していくことたびに，`Plus.plus` の引数に取れる型が増えていきます．

<!-- In the following type class declaration, `Plus` is the name of the class, `α : Type` is the only argument, and `plus : α → α → α` is the only method: -->

以下の型クラスの宣言では，`Plua` がクラス名，`α : Type` が唯一の引数，`plus : α → α → α` が唯一のメソッドです：

```lean
{{#example_decl Examples/Classes.lean Plus}}
```
<!-- This declaration says that there is a type class `Plus` that overloads operations with respect to a type `α`.
In particular, there is one overloaded operation called `plus` that takes two `α`s and returns an `α`. -->

この宣言は，型クラス `Plus` が存在し，型 `α` に対して演算をオーバーロードすることを意味しています．特に，2つの `α` を受け取って `α` を返す `plus` という演算が1つだけ存在します．

<!-- Type classes are first class, just as types are first class.
In particular, a type class is another kind of type.
The type of `{{#example_in Examples/Classes.lean PlusType}}` is `{{#example_out Examples/Classes.lean PlusType}}`, because it takes a type as an argument (`α`) and results in a new type that describes the overloading of `Plus`'s operation for `α`. -->

型が第一級であるように，型クラスも第一級です．特に，型クラスは別の種類の型です．`{{#example_in Examples/Classes.lean PlusType}}` の型は `{{#example_out Examples/Classes.lean PlusType}}` です．なぜなら，これは型（ `α` ）を引数に取り，`α` に対する `Plus` の演算のオーバーロードを記述する新しい型を生成するからです．

<!-- To overload `plus` for a particular type, write an instance: -->

`plus` を特定の型にオーバーロードするには以下のようにインスタンスを書く必要があります：

```lean
{{#example_decl Examples/Classes.lean PlusNat}}
```
<!-- The colon after `instance` indicates that `Plus Nat` is indeed a type.
Each method of class `Plus` should be assigned a value using `:=`.
In this case, there is only one method: `plus`. -->

`instance` の後のコロンは，`Plus Nat` が実際に型であることを示しています．クラス `Plus` の各メソッドには `:=` を使って値を代入します．今回の場合，メソッドは `plus` だけです．

<!-- By default, type class methods are defined in a namespace with the same name as the type class.
It can be convenient to `open` the namespace so that users don't need to type the name of the class first.
Parentheses in an `open` command indicate that only the indicated names from the namespace are to be made accessible: -->

デフォルトでは，各クラスのメソッドは型クラスと同じ名前の名前空間に定義されます．名前空間を `open` することで，利用者がメソッドの前にクラス名を入力する必要がなくなるため便利です．`open` コマンドの中で使われている括弧は，名前空間から指定された名前にのみアクセスできるようにすることを示します：

```lean
{{#example_decl Examples/Classes.lean openPlus}}

{{#example_in Examples/Classes.lean plusNatFiveThreeAgain}}
```
```output info
{{#example_out Examples/Classes.lean plusNatFiveThreeAgain}}
```

<!-- Defining an addition function for `Pos` and an instance of `Plus Pos` allows `plus` to be used to add both `Pos` and `Nat` values: -->

`Pos` の足し算の関数と `Plus Pos` のインスタンスを定義することで， `plus` を使って `Nat` の値に対してだけでなく，`Pos` の値に対しても足し算をすることができます：

```lean
{{#example_decl Examples/Classes.lean PlusPos}}
```

<!-- Because there is not yet an instance of `Plus Float`, attempting to add two floating-point numbers with `plus` fails with a familiar message: -->

ここでまだ `Plus float` のインスタンスがないので， `plus` を使って2つの浮動小数点数を足そうとするとおなじみのメッセージが出て失敗します：

```lean
{{#example_in Examples/Classes.lean plusFloatFail}}
```
```output error
{{#example_out Examples/Classes.lean plusFloatFail}}
```
<!-- These errors mean that Lean was unable to find an instance for a given type class. -->

これらのエラーはLeanが指定された型クラスのインスタンスを見つけられなかったことを意味します．

<!-- ## Overloaded Addition -->

## オーバーロードされた足し算

<!-- Lean's built-in addition operator is syntactic sugar for a type class called `HAdd`, which flexibly allows the arguments to addition to have different types.
`HAdd` is short for _heterogeneous addition_.
For example, an `HAdd` instance can be written to allow a `Nat` to be added to a `Float`, resulting in a new `Float`.
When a programmer writes `{{#example_eval Examples/Classes.lean plusDesugar 0}}`, it is interpreted as meaning `{{#example_eval Examples/Classes.lean plusDesugar 1}}`. -->

Leanの組み込みの足し算の演算子は，`HAdd` と呼ばれる型クラスの糖衣構文であり，加算の2つの引き数が異なる型を持つことを柔軟に許可しています．`HAdd` は _heterogeneous addition_ の略です．例えば，`HAdd` のインスタンスは `Float` に `Nat` を加えて新しい `Float` の値を出力できるように定義されています．プログラマが `{{#example_eval Examples/Classes.lean plusDesugar 0}}` と書くと， `{{#example_eval Examples/Classes.lean plusDesugar 1}}` という意味に解釈されます．

<!-- While an understanding of the full generality of `HAdd` relies on features that are discussed in [another section in this chapter](out-params.md), there is a simpler type class called `Add` that does not allow the types of the arguments to be mixed.
The Lean libraries are set up so that an instance of `Add` will be found when searching for an instance of `HAdd` in which both arguments have the same type. -->

`HAdd` の汎用性の全貌の理解は [別の章の節](out-params.md) で説明する機能を学んでからになりますが，そこまで要求せずに，引数の型を混在させない `Add` というより単純な型クラスも存在します．Leanのライブラリは両方の引数が同じ型である `HAdd` のインスタンスを検索した時に `Add` のインスタンスが選ばれるように設定されています．

<!-- Defining an instance of `Add Pos` allows `Pos` values to use ordinary addition syntax: -->

`Add Pos` のインスタンスを定義することで，`Pos` の値を通常の足し算の記法で使うことができるようになります：

```lean
{{#example_decl Examples/Classes.lean AddPos}}

{{#example_decl Examples/Classes.lean betterFourteen}}
```

<!-- ## Conversion to Strings -->

## 文字列への変換

<!-- Another useful built-in class is called `ToString`.
Instances of `ToString` provide a standard way of converting values from a given type into strings.
For example, a `ToString` instance is used when a value occurs in an interpolated string, and it determines how the `IO.println` function used at the [beginning of the description of `IO`](../hello-world/running-a-program.html#running-a-program) will display a value. -->

便利な組み込みのクラスとして他には `ToString` というものがあります．`ToString` のインスタンスは，与えられた型の値を文字列に変換する標準的な方法を提供します．例えば，`ToString` のインスタンスは文字列中に値を内挿する場合に使用され， [`IO` の説明の最初](../hello-world/running-a-program.html#running-a-program) で使用されている `IO.println` 関数が値をどのように表示するかを決定します．

<!-- For example, one way to convert a `Pos` into a `String` is to reveal its inner structure.
The function `posToString` takes a `Bool` that determines whether to parenthesize uses of `Pos.succ`, which should be `true` in the initial call to the function and `false` in all recursive calls. -->

`Pos` を `String` に変換する方法の一例として，その内部構造を明らかにするというものがあります．以下の関数 `posToString` は `Pos.succ` の使用を括弧で囲むかどうかを決定する `Bool` を受け取っています．

```lean
{{#example_decl Examples/Classes.lean posToStringStructure}}
```
<!-- Using this function for a `ToString` instance: -->

この関数を `ToString` のインスタンスに使うと以下のようになります：

```lean
{{#example_decl Examples/Classes.lean UglyToStringPos}}
```
<!-- results in informative, yet overwhelming, output: -->

こうすることでいささか過剰ですが，有益な出力が得られます：

```lean
{{#example_in Examples/Classes.lean sevenLong}}
```
```output info
{{#example_out Examples/Classes.lean sevenLong}}
```

<!-- On the other hand, every positive number has a corresponding `Nat`.
Converting it to a `Nat` and then using the `ToString Nat` instance (that is, the overloading of `toString` for `Nat`) is a quick way to generate much shorter output: -->

一方で，すべての正の整数には対応する `Nat` があります．これを `Nat` に変換し，`ToString Nat` インスタンス（つまり，`Nat` に対する `toString` のオーバーロード）を使用することで，より短い出力を生成することができます：

```lean
{{#example_decl Examples/Classes.lean posToNat}}

{{#example_decl Examples/Classes.lean PosToStringNat}}

{{#example_in Examples/Classes.lean sevenShort}}
```
```output info
{{#example_out Examples/Classes.lean sevenShort}}
```
<!-- When more than one instance is defined, the most recent takes precedence.
Additionally, if a type has a `ToString` instance, then it can be used to display the result of `#eval` even if the type in question was not defined with `deriving Repr`, so `{{#example_in Examples/Classes.lean sevenEvalStr}}` outputs `{{#example_out Examples/Classes.lean sevenEvalStr}}`. -->

複数のインスタンスが定義されている場合，一番最後に定義したものが優先されます．さらに，ある型が `ToString` インスタンスを持っている場合，その型が `deriving Repr` で定義されていなくても，その型の結果を `#eval` で表示するために `ToString` が使用されるため，`{{#example_in Examples/Classes.lean sevenEvalStr}}` は `{{#example_out Examples/Classes.lean sevenEvalStr}}` を出力します．

<!-- ## Overloaded Multiplication -->

## オーバーロードされた掛け算

<!-- For multiplication, there is a type class called `HMul` that allows mixed argument types, just like `HAdd`.
Just as `{{#example_eval Examples/Classes.lean plusDesugar 0}}` is interpreted as `{{#example_eval Examples/Classes.lean plusDesugar 1}}`, `{{#example_eval Examples/Classes.lean timesDesugar 0}}` is interpreted as `{{#example_eval Examples/Classes.lean timesDesugar 1}}`.
For the common case of multiplication of two arguments with the same type, a `Mul` instance suffices. -->

掛け算について，`HMul` という型クラスがあり，`HAdd` と同じように引数の型を混ぜることができます．ちょうど `{{#example_eval Examples/Classes.lean plusDesugar 0}}` が `{{#example_eval Examples/Classes.lean plusDesugar 1}}` と解釈されるように，`{{#example_eval Examples/Classes.lean timesDesugar 0}}` は `{{#example_eval Examples/Classes.lean timesDesugar 1}}` と解釈されます．同じ型を持つ2つの引数の掛け算で一般的なケースでは `Mul` インスタンスで十分です．

<!-- An instance of `Mul` allows ordinary multiplication syntax to be used with `Pos`: -->

`Mul` のインスタンスを定義することで通常の掛け算の構文を `Pos` に対して使うことができます：

```lean
{{#example_decl Examples/Classes.lean PosMul}}
```
<!-- With this instance, multiplication works as expected: -->

インスタンスのおかげで，掛け算は意図通りに実行されます：

```lean
{{#example_in Examples/Classes.lean muls}}
```
```output info
{{#example_out Examples/Classes.lean muls}}
```

<!-- ## Literal Numbers -->

## 数値リテラル

<!-- It is quite inconvenient to write out a sequence of constructors for positive numbers.
One way to work around the problem would be to provide a function to convert a `Nat` into a `Pos`.
However, this approach has downsides.
First off, because `Pos` cannot represent `0`, the resulting function would either convert a `Nat` to a bigger number, or it would return `Option Pos`.
Neither is particularly convenient for users.
Secondly, the need to call the function explicitly would make programs that use positive numbers much less convenient to write than programs that use `Nat`.
Having a trade-off between precise types and convenient APIs means that the precise types become less useful. -->

`Pos` の値を宣言するにあたり，コンストラクタの列をずらずら書き出すのはかなり不便です．この問題を回避する一つの方法は，`Nat` を `Pos` に変換する関数を提供することでしょう．しかし，この方法には欠点があります．まず，`Pos` は `0` を表すことができないため，結果として関数は `Nat` を大きい値に変換するか，戻り値の型を `Option Pos` となります．どちらもユーザにとってあまり使いやすいものではありません．第二に，関数を明示的に呼び出す必要があるため，正の整数を使用するプログラムは `Nat` を使用するプログラムよりもはるかに書きにくくなります．正確な型と便利なAPIの間にトレードオフがあるということは，その型が有用でなくなることを意味します．

<!-- In Lean, natural number literals are interpreted using a type class called `OfNat`: -->

Leanでは，自然数のリテラルは `OfNat` という型クラスを使って解釈されます：

```lean
{{#example_decl Examples/Classes.lean OfNat}}
```
<!-- This type class takes two arguments: `α` is the type for which a natural number is overloaded, and the unnamed `Nat` argument is the actual literal number that was encountered in the program.
The method `ofNat` is then used as the value of the numeric literal.
Because the class contains the `Nat` argument, it becomes possible to define only instances for those values where the number makes sense. -->

この型クラスは2つの引数を取ります： `α` は自然数をオーバーロードする型であり，無名の `Nat` 引数は実際にプログラムで利用する際に遭遇する数値リテラルです．そして `ofNat` メソッドが数値リテラルの値として使用されます．このクラスには `Nat` 引数が含まれるため，その数値が対象の型において意味を持つものに対してのインスタンスのみを定義することが可能になります．

<!-- `OfNat` demonstrates that the arguments to type classes do not need to be types.
Because types in Lean are first-class participants in the language that can be passed as arguments to functions and given definitions with `def` and `abbrev`, there is no barrier that prevents non-type arguments in positions where a less-flexible language could not permit them.
This flexibility allows overloaded operations to be provided for particular values as well as particular types. -->

`OfNat` は型クラスの引数が型である必要がないことの一例です．Leanの型は関数の引数として渡したり，`def` や `abbrev` で定義を与えることができる第一級としての言語の構成員であるため，柔軟性の低い言語では許されないような位置で型以外の引数を妨げるような障壁はありません．この柔軟性によって，特定の型だけでなく，特定の値に対してもオーバーロードされた演算を提供することができます．

<!-- For example, a sum type that represents natural numbers less than four can be defined as follows: -->

例えば，4未満の自然数を表す直和型は次のように定義できます：

```lean
{{#example_decl Examples/Classes.lean LT4}}
```
<!-- While it would not make sense to allow _any_ literal number to be used for this type, numbers less than four clearly make sense: -->

この型に対して _どんな_ 数値リテラルでも使えるようにするのは意味がありませんが，4未満の数に限れば明らかに意味があります：

```lean
{{#example_decl Examples/Classes.lean LT4ofNat}}
```
<!-- With these instances, the following examples work: -->

このインスタンスによって，以下の例が機能します：

```lean
{{#example_in Examples/Classes.lean LT4three}}
```
```output info
{{#example_out Examples/Classes.lean LT4three}}
```
```lean
{{#example_in Examples/Classes.lean LT4zero}}
```
```output info
{{#example_out Examples/Classes.lean LT4zero}}
```
<!-- On the other hand, out-of-bounds literals are still not allowed: -->

一方で範囲外のリテラルはちゃんと不許可となります：

```lean
{{#example_in Examples/Classes.lean LT4four}}
```
```output error
{{#example_out Examples/Classes.lean LT4four}}
```

<!-- For `Pos`, the `OfNat` instance should work for _any_ `Nat` other than `Nat.zero`.
Another way to phrase this is to say that for all natural numbers `n`, the instance should work for `n + 1`.
Just as names like `α` automatically become implicit arguments to functions that Lean fills out on its own, instances can take automatic implicit arguments.
In this instance, the argument `n` stands for any `Nat`, and the instance is defined for a `Nat` that's one greater: -->

`Pos` の場合，`OfNat`インスタンスは `Nat.zero` 以外の **すべての** `Nat` に対して動作する必要があります．別の言い方をすると，すべての自然数 `n` に対して，インスタンスは `n + 1` に対して動作する必要があります．`α` のような名前が自動的に関数の暗黙の引数になり，Leanがそれを埋めてくれるように，インスタンスも自動的に暗黙の引数を取ることができます．このインスタンスでは，引数 `n` は任意の `Nat` を表し，インスタンスは1つ大きい `Nat` に対して定義されます：

```lean
{{#example_decl Examples/Classes.lean OfNatPos}}
```
<!-- Because `n` stands for a `Nat` that's one less than what the user wrote, the helper function `natPlusOne` returns a `Pos` that's one greater than its argument.
This makes it possible to use natural number literals for positive numbers, but not for zero: -->

`n` は `n + 1` でパターンマッチされることでユーザが書いた値より1小さい `Nat` を表すので，ヘルパー関数 `natPlusOne` は引数より1大きい `Pos` を返します．これにより，正の整数には自然数のリテラルを使用できますが，0には使用できません．

```lean
{{#example_decl Examples/Classes.lean eight}}

{{#example_in Examples/Classes.lean zeroBad}}
```
```output error
{{#example_out Examples/Classes.lean zeroBad}}
```

<!-- ## Exercises -->

## 演習問題

<!-- ### Another Representation -->

### 別の表現

<!-- An alternative way to represent a positive number is as the successor of some `Nat`.
Replace the definition of `Pos` with a structure whose constructor is named `succ` that contains a `Nat`: -->

正の整数を表す別の方法として，`Nat` の対応する値の次の値を表すというものもあります．`Pos` の定義を `Nat` を含む `succ` という名前のコンストラクタを持つ構造体に置き換えると以下のようになります：

```lean
{{#example_decl Examples/Classes.lean AltPos}}
```
<!-- Define instances of `Add`, `Mul`, `ToString`, and `OfNat` that allow this version of `Pos` to be used conveniently. -->

このバージョンの `Pos` を便利にするために `Add` と `Mul` ，`ToString` ，`OfNat` を定義してください．

<!-- ### Even Numbers -->

### 偶数

<!-- Define a datatype that represents only even numbers. Define instances of `Add`, `Mul`, and `ToString` that allow it to be used conveniently.
`OfNat` requires a feature that is introduced in [the next section](polymorphism.md). -->

偶数のみを表すデータ型を定義してください．またそれを便利に使えるように `Add` と `Mul` ，`ToString` を定義してください．`OfNat` は[次の節](polymorphism.md)で紹介する機能を必要とします．

<!-- ### HTTP Requests -->

### HTTPリクエスト

<!-- An HTTP request begins with an identification of a HTTP method, such as `GET` or `POST`, along with a URI and an HTTP version.
Define an inductive type that represents an interesting subset of the HTTP methods, and a structure that represents HTTP responses.
Responses should have a `ToString` instance that makes it possible to debug them.
Use a type class to associate different `IO` actions with each HTTP method, and write a test harness as an `IO` action that calls each method and prints the result. -->

HTTPリクエストはURIとHTTPバージョンとともに，`GET` や `POST` などのHTTPメソッドの識別子から始まります．HTTPメソッドのうち興味深いサブセットについてそれを表す帰納型と，HTTPレスポンスを表す構造体を定義してください．レスポンスには `ToString` インスタンスを持たせ，デバッグできるようにしてください．型クラスを使用して各HTTPメソッドに異なる `IO` アクションを関連付け，`IO` アクションで各メソッドを呼び出して結果を表示するテストハーネスを書いてください．
