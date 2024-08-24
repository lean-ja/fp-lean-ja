<!--
# Combining IO and Reader
-->

# IOとReaderを組み合わせる

<!--
One case where a reader monad can be useful is when there is some notion of the "current configuration" of the application that is passed through many recursive calls.
An example of such a program is `tree`, which recursively prints the files in the current directory and its subdirectories, indicating their tree structure using characters.
The version of `tree` in this chapter, called `doug` after the mighty Douglas Fir tree that adorns the west coast of North America, provides the option of Unicode box-drawing characters or their ASCII equivalents when indicating directory structure.
-->

リーダモナドが有用なケースの1つに、深い再帰呼び出しを通して渡されるアプリケーションの「現在の設定値」の概念があります。このようなプログラムの例は `tree` で、これはカレントディレクトリとサブディレクトリにあるファイルを再帰的に表示し、その木構造を文字で示します。この章で登場する `tree` は、北米の西海岸を彩る強大な米松（Douglas Fir）にちなんで `doug` と呼ぶことにし、ディレクトリ構造を示すときにUnicodeの罫線素片、もしくはそれに相当するASCII文字のどちらかを選べるオプションを提供します。

<!--
For example, the following commands create a directory structure and some empty files in a directory called `doug-demo`:
-->

例として、以下のコマンドは `doug-demo` というディレクトリにディレクトリ構造といくつかの空のファイルを作成しています：

```
$ cd doug-demo
$ {{#command {doug-demo} {doug} {mkdir -p a/b/c} }}
$ {{#command {doug-demo} {doug} {mkdir -p a/d} }}
$ {{#command {doug-demo} {doug} {mkdir -p a/e/f} }}
$ {{#command {doug-demo} {doug} {touch a/b/hello} }}
$ {{#command {doug-demo} {doug} {touch a/d/another-file} }}
$ {{#command {doug-demo} {doug} {touch a/e/still-another-file-again} }}
```
<!--
Running `doug` results in the following:
-->

ここで `doug` を実行すると以下の結果となります：

```
$ {{#command {doug-demo} {doug} {doug} }}
{{#command_out {doug} {doug} }}
```

<!--
## Implementation
-->

## 実装

<!--
Internally, `doug` passes a configuration value downwards as it recursively traverses the directory structure.
This configuration contains two fields: `useASCII` determines whether to use Unicode box-drawing characters or ASCII vertical line and dash characters to indicate structure, and `currentPrefix` contains a string to prepend to each line of output.
As the current directory deepens, the prefix string accumulates indicators of being in a directory.
The configuration is a structure:
-->

内部的には、`doug` はディレクトリ構造を再帰的に走査しながら設定値を下方に渡しています。この設定は2つのフィールドを含みます：`useASCII` はUnicodeの罫線素片とASCIIの縦棒とダッシュ文字のどちらを構造の表示に用いるかを決定し、`currentPrefix` は出力の各行の先頭につける文字列を保持します。カレントディレクトリが深くなるにつれて、そのディレクトリを接頭辞文字列に蓄積していきます。この設定値は以下の構造体です：

```lean
{{#example_decl Examples/MonadTransformers.lean Config}}
```
<!--
This structure has default definitions for both fields.
The default `Config` uses Unicode display with no prefix.
-->

この構造体は両方のフィールドにデフォルト定義を持ちます。デフォルトの `Config` はUnicodeによる表示を行い、接頭辞を付けません。

<!--
Users who invoke `doug` will need to be able to provide command-line arguments.
The usage information is as follows:
-->

`doug` の利用者はコマンドライン引数を与えられる必要があるでしょう。この使い方は以下の通りです：

```lean
{{#example_decl Examples/MonadTransformers.lean usage}}
```
<!--
Accordingly, a configuration can be constructed by examining a list of command-line arguments:
-->

したがって、設定値はコマンドライン引数のリストを調べることで構築できます：

```lean
{{#example_decl Examples/MonadTransformers.lean configFromArgs}}
```

<!--
The `main` function is a wrapper around an inner worker, called `dirTree`, that shows the contents of a directory using a configuration.
Before calling `dirTree`, `main` is responsible for processing command-line arguments.
It must also return the appropriate exit code to the operating system:
-->

`main` 関数は `dirTree` と呼ばれる内部ワーカーのラッパーです。この関数は設定値をもとにディレクトリの内容を表示します。`dirTree` を呼び出す前に、`main` はコマンドライン引数を処理しなければなりません。またこの関数はOSに適切な終了コードを返さなければなりません：

```lean
{{#example_decl Examples/MonadTransformers.lean OldMain}}
```

<!--
Not all paths should be shown in the directory tree.
In particular, files named `.` or `..` should be skipped, as they are actually features used for navigation rather than files _per se_.
-->

すべてのパスがディレクトリツリーに表示されるべきではありません。特に、`.` や `..` という名前のファイルはスキップされるべきです。これらはファイル **そのもの** というより実際にはナビゲーションのための機能であるからです。

<!--
Of those files that should be shown, there are two kinds: ordinary files and directories:
-->

表示すべきファイルは2種類です：通常のファイルとディレクトリです：

```lean
{{#example_decl Examples/MonadTransformers.lean Entry}}
```
<!--
To determine whether a file should be shown, along with which kind of entry it is, `doug` uses `toEntry`:
-->

あるファイルを表示すべきかどうかとそのファイルの種類を決定するために、`doug` は `toEntry` を使用します：

```lean
{{#example_decl Examples/MonadTransformers.lean toEntry}}
```
<!--
`System.FilePath.components` converts a path into a list of path components, splitting the name at directory separators.
If there is no last component, then the path is the root directory.
If the last component is a special navigation file (`.` or `..`), then the file should be excluded.
Otherwise, directories and files are wrapped in the corresponding constructors.
-->

`System.FilePath.components` はパスを、パスの区切り文字で分割した要素のリストに変換します。リストに最後の要素が無い（訳注：リストが空である）場合は、そのパスはルートディレクトリとなります。リストの最後の要素が特別なナビゲーションファイル（`.` や `..` ）である場合、このファイルは除外するべきです。それ以外の場合、ディレクトリとファイルは対応するコンストラクタでラップされます。

<!--
Lean's logic has no way to know that directory trees are finite.
Indeed, some systems allow the construction of circular directory structures.
Thus, `dirTree` is declared `partial`:
-->

Leanのロジックにはディレクトリツリーが有限であることを知るすべはありません。実際に、システムによっては循環的なディレクトリ構造を構築することができます。したがって、`dirTree` は `partial` として宣言されています：

```lean
{{#example_decl Examples/MonadTransformers.lean OldDirTree}}
```
<!--
The call to `toEntry` is a [nested action](../hello-world/conveniences.md#nested-actions)—the parentheses are optional in positions where the arrow couldn't have any other meaning, such as `match`.
When the filename doesn't correspond to an entry in the tree (e.g. because it is `..`), `dirTree` does nothing.
When the filename points to an ordinary file, `dirTree` calls a helper to show it with the current configuration.
When the filename points to a directory, it is shown with a helper, and then its contents are recursively shown in a new configuration in which the prefix has been extended to account for being in a new directory.
-->

`toEntry` の呼び出しは [入れ子になったアクション](../hello-world/conveniences.md#nested-actions) です。`match` のように矢印が他の意味を持ちえない位置では括弧を省略することができます。ファイル名がツリーの要素に対応していない場合（例えば `..` の場合）、`dirTree` は何もしません。ファイル名が通常のファイルを指している場合、`dirTree` は補助関数を呼び出して現在の設定値をもとにファイルを表示します。ファイル名がディレクトリを指している場合、補助関数を呼び出してディレクトリ名を表示し、その中身についてはディレクトリに入ったことを考慮して接頭辞を拡張した新しい設定のもとで再帰的に表示を行います。

<!--
Showing the names of files and directories is achieved with `showFileName` and `showDirName`:
-->

ファイルとディレクトリの名前を表示するには、`showFileName` と `showDirName` を使います：

```lean
{{#example_decl Examples/MonadTransformers.lean OldShowFile}}
```
<!--
Both of these helpers delegate to functions on `Config` that take the ASCII vs Unicode setting into account:
-->

これらの補助関数はどちらもASCIIかUnicodeの設定を考慮する `Config` 上の関数に委譲しています：

```lean
{{#example_decl Examples/MonadTransformers.lean filenames}}
```
<!--
Similarly, `Config.inDirectory` extends the prefix with a directory marker:
-->

同じように、`Config.inDirectory` は接頭辞をディレクトリを示す印で拡張します：

```lean
{{#example_decl Examples/MonadTransformers.lean inDirectory}}
```

<!--
Iterating an IO action over a list of directory contents is achieved using `doList`.
Because `doList` carries out all the actions in a list and does not base control-flow decisions on the values returned by any of the actions, the full power of `Monad` is not necessary, and it will work for any `Applicative`:
-->

IOアクションをディレクトリの内容のリストに対して繰り返し実行するには、`doList` を使用します。`doList` はリスト内のすべてのアクションを実行しますが、アクションが返す値に基づいて制御の流れを決定するわけではないので `Monad` のフルパワーは必要なく、任意の `Applicative` で動作します：

```lean
{{#example_decl Examples/MonadTransformers.lean doList}}
```


<!--
## Using a Custom Monad
-->

## カスタムのモナドを使う

<!--
While this implementation of `doug` works, manually passing the configuration around is verbose and error-prone.
The type system will not catch it if the wrong configuration is passed downwards, for instance.
A reader effect ensures that the same configuration is passed to all recursive calls, unless it is manually overridden, and it helps make the code less verbose.
-->

この実装で `doug` は動作してくれますが、手動で設定値を渡すのは冗長でエラーになりやすいです。例えば、間違った設定値が `doug` に渡され、ディレクトリを掘りながら設定値が伝播してしまうことを型システムは捕捉してくれません。リーダモナドの作用によって、手動で上書きしない限り同じ設定値がすべての再帰呼び出しに渡されることが保証されます。これによってコードの冗長性が緩和されます。

<!--
To create a version of `IO` that is also a reader of `Config`, first define the type and its `Monad` instance, following the recipe from [the evaluator example](../monads/arithmetic.md#custom-environments):
-->

`Config` についてのリーダでもある `IO` モナドを作成するには、まず [評価器の例](../monads/arithmetic.md#custom-environments) のレシピに従って型とその `Monad` インスタンスを定義します：

```lean
{{#example_decl Examples/MonadTransformers.lean ConfigIO}}
```
<!--
The difference between this `Monad` instance and the one for `Reader` is that this one uses `do`-notation in the `IO` monad as the body of the function that `bind` returns, rather than applying `next` directly to the value returned from `result`.
Any `IO` effects performed by `result` must occur before `next` is invoked, which is ensured by the `IO` monad's `bind` operator.
`ConfigIO` is not universe polymorphic because the underlying `IO` type is also not universe polymorphic.
-->

この `Monad` インスタンスと `Reader` のインスタンスの違いは、上記のインスタンスでは `result` から返された値に直接 `next` を適用するのではなく、`bind` が返す関数のボディとして `IO` モナドの `do` 記法を使用する点です。`results` によって発生する任意の `IO` の作用は `next` が呼び出される前に発生しなければなりませんが、これは `IO` モナドの `bind` 演算子によって保証されています。`Config IO` は宇宙多相ではありませんが、これはベースにした `IO` 型も宇宙多相ではないからです。

<!--
Running a `ConfigIO` action involves transforming it into an `IO` action by providing it with a configuration:
-->

`ConfigIO` アクションを実行するには設定値を与えてこのアクションを `IO` アクションに変換します：

```lean
{{#example_decl Examples/MonadTransformers.lean ConfigIORun}}
```
<!--
This function is not really necessary, as a caller could simply provide the configuration directly.
However, naming the operation can make it easier to see which parts of the code are intended to run in which monad.
-->

呼び出し元が直接設定値を提供すればよいため、実際にはこの関数は必要ありません。しかし、操作に名前をつけることでコードのどの部分がどのモナドで実行しようとしているかがわかりやすくなります。

<!--
The next step is to define a means of accessing the current configuration as part of `ConfigIO`:
-->

次のステップは `ConfigIO` に含まれている現在の設定値にアクセスする手段を定義することです：

```lean
{{#example_decl Examples/MonadTransformers.lean currentConfig}}
```
<!--
This is just like `read` from [the evaluator example](../monads/arithmetic.md#custom-environments), except it uses `IO`'s `pure` to return its value rather than doing so directly.
Because entering a directory modifies the current configuration for the scope of a recursive call, it will be necessary to have a way to override a configuration:
-->

これは [評価器の例](../monads/arithmetic.md#custom-environments) での `read` とよく似ていますが、ここでは値を返すにあたって直接ではなく `IO` の `pure` を使用しています。ディレクトリに入ると再帰呼び出しのスコープで現在の設定が変更されるため、設定を上書きする方法が必要になります：

```lean
{{#example_decl Examples/MonadTransformers.lean locally}}
```

<!--
Much of the code used in `doug` has no need for configurations, and `doug` calls ordinary Lean `IO` actions from the standard library that certainly don't need a `Config`.
Ordinary `IO` actions can be run using `runIO`, which ignores the configuration argument:
-->

`doug` で使用されるコードではほとんど設定値を必要としません。事実、`doug` は `Config` を必要としない標準ライブラリから普通の `IO` アクションを呼び出します。通常の `IO` アクションは `runIO` を使用して実行することができ、このアクションは設定値の引数を無視します：

```lean
{{#example_decl Examples/MonadTransformers.lean runIO}}
```

<!--
With these components, `showFileName` and `showDirName` can be updated to take their configuration arguments implicitly through the `ConfigIO` monad.
They use [nested actions](../hello-world/conveniences.md#nested-actions) to retrieve the configuration, and `runIO` to actually execute the call to `IO.println`:
-->

これらのコンポーネントを使うことで、`showFileName` と `showDirName` は `ConfigIO` モナドを通じて暗黙の設定引数を受け取るように更新することができます。設定を取得するには [ネストされたアクション](../hello-world/conveniences.md#nested-actions) を使用し、`IO.println` の呼び出しを実際に実行するには `runIO` を使用します。

```lean
{{#example_decl Examples/MonadTransformers.lean MedShowFileDir}}
```

<!--
In the new version of `dirTree`, the calls to `toEntry` and `System.FilePath.readDir` are wrapped in `runIO`.
Additionally, instead of building a new configuration and then requiring the programmer to keep track of which one to pass to recursive calls, it uses `locally` to naturally delimit the modified configuration to only a small region of the program, in which it is the _only_ valid configuration:
-->

新しい `dirTree` では `toEntry` と `System.FilePath.readDir` の呼び出しが `runIO` でラップされています。さらに、新しい設定を構成してプログラマが再帰呼び出しに渡す設定を追跡する代わりに、`locally` を使用して変更された設定をそれが有効な設定 **でしかない** ようにプログラムの小さな領域のみに自然に限定します：

```lean
{{#example_decl Examples/MonadTransformers.lean MedDirTree}}
```

<!--
The new version of `main` uses `ConfigIO.run` to invoke `dirTree` with the initial configuration:
-->

新しい `main` では `ConfigIO.run` を使い、初期設定値をもとに `dirTree` を実行します：

```lean
{{#example_decl Examples/MonadTransformers.lean MedMain}}
```

<!--
This custom monad has a number of advantages over passing configurations manually:
-->

このカスタムのモナドは設定値を手動で渡す場合に比べて多くの利点があります：

 <!--
 1. It is easier to ensure that configurations are passed down unchanged, except when changes are desired
 2. The concern of passing the configuration onwards is more clearly separated from the concern of printing directory contents
 3. As the program grows, there will be more and more intermediate layers that do nothing with configurations except propagate them, and these layers don't need to be rewritten as the configuration logic changes
-->
 1. 変更が必要な場合を除き、設定が変更されずに受け渡されることを保証するのが容易
 2. 設定値を引き継ぐことと、ディレクトリの内容を表示することの関心事がより明確に分離される
 3. プログラムが巨大化するにつれて、設定値を伝播する以外は何もしない中間層がどんどん増えていくが、設定値のロジックの変更があってもこれらのレイヤに対して修正を行う必要がない

<!--
However, there are also some clear downsides:
-->

しかし、一方で明確なマイナス面もあります：

 <!--
 1. As the program evolves and the monad requires more features, each of the basic operators such as `locally` and `currentConfig` will need to be updated
 2. Wrapping ordinary `IO` actions in `runIO` is noisy and distracts from the flow of the program
 3. Writing monads instances by hand is repetitive, and the technique for adding a reader effect to another monad is a design pattern that requires documentation and communication overhead
-->
 1. プログラムを改良し、モナドがより多くの機能を必要とするようになると、`locally` や `currentConfig` などの基本的な演算子それぞれを更新する必要がある
 2. 通常の `IO` アクションを `runIO` でラップするのは視認性が悪く、プログラムの流れを乱してしまう
 3. 手動でモナドのインスタンスを書くのは同じことの繰り返しであり、リーダの作用を別のモナドに追加するテクニックは余分な文書化とコミュニケーションを要するデザインパターンである

<!--
Using a technique called _monad transformers_, all of these downsides can be addressed.
A monad transformer takes a monad as an argument and returns a new monad.
Monad transformers consist of:
-->

**モナド変換子** （monad transformer）と呼ばれるテクニックを使えば、これらすべての欠点を解決することができます。モナド変換子はモナドを引数に取り、新しいモナドを返します。モナド変換子の構成は以下の通りです：

 <!--
 1. A definition of the transformer itself, which is typically a function from types to types
 2. A `Monad` instance that assumes the inner type is already a monad
 3. An operator to "lift" an action from the inner monad to the transformed monad, akin to `runIO`
-->
 1. このモナド変換子自体の定義、これは通常型から型への関数
 2. 内部の型がすでにモナドであると仮定した `Monad` インスタンス
 3. 内側のモナドから変換後のモナドにアクションを「持ち上げる」演算子、これは `runIO` に似ている

<!--
## Adding a Reader to Any Monad
-->

## リーダを任意のモナドに付与する

<!--
Adding a reader effect to `IO` was accomplished in `ConfigIO` by wrapping `IO α` in a function type.
The Lean standard library contains a function that can do this to _any_ polymorphic type, called `ReaderT`:
-->

`ConfigIO` にてリーダの作用を `IO` に追加するのは `IO α` を関数型で包むことで実現しました。Leanの標準ライブラリにはこれを **どんな** 多相型に対しても行うことのできる関数を備えており、`ReaderT` と呼ばれています：

```lean
{{#example_decl Examples/MonadTransformers.lean MyReaderT}}
```
<!--
Its arguments are as follows:
-->

これの引数は以下です：

 <!--
 * `ρ` is the environment that is accessible to the reader
 * `m` is the monad that is being transformed, such as `IO`
 * `α` is the type of values being returned by the monadic computation
-->
 * `ρ` はリーダから参照される環境
 * `m` は変換対象のモナドで、例えば `IO` などが入る
 * `α` はモナドの計算で返される値の型
<!--
Both `α` and `ρ` are in the same universe because the operator that retrieves the environment in the monad will have type `m ρ`.
-->

`α` と `ρ` のどちらも同じ宇宙に属します。というのも、このモナドで環境を引っ張ってくる演算子は `m ρ` 型を持つからです。

<!--
With `ReaderT`, `ConfigIO` becomes:
-->

`ReaderT` を使うことで、`ConfigIO` は以下のようになります：

```lean
{{#example_decl Examples/MonadTransformers.lean ReaderTConfigIO}}
```
<!--
It is an `abbrev` because `ReaderT` has many useful features defined in the standard library that a non-reducible definition would hide.
Rather than taking responsibility for making these work directly for `ConfigIO`, it's easier to simply have `ConfigIO` behave identically to `ReaderT Config IO`.
-->

ここでは `abbrev` を使います。なぜなら、`ReaderT` には簡約できない定義では隠されてしまうような多くの便利な機能が標準ライブラリで定義されているからです。これらを `ConfigIO` のために直接動作させる責任を負うよりも、`ConfigIO` に `ReaderT Config IO` と同じ動作をさせる方が簡単です。

<!--
The manually-written `currentConfig` obtained the environment out of the reader.
This effect can be defined in a generic form for all uses of `ReaderT`, under the name `read`:
-->

手動で書いた `currentConfig` はリーダから環境を取得していました。この作用は `ReaderT` のあらゆる用途に対して `read` という名前で汎用的に定義することができます：

```lean
{{#example_decl Examples/MonadTransformers.lean MyReaderTread}}
```
<!--
However, not every monad that provides a reader effect is built with `ReaderT`.
The type class `MonadReader` allows any monad to provide a `read` operator:
-->

しかし、リーダの作用を提供するすべてのモナドが `ReaderT` で構築されているわけではありません。型クラス `MonadReader` を使えばどのモナドでも `read` 演算子を使えるようになります：

```lean
{{#example_decl Examples/MonadTransformers.lean MonadReader}}
```
<!--
The type `ρ` is an output parameter because any given monad typically only provides a single type of environment through a reader, so automatically selecting it when the monad is known makes programs more convenient to write.
-->

型 `ρ` は出力パラメータです。なぜなら、与えられた任意のモナドは通常リーダを通して単一の型の環境しか提供しないため、モナドがわかっている際に自動的に型 `ρ` を選択することでプログラムをより書きやすくなるからです。

<!--
The `Monad` instance for `ReaderT` is essentially the same as the `Monad` instance for `ConfigIO`, except `IO` has been replaced by some arbitrary monad argument `m`:
-->

`ReaderT` の `Monad` インスタンスは `ConfigIO` の `Monad` インスタンスと本質的に同じではありますが、`IO` が任意のモナド `m` に置き換えられています：

```lean
{{#example_decl Examples/MonadTransformers.lean MonadMyReaderT}}
```


<!--
The next step is to eliminate uses of `runIO`.
When Lean encounters a mismatch in monad types, it automatically attempts to use a type class called `MonadLift` to transform the actual monad into the expected monad.
This process is similar to the use of coercions.
`MonadLift` is defined as follows:
-->

次のステップは `runIO` の使用を無くすことです。Leanはモナドの型の不一致に遭遇すると、対象のモナドに対して `MonadLift` と呼ばれる型クラスを自動的に使用して期待されるモナドに変換しようとします。このプロセスは型強制と似ています。`MonadLift` は以下のように定義されています：

```lean
{{#example_decl Examples/MonadTransformers.lean MyMonadLift}}
```
<!--
The method `monadLift` translates from the monad `m` to the monad `n`.
The process is called "lifting" because it takes an action in the embedded monad and makes it into an action in the surrounding monad.
In this case, it will be used to "lift" from `IO` to `ReaderT Config IO`, though the instance works for _any_ inner monad `m`:
-->

`monadLift` メソッドはモナド `m` をモナド `n` へ変換します。このプロセスは埋め込まれたモナドのアクションをその外側のモナドのアクションに変換することから「持ち上げ（lifting）」と呼ばれます。今回の場合、`IO` から　`ReaderT Config IO` への「持ち上げ」に用いられますが、このインスタンスは **どんな** 内部のモナド `m` に対して機能します：

```lean
{{#example_decl Examples/MonadTransformers.lean MonadLiftReaderT}}
```
<!--
The implementation of `monadLift` is very similar to that of `runIO`.
Indeed, it is enough to define `showFileName` and `showDirName` without using `runIO`:
-->

`monadLift` の実装は `runIO` のそれと非常に似ています。実は、`runIO` を使わなくても `showFileName` と `showDirName` を定義することができます：

```lean
{{#example_decl Examples/MonadTransformers.lean showFileAndDir}}
```

<!--
One final operation from the original `ConfigIO` remains to be translated to a use of `ReaderT`: `locally`.
The definition can be translated directly to `ReaderT`, but the Lean standard library provides a more general version.
The standard version is called `withReader`, and it is part of a type class called `MonadWithReader`:
-->

もとの `ConfigIO` から `ReaderT` を使用したバージョンに変換するにあたってまだもう一つ操作が残っています：`locally` です。この定義は `ReaderT` に直接翻訳することもできますが、Leanの標準ライブラリではより一般的なものを提供しています。標準のものは `withReader` と呼ばれ、`MonadWithReader` という型クラスの一部になっています：

```lean
{{#example_decl Examples/MonadTransformers.lean MyMonadWithReader}}
```
<!--
Just as in `MonadReader`, the environment `ρ` is an `outParam`.
The `withReader` operation is exported, so that it doesn't need to be written with the type class name before it:
-->

`MonadReader` の同様に、環境 `ρ` は `outParam` です。`withReader` 操作はエクスポートされているため、前に型クラス名を書く必要はありません：

```lean
{{#example_decl Examples/MonadTransformers.lean exportWithReader}}
```
<!--
The instance for `ReaderT` is essentially the same as the definition of `locally`:
-->

`ReaderT` のインスタンスは本質的には `locally` の定義と同じです：

```lean
{{#example_decl Examples/MonadTransformers.lean ReaderTWithReader}}
```

<!--
With these definitions in place, the new version of `dirTree` can be written:
-->

以上の定義から、新しいバージョンの `dirTree` を書くことができます：

```lean
{{#example_decl Examples/MonadTransformers.lean readerTDirTree}}
```
<!--
Aside from replacing `locally` with `withReader`, it is the same as before.
-->

`locally` を `withReader` に置き換えた以外は、以前のものと同じです。

<!--
Replacing the custom `ConfigIO` type with `ReaderT` did not save a large number of lines of code in this section.
However, rewriting the code using components from the standard library does have long-term benefits.
First, readers who know about `ReaderT` don't need to take time to understand the `Monad` instance for `ConfigIO`, working backwards to the meaning of monad itself.
Instead, they can be confident in their initial understanding.
Next, adding further effects to the monad (such as a state effect to count the files in each directory and display a count at the end) requires far fewer changes to the code, because the monad transformers and `MonadLift` instances provided in the library work well together.
Finally, using a set of type classes included in the standard library, polymorphic code can be written in such a way that it can work with a variety of monads without having to care about details like the order in which the monad transformers were applied.
Just as some functions work in any monad, others can work in any monad that provides a certain type of state, or a certain type of exceptions, without having to specifically describe the _way_ in which a particular concrete monad provides the state or exceptions.
-->

カスタムの `ConfigIO` 型を `ReaderT` 型に置き換えても、この節のコード量はそこまで大幅には減りませんでした。しかし、標準ライブラリのコンポーネントを使用してコードを書き直すことには長期的な利点があります。まず `ReaderT` について知っている読者は `ConfigIO` の `Monad` インスタンスをモナドそのものの意味から逆算してじっくり時間をかけて理解する必要がありません。そのため `ConfigIO` への理解が容易になります。次に、モナドにさらなる作用（各ディレクトリ内のファイルをカウントして最後にカウントを表示する状態の作用など）を追加する場合、ライブラリで提供されているモナド変換子と `MonadLift` インスタンスがうまく連携して動くため、コードの変更量がはるかに少なくなります。最後に、標準ライブラリにある型クラスたちを使うことで、モナド変換子の適用順などの細かいことを気にすることなく、様々なモナドで動作するように多相なコードを書くことができます。一部の関数がどのモナドでも動作するように、関数がある種の状態や例外などの任意のモナドに対して、それらの具体的なモナドが状態や例外を提供する **方法** を具体的に記述することなく動作することができます。

<!--
## Exercises
-->

## 演習問題

<!--
### Controlling the Display of Dotfiles
-->

### ドットのファイルの表示の制御

<!--
Files whose names begin with a dot character (`'.'`) typically represent files that should usually be hidden, such as source-control metadata and configuration files.
Modify `doug` with an option to show or hide filenames that begin with a dot.
This option should be controlled with a `-a` command-line option.
-->

ファイル名がドット文字（`'.'`）で始まるファイルは通常、ソース管理のメタデータや設定ファイルなど、通常は隠すべきファイルを表します。`doug` にドットで始まるファイル名を表示または非表示にするオプションを追加してください。このオプションは `-a` コマンドラインオプションで制御します。

<!--
### Starting Directory as Argument
-->

### 開始するディレクトリを引数に

<!--
Modify `doug` so that it takes a starting directory as an additional command-line argument.
-->

`doug` を修正してコマンドライン引数に追加で開始ディレクトリを受け取るようにしてください。
