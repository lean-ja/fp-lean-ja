<!-- # Functors, Applicative Functors, and Monads -->

# 関手とアプリカティブ関手，そしてモナド

<!-- `Functor` and `Monad` both describe operations for types that are still waiting for a type argument.
One way to understand them is that `Functor` describes containers in which the contained data can be transformed, and `Monad` describes an encoding of programs with side effects.
This understanding is incomplete, however.
After all, `Option` has instances for both `Functor` and `Monad`, and simultaneously represents an optional value _and_ a computation that might fail to return a value. -->

`Functor` と `Monad` はどちらもさらに型引数を待ち受ける型の演算を記述します．このことを理解するにあたって，`Functor` は変換対象のデータを保持するコンテナを記述し，`Monad` は副作用のあるプログラムのエンコードを記述するものと考えるのも1つの手でしょう．しかし，この理解は不完全です．というのも， `Option` は `Functor` と `Monad` の両方のインスタンスを持ち，オプショナルな値と値の返却に失敗するかもしれない計算を **同時に** 表現するからです．

<!-- From the perspective of data structures, `Option` is a bit like a nullable type or like a list that can contain at most one entry.
From the perspective of control structures, `Option` represents a computation that might terminate early without a result.
Typically, programs that use the `Functor` instance are easiest to think of as using `Option` as a data structure, while programs that use the `Monad` instance are easiest to think of as using `Option` to allow early failure, but learning to use both of these perspectives fluently is an important part of becoming proficient at functional programming. -->

データ構造の観点から，`Option` はnullable型や高々1個の要素しか保持できないリストのようなものに少し似ています．制御構造の観点からは，`Option` は結果を伴わずに早期リターンするかもしれない計算を表現します．通常，`Functor` インスタンスを使うプログラムは `Option` の使い道をデータ構造としてみなす場合が最も簡単であり，一方で `Monad` インスタンスを使うプログラムも `Option` の使い道を早期の失敗を許可するものとみなす場合が最も簡単ですが，これらの観点両方を流暢に使えるようになることは関数型プログラミングの達人になるためには重要なポイントです．

<!-- There is a deeper relationship between functors and monads.
It turns out that _every monad is a functor_.
Another way to say this is that the monad abstraction is more powerful than the functor abstraction, because not every functor is a monad.
Furthermore, there is an additional intermediate abstraction, called _applicative functors_, that has enough power to write many interesting programs and yet permits libraries that cannot use the `Monad` interface.
The type class `Applicative` provides the overloadable operations of applicative functors.
Every monad is an applicative functor, and every applicative functor is a functor, but the converses do not hold. -->

関手とモナドの間には深い関係があります．実は **すべてのモナドは関手になります** ．言い換えると，すべての関手がモナドにはならないため，モナドの抽象化は関手の抽象化よりも強力であるということです．さらに，両者の間には **アプリカティブ関手** （applicative functor）と呼ばれる抽象化が存在します．これもまた多くの興味深いプログラムを書くにあたって十分な力を持ち，`Monad` のインタフェースを使えないライブラリでも使うことができます．型クラス `Applicative` はアプリカティブ関手のオーバーロードされた演算を提供します．すべてのモナドはアプリカティブ関手であり，またすべてのアプリカティブ関手は関手ですが，これらの逆は成り立ちません．
