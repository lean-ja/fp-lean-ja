<!-- # Starting a Project -->

# プロジェクトの開始

<!-- As a program written in Lean becomes more serious, an ahead-of-time compiler-based workflow that results in an executable becomes more attractive.
Like other languages, Lean has tools for building multiple-file packages and managing dependencies.
The standard Lean build tool is called Lake (short for "Lean Make"), and it is configured in Lean.
Just as Lean contains a special-purpose language for writing programs with effects (the `do` language), Lake contains a special-purpose language for configuring builds.
These languages are referred to as _embedded domain-specific languages_ (or sometimes _domain-specific embedded languages_, abbreviated EDSL or DSEL).
They are _domain-specific_ in the sense that they are used for a particular purpose, with concepts from some sub-domain, and they are typically not suitable for general-purpose programming.
They are _embedded_ because they occur inside another language's syntax.
While Lean contains rich facilities for creating EDSLs, they are beyond the scope of this book. -->

Lean で書かれたプログラムが本格的になるにつれて，Ahead-Of-Time コンパイラベースのワークフローが魅力的になってきます．ほかの言語と同様に，Lean にも複数ファイルのパッケージのビルドと依存関係の管理のためのツールがあります．Lean の標準的なビルドツールは Lake（Lean Make の略）と呼ばれ，Lean で設定されます．Lean には `do` 記法のように副作用を持つプログラムを書くための特別な言語があるように，Lake にもビルドを設定するための特別な言語があります．これらの言語は**埋め込みドメイン固有言語**（embedded domain-specific languages）と呼ばれ EDSL と略されます（または**ドメイン固有言語**（domain-specific languages）とも呼び DSL と略します）．EDSL は，あるサブドメインの概念を用いて特定の目的のために使用されるという意味で**ドメイン固有**（domain-specific）であり，一般的に汎用プログラミングには適していません．また，**埋め込み**（embedded）とはほかの言語の構文の内部で使用されることに由来します．Lean には EDSL を作成するための豊富な機能がありますが，それは本書の範囲外です．

<!-- ## First steps -->

## 最初のステップ

<!-- To get started with a project that uses Lake, use the command `{{#command {first-lake} {lake} {lake new greeting} }}` in a directory that does not already contain a file or directory called `greeting`.
This creates a directory called `greeting` that contains the following files: -->

Lake を使用するプロジェクトを開始するには，`greeting` というファイルやディレクトリがまだ存在しないディレクトリで `{{#command {first-lake} {lake} {lake new greeting} }}` コマンドを使用します．

 <!-- * `Main.lean` is the file in which the Lean compiler will look for the `main` action.
 * `Greeting.lean` and `Greeting/Basic.lean` are the scaffolding of a support library for the program.
 * `lakefile.lean` contains the configuration that `lake` needs to build the application.
 * `lean-toolchain` contains an identifier for the specific version of Lean that is used for the project. -->

 * `Main.lean` は Lean コンパイラが `main` アクションを探すファイルです．
 * `Greeting.lean` と `Greeting/Basic.lean` はプログラムのサポートライブラリの足場です．
 * `lakefile.lean` は `lake` がアプリケーションをビルドするために必要な設定を含みます．
 * `lean-toolchain` は プロジェクトに使用される Lean の特定のバージョンの識別子を含みます．

<!-- Additionally, `lake new` initializes the project as a Git repository and configures its `.gitignore` file to ignore intermediate build products.
Typically, the majority of the application logic will be in a collection of libraries for the program, while `Main.lean` will contain a small wrapper around these pieces that does things like parsing command lines and executing the central application logic.
To create a project in an already-existing directory, run `lake init` instead of `lake new`. -->

さらに，`lake new` はプロジェクトを Git リポジトリとして初期化し，`.gitignore` ファイルを設定して中間ビルド生成物を無視します．通常，アプリケーションロジックの大部分はプログラム用のライブラリの集まりに含まれ，一方で `Main.lean` にはコマンドラインの解析や中心的なアプリケーションロジックの実行を行う小さなラッパーが含まれます．
すでに存在するディレクトリにプロジェクトを作成するには，`lake init` の代わりに `lake new` を実行します．

<!-- By default, the library file `Greeting/Basic.lean` contains a single definition: -->

デフォルトでは，ライブラリファイル `Greeting/Basic.lean` は1つの定義を含みます：

```lean
{{#file_contents {lake} {first-lake/greeting/Greeting/Basic.lean} {first-lake/expected/Greeting/Basic.lean}}}
```
<!-- The library file `Greeting.lean` imports `Greeting/Basic.lean`: -->

ライブラリファイル `Greeting.lean` は `Greeting/Basic.lean` をインポートします：

```lean
{{#file_contents {lake} {first-lake/greeting/Greeting.lean} {first-lake/expected/Greeting.lean}}}
```
<!-- This means that everything defined in `Greetings/Basic.lean` is also available to files that import `Greetings.lean`.
In `import` statements, dots are interpreted as directories on disk.
Placing guillemets around a name, as in `«Greeting»`, allow it to contain spaces or other characters that are normally not allowed in Lean names, and it allows reserved keywords such as `if` or `def` to be used as ordinary names by writing `«if»` or `«def»`.
This prevents issues when the package name provided to `lake new` contains such characters. -->

これは，`Greetings/Basic.lean` で定義された全てが `Greetings.lean` をインポートするファイルでも利用可能であることを意味します．`import` 文では，ドットはディスク上のディレクトリとして解釈されます．`«Greeting»` のように名前の周りに二重山括弧を置くことで，通常 Lean の名前では許されないスペースや他の文字を含むことができます．また，`«if»` や `«def»` と書くことで，`if` や `def` のような予約語を通常の名前として使用できます．これにより，`lake new` で作成されたパッケージ名にそれらの文字が含まれていた場合の問題を防ぐことができます．

<!-- The executable source `Main.lean` contains: -->

実行可能なソース `Main.lean` には以下の内容が含まれています：

```lean
{{#file_contents {lake} {first-lake/greeting/Main.lean} {first-lake/expected/Main.lean}}}
```
<!-- Because `Main.lean` imports `Greetings.lean` and `Greetings.lean` imports `Greetings/Basic.lean`, the definition of `hello` is available in `main`. -->

`Main.lean` は `Greetings.lean` をインポートし，`Greetings.lean` は `Greetings/Basic.lean` をインポートするので，`hello` の定義は `main` で使用可能です．

<!-- To build the package, run the command `{{#command {first-lake/greeting} {lake} {lake build} }}`.
After a number of build commands scroll by, the resulting binary has been placed in `build/bin`.
Running `{{#command {first-lake/greeting} {lake} {./build/bin/greeting} }}` results in `{{#command_out {lake} {./build/bin/greeting} }}`. -->

パッケージをビルドするには，`{{#command {first-lake/greeting} {lake} {lake build} }}` を実行します．いくつかのビルドコマンドがスクロールした後，結果のバイナリは `build/bin` に置かれます．
`{{#command {first-lake/greeting} {lake} {./build/bin/greeting} }}` の実行結果は `{{#command_out {lake} {./build/bin/greeting} }}` です．

<!-- ## Lakefiles -->

## Lakefiles

<!-- A `lakefile.lean` describes a _package_, which is a coherent collection of Lean code for distribution, analogous to an `npm` or `nuget` package or a Rust crate.
A package may contain any number of libraries or executables.
While the [documentation for Lake](https://github.com/leanprover/lake#readme) describes the available options in a lakefile, it makes use of a number of Lean features that have not yet been described here.
The generated `lakefile.lean` contains the following: -->

`lakefile.lean` は配布用の Lean コードの首尾一貫したコレクションである**パッケージ**を記述します．これは `npm` や `nuget` パッケージ，Rust のクレートと似ています．パッケージはいくつかのライブラリや実行可能ファイルを含むことができます．[Lake のドキュメント](https://github.com/leanprover/lake#readme) では lakefile で利用可能なオプションについて説明されていますが，ここではまだ説明されていない多くの Lean の機能を利用しています．
生成された `lakefile.lean` には以下が含まれています：

```lean
{{#file_contents {lake} {first-lake/greeting/lakefile.lean} {first-lake/expected/lakefile.lean}}}
```

<!-- This initial Lakefile consists of three items:
 * a _package_ declaration, named `greeting`,
 * a _library_ declaration, named `Greeting`, and
 * an _executable_, also named `greeting`. -->

 生成直後の Lakefile は3つの項目を含みます：
 * `greeting` という名前の**パッケージ**宣言
 * `Greeting` という名前の**ライブラリ**宣言
 * `greeting` という名前の**実行ファイル**

<!-- Each of these names is enclosed in guillemets to allow users more freedom in picking package names. -->

これらの名前はそれぞれ二重山括弧で囲まれており，ユーザがパッケージ名を自由に選べるようになっています．

<!-- Each Lakefile will contain exactly one package, but any number of libraries or executables.
Additionally, Lakefiles may contain _external libraries_, which are libraries not written in Lean to be statically linked with the resulting executable, _custom targets_, which are build targets that don't fit naturally into the library/executable taxonomy, _dependencies_, which are declarations of other Lean packages (either locally or from remote Git repositories), and _scripts_, which are essentially `IO` actions (similar to `main`), but that additionally have access to metadata about the package configuration.
The items in the Lakefile allow things like source file locations, module hierarchies, and compiler flags to be configured.
Generally speaking, however, the defaults are reasonable. -->

各 Lakefile にはちょうど1つのパッケージが含まれますが，ライブラリや実行ファイルはいくつでも含めることができます．さらに，Lakefile は以下も含めることができます：
* **外部ライブラリ**（external libraries）- Lean で書かれていませんが，最終的な実行可能ファイルに制的リンクされるライブラリ
* **カスタムターゲット**（custom targets）- ライブラリ・実行可能ファイルの分類には自然に収まらないビルドターゲット
* **依存関係**（dependencies）- 他の Lean パッケージの宣言（ローカルまたは Git リポジトリから取得されます）
* **スクリプト**（scripts）- 本質的には `main` のような `IO` アクションで，パッケージの設定に関するメタデータにもアクセスできます

Lakefile の項目により，ソースファイルの場所，モジュール階層，コンパイラフラグなどの設定が可能です．しかし一般的にはデフォルト設定が合理的です．

<!-- Libraries, executables, and custom targets are all called _targets_.
By default, `lake build` builds those targets that are annotated with `@[default_target]`.
This annotation is an _attribute_, which is metadata that can be associated with a Lean declaration.
Attributes are similar to Java annotations or C# and Rust attributes.
They are used pervasively throughout Lean.
To build a target that is not annotated with `@[default_target]`, specify the target's name as an argument after `lake build`. -->

ライブラリ，実行可能ファイル，カスタムターゲットはすべて**ターゲット**（target）と呼ばれます．デフォルトでは，`lake build` は `@[default_target]` でアノテーションされたターゲットをビルドします．このアノテーションは**アトリビュート**（attribute）で，Lean の宣言に関連付けることができるメタデータです．アトリビュートは Java のアノテーションや C# や Rust のアトリビュートと似ています．これらは Lean 全体で広く使用されています.
`@[default_target]` でアノテーションされていないターゲットをビルドするには，`lake build` の後にターゲットの名前を引数として指定します．

<!-- ## Libraries and Imports -->

## ライブラリとインポート

<!-- A Lean library consists of a hierarchically organized collection of source files from which names can be imported, called _modules_.
By default, a library has a single root file that matches its name.
In this case, the root file for the library `Greeting` is `Greeting.lean`.
The first line of `Main.lean`, which is `import Greeting`, makes the contents of `Greeting.lean` available in `Main.lean`. -->

Lean のライブラリは名前をインポートできるソースファイルの階層的に整理されたコレクションで構成され，これを**モジュール**（moudle）と呼びます．デフォルトでは，ライブラリにはその名前と一致する1つのルートファイルがあります．今回の場合，ライブラリ `Greeting` のルートファイルは `Greeting.lean` です．
`Main.lean` の最初の行 `import Greeting` は `Greeting.lean` の内容を `Main.lean` で使用可能にします．

<!-- Additional module files may be added to the library by creating a directory called `Greeting` and placing them inside.
These names can be imported by replacing the directory separator with a dot.
For instance, creating the file `Greeting/Smile.lean` with the contents: -->

追加のモジュールファイルをライブラリに追加するには，``Greeting` というディレクトリを作成し，その中にファイルを配置します．これらの名前はディレクトリの区切り文字をドットに置き換えることでインポートできます．
例えば，以下の内容の `Greeting/Smile.lean` を作成するとします：

```lean
{{#file_contents {lake} {second-lake/greeting/Greeting/Smile.lean}}}
```
<!-- means that `Main.lean` can use the definition as follows: -->

これにより，`Main.lean` は以下のように定義を使用できます：

```lean
{{#file_contents {lake} {second-lake/greeting/Main.lean}}}
```

<!-- The module name hierarchy is decoupled from the namespace hierarchy.
In Lean, modules are units of code distribution, while namespaces are units of code organization.
That is, names defined in the module `Greeting.Smile` are not automatically in a corresponding namespace `Greeting.Smile`.
Modules may place names into any namespace they like, and the code that imports them may `open` the namespace or not.
`import` is used to make the contents of a source file available, while `open` makes names from a namespace available in the current context without prefixes.
In the Lakefile, the line `import Lake` makes the contents of the `Lake` module available, while the line `open Lake DSL` makes the contents of the `Lake` and `Lake.DSL` namespaces available without any prefixes.
`Lake.DSL` is opened because opening `Lake` makes `Lake.DSL` available as just `DSL`, just like all other names in the `Lake` namespace.
The `Lake` module places names into both the `Lake` and `Lake.DSL` namespaces. -->

モジュール名の階層は名前空間の階層と切り離されています．Lean では，モジュールはコード配布の単位で，名前空間はコードの集まりの単位です．つまり，`Greeting.Smile` モジュールで定義された名前は，対応する名前空間 `Greeting.Smile` に自動的に含まれるわけではありません．モジュールは任意の名前空間に名前を配置でき，インポートするコードはその名前空間を `open` するかどうかを選べます．`import` はソースファイルの内容を使用可能にするために使用され，`open` は名前空間から名前をプレフィックスなしで現在のコンテキストで使用可能にします．Lakefile では，`import Lake` の行は `Lake` モジュールの内容を使用可能にし，`open Lake DSL` の行は `Lake` および `Lake.DSL` 名前空間の内容をプレフィックスなしで使用可能にします．`Lake` をオープンすることで `Lake.DSL` が `DSL` として使用可能となるため，`Lake.DSL` もオープンされます．
`Lake` モジュールは名前を `Lake` と `Lake.DSL` 名前空間の両方に配置します．

<!-- Namespaces may also be opened _selectively_, making only some of their names available without explicit prefixes.
This is done by writing the desired names in parentheses.
For example, `Nat.toFloat` converts a natural number to a `Float`.
It can be made available as `toFloat` using `open Nat (toFloat)`. -->

名前空間は**選択的に**オープンすることもでき，特定の名前だけをプレフィックスなしで使用可能にすることができます．これは，必要な名前を括弧内に書くことで行います．
例えば，`Nat.toFloat` は自然数を `Float` に変換します．
これを `toFloat` として使用可能にするには `open Nat (toFloat)` と書きます．
