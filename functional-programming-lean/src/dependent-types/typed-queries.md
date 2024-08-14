<!--
# Worked Example: Typed Queries
-->

# 使用事例：型付きクエリ

<!--
Indexed families are very useful when building an API that is supposed to resemble some other language.
They can be used to write a library of HTML constructors that don't permit generating invalid HTML, to encode the specific rules of a configuration file format, or to model complicated business constraints.
This section describes an encoding of a subset of relational algebra in Lean using indexed families, as a simpler demonstration of techniques that can be used to build a more powerful database query language.
-->

添字族はほかの言語に似せたAPIを構築する際に非常に有用です。無効なHTMLの生成を許可しないHTML構築のライブラリを記述したり、設定ファイル形式の特定のルールをエンコードしたり、複雑なビジネス制約をモデル化したりするのに使用できます。この節では、このテクニックがより強力なデータベースクエリ言語を構築するために使えることの簡単なデモンストレーションとして、添字族を使用したLeanにおける関係代数のサブセットのエンコードについて説明します。

<!--
This subset uses the type system to enforce requirements such as disjointness of field names, and it uses type-level computation to reflect the schema into the types of values that are returned from a query.
It is not a realistic system, however—databases are represented as linked lists of linked lists, the type system is much simpler than that of SQL, and the operators of relational algebra don't really match those of SQL.
However, it is large enough to demonstrate useful principles and techniques.
-->

このサブセットではテーブル間で同じフィールド名が無いことなどの要件を強制するために型システムを使用し、クエリから返される値の型にスキーマを反映させるために型レベルの計算を使用します。しかし、これは現実的なシステムではありません。データベースは連結リストの連結リストとして表現され、型システムはSQLのものよりずっと単純であり、関係代数の演算子はSQLの演算子と一致しません。しかし、有用な原理やテクニックを示すには十分な規模です。

<!--
## A Universe of Data
-->

## データのユニバース

<!--
In this relational algebra, the base data that can be held in columns can have types `Int`, `String`, and `Bool` and are described by the universe `DBType`:
-->

この関係代数では、カラムに保持できる基本データは `Int` 、`String` 、`Bool` 型で `DBType` というユニバースで記述されます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean DBType}}
```

<!--
Using `asType` allows these codes to be used for types.
For example:
-->

`asType` を使用すると、これらのコードを型として使用することができます。例えば：

```lean
{{#example_in Examples/DependentTypes/DB.lean mountHoodEval}}
```
```output info
{{#example_out Examples/DependentTypes/DB.lean mountHoodEval}}
```

<!--
It is possible to compare the values described by any of the three database types for equality.
Explaining this to Lean, however, requires a bit of work.
Simply using `BEq` directly fails:
-->

3つのデータベースの型はどれで記述された値であっても同値性を比較することは可能です。しかし、このことをLeanに説明するには少し手間がかかります。`BEq` を直接使うだけでは失敗します：

```lean
{{#example_in Examples/DependentTypes/DB.lean dbEqNoSplit}}
```
```output info
{{#example_out Examples/DependentTypes/DB.lean dbEqNoSplit}}
```
<!--
Just as in the nested pairs universe, type class search doesn't automatically check each possibility for `t`'s value
The solution is to use pattern matching to refine the types of `x` and `y`:
-->

入れ子になったペアのユニバースと同じように、型クラスの検索では `t` の値の可能性を自動的にチェックすることができません。解決策は、パターンマッチを使って `x` と `y` の型を絞り込むことです：

```lean
{{#example_decl Examples/DependentTypes/DB.lean dbEq}}
```
<!--
In this version of the function, `x` and `y` have types `Int`, `String`, and `Bool` in the three respective cases, and these types all have `BEq` instances.
The definition of `dbEq` can be used to define a `BEq` instance for the types that are coded for by `DBType`:
-->

このバージョンの関数では、`x` と `y` はそれぞれ `Int` 、`String` 、`Bool` 型を持ち、これらの型すべてが `BEq` インスタンスを持っています。`dbEq` の定義では、`DBType` でコード化された型に対して `BEq` インスタンスを定義することができます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean BEqDBType}}
```
<!--
This is not the same as an instance for the codes themselves:
-->

これはコードによるインスタンスとは異なります：

```lean
{{#example_decl Examples/DependentTypes/DB.lean BEqDBTypeCodes}}
```
<!--
The former instance allows comparison of values drawn from the types described by the codes, while the latter allows comparison of the codes themselves.
 
-->

前者のインスタンスはコードによって記述された型から引き出された値の比較をしている一方で、後者はコード自体の比較しています。

<!--
A `Repr` instance can be written using the same technique.
The method of the `Repr` class is called `reprPrec` because it is designed to take things like operator precedence into account when displaying values.
Refining the type through dependent pattern matching allows the `reprPrec` methods from the `Repr` instances for `Int`, `String`, and `Bool` to be used:
-->

同じ手法で `Repr` インスタンスも書くことができます。`Repr` クラスのメソッドは値を表示する際に演算子の優先順位なども考慮にいれるよう設計されていることから `reprPrec` と呼ばれます。依存パターンマッチによって型を絞り込むことで、`Int` 、`String` 、`Bool` の `Repr` インスタンスから `reprPrec` メソッドを利用することができます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean ReprAsType}}
```

<!--
## Schemas and Tables
-->

## スキーマとテーブル

<!--
A schema describes the name and type of each column in a database:
-->

スキーマはデータベースの各カラムの名前と型を記述します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Schema}}
```
<!--
In fact, a schema can be seen as a universe that describes rows in a table.
The empty schema describes the unit type, a schema with a single column describes that value on its own, and a schema with at least two columns is represented by a tuple:
-->

実は、スキーマはテーブルの行を記述するユニバースと見なすことができます。空のスキーマはユニットタイプを、1つのカラムを持つスキーマはその値単独を、少なくとも2つのカラムを持つスキーマはタプルで表現されます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Row}}
```

<!--
As described in [the initial section on product types](../getting-to-know/polymorphism.md#Prod), Lean's product type and tuples are right-associative.
This means that nested pairs are equivalent to ordinary flat tuples.
-->

[直積型の最初の節](../getting-to-know/polymorphism.md#Prod) で説明したように、Leanの直積型とタプルは右結合です。つまり、入れ子になったペアは通常のフラットなタプルと等価です。

<!--
A table is a list of rows that share a schema:
-->

テーブルはスキーマを共有する行のリストです：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Table}}
```
<!--
For example, a diary of visits to mountain peaks can be represented with the schema `peak`:
-->

例えば、山頂の旅日記はスキーマ `peak` で表現することができます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean peak}}
```
<!--
A selection of peaks visited by the author of this book appears as an ordinary list of tuples:
-->

本書の著者が訪れた山頂セレクションは通常のタプルのリストとして表示されます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean mountainDiary}}
```
<!--
Another example consists of waterfalls and a diary of visits to them:
-->

別の例は滝とその旅日記です：

```lean
{{#example_decl Examples/DependentTypes/DB.lean waterfall}}

{{#example_decl Examples/DependentTypes/DB.lean waterfallDiary}}
```

<!--
### Recursion and Universes, Revisited
-->

### 再訪：再帰とユニバースについて

<!--
The convenient structuring of rows as tuples comes at a cost: the fact that `Row` treats its two base cases separately means that functions that use `Row` in their types and are defined recursively over the codes (that, is the schema) need to make the same distinctions.
One example of a case where this matters is an equality check that uses recursion over the schema to define a function that checks rows for equality.
This example does not pass Lean's type checker:
-->

行をタプルを使って便利に構造化することには次のような代償が伴います：すなわち `Row` が2つの基本ケースを別々に扱うということは、型に `Row` を使用しコード（つまりスキーマ）に対して再帰的に定義される関数も同じように区別する必要があるということです。このことが問題になるケースの一例として、スキーマに対する再帰を使用して行が等しいかどうかをチェックする関数を定義する同値チェックが挙げられます。以下の例はLeanの型チェッカを通過しません：

```lean
{{#example_in Examples/DependentTypes/DB.lean RowBEqRecursion}}
```
```output error
{{#example_out Examples/DependentTypes/DB.lean RowBEqRecursion}}
```
<!--
The problem is that the pattern `col :: cols` does not sufficiently refine the type of the rows.
This is because Lean cannot yet tell whether the singleton pattern `[col]` or the `col1 :: col2 :: cols` pattern in the definition of `Row` was matched, so the call to `Row` does not compute down to a pair type.
The solution is to mirror the structure of `Row` in the definition of `Row.bEq`:
-->

問題はパターン `col :: cols` が行の型を十分に絞り込めないことです。これはLeanが `Row` の定義にある要素が1つのパターン `[col]` と `col1 :: col2 :: cols` のどちらがマッチしたかを判断できないためで、`Row` の呼び出しはペアの型まで計算されません。解決策は `Row.bEq` の定義における `Row` の構造を鏡写しにすることです：

```lean
{{#example_decl Examples/DependentTypes/DB.lean RowBEq}}
```

<!--
Unlike in other contexts, functions that occur in types cannot be considered only in terms of their input/output behavior.
Programs that use these types will find themselves forced to mirror the algorithm used in the type-level function so that their structure matches the pattern-matching and recursive behavior of the type.
A big part of the skill of programming with dependent types is the selection of appropriate type-level functions with the right computational behavior.
-->

別の文脈とは異なり、型の中に出現する関数はその入出力の挙動だけから考察することはできません。このような型を使用するプログラムは、その構造が型のパターンマッチや再帰的な挙動と一致させるために型レベルの関数で使用されるアルゴリズムをそのまま映すことを強制されます。依存型を使ったプログラミングのスキルの大部分は適切な計算動作を持つ適切な型レベル関数を選定することが占めています。

<!--
### Column Pointers
-->

### カラムへのポインタ

<!--
Some queries only make sense if a schema contains a particular column.
For example, a query that returns mountains with an elevation greater than 1000 meters only makes sense in the context of a schema with a `"elevation"` column that contains integers.
One way to indicate that a column is contained in a schema is to provide a pointer directly to it, and defining the pointer as an indexed family makes it possible to rule out invalid pointers.
-->

クエリの中にはスキーマが特定のカラムを含んでいる場合にの意味を為すものがあります。例えば、標高が1000mを超える山を返すクエリは、整数からなるカラム `"elevation"` を持つスキーマでのみ意味を持ちます。あるカラムがスキーマに含まれていることを示す1つの方法は、そのカラムへのポインタを直接提供し、無効なポインタを除外するような添字族としてポインタを定義することです。

<!--
There are two ways that a column can be present in a schema: either it is at the beginning of the schema, or it is somewhere later in the schema.
Eventually, if a column is later in a schema, then it will be the beginning of some tail of the schema.
-->

あるカラムがスキーマに存在するには2つの方法があります：スキーマの先頭にあるか、その後続に存在するかです。結果的にカラムがスキーマの後続にある場合、それはスキーマの後続リストの先頭になります。

<!--
The indexed family `HasCol` is a translation of the specification into Lean code:
-->

`HasCol` 添字族はこの仕様をLeanの実装に翻訳したものです：

```lean
{{#example_decl Examples/DependentTypes/DB.lean HasCol}}
```
<!--
The family's three arguments are the schema, the column name, and its type.
All three are indices, but re-ordering the arguments to place the schema after the column name and type would allow the name and type to be parameters.
The constructor `here` can be used when the schema begins with the column `⟨name, t⟩`; it is thus a pointer to the first column in the schema that can only be used when the first column has the desired name and type.
The constructor `there` transforms a pointer into a smaller schema into a pointer into a schema with one more column on it.
-->

この族の3つの引数はスキーマ、カラム名、そしてその型です。3つとも添字ですが、引数を列名と型の後にスキーマが来るように並べ替えると、名前と型をパラメータにすることができます。コンストラクタ `here` はスキーマがカラム `⟨name, t⟩` から始まっている場合に使用できます；つまりこれはスキーマの最初のカラムへのポインタであり、最初のカラムが期待する名前と型を持つ場合にのみ使用できます。コンストラクタ `there` はある小さいスキーマへのポインタを、このスキーマに1つカラムを追加したスキーマへのポインタに変換します。

<!--
Because `"elevation"` is the third column in `peak`, it can be found by looking past the first two columns with `there`, after which it is the first column.
In other words, to satisfy the type `{{#example_out Examples/DependentTypes/DB.lean peakElevationInt}}`, use the expression `{{#example_in Examples/DependentTypes/DB.lean peakElevationInt}}`.
One way to think about `HasCol` is as a kind of decorated `Nat`—`zero` corresponds to `here`, and `succ` corresponds to `there`.
The extra type information makes it impossible to have off-by-one errors.
-->

`"elevation"` は `peak` の3番目のカラムであるため、最初の2カラムを `there` で通過することでこのカラムが先頭のカラムとなることで発見できます。言い換えると `{{#example_out Examples/DependentTypes/DB.lean peakElevationInt}}` という型を満たすには、`{{#example_in Examples/DependentTypes/DB.lean peakElevationInt}}` という式を使用します。`HasCol` は装飾された一種の `Nat` と考えることができるでしょう。`zero` は `here` 、`succ` は `there` にそれぞれ対応します。型情報が追加されたことで、off-by-oneエラーは発生しなくなります。

<!--
A pointer to a particular column in a schema can be used to extract that column's value from a row:
-->

あるスキーマの特定のカラムへのポインタによってそのカラムの値を行から抽出することができます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Rowget}}
```
<!--
The first step is to pattern match on the schema, because this determines whether the row is a tuple or a single value.
No case is needed for the empty schema because there is a `HasCol` available, and both constructors of `HasCol` specify non-empty schemas.
If the schema has just a single column, then the pointer must point to it, so only the `here` constructor of `HasCol` need be matched.
If the schema has two or more columns, then there must be a case for `here`, in which case the value is the first one in the row, and one for `there`, in which case a recursive call is used.
Because the `HasCol` type guarantees that the column exists in the row, `Row.get` does not need to return an `Option`.
-->

最初のステップはスキーマのパターンマッチです。というのも、これによって行がタプルか単一の値であるかが決定されるからです。`HasCol` が利用可能であり、`HasCol` のコンストラクタはどちらも空でないスキーマを指定しているため、空のスキーマに対するケースは不要です。もしスキーマにカラムが1つしかない場合、ポインタはそのカラムを指す必要があるため、`HasCol` の `here` コンストラクタのみをマッチさせる必要があります。スキーマに2つ以上列がある場合は、値が行の先頭にいる場合である `here` のケースと、再帰呼び出しが用いられる `there` のケースが必要です。`HasCol` 型はそのカラムが行に存在することを保証しているため、`Row.get` は `Option` を返す必要はありません。

<!--
`HasCol` plays two roles:
-->

`HasCol` は2つの役割を演じています：

 <!--
 1. It serves as _evidence_ that a column with a particular name and type exists in a schema.
 -->

 1. 特定の名前と型のカラムがスキーマに存在するという **根拠** としての機能。

 <!--
 2. It serves as _data_ that can be used to find the value associated with the column in a row.
 -->

 2. そのカラムに紐づく値を行から探すために用いられる **データ** としての機能。

<!--
The first role, that of evidence, is similar to way that propositions are used.
The definition of the indexed family `HasCol` can be read as a specification of what counts as evidence that a given column exists.
Unlike propositions, however, it matters which constructor of `HasCol` was used.
In the second role, the constructors are used like `Nat`s to find data in a collection.
Programming with indexed families often requires the ability to switch fluently between both perspectives.
-->

1つ目の役割である根拠は命題の使われ方と似ています。添字族 `HasCol` の定義は与えられたカラムが存在する根拠としてのキモの指定として読むことができます。しかし、命題とは異なり、`HasCol` のどのコンストラクタが使われたかは重要です。2つ目の役割として、コンストラクタは `Nat` のようにコレクション内のデータを見つけるために使用されます。添字族を使用したプログラミングでは、両方の視点を流暢に切り替える能力が必要である場合がよくあります。

<!--
### Subschemas
-->

### 副スキーマ

<!--
One important operation in relational algebra is to _project_ a table or row into a smaller schema.
Every column not present in the smaller schema is forgotten.
In order for projection to make sense, the smaller schema must be a subschema of the larger schema, which means that every column in the smaller schema must be present in the larger schema.
Just as `HasCol` makes it possible to write a single-column lookup in a row that cannot fail, a representation of the subschema relationship as an indexed family makes it possible to write a projection function that cannot fail.
-->

関係代数における重要な操作の1つとして、テーブルや行をより小さなスキーマにする **射影** （projection）があります。この小さくなったスキーマに含まれないすべてのカラムは忘れ去られます。射影が意味を持つためには、小さくなったスキーマは大きいスキーマの副スキーマでなければなりません。副スキーマとは小さくなったスキーマのすべてのカラムが大きいスキーマに存在していることを指します。`HasCol` によって失敗することのない行からの単一カラムの検索を書くことができるように、副スキーマの関係を添字族として表現することで失敗することのない射影関数を書くことができます。

<!--
The ways in which one schema can be a subschema of another can be defined as an indexed family.
The basic idea is that a smaller schema is a subschema of a bigger schema if every column in the smaller schema occurs in the bigger schema.
If the smaller schema is empty, then it's certainly a subschema of the bigger schema, represented by the constructor `nil`.
If the smaller schema has a column, then that column must be in the bigger schema, and all the rest of the columns in the subschema must also be a subschema of the bigger schema.
This is represented by the constructor `cons`.
-->

あるスキーマが別のスキーマの副スキーマになる方法は、添字族として定義できます。基本的な考え方は、小さい方のスキーマのカラムがすべて大きい方に含まれている場合に小さい方が大きい方の副スキーマであるというものです。もし小さい方のスキーマが空であれば、これは確実に大きい方の副スキーマとなります。これをコンストラクタ `nil` で表現します。もし小さい方のスキーマにカラムがある場合、そのカラムが大きい方に存在し、かつそれを除いたすべてのカラムからなる副スキーマも大きい方の副スキーマでなければなりません。これはコンストラクタ `cons` で表現されます。

```lean
{{#example_decl Examples/DependentTypes/DB.lean Subschema}}
```
<!--
In other words, `Subschema` assigns each column of the smaller schema a `HasCol` that points to its location in the larger schema.
-->

言い換えると、`Subschema` は小さい方のスキーマの各カラムに大きい方のスキーマでの位置を表す `HasCol` を割り当てます。

<!--
The schema `travelDiary` represents the fields that are common to both `peak` and `waterfall`:
-->

スキーマ `travelDiary` は `peak` と `waterfall` の両方に共通するフィールドを表します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean travelDiary}}
```
<!--
It is certainly a subschema of `peak`, as shown by this example:
-->

これは明らかに `peak` の副スキーマで、次の例のように示されます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean peakDiarySub}}
```
<!--
However, code like this is difficult to read and difficult to maintain.
One way to improve it is to instruct Lean to write the `Subschema` and `HasCol` constructors automatically.
This can be done using the tactic feature that was introduced in [the Interlude on propositions and proofs](../props-proofs-indexing.md).
That interlude uses `by simp` to provide evidence of various propositions.
-->

しかし、このようなコードは読みにくく、保守も難しいです。これを改善する一つの方法は、`Subschema` と `HasCol` のコンストラクタを自動的に書くようにLeanに指示することです。これは [命題と証明に関する幕間](../props-proofs-indexing.md) で紹介したタクティク機能を使って行うことができます。その幕間では `by simp` を使って様々な命題の根拠を提供しました。

<!--
In this context, two tactics are useful:
-->

今回の文脈では、2つのタクティクが有効です：

 <!--
 * The `constructor` tactic instructs Lean to solve the problem using the constructor of a datatype.
 -->
 * `constructor` タクティクは、データ型のコンストラクタを使って問題を解決するようLeanに指示します。
 <!--
 * The `repeat` tactic instructs Lean to repeat a tactic over and over until it either fails or the proof is finished.
 -->
 * `repeat` タクティクは受け取ったタクティクを失敗するか証明が完了するまで何度も繰り返すよう指示します。

<!--
In the next example, `by constructor` has the same effect as just writing `.nil` would have:
-->

次の例では、`by constructor` は `.nil` と書くのと同じ効果があります：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean emptySub}}
```
<!--
However, attempting that same tactic with a slightly more complicated type fails:
-->

しかし、ちょっとでも複雑なもので同じタクティクを試すと失敗します：

```leantac
{{#example_in Examples/DependentTypes/DB.lean notDone}}
```
```output error
{{#example_out Examples/DependentTypes/DB.lean notDone}}
```
<!--
Errors that begin with `unsolved goals` describe tactics that failed to completely build the expressions that they were supposed to.
In Lean's tactic language, a _goal_ is a type that a tactic is to fulfill by constructing an appropriate expression behind the scenes.
In this case, `constructor` caused `Subschema.cons` to be applied, and the two goals represent the two arguments expected by `cons`.
Adding another instance of `constructor` causes the first goal (`HasCol peak \"location\" DBType.string`) to be addressed with `HasCol.there`, because `peak`'s first column is not `"location"`:
-->

`unsolved goals` から始まるエラーはタクティクが想定した式を完全に構築できなかったことを表します。Leanのタクティク言語では、**ゴール** （goal）はタクティクが裏で適切な式を構築することで満たすべき型を指します。この場合、`constructor` によって `Subschema.cons` が適用と `cons` が期待する2つの引数を表す2つのゴールが発生します。もう1つ `constructor` のインスタンスを追加すると、最初のゴール（`HasCol peak \"location\" DBType.string`）は `peak` の最初のカラムが `"location"` ではないことから `HasCol.there` で処理されます：

```leantac
{{#example_in Examples/DependentTypes/DB.lean notDone2}}
```
```output error
{{#example_out Examples/DependentTypes/DB.lean notDone2}}
```
<!--
However, adding a third `constructor` results in the first goal being solved, because `HasCol.here` is applicable:
-->

しかし、3つ目の `constructor` を追加すると、`HasCol.here` が適用されるため、1つ目のゴールが解決されます：

```leantac
{{#example_in Examples/DependentTypes/DB.lean notDone3}}
```
```output error
{{#example_out Examples/DependentTypes/DB.lean notDone3}}
```
<!--
A fourth instance of `constructor` solves the `Subschema peak []` goal:
-->

4つ目の `constructor` のインスタンスによってゴール `Subschema peak []` が解決されます：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean notDone4}}
```
<!--
Indeed, a version written without the use of tactics has four constructors:
-->

実際に、タクティクを使わずに書いたものにも4つのコンストラクタが存在します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean notDone5}}
```

<!--
Instead of experimenting to find the right number of times to write `constructor`, the `repeat` tactic can be used to ask Lean to just keep trying `constructor` as long as it keeps making progress:
-->

`constructor` の適切な書く回数を試して見つける代わりに、`repeat` タクティクを使うことで `constructor` が機能しつづける限り試し続けるようにLeanに依頼することができます：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean notDone6}}
```
<!--
This more flexible version also works for more interesting `Subschema` problems:
-->

この柔軟なバージョンはより興味のある `Subschema` の問題にも対応します：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean subschemata}}
```

<!--
The approach of blindly trying constructors until something works is not very useful for types like `Nat` or `List Bool`.
Just because an expression has type `Nat` doesn't mean that it's the _correct_ `Nat`, after all.
But types like `HasCol` and `Subschema` are sufficiently constrained by their indices that only one constructor will ever be applicable, which means that the contents of the program itself are less interesting, and a computer can pick the correct one.
-->

うまくいくまでやみくもにコンストラクタを試すアプローチは `Nat` や `List Bool` のような型にはあまり役に立ちません。これは式が `Nat` 型を持っているからと言っても、結局のところそれが **正しい** `Nat` であるとは限らないからです。しかし `HasCol` や `Subschema` のような型では添字によって十分制約されているため、コンストラクタはただ1つしか適用できません。これはそのプログラムの中身自体にはあまり面白みがなく、コンピュータは正しいものを選ぶことができるということです。

<!--
If one schema is a subschema of another, then it is also a subschema of the larger schema extended with an additional column.
This fact can be captured as a function definition.
`Subschema.addColumn` takes evidence that `smaller` is a subschema of `bigger`, and then returns evidence that `smaller` is a subschema of `c :: bigger`, that is, `bigger` with one additional column:
-->

あるスキーマが別のスキーマの副スキーマである場合、大きい方のスキーマにカラムを追加して拡張したより大きなスキーマの副スキーマでもあります。この事実は関数定義として捉えることができます。`Subschema.addColumn` は `smaller` が `bigger` の副スキーマである根拠を取り、`smaller` が `c :: bigger` 、すなわちカラムが追加された `bigger` の副スキーマであるという根拠を返します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean SubschemaAdd}}
```
<!--
A subschema describes where to find each column from the smaller schema in the larger schema.
`Subschema.addColumn` must translate these descriptions from the original larger schema into the extended larger schema.
In the `nil` case, the smaller schema is `[]`, and `nil` is also evidence that `[]` is a subschema of `c :: bigger`.
In the `cons` case, which describes how to place one column from `smaller` into `larger`, the placement of the column needs to be adjusted with `there` to account for the new column `c`, and a recursive call adjusts the rest of the columns.
-->

副スキーマは小さい方のスキーマの各カラムが大きい方のどこにあるかを記述します。`Subschema.addColumn` はこれらの記述をもとの大きいスキーマから拡張されたスキーマへ変換しなければなりません。`nil` の場合、小さい方のスキーマは `[]` であり、また `nil` は `[]` が `c :: bigger` の副スキーマである根拠でもあります。`cons` 、つまり `smaller` のあるカラムを `bigger` に配置する方法を記述したケースの場合、そのカラムを配置するには新しいカラム `c` を考慮するために `there` でカラムの位置を調節する必要があります。そして再帰呼び出しで残りのカラムを調整します。

<!--
Another way to think about `Subschema` is that it defines a _relation_ between two schemas—the existence of an expression  with type `Subschema bigger smaller` means that `(bigger, smaller)` is in the relation.
This relation is reflexive, meaning that every schema is a subschema of itself:
-->

`Subschema` の別の考え方はこれが2つのスキーマの **関係** を定義しているというものです。つまり `Subschema bigger smaller` 型の式が存在するということは、`(bigger, smaller)` がその関係にあるということです。この関係は反射的であり、すべてのスキーマはそれ自身の副スキーマであることを意味します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean SubschemaSame}}
```


<!--
### Projecting Rows
-->

### 行の射影

<!--
Given evidence that `s'` is a subschema of `s`, a row in `s` can be projected into a row in `s'`.
This is done using the evidence that `s'` is a subschema of `s`, which explains where each column of `s'` is found in `s`.
The new row in `s'` is built up one column at a time by retrieving the value from the appropriate place in the old row.
-->

`s'` が `s` の副スキーマであるという根拠をもとに、`s` の行を `s'` の行に射影することができます。これは `s'` が `s` の副スキーマであるという根拠を用いて行われ、`s'` の各列が `s` のどこにあるかを説明します。`s'` の新しい行は、古い行の適切な位置から値を取り出すことで1列ずつ構築されます。

<!--
The function that performs this projection, `Row.project`, has three cases, one for each case of `Row` itself.
It uses `Row.get` together with each `HasCol` in the `Subschema` argument to construct the projected row:
-->

この射影を行う関数 `Row.project` には3つの場合分けが存在しており、それぞれ `Row` 自体のケースに対応しています。`Row.get` と `Subschema` の引数の各 `HasCol` を使用して射影された行を構築します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean RowProj}}
```


<!--
## Conditions and Selection
-->

## 条件と選択

<!--
Projection removes unwanted columns from a table, but queries must also be able to remove unwanted rows.
This operation is called _selection_.
Selection relies on having a means of expressing which rows are desired.
-->

射影はテーブルから不要な列を除外しますが、クエリでは不要な行も除外できなければなりません。この操作は　**選択** （selection）と呼ばれます。選択はどの行が必要かを表現する手段があることが前提になります。

<!--
The example query language contains expressions, which are analogous to what can be written in a `WHERE` clause in SQL.
Expressions are represented by the indexed family `DBExpr`.
Because expressions can refer to columns from the database, but different sub-expressions all have the same schema, `DBExpr` takes the database schema as a parameter.
Additionally, each expression has a type, and these vary, making it an index:
-->

今回のクエリ言語の例ではSQLの `WHERE` 節で記述するものと同じような式を持ちます。式は添字族 `DBExpr` で表現されます。式はデータベースのカラムを参照することができますが、式内の異なる部分式はすべて同じスキーマを持つため、`DBExpr` はスキーマをパラメータとして受け取ります。さらに、各式には型があり、それが変化することで添字になります：

```lean
{{#example_decl Examples/DependentTypes/DB.lean DBExpr}}
```
<!--
The `col` constructor represents a reference to a column in the database.
The `eq` constructor compares two expressions for equality, `lt` checks whether one is less than the other, `and` is Boolean conjunction, and `const` is a constant value of some type.
-->

`col` コンストラクタはデータベースのカラムへの参照を表します。`eq` コンストラクタは2つの式の同値を確かめ、`lt` は片方の式がもう片方未満であることをチェック、`and` は論理積、`const` は何らかの型の定数値を表します。

<!--
For example, an expression in `peak` that checks whether the `elevation` column is greater than 1000 and the location is `"Denmark"` can be written:
-->

例えば `peak` の式として、`elevation` カラムが1000より大きく、かつその場所が `"Denmark"` であることをチェックするものは次のように書けます：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean tallDk}}
```
<!--
This is somewhat noisy.
In particular, references to columns contain boilerplate calls to `by repeat constructor`.
A Lean feature called _macros_ can help make expressions easier to read by eliminating this boilerplate:
-->

これはやや煩雑です。特に、カラムへの参照に `by repeat constructor` の定型的な呼び出しが含まれています。**マクロ** （macro）と呼ばれるLeanの機能によってこのような定型文を排除することで式を読みやすくしてくれます：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean cBang}}
```
<!--
This declaration adds the `c!` keyword to Lean, and instructs Lean to replace any instance of `c!` followed by an expression with the corresponding `DBExpr.col` construction.
Here, `term` stands for Lean expressions, rather than commands, tactics, or some other part of the language.
Lean macros are a bit like C preprocessor macros, except they are better integrated into the language and they automatically avoid some of the pitfalls of CPP.
In fact, they are very closely related to macros in Scheme and Racket.
-->

この宣言は `c!` というキーワードをLeanに追加し、`c!` のインスタンスに続く式を、対応する `DBExpr.col` 構文で置き換えるように指示しています。ここで、`term` はLeanの式を表しており、コマンドやタクティクなどの言語の一部を表しているわけではありません。LeanのマクロはC言語のプリプロセッサマクロ（CPP）に少し似ていますが、言語への統合が進んでおり、CPPの落とし穴のいくつかを自動的に避けることができます。実は、このマクロはSchemeやRacketのマクロと非常に密接な関係があります。

<!--
With this macro, the expression can be much easier to read:
-->

このマクロを使うと、式はもっと読みやすくなります：

```lean
{{#example_decl Examples/DependentTypes/DB.lean tallDkBetter}}
```

<!--
Finding the value of an expression with respect to a given row uses `Row.get` to extract column references, and it delegates to Lean's operations on values for every other expression:
-->

与えられた行に対応する式の値を見つけるには、`Row.get` を使用してカラム参照を抽出し、他のすべての式の値に関するLeanの操作に委譲します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean DBExprEval}}
```

<!--
Evaluating the expression for Valby Bakke, the tallest hill in the Copenhagen area, yields `false` because Valby Bakke is much less than 1 km over sea level:
-->

コペンハーゲン地域で最も高い丘であるValby Bakkeについての式を評価すると、Valby Bakkeの標高は海抜1km未満であるため `false` が返されます：

```lean
{{#example_in Examples/DependentTypes/DB.lean valbybakke}}
```
```output info
{{#example_out Examples/DependentTypes/DB.lean valbybakke}}
```
<!--
Evaluating it for a fictional mountain of 1230m elevation yields `true`:
-->

これを標高1230mの架空の山で評価すると `true` が返されます：

```lean
{{#example_in Examples/DependentTypes/DB.lean fakeDkBjerg}}
```
```output info
{{#example_out Examples/DependentTypes/DB.lean fakeDkBjerg}}
```
<!--
Evaluating it for the highest peak in the US state of Idaho yields `false`, as Idaho is not part of Denmark:
-->

アメリカのアイダホ州の最高峰で評価すると、アイダホはデンマークの一部ではないため、`false` が返されます：

```lean
{{#example_in Examples/DependentTypes/DB.lean borah}}
```
```output info
{{#example_out Examples/DependentTypes/DB.lean borah}}
```

<!--
## Queries
-->

## クエリ

<!--
The query language is based on relational algebra.
In addition to tables, it includes the following operators:
-->

クエリ言語は関係代数に基づいています。テーブルに加え、以下の演算子があります：

 <!--
 1. The union of two expressions that have the same schema combines the rows that result from two queries
 -->
 1. 2つのクエリの結果を結合する2つの式の和
 <!--
 2. The difference of two expressions that have the same schema removes rows found in the second result from the rows in the first result
 -->
 2. 同じスキーマを持つ2つの式において、最初の結果から2番目の結果の行を削除する差
 <!--
 3. Selection by some criterion filters the result of a query according to an expression
 -->
 3. 何らかの基準で式に従ってクエリの結果をフィルタリングする選択
 <!--
 4. Projection into a subschema, removing columns from the result of a query
 -->
 4. クエリの結果からカラムを取り除く副スキーマへの射影
 <!--
 5. Cartesian product, combining every row from one query with every row from another
 -->
 5. 直積、あるクエリのすべての行と別のクエリのすべての行を結合します
 <!--
 6. Renaming a column in the result of a query, which modifies its schema
 -->
 6. クエリ結果のカラム名の属性名変更、これはカラムのスキーマを変更します
 <!--
 7. Prefixing all columns in a query with a name
 -->
 7. クエリ内のすべてのカラムに名前を前置する
 
<!--
The last operator is not strictly necessary, but it makes the language more convenient to use.
-->

厳密には最後の演算子は必要ではありませんが、言語をより便利に使うことができます。

<!--
Once again, queries are represented by an indexed family:
-->

繰り返しになりますが、クエリは添字族で表現されます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Query}}
```
<!--
The `select` constructor requires that the expression used for selection return a Boolean.
The `product` constructor's type contains a call to `disjoint`, which ensures that the two schemas don't share any names:
-->

`select` コンストラクタでは、選択に使用する式がブール値を返す必要があります。`product` コンストラクタの型には `disjoint` が含まれており、これにより2つのスキーマが同じ名前を持たないことが保証されます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean disjoint}}
```
<!--
The use of an expression of type `Bool` where a type is expected triggers a coercion from `Bool` to `Prop`.
Just as decidable propositions can be considered to be Booleans, where evidence for the proposition is coerced to `true` and refutations of the proposition are coerced to `false`, Booleans are coerced into the proposition that states that the expression is equal to `true`.
Because all uses of the library are expected to occur in contexts where the schemas are known ahead of time, this proposition can be proved with `by simp`.
Similarly, the `renameColumn` constructor checks that the new name does not already exist in the schema.
It uses the helper `Schema.renameColumn` to change the name of the column pointed to by `HasCol`:
-->

型が期待されるところで `Bool` 型の式を使用すると、`Bool` から `Prop` への強制が発火します。命題の根拠が `true` に、命題の反論が `false` にそれぞれ強制されることから決定可能な命題を真偽値と見なすことができるように、真偽値はその式が `true` に等しいことを述べる命題へと強制されます。このライブラリのすべての使用ケースはスキーマがあらかじめ分かっているコンテキストにおいて発生すると考えられるため、この命題は `by simp` で証明することができます。同様に、`renameColumn` コンストラクタは変更予定の新しい名前がスキーマにすでに存在しないことをチェックします。ここでは補助関数 `Schema.renameColumn` を使用して、`HasCol` が指すカラムの名前を変更します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean renameColumn}}
```

<!--
## Executing Queries
-->

## クエリの実行

<!--
Executing queries requires a number of helper functions.
The result of a query is a table; this means that each operation in the query language requires a corresponding implementation that works with tables.
-->

クエリを実行するにはいくつかの補助関数が必要です。クエリの結果はテーブルです；これはつまりクエリ言語の各操作にはテーブルに対応した実装が必要だということです。

<!--
### Cartesian Product
-->

### 直積

<!--
Taking the Cartesian product of two tables is done by appending each row from the first table to each row from the second.
First off, due to the structure of `Row`, adding a single column to a row requires pattern matching on its schema in order to determine whether the result will be a bare value or a tuple.
Because this is a common operation, factoring the pattern matching out into a helper is convenient:
-->

2つのテーブルの直積を取るには、1つ目のテーブルの各行を2つ目のテーブルの各行に追加します。まず、`Row` の構造上、行に1つのカラムを追加する場合にスキーマに対して追加結果が素の値かタプルであるかを決定するためのパターンマッチが必要になります。これは一般的な操作であるため、パターンマッチを補助関数にまとめると便利です：

```lean
{{#example_decl Examples/DependentTypes/DB.lean addVal}}
```
<!--
Appending two rows is recursive on the structure of both the first schema and the first row, because the structure of the row proceeds in lock-step with the structure of the schema.
When the first row is empty, appending returns the second row.
When the first row is a singleton, the value is added to the second row.
When the first row contains multiple columns, the first column's value is added to the result of recursion on the remainder of the row.
-->

2つの行を追加するには1つ目のスキーマと1つ目の行の構造に対しての再帰が必要です。というのも、行の構造はスキーマの構造と同期して進むからです。最初の行が空の場合、追加結果として2つ目の行が返されます。最初の行が単一の値の場合、その値が2つ目の行に追加されます。最初の行が複数の列を含む場合、最初の列の値は、残りの行に対する再帰の結果に追加されます。

```lean
{{#example_decl Examples/DependentTypes/DB.lean RowAppend}}
```

<!--
`List.flatMap` applies a function that itself returns a list to every entry in an input list, returning the result of appending the resulting lists in order:
-->

`List.flatMap` は入力リストの各要素に対してリストを返す関数を適用し、その結果のリストを順番に追加した結果を返します：

```lean
{{#example_decl Examples/DependentTypes/DB.lean ListFlatMap}}
```
<!--
The type signature suggests that `List.flatMap` could be used to implement a `Monad List` instance.
Indeed, together with `pure x := [x]`, `List.flatMap` does implement a monad.
However, it's not a very useful `Monad` instance.
The `List` monad is basically a version of `Many` that explores _every_ possible path through the search space in advance, before users have the chance to request some number of values.
Because of this performance trap, it's usually not a good idea to define a `Monad` instance for `List`.
Here, however, the query language has no operator for restricting the number of results to be returned, so combining all possibilities is exactly what is desired:
-->

この型シグネチャは `List.flatMap` が `Monad List` のインスタンスを実装するのに使えることを示唆しています。実際に、`pure x := [x]` と共に `List.flatMap` でモナドが実装されています。しかし、これはあまり便利な `Monad` インスタンスではありません。`List` モナドは基本的に `Many` の亜種であり、ユーザがいくつかの値を要求する前に、探索空間を通して可能な **すべて** のパスを探索します。このようなパフォーマンスの罠があるため、通常 `List` 用の `Monad` インスタンスを定義するのは良い考えとは言えません。しかし、ここではクエリ言語には返される結果の数を制限する演算子がないため、すべての可能性を組み合わせることが望まれます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean TableCartProd}}
```

<!--
Just as with `List.product`, a loop with mutation in the identity monad can be used as an alternative implementation technique:
-->

`List.product` と同じように、別の実装方法として恒等モナドで変更を伴うループを使うことができます：

```lean
{{#example_decl Examples/DependentTypes/DB.lean TableCartProdOther}}
```


<!--
### Difference
-->

### 差

<!--
Removing undesired rows from a table can be done using `List.filter`, which takes a list and a function that returns a `Bool`.
A new list is returned that contains only the entries for which the function returns `true`.
For instance,
-->

テーブルから不要な行を除外するには、リストと `Bool` を返す関数を受け取る `List.filter` を使って行えます。これによって関数が `true` を返す要素のみを含む新しいリストが返されます。例えば、

```lean
{{#example_in Examples/DependentTypes/DB.lean filterA}}
```
<!--
evaluates to
-->

は以下のように評価されます。

```lean
{{#example_out Examples/DependentTypes/DB.lean filterA}}
```
<!--
because `"Columbia"` and `"Sandy"` have lengths less than or equal to `8`.
Removing the entries of a table can be done using the helper `List.without`:
-->

これは `"Columbia"` と `"Sandy"` の長さが `8` 以下であるからです。テーブルの要素を除外するには補助関数 `List.without` を使います：

```lean
{{#example_decl Examples/DependentTypes/DB.lean ListWithout}}
```
<!--
This will be used with the `BEq` instance for `Row` when interpreting queries.
-->

クエリを解釈する際に、これは `Row` に対する `BEq` インスタンスと共に使用されます。

<!--
### Renaming Columns
-->

### 属性名変更

<!--
Renaming a column in a row is done with a recursive function that traverses the row until the column in question is found, at which point the column with the new name gets the same value as the column with the old name:
-->

行の属性名変更は再帰関数で行われ、該当のカラムが見つかるまで行を走査し、その時点で新しい名前のカラムは古い名前のカラムと同じ値になります：

```lean
{{#example_decl Examples/DependentTypes/DB.lean renameRow}}
```
<!--
While this function changes the _type_ of its argument, the actual return value contains precisely the same data as the original argument.
From a run-time perspective, `renameRow` is nothing but a slow identity function.
One difficulty in programming with indexed families is that when performance matters, this kind of operation can get in the way.
It takes a very careful, often brittle, design to eliminate these kinds of "re-indexing" functions.
-->

この関数は引数の **型** を変更しますが、実際の戻り値には元の引数とまったく同じデータを含みます。実行時においては、`renameRow` はただ遅いだけの恒等関数でしかありません。添字族を使用したプログラミングの難しさの1つは、パフォーマンスが重要な場合にこの種の操作が邪魔になることです。このような「再インデックス」関数を排除するには、とても注意深く、時に脆い設計が必要です。

<!--
### Prefixing Column Names
-->

### カラム名への接頭辞の付与

<!--
Adding a prefix to column names is very similar to renaming a column.
Instead of proceeding to a desired column and then returning, `prefixRow` must process all columns:
-->

カラム名に接頭辞を追加することは、属性名変更と非常に似ています。`prefixRow` は希望するカラムのみ処理して戻るのではなく、すべてのカラムに対して処理しなければなりません：

```lean
{{#example_decl Examples/DependentTypes/DB.lean prefixRow}}
```
<!--
This can be used with `List.map` in order to add a prefix to all rows in a table.
Once again, this function only exists to change the type of a value.
-->

これは `List.map` と一緒に使うことでテーブルのすべての行に接頭辞を追加することができます。繰り返しになりますが、この関数は値の型を変更するためだけに存在します。

<!--
### Putting the Pieces Together
-->

### ピースをひとつにまとめる

<!--
With all of these helpers defined, executing a query requires only a short recursive function:
-->

これらの補助関数がすべて定義されたなら、クエリを実行するのに必要なのは短い再帰関数だけです：

```lean
{{#example_decl Examples/DependentTypes/DB.lean QueryExec}}
```
<!--
Some arguments to the constructors are not used during execution.
In particular, both the constructor `project` and the function `Row.project` take the smaller schema as explicit arguments, but the type of the _evidence_ that this schema is a subschema of the larger schema contains enough information for Lean to fill out the argument automatically.
Similarly, the fact that the two tables have disjoint column names that is required by the `product` constructor is not needed by `Table.cartesianProduct`.
Generally speaking, dependent types provide many opportunities to have Lean fill out arguments on behalf of the programmer.
-->

コンストラクタの引数の中には実行時に使用されないものもあります。特に、コンストラクタ `project` と関数 `Row.project` は小さい方のスキーマを明示的な引数として受け取りますが、このスキーマが大きい方の副スキーマであるという **根拠** の型にはLeanが自動的に引数を埋めるために十分な情報が含まれています。同様に、`product` コンストラクタで必要とされる2つのテーブルが同じカラム名を持たないという事実は `Table.cartesianProduct` では必要ありません。一般的に、依存型はLeanがプログラマの代わりに引数を埋めるための機会を多く提供します。

<!--
Dot notation is used with the results of queries to call functions defined both in the `Table` and `List` namespaces, such `List.map`, `List.filter`, and `Table.cartesianProduct`.
This works because `Table` is defined using `abbrev`.
Just like type class search, dot notation can see through definitions created with `abbrev`. 
-->

ドット記法は `List.map` や `List.filter` 、`Table.cartesianProduct` などの `Table` と `List` の両方の名前空間で定義された関数を呼び出すクエリの結果で使用されます。これは `Table` が `abbrev` を使って定義されているためです。型クラス検索と同じように、ドット記法は `abbrev` で作成された定義を見抜くことができます。

<!--
The implementation of `select` is also quite concise.
After executing the query `q`, `List.filter` is used to remove the rows that do not satisfy the expression.
Filter expects a function from `Row s` to `Bool`, but `DBExpr.evaluate` has type `Row s → DBExpr s t → t.asType`.
Because the type of the `select` constructor requires that the expression have type `DBExpr s .bool`, `t.asType` is actually `Bool` in this context.
-->

`select` の実装も非常に簡潔です。クエリ `q` を実行した後、`List.filter` を使用して式を満たさない行を除外します。フィルタには `Row s` から `Bool` への関数が期待されますが、`DBExpr.evaluate` の型は `Row s → DBExpr s t → t.asType` です。`select` コンストラクタの型は式が `DBExpr s .bool` 型であることを要求するため、`t.asType` はこのコンテキストでは `Bool` となります。

<!--
A query that finds the heights of all mountain peaks with an elevation greater than 500 meters can be written:
-->

標高が500mを超えるすべての山の高さを求めるクエリは次のように書くことができます：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean Query1}}
```

<!--
Executing it returns the expected list of integers:
-->

これを実行すると、期待通り整数のリストが返されます：

```lean
{{#example_in Examples/DependentTypes/DB.lean Query1Exec}}
```
```output info
{{#example_out Examples/DependentTypes/DB.lean Query1Exec}}
```

<!--
To plan a sightseeing tour, it may be relevant to match all pairs mountains and waterfalls in the same location.
This can be done by taking the Cartesian product of both tables, selecting only the rows in which they are equal, and then projecting out the names:
-->

観光ツアーを計画するためには、ある山と滝のペアをすべて同じ場所に合わせることが妥当かもしれません。これは両方のテーブルの直積を取り、それらが等しい行だけを選び、名前を射影することで実現されます：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean Query2}}
```
<!--
Because the example data includes only waterfalls in the USA, executing the query returns pairs of mountains and waterfalls in the US:
-->

例で挙げたデータにはアメリカの滝だけが含まれているため、クエリを実行するとアメリカの山と滝のペアが返されます：

```lean
{{#example_in Examples/DependentTypes/DB.lean Query2Exec}}
```
```output info
{{#example_out Examples/DependentTypes/DB.lean Query2Exec}}
```

<!--
### Errors You May Meet
-->

### 見るかもしれないエラー

<!--
Many potential errors are ruled out by the definition of `Query`.
For instance, forgetting the added qualifier in `"mountain.location"` yields a compile-time error that highlights the column reference `c! "location"`:
-->

多くの潜在的なエラーは `Query` の定義によって除外されます。例えば、`"mountain.location"` に追加された修飾子を忘れると、コンパイル時にエラーが発生し、`c! "location"` がハイライト表示されます：

```leantac
{{#example_in Examples/DependentTypes/DB.lean QueryOops1}}
```
<!--
This is excellent feedback!
On the other hand, the text of the error message is quite difficult to act on:
-->

これは素晴らしいフィードバックです！一方でエラーメッセージの文面から対処法を決めるのはかなり難しいです：

```output error
{{#example_out Examples/DependentTypes/DB.lean QueryOops1}}
```

<!--
Similarly, forgetting to add prefixes to the names of the two tables results in an error on `by simp`, which should provide evidence that the schemas are in fact disjoint;
-->

同じように、2つのテーブルの名前に接頭辞をつけ忘れると、スキーマに同じフィールド名が無いことの根拠を提供すべきところの `by simp` でエラーになります：

```leantac
{{#example_in Examples/DependentTypes/DB.lean QueryOops2}}
```
<!--
However, the error message is similarly unhelpful:
-->

しかし、このエラーメッセージも同じように役に立ちません：

```output error
{{#example_out Examples/DependentTypes/DB.lean QueryOops2}}
```

<!--
Lean's macro system contains everything needed not only to provide a convenient syntax for queries, but also to arrange for the error messages to be helpful.
Unfortunately, it is beyond the scope of this book to provide a description of implementing languages with Lean macros.
An indexed family such as `Query` is probably best as the core of a typed database interaction library, rather than its user interface.
-->

Leanのマクロシステムには、クエリに便利な構文を提供するだけでなく、エラーメッセージが有用になるようアレンジするために必要なものもすべて含まれています。残念ながら、Leanマクロを使った言語の実装について説明するのは本書の範囲を超えています。`Query` のような添字族はユーザインタフェースというよりは、型付きデータベースの対話ライブラリのコアとして使うことがベストでしょう。

<!--
## Exercises
-->

## 演習問題

<!--
### Dates
-->

### データ

<!--
Define a structure to represent dates. Add it to the `DBType` universe and update the rest of the code accordingly. Provide the extra `DBExpr` constructors that seem to be necessary.
-->

日付を表す構造体を定義してください。それを `DBType` ユニバースに追加し、それに合わせて残りの実装を更新してください。必要と思われる `DBType` のコンストラクタも追加してください。

<!--
### Nullable Types
-->

### nullable型

<!--
Add support for nullable columns to the query language by representing database types with the following structure:
-->

次のような構造体でデータベースの型を表現することで、クエリ言語にnullableなカラムのサポートを追加してください：

```lean
structure NDBType where
  underlying : DBType
  nullable : Bool

abbrev NDBType.asType (t : NDBType) : Type :=
  if t.nullable then
    Option t.underlying.asType
  else
    t.underlying.asType
```

<!--
Use this type in place of `DBType` in `Column` and `DBExpr`, and look up SQL's rules for `NULL` and comparison operators to determine the types of `DBExpr`'s constructors.
-->

この型を `DBType` と `Column` の中の `DBType` と置き換え、`DBType` のコンストラクタの型を決定するために `NULL` と比較演算子に関するSQLのルールを探索してください。

<!--
### Experimenting with Tactics
-->

### タクティクの実験

<!--
What is the result of asking Lean to find values of the following types using `by repeat constructor`? Explain why each gives the result that it does.
-->

Leanに `by repeat constructor` を使って以下の型の値を求めるとどのような結果になるでしょうか？それぞれがなぜその結果になるのかを説明してください。

 * `Nat`
 * `List Nat`
 * `Vect Nat 4`
 * `Row []`
 * `Row [⟨"price", .int⟩]`
 * `Row peak`
 * `HasCol [⟨"price", .int⟩, ⟨"price", .int⟩] "price" .int`
