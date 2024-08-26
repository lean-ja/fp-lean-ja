<!--
# Tail Recursion
-->

# 末尾再帰

<!--
While Lean's `do`-notation makes it possible to use traditional loop syntax such as `for` and `while`, these constructs are translated behind the scenes to invocations of recursive functions.
In most programming languages, recursive functions have a key disadvantage with respect to loops: loops consume no space on the stack, while recursive functions consume stack space proportional to the number of recursive calls.
Stack space is typically limited, and it is often necessary to take algorithms that are naturally expressed as recursive functions and rewrite them as loops paired with an explicit mutable heap-allocated stack.
-->

Leanの `do` 記法によって `for` や `while` などの伝統的な繰り返し構文が使えるようになりますが、裏ではこれらの構文は再帰関数の呼び出しに変換されています。ほとんどのプログラミング言語では、ループに対して重要な欠点を持っています：ループはスタック上の領域を消費しませんが、再帰関数は再帰呼び出しの数に比例してスタック領域を消費します。スタック領域は一般的に限られているため、再帰関数として自然に表現されるアルゴリズムを、明示的に可変で割り当てられたヒープ領域でのループに書き直す必要がしばしばあります。

<!--
In functional programming, the opposite is typically true.
Programs that are naturally expressed as mutable loops may consume stack space, while rewriting them to recursive functions can cause them to run quickly.
This is due to a key aspect of functional programming languages: _tail-call elimination_.
A tail call is a call from one function to another that can be compiled to an ordinary jump, replacing the current stack frame rather than pushing a new one, and tail-call elimination is the process of implementing this transformation.
-->

関数型プログラミングではその逆が一般的です。可変状態を持つループとして自然に表現されるプログラムはスタック領域を消費するかもしれませんが、再帰関数に書き換えれば高速に実行できます。これは関数型プログラミング言語の重要な側面によるものです：すなわち **末尾呼び出しの除去** （tail-call elimination）です。末尾呼び出しとはある関数から別の関数への呼び出しの中でも、呼び出し時に新しいスタックフレームをプッシュするのではなく、現在のスタックフレームに置き換えることで通常のジャンプにコンパイルできるものを指します。

<!--
Tail-call elimination is not just merely an optional optimization.
Its presence is a fundamental part of being able to write efficient functional code.
For it to be useful, it must be reliable.
Programmers must be able to reliably identify tail calls, and they must be able to trust that the compiler will eliminate them.
-->

末尾呼び出しの除去は単なるオプショナルな最適化ではありません。その存在は効率的な関数型コードを書くための基礎的な部分です。この機能が有用であるためには、信頼できるものでなければなりません。プログラマは確実に末尾呼び出しを特定できなければならず、コンパイラによる末尾呼び出しの除去が信頼できなければなりません。

<!--
The function `NonTail.sum` adds the contents of a list of `Nat`s:
-->

関数 `NonTail.sum` は `Nat` のリストの内容を加算します：

```lean
{{#example_decl Examples/ProgramsProofs/TCO.lean NonTailSum}}
```
<!--
Applying this function to the list `[1, 2, 3]` results in the following sequence of evaluation steps:
-->

この関数をリスト `[1, 2, 3]` に適用すると、次のような評価のステップの流れになります：

```lean
{{#example_eval Examples/ProgramsProofs/TCO.lean NonTailSumOneTwoThree}}
```
<!--
In the evaluation steps, parentheses indicate recursive calls to `NonTail.sum`.
In other words, to add the three numbers, the program must first check that the list is non-empty.
To add the head of the list (`1`) to the sum of the tail of the list, it is first necessary to compute the sum of the tail of the list:
-->

この評価ステップにおいて、括弧は `NonTail.sum` の再帰呼び出しを示しています。言い換えると、3つの数値を足すには、このプログラムは最初にリストが空でないことをチェックしなければなりません。リストの先頭（`1`）とリストの後続の和を足すには、まずリストの後続の和を計算する必要があります：

```lean
{{#example_eval Examples/ProgramsProofs/TCO.lean NonTailSumOneTwoThree 1}}
```
<!--
But to compute the sum of the tail of the list, the program must check whether it is empty.
It is not - the tail is itself a list with `2` at its head.
The resulting step is waiting for the return of `NonTail.sum [3]`:
-->

しかし、リストの後続の和を計算するためには、プログラムはそれが空かどうかをチェックしなければなりません。そしてこれは空ではなく、後続のリストの先頭は `2` です。この結果のステップでは `NonTail.sum [3]` が変えることを待ちます：

```lean
{{#example_eval Examples/ProgramsProofs/TCO.lean NonTailSumOneTwoThree 2}}
```
<!--
The whole point of the run-time call stack is to keep track of the values `1`, `2`, and `3` along with the instruction to add them to the result of the recursive call.
As recursive calls are completed, control returns to the stack frame that made the call, so each step of addition is performed.
Storing the heads of the list and the instructions to add them is not free; it takes space proportional to the length of the list.
-->

実行時の呼び出しのスタックの要点は、値 `1` ・`2` ・`3` とそれらを再帰呼び出しの結果に加算する命令を追跡することです。再帰呼び出しが完了すると、制御が呼び出しを行ったスタックフレームに戻り、加算の各ステップが実行されます。リストの先頭とそれらの加算の命令を格納した領域は解放されません；これはリストの長さに比例した領域を占めます。

<!--
The function `Tail.sum` also adds the contents of a list of `Nat`s:
-->

関数 `Tail.sum` も `Nat` のリストの内容を加算します：

```lean
{{#example_decl Examples/ProgramsProofs/TCO.lean TailSum}}
```
<!--
Applying it to the list `[1, 2, 3]` results in the following sequence of evaluation steps:
-->

これをリスト `[1, 2, 3]` に適用すると、次のような評価の流れになります：

```lean
{{#example_eval Examples/ProgramsProofs/TCO.lean TailSumOneTwoThree}}
```
<!--
The internal helper function calls itself recursively, but it does so in a way where nothing needs to be remembered in order to compute the final result.
When `Tail.sumHelper` reaches its base case, control can be returned directly to `Tail.sum`, because the intermediate invocations of `Tail.sumHelper` simply return the results of their recursive calls unmodified.
In other words, a single stack frame can be re-used for each recursive invocation of `Tail.sumHelper`.
Tail-call elimination is exactly this re-use of the stack frame, and `Tail.sumHelper` is referred to as a _tail-recursive function_.
-->

内部の補助関数は自分自身を再帰的に呼び出しますが、最終的な結果を計算するために何も覚えておく必要はありません。`Tail.sumHelper` の中華に呼び出しは再帰呼び出しの結果をそのまま返すだけであるため、`Tail.sumHelper` が基本ケースに到達すると制御を直接 `Tail.sum` に戻すことができます。つまり、`Tail.sumHelper` を再帰的に呼び出すたびに1つのスタックフレームを再利用することができます。末尾呼び出しの除去とはまさにこのスタックフレームの再利用のことであり、`Tail.sumHelper` は **末尾再帰関数** と呼ばれます。

<!--
The first argument to `Tail.sumHelper` contains all of the information that would otherwise need to be tracked in the call stack—namely, the sum of the numbers encountered so far.
In each recursive call, this argument is updated with new information, rather than adding new information to the call stack.
Arguments like `soFar` that replace the information from the call stack are called _accumulators_.
-->

`Tail.sumHelper` の最初の引数にはコールスタックで追跡すべき情報がすべて含まれています。すなわち、遭遇してきた数値をすべて加算した値です。各再帰呼び出しでは、コールスタックに新しい情報を追加するのではなく、この引数が新しい情報で更新されます。コールスタックの情報を置き換える `soFar` のような引数は **アキュムレータ** （accumulator）と呼ばれます。

<!--
At the time of writing and on the author's computer, `NonTail.sum` crashes with a stack overflow when passed a list with 216,856 or more entries.
`Tail.sum`, on the other hand, can sum a list of 100,000,000 elements without a stack overflow.
Because no new stack frames need to be pushed while running `Tail.sum`, it is completely equivalent to a `while` loop with a mutable variable that holds the current list.
At each recursive call, the function argument on the stack is simply replaced with the next node of the list.
-->

この記事を書いている時点と筆者のコンピュータでは、216,856以上の要素を持つリストを渡すと、`NonTail.sum` はスタックオーバーフローでクラッシュします。一方で、`Tail.sum` は100,000,000個の要素を持つリストでもスタックオーバーフローを起こすことなく合計を計算することができます。`Tail.sum` の実行中に新しいスタックフレームをプッシュする必要がないため、現在のリストを保持する可変な変数を持つ `while` ループと完全に等価です。再帰呼び出しの度に、スタック上の関数の引数はリストの次のノードに置き換えられます。

<!--
## Tail and Non-Tail Positions
-->

## 末尾位置と非末尾位置

<!--
The reason why `Tail.sumHelper` is tail recursive is that the recursive call is in _tail position_.
Informally speaking, a function call is in tail position when the caller does not need to modify the returned value in any way, but will just return it directly.
More formally, tail position can be defined explicitly for expressions.
-->

`Tail.sumHelper` が末尾再帰である理由は、再帰呼び出しが **末尾の位置** にあるからです。非形式的には、関数呼び出しが末尾の位置にあるのは、呼び出し元が戻り値を変更する必要がなく、そのまま返す場合です。より形式的には、末尾位置は式に対して明示的に定義することができます。

<!--
If a `match`-expression is in tail position, then each of its branches is also in tail position.
Once a `match` has selected a branch, control proceeds immediately to it.
Similarly, both branches of an `if`-expression are in tail position if the `if`-expression itself is in tail position.
Finally, if a `let`-expression is in tail position, then its body is as well.
-->

もし `match` 式が末尾の位置であれば、その各ブランチも末尾の位置となります。一度 `match` がブランチを選択すると、制御はすぐにそのブランチに進みます。同様に、`if` 式が末尾にある場合、`if` 式の両方のブランチも末尾の位置となります。最後に、`let` 式が末尾にある場合は、その本体も末尾となります。

<!--
All other positions are not in tail position.
The arguments to a function or a constructor are not in tail position because evaluation must track the function or constructor that will be applied to the argument's value.
The body of an inner function is not in tail position because control may not even pass to it: function bodies are not evaluated until the function is called.
Similarly, the body of a function type is not in tail position.
To evaluate `E` in `(x : α) → E`, it is necessary to track that the resulting type must have `(x : α) → ...` wrapped around it.
-->

これ以外の他のすべての位置は末尾の位置とはなりません。関数やコンストラクタの引数は末尾の位置ではありません。なぜなら、評価は引数の値に適用される関数やコンストラクタを追跡しなければならないからです。内部関数の本体も末尾の位置ではありません。というのも制御が渡されないかもしれないからです：すなわち、関数の本体は関数が呼び出されるまで評価されないからです。同様に、関数型の本体も末尾の位置ではありません。`E` in `(x : α) → E` を評価するためには、結果として得られる型が `(x : α) → ...` で囲まれていることを追跡する必要があります。

<!--
In `NonTail.sum`, the recursive call is not in tail position because it is an argument to `+`.
In `Tail.sumHelper`, the recursive call is in tail position because it is immediately underneath a pattern match, which itself is the body of the function.
-->

`NonTail.sum` では、再帰呼び出しは `+` の引数であるため末尾の位置ではありません。`Tail.sumHelper` ではパターンマッチ（これ自体が関数の本体である）の直下であるため、この再帰呼び出しは末尾の位置です。

<!--
At the time of writing, Lean only eliminates direct tail calls in recursive functions.
This means that tail calls to `f` in `f`'s definition will be eliminated, but not tail calls to some other function `g`.
While it is certainly possible to eliminate a tail call to some other function, saving a stack frame, this is not yet implemented in Lean.
-->

この記事を書いている時点では、Leanは再帰関数内の直接の末尾呼び出しのみを除去します。つまり、ある関数 `f` の定義における `f` への末尾呼び出しは除去されますが、他の関数 `g` への末尾呼び出しは除去されません。スタックフレームを節約して他の関数への末尾呼び出しを除去することは可能ですが、Leanではまだ実装されていません。

<!--
## Reversing Lists
-->

## リストの反転

<!--
The function `NonTail.reverse` reverses lists by appending the head of each sub-list to the end of the result:
-->

関数 `NonTail.reverse` は各サブリストの先頭を結果の末尾に追加することでリストを反転させます：

```lean
{{#example_decl Examples/ProgramsProofs/TCO.lean NonTailReverse}}
```
<!--
Using it to reverse `[1, 2, 3]` yields the following sequence of steps:
-->

これを `[1, 2, 3]` に使用して反転させると、次のような評価の流れになります：

```lean
{{#example_eval Examples/ProgramsProofs/TCO.lean NonTailReverseSteps}}
```

<!--
The tail-recursive version uses `x :: ·` instead of `· ++ [x]` on the accumulator at each step:
-->

末尾再帰版では各ステップでのアキュムレータに対して `· ++ [x]` の代わりに `x :: ·` を用います：

```lean
{{#example_decl Examples/ProgramsProofs/TCO.lean TailReverse}}
```
<!--
This is because the context saved in each stack frame while computing with `NonTail.reverse` is applied beginning at the base case.
Each "remembered" piece of context is executed in last-in, first-out order.
On the other hand, the accumulator-passing version modifies the accumulator beginning from the first entry in the list, rather than the original base case, as can be seen in the series of reduction steps:
-->

これは `NonTail.reverse` で計算している間に各スタックフレームに保存されたコンテキストが基本ケースから適用されるためです。コンテキストの各「記憶された」断片は、後入れ先出しの順に実行されます。一方で、アキュムレータ渡し版では、以下の簡約ステップの流れからわかるように、元の基本ケースではなくリストの最初の要素からアキュムレータを更新します：

```lean
{{#example_eval Examples/ProgramsProofs/TCO.lean TailReverseSteps}}
```
<!--
In other words, the non-tail-recursive version starts at the base case, modifying the result of recursion from right to left through the list.
The entries in the list affect the accumulator in a first-in, first-out order.
The tail-recursive version with the accumulator starts at the head of the list, modifying an initial accumulator value from left to right through the list.
-->

つまり、非末尾再帰版は基本ケースから開始し、対象のリストを右から左に走査して再帰の結果を更新します。これらのリストの要素は先入先出の順序でアキュムレータに影響を与えます。アキュムレータを使用する末尾再帰版はリストの先頭から開始し、リストを左から右へ走査し、アキュムレータの初期値を更新します。

<!--
Because addition is commutative, nothing needed to be done to account for this in `Tail.sum`.
Appending lists is not commutative, so care must be taken to find an operation that has the same effect when run in the opposite direction.
Appending `[x]` after the result of the recursion in `NonTail.reverse` is analogous to adding `x` to the beginning of the list when the result is built in the opposite order.
-->

加算は可換であるため、`Tail.sum` ではこの点を考慮する必要はありません。リストの結合は可換ではないため、逆方向に実行しても同じ効果を持つ演算を見つけるように注意しなければなりません。`NonTail.reverse` の再帰の結果の後に `[x]` を追加することは、結果を逆の順序で構築する時にリストの先頭に `x` を追加することに似ています。

<!--
## Multiple Recursive Calls
-->

## 複数の再帰呼び出し

<!--
In the definition of `BinTree.mirror`, there are two recursive calls:
-->

`BinTree.mirror` の定義では、2つの再帰呼び出しがあります：

```lean
{{#example_decl Examples/Monads/Conveniences.lean mirrorNew}}
```
<!--
Just as imperative languages would typically use a while loop for functions like `reverse` and `sum`, they would typically use recursive functions for this kind of traversal.
This function cannot be straightforwardly rewritten to be tail recursive using accumulator-passing style.
-->

命令型言語が `reverse` や `sum` のような関数にwhileループを使うように、この種の走査には再帰関数を使うことが一般的です。この関数は安直にアキュムレータを渡すスタイルを使って末尾再帰的に書き換えることはできません。

<!--
Typically, if more than one recursive call is required for each recursive step, then it will be difficult to use accumulator-passing style.
This difficulty is similar to the difficulty of rewriting a recursive function to use a loop and an explicit data structure, with the added complication of convincing Lean that the function terminates.
However, as in `BinTree.mirror`, multiple recursive calls often indicate a data structure that has a constructor with multiple recursive occurrences of itself.
In these cases, the depth of the structure is often logarithmic with respect to its overall size, which makes the tradeoff between stack and heap less stark.
There are systematic techniques for making these functions tail-recursive, such as using _continuation-passing style_, but they are outside the scope of this chapter.
-->

通常、各再帰ステップに1回より多い再帰呼び出しが必要な場合、アキュムレータを渡すスタイルを使用することは難しいです。この難しさは、再帰関数をループと明示的なデータ構造を使用するように書き換える難しさと似ており、さらに関数が終了することをLeanに納得させる複雑さも備わっています。しかし、`BinTree.mirror` のように複数の再帰呼び出しは、それ自体が複数回再帰的に出現するコンストラクタを持つデータ構造を示すことが多いです。このような場合、構造体の深さは全体のサイズに対して対数になることが多く、スタックとヒープのトレードオフが小さくなります。これらの関数を末尾再帰にするための体系的なテクニックとして **継続渡しスタイル** （continuation-passing style）を使用するなどの方法がありますが、この章の範囲外です。

<!--
## Exercises
-->

## 演習問題

<!--
Translate each of the following non-tail-recursive functions into accumulator-passing tail-recursive functions:
-->

以下の非末尾再帰関数をそれぞれアキュムレータを渡すスタイルの末尾再帰関数に変換してください：

```lean
{{#example_decl Examples/ProgramsProofs/TCO.lean NonTailLength}} 
```

```lean
{{#example_decl Examples/ProgramsProofs/TCO.lean NonTailFact}}
```

<!--
The translation of `NonTail.filter` should result in a program that takes constant stack space through tail recursion, and time linear in the length of the input list.
A constant factor overhead is acceptable relative to the original:
-->

`NonTail.filter` の変換では、末尾再帰によって一定のスタック領域と入力リストの長さに線形な時間を要するプログラムになるはずです。オリジナルに対して一定のオーバーヘッドは許容されます：

```lean
{{#example_decl Examples/ProgramsProofs/TCO.lean NonTailFilter}}
```
