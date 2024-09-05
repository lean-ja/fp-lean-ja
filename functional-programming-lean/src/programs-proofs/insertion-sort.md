<!--
# Insertion Sort and Array Mutation
-->

# 挿入ソートと配列の更新

<!--
While insertion sort does not have the optimal worst-case time complexity for a sorting algorithm, it still has a number of useful properties:
-->

挿入ソートはソートアルゴリズムとしては最悪計算時間の複雑性において最適ではありませんが、それでもいくつもの有用な性質を持ちます：

 <!--
 * It is simple and straightforward to implement and understand
 * It is an in-place algorithm, requiring no additional space to run
 * It is a stable sort
 * It is fast when the input is already almost sorted
-->
 
 * 実装および理屈がシンプルで直観的であること
 * in-placeアルゴリズムであり、実行時に追加の領域を必要としないこと
 * 安定ソートである
 * 入力がソート済みである場合は高速
 
<!--
In-place algorithms are particularly useful in Lean due to the way it manages memory.
In some cases, operations that would normally copy an array can be optimized into mutation.
This includes swapping elements in an array.
-->

特にin-placeアルゴリズムである点はLeanにおいてメモリ管理の方法から有用です。いくつかのケースでは、通常では配列のコピーの操作は更新に最適化されます。これは配列内の要素の交換も含みます。

<!--
Most languages and run-time systems with automatic memory management, including JavaScript, the JVM, and .NET, use tracing garbage collection.
When memory needs to be reclaimed, the system starts at a number of _roots_ (such as the call stack and global values) and then determines which values can be reached by recursively chasing pointers.
Any values that can't be reached are deallocated, freeing memory.
-->

JavaScriptやJVM、.NETを含むメモリを動的に管理するほとんどの言語とランタイムでは、ガベージコレクションの追跡を用います。メモリを再要求する必要がある場合、システムはいくつかの **ルート** （コールスタックやグローバル値など）から開始し、再帰的にポインタを追いかけることで到達できる値を決定します。到達できない値はすべて割り当て解除され、メモリが解放されます。

<!--
Reference counting is an alternative to tracing garbage collection that is used by a number of languages, including Python, Swift, and Lean.
In a system with reference counting, each object in memory has a field that tracks how many references there are to it.
When a new reference is established, the counter is incremented.
When a reference ceases to exist, the counter is decremented.
When the counter reaches zero, the object is immediately deallocated.
-->

ガベージコレクションの追跡の代替手段として、Python・Swift・Leanを含む多くの言語では参照カウントが用いられます。参照カウントを持つシステムでは、メモリ内のオブジェクトはそれへの参照がいくつあるかを追跡するフィールドを持ちます。新しい参照が確立されるとカウントが1増えます。参照が存在しなくなるとカウントが1減ります。カウントが0になると、オブジェクトは直ちに解放されます。

<!--
Reference counting has one major disadvantage compared to a tracing garbage collector: circular references can lead to memory leaks.
If object \\( A \\) references object \\( B \\) , and object \\( B \\) references object \\( A \\), they will never be deallocated, even if nothing else in the program references either \\( A \\) or \\( B \\).
Circular references result either from uncontrolled recursion or from mutable references.
Because Lean supports neither, it is impossible to construct circular references.
-->

参照カウンタはガベージコレクションの追跡に対して1つの大きな欠点があります：循環参照によるメモリーリークです。あるオブジェクト \\( A \\) がオブジェクト \\( B \\) を参照し、オブジェクト \\( B \\) がオブジェクト \\( A \\) を参照している場合、たとえそのプログラム内で \\( A \\) と \\( B \\) に対して参照が無くてもこれらは決して解放されません。循環参照は制御されていない再帰か、変更可能な参照のどちらかに起因します。Leanはどちらもサポートしていないため、循環参照を構築することは不可能です。

<!--
Reference counting means that the Lean runtime system's primitives for allocating and deallocating data structures can check whether a reference count is about to fall to zero, and re-use an existing object instead of allocating a new one.
This is particularly important when working with large arrays.
-->

参照カウントによってLeanのランタイムシステムのデータ構造の割り当て・解放のプリミティブが、あるオブジェクトの参照カウントが0になるかどうか、既存のオブジェクトを新しく割り当てることなく再利用するかをチェックできるようになります。これは大きな配列を扱う際には特に重要になります。

<!--
An implementation of insertion sort for Lean arrays should satisfy the following criteria:
-->

Leanの配列についての挿入ソートの実装は以下の性質を満たさなければなりません：

 <!--
 1. Lean should accept the function without a `partial` annotation
 2. If passed an array to which there are no other references, it should modify the array in-place rather than allocating a new one
-->

 1. Leanがこの関数を `partial` 注釈無しで許容するべきである
 2. 他に参照がない配列が渡された場合、新しい配列を確保するのではなく、in-placeで配列を変更すること

<!--
The first criterion is easy to check: if Lean accepts the definition, then it is satisfied.
The second, however, requires a means of testing it.
Lean provides a built-in function called `dbgTraceIfShared` with the following signature:
-->

最初の性質は簡単にチェックできます：もしLeanがその定義を受け入れるならば満足します。しかし2つ目は検証方法が必要になります。Leanには下記のシグネチャを持つ `dbgTraceIfShared` という関数が組み込まれています：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean dbgTraceIfSharedSig}}
```
```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean dbgTraceIfSharedSig}}
```
<!--
It takes a string and a value as arguments, and prints a message that uses the string to standard error if the value has more than one reference, returning the value.
This is not, strictly speaking, a pure function.
However, it is intended to be used only during development to check that a function is in fact able to re-use memory rather than allocating and copying.
-->

これは引数として文字列と値を受け取り、もしその値に複数の参照があれば渡された文字列を使用したメッセージを標準エラーに出力し、値を返します。これは厳密には純粋関数ではありません。しかし、これは関数が実際にメモリを割り当てたりコピーしたりせずにメモリを再利用できるかどうかをチェックするために、開発中にのみ使用することを意図しています。

<!--
When learning to use `dbgTraceIfShared`, it's important to know that `#eval` will report that many more values are shared than in compiled code.
This can be confusing.
It's important to build an executable with `lake` rather than experimenting in an editor.
-->

`dbgTraceIfShared` の使い方を学ぶにあたって、`#eval` がコンパイルされたコード中のものよりも多くの値が共有されていると報告することを知ることが大事です。これは混乱を招く恐れがあります。エディタで実験するよりも、`lake` を使って実行ファイルをビルドすることが重要です。

<!--
Insertion sort consists of two loops.
The outer loop moves a pointer from left to right across the array to be sorted.
After each iteration, the region of the array to the left of the pointer is sorted, while the region to the right may not yet be sorted.
The inner loop takes the element pointed to by the pointer and moves it to the left until the appropriate location has been found and the loop invariant has been restored.
In other words, each iteration inserts the next element of the array into the appropriate location in the sorted region.
-->

挿入ソートは2つのループから構成されます。外側のループはポインタをソート対象の配列を左から右に動かします。各繰り返しの後に、配列内のポインタの左側はソートされる一方で右側は未ソートとなります。内側のループはポインタが指す要素を受け取り、それを適切な場所が見つかりループの不変条件が復元するまで左へと移動させます。言い換えると、各繰り返しは配列の次の要素をソート済み領域の適切な位置に挿入します。

<!--
## The Inner Loop
-->

## 内側のループ

<!--
The inner loop of insertion sort can be implemented as a tail-recursive function that takes the array and the index of the element being inserted as arguments.
The element being inserted is repeatedly swapped with the element to its left until either the element to the left is smaller or the beginning of the array is reached.
The inner loop is structurally recursive on the `Nat` that is inside the `Fin` used to index into the array:
-->

挿入ソートの内側のループは配列と挿入する要素を引数として受け取る末尾再帰関数として実装することができます。挿入されるこの要素は、左側の要素の方が小さいときか配列の先頭にたどり着くまで繰り返し左の要素と入れ替えられ続けます。内側のループは配列のインデックスとして使われる `Fin` の中の `Nat` に対して構造的に再帰的です：

```leantac
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insertSorted}}
```
<!--
If the index `i` is `0`, then the element being inserted into the sorted region has reached the beginning of the region and is the smallest.
If the index is `i' + 1`, then the element at `i'` should be compared to the element at `i`.
Note that while `i` is a `Fin arr.size`, `i'` is just a `Nat` because it results from the `val` field of `i`.
It is thus necessary to prove that `i' < arr.size` before `i'` can be used to index into `arr`.
-->

インデックス `i` が `0` ならば、ソート済み領域に挿入されるこの要素はすでに領域の先頭であり最小の値です。インデックスが `i' + 1` ならば、`i'` 番目の要素は `i` 番目の要素と比較されるべきです。ここで `i` は `Fin arr.size` 型ですが、`i'` は `i` の `val` フィールドから得られたものなのでただの `Nat` であることに注意してください。したがって `i'` を `arr` のインデックスとして使う前に `i' < arr.size` を証明する必要があります。

<!--
Omitting the `have`-expression with the proof that `i' < arr.size` reveals the following goal:
-->

`i' < arr.size` の証明から `have` 式を取り除くと以下のゴールが現れます：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertSortedNoProof}}
```

<!--
The hint `Nat.lt_of_succ_lt` is a theorem from Lean's standard library.
Its signature, found by `{{#example_in Examples/ProgramsProofs/InsertionSort.lean lt_of_succ_lt_type}}`, is
-->

`Nat.lt_of_succ_lt` はLeanの標準ライブラリにある定理です。このシグネチャは `{{#example_in Examples/ProgramsProofs/InsertionSort.lean lt_of_succ_lt_type}}` で確認でき、以下のようになります：

```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean lt_of_succ_lt_type}}
```
<!--
In other words, it states that if `n + 1 < m`, then `n < m`.
The `*` passed to `simp` causes it to combine `Nat.lt_of_succ_lt` with the `isLt` field from `i` to get the final proof.
-->

言い換えると、これは `n + 1 < m` ならば `n < m` であるということを述べています。`simp` に `*` を渡すことで最終的な証明を得るために `Nat.lt_of_succ_lt` に `i` の `isLt` フィールドが組み合わせられます。

<!--
Having established that `i'` can be used to look up the element to the left of the element being inserted, the two elements are looked up and compared. 
If the element to the left is less than or equal to the element being inserted, then the loop is finished and the invariant has been restored.
If the element to the left is greater than the element being inserted, then the elements are swapped and the inner loop begins again.
`Array.swap` takes both of its indices as `Fin`s, and the `by assumption` that establishes that `i' < arr.size` makes use of the `have`.
The index to be examined on the next round through the inner loop is also `i'`, but `by assumption` is not sufficient in this case.
This is because the proof was written for the original array `arr`, not the result of swapping two elements.
The `simp` tactic's database contains the fact that swapping two elements of an array doesn't change its size, and the `[*]` argument instructs it to additionally use the assumption introduced by `have`.
-->

`i'` が挿入される要素の左の要素を調べるために使えるようになったため、これら2つの要素を調べて比較します。左の要素が挿入される要素以下であれば、ループは終了し、ループ不変条件が復元されます。もし左の要素が挿入される要素より大きければ、要素が入れ替わり内側のループが再び始まります。`Array.swap` は `Fin` である両方のインデックスと、`have` で成立した `i' < arr.size` を利用している `by assumption` を受け取ります。次のループで調べるインデックスも `i'` ですが、この場合 `by assumption` だけでは不十分です。なぜなら、この証明は2つの要素を入れ替えた結果ではなく、もとの配列 `arr` に対して書かれたものだからです。`simp` タクティクのデータベースには、配列の2つの要素を入れ替えてもサイズが変わらないという事実が含まれており、`[*]` 引数は `have` によって導入された仮定を追加で使用するように指示します。

<!--
## The Outer Loop
-->

## 外側のループ

<!--
The outer loop of insertion sort moves the pointer from left to right, invoking `insertSorted` at each iteration to insert the element at the pointer into the correct position in the array.
The basic form of the loop resembles the implementation of `Array.map`:
-->

挿入ソートの外側のループでは、ポインタを左から右へ動かし、各繰り返しで `insertSorted` を呼び出してポインタの要素を配列の正しい位置に挿入します。このループの基本形は `Array.map` の実装に似ています：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopTermination}}
```
<!--
The resulting error is also the same as the error that occurs without a `termination_by` clause on `Array.map`, because there is no argument that decreases at every recursive call:
-->

その結果生じるエラーも `termination_by` 節を `Array.map` に指定しない場合に生じるものと同じです。というのも再帰呼び出しのたびに減少する引数がないからです：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopTermination}}
```

<!--
Before constructing the termination proof, it can be convenient to test the definition with a `partial` modifier to make sure that it returns the expected answers:
-->

停止についての証明を構築する前に、`partial` 修飾子を使って定義をテストし、これが期待される答えを返すことを確認しておくと便利です：

```lean
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean partialInsertionSortLoop}}
```
```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialOne}}
```
```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialOne}}
```
```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialTwo}}
```
```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialTwo}}
```

<!--
### Termination
-->

### 停止性

<!--
Once again, the function terminates because the difference between the index and the size of the array being processed decreases on each recursive call.
This time, however, Lean does not accept the `termination_by`:
-->

ここでもまた、インデックスと配列のサイズの差が各再帰呼び出しのたびに小さくなっていくため関数は終了します。しかし、今回Leanはこの `termination_by` を受理しません：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopProof1}}
```
```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopProof1}}
```
<!--
The problem is that Lean has no way to know that `insertSorted` returns an array that's the same size as the one it is passed.
In order to prove that `insertionSortLoop` terminates, it is necessary to first prove that `insertSorted` doesn't change the size of the array.
Copying the unproved termination condition from the error message to the function and "proving" it with `sorry` allows the function to be temporarily accepted:
-->

問題はLeanが `insertSorted` が渡された配列と同じサイズの配列を返すことを知る方法がないことです。`insertionSortLoop` が終了することを証明するには、まず `insertSorted` が配列のサイズを変更しないことを証明する必要があります。エラーメッセージから証明されていない終了条件を関数にコピーし、`sorry` で「証明」することで、この関数を一時的に受け入れることができます：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopSorry}}
```
```output warning
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopSorry}}
```

<!--
Because `insertSorted` is structurally recursive on the index of the element being inserted, the proof should be by induction on the index.
In the base case, the array is returned unchanged, so its length certainly does not change.
For the inductive step, the induction hypothesis is that a recursive call on the next smaller index will not change the length of the array.
There are two cases two consider: either the element has been fully inserted into the sorted region and the array is returned unchanged, in which case the length is also unchanged, or the element is swapped with the next one before the recursive call.
However, swapping two elements in an array doesn't change the size of it, and the induction hypothesis states that the recursive call with the next index returns an array that's the same size as its argument.
Thus, the size remains unchanged.
-->

`insertSorted` は挿入される要素のインデックスに対して構造的に再帰的であるため、証明はインデックスに対する帰納法で行う必要があります。基本ケースでは配列は変更されずに返されるので、その長さは確かに変化しません。帰納法のステップでは、次の小さいインデックスで再帰的に呼び出しても配列の長さは変わらないという帰納法の仮定が成り立ちます。ここでは2つのケースを考慮します：要素がソート済みの領域に完全に挿入され、配列が変更されずに返される場合と、再帰呼び出しの前に要素が次の要素と交換される場合です。しかし、配列の2つの要素を入れ替えてもサイズは変わらないため、帰納法の仮定によれば次のインデックスによる再帰呼び出しは、引数と同じサイズの配列を返します。したがってサイズは変わりません。

<!--
Translating this English-language theorem statement to Lean and proceeding using the techniques from this chapter is enough to prove the base case and make progress in the inductive step:
-->

この自然言語の定理文をLeanに翻訳し、本章のテクニックを使って進めば、基本ケースの証明と帰納法のステップを進めるには十分です：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_0}}
```
<!--
The simplification using `insertSorted` in the inductive step revealed the pattern match in `insertSorted`:
-->

帰納法のステップ中で `insertSorted` を使って単純化することで `insertSorted` 内のパターンマッチが現れます：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_0}}
```
<!--
When faced with a goal that includes `if` or `match`, the `split` tactic (not to be confused with the `split` function used in the definition of merge sort) replaces the goal with one new goal for each path of control flow:
-->

`if` や `match` を含むゴールに直面した時、`split` タクティク（マージソートの定義で使われている `split` 関数と混同しないように）は制御フローのパスごとにゴールを新しいゴールに置き換えます：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_1}}
```
<!--
Additionally, each new goal has an assumption that indicates which branch led to that goal, named `heq✝` in this case:
-->

さらに、それぞれの新しいゴールにはどのブランチがそのゴールにつながったかを示す仮定があり、この場合では `heq✝` と名付けられます：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_1}}
```
<!--
Rather than write proofs for both simple cases, adding `<;> try rfl` after `split` causes the two straightforward cases to disappear immediately, leaving only a single goal:
-->

両方のケースに対して単純な証明を書くよりも、`split` の後に `<;> try rfl` を加えることで2つの単純なケースはたちまち消え、1つのゴールだけが残ります：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_2}}
```
```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_2}}
```

<!--
Unfortunately, the induction hypothesis is not strong enough to prove this goal.
The induction hypothesis states that calling `insertSorted` on `arr` leaves the size unchanged, but the proof goal is to show that the result of the recursive call with the result of swapping leaves the size unchanged.
Successfully completing the proof requires an induction hypothesis that works for _any_ array that is passed to `insertSorted` together with the smaller index as an argument
-->

残念なことに、帰納法の仮定はこのゴールを証明するには不十分です。帰納法の仮定は `arr` に対して `insertSorted` を呼び出すとサイズが変わらないことを述べていますが、証明のゴールは再帰的な呼び出しの結果と置換の結果がサイズを変えないことを示すことです。証明を成功させるには、小さい方のインデックスを引数として `insertSorted` に渡す **任意の** 配列に対して機能する帰納法の仮定が必要です。

<!--
It is possible to get a strong induction hypothesis by using the `generalizing` option to the `induction` tactic.
This option brings additional assumptions from the context into the statement that's used to generate the base case, the induction hypothesis, and the goal to be shown in the inductive step.
Generalizing over `arr` leads to a stronger hypothesis:
-->

`induction` タクティクに `generalizing` オプションを使用することで強力な帰納法の仮定を得ることができます。このオプションは、基本ケース、帰納法の仮定、および帰納法のステップで示されるゴールを生成するために使用される文にコンテキストから追加の仮定をもたらします。`arr` を一般化することで、より強力な仮定を導くことができます：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_3}}
```
<!--
In the resulting goal, `arr` is now part of a "for all" statement in the inductive hypothesis:
-->

その結果、`arr` は帰納法の仮定の「全ての～について～」文の一部となります：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_3}}
```

<!--
However, this whole proof is beginning to get unmanageable.
The next step would be to introduce a variable standing for the length of the result of swapping, show that it is equal to `arr.size`, and then show that this variable is also equal to the length of the array that results from the recursive call.
These equality statement can then be chained together to prove the goal.
It's much easier, however, to carefully reformulate the theorem statement such that the induction hypothesis is automatically strong enough and the variables are already introduced.
The reformulated statement reads:
-->

しかし、この証明全体は手に負えなくなってきました。次のステップは置換結果の長さを表す変数を導入し、それが `arr.size` と等しいことを示し、この変数が再帰呼び出しの結果得られる配列の長さとも等しいことを示すことです。これらの等式を連鎖させて、ゴールを証明することができます。しかし、帰納法の仮定が自動的に十分強く、変数もすでに導入されるように定理文を注意深く再定式化する方がはるかに簡単です。再定式化された文は次のようになります：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_0}}
```
<!--
This version of the theorem statement is easier to prove for a few reasons:
-->

このバージョンの定理文はいくつかの理由から証明が容易です：

 <!--
 1. Rather than bundling up the index and the proof of its validity in a `Fin`, the index comes before the array.
    This allows the induction hypothesis to naturally generalize over the array and the proof that `i` is in bounds.
 2. An abstract length `len` is introduced to stand for `array.size`.
    Proof automation is often better at working with explicit statements of equality.
-->

 1. インデックスとその有効性の証明を `Fin` にまとめるのではなく、インデックスを配列の前に持ってくる。これにより帰納法の仮定が配列と `i` が範囲内にあることの証明に対して自然に一般化されます。
 2. 抽象的な長さ `len` が `array.size` の略として導入されました。証明の自動化は明示的な等号を扱う方が得意な場合が多いです。

<!--
The resulting proof state shows the statement that will be used to generate the induction hypothesis, as well as the base case and the goal of the inductive step:
-->

結果として得られる証明状態は、帰納法の仮定を生成するために使用される文と、基本ケースと帰納法のステップのゴールを示します：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_0}}
```

<!--
Compare the statement with the goals that result from the `induction` tactic:
-->

この文と `induction` タクティクの結果として得られるゴールを比べてみてください：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_1a}}
```
<!--
In the base case, each occurrence of `i` has been replaced by `0`.
Using `intro` to introduce each assumption and then simplifying using `insertSorted` will prove the goal, because `insertSorted` at index `zero` returns its argument unchanged:
-->

基本ケースでは、`i` のそれぞれの出現が `0` に置き換えられています。各仮定の導入に `intro` を使用し、次に `insertSorted` を使用して単純化するとインデックス `zero` での `insertSorted` はその引数を変更せずに返すため、ゴールが証明されます：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_1a}}
```
<!--
In the inductive step, the induction hypothesis has exactly the right strength.
It will be useful for _any_ array, so long as that array has length `len`:
-->

帰納法のステップにおいて、帰納法の仮定は実にちょうど良い強さを持ちます。これは配列の長さが `len` である限り **どのような** 配列に対しても有効です：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_1b}}
```

<!--
In the base case, `simp` reduces the goal to `arr.size = len`:
-->

基本ケースでは、`simp` によってゴールが `arr.size = len` へと簡約されます：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_2}}
```
```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_2}}
```
<!--
This can be proved using the assumption `hLen`.
Adding the `*` parameter to `simp` instructs it to additionally use assumptions, which solves the goal:
-->

これは仮定 `hLen` を使って証明できます。`simp` に `*` パラメータを追加することで仮定を追加で使用するように指示することができます：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_2b}}
```

<!--
In the inductive step, introducing assumptions and simplifying the goal results once again in a goal that contains a pattern match:
-->

帰納法のステップにおいて、仮定の導入とゴールの単純化によってゴールはふたたびパターンマッチを含んだものとなります：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_3}}
```
```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_3}}
```
<!--
Using the `split` tactic results in one goal for each pattern.
Once again, the first two goals result from branches without recursive calls, so the induction hypothesis is not necessary:
-->

`split` タクティクを使うことで各パターンそれぞれに1つずつゴールが割り当てられます。繰り返しになりますが、最初の2つのゴールは再帰呼び出しのない分岐から得られるため帰納法の仮定は必要ありません：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_4}}
```
```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_4}}
```
<!--
Running `try assumption` in each goal that results from `split` eliminates both of the non-recursive goals:
-->

`split` で得られる各ゴールで `try assumption` を実行すると非再帰的なゴールは両方とも無くなります：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_5}}
```
```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_5}}
```

<!--
The new formulation of the proof goal, in which a constant `len` is used for the lengths of all the arrays involved in the recursive function, falls nicely within the kinds of problems that `simp` can solve.
This final proof goal can be solved by `simp [*]`, because the assumptions that relate the array's length to `len` are important:
-->

再帰関数に関係するすべての配列の長さに定数 `len` を使用するという新しい証明のゴールについての形式化は `simp` が解決できる類の問題にうまく当てはまります。配列の長さを `len` に関連付ける仮定が重要であるため、この証明の最終的なゴールは `simp [*]` で解くことができます：

```leantac
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_6}}
```

<!--
Finally, because `simp [*]` can use assumptions, the `try assumption` line can be replaced by `simp [*]`, shortening the proof:
-->

最後に、`simp [*]` は仮定を使うことができるため、`try assumption` の行は `simp [*]` に置き換えることができ、証明を短くできます：

```leantac
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo}}
```

<!--
This proof can now be used to replace the `sorry` in `insertionSortLoop`.
Providing `arr.size` as the `len` argument to the theorem causes the final conclusion to be `(insertSorted arr ⟨i, isLt⟩).size = arr.size`, so the rewrite ends with a very manageable proof goal:
-->

これでこの証明を使って `insertionSortLoop` の `sorry` を置き換えることができます。定理の `len` 引数に `arr.size` を与えることで最終的な結論は `(insertSorted arr ⟨i, isLt⟩).size = arr.size` となるため、非常に扱いやすい証明のゴールへと書き換えることができます：

```leantacnorfl
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopRw}}
```
```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopRw}}
```
<!--
The proof `{{#example_in Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}` is part of Lean's standard library.
It's type is `{{#example_out Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}`, which is exactly what's needed:
-->

証明 `{{#example_in Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}` はLeanの標準ライブラリの一部です。この型は `{{#example_out Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}` であり、これはまさに必要だったものです：


```leantacnorfl
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insertionSortLoop}}
```


<!--
## The Driver Function
-->

## ドライバ関数

<!--
Insertion sort itself calls `insertionSortLoop`, initializing the index that demarcates the sorted region of the array from the unsorted region to `0`:
-->

挿入ソート自体は `insertionSortLoop` を呼び出し、配列のソート済み領域と未ソート領域を区切るインデックスを `0` に初期化します：

```lean
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insertionSort}}
```

<!--
A few quick tests show the function is at least not blatantly wrong:
-->

簡単なテストをいくつかやってみると、この関数は少なくともあからさまに間違ってはいません：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortNums}}
```
```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortNums}}
```
```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortStrings}}
```
```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortStrings}}
```

<!--
## Is This Really Insertion Sort?
-->

## これは本当に挿入ソート？

<!--
Insertion sort is _defined_ to be an in-place sorting algorithm.
What makes it useful, despite its quadratic worst-case run time, is that it is a stable sorting algorithm that doesn't allocate extra space and that handles almost-sorted data efficiently.
If each iteration of the inner loop allocated a new array, then the algorithm wouldn't _really_ be insertion sort.
-->

挿入ソートはin-placeのソートアルゴリズムとして **定義されています** 。最悪実行時間が2倍になるにも関わらず挿入ソートが有用であるのは、余分な領域を割り当てず、ほぼソート済みのデータを効率的に扱う安定したソートアルゴリズムであるからです。もし内部ループの各繰り返しが新しい配列を割り当てるのであれば、このアルゴリズムは **本物の** 挿入ソートではありません。

<!--
Lean's array operations, such as `Array.set` and `Array.swap`, check whether the array in question has a reference count that is greater than one.
If so, then the array is visible to multiple parts of the code, which means that it must be copied.
Otherwise, Lean would no longer be a pure functional language.
However, when the reference count is exactly one, there are no other potential observers of the value.
In these cases, the array primitives mutate the array in place.
What other parts of the program don't know can't hurt them.
-->

`Array.set` や `Array.swap` などのLeanの配列操作は対象の配列の参照カウンタが1より大きいかどうかをチェックします。もし大きければ、その配列はコードの複数の個所から見えることになり、コピーしなければならないことになります。そうでなければLeanはもはや純粋関数型言語ではなくなってしまいます。しかし、参照カウンタがちょうど1の場合、その値に対する潜在的な観測者はほかに存在しません。このような場合、配列のプリミティブはその場で配列を変更します。ここ以外のプログラムが知り得ないことはそれ等自身を傷つけることはありません。

<!--
Lean's proof logic works at the level of pure functional programs, not the underlying implementation.
This means that the best way to discover whether a program unnecessarily copies data is to test it.
Adding calls to `dbgTraceIfShared` at each point where mutation is desired causes the provided message to be printed to `stderr` when the value in question has more than one reference.
-->

Leanの証明論理は純粋関数型プログラムのレベルで機能するのであって、その下にある実装に対しては機能しません。つまりプログラムが不必要にデータをコピーしているかどうかを発見する最善の方法は、それをテストすることです。更新が必要な各ポイントで `dbgTraceIfShared` の呼び出しを追加すると、問題の値が複数の参照を持つ場合に提供されたメッセージが `stderr` に出力されます。

<!--
Insertion sort has precisely one place that is at risk of copying rather than mutating: the call to `Array.swap`.
Replacing `arr.swap ⟨i', by assumption⟩ i` with `((dbgTraceIfShared "array to swap" arr).swap ⟨i', by assumption⟩ i)` causes the program to emit `shared RC array to swap` whenever it is unable to mutate the array.
However, this change to the program changes the proofs as well, because now there's a call to an additional function.
Because `dbgTraceIfShared` returns its second argument directly, adding it to the calls to `simp` is enough to fix the proofs.
-->

挿入ソートは変更ではなくコピーをしてしまう恐れある箇所がまさに一か所あります：`Array.swap`の呼び出しです。`arr.swap ⟨i', by assumption⟩ i` を `((dbgTraceIfShared "array to swap" arr).swap ⟨i', by assumption⟩ i)` に置き換えることで、プログラムはプログラムを変更できない時は必ず `shared RC array to swap` を出力するようになります。しかし、追加の関数呼び出しが加わることの変化によって証明も変わってしまいます。`dbgTraceIfShared` は第2引数を直接返すため、`simp` の呼び出しに追加するだけで証明は修正されます。

<!--
The complete instrumented code for insertion sort is:
-->

挿入ソートの計装用の完全なコードは以下の通りです：

```leantacnorfl
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:InstrumentedInsertionSort}}
```

<!--
A bit of cleverness is required to check whether the instrumentation actually works.
First off, the Lean compiler aggressively optimizes function calls away when all their arguments are known at compile time.
Simply writing a program that applies `insertionSort` to a large array is not sufficient, because the resulting compiled code may contain only the sorted array as a constant.
The easiest way to ensure that the compiler doesn't optimize away the sorting routine is to read the array from `stdin`.
Secondly, the compiler performs dead code elimination.
Adding extra `let`s to the program won't necessarily result in more references in running code if the `let`-bound variables are never used.
To ensure that the extra reference is not eliminated entirely, it's important to ensure that the extra reference is somehow used.
-->

計装が実際に機能するかどうかをチェックするにはちょっとした工夫が必要です。まずLeanのコンパイラはコンパイル時にすべての引数が分かっている場合、関数呼び出しを積極的に最適化します。そのため計装のために大きな配列に `insertionSort` を適用するプログラムを書くだけでは不十分です。というのもコンパイル結果のコードはソート済みの配列だけが定数として含まれる可能性があるからです。コンパイラがソートルーチンを最適化しないようにする最も簡単な方法は `stdin` から配列を読み込むことです。次に、コンパイラはデッドコードの除去を行います。もし `let` に束縛された変数が使われることがなければ、プログラムへの余分な `let` を追加しても実行中のコードの参照が増えるとは限りません。余分な参照が完全に除去されないようにするためには、余分な参照が何らかの形で使われるようにすることが重要です。

<!--
The first step in testing the instrumentation is to write `getLines`, which reads an array of lines from standard input:
-->

計装をテストする最初のステップは標準入力から行の配列を読み込む `getLines` を書くことです：

```lean
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:getLines}}
```
<!--
`IO.FS.Stream.getLine` returns a complete line of text, including the trailing newline.
It returns `""` when the end-of-file marker has been reached.
-->

`IO.FS.Stream.getLine` は末尾の開業を含む完全なテキスト行を返します。ファイル終端記号に到達した場合は `""` を返します。

<!--
Next, two separate `main` routines are needed.
Both read the array to be sorted from standard input, ensuring that the calls to `insertionSort` won't be replaced by their return values at compile time.
Both then print to the console, ensuring that the calls to `insertionSort` won't be optimized away entirely.
One of them prints only the sorted array, while the other prints both the sorted array and the original array.
The second function should trigger a warning that `Array.swap` had to allocate a new array:
-->

次に、2つの別々の `main` ルーチンが必要です。どちらも標準入力からソート対象の配列を読み込み、これによってコンパイル時に `insertionSort` の呼び出しが戻り値に置き換えられないようにします。どちらもコンソールに出力し、これにより `insertionSort` の呼び出しが完全に最適化されることはありません。一方はソートされた配列のみを表示し、もう一方はソートされた配列と元の配列を両方表示します。2番目の関数は `Array.swap` が新しい配列を確保しなければならなかったという警告を表示します：

```lean
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:mains}}
```

<!--
The actual `main` simply selects one of the two main actions based on the provided command-line arguments:
-->

実際の `main` は与えらえたコマンドライン引数に基づいて2つのメインアクションのうち1つを選択するだけです：

```lean
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:main}}
```

<!--
Running it with no arguments produces the expected usage information:
-->

引数無しで実行すると、期待通りの使用情報が得られます：

```
$ {{#command {sort-demo} {sort-sharing} {./run-usage} {sort}}}
{{#command_out {sort-sharing} {./run-usage} }}
```

<!--
The file `test-data` contains the following rocks:
-->

ファイル `test-data` は以下の岩についての情報を保持します：

```
{{#file_contents {sort-sharing} {sort-demo/test-data}}}
```

<!--
Using the instrumented insertion sort on these rocks results them being printed in alphabetical order:
-->

これらの岩石に計装用の挿入ソートを使うとアルファベット順に印字されます：

```
$ {{#command {sort-demo} {sort-sharing} {sort --unique < test-data}}}
{{#command_out {sort-sharing} {sort --unique < test-data} }}
```

<!--
However, the version in which a reference is retained to the original array results in a notification on `stderr` (namely, `shared RC array to swap`) from the first call to `Array.swap`:
-->

しかし、元の配列への参照が保持されるバージョンでは、最初に `Array.swap` を呼び出した時から `stderr` （つまり `shared RC array to swap` ）に通知が行われます：

```
$ {{#command {sort-demo} {sort-sharing} {sort --shared < test-data}}}
{{#command_out {sort-sharing} {sort --shared < test-data} }}
```
<!--
The fact that only a single `shared RC` notification appears means that the array is copied only once.
This is because the copy that results from the call to `Array.swap` is itself unique, so no further copies need to be made.
In an imperative language, subtle bugs can result from forgetting to explicitly copy an array before passing it by reference.
When running `sort --shared`, the array is copied as needed to preserve the pure functional meaning of Lean programs, but no more.
-->

`shared RC` が1つしか表示されないということは、配列が1度だけコピーされることを意味します。これは、`Array.swap` を呼び出した結果のコピー自体が一意であるためであり、それ以上コピーする必要はありません。命令型言語では、配列を参照渡しする前に明示的にコピーすることを忘れると微妙なバグが発生することがあります。`sort --shared` を実行すると、Leanのプログラムの純粋関数的な意味を保つために必要な分だけ配列がコピーされますが、それ以上はコピーされません。

<!--
## Other Opportunities for Mutation
-->

## その他の更新の機会

<!--
The use of mutation instead of copying when references are unique is not limited to array update operators.
Lean also attempts to "recycle" constructors whose reference counts are about to fall to zero, reusing them instead of allocating new data.
This means, for instance, that `List.map` will mutate a linked list in place, at least in cases when nobody could possibly notice.
One of the most important steps in optimizing hot loops in Lean code is making sure that the data being modified is not referred to from multiple locations.
-->

参照が一意である場合にコピーの代わりに更新を使用するのは配列更新演算子に限ったことではありません。Leanは参照カウンタが0になりそうなコンストラクタを「リサイクル」し、新しいデータを割り当てる代わりに再利用しようとします。これは例えば、`Let.map` が連結リストをその場で更新することを意味します。Leanのコードでホット・ループを最適化する最も重要なステップの1つは、変更されるデータが複数の場所から参照されないようにすることです。

<!--
## Exercises
-->

## 演習問題

 <!--
 * Write a function that reverses arrays. Test that if the input array has a reference count of one, then your function does not allocate a new array.
-->

 * 配列を反転させる関数を書いてください。入力配列の参照カウンタが1の場合、関数が新しい配列を確保しないことをテストしてください。

<!--
* Implement either merge sort or quicksort for arrays. Prove that your implementation terminates, and test that it doesn't allocate more arrays than expected. This is a challenging exercise!
-->

* 配列に対してマージソートかクイックソートのどちらかを実装してください。読者の実装が停止することを証明し、期待以上の配列を確保しないことをテストしてください。これは難しい練習問題です！ 
 
   
