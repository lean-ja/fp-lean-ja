<!--
# A Monad Construction Kit
-->

# モナド組み立てキット

<!--
`ReaderT` is far from the only useful monad transformer.
This section describes a number of additional transformers.
Each monad transformer consists of the following:
-->

`ReaderT` だけが便利なモナド変換子ではありません。本節では、さらに多くの変換子について説明します。各モナド変換子は以下のように構成されています：

 <!--
 1. A definition or datatype `T` that takes a monad as an argument.
    It should have a type like `(Type u → Type v) → Type u → Type v`, though it may accept additional arguments prior to the monad.
-->
 1. モナドを引数に取る定義もしくはデータ型 `T` 。これは `(Type u → Type v) → Type u → Type v` のような型を持ちますが、モナドの前に別で引数を受け取ることもできます。
 <!--
 2. A `Monad` instance for `T m` that relies on an instance of `Monad m`. This enables the transformed monad to be used as a monad.
-->
 2. `Monad m` のインスタンスに依存した `T m` の `Monad` インスタンス。これにより変換されたモナドをモナドとして使うことができます。
 <!--
 3. A `MonadLift` instance that translates actions of type `m α` into actions of type `T m α`, for arbitrary monads `m`. This enables actions from the underlying monad to be used in the transformed monad.
-->
 3. 任意のモナド `m` に対して `m α` 型のアクションを `T m α` 型のアクションに変換する `MonadLift` インスタンス。これにより、変換後のモナドでベースとなったモナドのアクションを使用できるようになります。

<!--
Furthermore, the `Monad` instance for the transformer should obey the contract for `Monad`, at least if the underlying `Monad` instance does.
In addition, `monadLift (pure x)` should be equivalent to `pure x` in the transformed monad, and `monadLift` should distribute over `bind` so that `monadLift (x >>= f)` is the same as `monadLift x >>= fun y => monadLift (f y)`.
-->

さらに、変換子の `Monad` インスタンスはベースとなった `Monad` インスタンスがモナドの約定に従うのであれば `Monad` の約定に従わなければなりません。加えて、`monadLift (pure x)` は変換後のモナドでは `pure x` と等価、`monadLift` は `monadLift (x >>= f)` が `monadLift x >>= fun y => monadLift (f y)` と同じになるように `bind` に対して分配されるべきです。

<!--
Many monad transformers additionally define type classes in the style of `MonadReader` that describe the actual effects available in the monad.
This can provide more flexibility: it allows programs to be written that rely only on an interface, and don't constrain the underlying monad to be implemented by a given transformer.
The type classes are a way for programs to express their requirements, and monad transformers are a convenient way to meet these requirements.
-->

多くのモナド変換子はさらに `MonadReader` というスタイルでモナドで利用可能な実際の作用を記述する型クラスを定義しています。これによりコードが柔軟さを増します：インタフェースにのみ依存するプログラムを書くことができるようになり、ベースのモナドに対して特定の変換子によって実装されることが要求されません。型クラスはプログラムが要求を表現するための方法であり、モナド変換子はこれらの要求を満たすための便利なツールです。

<!--
## Failure with `OptionT`
-->

## `OptionT` による失敗

<!--
Failure, represented by the `Option` monad, and exceptions, represented by the `Except` monad, both have corresponding transformers.
In the case of `Option`, failure can be added to a monad by having it contain values of type `Option α` where it would otherwise contain values of type `α`.
For example, `IO (Option α)` represents `IO` actions that don't always return a value of type `α`.
This suggests the definition of the monad transformer `OptionT`:
-->

`Option` モナドで表現される失敗と `Except` モナドで表現される例外はどちらもそれぞれ対応する変換子があります。`Option` の場合、別のモナドに失敗を追加するには、そのモナドが通常なら含んでいる `α` 型ではなく `Option α` 型を保持するようにすることで可能です。例えば、`IO (Option α)` はいつも `α` 型を返すとは限らないような `IO` アクションを表します。これよりモナド変換子 `OptionT` の定義が導かれます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean OptionTdef}}
```

<!--
As an example of `OptionT` in action, consider a program that asks the user questions.
The function `getSomeInput` asks for a line of input and removes whitespace from both ends.
If the resulting trimmed input is non-empty, then it is returned, but the function fails if there are no non-whitespace characters:
-->

実際の `OptionT` の例として、ユーザに質問するプログラムを考えてみましょう。関数 `getSomeInput` は一行の入力を受け取り、その両端から空白を取り除きます。切り取られた入力が空でなければそれを返しますが、空白以外の文字がなければ関数は失敗します：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean getSomeInput}}
```
<!--
This particular application tracks users with their name and their favorite species of beetle:
-->

この関数を用いたアプリケーションとして、ユーザの名前と好きなカブトムシの種類を確認するものを作れます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean UserInfo}}
```
<!--
Asking the user for input is no more verbose than a function that uses only `IO` would be:
-->

ユーザに入力を求めても、`IO` だけを使う関数のような冗長さはありません：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean getUserInfo}}
```
<!--
However, because the function runs in an `OptionT IO` context rather than just in `IO`, failure in the first call to `getSomeInput` causes the whole `getUserInfo` to fail, with control never reaching the question about beetles.
The main function, `interact`, invokes `getUserInfo` in a purely `IO` context, which allows it to check whether the call succeeded or failed by matching on the inner `Option`:
-->

しかし、この関数は単なる `IO` ではなく `OptionT IO` コンテキストで実行されるため、最初の `getSomeInput` の呼び出しに失敗すると、制御がカブトムシに関する質問に到達せずに `getUserInfo` 全体も失敗します。メインの関数である `interact` は純粋な `IO` のコンテキストで `getUserInfo` を呼び出し、これによってその中の `Option` をパターンマッチすることで呼び出しが成功したか失敗したかチェックすることができます。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean interact}}
```

<!--
### The Monad Instance
-->

### `OptionT` のモナドインスタンス

<!--
Writing the monad instance reveals a difficulty.
Based on the types, `pure` should use `pure` from the underlying monad `m` together with `some`.
Just as `bind` for `Option` branches on the first argument, propagating `none`, `bind` for `OptionT` should run the monadic action that makes up the first argument, branch on the result, and then propagate `none`.
Following this sketch yields the following definition, which Lean does not accept:
-->

モナドインスタンスを書いてみると難点が明らかになります。型に基づくと、`pure` はベースとなるモナド `m` の `pure` を `some` と共に使用する必要があります。ちょうど `Option` の `bind` が最初の引数で分岐し、`none` を伝播するように、`OptionT` の `bind` は最初の引数を構成するモナドアクションを実行し、その結果で分岐して `none` を伝播しなければなりません。この構想に従うと以下の定義が得られますが、Leanはこれを受け入れません：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean firstMonadOptionT}}
```
<!--
The error message shows a cryptic type mismatch:
-->

エラーメッセージには不可解な型の不一致が示されます：

```output error
{{#example_out Examples/MonadTransformers/Defs.lean firstMonadOptionT}}
```
<!--
The problem here is that Lean is selecting the wrong `Monad` instance for the surrounding use of `pure`.
Similar errors occur for the definition of `bind`.
One solution is to use type annotations to guide Lean to the correct `Monad` instance:
-->

問題はLeanが `pure` を使用するにあたって間違った `Monad` インスタンスを選択していることです。同様のエラーは `bind` の定義でも発生します。これに対する1つの解決策は、型注釈を使ってLeanに正しい `Monad` インスタンスを教えてあげることです：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadOptionTAnnots}}
```
<!--
While this solution works, it is inelegant and the code becomes a bit noisy.
-->

この解決策は機能しますが、エレガントではないですし、コードも少々煩雑になります。

<!--
An alternative solution is to define functions whose type signatures guide Lean to the correct instances.
In fact, `OptionT` could have been defined as a structure:
-->

別の解決策は、型注釈がLeanを正しいインスタンスに導く関数を定義することです。実は `OptionT` は構造体として定義することもできます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean OptionTStructure}}
```
<!--
This would solve the problem, because the constructor `OptionT.mk` and the field accessor `OptionT.run` would guide type class inference to the correct instances.
The downside to doing this is that structure values would need to be allocated and deallocated repeatedly when running code that uses it, while the direct definition is a compile-time-only feature.
The best of both worlds can be achieved by defining functions that serve the same role as `OptionT.mk` and `OptionT.run`, but that work with the direct definition:
-->

これにより、コンストラクタ `OptionT.mk` とフィールドアクセサ `OptionT.run` が型クラス推論を正しいインスタンスに導くため問題は解決します。この解決策の欠点は、直接の定義はコンパイル時のみの特徴である一方で、構造体の値を使用するコードでは実行時に構造体の値のメモリ確保と解放を繰り返し行う必要があることです。両方の長所を生かすには、`OptionT.mk` と `OptionT.run` と同じ役割を果たしつつ、しかし直接の定義で動くような関数を定義することです：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean FakeStructOptionT}}
```
<!--
Both functions return their inputs unchanged, but they indicate the boundary between code that is intended to present the interface of `OptionT` and code that is intended to present the interface of the underlying monad `m`.
Using these helpers, the `Monad` instance becomes more readable:
-->

どちらの関数も入力を変更せずに返しますが、`OptionT` のインタフェースを提示するつもりのコードと、ベースのモナド `m` のインタフェースを提示するつもりのコードとの境界をはっきりさせます。これらの補助関数を使うことで、`Monad` インスタンスはより読みやすくなります：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadOptionTFakeStruct}}
```
<!--
Here, the use of `OptionT.mk` indicates that its arguments should be considered as code that uses the interface of `m`, which allows Lean to select the correct `Monad` instances.
-->

ここで、`OptionT.mk` を使うことによって、その引数が `m` のインタフェースを使用するコードと見做されるべきことが示され、これによってLeanは正しい `Monad` インスタンスを選択することができます。

<!--
After defining the monad instance, it's a good idea to check that the monad contract is satisfied.
The first step is to show that `bind (pure v) f` is the same as `f v`.
Here's the steps:
-->

モナドインスタンスを定義した後、モナドの約定が満たされていることをチェックするのは良い考えです。最初のステップは `bind (pure v) f` が `f v` と同じであることを示すことです。以下がその手順です：

{{#equations Examples/MonadTransformers/Defs.lean OptionTFirstLaw}}

<!--
The second rule states that `bind w pure` is the same as `w`.
To demonstrate this, unfold the definitions of `bind` and `pure`, yielding:
-->

2つ目のルールは `bind w pure` が `w` に等しいというものです。これを示すために、`bind` と `pure` の定義を展開してみましょう：

```lean
OptionT.mk do
    match ← w with
    | none => pure none
    | some v => pure (some v)
```
<!--
In this pattern match, the result of both cases is the same as the pattern being matched, just with `pure` around it.
In other words, it is equivalent to `w >>= fun y => pure y`, which is an instance of `m`'s second monad rule.
-->

このパターンマッチでは、どちらのケースでもマッチされたパターンと同じ結果になります。つまり、これは `w >>= fun y => pure y` と等価であり、`m` の2番目のモナドルールのインスタンスです。

<!--
The final rule states that `bind (bind v f) g`  is the same as `bind v (fun x => bind (f x) g)`.
It can be checked in the same way, by expanding the definitions of `bind` and `pure` and then delegating to the underlying monad `m`.
-->

最後のルールは `bind (bind v f) g` が `bind v (fun x => bind (f x) g)` と同じというものです。これも `bind` と `pure` の定義を展開し、ベースのモナド `m` に委譲することで同じようにチェックすることができます。

<!--
### An `Alternative` Instance
-->

### `Alternative` インスタンス

<!--
One convenient way to use `OptionT` is through the `Alternative` type class.
Successful return is already indicated by `pure`, and the `failure` and `orElse` methods of `Alternative` provide a way to write a program that returns the first successful result from a number of subprograms:
-->

`OptionT` の便利な使用例として、`Alternative` 型クラスを使用するというものがあります。成功した結果は `pure` によって既に示されており、`Alternative` の `failure` メソッドと `orElse` メソッドによって複数のサブプログラムから最初に成功した結果を返すプログラムを書くことができます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean AlternativeOptionT}}
```


<!--
### Lifting
-->

### 持ち上げ

<!--
Lifting an action from `m` to `OptionT m` only requires wrapping `some` around the result of the computation:
-->

アクションを `m` から `OptionT m` に持ち上げるには計算結果を `some` で囲むだけで良いです：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean LiftOptionT}}
```


<!--
## Exceptions
-->

## 例外

<!--
The monad transformer version of `Except` is very similar to the monad transformer version of `Option`.
Adding exceptions of type `ε` to some monadic action of type `m α` can be accomplished by adding exceptions to `α`, yielding type `m (Except ε α)`:
-->

モナド変換子版の `Except` は同じくモナド変換子版の `Option` にとてもよく似ています。型 `m α` の何かしらのモナドのアクションに型 `ε` の例外を追加するには `α` に例外を追加して `m (Except ε α)` 型を生成することでできます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptT}}
```
<!--
`OptionT` provides `mk` and `run` functions to guide the type checker towards the correct `Monad` instances.
This trick is also useful for `ExceptT`:
-->

`OptionT` では `mk` と `run` 関数を使って型チェッカに正しい `Monad` インスタンスを導いていました。この技法は `ExceptT` でも有効です：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTFakeStruct}}
```
<!--
The `Monad` instance for `ExceptT` is also very similar to the instance for `OptionT`.
The only difference is that it propagates a specific error value, rather than `none`:
-->

`ExceptT` の `Monad` インスタンスも `OptionT` 版のインスタンスにそっくりです。唯一の違いは `none` の代わりに特定のエラー値を伝播することです：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadExceptT}}
```

<!--
The type signatures of `ExceptT.mk` and `ExceptT.run` contain a subtle detail: they annotate the universe levels of `α` and `ε` explicitly.
If they are not explicitly annotated, then Lean generates a more general type signature in which they have distinct polymorphic universe variables.
However, the definition of `ExceptT` expects them to be in the same universe, because they can both be provided as arguments to `m`.
This can lead to a problem in the `Monad` instance where the universe level solver fails to find a working solution:
-->

`ExceptT.mk` と `ExceptT.run` の型注釈にはひっそりとですが細かい指定があります：`α` と `ε` の宇宙レベルが明示的にアノテーションされています。もしこれらが明示的にアノテーションされていない場合、Leanは `α` と `ε` に異なる多相宇宙変数を割り当てたより一般的な型注釈を生成します。しかし、`ExceptT` の定義ではどちらも `m` の引数に指定できるため、同じ宇宙であることが期待されます。これにより `Monad` インスタンスにて、宇宙レベルの解決に失敗してしまう事態を引き起こす可能性があります：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTNoUnis}}

{{#example_in Examples/MonadTransformers/Defs.lean MonadMissingUni}}
```
```output error
{{#example_out Examples/MonadTransformers/Defs.lean MonadMissingUni}}
```
<!--
This kind of error message is typically caused by underconstrained universe variables.
Diagnosing it can be tricky, but a good first step is to look for reused universe variables in some definitions that are not reused in others.
-->

この手のエラーメッセージは通常、制約不足の宇宙変数が原因です。これを診断するのは難しいですが、解析の最初の一歩としてある定義で再利用され、ほかの定義では再利用されていない宇宙変数を探すと良いでしょう。

<!--
Unlike `Option`, the `Except` datatype is typically not used as a data structure.
It is always used as a control structure with its `Monad` instance.
This means that it is reasonable to lift `Except ε` actions into `ExceptT ε m`, as well as actions from the underlying monad `m`.
Lifting `Except` actions into `ExceptT` actions is done by wrapping them in `m`'s `pure`, because an action that only has exception effects cannot have any effects from the monad `m`:
-->

`Option` とは異なり、`Except` データ型は通常、データ構造として使用されることはありません。いつも `Monad` インスタンスを持った制御構造として使用されます。このことから、`Except ε` のアクションを `ExceptT ε m` に持ち上げてベースのモナド `m` のアクションのようにするのは合理的でしょう。例外の作用しか持たないアクションはモナド `m` からの作用を持つことができないため、`Except` のアクションを `ExceptT` のアクションに持ち上げるには `m` の `pure` で包みます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTLiftExcept}}
```
<!--
Because actions from `m` do not have any exceptions in them, their value should be wrapped in `Except.ok`.
This can be accomplished using the fact that `Functor` is a superclass of `Monad`, so applying a function to the result of any monadic computation can be accomplished using `Functor.map`:
-->

`m` のアクションはその中に例外を持たないため、その値を `Except.ok` で包む必要があります。これは `Functor` が `Monad` のスーパークラスであることを利用して実現できます。つまり、関数を任意のモナドの計算結果に適用するために `Functor.map` を利用します：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTLiftM}}
```

<!--
### Type Classes for Exceptions
-->

### 例外の型クラス

<!--
Exception handling fundamentally consists of two operations: the ability to throw exceptions, and the ability to recover from them.
Thus far, this has been accomplished using the constructors of `Except` and pattern matching, respectively.
However, this ties a program that uses exceptions to one specific encoding of the exception handling effect.
Using a type class to capture these operations allows a program that uses exceptions to be used in _any_ monad that supports throwing and catching.
-->

例外処理は基本的に2つの操作から成り立ちます：例外を投げる機能と例外から回復する機能です。これまでは、この2つの機能はそれぞれ `Except` のコンストラクタとパターンマッチを使って実現してきました。しかし、これでは例外を使用するプログラムを例外処理作用に限定した実装になってしまいます。型クラスを使用してこれらの操作をキャプチャすることで、例外を使用するプログラムで例外のスローとキャッチをサポートする **任意の** モナドを使うことができるようになります。

<!--
Throwing an exception should take an exception as an argument, and it should be allowed in any context where a monadic action is requested.
The "any context" part of the specification can be written as a type by writing `m α`—because there's no way to produce a value of any arbitrary type, the `throw` operation must be doing something that causes control to leave that part of the program.
Catching an exception should accept any monadic action together with a handler, and the handler should explain how to get back to the action's type from an exception:
-->

例外を投げるには例外を引数として取り、モナドのアクションが要求される任意のコンテキストで可能であるべきです。ここで言う「任意のコンテキスト」は `m α` と書くことで型として記述できます。なぜなら任意の型を生成することはできないため、`throw` 操作はプログラム中のその部分から制御を離脱させるようなことをしなければならないからです。例外のキャッチは任意のモナドのアクションと一緒にハンドラを受け入れるべきです。このハンドラは例外からアクションの型に戻る方法を説明するべきです：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadExcept}}
```

<!--
The universe levels on `MonadExcept` differ from those of `ExceptT`.
In `ExceptT`, both `ε` and `α` have the same level, while `MonadExcept` imposes no such limitation.
This is because `MonadExcept` never places an exception value inside of `m`.
The most general universe signature recognizes the fact that `ε` and `α` are completely independent in this definition.
Being more general means that the type class can be instantiated for a wider variety of types.
-->

`MonadExcept` の宇宙レベルは `ExceptT` のそれとは異なります。`ExceptT` では `ε` と `α` は同じレベルでしたが、`MonadExcept` ではそのような制限は課しません。これは `MonadExcept` では例外の値を `m` の中に置くことがないからです。この最大限に一般的な宇宙シグネチャから、この定義において `ε` と `α` が完全に独立しているということが認識されます。より一般的であるということは、型クラスがより多様な型に対してインスタンス化できるということです。

<!--
An example program that uses `MonadExcept` is a simple division service.
The program is divided into two parts: a frontend that supplies a user interface based on strings that handles errors, and a backend that actually does the division.
Both the frontend and the backend can throw exceptions, the former for ill-formed input and the latter for division by zero errors.
The exceptions are an inductive type:
-->

`MonadExcept` を使ったプログラムの例として簡単な割り算サービスを考えてみましょう。プログラムは2つのパーツに分けられます：ユーザにエラーハンドリング付きで文字列ベースのフロントエンドと、実際に割り算を行うバックエンドです。フロントエンドとバックエンドはどちらも例外を投げます。前者は不正な入力に対して、後者はゼロ除算エラーに対してです。これらの例外は以下の帰納型で表されます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ErrEx}}
```
<!--
The backend checks for zero, and divides if it can:
-->

バックエンドはゼロであるかをチェックし、可能な場合は割り算を実行します：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean divBackend}}
```
<!--
The frontend's helper `asNumber` throws an exception if the string it is passed is not a number.
The overall frontend converts its inputs to `Int`s and calls the backend, handling exceptions by returning a friendly string error:
-->

フロントエンドの補助関数 `asNumber` は渡された文字列が数値でない場合に例外を発生させます。フロントエンド全体は入力を `Int` に変換し、バックエンドを呼びつつ例外が発生した際には読みやすい文字列のエラーを返します：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean asNumber}}

{{#example_decl Examples/MonadTransformers/Defs.lean divFrontend}}
```
<!--
Throwing and catching exceptions is common enough that Lean provides a special syntax for using `MonadExcept`.
Just as `+` is short for `HAdd.hAdd`, `try` and `catch` can be used as shorthand for the `tryCatch` method:
-->

例外のスローとキャッチはよく使われる機能であるため、Leanでは `MonadExcept` を使った特別な記法を用意しています。`+` が `HAdd.hAdd` の省略形だったように、`try` と `catch` は `tryCatch` メソッドの省略形として使用できます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean divFrontendSugary}}
```

<!--
In addition to `Except` and `ExceptT`, there are useful `MonadExcept` instances for other types that may not seem like exceptions at first glance.
For example, failure due to `Option` can be seen as throwing an exception that contains no data whatsoever, so there is an instance of `{{#example_out Examples/MonadTransformers/Defs.lean OptionExcept}}` that allows `try ... catch ...` syntax to be used with `Option`.
-->

`Except` と `ExceptT` に加えて、 `MonadExcept` のインスタンスには一見すると例外とは思えないような型に対しての便利なインスタンスが存在します。例えば、`Option` による失敗は何のデータも含まない例外を投げていると見ることができるため、`Option` と一緒に `try ... catch ...` 構文を使うための `{{#example_out Examples/MonadTransformers/Defs.lean OptionExcept}}` インスタンスが存在します。

<!--
## State
-->

## 状態

<!--
A simulation of mutable state is added to a monad by having monadic actions accept a starting state as an argument and return a final state together with their result.
The bind operator for a state monad provides the final state of one action as an argument to the next action, threading the state through the program.
This pattern can also be expressed as a monad transformer:
-->

あるモナドにて可変状態のシミュレーションを行えるようにするには、そのモナドのアクションが引数として開始状態を受け取り、その結果と一緒に最終状態を返すことでできます。状態モナドの束縛演算子はあるアクションの最終状態を次のアクションへ引数として渡し、プログラム中の状態を縫い合わせます。このパターンはモナド変換子でも表現されます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean DefStateT}}
```


<!--
Once again, the monad instance is very similar to that for `State`.
The only difference is that the input and output states are passed around and returned in the underlying monad, rather than with pure code:
-->

ここでもまた、このモナドのインスタンスは `State` のインスタンスに非常に似ています。唯一の違いは、入力と出力の状態が純粋なコードではなく、ベースのモナドの中で受け渡され、返される点です：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadStateT}}
```

<!--
The corresponding type class has `get` and `set` methods.
One downside of `get` and `set` is that it becomes too easy to `set` the wrong state when updating it.
This is because retrieving the state, updating it, and saving the updated state is a natural way to write some programs.
For example, the following program counts the number of diacritic-free English vowels and consonants in a string of letters:
-->

これに対応する型クラスは `get` と `set` メソッドを持ちます。`get` と `set` の欠点の一つに、状態を更新する際に間違った状態をあまりにも容易に `set` できるようにしてしまうというものがあります。これは状態を取得・更新し、更新された状態を保存するという流れがプログラムによっては自然な書き方だからです。例えば、以下のプログラムは文字列中の発音区別のない英語の母音と子音の数をかぞえます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLetters}}
```
<!--
It would be very easy to write `set st` instead of `set st'`.
In a large program, this kind of mistake can lead to difficult-to-diagnose bugs.
-->

ここで `set st'` の代わりに `set st` といとも簡単に書き間違えうるのです。大きなプログラムでは、このようなミスは解析の難しいバグにつながる可能性があります。

<!--
While using a nested action for the call to `get` would solve this problem, it can't solve all such problems.
For example, a function might update a field on a structure based on the values of two other fields.
This would require two separate nested-action calls to `get`.
Because the Lean compiler contains optimizations that are only effective when there is a single reference to a value, duplicating the references to the state might lead to code that is significantly slower.
Both the potential performance problem and the potential bug can be worked around by using `modify`, which transforms the state using a function:
-->

`get` の呼び出しにネストしたアクションを使えばこの問題は解決しますが、いつでもこのやり方が通用するわけではありません。例えば、構造体のあるフィールドを別の2つのフィールドをもとに更新する関数を考えます。この場合、`get` に対するネストされたアクションを別々に2度呼び出す必要があります。Leanのコンパイラは値の参照が1つの場合にのみ有効な最適化を含むため、状態への参照が重複するとコードが著しく遅くなる可能性があります。潜在的なパフォーマンスの問題と潜在的なバグの両方を回避するには、状態の変換に関数を用いる `modify` を使用することで対処できます：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLettersModify}}
```
<!--
The type class contains a function akin to `modify` called `modifyGet`, which allows the function to both compute a return value and transform an old state in a single step.
The function returns a pair in which the first element is the return value, and the second element is the new state; `modify` just adds the constructor of `Unit` to the pair used in `modifyGet`:
-->

この型クラスは `modify` に似た `modifyGet` という関数を持っており、これは戻り値の計算と古い状態の変換の両方を一度に行うことができます。この関数は最初の要素が戻り値で2番目の要素が新しい状態であるペアを返します；`modify` は `Unit` のコンストラクタを `modifyGet` で使われているこのペアにただ追加しただけの関数です：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean modify}}
```

<!--
The definition of `MonadState` is as follows:
-->

`MonadState` の定義は以下の通りです：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadState}}
```
<!--
`PUnit` is a version of the `Unit` type that is universe-polymorphic to allow it to be in `Type u` instead of `Type`.
While it would be possible to provide a default implementation of `modifyGet` in terms of `get` and `set`, it would not admit the optimizations that make `modifyGet` useful in the first place, rendering the method useless.
-->

`PUnit` は `Unit` 型を宇宙多相にして `Type` の代わりに `Type u` にできるようにしたものです。`modifyGet` には `get` と `set` を用いたデフォルト実装を利用することも可能ですが、その場合はそもそも `modifyGet` を便利にするための最適化が働かないためデフォルト実装は役に立ちません。

<!--
## `Of` Classes and `The` Functions
-->

## `Of` クラスと `The` 関数

<!--
Thus far, each monad type class that takes extra information, like the type of exceptions for `MonadExcept` or the type of the state for `MonadState`, has this type of extra information as an output parameter.
For simple programs, this is generally convenient, because a monad that combines one use each of `StateT`, `ReaderT`, and `ExceptT` has only a single state type, environment type, and exception type.
As monads grow in complexity, however, they may involve multiple states or errors types.
In this case, the use of an output parameter makes it impossible to target both states in the same `do`-block.
-->

ここまで見てきた、`MonadExcept` の例外の型や、`MonadState` の状態の型のように追加の情報を受け取るモナドの型クラスはすべてこの追加情報の型を出力パラメータとして保持していました。単純なプログラムであれば、`StateT` 、`ReaderT` 、`ExceptT` からどれか1つを組み合わせたモナドは状態の型、環境の型、例外の型のうちどれか1つしか持たないため一般的に利用しやすいです。しかし。モナドが複雑になってくると複数の状態やエラーの型を含むようになります。この場合、出力パラメータを用いると同じ `do` ブロックで両方の状態をターゲットにすることができなくなります。

<!--
For these cases, there are additional type classes in which the extra information is not an output parameter.
These versions of the type classes use the word `Of` in the name.
For example, `MonadStateOf` is like `MonadState`, but without an `outParam` modifier.
-->

このような場合のために、追加の情報を出力パラメータとしない追加の型クラスがあります。これらの型クラスでは名前に `Of` という単語を使っています。例えば、`MonadStateOf` は `MonadState` に似ていますが、`outParam` 修飾子を持ちません：

<!--
Similarly, there are versions of the type class methods that accept the type of the extra information as an _explicit_, rather than implicit, argument.
For `MonadStateOf`, there are `{{#example_in Examples/MonadTransformers/Defs.lean getTheType}}` with type
-->

同じように、追加情報の型を暗黙の引数ではなく **明示的に** 受け取る型クラスのメソッドがあります。`MonadStateOf` の場合、`{{#example_in Examples/MonadTransformers/Defs.lean getTheType}}` があり、型は次のようになります：

```lean
{{#example_out Examples/MonadTransformers/Defs.lean getTheType}}
```
<!--
and `{{#example_in Examples/MonadTransformers/Defs.lean modifyTheType}}` with type
-->

また `{{#example_in Examples/MonadTransformers/Defs.lean modifyTheType}}` は以下の型になります。

```lean
{{#example_out Examples/MonadTransformers/Defs.lean modifyTheType}}
```
<!--
There is no `setThe` because the type of the new state is enough to decide which surrounding state monad transformer to use.
-->

`setThe` が無いのは、新しい状態の型だけでそれを包む状態のモナド変換として何を使うかを決定できるからです。

<!--
In the Lean standard library, there are instances of the non-`Of` versions of the classes defined in terms of the instances of the versions with `Of`.
In other words, implementing the `Of` version yields implementations of both.
It's generally a good idea to implement the `Of` version, and then start writing programs using the non-`Of` versions of the class, transitioning to the `Of` version if the output parameter becomes inconvenient.
-->

Leanの標準ライブラリには `Of` バージョンのインスタンスで定義された `Of` なしバージョンのインスタンスが存在します。言い換えると `Of` バージョンを実装すると、両方の実装が得られます。一般的には、`Of` バージョンを実装し、それからそのクラスの `Of` なしバージョンを使ってプログラムをまず書き、出力パラメータが煩わしくなってきたところで `Of` バージョンに移行すると良いでしょう。

<!--
## Transformers and `Id`
-->

## 変換子と `Id`

<!--
The identity monad `Id` is the monad that has no effects whatsoever, to be used in contexts that expect a monad for some reason but where none is actually necessary.
Another use of `Id` is to serve as the bottom of a stack of monad transformers.
For instance, `StateT σ Id` works just like `State σ`.
-->

恒等モナド `Id` は何の作用も持たないモナドで、何らかの理由でモナドが要求されるものの実際にはモナドとしての性質が不要な場合に用いられます。`Id` のもう一つの使い方は、モナド変換子のスタックの一番下に置くことです。例えば、`StateT σ Id` は `State σ` と同じように動作します。

<!--
## Exercises
-->

## 演習問題

<!--
### Monad Contract
-->

### モナドの約定

<!--
Using pencil and paper, check that the rules of the monad transformer contract are satisfied for each monad transformer in this section.
-->

紙と鉛筆を使って、本節の各モナド変換子についてモナド変換子のルールが満たされていることをチェックしてください。

<!--
### Logging Transformer
-->

### ロギング変換子

<!--
Define a monad transformer version of `WithLog`.
Also define the corresponding type class `MonadWithLog`, and write a program that combines logging and exceptions.
-->

`WithLog` のモナド変換子を定義してください。また対応する型クラス `MonadWithLog` を定義し、ロギングと例外を組み合わせたプログラムを書いてください。

<!--
### Counting Files
-->

### ファイル数のカウント

<!--
Modify `doug`'s monad with `StateT` such that it counts the number of directories and files seen.
At the end of execution, it should display a report like:
-->

`doug` のモナドを `StateT` に変更して、確認したディレクトリとファイルの数をカウントするようにしてください。実行の最後には以下のようなレポートを表示してください：

```
  Viewed 38 files in 5 directories.
```
