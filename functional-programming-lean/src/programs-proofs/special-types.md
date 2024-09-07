<!--
# Special Types
-->

# 特別な型

<!--
Understanding the representation of data in memory is very important.
Usually, the representation can be understood from the definition of a datatype.
Each constructor corresponds to an object in memory that has a header that includes a tag and a reference count.
The constructor's arguments are each represented by a pointer to some other object.
In other words, `List` really is a linked list and extracting a field from a `structure` really does just chase a pointer.
-->

メモリ上でのデータ表現を理解することは非常に重要です。通常、このような表現はデータ型の定義から理解することができます。各コンストラクタはタグと参照カウントを含むヘッダを持つメモリ上のオブジェクトに対応します。コンストラクタの引数はそれぞれ対応するオブジェクトへのポインタで表されます。言い換えると、`List` は本当に連結リストであり、`structure` からフィールドを取り出すことはまさにポインタを追跡することになります。

<!--
There are, however, some important exceptions to this rule.
A number of types are treated specially by the compiler.
For example, the type `UInt32` is defined as `Fin (2 ^ 32)`, but it is replaced at run-time with an actual native implementation based on machine words.
Similarly, even though the definition of `Nat` suggests an implementation similar to `List Unit`, the actual run-time representation uses immediate machine words for sufficiently-small numbers and an efficient arbitrary-precision arithmetic library for larger numbers.
The Lean compiler translates from definitions that use pattern matching into the appropriate operations for this representation, and calls to operations like addition and subtraction are mapped to fast operations from the underlying arithmetic library.
After all, addition should not take time linear in the size of the addends.
-->

しかし、このルールにはいくつかの重要な例外があります。いくつかの型はコンパイラによって特別に扱われます。例えば、`UInt32` 型は `Fin (2 ^ 32)` として定義されていますが、実行時には機械語に基づく実際のネイティブ実装に置き換えられます。同様に、`Nat` の定義が `List Unit` に似た実装を示唆している一方で、実際の実行時の表現においては、十分に小さい数には即座に機械語を使用し、大きい数には効率的な任意精度の算術ライブラリを使用します。Leanのコンパイラはパターンマッチを使用する定義をこの表現に適した演算に変換し、加算や減算のような演算の呼び出しには基礎となる算術ライブラリの高速な演算にマッピングされます。この結果、足し算は加算する値の大きさに比例して時間がかかるようなものになるべくもありません。

<!--
The fact that some types have special representations also means that care is needed when working with them.
Most of these types consist of a `structure` that is treated specially by the compiler.
With these structures, using the constructor or the field accessors directly can trigger an expensive conversion from an efficient representation to a slow one that is convenient for proofs.
For example, `String` is defined as a structure that contains a list of characters, but the run-time representation of strings uses UTF-8, not linked lists of pointers to characters.
Applying the constructor to a list of characters creates a byte array that encodes them in UTF-8, and accessing the field of the structure takes time linear in the length of the string to decode the UTF-8 representation and allocate a linked list.
Arrays are represented similarly.
From the logical perspective, arrays are structures that contain a list of array elements, but the run-time representation is a dynamically-sized array.
At run time, the constructor translates the list into an array, and the field accessor allocates a linked list from the array.
The various array operations are replaced with efficient versions by the compiler that mutate the array when possible instead of allocating a new one.
-->

いくつかの型が特別な表現を持っているということは、それらを扱う際に注意が必要だということでもあります。これらの型のほとんどは、コンパイラによって特別に扱われる `structure` からなります。これらの構造体では、コンストラクタやフィールドアクセサを直接使用すると効率的な表現から証明に便利な遅い表現への高価な変換が引き起こされる可能性があります。例えば、`String` は文字のリストを含む構造体として定義されていますが、文字列の実行時の表現ではUTF-8が使用され、文字へのポインタの連結リストは使用されません。文字のリストにコンストラクタを適用すると、UTF-8でエンコードされたバイト文字列が作成され、構造体のフィールドにアクセスすると、UTF-8表現をデコードして連結リストを割り当てるために、文字列に対して線形に時間がかかります。配列も同じように表現されます。論理的な観点からは、配列は配列要素を含む構造体ですが、実行時の表現は動的配列です。実行時にはコンストラクタがリストを配列に変換し、フィールドアクセサが配列から連結リストを割り当てます。さまざまな配列操作はコンパイラによって効率的なバージョンに置き換えられ、新しい配列を割り当てる代わりに可能な限り配列を更新するようにします。

<!--
Both types themselves and proofs of propositions are completely erased from compiled code.
In other words, they take up no space, and any computations that might have been performed as part of a proof are similarly erased.
This means that proofs can take advantage of the convenient interface to strings and arrays as inductively-defined lists, including using induction to prove things about them, without imposing slow conversion steps while the program is running.
For these built-in types, a convenient logical representation of the data does not imply that the program must be slow.
-->

型自体と命題の証明のどちらもコンパイルされたコードからは完全に消去されます。言い換えればそれらはスペースを取らず、証明の一部として実行されていただろう計算も同様に消去されます。つまり、証明はプログラム実行中に遅い変換ステップを課されることなく、帰納的に定義されたリストとしての文字列や配列に対して、帰納法による証明などの便利なインタフェースを利用することができます。これらの組み込み型では、データの便利な論理表現によって、プログラムが遅くなることはありません。

<!--
If a structure type has only a single non-type non-proof field, then the constructor itself disappears at run time, being replaced with its single argument.
In other words, a subtype is represented identically to its underlying type, rather than with an extra layer of indirection.
Similarly, `Fin` is just `Nat` in memory, and single-field structures can be created to keep track of different uses of `Nat`s or `String`s without paying a performance penalty.
If a constructor has no non-type non-proof arguments, then the constructor also disappears and is replaced with a constant value where the pointer would otherwise be used.
This means that `true`, `false`, and `none` are constant values, rather than pointers to heap-allocated objects.
-->

構造体型が非型で非証明のフィールドを1つだけ持つ場合、コンストラクタ自体が実行時に消滅し、その1つだけの引数に置き換えられます。つまり、部分型はその基本の型に対して間接的に参照する追加のレイヤーを持たずに、基本型と同じように表現されます。同様に、`Fin` はメモリ上では単なる `Nat` であり、`Nat` や `String` の異なる使用を追跡するための単一のフィールドを持つ構造体をパフォーマンスを落とすことなく作成することができます。コンストラクタに非型で非証明の引数が無い場合、コンストラクタも消滅し、ポインタが使用される定数値に置き換えられます。つまり、`true` ・`false` ・`none` はヒープに割り当てられたオブジェクトへのポインタではなく、定数値となります。

<!--
The following types have special representations:
-->

以下の型は特別な表現を持ちます：

<!--
| Type                                  | Logical representation                                                                | Run-time Representation                 |
|---------------------------------------|---------------------------------------------------------------------------------------|-----------------------------------------|
| `Nat`                                 | Unary, with one pointer from each `Nat.succ`                                          | Efficient arbitrary-precision integers  |
| `Int`                                 | A sum type with constructors for positive or negative values, each containing a `Nat` | Efficient arbitrary-precision integers  |
| `UInt8`, `UInt16`, `UInt32`, `UInt64` | A `Fin` with an appropriate bound                                                     | Fixed-precision machine integers        |
| `Char`                                | A `UInt32` paired with a proof that it's a valid code point                           | Ordinary characters                     |
| `String`                              | A structure that contains a `List Char` in a field called `data`                      | UTF-8-encoded string                    |
| `Array α`                             | A structure that contains a `List α` in a field called `data`                         | Packed arrays of pointers to `α` values |
| `Sort u`                              | A type                                                                                | Erased completely                       |
| Proofs of propositions                | Whatever data is suggested by the proposition when considered as a type of evidence   | Erased completely                       |
-->

| 型                                  | 論理的表現                                                                | 実行時の表現                 |
|---------------------------------------|---------------------------------------------------------------------------------------|-----------------------------------------|
| `Nat`                                 | 各 `Nat.succ` からのポインタを1つ持つ単項式                                          | 効率的な任意精度整数  |
| `Int`                                 | それぞれ `Nat` を含む正負のコンストラクタからなる直和型 | 効率的な任意精度整数  |
| `UInt8`, `UInt16`, `UInt32`, `UInt64` | それぞれの範囲に応じた `Fin`                                                     | 固定精度の機械整数        |
| `Char`                                | 正当なコードポイントであることの証明付きの `UInt32`                           | 通常の文字型                     |
| `String`                              | `List Char` 型で `data` という名前のフィールドを持つ構造体                      | UTF-8エンコードされた文字列                    |
| `Array α`                             | `List α` 型で `data` という名前のフィールドを持つ構造体                         | `α` 型の値へのポインタからなる配列 |
| `Sort u`                              | 型                                                                                | 完全に削除                       |
| 命題の証明                | データの中身が何であれ根拠の一種と見なされれば命題が示唆するもの何でも   | 完全に削除                       |

<!--
## Exercise
-->

## 演習問題

<!--
The [definition of `Pos`](../type-classes/pos.html) does not take advantage of Lean's compilation of `Nat` to an efficient type.
At run time, it is essentially a linked list.
Alternatively, a subtype can be defined that allows Lean's fast `Nat` type to be used internally, as described [in the initial section on subtypes](../functor-applicative-monad/applicative.md#subtypes).
At run time, the proof will be erased.
Because the resulting structure has only a single data field, it is represented as that field, which means that this new representation of `Pos` is identical to that of `Nat`.
-->

[`Pos` の定義](../type-classes/pos.html) はLeanが `Nat` を効率的な型にコンパイルすることを利用していません。実行時において、これは本質的に連結リストとなってしまいます。別の方法として、[部分型に関する最初の節](../functor-applicative-monad/applicative.md#subtypes) で説明したように、Leanの高速な `Nat` 型を内部で使用できるようにする部分型を定義することができます。実行時にはこの証明は消去されます。結果の構造体はたった一つのデータフィールドを持つため、これは `Pos` の新しい表現が `Nat` の表現と同じであることを意味します。

<!--
After proving the theorem `∀ {n k : Nat}, n ≠ 0 → k ≠ 0 → n + k ≠ 0`, define instances of `ToString`, and `Add` for this new representation of `Pos`. Then, define an instance of `Mul`, proving any necessary theorems along the way.
-->

定理 `∀ {n k : Nat}, n ≠ 0 → k ≠ 0 → n + k ≠ 0` を証明したのちに、この `Pos` の新しい表現への `ToString` と `Add` のインスタンスを定義してください。その次に、必要な定理を証明しながら `Mul` のインスタンスを定義してください。
