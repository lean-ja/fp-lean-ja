<!--
# Summary
-->

# まとめ

<!--
## Encoding Side Effects
-->

## 副作用のエンコード

<!--
Lean is a pure functional language.
This means that it does not include side effects such as mutable variables, logging, or exceptions.
However, most side effects can be _encoded_ using a combination of functions and inductive types or structures.
For example, mutable state can be encoded as a function from an initial state to a pair of a final state and a result, and exceptions can be encoded as an inductive type with constructors for successful termination and errors.
-->

Leanは純粋関数型言語です。これは可変変数やロギング、例外等の副作用を言語として含んでいないことを意味します。しかし、ほとんどの副作用は関数と帰納型か構造体を組み合わせることで **エンコード** できます。例えば、可変状態は初期状態から最終状態と結果のペアへの関数としてエンコードされ、例外は正常終了と異常終了のそれぞれへのコンストラクタを持つ帰納型としてエンコードできます。

<!--
Each set of encoded effects is a type.
As a result, if a program uses these encoded effects, then this is apparent in its type.
Functional programming does not mean that programs can't use effects, it simply requires that they be *honest* about which effects they use.
A Lean type signature describes not only the types of arguments that a function expects and the type of result that it returns, but also which effects it may use.
-->

エンコードされた作用それぞれは型です。その結果、これらのエンコードされた作用を使うプログラムは、作用を使っていることが型に表れます。関数型プログラミングは作用が使えないことを意味せず、シンプルに使用する作用について **正直であること** が求められます。Leanの型シグネチャは関数が受け取る引数の型と関数の戻り値だけでなく、そこで使われる作用についても記述します。

<!--
## The Monad Type Class
-->

## モナド型クラス

<!--
It's possible to write purely functional programs in languages that allow effects anywhere.
For example, `2 + 3` is a valid Python program that has no effects at all.
Similarly, combining programs that have effects requires a way to state the order in which the effects must occur.
It matters whether an exception is thrown before or after modifying a variable, after all.
-->

作用をどこでも使えるような言語でも純粋で関数型のプログラムを書くことは可能です。例えば、`2 + 3` はPythonにおいて一切作用を持たないプログラムとして成立します。同様に、作用を持つプログラムの結合には作用がどの順番で行われるかを定める方法が求められます。つまり、変数を変更する前に例外が投げられるか、変更した後に例外が投げられるかが重要なのです。

<!--
The type class `Monad` captures these two important properties.
It has two methods: `pure` represents programs that have no effects, and `bind` sequences effectful programs.
The contract for `Monad` instances ensures that `bind` and `pure` actually capture pure computation and sequencing.
-->

`Monad` 型クラスはこれら2つの重要な性質を兼ね備えています。このクラスには2つのメソッドがあります：`pure` はプログラムが作用を持たないことを表し、`bind` は作用を含むプログラムを結合します。`Monad` インスタンスの約定は `bind` と `pure` が本当に純粋な計算と連結を体現することを保証します。

<!--
## `do`-Notation for Monads
-->

## モナドのための `do` 記法

<!--
Rather than being limited to `IO`, `do`-notation works for any monad.
It allows programs that use monads to be written in a style that is reminiscent of statement-oriented languages, with statements sequenced after one another.
Additionally, `do`-notation enables a number of additional convenient shorthands, such as nested actions.
A program written with `do` is translated to applications of `>>=` behind the scenes.
-->

`IO` に限ることなく、`do` 記法はどんなモナドでも使うことができます。これにより、プログラム中で文を順々に並べるというあたかも文指向（statement-oriented）言語を思わせるようなスタイルでモナドを使うことができます。さらに、`do` 記法はネストしたアクションなどの追加の便利な短縮記法を可能にします。`do` で書かれたプログラムはその裏で `>>=` の適用に翻訳されます。

<!--
## Custom Monads
-->

## モナドの自作

<!--
Different languages provide different sets of side effects.
While most languages feature mutable variables and file I/O, not all have features like exceptions.
Other languages offer effects that are rare or unique, like Icon's search-based program execution, Scheme and Ruby's continuations, and Common Lisp's resumable exceptions.
An advantage to encoding effects with monads is that programs are not limited to the set of effects that are provided by the language.
Because Lean is designed to make programming with any monad convenient, programmers are free to choose exactly the set of side effects that make sense for any given application.
-->

異なる言語では異なる副作用が提供されます。ほとんどの言語では可変変数とファイルのI/Oを兼ね備えている一方、例外を持たない言語も存在します。また一部の言語では珍しく独特な作用を用意しています。例えばIconの検索に基づくプログラムの実行やSchemeとRubyの継続、Common Lispの再開可能な例外などです。モナドで作用をエンコードすることには、言語から提供される作用だけに限定されなくなるというアドバンテージがあります。Leanはどんなモナドでも快適にプログラミングできるように設計されているため、プログラマは任意のアプリケーションにぴったりな副作用を自由に選ぶことができます。

<!--
## The `IO` Monad
-->

## `IO` モナド

<!--
Programs that can affect the real world are written as `IO` actions in Lean.
`IO` is one monad among many.
The `IO` monad encodes state and exceptions, with the state being used to keep track of the state of the world and the exceptions modeling failure and recovery.
-->

Leanでは、実世界に影響を及ぼすプログラムは `IO` アクションとして記述されます。`IO` は数多くあるモナドの中の1つです。`IO` モナドは状態と例外をエンコードしており、このうち状態は世界の状態を追跡するために、例外は失敗と回復をモデル化するためにそれぞれ用いられます。
