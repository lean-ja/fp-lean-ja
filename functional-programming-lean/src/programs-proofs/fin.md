<!--
# Safe Array Indices
-->

# 安全な配列のインデックス

<!--
The `GetElem` instance for `Array` and `Nat` requires a proof that the provided `Nat` is smaller than the array.
In practice, these proofs often end up being passed to functions along with the indices.
Rather than passing an index and a proof separately, a type called `Fin` can be used to bundle up the index and the proof into a single value.
This can make code easier to read.
Additionally, many of the built-in operations on arrays take their index arguments as `Fin` rather than as `Nat`, so using these built-in operations requires understanding how to use `Fin`.
-->

`Array` と `Nat` についての `GetElem` インスタンスは与えられた `Nat` が配列よりも小さいことの証明を要求します。実際には、これらの証明はインデックスと一緒に関数に渡されることが多いです。インデックスと証明を別々に渡すのではなく、`Fin` という型を使うことで、インデックスと証明を1つの値にまとめることができます。これによりコードはさらに読みやすくなります。さらに、配列に対する組み込み操作の多くは、インデックスの引数を `Nat` ではなく `Fin` として受け取るため、これらの組み込み操作を使用するには `Fin` の使い方を理解する必要があります。

<!--
The type `Fin n` represents numbers that are strictly less than `n`.
In other words, `Fin 3` describes `0`, `1`, and `2`, while `Fin 0` has no values at all.
The definition of `Fin` resembles `Subtype`, as a `Fin n` is a structure that contains a `Nat` and a proof that it is less than `n`:
-->

型 `Fin n` は `n` 未満の数を表します。つまり、`Fin 3` は `0` ・`1` ・`2` を表し、`Fin 0` は全く値を持ちません。`Fin n` はある `Nat` とそれが `n` より小さいことの証明を含む構造体であるため、`Fin` の定義は `Subtype` に似ています：

```lean
{{#example_decl Examples/ProgramsProofs/Fin.lean Fin}}
```

<!--
Lean includes instances of `ToString` and `OfNat` that allow `Fin` values to be conveniently used as numbers.
In other words, the output of `{{#example_in Examples/ProgramsProofs/Fin.lean fiveFinEight}}` is `{{#example_out Examples/ProgramsProofs/Fin.lean fiveFinEight}}`, rather than something like `{val := 5, isLt := _}`.
-->

Leanは `Fin` の値を数値として便利に使うために `ToString` と `OfNat` のインスタンスを有しています。つまり、`{{#example_in Examples/ProgramsProofs/Fin.lean fiveFinEight}}` の結果は `{val := 5, isLt := _}` ではなく `{{#example_out Examples/ProgramsProofs/Fin.lean fiveFinEight}}` です。

<!--
Instead of failing when the provided number is larger than the bound, the `OfNat` instance for `Fin` returns a value modulo the bound.
This means that `{{#example_in Examples/ProgramsProofs/Fin.lean finOverflow}}` results in `{{#example_out Examples/ProgramsProofs/Fin.lean finOverflow}}` rather than a compile-time error.
-->

与えた数値がその範囲より大きい場合に `OfNat` インスタンスは失敗ではなく範囲の値によるその値の剰余の `Fin` を返します。つまり `{{#example_in Examples/ProgramsProofs/Fin.lean finOverflow}}` はコンパイルエラーにならずに `{{#example_out Examples/ProgramsProofs/Fin.lean finOverflow}}` となります。

<!--
In a return type, a `Fin` returned as a found index makes its connection to the data structure in which it was found more clear.
The `Array.find` in the [previous section](./arrays-termination.md#proving-termination) returns an index that the caller cannot immediately use to perform lookups into the array, because the information about its validity has been lost.
A more specific type results in a value that can be used without making the program significantly more complicated:
-->

戻り値の型において、見つかったインデックスとして返される `Fin` はそれが見つかったデータ構造との関連をより明確にします。[前節](./arrays-termination.md#proving-termination) での `Array.find` はその有効性に関する情報が失われているため、そのインデックスを使って配列検索がすぐには実行できません。より具体的な型によって、プログラムを著しく複雑にすることなく使用できる値が返されます：

```lean
{{#example_decl Examples/ProgramsProofs/Fin.lean ArrayFindHelper}}

{{#example_decl Examples/ProgramsProofs/Fin.lean ArrayFind}}
```

<!--
## Exercise
-->

## 演習問題

<!--
Write a function `Fin.next? : Fin n → Option (Fin n)` that returns the next largest `Fin` when it would be in bounds, or `none` if not.
Check that
-->

与えられた値の1つ大きい数値が範囲内であればその `Fin` を、そうでなければ `none` を返す関数 `Fin.next? : Fin n → Option (Fin n)` を書いてください。これが以下に対して

```lean
{{#example_in Examples/ProgramsProofs/Fin.lean nextThreeFin}}
```
<!--
outputs
-->

以下を出力し、

```output info
{{#example_out Examples/ProgramsProofs/Fin.lean nextThreeFin}}
```
<!--
and that
-->

また以下に対して

```lean
{{#example_in Examples/ProgramsProofs/Fin.lean nextSevenFin}}
```
<!--
outputs
-->

以下を出力することを確かめてください。

```output info
{{#example_out Examples/ProgramsProofs/Fin.lean nextSevenFin}}
```
