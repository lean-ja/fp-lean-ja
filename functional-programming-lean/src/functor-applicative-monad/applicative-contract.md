<!--
# The Applicative Contract
-->

# アプリカティブ関手の約定

<!--
Just like `Functor`, `Monad`, and types that implement `BEq` and `Hashable`, `Applicative` has a set of rules that all instances should adhere to.
-->

`Functor` や `Monad` ，`BEq` と `Hashable` を実装した型と同じように，`Applicative` にはすべてのインスタンスで順守すべきルールがあります．

<!--
There are four rules that an applicative functor should follow:
-->

アプリカティブ関手は以下の4つのルールに従わなければなりません：

<!--
1. It should respect identity, so `pure id <*> v = v`
-->
1. 恒等性に配慮すべき，つまり `pure id <*> v = v`
<!--
2. It should respect function composition, so `pure (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)`
-->
2. 合成に配慮すべき，つまり `pure (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)`
<!--
3. Sequencing pure operations should be a no-op, so `pure f <*> pure x = pure (f x)`
-->
3. 純粋な演算を連ねても何も起こらないこと，つまり `pure f <*> pure x = pure (f x)`
<!--
4. The ordering of pure operations doesn't matter, so `u <*> pure x = pure (fun f => f x) <*> u`
-->
4. 純粋な演算は実行順序によらないこと，つまり `u <*> pure x = pure (fun f => f x) <*> u`

<!--
To check these for the `Applicative Option` instance, start by expanding `pure` into `some`.
-->

これらを `Applicative Option` のインスタンスでチェックするには，まず `pure` を `some` に展開します．

<!--
The first rule states that `some id <*> v = v`.
The definition of `seq` for `Option` states that this is the same as `id <$> v = v`, which is one of the `Functor` rules that have already been checked.
-->

最初のルールは `some id <*> v = v` です．`Option` の `seq` の定義によると，これは `id <$> v = v` と同じであり，この式はすでにチェック済みの `Functor` についてのルールのひとつです．

<!--
The second rule states that `some (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)`.
If any of `u`, `v`, or `w` is `none`, then both sides are `none`, so the property holds.
Assuming that `u` is `some f`, that `v` is `some g`, and that `w` is `some x`, then this is equivalent to saying that `some (· ∘ ·) <*> some f <*> some g <*> some x = some f <*> (some g <*> some x)`.
Evaluating the two sides yields the same result:
-->

2つ目のルールは `some (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)` です．もし `u` ，`v` ，`w` のいずれかが `none` であれば，両辺は `none` になり，式が成り立ちます．そこで `u` は `some f` ，`v` は `some g` ，`w` は `some x` であることを仮定すると，この式は `some (· ∘ ·) <*> some f <*> some g <*> some x = some f <*> (some g <*> some x)` であることと等しくなります．両辺を評価すると，同じ結果が得られます：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean OptionHomomorphism1}}

{{#example_eval Examples/FunctorApplicativeMonad.lean OptionHomomorphism2}}
```

<!--
The third rule follows directly from the definition of `seq`:
-->

3つ目のルールは，`seq` の定義から直接導かれます：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean OptionPureSeq}}
```

<!--
In the fourth case, assume that `u` is `some f`, because if it's `none`, both sides of the equation are `none`.
`some f <*> some x` evaluates directly to `some (f x)`, as does `some (fun g => g x) <*> some f`.
-->

4つ目のケースでは `u` を `some f` と仮定します．というのも，もし `none` であれば，等式の両辺は `none` になるからです．`some f <*> some x` は `some (f x)` へ直接評価され，`some (fun g => g x) <*> some f` も同じ式へ評価されます．

<!--
## All Applicatives are Functors
-->

## すべてのアプリカティブ関手は関手

<!--
The two operators for `Applicative` are enough to define `map`:
-->

`map` を定義するには，`Applicative` の2つの演算子で事足ります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeMap}}
```

<!--
This can only be used to implement `Functor` if the contract for `Applicative` guarantees the contract for `Functor`, however.
The first rule of `Functor` is that `id <$> x = x`, which follows directly from the first rule for `Applicative`.
The second rule of `Functor` is that `map (f ∘ g) x = map f (map g x)`.
Unfolding the definition of `map` here results in `pure (f ∘ g) <*> x = pure f <*> (pure g <*> x)`.
Using the rule that sequencing pure operations is a no-op, the left side can be rewritten to `pure (· ∘ ·) <*> pure f <*> pure g <*> x`.
This is an instance of the rule that states that applicative functors respect function composition.
-->

ただし，これは `Applicative` の約定が `Functor` の約定を保証している場合にのみ `Functor` の実装に使うことができます．`Functor` の最初のルールは `id <$> x = x` で，これは `Applicative` の最初のルールから直接導かれます．`Functor` の2番目のルールは `map (f ∘ g) x = map f (map g x)` です．ここで `map` の定義を展開すると `pure (f ∘ g) <*> x = pure f <*> (pure g <*> x)` となります．純粋な操作の連続は何も起こらないというルールを使えば，左辺は `pure (· ∘ ·) <*> pure f <*> pure g <*> x` と書き換えることができます．これはアプリカティブ関手が関数の合成に配慮するというルールの一例です．

<!--
This justifies a definition of `Applicative` that extends `Functor`, with a default definition of `map` given in terms of `pure` and `seq`:
-->

以上から `Applicative` の定義が `Functor` を継承したものであることが正当化され，`pure` と `seq` の観点から `map` のデフォルト定義が与えられます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeExtendsFunctorOne}}
```

<!--
## All Monads are Applicative Functors
-->

## すべてのモナドはアプリカティブ関手

<!--
An instance of `Monad` already requires an implementation of `pure`.
Together with `bind`, this is enough to define `seq`:
-->

`Monad` のインスタンスにはもうすでに `pure` の実装が必須でした．これに `bind` を用いれば，`seq` の定義には十分足ります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonadSeq}}
```
<!--
Once again, checking that the `Monad` contract implies the `Applicative` contract will allow this to be used as a default definition for `seq` if `Monad` extends `Applicative`.
-->

繰り返しになりますが，`Monad` の約定から `Applicative` の約定が導かれることをチェックすることで，`Monad` が `Applicative` を継承していれば上記を `seq` のデフォルト定義として使うことができます．

<!--
The rest of this section consists of an argument that this implementation of `seq` based on `bind` in fact satisfies the `Applicative` contract.
One of the beautiful things about functional programming is that this kind of argument can be worked out on a piece of paper with a pencil, using the kinds of evaluation rules from [the initial section on evaluating expressions](../getting-to-know/evaluating.md).
Thinking about the meanings of the operations while reading these arguments can sometimes help with understanding.
-->

この節の残りは，この `bind` に基づく `seq` の実装が実際に `Applicative` の約定を満たすという議論からなります．関数型プログラミングの素晴らしい点の1つは，このような論証が [式の評価に関する最初の節](../getting-to-know/evaluating.md)　にある評価ルールなどを使って，鉛筆で紙の上に書くことができることです．こうした議論を読みながら操作の意味を考えることは理解の助けになり得ます．

<!--
Replacing `do`-notation with explicit uses of `>>=` makes it easier to apply the `Monad` rules:
-->

`do` 記法の代わりに，`>>=` を明示的に使うことで `Monad` ルールを適用しやすくなります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonadSeqDesugar}}
```


<!--
To check that this definition respects identity, check that `seq (pure id) (fun () => v) = v`.
The left hand side is equivalent to `pure id >>= fun g => (fun () => v) () >>= fun y => pure (g y)`.
The unit function in the middle can be eliminated immediately, yielding `pure id >>= fun g => v >>= fun y => pure (g y)`.
Using the fact that `pure` is a left identity of `>>=`, this is the same as `v >>= fun y => pure (id y)`, which is `v >>= fun y => pure y`.
Because `fun x => f x` is the same as `f`, this is the same as `v >>= pure`, and the fact that `pure` is a right identity of `>>=` can be used to get `v`.
-->

この定義が恒等性に配慮していることを確認するには `seq (pure id) (fun () => v) = v` をチェックします．左辺は `pure id >>= fun g => (fun () => v) () >>= fun y => pure (g y)` と等価です．真ん中の単位関数はすぐに取り除くことができ，`pure id >>= fun g => v >>= fun y => pure (g y)` となります．`pure` が `>>=` の左単位であることを利用すると，これは `v >>= fun y => pure (id y)` と同じであり，`v >>= fun y => pure y` となります．`fun x => f x` は `f` と同じであるため，これは `v >>= pure` と等しく，`pure` が `>>=` の右単位であることを利用して `v` を得ることができます．

<!--
This kind of informal reasoning can be made easier to read with a bit of reformatting.
In the following chart, read "EXPR1 ={ REASON }= EXPR2" as "EXPR1 is the same as EXPR2 because REASON":
-->

このような非公式な推論は，少し書式を変えれば読みやすくなります．例えば，次の表に従うと「EXPR1 ={ REASON }= EXPR2」を「EXPR1はEXPR2と同じである」と読めます：
{{#equations Examples/FunctorApplicativeMonad.lean mSeqRespId}}

<!--
To check that it respects function composition, check that `pure (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)`.
The first step is to replace `<*>` with this definition of `seq`.
After that, a (somewhat long) series of steps that use the identity and associativity rules from the `Monad` contract is enough to get from one to the other:
-->

関数の合成に配慮することを確認するには，`pure (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)` をチェックします．最初のステップは `<*>` をこの `seq` の定義に置き換えることです．その後は `Monad` の約定による恒等性と結合性のルールによる一連のステップを踏むだけです（いくぶん長いですが）：
{{#equations Examples/FunctorApplicativeMonad.lean mSeqRespComp}}

<!--
To check that sequencing pure operations is a no-op:
-->

純粋な演算の列が何もしないことのチェックは次のようになります：
{{#equations Examples/FunctorApplicativeMonad.lean mSeqPureNoOp}}

<!--
And finally, to check that the ordering of pure operations doesn't matter:
-->

そして最後に，純粋な操作の順序が重要でないことを確認します：
{{#equations Examples/FunctorApplicativeMonad.lean mSeqPureNoOrder}}

<!--
This justifies a definition of `Monad` that extends `Applicative`, with a default definition of `seq`:
-->

以上から `Monad` の定義が `Applicative` を継承していることが正当化され，`seq` のデフォルト定義を持ちます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonadExtends}}
```
<!--
`Applicative`'s own default definition of `map` means that every `Monad` instance automatically generates `Applicative` and `Functor` instances as well.
-->

`Applicative` の固有のデフォルト定義の `map` はすべての `Monad` インスタンスが自動的に `Applicative` と `Functor` のインスタンスを生成することを意味します．

<!--
## Additional Stipulations
-->

## 追加の条項

<!--
In addition to adhering to the individual contracts associated with each type class, combined implementations `Functor`, `Applicative` and `Monad` should work equivalently to these default implementations.
In other words, a type that provides both `Applicative` and `Monad` instances should not have an implementation of `seq` that works differently from the version that the `Monad` instance generates as a default implementation.
This is important because polymorphic functions may be refactored to replace a use of `>>=` with an equivalent use of `<*>`, or a use of `<*>` with an equivalent use of `>>=`.
This refactoring should not change the meaning of programs that use this code.
-->

それぞれの型クラスに関連付けられた個々の約定を順守することに加えて，`Functor` と `Applicative` ，`Monad` を組み合わせた実装はこれらのデフォルトの実装と同等に動作する必要があります．言い換えると，`Applicative` と `Monad` インスタンスの両方を提供する型は，`Monad` インスタンスがデフォルトの実装として生成するバージョンと異なる動作をする `seq` の実装を持つべきではありません．これは多相関数をリファクタリングして `>>=` を等価な `<*>` に置き換えたり，`<*>` を等価な `>>=` に置き換えたりする場合があるため重要です．このリファクタリングによって，このコードを使用するプログラムの意味が変わることはあってはなりません．

<!--
This rule explains why `Validate.andThen` should not be used to implement `bind` in a `Monad` instance.
On its own, it obeys the monad contract.
However, when it is used to implement `seq`, the behavior is not equivalent to `seq` itself.
To see where they differ, take the example of two computations, both of which return errors.
Start with an example of a case where two errors should be returned, one from validating a function (which could have just as well resulted from a prior argument to the function), and one from validating an argument:
-->

このルールは，前節においてなぜ `Validate.andThen` を `Monad` インスタンスの `bind` の実装に使ってはいけないのかを説明します．この関数自体はモナドの約定に従います．しかし，`seq` を実装するために使用した場合，その動作は `seq` 自体と同等になりません．両者の違いを見るために，エラーを返す2つの計算を例にとってみましょう．2つのエラーを返すべきケースの例から始めると，1つは関数をバリデーションした結果（これは関数に先に渡された引数によるものでも同様に発生します），もう1つは引数のバリデーションによるものです：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean counterexample}}
```

<!--
Combining them with the version of `<*>` from `Validate`'s `Applicative` instance results in both errors being reported to the user:
-->

これらを `Validate` の `Applicative` インスタンスの `<*>` のバージョンと組み合わせると，両方のエラーがユーザに報告されます：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean realSeq}}
```

<!--
Using the version of `seq` that was implemented with `>>=`, here rewritten to `andThen`, results in only the first error being available:
-->

一方で `>>=` で実装されていた `seq` のバージョンを，ここでは `andThen` に書き換えて使用すると，最初のエラーしか利用できません：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean fakeSeq}}
```


