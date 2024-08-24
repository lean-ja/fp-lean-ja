<!--
# The Monad Type Class
-->

# モナド型クラス

<!--
Rather than having to import an operator like `ok` or `andThen` for each type that is a monad, the Lean standard library contains a type class that allow them to be overloaded, so that the same operators can be used for _any_ monad.
Monads have two operations, which are the equivalent of `ok` and `andThen`:
-->

モナドの型ごとに `ok` や `andThen` のような演算子を導入する代わりに、Lean標準ライブラリにはそれらをオーバーロードできる型クラスがあるため、同じ演算子を **任意の** モナドに使うことができます。モナドには `ok` と `andThen` に相当する2つの演算があります：

```lean
{{#example_decl Examples/Monads/Class.lean FakeMonad}}
```
<!--
This definition is slightly simplified.
The actual definition in the Lean library is somewhat more involved, and will be presented later.
-->

この定義は実態より若干簡略化されています。Leanのライブラリにおける実際の定義はもう少し複雑ですが、それは後程紹介しましょう。

<!--
The `Monad` instances for `Option` and `Except` can be created by adapting the definitions of their respective `andThen` operations:
-->

`Option` と `Except` の `Monad` インスタンスは、それぞれの `andThen` 演算を適合させることで作成できます：

```lean
{{#example_decl Examples/Monads/Class.lean MonadOptionExcept}}
```

<!--
As an example, `firstThirdFifthSeventh` was defined separately for `Option α` and `Except String α` return types.
Now, it can be defined polymorphically for _any_ monad.
It does, however, require a lookup function as an argument, because different monads might fail to find a result in different ways.
The infix version of `bind` is `>>=`, which plays the same role as `~~>` in the examples.
-->

例として出した `firstThirdFifthSeventh` は `Option α` と `Except String α` の戻り値型に対して個別に定義されていました。しかし今やこの関数を **任意の** モナドに多相的に定義することができます。ただし、別のモナドによる異なる実装では結果を見つけることができないかもしれないため、引数としてルックアップ関数が必要です。例で出した `~~>` と同じ役割を果たしていた `bind` の中置バージョンは `>>=` です。

```lean
{{#example_decl Examples/Monads/Class.lean firstThirdFifthSeventhMonad}}
```

<!--
Given example lists of slow mammals and fast birds, this implementation of `firstThirdFifthSeventh` can be used with `Option`:
-->

この `firstThirdFifthSeventh` の実装は、のろい哺乳類と速い鳥の名前のリストを例として `Option` について利用することが可能です：

```lean
{{#example_decl Examples/Monads/Class.lean animals}}

{{#example_in Examples/Monads/Class.lean noneSlow}}
```
```output info
{{#example_out Examples/Monads/Class.lean noneSlow}}
```
```lean
{{#example_in Examples/Monads/Class.lean someFast}}
```
```output info
{{#example_out Examples/Monads/Class.lean someFast}}
```

<!--
After renaming `Except`'s lookup function `get` to something more specific, the very same  implementation of `firstThirdFifthSeventh` can be used with `Except` as well:
-->

`Except` のルックアップ関数 `get` をもう少し実態に即したものに名称変更することで、先ほどと全く同じ `firstThirdFifthSeventh` の実装を `Except` についても使うことができます：

```lean
{{#example_decl Examples/Monads/Class.lean getOrExcept}}

{{#example_in Examples/Monads/Class.lean errorSlow}}
```
```output info
{{#example_out Examples/Monads/Class.lean errorSlow}}
```
```lean
{{#example_in Examples/Monads/Class.lean okFast}}
```
```output info
{{#example_out Examples/Monads/Class.lean okFast}}
```
<!--
The fact that `m` must have a `Monad` instance means that the `>>=` and `pure` operations are available.
-->

`m` が `Monad` インスタンスを持っていなければならないということは、`>>=` と `pure` 演算が利用できるということを意味します。

<!--
## General Monad Operations
-->

## 良く使われるモナドの演算

<!--
Because many different types are monads, functions that are polymorphic over _any_ monad are very powerful.
For example, the function `mapM` is a version of `map` that uses a `Monad` to sequence and combine the results of applying a function:
-->

実に多くの型がモナドであるため、**任意の** モナドに対して多相性を持つ関数は非常に強力です。例えば、関数 `mapM` はモナド用の `map` で、`Monad` を使って関数を適用した結果を順番に並べたり組み合わせたりします：

```lean
{{#example_decl Examples/Monads/Class.lean mapM}}
```
<!--
The return type of the function argument `f` determines which `Monad` instance will be used.
In other words, `mapM` can be used for functions that produce logs, for functions that can fail, or for functions that use mutable state.
Because `f`'s type determines the available effects, they can be tightly controlled by API designers.
-->

関数 `f` の戻り値の型によって、どの `Monad` インスタンスを使うかが決まります。つまり、`mapM` はログを生成する関数や失敗する可能性のある関数、可変状態を使用する関数などのどれにでも使用することができるのです。`f` の型が利用可能な作用を決定するため、API設計者はその作用を厳密に制御することができます。

<!--
As described in [this chapter's introduction](../monads.md#numbering-tree-nodes), `State σ α` represents programs that make use of a mutable variable of type `σ` and return a value of type `α`.
These programs are actually functions from a starting state to a pair of a value and a final state.
The `Monad` class requires that its parameter expect a single type argument—that is, it should be a `Type → Type`.
This means that the instance for `State` should mention the state type `σ`, which becomes a parameter to the instance:
-->

[本章の導入](../monads.md#numbering-tree-nodes) で説明したように、`State σ α` という型は `σ` 型の可変変数を使用し、`α` 型の値を返すプログラムを表します。これらのプログラムは、実際には初期状態から値と最終状態のペアへの関数です。`Monad` クラスは引数がただの型であることを求めます。つまり、`Monad` となる型は `Type → Type` であることを要求されます。したがって `State` のインスタンスは状態の型 `σ` を指定しておく必要があり、これがインスタンスのパラメータになることを意味します：

```lean
{{#example_decl Examples/Monads/Class.lean StateMonad}}
```
<!--
This means that the type of the state cannot change between calls to `get` and `set` that are sequenced using `bind`, which is a reasonable rule for stateful computations.
The operator `increment` increases a saved state by a given amount, returning the old value:
-->

これは `bind` を使って `get` と `set` を連続して呼び出している間において状態の型を変更できないことを意味し、ステートフルな計算の規則として理にかなっています。`increment` 演算子は保存された状態を指定された量だけ増価させ、古い値を返します：

```lean
{{#example_decl Examples/Monads/Class.lean increment}}
```

<!--
Using `mapM` with `increment` results in a program that computes the sum of the entries in a list.
More specifically, the mutable variable contains the sum so far, while the resulting list contains a running sum.
In other words, `{{#example_in Examples/Monads/Class.lean mapMincrement}}` has type `{{#example_out Examples/Monads/Class.lean mapMincrement}}`, and expanding the definition of `State` yields `{{#example_out Examples/Monads/Class.lean mapMincrement2}}`.
It takes an initial sum as an argument, which should be `0`:
-->

`mapM` を `increment` と一緒に使うと、リスト内の要素の合計を計算するプログラムになります。より具体的には、可変変数には最終的な合計が格納され、戻り値のリストには実行中の各合計が格納されます。言い換えると、`{{#example_in Examples/Monads/Class.lean mapMincrement}}` は `{{#example_out Examples/Monads/Class.lean mapMincrement}}` 型を持ち、`State` の定義を展開すると `{{#example_out Examples/Monads/Class.lean mapMincrement2}}` が得られます。これらは引数として合計の初期値を引数に取り、これは `0` でなければなりません：

```lean
{{#example_in Examples/Monads/Class.lean mapMincrementOut}}
```
```output info
{{#example_out Examples/Monads/Class.lean mapMincrementOut}}
```

<!--
A [logging effect](../monads.md#logging) can be represented using `WithLog`.
Just like `State`, its `Monad` instance is polymorphic with respect to the type of the logged data:
-->

[ロギングの作用](../monads.md#logging) は`WithLog` を使って表現することができました。`State` と同様に、その `Monad` インスタンスはログに記録されているデータの型に対して多相的です：

```lean
{{#example_decl Examples/Monads/Class.lean MonadWriter}}
```
<!--
`saveIfEven` is a function that logs even numbers but returns its argument unchanged:
-->

`saveIfEven` は偶数についてログを出力して、引数について何もせずに返却する関数です：

```lean
{{#example_decl Examples/Monads/Class.lean saveIfEven}}
```
<!--
Using this function with `mapM` results in a log containing even numbers paired with an unchanged input list:
-->

この関数を `mapM` と一緒に使うと、偶数についてのログと変更されていないリストがペアになった結果が得られます：

```lean
{{#example_in Examples/Monads/Class.lean mapMsaveIfEven}}
```
```output info
{{#example_out Examples/Monads/Class.lean mapMsaveIfEven}}
```



<!--
## The Identity Monad
-->

## 恒等モナド

<!--
Monads encode programs with effects, such as failure, exceptions, or logging, into explicit representations as data and functions.
Sometimes, however, an API will be written to use a monad for flexibility, but the API's client may not require any encoded effects.
The _identity monad_ is a monad that has no effects, and allows pure code to be used with monadic APIs:
-->

モナドは失敗、例外、ロギングなどの作用を持つプログラムをデータや関数として明示的に表現します。しかし、柔軟性のためにモナドを使用するように設計されたAPIに対して、時にはエンコードされた作用を必要としない利用者もいます。**恒等モナド** （identity monad）は作用を持たないモナドであり、純粋なコードをモナドAPIで使用することを可能にします：

```lean
{{#example_decl Examples/Monads/Class.lean IdMonad}}
```
<!--
The type of `pure` should be `α → Id α`, but `Id α` reduces to just `α`.
Similarly, the type of `bind` should be `α → (α → Id β) → Id β`.
Because this reduces to `α → (α → β) → β`, the second argument can be applied to the first to find the result.
-->

`pure` の型は `α → Id α` であるべきですが、`Id α` はただの `α` に簡約されます。同様に、`bind` の型は `α → (α → Id β) → Id β` であるべきです。これは `α → (α → β) → β` に簡約されるため、2番目の引数を1番目の引数に適用して結果を求めることができます。

<!--
With the identity monad, `mapM` becomes equivalent to `map`.
To call it this way, however, Lean requires a hint that the intended monad is `Id`:
-->

恒等関手を使うことで、`mapM` は `map` と同じものになります。ただし、このように呼ぶにあたって、Leanは意図したモナドが `Id` であることのヒントを要求します：

```lean
{{#example_in Examples/Monads/Class.lean mapMId}}
```
```output info
{{#example_out Examples/Monads/Class.lean mapMId}}
```
<!--
Omitting the hint results in an error:
-->

ヒントを無くすとエラーになります：

```lean
{{#example_in Examples/Monads/Class.lean mapMIdNoHint}}
```
```output error
{{#example_out Examples/Monads/Class.lean mapMIdNoHint}}
```
<!--
In this error, the application of one metavariable to another indicates that Lean doesn't run the type-level computation backwards.
The return type of the function is expected to be the monad applied to some other type.
Similarly, using `mapM` with a function whose type doesn't provide any specific hints about which monad is to be used results in an "instance problem stuck" message:
-->

このエラーでは、あるメタ変数を別の変数に適用することで、Leanが型レベルの計算を逆方向に実行していないことを示しています。この関数の戻り値の型は、ほかの型に適用されたモナドであることが期待されます。同様に、型がどのモナドを使用するかについての具体的なヒントを提供しない関数で `mapM` を使用すると、「インスタンス問題のスタック」というメッセージが表示されます：

```lean
{{#example_in Examples/Monads/Class.lean mapMIdId}}
```
```output error
{{#example_out Examples/Monads/Class.lean mapMIdId}}
```


<!--
## The Monad Contract
-->

## モナドの約定

<!--
Just as every pair of instances of `BEq` and `Hashable` should ensure that any two equal values have the same hash, there is a contract that each instance of `Monad` should obey.
First, `pure` should be a left identity of `bind`.
That is, `bind (pure v) f` should be the same as `f v`.
Secondly, `pure` should be a right identity of `bind`, so `bind v pure` is the same as `v`.
Finally, `bind` should be associative, so `bind (bind v f) g` is the same as `bind v (fun x => bind (f x) g)`.
-->

`Beq` と `Hashable` のインスタンスのすべてのペアが等しい2つの値が同じハッシュ値を持つことを保証しなければならないように、`Monad` のインスタンスにも従うべき約定が存在します。まず、`pure` は `bind` の左単位でなければなりません。つまり、`bind (pure v) f` は `f v` と同じでなければなりません。次に、`pure` は `bind` の右単位でもあるべきで、`bind v pure` は `v` と同じとなります。最後に、`bind` は結合的であるべきで、`bind (bind v f) g` は `bind v (fun x => bind (f x) g)` と同じです。

<!--
This contract specifies the expected properties of programs with effects more generally.
Because `pure` has no effects, sequencing its effects with `bind` shouldn't change the result.
The associative property of `bind` basically says that the sequencing bookkeeping itself doesn't matter, so long as the order in which things are happening is preserved.
-->

この約定はより一般的に作用を持つプログラムに期待される特性を規定しています。`pure` は作用を持たないため、`bind` で作用を続けても結果は変わらないはずです。`bind` の結合性は、基本的に物事が起こっている順序が保たれていれば、処理の実行順番自体はどう行っても問題ないことを言っています。

<!--
## Exercises
-->

## 演習問題

<!--
### Mapping on a Tree
-->

### 木へのマッピング

<!--
Define a function `BinTree.mapM`.
By analogy to `mapM` for lists, this function should apply a monadic function to each data entry in a tree, as a preorder traversal.
The type signature should be:
-->

関数 `BinTree.mapM` を定義してください。リストの `mapM` と同様に、この関数は木の各データ要素に行きがけ順でモナド関数を適用する必要があります。型シグネチャは以下のようになります：

```
def BinTree.mapM [Monad m] (f : α → m β) : BinTree α → m (BinTree β)
```


<!--
### The Option Monad Contract
-->

### Optionモナドの約定

<!--
First, write a convincing argument that the `Monad` instance for `Option` satisfies the monad contract.
Then, consider the following instance:
-->

まず `Option` の `Monad` インスタンスがモナドの約定を満たすことへの根拠を書き出してください。次に、以下のインスタンスを考えてみましょう：

```lean
{{#example_decl Examples/Monads/Class.lean badOptionMonad}}
```
<!--
Both methods have the correct type.
Why does this instance violate the monad contract?
-->

どちらのメソッドも正しい型です。ではなぜこのインスタンスはモナドの約定を破っているのでしょうか？

