<!-- # Additional Conveniences -->

# その他の便利な機能

<!-- ## Shared Argument Types -->

## 引数の型の共有

<!-- When defining a function that takes multiple arguments that have the same type, both can be written before the same colon.
For example, -->

同じ型の引数を複数受け取る関数を定義する際に，両者を同じコロンの前に書くことができます．例えば，

```lean
{{#example_decl Examples/Monads/Conveniences.lean equalHuhOld}}
```
<!-- can be written -->

は以下のように書くことができます．

```lean
{{#example_decl Examples/Monads/Conveniences.lean equalHuhNew}}
```
<!-- This is especially useful when the type signature is large. -->

これは型シグネチャが大きい際には特に役立ちます．

<!-- ## Leading Dot Notation -->

## ドット始まり記法

<!-- The constructors of an inductive type are in a namespace.
This allows multiple related inductive types to use the same constructor names, but it can lead to programs becoming verbose.
In contexts where the inductive type in question is known, the namespace can be omitted by preceding the constructor's name with a dot, and Lean uses the expected type to resolve the constructor names.
For example, a function that mirrors a binary tree can be written: -->

帰納型のコンストラクタはその型の名前空間の中に配置されます．これにより，異なる同種の帰納型に対して同じコンストラクタ名を使用することができますが，プログラムが冗長になる可能性があります．問題の帰納型が明確なコンテキストでは，コンストラクタ名の前にドットを付けることで，名前空間を省略することができます．Leanはこのコンストラクタ名を解決するために期待された型を使ってくれます．例えば，二分木をそっくりコピーする関数は次のように書くことができます：

```lean
{{#example_decl Examples/Monads/Conveniences.lean mirrorOld}}
```
<!-- Omitting the namespaces makes it significantly shorter, at the cost of making the program harder to read in contexts like code review tools that don't include the Lean compiler: -->

名前空間を省略することでプログラムが大幅に短くなりますが，その代償としてLeanのコンパイラが無いコードのレビューツール上などの状況下ではプログラムが読みにくくなります：

```lean
{{#example_decl Examples/Monads/Conveniences.lean mirrorNew}}
```

<!-- Using the expected type of an expression to disambiguate a namespace is also applicable to names other than constructors.
If `BinTree.empty` is defined as an alternative way of creating `BinTree`s, then it can also be used with dot notation: -->

どの名前空間を使うかが曖昧にしないために式の予想される型を使用することは，コンストラクタ以外の名前にも適用できます．`BinTree.empty` が `BinTree` を作成する代替方法として定義されている場合，ドット記法を用いることもできます：

```lean
{{#example_decl Examples/Monads/Conveniences.lean BinTreeEmpty}}

{{#example_in Examples/Monads/Conveniences.lean emptyDot}}
```
```output info
{{#example_out Examples/Monads/Conveniences.lean emptyDot}}
```

<!-- ## Or-Patterns -->

## orパターン

<!-- In contexts that allow multiple patterns, such as `match`-expressions, multiple patterns may share their result expressions.
The datatype `Weekday` that represents days of the week: -->

`match` 式のような複数のパターンを許容するコンテキストでは，複数のパターンで結果の式を共有することができます．曜日を表す `Weekday` データ型は以下のようになります：

```lean
{{#example_decl Examples/Monads/Conveniences.lean Weekday}}
```

<!-- Pattern matching can be used to check whether a day is a weekend: -->

ある日が週末かどうかをチェックするにはパターンマッチを使うことで実現できます：

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendA}}
```
<!-- This can already be simplified by using constructor dot notation: -->

これについてすでに見たようにコンストラクタのドット記法で単純化できます：

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendB}}
```
<!-- Because both weekend patterns have the same result expression (`true`), they can be condensed into one: -->

週末のパターンはどちらも同じ式 (`true`) を持つため，これらを1つにまとめることができます：

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendC}}
```
<!-- This can be further simplified into a version in which the argument is not named: -->

引数に名前をつけないバージョンにすることでさらに単純化できます：

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendD}}
```

<!-- Behind the scenes, the result expression is simply duplicated across each pattern.
This means that patterns can bind variables, as in this example that removes the `inl` and `inr` constructors from a sum type in which both contain the same type of value: -->

この裏側では，結果の式は各パターンに対してただ複製されます．このことはパターンで変数を束縛できることを意味します．次の例では，`inl` と `inr` のコンストラクタを両方とも同じ型の値を含む直和型から取り除いています：

```lean
{{#example_decl Examples/Monads/Conveniences.lean condense}}
```
<!-- Because the result expression is duplicated, the variables bound by the patterns are not required to have the same types.
Overloaded functions that work for multiple types may be used to write a single result expression that works for patterns that bind variables of different types: -->

結果の式は複製されるため，パターンによって束縛される変数が同じ型である必要はありません．複数の型に対して動作するオーバーロードされた関数を使用すると，異なる型の変数をバインドするパターンに対して動作する唯一の結果式を記述できます：

```lean
{{#example_decl Examples/Monads/Conveniences.lean stringy}}
```
<!-- In practice, only variables shared in all patterns can be referred to in the result expression, because the result must make sense for each pattern.
In `getTheNat`, only `n` can be accessed, and attempts to use either `x` or `y` lead to errors. -->

実用的には，すべてのパターンで共有されている変数のみが結果式で参照されます．というのも，その結果はすべてのパターンに対して成立しなければならないからです．`getTheNat` では，`n` だけがアクセス可能で，`x` や `y` を使おうとするとエラーになります．

```lean
{{#example_decl Examples/Monads/Conveniences.lean getTheNat}}
```
<!-- Attempting to access `x` in a similar definition causes an error because there is no `x` available in the second pattern: -->

同様の定義で `x` にアクセスしようとすると，2つ目のパターンには利用可能な `x` が無いためエラーとなります：

```lean
{{#example_in Examples/Monads/Conveniences.lean getTheAlpha}}
```
```output error
{{#example_out Examples/Monads/Conveniences.lean getTheAlpha}}
```

<!-- The fact that the result expression is essentially copy-pasted to each branch of the pattern match can lead to some surprising behavior.
For example, the following definitions are acceptable because the `inr` version of the result expression refers to the global definition of `str`: -->

結果の式は本質的にはパターンマッチの各分岐にコピペされるため，意外な動作をすることがあります．例えば，結果式の `inr` バージョンは `str` のうろーばる定義を参照するため，以下の定義が通ります：

```lean
{{#example_decl Examples/Monads/Conveniences.lean getTheString}}
```
<!-- Calling this function on both constructors reveals the confusing behavior.
In the first case, a type annotation is needed to tell Lean which type `β` should be: -->

この関数を両方のコンストラクタについて呼び出すと混乱するような動作が行われます．最初のケースでは，`β` がどの型であるべきかLeanに伝えるために型注釈が必要です：

```lean
{{#example_in Examples/Monads/Conveniences.lean getOne}}
```
```output info
{{#example_out Examples/Monads/Conveniences.lean getOne}}
```
<!-- In the second case, the global definition is used: -->

2番目のケースでは，グローバル定義が使われます：

```lean
{{#example_in Examples/Monads/Conveniences.lean getTwo}}
```
```output info
{{#example_out Examples/Monads/Conveniences.lean getTwo}}
```

<!-- Using or-patterns can vastly simplify some definitions and increase their clarity, as in `Weekday.isWeekend`.
Because there is a potential for confusing behavior, it's a good idea to be careful when using them, especially when variables of multiple types or disjoint sets of variables are involved. -->

orパターンを使うと，`Weekday.isWeekend` のように定義が大幅に簡略化され，わかりやすくなる定義も存在します．しかし混乱を招く挙動をする可能性があるため，特に複数の型の変数や変数の素集合からなる場合は慎重に使用することをお勧めします．
