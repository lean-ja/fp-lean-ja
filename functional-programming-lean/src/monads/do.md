<!--
# `do`-Notation for Monads
-->

# モナドのための `do` 記法

<!--
While APIs based on monads are very powerful, the explicit use of `>>=` with anonymous functions is still somewhat noisy.
Just as infix operators are used instead of explicit calls to `HAdd.hAdd`, Lean provides a syntax for monads called _`do`-notation_ that can make programs that use monads easier to read and write.
This is the very same `do`-notation that is used to write programs in `IO`, and `IO` is also a monad.
-->

モナドに基づくAPIは非常に強力ですが、匿名関数を伴った `>>=` の明示的な使用は多少煩雑さがあります。`HAdd.hAdd` を呼び出す代わりに中置演算子を使うように、Leanはモナドを使うプログラムの読み書きを簡単にすることができる **`do` 記法** と呼ばれる構文を提供しています。これは `IO` でプログラムを書くときに使われる `do` 記法とまったく同じもので、実際 `IO` もモナドです。

<!--
In [Hello, World!](../hello-world.md), the `do` syntax is used to combine `IO` actions, but the meaning of these programs is explained directly.
Understanding how to program with monads means that `do` can now be explained in terms of how it translates into uses of the underlying monad operators.
-->

[ハローワールド！](../hello-world.md) では、`do` 記法は `IO` アクションの組み合わせのために用いられていましたが、これらのプログラムの意味は `IO` に基づいて直接説明されていました。モナドを使ったプログラミングを理解することは、`do` がどのようなモナド演算子の使い方に変換されるかという観点から説明できるようになることを意味します。

<!--
The first translation of `do` is used when the only statement in the `do` is a single expression `E`.
In this case, the `do` is removed, so
-->

`do` の翻訳規則の1つ目は、`do` の中の文がただ1つの式 `E` である場合です。この場合、`do` は削除されます。

```lean
{{#example_in Examples/Monads/Do.lean doSugar1}}
```
<!--
translates to
-->

上記は以下のように訳されます。

```lean
{{#example_out Examples/Monads/Do.lean doSugar1}}
```

<!--
The second translation is used when the first statement of the `do` is a `let` with an arrow, binding a local variable.
This translates to a use of `>>=` together with a function that binds that very same variable, so
-->

2つ目の翻訳規則は、`do` の最初の文がローカル変数を束縛する矢印付きの `let` である場合に使用されます。これは、その変数名を束縛する関数と一緒に `>>=` を使うように訳されます。したがって、

```lean
{{#example_in Examples/Monads/Do.lean doSugar2}}
```
<!--
translates to
-->

は以下のように訳されます。

```lean
{{#example_out Examples/Monads/Do.lean doSugar2}}
```

<!--
When the first statement of the `do` block is an expression, then it is considered to be a monadic action that returns `Unit`, so the function matches the `Unit` constructor and
-->

`do` ブロックの最初の文が式の場合、その式は `Unit` を返すモナドのアクションであるとみなされ、脱糖後の後続関数は `Unit` コンストラクタにパターンマッチするものとなるため、

```lean
{{#example_in Examples/Monads/Do.lean doSugar3}}
```
<!--
translates to
-->

は以下のように訳されます。

```lean
{{#example_out Examples/Monads/Do.lean doSugar3}}
```

<!--
Finally, when the first statement of the `do` block is a `let` that uses `:=`, the translated form is an ordinary let expression, so
-->

最後に、`do` ブロックの最初の文が `:=` を使った `let` の場合、翻訳された形は普通のlet式になります。したがって、

```lean
{{#example_in Examples/Monads/Do.lean doSugar4}}
```
<!--
translates to
-->

は以下のように訳されます。

```lean
{{#example_out Examples/Monads/Do.lean doSugar4}}
```

<!--
The definition of `firstThirdFifthSeventh` that uses the `Monad` class looks like this:
-->

`Monad` クラスを用いた `firstThirdFifthSeventh` の定義は以下のようなものでした：

```lean
{{#example_decl Examples/Monads/Class.lean firstThirdFifthSeventhMonad}}
```
<!--
Using `do`-notation, it becomes significantly more readable:
-->

`do` 記法を使うことで、劇的に読みやすくなります：

```lean
{{#example_decl Examples/Monads/Do.lean firstThirdFifthSeventhDo}}
```

<!--
Without the `Monad` type class, the function `number` that numbers the nodes of a tree was written:
-->

`Monad` 型クラスを用いずに、木のノードに採番する関数 `number` は次のように記述しました：

```lean
{{#example_decl Examples/Monads.lean numberMonadicish}}
```
<!--
With `Monad` and `do`, its definition is much less noisy:
-->

`Monad` と `do` を用いると、定義からわずらわしさが軽減されます：

```lean
{{#example_decl Examples/Monads/Do.lean numberDo}}
```


<!--
All of the conveniences from `do` with `IO` are also available when using it with other monads.
For example, nested actions also work in any monad.
The original definition of `mapM` was:
-->

`IO` について `do` で得られた恩恵は、ほかのモナドでも享受できます。例えば、ネストされたアクションはどのモナドでも動作します。もともとの `mapM` の定義は以下の通りです：

```lean
{{#example_decl Examples/Monads/Class.lean mapM}}
```
<!--
With `do`-notation, it can be written:
-->

`do` 記法によって、これは以下のように書くことができます：

```lean
{{#example_decl Examples/Monads/Do.lean mapM}}
```
<!--
Using nested actions makes it almost as short as the original non-monadic `map`:
-->

ネストされたアクションを使うことで、もとの非モナドな `map` と同じくらい短い記述にすることができます：

```lean
{{#example_decl Examples/Monads/Do.lean mapMNested}}
```
<!--
Using nested actions, `number` can be made much more concise:
-->

ネストされたアクションを使うことで、`number` をより簡潔にすることができます：

```lean
{{#example_decl Examples/Monads/Do.lean numberDoShort}}
```



<!--
## Exercises
-->

## 演習問題

 <!--
 * Rewrite `evaluateM`, its helpers, and the different specific use cases using `do`-notation instead of explicit calls to `>>=`.
 * Rewrite `firstThirdFifthSeventh` using nested actions.
-->
 * `evaluateM` とそのヘルパー、そしていくつかの異なるユースケース例を、`>>=` を明示的に呼び出す代わりに `do` 記法を使用して書き直してください。
 * `firstThirdFifthSeventh` をネストされたアクションを使って書き直してください。
