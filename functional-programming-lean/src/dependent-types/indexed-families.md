<!--
# Indexed Families
-->

# 添字族

<!--
Polymorphic inductive types take type arguments.
For instance, `List` takes an argument that determines the type of the entries in the list, and `Except` takes arguments that determine the types of the exceptions or values.
These type arguments, which are the same in every constructor of the datatype, are referred to as _parameters_.
-->

多相的な帰納型は型引数を取ります。例えば、`List` はリストの要素の型を、`Except` は例外や値の型をそれぞれ決定する引数を取ります。これらの型引数は対象のデータ型のすべてのコンストラクタで共有され、**パラメータ** と呼ばれます。

<!--
Arguments to inductive types need not be the same in every constructor, however.
Inductive types in which the arguments to the type vary based on the choice of constructor are called _indexed families_, and the arguments that vary are referred to as _indices_.
The "hello world" of indexed families is a type of lists that contains the length of the list in addition to the type of entries, conventionally referred to as "vectors":
-->

しかし、帰納型の引数はすべてのコンストラクタで同じである必要はありません。コンストラクタの選択によって型への引数が変化するような帰納型は **添字族** （indexed family）と呼ばれ、変化する引数は **添字** （index）と呼ばれます。添字族における「hello world」的教材は、要素の型に加えてリストの長さを含むリスト型であり、慣習的に「ベクトル」と呼ばれています：

```lean
{{#example_decl Examples/DependentTypes.lean Vect}}
```

<!--
Function declarations may take some arguments before the colon, indicating that they are available in the entire definition, and some arguments after, indicating a desire to pattern-match on them and define the function case by case.
Inductive datatypes have a similar principle: the argument `α` is named at the top of the datatype declaration, prior to the colon, which indicates that it is a parameter that must be provided as the first argument in all occurrences of `Vect` in the definition, while the `Nat` argument occurs after the colon, indicating that it is an index that may vary.
Indeed, the three occurrences of `Vect` in the `nil` and `cons` constructor declarations consistently provide `α` as the first argument, while the second argument is different in each case.
-->

関数宣言ではコロンの前にいくつかの引数を取り、定義全体で使用可能であることを示します。そしていくつかの引数はコロンの後ろに置き、この引数をパターンマッチの利用や関数ごとに定義できるようにしていることを示します。帰納的データ型でも同じ原理が働きます：引数 `α` がデータ型宣言の先頭かつコロンより前に来ている場合、これはパラメータで `Vect` 中のすべての定義の第一引数として提供されなければならないことを意味します。一方で、`Nat` 引数はコロンの後ろにあり、これは変化する可能性のあるインデックスであることを示します。実際、`nil` と `cons` コンストラクタの宣言の中で `Vect` が3回出現すると、それらすべてに一貫して `α` が第一引数として指定されますが、第二引数はそれぞれ異なります。

<!--
The declaration of `nil` states that it is a constructor of type `Vect α 0`.
This means that using `Vect.nil` in a context expecting a `Vect String 3` is a type error, just as `[1, 2, 3]` is a type error in a context that expects a `List String`:
-->

`nil` の宣言では、これが `Vect α 0` 型のコンストラクタであることが示されています。これは、ちょうど `List String` が期待されているコンテキストにおいて `[1, 2, 3]` がエラーになるように、`Vect String 3` 型が期待されているコンテキストで `Vect.nil` を使うと型エラーになるということです。

```lean
{{#example_in Examples/DependentTypes.lean nilNotLengthThree}}
```
```output error
{{#example_out Examples/DependentTypes.lean nilNotLengthThree}}
```
<!--
The mismatch between `0` and `3` in this example plays exactly the same role as any other type mismatch, even though `0` and `3` are not themselves types.
-->

この例においての `0` と `3` の食い違いはこれら自体が型でないにもかかわらず、一般的な型のミスマッチとまったく同じ役割を果たします。

<!--
Indexed families are called _families_ of types because different index values can make different constructors available for use.
In some sense, an indexed family is not a type; rather, it is a collection of related types, and the choice of index values also chooses a type from the collection.
Choosing the index `5` for `Vect` means that only the constructor `cons` is available, and choosing the index `0` means that only `nil` is available.
-->

添字族は異なる添え字の値によって使用できるコンストラクタを変えることができることから、型の **族** と呼ばれます。ある意味では、添字族は型ではありません；むしろ、関連した型のあつまりであり、添え字の選択によってそのあつまりから型を選ばれます。 `Vect` において添え字 `5` を選ぶことによってコンストラクタは `const` のみ、また添え字 `0` を選ぶことによって `nil` のみがそれぞれ利用可能となります。

<!--
If the index is not yet known (e.g. because it is a variable), then no constructor can be used until it becomes known.
Using `n` for the length allows neither `Vect.nil` nor `Vect.cons`, because there's no way to know whether the variable `n` should stand for a `Nat` that matches `0` or `n + 1`:
-->

添え字が不明である場合（例えば変数である等）、それが明らかになるまではどのコンストラクタも利用できません。長さとして `n` を用いると `Vect.nil` と `Vect.cons` のどちらも使用できません。というのも `n` が `0` と `n + 1` のどちらにマッチする `Nat` を表すのかを知るすべがないからです：

```lean
{{#example_in Examples/DependentTypes.lean nilNotLengthN}}
```
```output error
{{#example_out Examples/DependentTypes.lean nilNotLengthN}}
```
```lean
{{#example_in Examples/DependentTypes.lean consNotLengthN}}
```
```output error
{{#example_out Examples/DependentTypes.lean consNotLengthN}}
```

<!--
Having the length of the list as part of its type means that the type becomes more informative.
For example, `Vect.replicate` is a function that creates a `Vect` with a number of copies of a given value.
The type that says this precisely is:
-->

型の一部でリストの長さを保持することはその型がより有益になることを意味します。例えば、`Vect.replicate` は与えられた値のコピー回数をもとに `Vect` を作る関数です。これを正確に表す型は以下のようになります：

```lean
{{#example_in Examples/DependentTypes.lean replicateStart}}
```
<!--
The argument `n` appears as the length of the result.
The message associated with the underscore placeholder describes the task at hand:
-->

引数 `n` が結果の長さとして現れています。アンダースコアによるプレースホルダに紐づいたメッセージでは現在のタスクが説明されています：

```output error
{{#example_out Examples/DependentTypes.lean replicateStart}}
```

<!--
When working with indexed families, constructors can only be applied when Lean can see that the constructor's index matches the index in the expected type.
However, neither constructor has an index that matches `n`—`nil` matches `Nat.zero`, and `cons` matches `Nat.succ`.
Just as in the example type errors, the variable `n` could stand for either, depending on which `Nat` is provided to the function as an argument.
The solution is to use pattern matching to consider both of the possible cases:
-->

添字族を扱う際に、コンストラクタはLeanがそのコンストラクタの添字が期待される型の添字と一致することを確認できた場合にのみ適用可能です。しかし、どちらのコンストラクタも `n` にマッチする添字を持っていません。`nil` は `Nat.zero` に、`cons` は `Nat.succ` にマッチします。型エラーの例のように、変数 `n` は関数に引数として渡される `Nat` によってこのどちらかを表す可能性があります。そこで解決策としてパターンマッチを使用してありうる両方のケースを考慮することができます：

```lean
{{#example_in Examples/DependentTypes.lean replicateMatchOne}}
```
<!--
Because `n` occurs in the expected type, pattern matching on `n` _refines_ the expected type in the two cases of the match.
In the first underscore, the expected type has become `Vect α 0`:
-->

`n` は期待される型に含まれるため、`n` のパターンマッチによってマッチする2つのケースでの期待される型が **絞り込まれます** 。1つ目のアンダースコアでは、期待される型は `Vect α 0` になります：

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchOne}}
```
<!--
In the second underscore, it has become `Vect α (k + 1)`:
-->

2つ目のアンダースコアでは `Vect α (k + 1)` になります：

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchTwo}}
```
<!--
When pattern matching refines the type of a program in addition to discovering the structure of a value, it is called _dependent pattern matching_.
-->

パターンマッチが値の構造を解明することに加えてプログラムの型を絞り込む場合、これは **依存パターンマッチ** （dependent pattern matching）と呼ばれます。

<!--
The refined type makes it possible to apply the constructors.
The first underscore matches `Vect.nil`, and the second matches `Vect.cons`: 
-->

精練された型ではコンストラクタを適用することができます。1つ目のアンダースコアでは `Vect.nil` が、2つ目では `Vect.cons` がそれぞれマッチします：

```lean
{{#example_in Examples/DependentTypes.lean replicateMatchFour}}
```
<!--
The first underscore under the `.cons` should have type `α`.
There is an `α` available, namely `x`:
-->

`.cons` の中にある1つ目のアンダースコアは `α` 型でなければなりません。ここで利用可能な `α` は存在しており、まさに `x` のことです：

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchFour}}
```
<!--
The second underscore should be a `Vect α k`, which can be produced by a recursive call to `replicate`:
-->

2つ目のアンダースコアは `Vect α k` であるべきであり、これは `replicate` を再帰的に呼び出すことで生成できます：

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchFive}}
```
<!--
Here is the final definition of `replicate`:
-->

以下が `replicate` の最終的な定義です：

```lean
{{#example_decl Examples/DependentTypes.lean replicate}}
```

<!--
In addition to providing assistance while writing the function, the informative type of `Vect.replicate` also allows client code to rule out a number of unexpected functions without having to read the source code.
A version of `replicate` for lists could produce a list of the wrong length:
-->

関数を書く間の支援に加えて、`Vect.replicate` の情報に富んだ型によってクライアントコードはソースコードを読まなくても多くの予期しない関数である可能性を除外することができます。リスト用にした `replicate` では、間違った長さのリストを生成する可能性があります：

```lean
{{#example_decl Examples/DependentTypes.lean listReplicate}}
```
<!--
However, making this mistake with `Vect.replicate` is a type error:
-->

しかし、このミスは `Vect.replicate` では型エラーになります：

```lean
{{#example_in Examples/DependentTypes.lean replicateOops}}
```
```output error
{{#example_out Examples/DependentTypes.lean replicateOops}}
```


<!--
The function `List.zip` combines two lists by pairing the first entry in the first list with the first entry in the second list, the second entry in the first list with the second entry in the second list, and so forth.
`List.zip` can be used to pair the three highest peaks in the US state of Oregon with the three highest peaks in Denmark:
-->

`List.zip` は2つのリストに対して、1つ目のリストの最初の要素と2つ目のリストの最初の要素をペアに、1つ目のリストの2番目の要素と2つ目のリストの2番目の要素をペアに、という具合に結合していく関数です。`List.zip` はオレゴン州の3つの最高峰とデンマークの3つの最高峰をペアにすることができます：

```lean
{{#example_in Examples/DependentTypes.lean zip1}}
```
<!--
The result is a list of three pairs:
-->

結果は3つのペアを含むリストです：

```lean
{{#example_out Examples/DependentTypes.lean zip1}}
```
<!--
It's somewhat unclear what should happen when the lists have different lengths.
Like many languages, Lean chooses to ignore the extra entries in one of the lists.
For instance, combining the heights of the five highest peaks in Oregon with those of the three highest peaks in Denmark yields three pairs.
In particular,
-->

リストの長さが異なる場合にどうすればいいかはやや不明確です。多くの言語のように、Leanは長い方のリストの余分な要素を無視する実装を選んでいます。例えば、オレゴン州の5つの最高峰の高度とデンマークの3つの最高峰の高度を組み合わせると3つのペアができます。具体的には：

```lean
{{#example_in Examples/DependentTypes.lean zip2}}
```
<!--
evaluates to
-->

は以下に評価されます。

```lean
{{#example_out Examples/DependentTypes.lean zip2}}
```

<!--
While this approach is convenient because it always returns an answer, it runs the risk of throwing away data when the lists unintentionally have different lengths.
F# takes a different approach: its version of `List.zip` throws an exception when the lengths don't match, as can be seen in this `fsi` session:
-->

このアプローチでは必ず答えが得られる点が便利である一方、意図せず長さの異なるリストを渡した際に情報が捨てられてしまう危険性があります。F#は別のアプローチをとっています：以下の `fsi` セッションで見られるように、F#での `List.zip` では長さが異なる場合は例外を投げます：

```fsharp
> List.zip [3428.8; 3201.0; 3158.5; 3075.0; 3064.0] [170.86; 170.77; 170.35];;
```
```output error
System.ArgumentException: The lists had different lengths.
list2 is 2 elements shorter than list1 (Parameter 'list2')
   at Microsoft.FSharp.Core.DetailedExceptions.invalidArgDifferentListLength[?](String arg1, String arg2, Int32 diff) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/local.fs:line 24
   at Microsoft.FSharp.Primitives.Basics.List.zipToFreshConsTail[a,b](FSharpList`1 cons, FSharpList`1 xs1, FSharpList`1 xs2) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/local.fs:line 918
   at Microsoft.FSharp.Primitives.Basics.List.zip[T1,T2](FSharpList`1 xs1, FSharpList`1 xs2) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/local.fs:line 929
   at Microsoft.FSharp.Collections.ListModule.Zip[T1,T2](FSharpList`1 list1, FSharpList`1 list2) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/list.fs:line 466
   at <StartupCode$FSI_0006>.$FSI_0006.main@()
Stopped due to error
```
<!--
This avoids accidentally discarding information, but crashing a program comes with its own difficulties.
The Lean equivalent, which would use the `Option` or `Except` monads, would introduce a burden that may not be worth the safety.
-->

これによって誤って情報が破棄される事態を避けられますが、その代わりにプログラムをクラッシュさせてしまうことにはそれなりの困難が伴います。Leanにおいて `Option` や `Except` モナドを使うような同じアプローチをすると安全性に見合わない負担が発生します。

<!--
Using `Vect`, however, it is possible to write a version of `zip` with a type that requires that both arguments have the same length:
-->

しかし `Vect` を使えば、両方の引数が同じ長さであることを要求する型を持つバージョンの `zip` を書くことができます：

```lean
{{#example_decl Examples/DependentTypes.lean VectZip}}
```
<!--
This definition only has patterns for the cases where either both arguments are `Vect.nil` or both arguments are `Vect.cons`, and Lean accepts the definition without a "missing cases" error like the one that results from a similar definition for `List`:
-->

この定義は両方の引数が `Vect.nil` であるか、`Vect.cons` である場合のパターンを持っているだけであり、Leanは `List` に対する以下の同様の定義の結果のような `missing cases` エラーを出さずに定義を受け入れます：

```lean
{{#example_in Examples/DependentTypes.lean zipMissing}}
```
```output error
{{#example_out Examples/DependentTypes.lean zipMissing}}
```
<!--
This is because the constructor used in the first pattern, `nil` or `cons`, _refines_ the type checker's knowledge about the length `n`.
When the first pattern is `nil`, the type checker can additionally determine that the length was `0`, so the only possible choice for the second pattern is `nil`.
Similarly, when the first pattern is `cons`, the type checker can determine that the length was `k+1` for some `Nat` `k`, so the only possible choice for the second pattern is `cons`.
Indeed, adding a case that uses `nil` and `cons` together is a type error, because the lengths don't match:
-->

これは最初のパターンで使用されているコンストラクタ `nil` または `cons` が長さ `n` に関する型チェッカが持つ情報を **洗練** させるからです。最初のパターンが `nil` の場合、型チェッカは追加で長さが `0` であることを判断でき、その結果2つ目のパターンは `nil` 以外ありえなくなります。同様に、最初のパターンが `cons` の場合、型チェッカは `Nat` のある `k` に対して `k + 1` の長さだったと判断することができ、2つ目のパターンは `cons` 以外ありえなくなります。実際、`nil` と `cons` を一緒に使うケースを追加すると、長さが一致しないために型エラーになります：

```lean
{{#example_in Examples/DependentTypes.lean zipExtraCons}}
```
```output error
{{#example_out Examples/DependentTypes.lean zipExtraCons}}
```
<!--
The refinement of the length can be observed by making `n` into an explicit argument:
-->

`n` を明示的な引数にすることで、長さについての詳細化をより見やすくすることができます：

```lean
{{#example_decl Examples/DependentTypes.lean VectZipLen}}
```

<!--
## Exercises
-->

## 演習問題

<!--
Getting a feel for programming with dependent types requires experience, and the exercises in this section are very important.
For each exercise, try to see which mistakes the type checker can catch, and which ones it can't, by experimenting with the code as you go.
This is also a good way to develop a feel for the error messages.
-->

依存型を使ったプログラミングの感覚をつかむには、この節の演習問題は非常に重要です。各演習問題において、コードを試しながら、型チェッカがどのミスを捉え、どのミスを捉えられないかを試行錯誤してみてください。これはエラーメッセージに対する感覚を養う良い方法でもあります。

 <!--
 * Double-check that `Vect.zip` gives the right answer when combining the three highest peaks in Oregon with the three highest peaks in Denmark.
   Because `Vect` doesn't have the syntactic sugar that `List` has, it can be helpful to begin by defining `oregonianPeaks : Vect String 3` and `danishPeaks : Vect String 3`.
   -->

 * オレゴン州の3つの最高峰とデンマークの3つの最高峰を組み合わせたときに `Vect.zip` が正しい答えを出すかダブルチェックしてください。`Vect` には `List` のような糖衣構文がないので、まず `oregonianPeaks : Vect String 3` と `danishPeaks : Vect String 3` を定義しておくと便利でしょう。

 <!--
 * Define a function `Vect.map` with type `(α → β) → Vect α n → Vect β n`.
 -->

 * `(α → β) → Vect α n → Vect β n` 型を持つ `Vect.map` 関数を定義してください。

 <!--
 * Define a function `Vect.zipWith` that combines the entries in a `Vect` one at a time with a function.
   It should have the type `(α → β → γ) → Vect α n → Vect β n → Vect γ n`.
   -->
  
 * `Vect` の各要素を結合する際に関数を適用する関数 `Vect.zipWith` を定義してください。これは `(α → β → γ) → Vect α n → Vect β n → Vect γ n` 型になるべきです。

 <!--
 * Define a function `Vect.unzip` that splits a `Vect` of pairs into a pair of `Vect`s. It should have the type `Vect (α × β) n → Vect α n × Vect β n`.
 -->

 * 要素がペアである `Vect` を `Vect` のペアに分割する関数 `Vect.unzip` を定義してください。これは `Vect (α × β) n → Vect α n × Vect β n` 型になるべきです。

 <!--
 * Define a function `Vect.snoc` that adds an entry to the _end_ of a `Vect`. Its type should be `Vect α n → α → Vect α (n + 1)` and `{{#example_in Examples/DependentTypes.lean snocSnowy}}` should yield `{{#example_out Examples/DependentTypes.lean snocSnowy}}`. The name `snoc` is a traditional functional programming pun: it is `cons` backwards.
 -->

 * `Vect` の **末尾** に要素を追加する `Vect.snoc` を定義してください。これは `Vect α n → α → Vect α (n + 1)` 型になるべきで、`{{#example_in Examples/DependentTypes.lean snocSnowy}}` は `{{#example_out Examples/DependentTypes.lean snocSnowy}}` を返すべきです。`snoc` という名前は伝統的な関数型プログラミングのダジャレで、`cons` を逆さにしたものです。
 
 <!--
 * Define a function `Vect.reverse` that reverses the order of a `Vect`.
 -->

 * `Vect` の順序を逆にする関数 `Vect.reverse` を書いてください。
 
 <!--
 * Define a function `Vect.drop` with the following type: `(n : Nat) → Vect α (k + n) → Vect α k`.
   Verify that it works by checking that `{{#example_in Examples/DependentTypes.lean ejerBavnehoej}}` yields `{{#example_out Examples/DependentTypes.lean ejerBavnehoej}}`.
   -->

 * 次の型を持つ関数 `Vect.drop` を定義してください：`(n : Nat) → Vect α (k + n) → Vect α k` 。この関数が正しく動作することを検証するには `{{#example_in Examples/DependentTypes.lean ejerBavnehoej}}` が `{{#example_out Examples/DependentTypes.lean ejerBavnehoej}}` を返すことを確認することで行えます。

 <!--
 * Define a function `Vect.take` with type `(n : Nat) → Vect α (k + n) → Vect α n` that returns the first `n` entries in the `Vect`. Check that it works on an example.
 -->

 * 型 `(n : Nat) → Vect α (k + n) → Vect α n` で `Vect` の先頭から `n` 個の要素を返すの関数 `Vect.take` を定義してください。例をあげて動作することを確認もしてください。
