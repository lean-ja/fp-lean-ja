<!-- # Summary -->

# まとめ

<!-- ## Evaluating Expressions -->

## 式の評価

<!-- In Lean, computation occurs when expressions are evaluated.
This follows the usual rules of mathematical expressions: sub-expressions are replaced by their values following the usual order of operations, until the entire expression has become a value.
When evaluating an `if` or a `match`, the expressions in the branches are not evaluated until the value of the condition or the match subject has been found. -->

Leanでは，式が評価されるときに計算も行われます．これは数式の通常のルールに従って行われます：式全体が値になるまで，通常の演算順序に従って部分式が値で置き換えられます．`if` や `match` を評価する場合，条件の値やマッチの対象が見つかるまでは枝の中の式は評価されません．

<!-- Once they have been given a value, variables never change.
Similarly to mathematics but unlike most programming languages, Lean variables are simply placeholders for values, rather than addresses to which new values can be written.
Variables' values may come from global definitions with `def`, local definitions with `let`, as named arguments to functions, or from pattern matching. -->

一度値が与えられると，変数は決して変化しません．これは数学と似ている一方でほとんどのプログラミング言語と異なった性質です．Leanの変数は単に値のプレースホルダであり，新しい値を書き込むことができるアドレスではありません．変数の値は `def` によるグローバル定義，`let` によるローカル定義，関数への名前付き引数，パターンマッチによって得られます．

<!-- ## Functions -->

## 関数

<!-- Functions in Lean are first-class values, meaning that they can be passed as arguments to other functions, saved in variables, and used like any other value.
Every Lean function takes exactly one argument.
To encode a function that takes more than one argument, Lean uses a technique called currying, where providing the first argument returns a function that expects the remaining arguments.
To encode a function that takes no arguments, Lean uses the `Unit` type, which is the least informative possible argument. -->

Leanにおいて関数は第一級です．つまり，関数をほかの関数に引数として渡したり，変数に保存したり，ほかの値と同じように使用することができます．Leanのすべての関数は必ず1つの引数を取ります．2つ以上の引数を取る関数を実装する場合には，Leanはカリー化と呼ばれるテクニックを使います．これは複数引数のうち最初の引数を受け取ってそれ以降の引数を受け取るような関数を返すようにするものです．引数を取らない関数を実装する場合には，Leanでは `Unit` 型という引数として最低限の情報を持つ型を使用します．

<!-- There are three primary ways of creating functions: -->

関数の実装方法は主に以下の3つがあります：

<!-- 1. Anonymous functions are written using `fun`.
   For instance, a function that swaps the fields of a `Point` can be written `{{#example_in Examples/Intro.lean swapLambda}}` -->
1. `fun` を用いた無名関数．例として，`Point` のフィールドの交換を行う関数は `{{#example_in Examples/Intro.lean swapLambda}}` と書くことができます．
<!-- 2. Very simple anonymous functions are written by placing one or more centered dots `·` inside of parentheses.
   Each centered dot becomes an argument to the function, and the parentheses delimit its body.
   For instance, a function that subtracts one from its argument can be written as `{{#example_in Examples/Intro.lean subOneDots}}` instead of as `{{#example_out Examples/Intro.lean subOneDots}}`. -->
2. 括弧の中で一つ以上の中黒点を置いた非常にシンプルな無名関数．各中黒点は関数の引数になり，括弧は関数の本体の範囲を仕切ります．例として，引数から1を引く関数 `{{#example_in Examples/Intro.lean subOneDots}}` の代わりに `{{#example_out Examples/Intro.lean subOneDots}}` とも書けます．
<!-- 3. Functions can be defined using `def` or `let` by adding an argument list or by using pattern-matching notation. -->
3. `def` か `let` に引数のリストかパターンマッチ記法を続けるようにして定義した関数．

<!-- ## Types -->

## 型

<!-- Lean checks that every expression has a type.
Types, such as `Int`, `Point`, `{α : Type} → Nat → α → List α`, and `Option (String ⊕ (Nat × String))`, describe the values that may eventually be found for an expression.
Like other languages, types in Lean can express lightweight specifications for programs that are checked by the Lean compiler, obviating the need for certain classes of unit test.
Unlike most languages, Lean's types can also express arbitrary mathematics, unifying the worlds of programming and theorem proving.
While using Lean for proving theorems is mostly out of scope for this book, _[Theorem Proving in Lean 4](https://leanprover.github.io/theorem_proving_in_lean4/)_ contains more information on this topic. -->

Leanはすべての式が型を持っていることをチェックします．Leanでの型とは何かしらの式について最終的に見つかるかもしれない値を記述したもので，例えば `Int` や `Potin` ，`{α : Type} → Nat → α → List α` ，`Option (String ⊕ (Nat × String))` のようなものになります．ほかの言語と同様に，Leanの型はLeanのコンパイラによってチェックされるプログラムのための軽量な仕様を表現することができ，一部の単体テストの必要性を排除します．ほとんどの言語とは異なり，Leanの型は任意の数学も表現でき，プログラミングと定理証明の世界を統合しています．Leanを定理証明に使うことは本書の範囲外ですが， _[Theorem Proving in Lean 4](https://leanprover.github.io/theorem_proving_in_lean4/)_ にてこのトピックに関する詳細な情報があります．[^1]

<!-- Some expressions can be given multiple types.
For instance, `3` can be an `Int` or a `Nat`.
In Lean, this should be understood as two separate expressions, one with type `Nat` and one with type `Int`, that happen to be written in the same way, rather than as two different types for the same thing. -->

式の中には複数の型を指定できるものもあります．例えば，`3` は `Int` にも `Nat` にもなります．Leanでは，これは同じものに対して2つの異なる型あるというよりも，一つは `Nat` 型でもう一つは `Int` 型である2つの別々の式がたまたま同じように書かれたと理解すべきです．

<!-- Lean is sometimes able to determine types automatically, but types must often be provided by the user.
This is because Lean's type system is so expressive.
Even when Lean can find a type, it may not find the desired type—`3` could be intended to be used as an `Int`, but Lean will give it the type `Nat` if there are no further constraints.
In general, it is a good idea to write most types explicitly, only letting Lean fill out the very obvious types.
This improves Lean's error messages and helps make programmer intent more clear. -->

Leanは自動的に型を決定できることもありますが，多くの場合，型はユーザによって提供されなければなりません．これはLeanの型システムが非常に表現力豊かだからです．仮にLeanが型を見つけることが出来たとしても，それが期待した型ではない可能性があります．`3` は `Int` として使用されることを意図しているかもしれませんが，一切制約がない場合，Leanは `Nat` という型を与えます．一般的に，ほとんどの型は明示的に記述し，非常に明白な型はLeanに埋めてもらうようにするとよいでしょう．これはLeanのエラーメッセージを改善し，プログラマの意図をより明確にするのに役立ちます．

<!-- Some functions or datatypes take types as arguments.
They are called _polymorphic_.
Polymorphism allows programs such as one that calculates the length of a list without caring what type the entries in the list have.
Because types are first class in Lean, polymorphism does not require any special syntax, so types are passed just like other arguments.
Giving an argument a name in a function type allows later types to mention that argument, and the type of applying that function to an argument is found by replacing the argument's name with the argument's value. -->

関数やデータ型の中には，型を引数に取るものがあります．これは **多相性** （polymorphic）と呼ばれます．多相性によって，リストの要素がどの型を持っているかを気にせずにリストの長さを計算するようなプログラムが可能になります．型はLeanにおいて第一級であるため，多相性は特別な構文を必要とせず，型はほかの引数と同じように渡されます．関数型において型引数に名前を与えることで，後の型がその引数に言及できるようになり，その関数を引数に適用した型は引数の名前を引数の値に置き換えることで求められます．

<!-- ## Structures and Inductive Types -->

## 構造体と帰納的型

<!-- Brand new datatypes can be introduced to Lean using the `structure` or `inductive` features.
These new types are not considered to be equivalent to any other type, even if their definitions are otherwise identical.
Datatypes have _constructors_ that explain the ways in which their values can be constructed, and each constructor takes some number of arguments.
Constructors in Lean are not the same as constructors in object-oriented languages: Lean's constructors are inert holders of data, rather than active code that initializes an allocated object. -->

Leanでは `structure` や `inductive` の機能を使って，全く新しいデータ型を導入することができます．これらの新しいデータ型はたとえ定義が同じであったとしても他のデータ型と同じであるとはみなされません．データ型はその値を構築する方法を説明する **コンストラクタ** （constructor）を持ち，各コンストラクタはいくつかの引数を取ります．Leanのコンストラクタはオブジェクト指向言語のコンストラクタとは異なります：Leanのコンストラクタは，割り当てられたオブジェクトを初期化するアクティブなコードではなく，データを保持する不活性なものです．

<!-- Typically, `structure` is used to introduce a product type (that is, a type with just one constructor that takes any number of arguments), while `inductive` is used to introduce a sum type (that is, a type with many distinct constructors).
Datatypes defined with `structure` are provided with one accessor function for each of the constructor's arguments.
Both structures and inductive datatypes may be consumed with pattern matching, which exposes the values stored inside of constructors using a subset of the syntax used to call said constructors.
Pattern matching means that knowing how to create a value implies knowing how to consume it. -->

一般的に，`sturucture` は直積型（つまり，任意の数の引数を取るコンストラクタを1つだけ持つ型）を導入するために使用され，`inductive` は直和型（つまり，多数の異なるコンストラクタを持つ型）を導入するために使用されます．`sturucture` で定義されたデータ型はコンストラクタの引数ごとにアクセサ関数が提供されます．構造体と帰納的データ型のどちらもパターンマッチにかけることができます．パターンマッチはコンストラクタを呼び出すために使用される構文のサブセットを使用して，コンストラクタの内部に格納されている値を展開します．パターンマッチは，値の作成方法を知るにはその値を消費する方法を知る必要があることを意味します．

<!-- ## Recursion -->

## 再帰

<!-- A definition is recursive when the name being defined is used in the definition itself.
Because Lean is an interactive theorem prover in addition to being a programming language, there are certain restrictions placed on recursive definitions.
In Lean's logical side, circular definitions could lead to logical inconsistency. -->

定義されている名前がその定義自体で使われている場合，定義は再帰的です．Leanはプログラミング言語であると同時に対話型定理証明機であるため，再帰的定義には一定の制限があります．Leanの論理的な側面では，循環的な定義は論理的な矛盾につながる可能性があります．

<!-- In order to ensure that recursive definitions do not undermine the logical side of Lean, Lean must be able to prove that all recursive functions terminate, no matter what arguments they are called with.
In practice, this means either that recursive calls are all performed on a structurally-smaller piece of the input, which ensures that there is always progress towards a base case, or that users must provide some other evidence that the function always terminates.
Similarly, recursive inductive types are not allowed to have a constructor that takes a function _from_ the type as an argument, because this would make it possible to encode non-terminating functions. -->

再帰的定義がLeanの論理的側面を損なわないようにするために，Leanは再帰関数がどのような引数で呼び出されたとしても，すべての再帰関数が終了することを証明できなければなりません．実用としては，これは①再帰的な呼び出しがすべて入力の構造的に小さい部分で実行され，常にその構造の基底のケースに向かって進むことを保証するか，②ユーザが関数が常に終了するという他の証拠を提供する必要があること，のどちらかを意味します．同様に，再帰的帰納型はその型を引数として **受け取る** 関数を取るコンストラクタを持つことはできません．なぜならこれは終了しない関数の実装を可能にするからです．


[^1]: 日本語訳はhttps://aconite-ac.github.io/theorem_proving_in_lean4_ja/