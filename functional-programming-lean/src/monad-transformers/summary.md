<!--
# Summary
-->

# まとめ

<!--
## Combining Monads
-->

## モナドを組み合わせる

<!--
When writing a monad from scratch, there are design patterns that tend to describe the ways that each effect is added to the monad.
Reader effects are added by having the monad's type be a function from the reader's environment, state effects are added by including a function from the initial state to the value paired with the final state, failure or exceptions are added by including a sum type in the return type, and logging or other output is added by including a product type in the return type.
Existing monads can be made part of the return type as well, allowing their effects to be included in the new monad.
-->

モナドをイチから書く場合、デザインパターンとしてはモナドに各作用を追加する方法を記述しがちです。リーダ作用はモナドの型をリーダの環境からの関数にすること、状態作用は初期状態から最終状態と計算結果のペアへの関数を含めること、失敗や例外は戻り値の型に直和型を含めること、ロギングやその他の出力は戻り値の型に直積型を含めることで、それぞれの作用が追加されます。既存のモナドも同様に戻り値の型の一部にすることができ、それによってその作用を新しいモナドに含めることができます。

<!--
These design patterns are made into a library of reusable software components by defining _monad transformers_, which add an effect to some base monad.
Monad transformers take the simpler monad types as arguments, returning the enhanced monad types.
At a minimum, a monad transformer should provide the following instances:
-->

こうしたデザインパターンはベースのモナドに作用を追加する **モナド変換子** を定義することで再利用可能なソフトウェアコンポーネントによるライブラリとなります。モナド変換子はより単純なモナド型を引数として取り、拡張されたモナド型を返します。モナド変換子は最低でも以下のインスタンスを提供しなければなりません：

 <!--
 1. A `Monad` instance that assumes the inner type is already a monad
 -->
 1. 内側の型がすでにモナドであると仮定する `Monad` インスタンス
 <!--
 2. A `MonadLift` instance to translate an action from the inner monad to the transformed monad
 -->
 2. 内側のモナドから変換後のモナドにアクションを変換する `MonadLift` インスタンス
 
<!--
Monad transformers may be implemented as polymorphic structures or inductive datatypes, but they are most often implemented as functions from the underlying monad type to the enhanced monad type.
-->

モナド変換子は多相構造体や帰納的データ型として実装されることもありますが、ベースのモナド型から拡張されたモナド型への関数として実装されることが最も多いです。

<!--
## Type Classes for Effects
-->

## 作用ごとの型クラス

<!--
A common design pattern is to implement a particular effect by defining a monad that has the effect, a monad transformer that adds it to another monad, and a type class that provides a generic interface to the effect.
This allows programs to be written that merely specify which effects they need, so the caller can provide any monad that has the right effects.
-->

モナド変換子のデザインパターンは共通して、作用を持つモナドとその作用を別のモナドに追加するモナド変換子、作用へのジェネリックなインタフェースを提供する型クラスを定義して、特定の作用を実装します。これにより、必要な作用を指定するだけのプログラムを書くことができ、呼び出し側は適切な作用を持つ任意のモナドを提供することができます。

<!--
Sometimes, auxiliary type information (e.g. the state's type in a monad that provides state, or the exception's type in a monad that provides exceptions) is an output parameter, and sometimes it is not.
The output parameter is most useful for simple programs that use each kind of effect only once, but it risks having the type checker commit to a the wrong type too early when multiple instances of the same effect are used in a given program.
Thus, both versions are typically provided, with the ordinary-parameter version of the type class having a name that ends in `-Of`.
-->


ある時は補助的な型情報（例えば、状態を提供するモナドにおける状態の型や、例外を提供するモナドにおける例外の型）が出力パラメータになることもありますが、ならない時もあります。出力パラメータはそれぞれの種類の作用を一度だけ使用するシンプルなプログラムにおいて最も有用ですが、同じ作用の複数のインスタンスが特定のプログラムで使用される場合、型チェッカが間違った型にせっかちにコミットしてしまう危険性があります。そのため、通常は両方のバージョンが提供されており、通常のパラメータのバージョンの型クラスは `-Of` で終わる名前を持ちます。

<!--
## Monad Transformers Don't Commute
-->

## モナド変換子は可換ではない

<!--
It is important to note that changing the order of transformers in a monad can change the meaning of programs that use the monad.
For instance, re-ordering `StateT` and `ExceptT` can result either in programs that lose state modifications when exceptions are thrown or programs that keep changes.
While most imperative languages provide only the latter, the increased flexibility provided by monad transformers demands thought and attention to choose the correct variety for the task at hand.
-->

モナド内の変換子の順序を変えると、モナドを使用するプログラムの意味が変わってしまうことに注意することが重要です。例えば、`StateT` と `ExceptT` の順序を変更すると、例外が投げられた時に状態の変更が失われるプログラムか、変更が維持されるプログラムかのどちらかになります。ほとんどの命令型言語では後者しか提供しませんが、モナド変換子によって柔軟性が増すため、目の前のタスクに適した種類を選択するための思考と注意が必要になります。

<!--
## `do`-Notation for Monad Transformers
-->

## モナド変換子のための `do` 記法

<!--
Lean's `do`-blocks support early return, in which the block is terminated with some value, locally mutable variables, `for`-loops with `break` and `continue`, and single-branched `if`-statements.
While this may seem to be introducing imperative features that would get in the way of using Lean to write proofs, it is in fact nothing more than a more convenient syntax for certain common uses of monad transformers.
Behind the scenes, whatever monad the `do`-block is written in is transformed by appropriate uses of `ExceptT` and `StateT` to support these additional effects.
-->

Leanの `do` ブロックは、ブロックで何かしらの値で終了する早期リターン、局所的な可変変数、`break` と `continue` を使った `for` ループ、単一分岐の `if` 文をサポートしています。これはLeanを使って証明を書く際には邪魔になるような命令的な機能を導入しているように見えるかもしれませんが、実際にはただモナド変換子のある一般的な使用法に対しての便利な構文に過ぎません。裏では、`do` ブロックがどのようなモナドで書かれていたとしても、これらの追加作用をサポートするために `ExceptT` と `StateT` の適切な使用によって変換されます。
