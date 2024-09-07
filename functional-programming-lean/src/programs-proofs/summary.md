<!--
# Summary
-->

# まとめ

<!--
## Tail Recursion
-->

## 末尾再帰

<!--
Tail recursion is recursion in which the results of recursive calls are returned immediately, rather than being used in some other way.
These recursive calls are called _tail calls_.
Tail calls are interesting because they can be compiled to a jump instruction rather than a call instruction, and the current stack frame can be re-used instead of pushing a new frame.
In other words, tail-recursive functions are actually loops.
-->

末尾再帰とは再帰の一種で、再帰呼び出しの結果を他の何かで使用するのではなく、即座にそれを返すものを指します。このような再帰呼び出しは **末尾呼び出し** と呼ばれます。末尾呼び出しはCALL命令ではなくJUMP命令にコンパイルでき、新しいフレームをプッシュする代わりに現在のスタックフレームを再利用できるという興味深い存在です。言い換えれば、末尾再帰関数は実際にはループなのです。

<!--
A common way to make a recursive function faster is to rewrite it in accumulator-passing style.
Instead of using the call stack to remember what is to be done with the result of a recursive call, an additional argument called an _accumulator_ is used to collect this information.
For example, an accumulator for a tail-recursive function that reverses a list contains the already-seen list entries, in reverse order.
-->

再帰関数を高速化する一般的な方法はアキュムレータを渡すスタイルに書き換えることです。呼び出しスタックを使って再帰呼び出しの結果を記憶する代わりに、**アキュムレータ** と呼ばれる追加の引数を使用して情報を収集します。例えば、リストを反転させる末尾再帰関数のアキュムレータには、再帰中にすでに見てきたリストの要素が逆順で格納されます。

<!--
In Lean, only self-tail-calls are optimized into loops.
In other words, two functions that each end with a tail call to the other will not be optimized.
-->

Leanではループに最適化されるのは自分自身の末尾呼び出しだけです。言い換えると、2つの関数の最後がそれぞれもう一方の関数への末尾呼び出しで終わっている場合は最適化されません。

<!--
## Reference Counting and In-Place Updates
-->

## 参照カウントとin-placeな更新

<!--
Rather than using a tracing garbage collector, as is done in Java, C#, and most JavaScript implementations, Lean uses reference counting for memory management.
This means that each value in memory contains a field that tracks how many other values refer to it, and the run-time system maintains these counts as references appear or disappear.
Reference counting is also used in Python, PHP, and Swift.
-->

Java・C#・JavaScriptなどのほとんどの実装で行われているようなガベージコレクションの追跡を使用するのではなく、Leanではメモリ管理に参照カウントを使用します。つまり、メモリ上の各値はその値を参照している他の値がいくつあるかを追跡するフィールドを含んでおり、ランタイムシステムは参照が現れたり消えたりするたびにこれらのカウントを管理します。参照カウントはPython・PHP・Swiftでも使われています。

<!--
When asked to allocate a fresh object, Lean's run-time system is able to recycle existing objects whose reference counts are falling to zero.
Additionally, array operations such as `Array.set` and `Array.swap` will mutate an array if its reference count is one, rather than allocating a modified copy.
If `Array.swap` holds the only reference to an array, then no other part of the program can tell that it was mutated rather than copied.
-->

新しいオブジェクトを割り当てるよう要求されると、Leanのランタイムシステムは参照カウントが0になってしまった既存のオブジェクトを再利用することができます。さらに、`Array.set` や `Array.swap` などの配列操作は参照カウントが1であれば、変更されたコピーを割り当てるのではなく、配列を更新します。もし `Array.swap` が配列への唯一の参照を保持している場合プログラムの他の部分からは、その配列がコピーされずに変更されたことを認識できません。

<!--
Writing efficient code in Lean requires the use of tail recursion and being careful to ensure that large arrays are used uniquely.
While tail calls can be identified by inspecting the function's definition, understanding whether a value is referred to uniquely may require reading the whole program.
The debugging helper `dbgTraceIfShared` can be used at key locations in the program to check that a value is not shared.
-->

Leanにおいて効率的なコードを書くには末尾再帰を利用し、大きな配列が一意に使用されるように注意を払う必要があります。末尾呼び出しは関数の定義を調べることで識別できますが、値が一意に参照されているかどうかを理解するには、プログラム全体を読む必要がある可能性があります。デバッグ用の補助関数 `dbgTraceIfShared` をプログラムの重要な場所で使用すると、値が共有されていないことを確認できます。

<!--
## Proving Programs Correct
-->

## プログラムの正しさの証明

<!--
Rewriting a program in accumulator-passing style, or making other transformations that make it run faster, can also make it more difficult to understand.
It can be useful to keep the original version of the program that is more clearly correct, and then use it as an executable specification for the optimized version.
While techniques such as unit testing work just as well in Lean as in any other language, Lean also enables the use of mathematical proofs that completely ensure that both versions of the function return the same result for _all possible_ inputs.
-->

プログラムをアキュムレータを渡すスタイルに書き換えたり、より高速に実行できるように他の変換を加えたりすると理解しづらい実装になることもあります。こうした実装よりも正しさがより明確なオリジナルバージョンのプログラムを保持し、最適化バージョンの実行可能な仕様として使用することは有用です。単体テストのようなテクニックはLeanでも他の言語と同様に機能しますが、Leanでは関数の両方のバージョンが **可能な限りすべての** 入力に対して同じ結果を返すことを完全に保証する数学的証明を使用することもできます。

<!--
Typically, proving that two functions are equal is done using function extensionality (the `funext` tactic), which is the principle that two functions are equal if they return the same values for every input.
If the functions are recursive, then induction is usually a good way to prove that their outputs are the same.
Usually, the recursive definition of the function will make recursive calls on one particular argument; this argument is a good choice for induction.
In some cases, the induction hypothesis is not strong enough.
Fixing this problem usually requires thought about how to construct a more general version of the theorem statement that provides induction hypotheses that are strong enough.
In particular, to prove that a function is equivalent to an accumulator-passing version, a theorem statement that relates arbitrary initial accumulator values to the final result of the original function is needed.
-->

通常、2つの関数が等しいことを証明するためには、関数の外延性（`funext` タクティク）を用います。これは2つの関数がすべての入力に対して同じ値を返すなら等しいという原則です。もし関数が再帰的であれば、その出力が同じであることの証明には帰納法を用いることが大抵良いでしょう。通常、関数の再帰的定義はある特定の引数に対して再帰的な呼び出しを行います；このような引数が帰納法の格好の対象になります。場合によっては帰納法の仮定が十分に強くないこともあります。この問題を解決するには通常、十分に強い帰納法の仮定を提供する定理文に対してより一般的なバージョンを構築する方法を考える必要があります。特に、ある関数がアキュムレータを渡すバージョンと等価であることを証明するには、任意の初期アキュムレータ値と元の関数の最終結果と関連していることを示す定理文が必要です。

<!--
## Safe Array Indices
-->

## 安全な配列のインデックス

<!--
The type `Fin n` represents natural numbers that are strictly less than `n`.
`Fin` is short for "finite".
As with subtypes, a `Fin n` is a structure that contains a `Nat` and a proof that this `Nat` is less than `n`.
There are no values of type `Fin 0`.
-->

型 `Fin n` は `n` 未満の自然数を表します。`Fin` は「有限（finite）」の略です。部分型と同様に、`Fin n` はある `Nat` とその `Nat` が `n` 未満であるという証明を含む構造体です。`Fin 0` 型の値は存在しません。

<!--
If `arr` is an `Array α`, then `Fin arr.size` always contains a number that is a suitable index into `arr`.
Many of the built-in array operators, such as `Array.swap`, take `Fin` values as arguments rather than separated proof objects.
-->

もし `arr` が `Array α` であれば、`Fin arr.size` は常に `arr` への適切なインデックスとなる数値を含みます。`Array.swap` などの組み込みの配列演算子の多くは、個別の証明オブジェクトではなく、`Fin` の値を引数に取ります。

<!--
Lean provides instances of most of the useful numeric type classes for `Fin`.
The `OfNat` instances for `Fin` perform modular arithmetic rather than failing at compile time if the number provided is larger than the `Fin` can accept.
-->

Leanは `Fin` 用の便利な数値型クラスのインスタンスを提供しています。`Fin` 用の `OfNat` インスタンスは、提供された数値が `Fin` が受け付ける数値よりも大きい場合にコンパイル時に失敗するのではなく、剰余演算を実行します。

<!--
## Provisional Proofs
-->

## 暫定的な証明

<!--
Sometimes, it can be useful to pretend that a statement is proved without actually doing the work of proving it.
This can be useful when making sure that a proof of a statement would be suitable for some task, such as a rewrite in another proof, determining that an array access is safe, or showing that a recursive call is made on a smaller value than the original argument.
It's very frustrating to spend time proving something, only to discover that some other proof would have been more useful.
-->

ある文を実際に証明する作業を行わずに、証明されたフリをすることが役に立つことがあります。これはある文の証明が、他の証明の書き換えや、配列アクセスが安全であることの判断、再帰呼び出しが元の引数よりも小さな値で行われることの証明など、何らかのタスクに適していることを確認する時に便利です。ある文を証明するのに時間を費やした結果、他の証明の方がより有用であったことがということだけが判明するのは非常にフラストレーションがたまるものです。

<!--
The `sorry` tactic causes Lean to provisionally accept a statement as if it were a real proof.
It can be seen as analogous to a stub method that throws a `NotImplementedException` in C#.
Any proof that relies on `sorry` includes a warning in Lean.
-->

`sorry` タクティクはある文をLeanにあたかも本当の証明であるかのように暫定的に承認させます。これはC#で `NotImplementedException` を投げるスタブメソッドに似ています。`sorry` に依存する証明はLeanからの警告を含みます。

<!--
Be careful!
The `sorry` tactic can prove _any_ statement, even false statements.
Proving that `3 < 2` can cause an out-of-bounds array access to persist to runtime, unexpectedly crashing a program.
Using `sorry` is convenient during development, but keeping it in the code is dangerous.
-->

気を付けましょう！`sorry` タクティクはたとえ偽の文であっても、**どんな** 文でも証明することができてしまいます。`3 < 2` を証明すると、範囲外の配列アクセスが実行時まで持続し、予期せずプログラムがクラッシュすることがありえます。開発中に `sorry` を使うのは便利ですが、コードに残しておくのは危険です。

<!--
## Proving Termination
-->

## 停止性の証明

<!--
When a recursive function does not use structural recursion, Lean cannot automatically determine that it terminates.
In these situations, the function could just be marked `partial`.
However, it is also possible to provide a proof that the function terminates.
-->

再帰関数が構造的再帰を使用していない場合、Leanは自動的にその関数の終了を判断することができません。このような状況において、関数に単に `partial` とマークすることも可能ではあります。しかし、関数が終了することを証明することもできます。

<!--
Partial functions have a key downside: they can't be unfolded during type checking or in proofs.
This means that Lean's value as an interactive theorem prover can't be applied to them.
Additionally, showing that a function that is expected to terminate actually always does terminate removes one more potential source of bugs.
-->

部分関数には重要な欠点があります：それは型検査中や証明中で展開できないことです。これはLeanの対話的定理証明器としての価値が適用できないことを意味します。さらに、停止することが期待される関数が実際には常に停止することを示すことでバグの潜在的な原因を1つ取り除くことができます。

<!--
The `termination_by` clause that's allowed at the end of a function can be used to specify the reason why a recursive function terminates.
The clause maps the function's arguments to an expression that is expected to be smaller for each recursive call.
Some examples of expressions that might decrease are the difference between a growing index into an array and the array's size, the length of a list that's cut in half at each recursive call, or a pair of lists, exactly one of which shrinks on each recursive call.
-->

関数の最後に指定できる `termination_by` 節は再帰関数が停止する理由を指定するために使うことができます。この節は、関数の引数を再帰的に呼び出されるたびに小さくなることが予想される式にマップします。小さくなる可能性のある式の例としては、配列のインデックスと配列のサイズの差、再帰呼び出しのたびに半分になるリストの長さ、再帰呼び出しのたびに片方が小さくなるリストのペアなどがあります。

<!--
Lean contains proof automation that can automatically determine that some expressions shrink with each call, but many interesting programs will require manual proofs.
These proofs can be provided with `have`, a version of `let` that's intended for locally providing proofs rather than values.
-->

Leanには証明の自動化機能があり、場合によっては呼び出しごとに式が縮小することを自動的に判断することができますが、多くの興味深いプログラムでは手作業の証明が必要になります。これらの証明は `have` を使って提供することができます。これは `let` の亜種で、値ではなく証明をローカルに提供することを目的としています。

<!--
A good way to write recursive functions is to begin by declaring them `partial` and debugging them with testing until they return the right answers.
Then, `partial` can be removed and replaced with a `termination_by` clause.
Lean will place error highlights on each recursive call for which a proof is needed that contains the statement that needs to be proved.
Each of these statements can be placed in a `have`, with the proof being `sorry`.
If Lean accepts the program and it still passes its tests, the final step is to actually prove the theorems that enable Lean to accept it.
This approach can prevent wasting time on proving that a buggy program terminates.
-->

再帰関数を書く良い方法は、まず `partial` と宣言し、正しい答えを返すまでテストしながらデバッグすることです。次に、`partial` を削除して `termination_by` 節に置き換えます。Leanは証明が必要な各再帰呼び出しに証明が必要な文を含むエラーをハイライトします。これらの文はそれぞれ証明の中身を `sorry` にした `have` に設定することができます。Leanがプログラムを受け入れテストに合格したら、最後のステップはLeanがプログラムを受け入れるための定義を実際に証明するこです。このアプローチで、バグのあるプログラムに対して停止することの証明に時間を浪費してしまうことを防ぐことができます。
