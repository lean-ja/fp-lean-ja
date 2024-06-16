<!-- # Additional Conveniences -->

# その他の便利な機能

<!-- ## Constructor Syntax for Instances -->

## インスタンスのためのコンストラクタ記法

<!-- Behind the scenes, type classes are structure types and instances are values of these types.
The only differences are that Lean stores additional information about type classes, such as which parameters are output parameters, and that instances are registered for searching.
While values that have structure types are typically defined using either `⟨...⟩` syntax or with braces and fields, and instances are typically defined using `where`, both syntaxes work for both kinds of definition. -->

裏側では，型クラスは構造体型であり，インスタンスはこれらの型の値です．唯一の違いは，Leanが型クラスに関する追加情報（どのパラメータが出力パラメータであるかなど）を保存していることと，インスタンスが検索のために登録されていることです．構造体型の値は通常 `⟨...⟩` 構文か波括弧とフィールドを使って定義されます．インスタンスは通常 `where` を使って定義されます．これらの構文は両方の定義どちらでも使うことができます．

For example, a forestry application might represent trees as follows:

例えば，林業に対するアプリケーションでは樹木を次のように表現します：

```lean
{{#example_decl Examples/Classes.lean trees}}
```
<!-- All three syntaxes are equivalent. -->

これら3つの記法は等価です．

<!-- Similarly, type class instances can be defined using all three syntaxes: -->

同じように，型クラスのインスタンスもこれら3つすべての記法で定義可能です：

```lean
{{#example_decl Examples/Classes.lean Display}}
```

<!-- Generally speaking, the `where` syntax should be used for instances, and the curly-brace syntax should be used for structures.
The `⟨...⟩` syntax can be useful when emphasizing that a structure type is very much like a tuple in which the fields happen to be named, but the names are not important at the moment.
However, there are situations where it can make sense to use other alternatives.
In particular, a library might provide a function that constructs an instance value.
Placing a call to this function after `:=` in an instance declaration is the easiest way to use such a function. -->

一般的に，インスタンスには `where` 構文を使用し，構造体には波括弧構文を使用します．`⟨...⟩` の構文は，構造体型がタプルとよく似ていることを強調する際には便利です．つまり，フィールドに名前がついてはいますが，そのことがあまり重要でない場合です．しかし，ほかの選択肢を使うことが理にかなっている状況もあります．特に，ライブラリがインスタンス値を構築する関数を提供する場合です．このような関数の使い方として最も簡単な方法は，インスタンス宣言の `:=` の後にこの関数を呼び出すのことです．

<!-- ## Examples -->

## 例の記述

<!-- When experimenting with Lean code, definitions can be more convenient to use than `#eval` or `#check` commands.
First off, definitions don't produce any output, which can help keep the reader's focus on the most interesting output.
Secondly, it's easiest to write most Lean programs by starting with a type signature, allowing Lean to provide more assistance and better error messages while writing the program itself.
On the other hand, `#eval` and `#check` are easiest to use in contexts where Lean is able to determine the type from the provided expression.
Thirdly, `#eval` cannot be used with expressions whose types don't have `ToString` or `Repr` instances, such as functions.
Finally, multi-step `do` blocks, `let`-expressions, and other syntactic forms that take multiple lines are particularly difficult to write with a type annotation in `#eval` or `#check`, simply because the required parenthesization can be difficult to predict. -->

Leanのコードを試したい場合，`#eval` や `#check` コマンドよりも定義を使った方が便利な場合があります．第一に，定義は出力を生成しないので，読者の注意を最も興味深い出力に集中させることができます．第二に，Leanのプログラムを書くにあたって型シグネチャから始めることが最も簡単で，これによってプログラムを書いている間により良いエラーメッセージと支援をLeanから得ることができます．一方，`#eval` と `#check` はLeanが与えられた式から型を決定できるコンテキストで使用することが最も簡単です．第三に，`#eval` は関数のように，`ToString` や `Repr` インスタンスを持たない式には使用できません．最後に，複数行にわたる `do` ブロック，`let` 式，その他の構文形は `#eval` や `#check` で型注釈を記述することが特に難しいです．　というのもシンプルにそれらに求められる括弧がどう挿入されるかの予測が難しいからです．

<!-- To work around these issues, Lean supports the explicit indication of examples in a source file.
An example is like a definition without a name.
For instance, a non-empty list of birds commonly found in Copenhagen's green spaces can be written: -->

これらの問題を回避するために，Leanはソースファイル内の例を明示的に示すことをサポートしています．例とは名前のない定義のようなものです．例えば，コペンハーゲンの緑地でよくみられる鳥についての空でないリストは以下のように書くことができます．

```lean
{{#example_decl Examples/Classes.lean birdExample}}
```

<!-- Examples may define functions by accepting arguments: -->

例は引数を受け付けることで関数を定義することもできるでしょう：

```lean
{{#example_decl Examples/Classes.lean commAdd}}
```
<!-- While this creates a function behind the scenes, this function has no name and cannot be called.
Nonetheless, this is useful for demonstrating how a library can be used with arbitrary or unknown values of some given type.
In source files, `example` declarations are best paired with comments that explain how the example illustrates the concepts of the library. -->

これは裏側で関数を作成しますが，この関数には名前がなく，呼び出すことができません．とはいえ，この関数は任意の型や未知の型の値でライブラリがどのように使えるのかを示すのに便利です．ソースファイルでは，`example` 宣言はその例がライブラリの概念をどのように表現しているかを説明するコメントと組み合わせるのが最適です．
