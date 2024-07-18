<!--
# Alternatives
-->

# オルタナティブ

<!--
## Recovery from Failure
-->

## 失敗からの復帰

<!--
`Validate` can also be used in situations where there is more than one way for input to be acceptable.
For the input form `RawInput`, an alternative set of business rules that implement conventions from a legacy system might be the following:
-->

`Validate` は入力を受け付ける方法が複数ある場合にも使用することができます．`RawInput` の形式の入力に対して前節の方法の代わりに，レガシーなシステムからの慣習に則ったビジネスルールは以下のようになります：

 <!--
 1. All human users must provide a birth year that is four digits.
-->
 1. すべての人間ユーザは，4桁の誕生年を記入しなければならない．
 <!--
 2. Users born prior to 1970 do not need to provide names, due to incomplete older records.
-->
 2. 1970年より前に生まれたユーザは古い記録が不完全なため氏名を記入する必要はない．
 <!--
 3. Users born after 1970 must provide names.
-->
 3. 1970年より後に生まれたユーザは氏名を記入しなければならない．
 <!--
 4. Companies should enter `"FIRM"` as their year of birth and provide a company name.
-->
 4. 企業は誕生年を `"FIRM"` とし，会社名を記入すること．
 
<!--
No particular provision is made for users born in 1970.
It is expected that they will either give up, lie about their year of birth, or call.
The company considers this an acceptable cost of doing business.
-->

1970年生まれの利用者に該当する規定はありません．これに該当する場合は入力を諦めるか，誕生年を偽るか，このサービスの会社に電話をかけるかのいずれかになるでしょう．この会社は，これはビジネス上許容できるコストだと考えています．

<!--
The following inductive type captures the values that can be produced from these stated rules:
-->

以下の帰納型は，これらの記述されたルールに基づいた値を表現しています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean LegacyCheckedInput}}
```

<!--
A validator for these rules is more complicated, however, as it must address all three cases.
While it can be written as a series of nested `if` expressions, it's easier to design the three cases independently and then combine them.
This requires a means of recovering from failure while preserving error messages:
-->

しかし，このルールに対応するバリデータは3つのケースすべてに対応しなければならないため，前節のものより複雑になります．入れ子になった一連の `if` 式として書くこともできますが，3つのケースを個別に設計しそれらを組み合わせる方が簡単です．そのためには，エラーメッセージを保持しながら失敗から回復する手段が必要になります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ValidateorElse}}
```

<!--
This pattern of recovery from failures is common enough that Lean has built-in syntax for it, attached to a type class named `OrElse`:
-->

この失敗からの復帰パターンは，Leanに `OrElese` という名前の型クラスとそれに伴う組み込みの構文があるほど一般的です：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean OrElse}}
```
<!--
The expression `{{#example_in Examples/FunctorApplicativeMonad.lean OrElseSugar}}` is short for `{{#example_out Examples/FunctorApplicativeMonad.lean OrElseSugar}}`.
An instance of `OrElse` for `Validate` allows this syntax to be used for error recovery:
-->

式 `{{#example_in Examples/FunctorApplicativeMonad.lean OrElseSugar}}` は `{{#example_out Examples/FunctorApplicativeMonad.lean OrElseSugar}}` の省略形です．`Validate` の `OrElse` インスタンスを使うことで，この構文をエラー復帰に使用することができます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean OrElseValidate}}
```

<!--
The validator for `LegacyCheckedInput` can be built from a validator for each constructor.
The rules for a company state that the birth year should be the string `"FIRM"` and that the name should be non-empty.
The constructor `LegacyCheckedInput.company`, however, has no representation of the birth year at all, so there's no easy way to carry it out using `<*>`.
The key is to use a function with `<*>` that ignores its argument.
-->

`LegacyCheckedInput` のバリデータは各コンストラクタのバリデータから構築することができます．会社用のルールでは誕生年は文字列 `"FIRM"` でなければならず，名前は空であってはなりません．しかし，コンストラクタ `LegacyCheckedInput.company` は誕生年をまったく表現しないため，単に `<*>` を使ってバリデーションすることはできません．ポイントは引数を無視する `<*>` 関数を使うことです．

<!--
Checking that a Boolean condition holds without recording any evidence of this fact in a type can be accomplished with `checkThat`:
-->

型にこの根拠を付与することなく，論理条件が成立することをチェックするには `checkThat` を使用します：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkThat}}
```
<!--
This definition of `checkCompany` uses `checkThat`, and then throws away the resulting `Unit` value:
-->

この `checkCompany` の定義は `checkThat` を使用し，その結果の `Unit` 値を捨てています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkCompanyProv}}
```

<!--
However, this definition is quite noisy.
It can be simplified in two ways.
The first is to replace the first use of `<*>` with a specialized version that automatically ignores the value returned by the first argument, called `*>`.
This operator is also controlled by a type class, called `SeqRight`, and `{{#example_in Examples/FunctorApplicativeMonad.lean seqRightSugar}}` is syntactic sugar for `{{#example_out Examples/FunctorApplicativeMonad.lean seqRightSugar}}`:
-->

しかし，この定義はかなり煩雑です．これをシンプルにするにあたって2つの方法があります．1つ目は，最初の `<*>` の使用を，最初の引数が返す値を自動的に無視する `*>` という特殊なバージョンに置き換えることです．この演算子も `SeqRight` と呼ばれる型クラスによって制御され，`{{#example_in Examples/FunctorApplicativeMonad.lean seqRightSugar}}` は `{{#example_out Examples/FunctorApplicativeMonad.lean seqRightSugar}}` の糖衣構文です：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ClassSeqRight}}
```
<!--
There is a default implementation of `seqRight` in terms of `seq`: `seqRight (a : f α) (b : Unit → f β) : f β := pure (fun _ x => x) <*> a <*> b ()`.
-->

`seqRight` の実装には `seq` によるデフォルト実装：`seqRight (a : f α) (b : Unit → f β) : f β := pure (fun _ x => x) <*> a <*> b ()` が存在します．

<!--
Using `seqRight`, `checkCompany` becomes simpler:
-->

`seqRight` を使うことで，`checkCompany` はもっとシンプルになります：
```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkCompanyProv2}}
```
<!--
One more simplification is possible.
For every `Applicative`, `pure F <*> E` is equivalent to `f <$> E`.
In other words, using `seq` to apply a function that was placed into the `Applicative` type using `pure` is overkill, and the function could have just been applied using `Functor.map`.
This simplification yields:
-->

さらなる簡略化も可能です．すべての `Applicative` に対して，`pure F <*> E` は `f <$> E` と等価です．言い換えると，`pure` で `Applicative` 内に置かれた関数を `seq` を使って適用するのはやりすぎであり，`Functor.map` を使って適用すればよかったのです．この簡略化は以下のようになります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkCompany}}
```

<!--
The remaining two constructors of `LegacyCheckedInput` use subtypes for their fields.
A general-purpose tool for checking subtypes will make these easier to read:
-->

`LegacyCheckedInput` の残り2つのコンストラクタは，フィールドに部分型を使用しています．部分型をチェックする汎用的なツールがあれば，さらに読みやすくなるでしょう：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkSubtype}}
```
<!--
In the function's argument list, it's important that the type class `[Decidable (p v)]` occur after the specification of the arguments `v` and `p`.
Otherwise, it would refer to an additional set of automatic implicit arguments, rather than to the manually-provided values.
The `Decidable` instance is what allows the proposition `p v` to be checked using `if`.
-->

関数の引数リストにて，引数 `v` と `p` を指定した後に `[Decidable (p v)]` という型クラスが来ていることがミソです．そうでなければ手動で指定した値ではなく，自動的な暗黙の引数を追加で参照することになります．`Decidable` インスタンスは，命題 `p v` を `if` を使ってチェックできるようにするものです．

<!--
The two human cases do not need any additional tools:
-->

人間についての2つのケースでは追加の道具は必要ありません：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkHumanBefore1970}}

{{#example_decl Examples/FunctorApplicativeMonad.lean checkHumanAfter1970}}
```

<!--
The validators for the three cases can be combined using `<|>`:
-->

以上の3つのケースのバリデータは `<|>` を使って組み合わせることができます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkLegacyInput}}
```

<!--
The successful cases return constructors of `LegacyCheckedInput`, as expected:
-->

成功したケースでは，期待通りに `LegacyCheckedInput` のコンストラクタが返されます：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean trollGroomers}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean trollGroomers}}
```
```lean
{{#example_in Examples/FunctorApplicativeMonad.lean johnny}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean johnny}}
```
```lean
{{#example_in Examples/FunctorApplicativeMonad.lean johnnyAnon}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean johnnyAnon}}
```

<!--
The worst possible input returns all the possible failures:
-->

最悪の入力においては，起こりうるすべての失敗が返されます：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean allFailures}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean allFailures}}
```


<!--
## The `Alternative` Class
-->

## `Alternative` クラス

<!--
Many types support a notion of failure and recovery.
The `Many` monad from the section on [evaluating arithmetic expressions in a variety of monads](../monads/arithmetic.md#nondeterministic-search) is one such type, as is `Option`.
Both support failure without providing a reason (unlike, say, `Except` and `Validate`, which require some indication of what went wrong).
-->

多くの型が失敗と復帰の概念をサポートしています．[様々なモナドでの算術式の評価](../monads/arithmetic.md#nondeterministic-search) についての節で定義した `Many` モナドや，`Option` 型はそのような型の1つです．どちらも失敗に対して理由を付与しません（一方で `Except` と `Validate` では何が間違っていたのかを示す必要があります）．

<!--
The `Alternative` class describes applicative functors that have additional operators for failure and recovery:
-->

`Alternative` クラスはアプリカティブ関手に失敗と復帰のための演算子を追加したものとして記述されます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FakeAlternative}}
```
<!--
Just as implementors of `Add α` get `HAdd α α α` instances for free, implementors of `Alternative` get `OrElse` instances for free:
-->

`Add α` の実装者が `HAdd α α α` のインスタンスをタダで取得できるように，`Alternative` の実装者は `OrElse` インスタンスを何もせずに手に入れることができます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean AltOrElse}}
```

<!--
The implementation of `Alternative` for `Option` keeps the first none-`none` argument:
-->

`Option` に対する `Alternative` は引数のうち一番初めの非 `none` を保持するように実装されます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean AlternativeOption}}
```
<!--
Similarly, the implementation for `Many` follows the general structure of `Many.union`, with minor differences due to the laziness-inducing `Unit` parameters being placed differently:
-->

同様に，`Many` の実装は `Many.union` の一般的な構造に従っていますが，遅延評価のための `Unit` パラメータの配置が異なるため若干の違いがあります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean AlternativeMany}}
```

<!--
Like other type classes, `Alternative` enables the definition of a variety of operations that work for _any_ applicative functor that implements `Alternative`.
One of the most important is `guard`, which causes `failure` when a decidable proposition is false:
-->

他の型クラスと同様に，`Alternative` は `Alternative` を実装したアプリカティブ関手 **すべて** に対して機能する様々な操作を定義することができます．最も重要なもののの1つは `guard` で，これは決定可能な命題が偽の場合に `failure` を実行します：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean guard}}
```
<!--
It is very useful in monadic programs to terminate execution early.
In `Many`, it can be used to filter out a whole branch of a search, as in the following program that computes all even divisors of a natural number:
-->

これはモナドを使ったプログラムの実行を早期に終了させるのに非常に便利です．`Many` においては，自然数のすべての偶数の約数を計算する以下のプログラムのように，検索の分岐全体をフィルタリングするために使うことができます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean evenDivisors}}
```
<!--
Running it on `20` yields the expected results:
-->

`20` に対して実行すると予想通りの結果を得ます：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean evenDivisors20}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean evenDivisors20}}
```


<!--
## Exercises
-->

## 演習問題

<!--
### Improve Validation Friendliness
-->

## バリデータの利便性向上

<!--
The errors returned from `Validate` programs that use `<|>` can be difficult to read, because inclusion in the list of errors simply means that the error can be reached through _some_ code path.
A more structured error report can be used to guide the user through the process more accurately:
-->

`<|>` を使用した `Validate` プログラムから返されるエラーは読みにくいものになります．というのも，あるエラーがエラーのリストに含まれているということは，ただ単にそのエラーがバリデーション中の経路の **どこか** で発生したということを意味します．より構造化されたエラーレポートがあれば，ユーザをより正確に導くことができます：

 <!--
 * Replace the `NonEmptyList` in `Validate.error` with a bare type variable, and then update the definitions of the `Applicative (Validate ε)` and `OrElse (Validate ε α)` instances to require only that there be an `Append ε` instance available.
-->
 * `Validate.error` 内の `NonEmptyList` をただの型変数に置き換え，`Applicative (Validate ε)` と `OrElse (Validate ε α)` インスタンスの定義を更新して `Append ε` インスタンスが利用可能であることだけを要求するようにしてください．
 <!--
 * Define a function `Validate.mapErrors : Validate ε α → (ε → ε') → Validate ε' α` that transforms all the errors in a validation run.
-->
 * バリデーション中に発生するすべてのエラーを変換する関数 `Validate.mapErrors : Validate ε α → (ε → ε') → Validate ε' α` を定義してください．
 <!--
 * Using the datatype `TreeError` to represent errors, rewrite the legacy validation system to track its path through the three alternatives.
-->
 * エラーを表すデータ型 `TypeError` を使って，レガシーなバリデーションシステムを書き換えることで3つの選択肢を通してその経路を追跡できるようにしてください．
 <!--
 * Write a function `report : TreeError → String` that outputs a user-friendly view of the `TreeError`'s accumulated warnings and errors.
-->
 * `TypeError` に蓄積された警告とエラーをユーザフレンドリに出力する関数 `report : TreeError → String` を書いてください．
 
```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean TreeError}}
```


