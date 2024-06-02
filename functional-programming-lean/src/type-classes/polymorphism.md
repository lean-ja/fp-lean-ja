<!-- # Type Classes and Polymorphism -->

# 型クラスと多相性

<!-- It can be useful to write functions that work for _any_ overloading of a given function.
For instance, `IO.println` works for any type that has an instance of `ToString`.
This is indicated using square brackets around the required instance: the type of `IO.println` is `{{#example_out Examples/Classes.lean printlnType}}`.
This type says that `IO.println` accepts an argument of type `α`, which Lean should determine automatically, and that there must be a `ToString` instance available for `α`.
It returns an `IO` action. -->

与えられた関数の _任意の_ オーバーロードされた関数でも動作するような関数を書くと便利です．例えば，`IO.println` は `ToString` のインスタンスを持つすべての型に対して動作します．これを実現するには対象のインスタンスを角括弧で囲むことが必要とされ，実際に `IO.println` の型は `{{#example_out Examples/Classes.lean printlnType}}` となっています．この型は `IO.println` が受け取る `α` 型の引数をLeanによって自動的に決定され，`α` に対して利用可能な `ToString` インスタンスがなければならないことを表しています．この関数は `IO` アクションを返します．

<!-- ## Checking Polymorphic Functions' Types -->

## 多相関数の型のチェック

<!-- Checking the type of a function that takes implicit arguments or uses type classes requires the use of some additional syntax.
Simply writing -->

暗黙の引数を取る関数や型クラスを使用する関数の型をチェックするにはいくつか追加の構文を利用する必要があります．単純に以下のように書くと

```lean
{{#example_in Examples/Classes.lean printlnMetas}}
```
<!-- yields a type with metavariables: -->

メタ変数を伴った以下の型を出力します：

```output info
{{#example_out Examples/Classes.lean printlnMetas}}
```
<!-- This is because Lean does its best to discover implicit arguments, and the presence of metavariables indicates that it did not yet discover enough type information to do so.
To understand the signature of a function, this feature can be suppressed with an at-sign (`@`) before the function's name: -->

Leanは暗黙の引数の発見に最善を尽くしますが，それでもメタ変数が存在するということから，暗黙の引数発見のために十分な型情報をまだ発見していないことを示しています．関数シグネチャを理解するために，関数名の前にアットマーク（ `@` ）を付けてこの機能を抑制することができます：

```lean
{{#example_in Examples/Classes.lean printlnNoMetas}}
```
```output info
{{#example_out Examples/Classes.lean printlnNoMetas}}
```
<!-- In this output, the instance itself has been given the name `inst`.
Additionally, there is a `u_1` after `Type`, which uses a feature of Lean that has not yet been introduced.
For now, ignore these parameters to `Type`. -->

この出力では，インスタンス自体に `inst` という名前が与えられています．さらに，`Type` の後に `u_1` が続いていますが，これはまだ紹介していないLeanの機能を使用しています．今時点ではこれらの `Type` へのパラメータは無視してください．

<!-- ## Defining Polymorphic Functions with Instance Implicits -->

## 暗黙のインスタンスを取る多相関数の定義

<!-- A function that sums all entries in a list needs two instances: `Add` allows the entries to be added, and an `OfNat` instance for `0` provides a sensible value to return for the empty list: -->

リストの要素をすべて足し合わせる関数は2つのインスタンスを必要とします： `Add` は要素を足すためのもので，`0` のための `OfNat` インスタンスは空のリストに対しての戻り値です：

```lean
{{#example_decl Examples/Classes.lean ListSum}}
```
<!-- This function can be used for a list of `Nat`s: -->

この関数は `Nat` のリストに対して使うことができます：

```lean
{{#example_decl Examples/Classes.lean fourNats}}

{{#example_in Examples/Classes.lean fourNatsSum}}
```
```output info
{{#example_out Examples/Classes.lean fourNatsSum}}
```
<!-- but not for a list of `Pos` numbers: -->

しかし `Pos` の数値のリストに対しては使えません：

```lean
{{#example_decl Examples/Classes.lean fourPos}}

{{#example_in Examples/Classes.lean fourPosSum}}
```
```output error
{{#example_out Examples/Classes.lean fourPosSum}}
```

<!-- Specifications of required instances in square brackets are called _instance implicits_.
Behind the scenes, every type class defines a structure that has a field for each overloaded operation.
Instances are values of that structure type, with each field containing an implementation.
At a call site, Lean is responsible for finding an instance value to pass for each instance implicit argument.
The most important difference between ordinary implicit arguments and instance implicits is the strategy that Lean uses to find an argument value.
In the case of ordinary implicit arguments, Lean uses a technique called _unification_ to find a single unique argument value that would allow the program to pass the type checker.
This process relies only on the specific types involved in the function's definition and the call site.
For instance implicits, Lean instead consults a built-in table of instance values. -->

角括弧で囲まれた必須なインスタンスの指定は _暗黙のインスタンス(instance implicit)_ と呼ばれます．裏側では，すべての型クラスはオーバーロードされた演算ごとのフィールドを持つ構造体として定義されています．インスタンスはその構造体の値であり，各フィールドには具体的な実装が含まれています．呼び出し先では，Leanが各暗黙引数のインスタンスに渡す値を見つける責任を負います．通常の暗黙引数と暗黙のインスタンス引数の最も重要な違いは，Leanが引数の値を見つけるために使用する戦略です．通常の暗黙引数の場合，Leanは _ユニフィケーション(unification)_ と呼ばれるテクニックを使って，プログラムが型チェッカをパスできるような一意の引数の値を見つけます．このプロセスは関数の定義と呼び出しにかかわる特定の型にのみ依存します．暗黙のインスタンスの場合，Leanはこの代わりにインスタンスの値の組み込みテーブルを参照します．

<!-- Just as the `OfNat` instance for `Pos` took a natural number `n` as an automatic implicit argument, instances may also take instance implicit arguments themselves.
The [section on polymorphism](../getting-to-know/polymorphism.md) presented a polymorphic point type: -->

`Pos` に対する `OfNat` のインスタンスが自然数 `n` を自動的な暗黙の引数として取っていたように，インスタンスもインスタンス自身の暗黙の引数を取ることができます．[多相性の節](../getting-to-know/polymorphism.md) では，多相なポイント型を紹介しました：

```lean
{{#example_decl Examples/Classes.lean PPoint}}
```
<!-- Addition of points should add the underlying `x` and `y` fields.
Thus, an `Add` instance for `PPoint` requires an `Add` instance for whatever type these fields have.
In other words, the `Add` instance for `PPoint` requires a further `Add` instance for `α`: -->

点の足し算を考える際には，その中にある `x` フィールドと `y` フィールド同士を足し算する必要があります．したがって，`PPoint` の `Add` インスタンスには，これらのフィールドの型がどういうものであってもそれ自体にも `Add` インスタンスが必要になります．言い換えると，`PPoint` の `Add` インスタンスには，さらに `α` の `Add` インスタンスが必要になります：

```lean
{{#example_decl Examples/Classes.lean AddPPoint}}
```
<!-- When Lean encounters an addition of two points, it searches for and finds this instance.
It then performs a further search for the `Add α` instance. -->

Leanが2つの点の足し算に遭遇すると，まずこのインスタンスを検索して見つけます．そして，`Add α` インスタンスをさらに検索します．

<!-- The instance values that are constructed in this way are values of the type class's structure type.
A successful recursive instance search results in a structure value that has a reference to another structure value.
An instance of `Add (PPoint Nat)` contains a reference to the instance of `Add Nat` that was found. -->

このようにして構築されるインスタンスの値は，型クラスの構造体型としての値です．再帰的なインスタンスの探索に成功すると，さらに別の構造体の値への参照を持つ構造体の値が得られます．`Add (PPoint Nat)` のインスタンスはこの過程で見つかった `Add Nat` のインスタンスへの参照を持ちます．

<!-- This recursive search process means that type classes offer significantly more power than plain overloaded functions.
A library of polymorphic instances is a set of code building blocks that the compiler will assemble on its own, given nothing but the desired type.
Polymorphic functions that take instance arguments are latent requests to the type class mechanism to assemble helper functions behind the scenes.
The API's clients are freed from the burden of plumbing together all of the necessary parts by hand. -->

この再帰的な探索プロセスは，型クラスが単なるオーバーロードされた関数よりもはるかに大きなパワーを提供することを意味します．多相なインスタンスのライブラリは，コンパイラが独自に組み立てるコードを組むためのブロックの集合であり，必要な型以外は何も与えられていません．インスタンスを引数に取る多相関数は，型クラスの機構に対して，裏側でヘルパー関数を組み立てるように潜在的に要求しています．APIのクライアントは，必要な部分をすべて手作業で組み立てる負担から解放されます．

<!-- ## Methods and Implicit Arguments -->

## メソッドと暗黙の引数

<!-- The type of `{{#example_in Examples/Classes.lean ofNatType}}` may be surprising.
It is `{{#example_out Examples/Classes.lean ofNatType}}`, in which the `Nat` argument `n` occurs as an explicit function argument.
In the declaration of the method, however, `ofNat` simply has type `α`.
This seeming discrepancy is because declaring a type class really results in the following: -->

`{{#example_in Examples/Classes.lean ofNatType}}` の型は意外に思われるかもしれません．これは `{{#example_out Examples/Classes.lean ofNatType}}` であり，`Nat` の引数 `n` は明示的な関数の引数として渡されます．しかし，メソッドの宣言においては `ofNat` は単に `α` 型を持ちます．このように一見矛盾しているように見えるのは，型クラスを宣言すると実際には以下のものが生成されるからです：

 <!-- * A structure type to contain the implementation of each overloaded operation -->
 * 各オーバーロードされた演算の実装を持った構造体型
 <!-- * A namespace with the same name as the class -->
 * クラスと同じ名前の名前空間
 <!-- * For each method, a function in the class's namespace that retrieves its implementation from an instance -->
 * 各メソッドについて，インスタンスから実装を読んでくるためのクラスの名前空間にある関数

<!-- This is analogous to the way that declaring a new structure also declares accessor functions.
The primary difference is that a structure's accessors take the structure value as an explicit argument, while the type class methods take the instance value as an instance implicit to be found automatically by Lean. -->

これは新しい構造体を宣言すると，アクセサ関数も宣言されるのと似ています．主な違いは，構造体のアクセサが構造体の値を明示的な引数として受け取るのに対し，型クラスのメソッドはインスタンスの値を暗黙のインスタンスとして受け取り，Leanが自動的に判定するようになっている点です．

<!-- In order for Lean to find an instance, its arguments must be available.
This means that each argument to the type class must be an argument to the method that occurs before the instance.
It is most convenient when these arguments are implicit, because Lean does the work of discovering their values.
For example, `{{#example_in Examples/Classes.lean addType}}` has the type `{{#example_out Examples/Classes.lean addType}}`.
In this case, the type argument `α` can be implicit because the arguments to `Add.add` provide information about which type the user intended.
This type can then be used to search for the `Add` instance. -->

Leanがインスタンスを見つけるためには，そのインスタンスの引数が利用可能でなければなりません．これは型クラスへの各引数が，メソッドの引数としてインスタンスの前に現れなければならないことを意味します．これらの引数を暗黙的にすると，Leanがその値を発見する作業を行ってくれるためとても便利です．例えば，`{{#example_in Examples/Classes.lean addType}}` は `{{#example_out Examples/Classes.lean addType}}` という型を持っています．この場合，`Add.add` の引数がユーザが意図した型に関する情報を提供するため，型の引数 `α` は暗黙に指定することができます．この型を使用して `Add` インスタンスを検索することができます．

<!-- In the case of `ofNat`, however, the particular `Nat` literal to be decoded does not appear as part of any other argument.
This means that Lean would have no information to use when attempting to figure out the implicit argument `n`.
The result would be a very inconvenient API.
Thus, in these cases, Lean uses an explicit argument for the class's method. -->

しかし `ofNat` の場合，デコードされる特定の `Nat` リテラルはほかの引数の一部として現れません．これは，Leanが暗黙の引数 `n` を解釈しようとするときに，使用する情報がないことを意味します．その結果，非常に不便なAPIになってしまいます．したがってこのような場合，Leanはクラスのメソッドに明示的な引数を使用します．

<!-- ## Exercises -->

## 演習問題

<!-- ### Even Number Literals -->

### 偶数値リテラル

<!-- Write an instance of `OfNat` for the even number datatype from the [previous section's exercises](pos.md#even-numbers) that uses recursive instance search.
For the base instance, it is necessary to write `OfNat Even Nat.zero` instead of `OfNat Even 0`. -->

[前節の練習問題](pos.md#偶数) に出てきた偶数データ型用の `OfNat` のインスタンスを再帰的なインスタンス探索を使って書いてください．ベースとなるインスタンスには `OfNat Even 0` ではなく `OfNat Even Nat.zero` と書く必要があります．

<!-- ### Recursive Instance Search Depth -->

### 再帰的なインスタンス探索の深さ

<!-- There is a limit to how many times the Lean compiler will attempt a recursive instance search.
This places a limit on the size of even number literals defined in the previous exercise.
Experimentally determine what the limit is. -->

Leanのコンパイラが再帰的なインスタンス探索を試みる回数には上限があります．これは前の練習問題で定義した偶数リテラルのサイズに制限を設けます．実験的にその制限を確認してみてください．
