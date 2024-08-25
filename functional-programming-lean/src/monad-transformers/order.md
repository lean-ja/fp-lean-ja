<!--
# Ordering Monad Transformers
-->

# モナド変換子の順序

<!--
When composing a monad from a stack of monad transformers, it's important to be aware that the order in which the monad transformers are layered matters.
Different orderings of the same set of transformers result in different monads.
-->

モナド変換子のスタックからモナドを構成する場合、モナド変換子を重ねる順番に注意が必要です。同じ変換子のあつまりでも異なる順番で並べると異なるモナドになります。

<!--
This version of `countLetters` is just like the previous version, except it uses type classes to describe the set of available effects instead of providing a concrete monad:
-->

以下の `countLetters` は前節のものとほぼ同じですが、具体的なモナドを提示する代わりに利用可能な作用の組を記述するために型クラスを使用する点が異なります：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLettersClassy}}
```
<!--
The state and exception monad transformers can be combined in two different orders, each resulting in a monad that has instances of both type classes:
-->

状態と例外についてのモナド変換子の組み合わせ方には2通りあり、それぞれ両方の型クラスのインスタンスを持つモナドになります：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean SomeMonads}}
```

<!--
When run on input for which the program does not throw an exception, both monads yield similar results:
-->

例外が発生しない入力に対してプログラムを実行した場合、どちらのモナドも似たような結果を出力します：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM1Ok}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM1Ok}}
```
```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM2Ok}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM2Ok}}
```
<!--
However, there is a subtle difference between these return values.
In the case of `M1`, the outermost constructor is `Except.ok`, and it contains a pair of the unit constructor with the final state.
In the case of `M2`, the outermost constructor is the pair, which contains `Except.ok` applied only to the unit constructor.
The final state is outside of `Except.ok`.
In both cases, the program returns the counts of vowels and consonants.
-->

しかし、これらの戻り値には微妙な違いがあります。`M1` の場合、外側のコンストラクタは `Except.ok` で、ユニットのコンストラクタと最終状態のペアを含んでいます。`M2` の場合、外側のコンストラクタはペアで、その中にはユニットのコンストラクタを適用した `Except.ok` が含まれています。最終状態は `Except.ok` の外側になっています。どちらの場合もプログラムは母音と子音の数を返します。

<!--
On the other hand, only one monad yields a count of vowels and consonants when the string causes an exception to be thrown.
Using `M1`, only an exception value is returned:
-->

一方、例外が出る文字列を入力にした場合、母音と子音のカウントを返すモナドは1つだけです。`M1` を使うと例外の値だけが返されます：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM1Error}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM1Error}}
```
<!--
Using `M2`, the exception value is paired with the state as it was at the time that the exception was thrown:
-->

`M2` を使うと、例外の値は例外が投げられた時の状態とのペアからなります：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM2Error}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM2Error}}
```

<!--
It might be tempting to think that `M2` is superior to `M1` because it provides more information that might be useful when debugging.
The same program might compute _different_ answers in `M1` than it does in `M2`, and there's no principled reason to say that one of these answers is necessarily better than the other.
This can be seen by adding a step to the program that handles exceptions:
-->

`M2` ではデバッグ時に役立つ情報が多く得られるため、`M2` の方が `M1` より優れていると考えたくなるかもしれません。しかし、同じプログラムでも `M1` と `M2` で **異なる** 計算結果を返すかもしれず、これらの答えのうちどちらか一方が他方より必ずしも優れているという原理的な理由はありません。これは上記のプログラムに例外を処理するステップを追加するとよくわかります：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countWithFallback}}
```
<!--
This program always succeeds, but it might succeed with different results.
If no exception is thrown, then the results are the same as `countLetters`:
-->

このプログラムは常に成功しますが、実際の入力に対して異なる結果で成功することもあります。例外が投げられなければ出力は `countLetters` と同じです：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM1Ok}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM1Ok}}
```
```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM2Ok}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM2Ok}}
```
<!--
However, if the exception is thrown and caught, then the final states are very different.
With `M1`, the final state contains only the letter counts from `"Fallback"`:
-->

しかし、例外が投げられキャッチされた場合、最終結果は大きく異なります。`M1` の場合、最終状態には `"Fallback"` の文字数だけが含まれます：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM1Error}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM1Error}}
```
<!--
With `M2`, the final state contains letter counts from both `"hello"` and from `"Fallback"`, as one would expect in an imperative language:
-->

`M2` での最終状態には `"hello"` と `"Fallback"` の両方の文字数が含まれます。これは命令型言語で見られるような挙動です：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM2Error}}
```
```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM2Error}}
```

<!--
In `M1`, throwing an exception "rolls back" the state to where the exception was caught.
In `M2`, modifications to the state persist across the throwing and catching of exceptions.
This difference can be seen by unfolding the definitions of `M1` and `M2`.
`{{#example_in Examples/MonadTransformers/Defs.lean M1eval}}` unfolds to `{{#example_out Examples/MonadTransformers/Defs.lean M1eval}}`, and `{{#example_in Examples/MonadTransformers/Defs.lean M2eval}}` unfolds to `{{#example_out Examples/MonadTransformers/Defs.lean M2eval}}`.
That is to say, `M1 α` describes functions that take an initial letter count, returning either an error or an `α` paired with updated counts.
When an exception is thrown in `M1`, there is no final state.
`M2 α` describes functions that take an initial letter count and return a new letter count paired with either an error or an `α`.
When an exception is thrown in `M2`, it is accompanied by a state.
-->

`M1` では、例外を投げると例外がキャッチされた時点まで状態を「ロールバック」します。`M2` では、例外のスローとキャッチにまたがって状態の変更が持続します。この違いは `M1` と `M2` の定義を展開することでわかります。`{{#example_in Examples/MonadTransformers/Defs.lean M1eval}}` は展開すると `{{#example_out Examples/MonadTransformers/Defs.lean M1eval}}` となり、`{{#example_in Examples/MonadTransformers/Defs.lean M2eval}}` は展開すると `{{#example_out Examples/MonadTransformers/Defs.lean M2eval}}` となります。これはつまり、`M1 α` は文字数の初期値を受け取り、エラーか「 `α` と更新された文字数」のペアを返す関数を記述しています。`M1` で例外が投げられると、最終的な状態は無くなります。`M2 α` は文字数の初期値を受け取り、更新された文字数とエラーか `α` のペアを返す関数を記述しています。`M2` での例外送出には状態が伴います。

<!--
## Commuting Monads
-->

## 可換なモナド

<!--
In the jargon of functional programming, two monad transformers are said to _commute_ if they can be re-ordered without the meaning of the program changing.
The fact that the result of the program can differ when `StateT` and `ExceptT` are reordered means that state and exceptions do not commute.
In general, monad transformers should not be expected to commute.
-->

関数型プログラミングの専門用語では、2つのモナド変換子がプログラムの意味を変えることなく並べ替えられる場合 **可換** （commute）と呼ばれます。`StateT` と `ExceptT` を並べ替えたときにプログラムの結果が異なる可能性があるということは、状態と例外が可換ではないということを意味します。一般的に、モナド変換子が可換であることを期待するべきではありません。

<!--
Even though not all monad transformers commute, some do.
For example, two uses of `StateT` can be re-ordered.
Expanding the definitions in `{{#example_in Examples/MonadTransformers/Defs.lean StateTDoubleA}}` yields the type `{{#example_out Examples/MonadTransformers/Defs.lean StateTDoubleA}}`, and `{{#example_in Examples/MonadTransformers/Defs.lean StateTDoubleB}}` yields `{{#example_out Examples/MonadTransformers/Defs.lean StateTDoubleB}}`.
In other words, the differences between them are that they nest the `σ` and `σ'` types in different places in the return type, and they accept their arguments in a different order.
Any client code will still need to provide the same inputs, and it will still receive the same outputs.
-->

全てのモナド変換子が可換ではありませんが、可換であるものもあります。例えば、`StateT` を2つ使用した場合、これは並べ替えることができます。`{{#example_in Examples/MonadTransformers/Defs.lean StateTDoubleA}}` の定義を展開すると `{{#example_out Examples/MonadTransformers/Defs.lean StateTDoubleA}}` 型が得られ、`{{#example_in Examples/MonadTransformers/Defs.lean StateTDoubleB}}` からは `{{#example_out Examples/MonadTransformers/Defs.lean StateTDoubleB}}` が得られます。言い換えると、両者の違いは `σ` 型と `σ'` 型を戻り値内の異なる場所にてネストし、異なる順序で引数を受け取るということです。クライアントコードは同じ入力を提供する必要があり、同じ出力を受け取ることができます。

<!--
Most programming languages that have both mutable state and exceptions work like `M2`.
In those languages, state that _should_ be rolled back when an exception is thrown is difficult to express, and it usually needs to be simulated in a manner that looks much like the passing of explicit state values in `M1`.
Monad transformers grant the freedom to choose an interpretation of effect ordering that works for the problem at hand, with both choices being equally easy to program with.
However, they also require care to be taken in the choice of ordering of transformers.
With great expressive power comes the responsibility to check that what's being expressed is what is intended, and the type signature of `countWithFallback` is probably more polymorphic than it should be.
-->

可変状態と例外を持つプログラミング言語のうちほとんどは `M2` のように動作します。そのような言語では例外が投げられたときに状態をロールバック **しなければならない** ように記述するのは難しく、通常は `M1` の明示的な状態値の受け渡しによく似た方法でシミュレーションする必要があります。モナド変換子は手元の問題に対して作用の順序の解釈を選択する自由を与え、そして両者の選択は同じくらい容易にプログラム可能です。しかし、変換子の順序の選択には注意が必要です。この素晴らしい表現力を使うには表現されているものが意図通りかをチェックする責任が伴い、`countWithFallback` の型シグネチャはおそらく必要以上に多相的になります。

<!--
## Exercises
-->

## 演習問題

 <!--
 * Check that `ReaderT` and `StateT` commute by expanding their definitions and reasoning about the resulting types.
 * Do `ReaderT` and `ExceptT` commute? Check your answer by expanding their definitions and reasoning about the resulting types.
 * Construct a monad transformer `ManyT` based on the definition of `Many`, with a suitable `Alternative` instance. Check that it satisfies the `Monad` contract.
 * Does `ManyT` commute with `StateT`? If so, check your answer by expanding definitions and reasoning about the resulting types. If not, write a program in `ManyT (StateT σ Id)` and a program in `StateT σ (ManyT Id)`. Each program should be one that makes more sense for the given ordering of monad transformers.
-->
 * `ReaderT` と `StateT` の定義を展開し、その結果の型を推論して `ReaderT` と `StateT` が可換であることを確認してください。
 * `ReaderT` と `ExceptT` は可換になるでしょうか？定義を展開し、結果の型を推論して答えを確認してください。
 * モナド変換子 `ManyT` を`Many` の定義と適切な `Alternative` インスタンスに基づいて構築してください。そしてそれが `Monad` の約定を満たすことを確認してください。
 * `ManyT` は　`StateT` と可換になるでしょうか？もしそうなら、定義を展開し、結果の型を推論して答えを確認してください。もしそうでないなら、`ManyT (StateT σ Id)` と `StateT σ (ManyT Id)` のプログラムを書いてください。それぞれのプログラムはモナド変換子の順序に対してより理にかなったものにしてください。
