<!--
# Programming with Dependent Types
-->

# 依存型によるプログラミング

<!--
In most statically-typed programming languages, there is a hermetic seal between the world of types and the world of programs.
Types and programs have different grammars and they are used at different times.
Types are typically used at compile time, to check that a program obeys certain invariants.
Programs are used at run time, to actually perform computations.
When the two interact, it is usually in the form of a type-case operator like an "instance-of" check or a casting operator that provides the type checker with information that was otherwise unavailable, to be verified at run time.
In other words, the interaction consists of types being inserted into the world of programs, gaining some limited run-time meaning.
-->

ほとんどの静的型付けプログラミングでは、型の世界とプログラミングの世界の間にはハーメチックシール（訳注：気密防水のためのシールのこと）が貼られています。型とプログラミングでは異なる文法が用いられ、異なるタイミングで使用されます。型は通常、コンパイル時に用いられ、プログラムが特定の不変量にしたがうかどうかをチェックします。プログラムは実行時に用いられ、実際に計算を実行します。この2つを相互に作用させる場合、通常は `instance-of` チェックのような型ケース演算子や、キャスティング演算子などを用いる形で行われます。これらは実行時に検証するために型チェッカに他の方法で得られなかった情報を提供してくれます。言い換えれば、この相互作用は型がプログラムの世界に挿入され、実行時に限定された意味を持つようになるということです。

<!--
Lean does not impose this strict separation.
In Lean, programs may compute types and types may contain programs.
Placing programs in types allows their full computation power to be used at compile time, and the ability to return types from functions makes types into first-class participants in the programming process.
-->

Leanにおいて、このような厳格な分離は行いません。Leanではプログラムは型を計算し、型はプログラムを含むことができます。プログラムを型の中に置くことで、コンパイル時にその計算能力をフルに使うことができ、関数から型を返す機能により型はプログラミングのプロセスにおいて第一級の参加者となります。

<!--
_Dependent types_ are types that contain non-type expressions.
A common source of dependent types is a named argument to a function.
For example, the function `natOrStringThree` returns either a natural number or a string, depending on which `Bool` it is passed:
-->

**依存型** （dependent type）とは型以外の式を含む型のことです。依存型は関数に与えられる名前付きの引数においてよく見られます。例えば、関数 `natOrStringThree` は渡された `Bool` によって自然数か文字列のどちらかを返します：

```lean
{{#example_decl Examples/DependentTypes.lean natOrStringThree}}
```

<!--
Further examples of dependent types include:
-->

依存型について他にも以下のような例がありました：

 <!--
 * [The introductory section on polymorphism](getting-to-know/polymorphism.md) contains `posOrNegThree`, in which the function's return type depends on the value of the argument.
 * [The `OfNat` type class](type-classes/pos.md#literal-numbers) depends on the specific natural number literal being used.
 * [The `CheckedInput` structure](functor-applicative-monad/applicative.md#validated-input) used in the example of validators depends on the year in which validation occurred.
 * [Subtypes](functor-applicative-monad/applicative.md#subtypes) contain propositions that refer to particular values.
 * Essentially all interesting propositions, including those that determine the validity of [array indexing notation](props-proofs-indexing.md), are types that contain values and are thus dependent types.
 -->
 * [多相性について導入した節](getting-to-know/polymorphism.md) で定義した `posOrNegThree` はその引数の値に戻り値の型が依存します。
 * [`OfNat` 型クラス](type-classes/pos.md#literal-numbers) はインスタンス化の際に使われた特定の数値リテラルに依存します。
 * バリデータの例にて用いられた [`CheckedInput` 構造体](functor-applicative-monad/applicative.md#validated-input) はバリデーション時に渡される年の値に依存します。
 * [部分型](functor-applicative-monad/applicative.md#subtypes) は特定の値を参照する命題を含みます。
 * [配列の添え字表記](props-proofs-indexing.md) の妥当性決定を含め、本質的に興味深い名地あはすべて値を含む型であり、したがって依存型です。

<!--
Dependent types vastly increase the power of a type system.
The flexibility of return types that branch on argument values enables programs to be written that cannot easily be given types in other type systems.
At the same time, dependent types allow a type signature to restrict which values may be returned from a function, enabling strong invariants to be enforced at compile time.
-->

依存型は型システムの能力を飛躍的に向上させます。引数の値によって戻り値の型を分岐させられる柔軟性により、ほかのシステムでは簡単に与えられないようなプログラムを書くことができます。同時に、依存型は型シグネチャによって関数から返される値を制限することを可能にし、コンパイル時に強力な不変性を強制することを可能にします。

<!--
However, programming with dependent types can be quite complex, and it requires a whole set of skills above and beyond functional programming.
Expressive specifications can be complicated to fulfill, and there is a real risk of tying oneself in knots and being unable to complete the program.
On the other hand, this process can lead to new understanding, which can be expressed in a refined type that can be fulfilled.
While this chapter scratches the surface of dependently typed programming, it is a deep topic that deserves an entire book of its own.
-->

しかし、依存型を使ったプログラミングは非常に複雑であり、関数型プログラミング以上のスキルを必要とします。表現力豊かな仕様を満たすことは複雑であり、それにとらわれすぎてプログラムを完成させることができなくなる危険性があります。その一方で、このプロセスによって新たな理解につながることもあり、それは洗練された型として表現することができます。この章は依存型プログラミングの表層を掬うだけにとどまりますが、このトピックは実に奥が深く、それだけで1冊の本を出版するに値するものです。
