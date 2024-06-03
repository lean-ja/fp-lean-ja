<!-- # Additional Conveniences -->

## その他の便利な機能

<!-- Lean contains a number of convenience features that make programs much more concise. -->

Leanにはプログラムをより簡潔にする便利な機能がたくさんあります．

<!-- ## Automatic Implicit Arguments -->

## 自動的な暗黙引数

<!-- When writing polymorphic functions in Lean, it is typically not necessary to list all the implicit arguments.
Instead, they can simply be mentioned.
If Lean can determine their type, then they are automatically inserted as implicit arguments.
In other words, the previous definition of `length`: -->

Leanで多相関数を書く場合，基本的にすべての暗黙引数を列挙する必要はありません．その代わりに，単にそれらを参照するだけでよいのです．Leanが引数に現れなかった変数の型を決定できる場合，それらは自動的に暗黙の引数として挿入されます．例えば，先ほどの `length` の定義について：

```lean
{{#example_decl Examples/Intro.lean lengthImp}}
```
<!-- can be written without `{α : Type}`: -->

`{α : Type}` を書かずに定義できます：

```lean
{{#example_decl Examples/Intro.lean lengthImpAuto}}
```
<!-- This can greatly simplify highly polymorphic definitions that take many implicit arguments. -->

これにより，多くの暗黙引数をとるような高度に多相的な定義を大幅に簡略化することができます．

<!-- ## Pattern-Matching Definitions -->

## パターンマッチによる定義

<!-- When defining functions with `def`, it is quite common to name an argument and then immediately use it with pattern matching.
For instance, in `length`, the argument `xs` is used only in `match`.
In these situations, the cases of the `match` expression can be written directly, without naming the argument at all. -->

`def` で関数を定義するとき，引数に名前をつけてもすぐにパターンマッチに適用してしまうケースはよくあります．例えば，`length` では引数 `xs` は `match` でのみ使用されます．このような状況では，引数に名前を付けずに `match` 式のケースを直接書くことができます．

<!-- The first step is to move the arguments' types to the right of the colon, so the return type is a function type.
For instance, the type of `length` is `List α → Nat`.
Then, replace the `:=` with each case of the pattern match: -->

最初のステップは，引数の型をコロンの右側に移動させることです．例えば `length` の型は `List α → Nat` となります．次に，`:=` をパターンマッチの各ケースで置き換えます：

```lean
{{#example_decl Examples/Intro.lean lengthMatchDef}}
```

<!-- This syntax can also be used to define functions that take more than one argument.
In this case, their patterns are separated by commas.
For instance, `drop` takes a number \\( n \\) and a list, and returns the list after removing the first \\( n \\) entries. -->

この構文は複数の引数を取る関数を定義するのにも使えます．この場合，パターンはカンマで区切られます．例えば，`drop` は整数値 \\( n \\) とリストを受け取り，先頭から \\( n \\) 個の要素を取り除いたリストを返します．

```lean
{{#example_decl Examples/Intro.lean drop}}
```

<!-- Named arguments and patterns can also be used in the same definition.
For instance, a function that takes a default value and an optional value, and returns the default when the optional value is `none`, can be written: -->

名前の付いた引数とパターンを同じ定義で使用することもできます．例えば，デフォルト値とオプション値を受け取り，オプション値が `none` の場合はデフォルト値を返す関数を書くことができます：

```lean
{{#example_decl Examples/Intro.lean fromOption}}
```
<!-- This function is called `Option.getD` in the standard library, and can be called with dot notation: -->

この関数は標準ライブラリに `Option.getD` という名前で定義されており，ドット記法で呼び出すことができます：

```lean
{{#example_in Examples/Intro.lean getD}}
```
```output info
{{#example_out Examples/Intro.lean getD}}
```
```lean
{{#example_in Examples/Intro.lean getDNone}}
```
```output info
{{#example_out Examples/Intro.lean getDNone}}
```

<!-- ## Local Definitions -->

## ローカル定義

<!-- It is often useful to name intermediate steps in a computation.
In many cases, intermediate values represent useful concepts all on their own, and naming them explicitly can make the program easier to read.
In other cases, the intermediate value is used more than once.
As in most other languages, writing down the same code twice in Lean causes it to be computed twice, while saving the result in a variable leads to the result of the computation being saved and re-used. -->

計算の途中のステップに名前を付けると便利なことが多いものです．多くの場合，こうした中間値はそれだけで有用な概念を表しており，明示的に名前をつけることでプログラムを読みやすくすることができます．また中間値が複数回使われる場合もあります．ほかの多くの言語と同じように，Leanにて同じコードを2回書くと2回計算されることになる一方で，結果を変数に保存すると計算結果が保存されて再利用されることになります．

<!-- For instance, `unzip` is a function that transforms a list of pairs into a pair of lists.
When the list of pairs is empty, then the result of `unzip` is a pair of empty lists.
When the list of pairs has a pair at its head, then the two fields of the pair are added to the result of unzipping the rest of the list.
This definition of `unzip` follows that description exactly: -->

例えば，`unzip` はペアのリストをリストのペアに変換する関数です．ペアのリストが空の場合，`unzip` の結果は空のリストのペアになります．ペアのリストの先頭にペアがある場合，そのペアの2つのフィールドが残りのリストを `unzip` した結果に追加されます．この `unzip` の定義を完全に起こすと以下のようになります：

```lean
{{#example_decl Examples/Intro.lean unzipBad}}
```
<!-- Unfortunately, there is a problem: this code is slower than it needs to be.
Each entry in the list of pairs leads to two recursive calls, which makes this function take exponential time.
However, both recursive calls will have the same result, so there is no reason to make the recursive call twice. -->

残念ながら，このコードには問題があります: これは必要以上に遅いのです．ペアのリストの各要素が2回の再帰呼び出しを行うため，この関数には指数関数的な時間がかかります．しかし，どちらの再帰呼び出しも結果は同じであるため，再帰呼び出しを2回行う必要はありません．

<!-- In Lean, the result of the recursive call can be named, and thus saved, using `let`.
Local definitions with `let` resemble top-level definitions with `def`: it takes a name to be locally defined, arguments if desired, a type signature, and then a body following `:=`.
After the local definition, the expression in which the local definition is available (called the _body_ of the `let`-expression) must be on a new line, starting at a column in the file that is less than or equal to that of the `let` keyword.
For instance, `let` can be used in `unzip` like this: -->

Leanでは再帰呼び出しの結果を `let` を使って名前を付け，保存することができます．`let` によるローカル定義は `def` によるトップレベル定義と似ています: この構文ではローカル定義する名前，必要であれば引数，型シグネチャ，そして `:=` に続く本体を取ります．ローカル定義の後，この定義が使用可能な式（ `let` 式の **本体** （body）と呼ばれます）は次の行からかつ `let` キーワードが定義された列と同じかそれよりも後ろから始まる必要があります．例えば `let` は `unzip` で次のように使用することができます：

```lean
{{#example_decl Examples/Intro.lean unzip}}
```
<!-- To use `let` on a single line, separate the local definition from the body with a semicolon. -->

`let` を1行で使用するには，ローカル定義と本体をセミコロンで区切ります．

<!-- Local definitions with `let` may also use pattern matching when one pattern is enough to match all cases of a datatype.
In the case of `unzip`, the result of the recursive call is a pair.
Because pairs have only a single constructor, the name `unzipped` can be replaced with a pair pattern: -->

`let` を使用したローカル定義では，1つのパターンでデータ型のすべてのケースにマッチする場合であればパターンマッチを使うこともできます．`unzip` の場合，再帰呼び出しの結果はペアになります．ペアは単一のコンストラクタしか持たないので，`unzipped` という名前をペアのパターンに置き換えることができます：

```lean
{{#example_decl Examples/Intro.lean unzipPat}}
```
<!-- Judicious use of patterns with `let` can make code easier to read, compared to writing the accessor calls by hand. -->

`let` を使ったパターンをうまく使えば，手作業でアクセサの呼び出しを書くよりもコードを読みやすくすることができます．

<!-- The biggest difference between `let` and `def` is that recursive `let` definitions must be explicitly indicated by writing `let rec`.
For instance, one way to reverse a list involves a recursive helper function, as in this definition: -->

`let` と `def` の最大の違いは再帰的な `let` 定義は `let rec` と書いて明示的に示さなければならない点です．例えば，リストを反転させる方法の1つに，以下の定義のような再帰的なヘルパー関数を用いるものがあります：

```lean
{{#example_decl Examples/Intro.lean reverse}}
```
<!-- The helper function walks down the input list, moving one entry at a time over to `soFar`.
When it reaches the end of the input list, `soFar` contains a reversed version of the input. -->

ヘルパー関数は入力リストを下向きに進み，そのたびに1つの要素を `soFar` に移動していきます．入力リストの最後に到達すると，`soFar` には入力されたリストの逆順が格納されます．

<!-- ## Type Inference -->

## 型推論

<!-- In many situations, Lean can automatically determine an expression's type.
In these cases, explicit types may be omitted from both top-level definitions (with `def`) and local definitions (with `let`).
For instance, the recursive call to `unzip` does not need an annotation: -->

多くの場合，Leanは式の型を自動的に決定することができます．このような場合，（ `def` による）トップレベルの定義と（ `let` による）ローカル定義のどちらでも明示的な型の省略ができます．例えば，再帰的に呼び出される `unzip` には注釈は不要です：

```lean
{{#example_decl Examples/Intro.lean unzipNT}}
```

<!-- As a rule of thumb, omitting the types of literal values (like strings and numbers) usually works, although Lean may pick a type for literal numbers that is more specific than the intended type.
Lean can usually determine a type for a function application, because it already knows the argument types and the return type.
Omitting return types for function definitions will often work, but function arguments typically require annotations.
Definitions that are not functions, like `unzipped` in the example, do not need type annotations if their bodies do not need type annotations, and the body of this definition is a function application. -->

経験則として，（文字列や数値のような）リテラル値の型を省略することは通常うまくいきますが，Leanはリテラルの数値に対して意図した型よりも特殊な型を選ぶことがあります．Leanは関数適用の型を決定することができます，というのもすでに引数の型と戻り値の型を知っているからです．関数の定義で戻り値の型を省略することはよくありますが，引数には通常注釈が必要です．先ほどの `unzipped` のような関数ではない定義においては，その本体が型注釈を必要とせず，かつ定義の本体が関数適用である場合は型注釈を必要としません．

<!-- Omitting the return type for `unzip` is possible when using an explicit `match` expression: -->

明示的な `match` 式を使用する場合，`unzip` の戻り値の型を省略することができます:

```lean
{{#example_decl Examples/Intro.lean unzipNRT}}
```


<!-- Generally speaking, it is a good idea to err on the side of too many, rather than too few, type annotations.
First off, explicit types communicate assumptions about the code to readers.
Even if Lean can determine the type on its own, it can still be easier to read code without having to repeatedly query Lean for type information.
Secondly, explicit types help localize errors.
The more explicit a program is about its types, the more informative the error messages can be.
This is especially important in a language like Lean that has a very expressive type system.
Thirdly, explicit types make it easier to write the program in the first place.
The type is a specification, and the compiler's feedback can be a helpful tool in writing a program that meets the specification.
Finally, Lean's type inference is a best-effort system.
Because Lean's type system is so expressive, there is no "best" or most general type to find for all expressions.
This means that even if you get a type, there's no guarantee that it's the _right_ type for a given application.
For instance, `14` can be a `Nat` or an `Int`: -->

一般論として，型注釈は少なすぎるよりは多すぎる方が良いです．まず，明示的な型は読み手にコードの前提を伝えます．たとえLeanによって型が決定できるものでも，Leanに型情報をいちいち問い合わせることなくコードを読むことができます．第二に，明示的な型はエラーの特定に役立ちます．プログラムが型について明示的であればあるほど，エラーメッセージはより有益なものになります．これはLeanに限らず非常に表現力豊かな型システムを持つ言語では特に重要です．第三に，型が明示されていることによって，そもそもプログラムを書くのが簡単になります．型は仕様であり，コンパイラのフィードバックは仕様を満たすプログラムを書くのに役立つツールになります．最後に，Leanの型推論はベストエフォートなシステムです．Leanの型システムは非常に表現力が豊かであるため，すべての式に対して「最良」な型や最も一般的な型を見つけることができません．つまり，型が得られたとしても，それが与えられたアプリケーションにとって「正しい」型であるという保証はないということです．例えば，`14` は `Nat` にも `Int` にもなり得ます：

```lean
{{#example_in Examples/Intro.lean fourteenNat}}
```
```output info
{{#example_out Examples/Intro.lean fourteenNat}}
```
```lean
{{#example_in Examples/Intro.lean fourteenInt}}
```
```output info
{{#example_out Examples/Intro.lean fourteenInt}}
```

<!-- Missing type annotations can give confusing error messages.
Omitting all types from the definition of `unzip`: -->

型注釈が欠落すると，エラーメッセージがわかりづらくなります．`unzip` の定義からすべての型を省略すると：

```lean
{{#example_in Examples/Intro.lean unzipNoTypesAtAll}}
```
<!-- leads to a message about the `match` expression: -->

`match` 式について以下のようなメッセージが出力されます:

```output error
{{#example_out Examples/Intro.lean unzipNoTypesAtAll}}
```
<!-- This is because `match` needs to know the type of the value being inspected, but that type was not available.
A "metavariable" is an unknown part of a program, written `?m.XYZ` in error messages—they are described in the [section on Polymorphism](polymorphism.md).
In this program, the type annotation on the argument is required. -->

これは `match` が受け取った検査対象の値の型を知る必要がありますが，その型が利用できなかったためです．「metavariable（メタ変数）」とはプログラムの未知の部分のことで，エラーメッセージでは `?m.XYZ` と書かれます．これについては [「多相性」節](polymorphism.md) で解説しています．このプログラムでは，引数の型注釈が必要です．

<!-- Even some very simple programs require type annotations.
For instance, the identity function just returns whatever argument it is passed.
With argument and type annotations, it looks like this: -->

非常に単純なプログラムであっても，型注釈を必要とするものがあります．例えば，恒等関数は渡された引数をそのまま返すだけの関数です．引数と型注釈を使うと次のようになります：

```lean
{{#example_decl Examples/Intro.lean idA}}
```
<!-- Lean is capable of determining the return type on its own: -->

Leanはこの戻り値の型を自力で決定できます：

```lean
{{#example_decl Examples/Intro.lean idB}}
```
<!-- Omitting the argument type, however, causes an error: -->

ここで引数の型を削除すると，以下のエラーを引き起こします：

```lean
{{#example_in Examples/Intro.lean identNoTypes}}
```
```output error
{{#example_out Examples/Intro.lean identNoTypes}}
```

<!-- In general, messages that say something like "failed to infer" or that mention metavariables are often a sign that more type annotations are necessary.
Especially while still learning Lean, it is useful to provide most types explicitly. -->

一般的に，「failed to infer（推論に失敗）」のようなメッセージやメタ変数に言及したメッセージは型注釈が足りていないというサインであることが多いです．特にLeanを学習している段階においては，ほとんどの型を明示的に提供することが有用です．

<!-- ## Simultaneous Matching -->

## 同時パターンマッチ

<!-- Pattern-matching expressions, just like pattern-matching definitions, can match on multiple values at once.
Both the expressions to be inspected and the patterns that they match against are written with commas between them, similarly to the syntax used for definitions.
Here is a version of `drop` that uses simultaneous matching: -->

パターンマッチング式は，パターンマッチング定義と同様に，一度に複数の値にマッチすることができます．検査する式とマッチするパターンは，定義に使われる構文と同じようにカンマで区切って記述します．以下は同時パターンマッチを使用するバージョンの `drop` です：

```lean
{{#example_decl Examples/Intro.lean dropMatch}}
```

<!-- ## Natural Number Patterns -->

## 整数のパターンマッチ

<!-- In the section on [datatypes and patterns](datatypes-and-patterns.md), `even` was defined like this: -->

[「データ型，パターンそして再帰」](datatypes-and-patterns.md)の節において，`even` は次のように定義されていました：

```lean
{{#example_decl Examples/Intro.lean even}}
```
<!-- Just as there is special syntax to make list patterns more readable than using `List.cons` and `List.nil` directly, natural numbers can be matched using literal numbers and `+`.
For instance, `even` can also be defined like this: -->

リストのパターンマッチを `List.cons` や `List.nil` を使うよりも読みやすくするための特別な構文があるように，自然数もリテラル数値と `+` を使ってマッチさせることができます．例えば，`even` は以下のように定義することもできます：

```lean
{{#example_decl Examples/Intro.lean evenFancy}}
```

<!-- In this notation, the arguments to the `+` pattern serve different roles.
Behind the scenes, the left argument (`n` above) becomes an argument to some number of `Nat.succ` patterns, and the right argument (`1` above) determines how many `Nat.succ`s to wrap around the pattern.
The explicit patterns in `halve`, which divides a `Nat` by two and drops the remainder: -->

この記法では，`+` パターンの引数は異なる役割を果たします．裏側では，左の引数（上の `n` ）は何かしらの数値の `Nat.succ` パターンの引数になり，右の引数（上の `1` ）はパターンにラップする `Nat.succ` の数を決定します．さて，次に `halve` 関数の明示的なパターンでは `Nat` を2で割って余りを落とします：

```lean
{{#example_decl Examples/Intro.lean explicitHalve}}
```
<!-- can be replaced by numeric literals and `+`: -->

このパターンマッチは数値リテラルと `+` で置き換えることができます：

```lean
{{#example_decl Examples/Intro.lean halve}}
```
<!-- Behind the scenes, both definitions are completely equivalent.
Remember: `halve n + 1` is equivalent to `(halve n) + 1`, not `halve (n + 1)`. -->

この裏側では，上記二つの定義はどちらも完全に等価です．ここで覚えておいてほしいこととして，`halve n + 1` は `(halve n) + 1` と等価であり，`halve (n + 1)` とは等価ではありません．

<!-- When using this syntax, the second argument to `+` should always be a literal `Nat`.
Even though addition is commutative, flipping the arguments in a pattern can result in errors like the following: -->

この構文を使う場合，`+` の第二引数は常に `Nat` のリテラルでなければなりません．また可算は可換であるにもかかわらず，パターン内の引数を反転させると次のようなエラーになることがあります：

```lean
{{#example_in Examples/Intro.lean halveFlippedPat}}
```
```output error
{{#example_out Examples/Intro.lean halveFlippedPat}}
```
<!-- This restriction enables Lean to transform all uses of the `+` notation in a pattern into uses of the underlying `Nat.succ`, keeping the language simpler behind the scenes. -->

この制限により，Leanはパターン内で `+` 表記を使用する場合はすべて，その基礎となる `Nat.succ` 表記に変換することができます．

<!-- ## Anonymous Functions -->

## 無名関数

<!-- Functions in Lean need not be defined at the top level.
As expressions, functions are produced with the `fun` syntax.
Function expressions begin with the keyword `fun`, followed by one or more arguments, which are separated from the return expression using `=>`.
For instance, a function that adds one to a number can be written: -->

Leanの関数はトップレベルで定義する必要はありません．式としての関数は `fun` 構文で生成されます．関数式はキーワード `fun` で始まり，1つ以上の引数が続き，その後に `=>` を挟んで返される式が続きます．例えば，ある数値に1を足す関数は次のように書くことができます：

```lean
{{#example_in Examples/Intro.lean incr}}
```
```output info
{{#example_out Examples/Intro.lean incr}}
```
<!-- Type annotations are written the same way as on `def`, using parentheses and colons: -->

型注釈は `def` と同じように括弧とコロンを使って記述します：

```lean
{{#example_in Examples/Intro.lean incrInt}}
```
```output info
{{#example_out Examples/Intro.lean incrInt}}
```
<!-- Similarly, implicit arguments may be written with curly braces: -->

同じように，暗黙引数は波括弧を使って記述します：

```lean
{{#example_in Examples/Intro.lean identLambda}}
```
```output info
{{#example_out Examples/Intro.lean identLambda}}
```
<!-- This style of anonymous function expression is often referred to as a _lambda expression_, because the typical notation used in mathematical descriptions of programming languages uses the Greek letter λ (lambda) where Lean has the keyword `fun`.
Even though Lean does permit `λ` to be used instead of `fun`, it is most common to write `fun`. -->

この無名関数式のスタイルはしばしば **ラムダ式** （lambda expression）と呼ばれます，というのもLeanではキーワード `fun` に対応するプログラミング言語の数学的な記述で使われる典型的な表記法はギリシャ文字のλ（ラムダ）だからです．Leanでも `fun` の代わりに `λ` を使うことができますが，`fun` と書く方が一般的です．

<!-- Anonymous functions also support the multiple-pattern style used in `def`.
For instance, a function that returns the predecessor of a natural number if it exists can be written: -->

無名関数は `def` で使われる複数パターンのスタイルもサポートしています．例えば，ある自然数に対して，もし存在するならそのひとつ前を返す関数は以下のように書けます：

```lean
{{#example_in Examples/Intro.lean predHuh}}
```
```output info
{{#example_out Examples/Intro.lean predHuh}}
```
<!-- Note that Lean's own description of the function has a named argument and a `match` expression.
Many of Lean's convenient syntactic shorthands are expanded to simpler syntax behind the scenes, and the abstraction sometimes leaks. -->

関数に対してLeanから実際に付けられる情報には，名前付き引数と `match` 式があることに注意してください．Leanの便利な構文の短縮形の多くは，裏ではより単純な構文に拡張されており，抽象化が漏れることもあります．

<!-- Definitions using `def` that take arguments may be rewritten as function expressions.
For instance, a function that doubles its argument can be written as follows: -->

`def` を使った定義で引数を取るものは，関数式に置き換えることができます．例えば，引数を2倍にする関数は以下のように書けます：

```lean
{{#example_decl Examples/Intro.lean doubleLambda}}
```

<!-- When an anonymous function is very simple, like `{{#example_eval Examples/Intro.lean incrSteps 0}}`, the syntax for creating the function can be fairly verbose.
In that particular example, six non-whitespace characters are used to introduce the function, and its body consists of only three non-whitespace characters.
For these simple cases, Lean provides a shorthand.
In an expression surrounded by parentheses, a centered dot character `·` can stand for an argument, and the expression inside the parentheses becomes the function's body.
That particular function can also be written `{{#example_eval Examples/Intro.lean incrSteps 1}}`. -->

無名関数が，`{{#example_eval Examples/Intro.lean incrSteps 0}}` のように非常に単純な場合，関数を作成する構文はかなり冗長になります．この例では，6つの非空白文字が関数の導入に使用され，本体は3つの非空白文字で構成されています．このような単純なケースのために，Leanは省略記法を用意しています．括弧で囲まれた式の中で，中黒点 `·` が引数を表し，括弧の中の式が関数の本体になります．この関数は `{{#example_eval Examples/Intro.lean incrSteps 1}}` と書くこともできます．

<!-- The centered dot always creates a function out of the _closest_ surrounding set of parentheses.
For instance, `{{#example_eval Examples/Intro.lean funPair 0}}` is a function that returns a pair of numbers, while `{{#example_eval Examples/Intro.lean pairFun 0}}` is a pair of a function and a number.
If multiple dots are used, then they become arguments from left to right: -->

中黒点は常に最も近い括弧から関数を生成します．例えば，`{{#example_eval Examples/Intro.lean funPair 0}}` は数字のペアを返す関数で，`{{#example_eval Examples/Intro.lean pairFun 0}}` は関数と数字のペアです．複数の点が使用された場合，それらは左から右の順に複数の引数になります：

```lean
{{#example_eval Examples/Intro.lean twoDots}}
```

<!-- Anonymous functions can be applied in precisely the same way as functions defined using `def` or `let`.
The command `{{#example_in Examples/Intro.lean applyLambda}}` results in: -->

無名関数は `def` や `let` で定義された関数とまったく同じように適用することができます．コマンド `{{#example_in Examples/Intro.lean applyLambda}}` の結果は以下のようになります：

```output info
{{#example_out Examples/Intro.lean applyLambda}}
```
<!-- while `{{#example_in Examples/Intro.lean applyCdot}}` results in: -->

一方で `{{#example_in Examples/Intro.lean applyCdot}}` の結果は以下のようになります：

```output info
{{#example_out Examples/Intro.lean applyCdot}}
```

<!-- ## Namespaces -->

## 名前空間

<!-- Each name in Lean occurs in a _namespace_, which is a collection of names.
Names are placed in namespaces using `.`, so `List.map` is the name `map` in the `List` namespace.
Names in different namespaces do not conflict with each other, even if they are otherwise identical.
This means that `List.map` and `Array.map` are different names.
Namespaces may be nested, so `Project.Frontend.User.loginTime` is the name `loginTime` in the nested namespace `Project.Frontend.User`. -->

Leanの各名前は名前の集まりである **名前空間** （namespace）の中に存在します．名前は `.` を使って名前空間に配置されるので，`List.map` は `List` 名前空間の `map` という名前になります．名前空間が異なる名前同士は，たとえ同じ名前であっても衝突することはありません．つまり，`List.map` と `Array.map` は異なる名前です．名前空間は入れ子にすることができるので，`Project.Frontend.User.loginTime` は `Project.Frontend.User` の `loginTime` という名前になります．

<!-- Names can be directly defined within a namespace.
For instance, the name `double` can be defined in the `Nat` namespace: -->

名前は名前空間内で直接定義することができます．例えば，`double` という名前は `Nat` 名前空間で定義することができます：

```lean
{{#example_decl Examples/Intro.lean NatDouble}}
```
<!-- Because `Nat` is also the name of a type, dot notation is available to call `Nat.double` on expressions with type `Nat`: -->

`Nat` は型の名前でもあるので，ドット記法を使えば `Nat` 型の式で `Nat.double` を呼び出すことができる：

```lean
{{#example_in Examples/Intro.lean NatDoubleFour}}
```
```output info
{{#example_out Examples/Intro.lean NatDoubleFour}}
```

<!-- In addition to defining names directly in a namespace, a sequence of declarations can be placed in a namespace using the `namespace` and `end` commands.
For instance, this defines `triple` and `quadruple` in the namespace `NewNamespace`: -->

名前空間内で直接名前を定義するだけでなく，`namespace` コマンドと `end` コマンドを使用して一連の宣言を名前空間内に配置することができます．例えば，以下では名前空間 `NewNamespace` に `triple` と `quadruple` を定義しています：

```lean
{{#example_decl Examples/Intro.lean NewNamespace}}
```
<!-- To refer to them, prefix their names with `NewNamespace.`: -->

これらを参照するには，それらの名前に接頭辞 `NewNamespace.` を付けます：

```lean
{{#example_in Examples/Intro.lean tripleNamespace}}
```
```output info
{{#example_out Examples/Intro.lean tripleNamespace}}
```
```lean
{{#example_in Examples/Intro.lean quadrupleNamespace}}
```
```output info
{{#example_out Examples/Intro.lean quadrupleNamespace}}
```

<!-- Namespaces may be _opened_, which allows the names in them to be used without explicit qualification.
Writing `open MyNamespace in` before an expression causes the contents of `MyNamespace` to be available in the expression.
For example, `timesTwelve` uses both `quadruple` and `triple` after opening `NewNamespace`: -->

名前空間は **開く** （open）ことができます．これによって名前空間内の名前を明示的に指定することなく使うことができるようになります．式の前に `open MyNamespace in` と書くと，その式で `MyNamespace` の内容が使用できるようになります．以下の例で，`timesTwelve` は `NewNamespace` を開いた後に `quadruple` と `triple` の両方を使用しています：

```lean
{{#example_decl Examples/Intro.lean quadrupleOpenDef}}
```
<!-- Namespaces can also be opened prior to a command.
This allows all parts of the command to refer to the contents of the namespace, rather than just a single expression.
To do this, place the `open ... in` prior to the command. -->

名前空間はコマンドの前に開くこともできます．これにより単一の式内ではなく，コマンドのすべての部分で名前空間の内容を参照できるようになります．これを行うには，コマンドの前に `open ... in` を置きます：

```lean
{{#example_in Examples/Intro.lean quadrupleNamespaceOpen}}
```
```output info
{{#example_out Examples/Intro.lean quadrupleNamespaceOpen}}
```
<!-- Function signatures show the name's full namespace.
Namespaces may additionally be opened for _all_ following commands for the rest of the file.
To do this, simply omit the `in` from a top-level usage of `open`. -->

関数のシグネチャは，名前の完全な名前空間を示します．名前空間はさらに，ファイルの残りの部分 **すべて** のコマンドのために開くこともできます．これを行うには `open` のトップレベルの使用法から `in` を省略するだけです．

## if let

<!-- When consuming values that have a sum type, it is often the case that only a single constructor is of interest.
For instance, given this type that represents a subset of Markdown inline elements: -->

直和型を持つ値を計算する場合，複数のコンストラクタの中のどれか一つだけが注目されることがよくあります．例えば，Markdownのインライン要素のサブセットを表す以下の型を考えます：

```lean
{{#example_decl Examples/Intro.lean Inline}}
```
<!-- a function that recognizes string elements and extracts their contents can be written: -->

ここで文字列要素を認識してその内容を抽出する関数を書くことができます：

```lean
{{#example_decl Examples/Intro.lean inlineStringHuhMatch}}
```
<!-- An alternative way of writing this function's body uses `if` together with `let`: -->

この関数の本体部分は，`if` を `let` と一緒に使うことでも記述できます：

```lean
{{#example_decl Examples/Intro.lean inlineStringHuh}}
```
<!-- This is very much like the pattern-matching `let` syntax.
The difference is that it can be used with sum types, because a fallback is provided in the `else` case.
In some contexts, using `if let` instead of `match` can make code easier to read. -->

これはパターンマッチの `let` 構文によく似ています．違いは，`else` の場合にフォールバックするようになるため，直和型で使用できる点です．文脈によっては，`match` の代わりに `if let` を使うとコードが読みやすくなることがあります．

<!-- ## Positional Structure Arguments -->

## 構造体の位置引数

<!-- The [section on structures](structures.md) presents two ways of constructing structures: -->

[「構造体」の節](structures.md) では構造体の構築の仕方について2つの方法を紹介しました：

 <!-- 1. The constructor can be called directly, as in `{{#example_in Examples/Intro.lean pointCtor}}`. -->

 1. `{{#example_in Examples/Intro.lean pointCtor}}` のようにコンストラクタを直接呼ぶ．

 <!-- 2. Brace notation can be used, as in `{{#example_in Examples/Intro.lean pointBraces}}`. -->

 2. `{{#example_in Examples/Intro.lean pointBraces}}` のように括弧記法を使う．

<!-- In some contexts, it can be convenient to pass arguments positionally, rather than by name, but without naming the constructor directly.
For instance, defining a variety of similar structure types can help keep domain concepts separate, but the natural way to read the code may treat each of them as being essentially a tuple.
In these contexts, the arguments can be enclosed in angle brackets `⟨` and `⟩`.
A `Point` can be written `{{#example_in Examples/Intro.lean pointPos}}`.
Be careful!
Even though they look like the less-than sign `<` and greater-than sign `>`, these brackets are different.
They can be input using `\<` and `\>`, respectively. -->

文脈によっては，コンストラクタに直接名前を付けずに，名前ではなく位置で引数を渡すと便利な場合があります．例えば，様々な似たような構造体タイプを定義することで，ドメイン概念を分離しておくことができますが，コードを読む際にはそれらを実質的にタプルとして扱う方が自然です．このような文脈では，引数を角括弧 `⟨` と `⟩` で囲むことができます．`Point` は `{{#example_in Examples/Intro.lean pointPos}}` と書くことができます．ここで注意点です！この括弧は小なり記号 `<` と大なり記号 `>` のように見えますが，これらの括弧は違うものです．それぞれ `\<` と `\>` で入力できます．

<!-- Just as with the brace notation for named constructor arguments, this positional syntax can only be used in a context where Lean can determine the structure's type, either from a type annotation or from other type information in the program.
For instance, `{{#example_in Examples/Intro.lean pointPosEvalNoType}}` yields the following error: -->

名前付きコンストラクタ引数の波括弧表記と同様に，この位置指定構文は，型注釈やプログラム内の他の型情報から，Leanが構造体の型を決定できるコンテキストでのみ使用できます．例えば，`{{#example_in Examples/Intro.lean pointPosEvalNoType}}` は以下のエラーを返します：

```output error
{{#example_out Examples/Intro.lean pointPosEvalNoType}}
```
<!-- The metavariable in the error is because there is no type information available.
Adding an annotation, such as in `{{#example_in Examples/Intro.lean pointPosWithType}}`, solves the problem: -->

エラーのメタ変数は，利用可能な型情報が無いためです．例えば，`{{#example_in Examples/Intro.lean pointPosWithType}}` のような注釈を追加することで問題は解決します：

```output info
{{#example_out Examples/Intro.lean pointPosWithType}}
```


<!-- ## String Interpolation -->

## 文字列への内挿

<!-- In Lean, prefixing a string with `s!` triggers _interpolation_, where expressions contained in curly braces inside the string are replaced with their values.
This is similar to `f`-strings in Python and `$`-prefixed strings in C#.
For instance, -->

Leanでは，文字列の先頭に `s!` を付けると **内挿** が発動し，文字列内の波括弧に含まれる式がその値に置き換えられます．これはPythonの `f` 文字列や，C#の `$` 接頭辞付き文字列に似ています．例えば，

```lean
{{#example_in Examples/Intro.lean interpolation}}
```
<!-- yields the output -->

は以下を出力します

```output info
{{#example_out Examples/Intro.lean interpolation}}
```

<!-- Not all expressions can be interpolated into a string.
For instance, attempting to interpolate a function results in an error. -->

すべての式を文字列に内挿できるわけではありません．例えば，関数を内挿しようとするとエラーになります．

```lean
{{#example_in Examples/Intro.lean interpolationOops}}
```
<!-- yields the output -->

上記は以下を出力します

```output info
{{#example_out Examples/Intro.lean interpolationOops}}
```
<!-- This is because there is no standard way to convert functions into strings.
The Lean compiler maintains a table that describes how to convert values of various types into strings, and the message `failed to synthesize instance` means that the Lean compiler didn't find an entry in this table for the given type.
This uses the same language feature as the `deriving Repr` syntax that was described in the [section on structures](structures.md). -->

これは，関数を文字列に変換する標準的な方法がないからです．Leanコンパイラはさまざまな型の値を文字列に変換する方法を記述したテーブルを保持しており，`failed to synthesize instance` というメッセージはLeanコンパイラがこのテーブルの中から指定された型の要素を見つけられなかったことを意味します．これは[「構造体」の節](structures.md) で説明した `deriving Repr` 構文と同じ言語機能を使用しています．
