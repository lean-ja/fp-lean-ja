<!--
# Pitfalls of Programming with Dependent Types
-->

# 依存型プログラミングの落とし穴

<!--
The flexibility of dependent types allows more useful programs to be accepted by a type checker, because the language of types is expressive enough to describe variations that less-expressive type systems cannot.
At the same time, the ability of dependent types to express very fine-grained specifications allows more buggy programs to be rejected by a type checker.
This power comes at a cost.
-->

依存型の柔軟性によって、より便利なプログラムが型チェッカに受理されるようになります。というのも、この型の言語は表現力の乏しい型システムでは記述できないようなものについて記述するのに十分な表現力を備えているからです。同時に、依存型は非常にきめ細やかな仕様を表現できるため、バグを含むプログラムについて通常の型システムよりも多くのものが型チェッカで拒否されるようになります。このパワーには代償が伴います。

<!--
The close coupling between the internals of type-returning functions such as `Row` and the types that they produce is an instance of a bigger difficulty: the distinction between the interface and the implementation of functions begins to break down when functions are used in types.
Normally, all refactorings are valid as long as they don't change the type signature or input-output behavior of a function.
Functions can be rewritten to use more efficient algorithms and data structures, bugs can be fixed, and code clarity can be improved without breaking client code.
When the function is used in a type, however, the internals of the function's implementation become part of the type, and thus part of the _interface_ to another program.
-->

`Row` のような型を返す関数の内部と、その関数が生成する型との間の密結合などはより大きな困難の一例です：関数のインタフェースと実装の区別は関数が型の中で使われると崩れ始めます。通常、関数の型シグネチャや入出力の動作を変更しない限り、すべてのリファクタリングが有効です。クライアントコードを壊すことなく、関数はより効率的なアルゴリズムやデータ構造を使用するように書き換え、バグを修正し、ソースコードの明瞭性を向上させることができます。しかし、関数が型の中で使用されると、関数の実装内部は型の一部となり、したがって他のプログラムへの **インタフェース** の一部となります。

<!--
As an example, take the following two implementations of addition on `Nat`.
`Nat.plusL` is recursive on its first argument:
-->

例として、以下の2つの `Nat` の加算の実装を見てみましょう。`Nat.plusL` は最初の引数に対して再帰的です：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusL}}
```
<!--
`Nat.plusR`, on the other hand, is recursive on its second argument:
-->

一方、`Nat.plusR` は第2引数に対して再帰的です：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR}}
```
<!--
Both implementations of addition are faithful to the underlying mathematical concept, and they thus return the same result when given the same arguments.
-->

足し算の実装はどちらもベースの数学的なコンセプトに忠実であるため、同じ引数が与えられた時に同じ結果を返します。

<!--
However, these two implementations present quite different interfaces when they are used in types.
As an example, take a function that appends two `Vect`s.
This function should return a `Vect` whose length is the sum of the length of the arguments.
Because `Vect` is essentially a `List` with a more informative type, it makes sense to write the function just as one would for `List.append`, with pattern matching and recursion on the first argument.
Starting with a type signature and initial pattern match pointing at placeholders yields two messages:
-->

しかし、これら2つの実装は型の中で用いられると全く異なるインタフェースを示します。例として、2つの `Vect` を連結する関数を考えてみましょう。この関数は引数の長さの和を長さとした `Vect` を返す必要があります。`Vect` は基本的に `List` により情報をもった型を加えたものであるので、この関数を `List.append` と同じように最初の引数に対してパターンマッチと再帰を行うように記述することは理にかなっているでしょう。型シグネチャとプレースホルダを指す最初のパターンマッチから始めると、2つのメッセージが得られます。

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL1}}
```
<!--
The first message, in the `nil` case, states that the placeholder should be replaced by a `Vect` with length `plusL 0 k`:
-->

`nil` のケースにある最初のメッセージは、プレースホルダが `plusL 0 k` の長さを持つ `Vect` で置き換えられるべきであるということを述べています：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL1}}
```
<!--
The second message, in the `cons` case, states that the placeholder should be replaced by a `Vect` with length `plusL (n✝ + 1) k`:
-->

`cons` のケースにある2番目のメッセージでは、プレースホルダは長さ `plusL (n✝ + 1) k` の `Vect` で置き換えられるべきであることを述べています：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL2}}
```
<!--
The symbol after `n`, called a _dagger_, is used to indicate names that Lean has internally invented.
Behind the scenes, pattern matching on the first `Vect` implicitly caused the value of the first `Nat` to be refined as well, because the index on the constructor `cons` is `n + 1`, with the tail of the `Vect` having length `n`.
Here, `n✝` represents the `Nat` that is one less than the argument `n`.
-->

`n` の後にある **ダガー** と呼ばれる記号はLeanが内部的に考案した名前を示すために使用されます。コンストラクタ `cons` の添字は `n + 1` であり `Vect` の後続のリストの長さが `n` であることから、裏では最初の `Vect` に対して暗黙的に行われたパターンマッチによって、最初の `Nat` の値が絞り込まれます。ここで、`n✝` は引数 `n` より1つ小さい `Nat` を表します。

<!--
## Definitional Equality
-->

## 定義上の同値

<!--
In the definition of `plusL`, there is a pattern case `0, k => k`.
This applies in the length used in the first placeholder, so another way to write the underscore's type `Vect α (Nat.plusL 0 k)` is `Vect α k`.
Similarly, `plusL` contains a pattern case `n + 1, k => plusN n k + 1`.
This means that the type of the second underscore can be equivalently written `Vect α (plusL n✝ k + 1)`.
-->

`plusL` の定義には `0, k => k` のパターンのケースがあります。これは最初のプレースホルダで使用されている長さに適用されるため、アンダースコアの型 `Vect α (Nat.plusL 0 k)` は `Vect α k` と別の書き方ができます。同様に、`plusL` は `n + 1, k => plusN n k + 1` というパターンのケースを含んでいます。つまり、2つ目のアンダースコアの型は `Vect α (plusL n✝ k + 1)` と書くことと等価です。

<!--
To expose what is going on behind the scenes, the first step is to write the `Nat` arguments explicitly, which also results in daggerless error messages because the names are now written explicitly in the program:
-->

裏で何が行われているかを明らかにするために、まず最初に `Nat` の引数を明示的に記述します。これによってプログラム中で今や名前が明示的に書かれることになるため、ダガーのないエラーメッセージが得られます：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL3}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL3}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL4}}
```
<!--
Annotating the underscores with the simplified versions of the types does not introduce a type error, which means that the types as written in the program are equivalent to the ones that Lean found on its own:
-->

アンダースコアに簡略化された型の注釈を付けても型エラーは発生しません。これはプログラム内で書かれた型がLeanが自力で見つけたものと等価であることを意味します：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL5}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL5}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL6}}
```

<!--
The first case demands a `Vect α k`, and `ys` has that type.
This is parallel to the way that appending the empty list to any other list returns that other list.
Refining the definition with `ys` instead of the first underscore yields a program with only one remaining underscore to be filled out:
-->

最初のケースは `Vect α k` を要求し、`ys` はその型を持ちます。これは空リストを他のリストに追加するとそのリストが返されることと対になっています。最初のアンダースコアの代わりに `ys` を使って型を絞り込むと、プログラム中にまだ埋められていないアンダースコアは残り1つとなります：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL7}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL7}}
```

<!--
Something very important has happened here.
In a context where Lean expected a `Vect α (Nat.plusL 0 k)`, it received a `Vect α k`.
However, `Nat.plusL` is not an `abbrev`, so it may seem like it shouldn't be running during type checking.
Something else is happening.
-->

ここで非常に重要なことが起こりました。Leanが `Vect α (Nat.plusL 0 k)` を期待したコンテキストで `Vect α k` を受け取ったのです。しかし、`Nat.plusL` は `abbrev` ではないため、型チェック中に実行されるべくもないと思われるかもしれません。つまり何か別のことが起こっています。

<!--
The key to understanding what's going on is that Lean doesn't just expand `abbrev`s while type checking.
It can also perform computation while checking whether two types are equivalent to one another, such that any expression of one type can be used in a context that expects the other type.
This property is called _definitional equality_, and it is subtle.
-->

何が起こっているかを理解する鍵となるのは、Leanが型チェックをする際に行うことはただ `abbrev` を展開するだけではないということです。それだけでなく、片方の型の任意の式がもう片方の型を期待するコンテキストで使われているような2つの型が等しいかどうかのチェックをしながら計算を行うこともできます。この性質は **定義上の同値** （definitional equality）と呼ばれ、とらえがたいものです。

<!--
Certainly, two types that are written identically are considered to be definitionally equal—`Nat` and `Nat` or `List String` and `List String` should be considered equal.
Any two concrete types built from different datatypes are not equal, so `List Nat` is not equal to `Int`.
Additionally, types that differ only by renaming internal names are equal, so `(n : Nat) → Vect String n` is the same as `(k : Nat) → Vect String k`.
Because types can contain ordinary data, definitional equality must also describe when data are equal.
Uses of the same constructors are equal, so `0` equals `0` and `[5, 3, 1]` equals `[5, 3, 1]`.
-->

当たり前ですが、同じように書かれた2つの型は定義上同値です。例えば、`Nat` は `Nat` と、`List String` は `List String` と等しいと見なされるべきです。異なるデータ型から構築された任意の2つの具体的な型は等しくありません。そのため `List Nat` は `Int` と等しくありません。さらに、内部的な名前の変更だけが異なる型は等しいです。そのため、`(n : Nat) → Vect String n` は `(k : Nat) → Vect String k` と同じです。型は通常のデータを含むことができるため、定義上の同値はデータが等しい場合についても記述しなければなりません。同じコンストラクタの使用は等しいです。そのため、`0` は `0` と、`[5, 3, 1]` は `[5, 3, 1]` と等しくなります。

<!--
Types contain more than just function arrows, datatypes, and constructors, however.
They also contain _variables_ and _functions_.
Definitional equality of variables is relatively simple: each variable is equal only to itself, so `(n k : Nat) → Vect Int n` is not definitionally equal to `(n k : Nat) → Vect Int k`.
Functions, on the other hand, are more complicated.
While mathematics considers two functions to be equal if they have identical input-output behavior, there is no efficient algorithm to check that, and the whole point of definitional equality is for Lean to check whether two types are interchangeable.
Instead, Lean considers functions to be definitionally equal either when they are both `fun`-expressions with definitionally equal bodies.
In other words, two functions must use _the same algorithm_ that calls _the same helpers_ to be considered definitionally equal.
This is not typically very helpful, so definitional equality of functions is mostly used when the exact same defined function occurs in two types.
-->

しかし、型に含まれるのは型に含まれるのは関数の矢印、データ型、コンストラクタだけではありません。型には **変数** と **関数** も含まれます。変数の定義上の同値は比較的シンプルです：各変数は自分自身と等しくなります。そのため `(n k : Nat) → Vect Int n` は `(n k : Nat) → Vect Int k` と定義上等しくありません。一方で関数はもっと複雑です。数学では2つの関数が入力と出力の挙動が同じであるときに等しいと見なしますが、それをチェックする効率的なアルゴリズムは無いため、Leanでは定義上同値なボディを持つ `fun` 式を持つ関数は定義上同値であると見なします。言い換えると、2つの関数が定義上同値であるためには **同じアルゴリズム** を使い、**同じ補助関数** を呼ばなければなりません。これは通常あまり役に立たないため、関数の定義上の同値は2つの型に全く同じ定義関数が存在する場合に使用されることがほとんどです。

<!--
When functions are _called_ in a type, checking definitional equality may involve reducing the function call.
The type `Vect String (1 + 4)` is definitionally equal to the type `Vect String (3 + 2)` because `1 + 4` is definitionally equal to `3 + 2`.
To check their equality, both are reduced to `5`, and then the constructor rule can be used five times.
Definitional equality of functions applied to data can be checked first by seeing if they're already the same—there's no need to reduce `["a", "b"] ++ ["c"]` to check that it's equal to `["a", "b"] ++ ["c"]`, after all.
If not, the function is called and replaced with its value, and the value can then be checked.
-->

関数が型の中で **呼ばれた** 場合、定義上の同値のチェックによって関数呼び出しの簡約が発火される場合があります。型 `Vect String (1 + 4)` は、`1 + 4` が `3 + 2` と定義上等しいため、型 `Vect String (3 + 2)` と定義上等しいです。これらの等価性をチェックするには、どちらも `5` に簡約され、コンストラクタのルールが5回使われることで確認できます。データに適用された関数の定義上の同値は、まずそれらがすでに同じであるかのチェックを行います。つまるところ、`["a", "b"] ++ ["c"]` が `["a", "b"] ++ ["c"]` と等しいことのチェックのために簡約する必要はないわけです。等しくなかった場合、関数が呼ばれ、得られた値で置き換えられ、その値がチェックされます。

<!--
Not all function arguments are concrete data.
For example, types may contain `Nat`s that are not built from the `zero` and `succ` constructors.
In the type `(n : Nat) → Vect String n`, the variable `n` is a `Nat`, but it is impossible to know _which_ `Nat` it is before the function is called.
Indeed, the function may be called first with `0`, and then later with `17`, and then again with `33`.
As seen in the definition of `appendL`, variables with type `Nat` may also be passed to functions such as `plusL`.
Indeed, the type `(n : Nat) → Vect String n` is definitionally equal to the type `(n : Nat) → Vect String (Nat.plusL 0 n)`.
-->

全ての関数の引数が具体的なデータというわけではありません。例えば、型の中には `zero` と `succ` コンストラクタのどちらからも生成されていない `Nat` が含まれることがあります。型 `(n : Nat) → Vect String n` の中で、変数 `n` は `Nat` ですが、この関数が呼ばれるまではこれが **どっちの** `Nat` であるか知ることは不可能です。実際、この関数はまず `0` で呼び、その後で `17` を、それから `33` で呼び出されるかもしれません。`appendL` の定義で見たように、`Nat` 型の変数も `plusL` のような関数に渡すことができます。実際、型 `(n : Nat) → Vect String n` は `(n : Nat) → Vect String (Nat.plusL 0 n)` と定義上等しくなります。

<!--
The reason that `n` and `Nat.plusL 0 n` are definitionally equal is that `plusL`'s pattern match examines its _first_ argument.
This is problematic: `(n : Nat) → Vect String n` is _not_ definitionally equal to `(n : Nat) → Vect String (Nat.plusL n 0)`, even though zero should be both a left and a right identity of addition.
This happens because pattern matching gets stuck when it encounters variables.
Until the actual value of `n` becomes known, there is no way to know which case of `Nat.plusL n 0` should be selected.
-->

`n` と `Nat.plusL 0 n` が定義上同値である理由は、`plusL` のパターンマッチがその **最初の** 引数を調べるからです。これは問題です：0は足し算の左右どちらともの単位元であるべきであるにもかかわらず、`(n : Nat) → Vect String n` は `(n : Nat) → Vect String (Nat.plusL n 0)` と定義上同値 **ではない** からです。これはパターンマッチが変数に遭遇したことで行き詰ってしまうことで発生します。`n` の実際の値がわかるまで、`Nat.plusL n 0` のどのケースを選択すべきか知るすべはありません。

<!--
The same issue appears with the `Row` function in the query example.
The type `Row (c :: cs)` does not reduce to any datatype because the definition of `Row` has separate cases for singleton lists and lists with at least two entries.
In other words, it gets stuck when trying to match the variable `cs` against concrete `List` constructors.
This is why almost every function that takes apart or constructs a `Row` needs to match the same three cases as `Row` itself: getting it unstuck reveals concrete types that can be used for either pattern matching or constructors.
-->

同じ問題がクエリの例での `Row` 関数でも発生します。`Row` の定義が中身が1つのリストと最低でも2つ以上要素を持つリストを分けているため、型 `Row (c :: cs)` はどのデータ型にも簡約することができません。つまり、具体的な `List` コンストラクタに対して変数 `cs` をマッチさせようとすると詰まってしまいます。これが `Row` を分解したり構成したりするほとんどすべての関数が `Row` の3つのケースと同じようにマッチさせる必要がある理由です：これを解消すると、パターンマッチにもコンストラクタにも使える具体的な型が見えてきます。

<!--
The missing case in `appendL` requires a `Vect α (Nat.plusL n k + 1)`.
The `+ 1` in the index suggests that the next step is to use `Vect.cons`:
-->

`appendL` の欠落しているケースでは `Vect α (Nat.plusL n k + 1)` が必要になります。この添字での `+ 1` によって次のステップで `Vect.cons` を使うことが示唆されます：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL8}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL8}}
```
<!--
A recursive call to `appendL` can construct a `Vect` with the desired length:
-->

`appendL` を再帰的に呼び出すことで、目的の長さの `Vect` を構築することができます：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendL9}}
```
<!--
Now that the program is finished, removing the explicit matching on `n` and `k` makes it easier to read and easier to call the function:
-->

これでプログラムが完成したので、`n` と `k` への明示的なマッチを削除することで読みやすく、関数も呼び出しやすくなります：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendL}}
```

<!--
Comparing types using definitional equality means that everything involved in definitional equality, including the internals of function definitions, becomes part of the _interface_ of programs that use dependent types and indexed families.
Exposing the internals of a function in a type means that refactoring the exposed program may cause programs that use it to no longer type check.
In particular, the fact that `plusL` is used in the type of `appendL` means that the definition of `plusL` cannot be replaced by the otherwise-equivalent `plusR`.
-->

定義上の同値を使った型の比較は関数定義の内部を含め、定義上同値なものに関連するすべてのものが、依存型と添字族を使うプログラムの **インタフェース** の一部になるということを意味します。型の中に関数の内部を公開するということは、その公開されたプログラムをリファクタリングすることでそれを使用するプログラムが型チェックをしなくなってしまう可能性があるということです。特に、`plusL` が `appendL` の型に使われているということは、`plusL` の定義を `plusR` と同等な他の定義に置き換えることができないということを意味します。

<!--
## Getting Stuck on Addition
-->

## 足し算での行き詰まり

<!--
What happens if append is defined with `plusR` instead?
Beginning in the same way, with explicit lengths and placeholder underscores in each case, reveals the following useful error messages:
-->

appendを `plusR` で代わりに定義するとどうなるでしょうか？同じように始めると、それぞれのケースで長さとプレースホルダのアンダースコアが明示され、次のような有益なエラーメッセージが表示されます：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR1}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR1}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR2}}
```
<!--
However, attempting to place a `Vect α k` type annotation around the first placeholder results in an type mismatch error:
-->

しかし、最初のプレースホルダを囲んで `Vect α k` の型注釈を付けようとすると、型の不一致エラーとなります：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR3}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR3}}
```
<!--
This error is pointing out that `plusR 0 k` and `k` are _not_ definitionally equal.
-->

このエラーは `plusR 0 k` と `k` が定義上等しく **ない** ことを指摘しています。

<!--
This is because `plusR` has the following definition:
-->

これは `plusR` が次のような定義を持っているためです：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR}}
```
<!--
Its pattern matching occurs on the _second_ argument, not the first argument, which means that the presence of the variable `k` in that position prevents it from reducing.
`Nat.add` in Lean's standard library is equivalent to `plusR`, not `plusL`, so attempting to use it in this definition results in precisely the same difficulties:
-->

このパターンマッチは第1引数ではなく **第二** 引数に対して行われるため、その位置に変数 `k` が存在すると簡約をすることができません。Leanの標準ライブラリにある `Nat.add` は `plusL` ではなく `plusR` と等価であるため、この定義で `Nat.add` を使おうとすると全く同じ問題が起こります：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR4}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR4}}
```

<!--
Addition is getting _stuck_ on the variables.
Getting it unstuck requires [propositional equality](../type-classes/standard-classes.md#equality-and-ordering).
-->

足し算は変数に **つまって** しまいます。これを解消するには、[命題の同値](../type-classes/standard-classes.md#equality-and-ordering) を使用します。

<!--
## Propositional Equality
-->

## 命題の同値

<!--
Propositional equality is the mathematical statement that two expressions are equal.
While definitional equality is a kind of ambient fact that Lean automatically checks when required, statements of propositional equality require explicit proofs.
Once an equality proposition has been proved, it can be used in a program to modify a type, replacing one side of the equality with the other, which can unstick the type checker.
-->

命題の同値は2つの式が等しいという数学的な文です。定義上の同値はLeanが必要な時に自動的にチェックする一種の曖昧な事実ですが、命題の同値の記述には明示的な証明が必要です。一度命題の同値が証明されると、プログラム内でそれを使って型を修正し、等式を片方の辺を他方のもので置き換えることができ、型チェッカの詰まりを解消できます。

<!--
The reason why definitional equality is so limited is to enable it to be checked by an algorithm.
Propositional equality is much richer, but the computer cannot in general check whether two expressions are propositionally equal, though it can verify that a purported proof is in fact a proof.
The split between definitional and propositional equality represents a division of labor between humans and machines: the most boring equalities are checked automatically as part of definitional equality, freeing the human mind to work on the interesting problems available in propositional equality.
Similarly, definitional equality is invoked automatically by the type checker, while propositional equality must be specifically appealed to.
-->

定義上の同値がこのように限定されている理由は、アルゴリズムによるチェックを可能にするためです。命題の同値はより機能が豊かですが、証明と称されるものが実際に証明であることを検証できたとしても、コンピュータは一般的に2つの式が命題的に等しいかどうかをチェックすることができません。定義上の同値と命題の同値の断絶は人間と機械の間の分業を表現しています：退屈極まりない等式は定義上の同値の一部として自動的にチェックされ、人間の頭脳は命題の同値で利用される興味深い問題に向けることができます。同様に、定義上の同値は型チェッカによって自動的に呼び出されますが、命題の同値は明確に呼びかけなければなりません。

<!--
In [Propositions, Proofs, and Indexing](../props-proofs-indexing.md), some equality statements are proved using `simp`.
All of these equality statements are ones in which the propositional equality is in fact already a definitional equality.
Typically, statements of propositional equality are proved by first getting them into a form where they are either definitional or close enough to existing proved equalities, and then using tools like `simp` to take care of the simplified cases.
The `simp` tactic is quite powerful: behind the scenes, it uses a number of fast, automated tools to construct a proof.
A simpler tactic called `rfl` specifically uses definitional equality to prove propositional equality.
The name `rfl` is short for _reflexivity_, which is the property of equality that states that everything equals itself.
-->

[「命題・証明・リストの添え字アクセス」](../props-proofs-indexing.md) にて、いくつかの同値についての文が `simp` を使って証明されました。これらの等式はすべて、命題の同値がすでに定義上の同値になっているものです。一般的に、命題の同値についての文を証明するには、まずそれらを定義上の同値か既存の証明済みの等式に近い形にし、`simp` のようなツールを使って単純化されたケースを処理します。`simp` タクティクは非常に強力です：裏では、高速で自動化された多くのツールを使って証明を構築します。これよりはシンプルな `rfl` と呼ばれるタクティクは命題の同値を証明するために定義上の同値を使用します。`rfl` という名前は **反射律** （reflexivity）の略であり、すべてのものはそれ自身に等しいという同値についての性質です。

<!--
Unsticking `appendR` requires a proof that `k = Nat.plusR 0 k`, which is not a definitional equality because `plusR` is stuck on the variable in its second argument.
To get it to compute, the `k` must become a concrete constructor.
This is a job for pattern matching.
-->

`appendR` の詰まりを解消するには、`k = Nat.plusR 0 k` という証明が必要ですが、これは `plusR` が第2引数の変数に着目しているため定義上の同値ではないのでした。これを計算させるためには `k` を具体的なコンストラクタにしなければなりません。これはパターンマッチの仕事です。

<!--
In particular, because `k` could be _any_ `Nat`, this task requires a function that can return evidence that `k = Nat.plusR 0 k` for _any_ `k` whatsoever.
This should be a function that returns a proof of equality, with type `(k : Nat) → k = Nat.plusR 0 k`.
Getting it started with initial patterns and placeholders yields the following messages:
-->

特に、`k` は **任意の** `Nat` でありうるので、このタスクは **任意の** `k` に対して `k = Nat.plusR 0 k` であるという根拠を返す関数を必要とします。これは `(k : Nat) → k = Nat.plusR 0 k` という型を持つ同値の証明を返す関数でなければなりません。一番初めのパターンとプレースホルダから始めると、次のようなメッセージが返ってきます：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_zero_left1}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_zero_left1}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_zero_left2}}
```
<!--
Having refined `k` to `0` via pattern matching, the first placeholder stands for evidence of a statement that does hold definitionally.
The `rfl` tactic takes care of it, leaving only the second placeholder:
-->

パターンマッチによって `k` を `0` に絞り込むと、最初のプレースホルダは定義上成立する文の根拠となります。`rfl` タクティクはこれを処理し、残るは2番目のプレースホルダのみとなります：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_zero_left3}}
```

<!--
The second placeholder is a bit trickier.
The expression `{{#example_in Examples/DependentTypes/Pitfalls.lean plusRStep}}` is definitionally equal to `{{#example_out Examples/DependentTypes/Pitfalls.lean plusRStep}}`.
This means that the goal could also be written `k + 1 = Nat.plusR 0 k + 1`:
-->

2番目のプレースホルダは少し厄介です。式 `{{#example_in Examples/DependentTypes/Pitfalls.lean plusRStep}}` は `{{#example_out Examples/DependentTypes/Pitfalls.lean plusRStep}}` と定義上同値です。これは、ゴールが `k + 1 = Nat.plusR 0 k + 1` とも書けることを意味します：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_zero_left4}}
```
```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_zero_left4}}
```

<!--
Underneath the `+ 1` on each side of the equality statement is another instance of what the function itself returns.
In other words, a recursive call on `k` would return evidence that `k = Nat.plusR 0 k`.
Equality wouldn't be equality if it didn't apply to function arguments. 
In other words, if `x = y`, then `f x = f y`.
The standard library contains a function `congrArg` that takes a function and an equality proof and returns a new proof where the function has been applied to both sides of the equality.
In this case, the function is `(· + 1)`:
-->

文の等式の両側にある `+ 1` の下には関数自体が返す別のインスタンスがあります。言い換えれば、`k` に対する再帰呼び出しは `k = Nat.plusR 0 k` という根拠を返すことになります。等式は関数の引数に適用されなければ等式になりません。つまり `x = y` ならば `f x = f y` となります。標準ライブラリには関数 `congrArg` があり、関数と同値の証明を受け取り、等号の両辺に関数を適用した新しい証明を返します。今回の場合、関数は `(· + 1)` です：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR_zero_left_done}}
```

<!--
Propositional equalities can be deployed in a program using the rightward triangle operator `▸`.
Given an equality proof as its first argument and some other expression as its second, this operator replaces instances of the left side of the equality with the right side of the equality in the second argument's type.
In other words, the following definition contains no type errors:
-->

命題の同値は右向きの三角形の演算子 `▸` を使ってプログラムに導入することができます。同値の証明を第1引数に、他の式を第2引数に与えることで、この演算子は第2引数の型において等式の左辺のインスタンスを右辺の等式に置き換えます。つまり、以下の定義には型エラーがありません：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendRsubst}}
```
<!--
The first placeholder has the expected type:
-->

最初のプレースホルダは以下の型が期待されています：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendRsubst}}
```
<!--
It can now be filled in with `ys`:
-->

これは `ys` で埋めることができます：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR5}}
```

<!--
Filling in the remaining placeholder requires unsticking another instance of addition:
-->

残りのプレースホルダを埋めるには、別の加算についてのインスタンスでの詰まりを解消する必要があります：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR5}}
```
<!--
Here, the statement to be proved is that `Nat.plusR (n + 1) k = Nat.plusR n k + 1`, which can be used with `▸` to draw the `+ 1` out to the top of the expression so that it matches the index of `cons`.
-->

ここで、証明すべき文は `Nat.plusR (n + 1) k = Nat.plusR n k + 1` です。これは `▸` を使うことで `+ 1` を先頭に抜き出し、これによって `cons` のインデックスと一致させることができます。

<!--
The proof is a recursive function that pattern matches on the second argument to `plusR`, namely `k`.
This is because `plusR` itself pattern matches on its second argument, so the proof can "unstick" it through pattern matching, exposing the computational behavior.
The skeleton of the proof is very similar to that of `plusR_zero_left`:
-->

この証明は `plusR` への第2引数、つまり `k` へのパターンマッチを行う再帰関数です。これは `plusR` 自身が第2引数でパターンマッチを行うためであり、証明はパターンマッチによって `plusR` を「解消」し、計算の挙動を明らかにすることができます。この証明の骨格は `plusR_zero_left` のものと非常によく似ています：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_succ_left_0}}
```

<!--
The remaining case's type is definitionally equal to `Nat.plusR (n + 1) k + 1 = Nat.plusR n (k + 1) + 1`, so it can be solved with `congrArg`, just as in `plusR_zero_left`:
-->

残ったケースの型は `Nat.plusR (n + 1) k + 1 = Nat.plusR n (k + 1) + 1` と定義上同値であるため、`plusR_zero_left` と同様に `congrArg` で解くことができます：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_succ_left_2}}
```
<!--
This results in a finished proof:
-->

これによって証明が完成します：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR_succ_left}}
```

<!--
The finished proof can be used to unstick the second case in `appendR`:
-->

完成した証明は `appendR` の2番目のケースの詰まりを解くことに使うことができます：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendR}}
```
<!--
When making the length arguments to `appendR` implicit again, they are no longer explicitly named to be appealed to in the proofs.
However, Lean's type checker has enough information to fill them in automatically behind the scenes, because no other values would allow the types to match:
-->

再び `appendR` の長さの引数を暗黙にすると、証明の中で要求されていた明示的な名前がなくなります。しかし、これらの型をマッチさせるための値はほかにありえないため、Leanの型チェッカは裏で自動的にそれらを埋めるための情報を十分に持っています：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendRImpl}}
```

<!--
## Pros and Cons
-->

## 長所と短所

<!--
Indexed families have an important property: pattern matching on them affects definitional equality.
For example, in the `nil` case in a `match` expression on a `Vect`, the length simply _becomes_ `0`.
Definitional equality can be very convenient, because it is always active and does not need to be invoked explicitly.
-->

添字族には重要な特性があります：これらへのパターンマッチは定義上の同値に影響を与えます。例えば、`Vect` に対する `Match` 式で `nil` のケースにおいて、長さは単純に `0` に **なります** 。定義上の同値はとても便利です。というのもこれはいつでも有効であり、明示的に呼び出す必要がないからです。

<!--
However, the use of definitional equality with dependent types and pattern matching has serious software engineering drawbacks.
First off, functions must be written especially to be used in types, and functions that are convenient to use in types may not use the most efficient algorithms.
Once a function has been exposed through using it in a type, its implementation has become part of the interface, leading to difficulties in future refactoring.
Secondly, definitional equality can be slow.
When asked to check whether two expressions are definitionally equal, Lean may need to run large amounts of code if the functions in question are complicated and have many layers of abstraction.
Third, error messages that result from failures of definitional equality are not always very easy to understand, because they may be phrased in terms of the internals of functions.
It is not always easy to understand the provenance of the expressions in the error messages.
Finally, encoding non-trivial invariants in a collection of indexed families and dependently-typed functions can often be brittle.
It is often necessary to change early definitions in a system when the exposed reduction behavior of functions proves to not provide convenient definitional equalities.
The alternative is to litter the program with appeals to equality proofs, but these can become quite unwieldy.
-->

しかし、依存型とパターンマッチによる定義上の同値の使用にはソフトウェア工学的に重大な欠点があります。まず第一に、関数は型の中で使用する用として特別に書かなければならず、型の中で便利に使用される関数では最も効率的なアルゴリズムを使用していない可能性があります。一度型の中で関数が使用されて公開されると、その実装はインタフェースの一部となり、将来のリファクタリングが困難になります。第二に、定義上の同値は時間がかかることがあります。2つの式が定義上同値であるかどうかをチェックするよう求められた時で問題の関数が複雑で抽象化のレイヤーが多い場合、Leanは大量のコードを実行する必要がある可能性が発生します。第三に、定義上の同値が失敗した時に得られるエラーメッセージは関数の内部的な用語で表現されるため、いつでも理解しやすいとは限りません。エラーメッセージに含まれる式の出所を理解するのは必ずしも容易ではありません。最後に、添字族と依存型関数のあつまりに自明でない不変量をエンコードすることはしばしば脆弱になります。関数の簡約についての挙動の公開によって便利な定義上の同値を提供しないことが判明した際に、システムの初期の定義を変更しなければならないことがよくあります。別の方法として、等式の証明の要求をプログラムにちりばめることもできますが、これは非常に扱いにくくなる可能性があります。

<!--
In idiomatic Lean code, indexed datatypes are not used very often.
Instead, subtypes and explicit propositions are typically used to enforce important invariants.
This approach involves many explicit proofs, and very few appeals to definitional equality.
As befits an interactive theorem prover, Lean has been designed to make explicit proofs convenient.
Generally speaking, this approach should be preferred in most cases.
-->

慣用的なLeanのコードでは、添字族はあまり使われません。その代わりに、部分型と明示的な命題を使用して重要な不変性を強制することが一般的です。このアプローチでは明示的な証明が多く、定義上の同値に訴えることはほとんどありません。対話型の定理証明器にふさわしく、Leanは明示的な証明を便利にするように設計されています。一般的に、ほとんどの場合においてこのアプローチが望ましいです。

<!--
However, understanding indexed families of datatypes is important.
Recursive functions such as `plusR_zero_left` and `plusR_succ_left` are in fact _proofs by mathematical induction_.
The base case of the recursion corresponds to the base case in induction, and the recursive call represents an appeal to the induction hypothesis.
More generally, new propositions in Lean are often defined as inductive types of evidence, and these inductive types usually have indices.
The process of proving theorems is in fact constructing expressions with these types behind the scenes, in a process not unlike the proofs in this section.
Also, indexed datatypes are sometimes exactly the right tool for the job.
Fluency in their use is an important part of knowing when to use them.
-->

しかし、データ型の添字族を理解することは重要です。`plusR_zero_left` や `plusR_succ_left` などの再帰関数は、実は **数学的帰納法による証明** （proofs by mathematical induction）です。再帰の基本ケースは帰納法の基本ケースに対応し、再帰呼び出しは帰納法の仮定に訴えることを表しています。より一般的には、Leanにおける新しい命題はしばしば帰納的な根拠の型として定義され、これらの帰納型は通常は添字を持ちます。定理を証明するプロセスはこの節の証明と同じようなプロセスで、実際にはこれらの型を持つ式を裏で構築しています。また、添字を持つデータ型はまさにその仕事に適したツールであることもあります。添字付きのデータ型の使い方を熟知することは、どのような場合に添字付きのデータ型を使うべきか知るための重要な要素です。

<!--
## Exercises
-->

## 演習問題

 <!--
 * Using a recursive function in the style of `plusR_succ_left`, prove that for all `Nat`s `n` and `k`, `n.plusR k = n + k`.
 * Write a function on `Vect` for which `plusR` is more natural than `plusL`, where `plusL` would require proofs to be used in the definition.
 -->
 * `plusR_succ_left` のスタイルの再帰関数を使って、すべての `n` と `k` に対して `n.plusR k = n + k` であることを証明してください。
 * `Vect` 上の関数で `plusL` よりも `plusR` の方が自然であるものを書いてください。つまり `plusL` ではその定義を用いた証明が必要となるようなものです。

