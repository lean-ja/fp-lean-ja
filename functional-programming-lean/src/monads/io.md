<!--
# The IO Monad
-->

# IOモナド

<!--
`IO` as a monad can be understood from two perspectives, which were described in the section on [running programs](../hello-world/running-a-program.md).
Each can help to understand the meanings of `pure` and `bind` for `IO`.
-->

モナドとしての `IO` は2つの観点から理解することができます．これは [プログラムの実行](../hello-world/running-a-program.md) の節で説明したとおりです．それぞれの観点から，`IO` における `pure` と `bind` の意味の理解が促進されます．

<!--
From the first perspective, an `IO` action is an instruction to Lean's run-time system.
For example, the instruction might be "read a string from this file descriptor, then re-invoke the pure Lean code with the string".
This perspective is an _exterior_ one, viewing the program from the perspective of the operating system.
In this case, `pure` is an `IO` action that does not request any effects from the RTS, and `bind` instructs the RTS to first carry out one potentially-effectful operation and then invoke the rest of the program with the resulting value.
-->

最初の観点では，`IO` アクションはLeanのランタイムシステム（RTS）に対する命令として捉えられていました．その命令は，例えば「このファイル記述子から文字列を読み込み，その文字列で純粋なLeanコードを再度呼んでください」などのようなものです．この観点は **外部的な** もので，オペレーティングシステム側からプログラムを見ています．この場合，`pure` は `IO` アクションであり，RTSにいかなる作用も要求しません．また，`bind` はRTSに対して，まず潜在的に作用を持つ操作を実行し，その結果得られた値で残りのプログラムを呼び出すように指示します．

<!--
From the second perspective, an `IO` action transforms the whole world.
`IO` actions are actually pure, because they receive a unique world as an argument and then return the changed world.
This perspective is an _interior_ one that matches how `IO` is represented inside of Lean.
The world is represented in Lean as a token, and the `IO` monad is structured to make sure that each token is used exactly once.
-->

2つ目の観点では，`IO` アクションは世界全体を変換すると考えられます．`IO` アクション自体は純粋です．というのもこれは一意な世界を引数として受け取り，変更後の世界を返すからです．この観点は **内部的な** もので，Leanの内部での `IO` の表現方法に一致します．Leanにおいて世界はトークンとして表現され，`IO` モナドは各トークンが正確に一度だけ利用されるように構造化されています．

<!--
To see how this works, it can be helpful to peel back one definition at a time.
The `#print` command reveals the internals of Lean datatypes and definitions.
For example,
-->

これがどのように動作するかを知るためには，定義を1つずつはがしていくことが有用です．`#print` コマンドはLeanのデータ型と定義の内部を明らかにします．例えば，

```lean
{{#example_in Examples/Monads/IO.lean printNat}}
```
<!--
results in
-->

は以下の結果となります．

```output info
{{#example_out Examples/Monads/IO.lean printNat}}
```
<!--
and
-->

また，

```lean
{{#example_in Examples/Monads/IO.lean printCharIsAlpha}}
```
<!--
results in
-->

は以下の結果となります．

```output info
{{#example_out Examples/Monads/IO.lean printCharIsAlpha}}
```

<!--
Sometimes, the output of `#print` includes Lean features that have not yet been presented in this book.
For example,
-->

`#print` の出力にはこの本でまだ紹介されていないLeanの特徴が含まれることが時折あります．例えば，

```lean
{{#example_in Examples/Monads/IO.lean printListIsEmpty}}
```
<!--
produces
-->

は以下を出力します．

```output info
{{#example_out Examples/Monads/IO.lean printListIsEmpty}}
```
<!--
which includes a `.{u}` after the definition's name, and annotates types as `Type u` rather than just `Type`.
This can be safely ignored for now.
-->

ここで，上記の定義名の後ろに `.{u}` が含まれ，また型に対してただの `Type` ではなく `Type u` と注釈されています．これについては今のところ無視して問題ありません．

<!--
Printing the definition of `IO` shows that it's defined in terms of simpler structures:
-->

`IO` の定義を表示すると，思ったより単純な構造で定義されていることがわかります：

```lean
{{#example_in Examples/Monads/IO.lean printIO}}
```
```output info
{{#example_out Examples/Monads/IO.lean printIO}}
```
<!--
`IO.Error` represents all the errors that could be thrown by an `IO` action:
-->

`IO.Error` は `IO` アクションが投げる可能性のあるすべてのエラーを表します：

```lean
{{#example_in Examples/Monads/IO.lean printIOError}}
```
```output info
{{#example_out Examples/Monads/IO.lean printIOError}}
```
<!--
`EIO ε α` represents `IO` actions that will either terminate with an error of type `ε` or succeed with a value of type `α`.
This means that, like the `Except ε` monad, the `IO` monad includes the ability to define error handling and exceptions.
-->

`EIO ε α` は，`ε` 型のエラーで終了するか，`α` 型の値で成功するかのどちらかになる `IO` アクションを表します．つまり，`Except ε` と同じように `IO` モナドにもエラー処理と例外を定義することができます．

<!--
Peeling back another layer, `EIO` is itself defined in terms of a simpler structure:
-->

さらに展開をはがすと，`EIO` もまたとてもシンプルな構造で定義されています：

```lean
{{#example_in Examples/Monads/IO.lean printEIO}}
```
```output info
{{#example_out Examples/Monads/IO.lean printEIO}}
```
<!--
The `EStateM` monad includes both errors and state—it's a combination of `Except` and `State`.
It is defined using another type, `EStateM.Result`:
-->

`EStateM` モナドはエラーと状態の両方を保持しています．つまり `Except` と `State` を組み合わせたものです．このモナドは `EStateM.Result` という別の型を使って定義されています：

```lean
{{#example_in Examples/Monads/IO.lean printEStateM}}
```
```output info
{{#example_out Examples/Monads/IO.lean printEStateM}}
```
<!--
In other words, a program with type `EStateM ε σ α` is a function that accepts an initial state of type `σ` and returns an `EStateM.Result ε σ α`.
-->

言い換えると，`EStateM ε σ α` 型を持つプログラムは初期状態として `σ` を受け取り，戻り値として `EStateM.Result ε σ α` を返す関数です．

<!--
`EStateM.Result` is very much like the definition of `Except`, with one constructor that indicates a successful termination and one constructor that indicates an error:
-->

`EStateM.Result` の定義は `Except` とよく似ており，正常終了とエラーそれぞれに対して1つずつコンストラクタがあります：

```lean
{{#example_in Examples/Monads/IO.lean printEStateMResult}}
```
```output info
{{#example_out Examples/Monads/IO.lean printEStateMResult}}
```
<!--
Just like `Except ε α`, the `ok` constructor includes a result of type `α`, and the `error` constructor includes an exception of type `ε`.
Unlike `Except`, both constructors have an additional state field that includes the final state of the computation.
-->

`Except ε α` と同様に，`ok` コンストラクタには `α` 型の結果が，`error` コンストラクタには `ε` 型の例外が含まれます．`Except` とは異なり，どちらのコンストラクタにも計算の最終状態を示す状態のフィールドが追加されています．

<!--
The `Monad` instance for `EStateM ε σ` requires `pure` and `bind`.
Just as with `State`, the implementation of `pure` for `EStateM` accepts an initial state and returns it unchanged, and just as with `Except`, it returns its argument in the `ok` constructor:
-->

`EStateM ε σ` の `Monad` インスタンスを定義するには `pure` と `bind` が必要です．`State` と同様に，`EStateM` の `pure` の実装は初期状態を受け取り，それを変更せずに返却します．これも `Except` と同様に，`ok` コンストラクタに引数を入れて返却します：

```lean
{{#example_in Examples/Monads/IO.lean printEStateMpure}}
```
```output info
{{#example_out Examples/Monads/IO.lean printEStateMpure}}
```
<!--
`protected` means that the full name `EStateM.pure` is needed even if the `EStateM` namespace has been opened.
-->

`protected` は `EStateM` 名前空間がオープンされていても，呼び出す際には `EStateM.pure` とフルネームを使う必要があることを意味します．

<!--
Similarly, `bind` for `EStateM` takes an initial state as an argument.
It passes this initial state to its first action.
Like `bind` for `Except`, it then checks whether the result is an error.
If so, the error is returned unchanged and the second argument to `bind` remains unused.
If the result was a success, then the second argument is applied to both the returned value and to the resulting state.
-->

同様に，`EStateM` の `bind` は初期状態を引数に取ります．この初期状態は最初のアクションに渡されます．そして `Except` の `bind` と同様に，結果がエラーかどうかのチェックを行います．もしエラーであれば，そのエラーがそのまま返却され，`bind` の第2引数は未使用のままとなります．結果が成功だった場合は，2番目の引数は戻り値と結果の状態の両方に適用されます．

```lean
{{#example_in Examples/Monads/IO.lean printEStateMbind}}
```
```output info
{{#example_out Examples/Monads/IO.lean printEStateMbind}}
```

<!--
Putting all of this together, `IO` is a monad that tracks state and errors at the same time.
The collection of available errors is that given by the datatype `IO.Error`, which has constructors that describe many things that can go wrong in a program.
The state is a type that represents the real world, called `IO.RealWorld`.
Each basic `IO` action receives this real world and returns another one, paired either with an error or a result.
In `IO`, `pure` returns the world unchanged, while `bind` passes the modified world from one action into the next action.
-->

これらをすべてまとめると，`IO` は状態とエラーを同時に追跡するモナドということになります．利用可能なエラーのあつまりは，`IO.Error` というデータ型によって与えられ，これはプログラム中に起こりうる様々なエラーを記述するコンストラクタを持ちます．状態は `IO.RealWorld` という実世界を表すデータ型です．それぞれの基本的な `IO` アクションはこの実世界を受け取り，エラーまたは結果と対になった別の実世界を返します．`IO` では，`pure` は世界を変更せずに返しますが，`bind` はアクションから次のアクションに変更された世界を渡します．

<!--
Because the entire universe doesn't fit in a computer's memory, the world being passed around is just a representation.
So long as world tokens are not re-used, the representation is safe.
This means that world tokens do not need to contain any data at all:
-->

全宇宙はコンピュータのメモリに収まらないため，アクション間で取りまわされる世界は単なる表現にすぎません．世界のトークンが再利用されない限り，表現は安全です．このことは，世界のトークンはデータを一切含む必要がないことを意味します：

```lean
{{#example_in Examples/Monads/IO.lean printRealWorld}}
```
```output info
{{#example_out Examples/Monads/IO.lean printRealWorld}}
```
