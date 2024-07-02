<!-- # Structures and Inheritance -->

# 構造体と継承

<!-- In order to understand the full definitions of `Functor`, `Applicative`, and `Monad`, another Lean feature is necessary: structure inheritance.
Structure inheritance allows one structure type to provide the interface of another, along with additional fields.
This can be useful when modeling concepts that have a clear taxonomic relationship.
For example, take a model of mythical creatures.
Some of them are large, and some are small: -->

`Functor` と `Applicative` ，`Monad` の完全な定義を理解するためには，構造体の継承というLeanの別の帰納が必要になります．構造体の継承は，ある構造体型にフィールドを追加した別の構造体のインタフェースを提供することを可能にします．これは明確な分類学的な関係を持つ概念をモデル化するときに便利です．例えば，神話上の生き物のモデルを考えてみましょう．その中には大きいものも居れば，小さいものも居ます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MythicalCreature}}
```
<!-- Behind the scenes, defining the `MythicalCreature` structure creates an inductive type with a single constructor called `mk`: -->

裏側では，`MythicalCreature` 構造体を定義すると `mk` というコンストラクタを1つだけ持つ帰納型が作られます：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean MythicalCreatureMk}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean MythicalCreatureMk}}
```
<!-- Similarly, a function `MythicalCreature.large` is created that actually extracts the field from the constructor: -->

同様に，コンストラクタから実際のフィールドを取り出す関数 `MythicalCreature.large` が作られます：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean MythicalCreatureLarge}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean MythicalCreatureLarge}}
```

<!-- In most old stories, each monster can be defeated in some way.
A description of a monster should include this information, along with whether it is large: -->

ほとんどの昔話において，それぞれの怪物は何らかの方法で倒すことができます．怪物の説明文には，大型かどうかと共に，この情報を含めるべきでしょう：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Monster}}
```
<!-- The `extends MythicalCreature` in the heading states that every monster is also mythical.
To define a `Monster`, both the fields from `MythicalCreature` and the fields from `Monster` should be provided.
A troll is a large monster that is vulnerable to sunlight: -->

先頭行に含まれる `extends MythicalCreature` はすべての怪物もまた神話的であると述べています．`Monster` を定義するには，`MythicalCreature` のフィールドと `Monster` のフィールドの両方を提供しなければなりません．トロールは大型の怪物で，その弱点は日光です：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean troll}}
```

<!-- Behind the scenes, inheritance is implemented using composition.
The constructor `Monster.mk` takes a `MythicalCreature` as its argument: -->

裏側では，継承は合成を用いて実装されています．コンストラクタ `Monster.mk` は `MythicalCreature` を引数に取ります：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean MonsterMk}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean MonsterMk}}
```
<!-- In addition to defining functions to extract the value of each new field, a function `{{#example_in Examples/FunctorApplicativeMonad.lean MonsterToCreature}}` is defined with type `{{#example_out Examples/FunctorApplicativeMonad.lean MonsterToCreature}}`.
This can be used to extract the underlying creature. -->

各新しいフィールドの値を抽出する関数の定義に加えて，`{{#example_out Examples/FunctorApplicativeMonad.lean MonsterToCreature}}` 型の関数 `{{#example_in Examples/FunctorApplicativeMonad.lean MonsterToCreature}}` が定義されています．これはベースになっている生き物を抽出するために使用できます．

<!-- Moving up the inheritance hierarchy in Lean is not the same thing as upcasting in object-oriented languages.
An upcast operator causes a value from a derived class to be treated as an instance of the parent class, but the value retains its identity and structure.
In Lean, however, moving up the inheritance hierarchy actually erases the underlying information.
To see this in action, consider the result of evaluating `troll.toMythicalCreature`: -->

Leanにおける継承の階層の移動はオブジェクト指向言語におけるアップキャストとは異なります．アップキャスト演算子は派生クラスの値を親クラスのインスタンスとして扱いますが，値自体は中身も構造もそのままです．しかしLeanでは，継承階層を上がることで実際にその中に含まれる情報を削除します．このことを実際に見るために，`troll.toMythicalCreature` の評価結果を考察してみましょう：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean evalTrollCast}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean evalTrollCast}}
```
<!-- Only the fields of `MythicalCreature` remain. -->

`MythicalCreature` のフィールドだけが残ります．

<!-- Just like the `where` syntax, curly-brace notation with field names also works with structure inheritance: -->

`where` 構文と同様に，フィールド名を伴った波括弧記法でも構造体の継承が機能します：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean troll2}}
```
<!-- However, the anonymous angle-bracket notation that delegates to the underlying constructor reveals the internal details: -->

その一方で，基礎となるコンストラクタに委譲する無名の角括弧記法では内部構造があらわになります：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean wrongTroll1}}
```
```output error
{{#example_out Examples/FunctorApplicativeMonad.lean wrongTroll1}}
```
<!-- An extra set of angle brackets is required, which invokes `MythicalCreature.mk` on `true`: -->

ここでは `true` で `MythicalCreature.mk` が起動するようにもう1つ角括弧が必要になります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean troll3}}
```


<!-- Lean's dot notation is capable of taking inheritance into account.
In other words, the existing `MythicalCreature.large` can be used with a `Monster`, and Lean automatically inserts the call to `{{#example_in Examples/FunctorApplicativeMonad.lean MonsterToCreature}}` before the call to `MythicalCreature.large`.
However, this only occurs when using dot notation, and applying the field lookup function using normal function call syntax results in a type error: -->

Leanのドット記法は継承を考慮にいれることを許容しています．言い換えると，既存の `MythicalCreature.large` は `Monster` で使用することができ，その際にはLeanが自動的に `MythicalCreature.large` の呼び出し前に `{{#example_in Examples/FunctorApplicativeMonad.lean MonsterToCreature}}` の呼び出しを挿入します．しかしこれはドット記法を使った場合のみに発生し，通常の関数呼び出し構文を使用してフィールド検索関数を適用すると型エラーが発生します：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean trollLargeNoDot}}
```
```output error
{{#example_out Examples/FunctorApplicativeMonad.lean trollLargeNoDot}}
```
<!-- Dot notation can also take inheritance into account for user-defined functions.
A small creature is one that is not large: -->

ドット記法はユーザ定義関数に対しても継承を考慮にいれることができます．小さい生き物とは，大きくない生き物のことです：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean small}}
```
<!-- Evaluating `{{#example_in Examples/FunctorApplicativeMonad.lean smallTroll}}` yields `{{#example_out Examples/FunctorApplicativeMonad.lean smallTroll}}`, while attempting to evaluate `{{#example_in Examples/FunctorApplicativeMonad.lean smallTrollWrong}}` results in: -->

`{{#example_in Examples/FunctorApplicativeMonad.lean smallTroll}}` を評価すると `{{#example_out Examples/FunctorApplicativeMonad.lean smallTroll}}` が出力される一方で，`{{#example_in Examples/FunctorApplicativeMonad.lean smallTrollWrong}}` は評価しようとすると以下の結果になります：

```output error
{{#example_out Examples/FunctorApplicativeMonad.lean smallTrollWrong}}
```

<!-- ### Multiple Inheritance -->

### 多重継承

<!-- A helper is a mythical creature that can provide assistance when given the correct payment: -->

ヘルパーとは神話上の生き物で，適切な報酬が与えられれば援助を提供してくれます：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Helper}}
```
<!-- For example, a _nisse_ is a kind of small elf that's known to help around the house when provided with tasty porridge: -->

例えば，**ニッセ** は小さな妖精の一種で，おいしいおかゆをあげると家の手伝いをしてくれると言われています：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean elf}}
```

<!-- If domesticated, trolls make excellent helpers.
They are strong enough to plow a whole field in a single night, though they require model goats to keep them satisfied with their lot in life.
A monstrous assistant is a monster that is also a helper: -->

もし従えることができれば，トロールは優秀なヘルパーになります．トロールは畑一面をすべて耕すのに1晩でできるほどパワフルですが，彼らの生活を満足させるためにはヤギの模型が必要です．怪物のような助っ人は，ヘルパーでもある怪物のことです：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonstrousAssistant}}
```
<!-- A value of this structure type must fill in all of the fields from both parent structures: -->

この構造体型の値は，親である両方の構造体のフィールドをすべて埋めなければなりません：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean domesticatedTroll}}
```

<!-- Both of the parent structure types extend `MythicalCreature`.
If multiple inheritance were implemented naïvely, then this could lead to a "diamond problem", where it would be unclear which path to `large` should be taken from a given `MonstrousAssistant`.
Should it take `large` from the contained `Monster` or from the contained `Helper`?
In Lean, the answer is that the first specified path to the grandparent structure is taken, and the additional parent structures' fields are copied rather than having the new structure include both parents directly. -->

どちらの親構造体型も `MythicalCreature` を継承しています．もし単純に多重継承を実装しようとすると，`large` を `MonstrousAssistant` から取得する際の経路が不明確になるという「菱形継承問題」が発生する可能性があります．`large` は含まれている `Monster` と，それとも `Helper` のどちらから取るべきしょうか？Leanでは，新しい構造体が両方の親を直接含むのではなく，最初に指定された親の親構造体へのパスが取得され，そののちに親構造で追加されたフィールドがコピーされるという解決策を取っています．

<!-- This can be seen by examining the signature of the constructor for `MonstrousAssistant`: -->

これは `MonstrousAssistant` のコンストラクタのシグネチャを調べればわかります：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkMonstrousAssistantMk}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkMonstrousAssistantMk}}
```
<!-- It takes a `Monster` as an argument, along with the two fields that `Helper` introduces on top of `MythicalCreature`.
Similarly, while `MonstrousAssistant.toMonster` merely extracts the `Monster` from the constructor, `MonstrousAssistant.toHelper` has no `Helper` to extract.
The `#print` command exposes its implementation: -->

このコンストラクタは `Monster` と，`MythicalCreature` に `Helper` で導入されている2つのフィールドを引数に取ります．同じように，`MonstrousAssistant.toMonster` はコンストラクタからただ `Monster` を取り出すだけですが，`MonstrousAssistant.toHelper` には取り出せる `Helper` がありません．`#print` コマンドからこの実装を明らかにすることができます：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean printMonstrousAssistantToHelper}}
```
```output info
{{#example_out Examples/FunctorApplicativeMonad.lean printMonstrousAssistantToHelper}}
```
<!-- This function constructs a `Helper` from the fields of `MonstrousAssistant`.
The `@[reducible]` attribute has the same effect as writing `abbrev`. -->

この関数は `MonstrousAssistant` のフィールドから `Helper` を作成しています．`@[reducible]` 属性は `abbrev` を同じ効果を持ちます．

<!-- ### Default Declarations -->

### デフォルト宣言

<!-- When one structure inherits from another, default field definitions can be used to instantiate the parent structure's fields based on the child structure's fields.
If more size specificity is required than whether a creature is large or not, a dedicated datatype describing sizes can be used together with inheritance, yielding a structure in which the `large` field is computed from the contents of the `size` field: -->

ある構造体が別の構造体を継承する場合，デフォルトのフィールド定義は親構造体のフィールドを子構造体のフィールドをもとにインスタンス化することができます．クリーチャーが大きいかどうかよりもより詳細なサイズが必要な場合，サイズを記述する専用のデータ型を継承と一緒に使用することができ，`large` フィールドを `size` フィールドの内容から計算するような構造体を生み出します：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean SizedCreature}}
```
<!-- This default definition is only a default definition, however.
Unlike property inheritance in a language like C# or Scala, the definitions in the child structure are only used when no specific value for `large` is provided, and nonsensical results can occur: -->

しかし，このデフォルト定義はあくまでデフォルトで与えられる定義にすぎません．C#やScalaのような言語でのプロパティ継承とは異なり，この子構造体の定義は `large` に特定の値が与えられない場合にのみ使用されるため，無意味な結果が生じることもあります：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean nonsenseCreature}}
```
<!-- If the child structure should not deviate from the parent structure, there are a few options: -->

子構造が親構造から逸脱してはならない場合，いくつかの手段があります：

 <!-- 1. Documenting the relationship, as is done for `BEq` and `Hashable` -->
 1. 関係性を文書化すること，これは `BEq` と `Hashable` で行われているような感じです
 <!-- 2. Defining a proposition that the fields are related appropriately, and designing the API to require evidence that the proposition is true where it matters -->
 2. それらのフィールドが適切に関係していることを示す命題を定義し，APIをその命題が真であるという根拠を重要な部分として要求するように設計すること
 <!-- 3. Not using inheritance at all -->
 3. 継承を全く用いない

<!-- The second option could look like this: -->

2番目の選択肢は以下のような感じです：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean sizesMatch}}
```
<!-- Note that a single equality sign is used to indicate the equality _proposition_, while a double equality sign is used to indicate a function that checks equality and returns a `Bool`.
`SizesMatch` is defined as an `abbrev` because it should automatically be unfolded in proofs, so that `simp` can see the equality that should be proven. -->

ここで等号1つは **命題としての** 同値を示すために使用され，等号2つは同値をチェックしてから `Bool` を返す関数をしmrすために使用されることに注意してください．`SizesMatch` は `abbrev` として定義されていますが，これは証明の際に自動的に展開され，`simp` で証明したい同値を示すことができるようにするためです．

<!-- A _huldre_ is a medium-sized mythical creature—in fact, they are the same size as humans.
The two sized fields on `huldre` match one another: -->

**ハルダー** は中くらいの大きさの神話上の生き物です．もっと言うと人間と同じ大きさの生き物です．`huldre` の2つの大きさについてのフィールドは互いに一致します：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean huldresize}}
```


<!-- ### Type Class Inheritance -->

### 型クラスの継承

<!-- Behind the scenes, type classes are structures.
Defining a new type class defines a new structure, and defining an instance creates a value of that structure type.
They are then added to internal tables in Lean that allow it to find the instances upon request.
A consequence of this is that type classes may inherit from other type classes. -->

型クラスは，裏側では構造体だったのでした．新しい型クラスの定義は新しい構造体を定義し，インスタンスの定義はその構造体の値が作成されます．そしてこの値がLeanの内部テーブルに追加され，リクエストに応じてインスタンスを見つけることができるようになります．この結果，型クラスはほかの型クラスを継承することができます．

<!-- Because it uses precisely the same language features, type class inheritance supports all the features of structure inheritance, including multiple inheritance, default implementations of parent types' methods, and automatic collapsing of diamonds.
This is useful in many of the same situations that multiple interface inheritance is useful in languages like Java, C# and Kotlin.
By carefully designing type class inheritance hierarchies, programmers can get the best of both worlds: a fine-grained collection of independently-implementable abstractions, and automatic construction of these specific abstractions from larger, more general abstractions. -->

型クラスの継承は構造体のそれとまったく同じ言語機能を使用するため，型クラスの慶弔は多重継承，親の型のメソッドのデフォルト実装，菱形の自動的な折り畳みなどの構造体継承のすべての帰納をサポートしています．これは，Java，C#，Kotlinのような言語で多重インターフェース継承が有用であることと多くの同じような状況で有用です．型クラスの継承階層を注意深く設計することで，プログラマは両方からいいとこ取りをすることができます：すなわち，独立に実装可能な抽象化をきめ細やかに行うこと，そしてより広く一般的な抽象化から特定の抽象化を自動的に構築することです．
