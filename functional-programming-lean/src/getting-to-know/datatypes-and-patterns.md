<!-- # Datatypes and Patterns -->

# データ型とパターン

<!-- Structures enable multiple independent pieces of data to be combined into a coherent whole that is represented by a brand new type.
Types such as structures that group together a collection of values are called _product types_.
Many domain concepts, however, can't be naturally represented as structures.
For instance, an application might need to track user permissions, where some users are document owners, some may edit documents, and others may only read them.
A calculator has a number of binary operators, such as addition, subtraction, and multiplication.
Structures do not provide an easy way to encode multiple choices. -->

構造体を使用すれば，複数の独立したデータをひとまとまりにしてまったく新しい型をつくることができます．値の集まりをグループ化する構造体のような型は**直積型**(product types)と呼ばれます．ただし，多くのドメイン概念は構造体として自然に表現できません．例えば，アプリケーションによっては，ドキュメントの所有者であるユーザー，ドキュメントを編集できるユーザー，ドキュメントの閲覧しかできないユーザーなどユーザーのアクセス権限を追う必要があるかもしれません．電卓であれば，加算，減算，乗算のような二項演算子があります．構造体で複数の選択肢を表現する簡単な方法はありません

<!-- Similarly, while a structure is an excellent way to keep track of a fixed set of fields, many applications require data that may contain an arbitrary number of elements.
Most classic data structures, such as trees and lists, have a recursive structure, where the tail of a list is itself a list, or where the left and right branches of a binary tree are themselves binary trees.
In the aforementioned calculator, the structure of expressions themselves is recursive.
The summands in an addition expression may themselves be multiplication expressions, for instance. -->

同様に，構造体は決まったフィールド値を追跡する優れた方法ですが，多くのアプリケーションでは好きな数の要素を含むデータが必要です．ツリーやリストなどの古典的なデータ構造のほとんどは再帰的な構造を持っており，リストの残りの部分自体がリストになったり，二分木の左右の枝自体が二分木になったりします．例えば，加算式内の足される数自体が乗算式である場合があります．

<!-- Datatypes that allow choices are called _sum types_ and datatypes that can include instances of themselves are called _recursive datatypes_.
Recursive sum types are called _inductive datatypes_, because mathematical induction may be used to prove statements about them.
When programming, inductive datatypes are consumed through pattern matching and recursive functions. -->

選択を許可するデータ型は**直和型**(sum types)と呼ばれ，それ自体のインスタンスを含めることができるデータ型は**再帰データ型**(recursive datatypes)と呼ばれます．再帰直和型は，それらに関する文を証明するために数学的帰納法を使用できるため，**帰納的データ型**(inductive datatypes)と呼ばれます．プログラミングの際，帰納的データ型はパターンマッチングと再帰関数を通じて使用されます．

<!-- Many of the built-in types are actually inductive datatypes in the standard library.
For instance, `Bool` is an inductive datatype: -->

標準ライブラリでは，組み込み型の多くは実際には帰納的データ型です．例えば，`Bool`は帰納的データ型です．

```lean
{{#example_decl Examples/Intro.lean Bool}}
```
<!-- This definition has two main parts.
The first line provides the name of the new type (`Bool`), while the remaining lines each describe a constructor.
As with constructors of structures, constructors of inductive datatypes are mere inert receivers of and containers for other data, rather than places to insert arbitrary initialization and validation code.
Unlike structures, inductive datatypes may have multiple constructors.
Here, there are two constructors, `true` and `false`, and neither takes any arguments.
Just as a structure declaration places its names in a namespace named after the declared type, an inductive datatype places the names of its constructors in a namespace.
In the Lean standard library, `true` and `false` are re-exported from this namespace so that they can be written alone, rather than as `Bool.true` and `Bool.false`, respectively. -->

この定義には2つの主要な部分があります．初めの行は新しい型の名前(`Bool`)を提供し，残りの行はそれぞれコンストラクタを記述します．構造体のコンストラクタと同様，帰納的データ型のコンストラクタは，好きに初期化コードやバリデーションコードを挿入する場所ではなく，何もしない他のデータのレシーバおよびコンテナにすぎません．構造体とは異なり，帰納的データ型には複数のコンストラクタを持つ場合があります．今の例では，`true`と`false`という2つのコンストラクタがあり，どちらも引数を取りません．構造体宣言がそのフィールドの名前を，宣言された型にちなんで名付けられた名前空間に配置するのと同様に，帰納的データ型はそのコンストラクタの名前を名前空間に配置します．Lean標準ライブラリでは，`true`と`false`はこの名前空間から再エクスポートされるため，それぞれ`Bool.true`と`Bool.false`としてではなく，単独で記述できます．

<!-- From a data modeling perspective, inductive datatypes are used in many of the same contexts where a sealed abstract class might be used in other languages.
In languages like C# or Java, one might write a similar definition of `Bool`: -->

データモデリングの観点から見ると，帰納的データ型は抽象クラスが他の言語で使用される場合と同じコンテキストの多くで使用されます．C#やJavaのような言語では，同様の`Bool`の定義を書くことができます．

```C#
abstract class Bool {}
class True : Bool {}
class False : Bool {}
```

<!-- However, the specifics of these representations are fairly different. In particular, each non-abstract class creates both a new type and new ways of allocating data. In the object-oriented example, `True` and `False` are both types that are more specific than `Bool`, while the Lean definition introduces only the new type `Bool`. -->

ただし，これらの表現の詳細はかなり異なります．特に，各非抽象クラスは，新しい型と新しいデータ割り当て方法の両方を作成します．オブジェクト指向の例では，`True`と`False`は両方とも`Bool`よりも具体的な型ですが，Leanでの定義では新しい型`Bool`のみが導入されます．

<!-- The type `Nat` of non-negative integers is an inductive datatype: -->

非負整数の型`Nat`は帰納的データ型です．

```lean
{{#example_decl Examples/Intro.lean Nat}}
```

<!-- Here, `zero` represents 0, while `succ` represents the successor of some other number.
The `Nat` mentioned in `succ`'s declaration is the very type `Nat` that is in the process of being defined.
_Successor_ means "one greater than", so the successor of five is six and the successor of 32,185 is 32,186.
Using this definition, `{{#example_eval Examples/Intro.lean four 1}}` is represented as `{{#example_eval Examples/Intro.lean four 0}}`.
This definition is almost like the definition of `Bool` with slightly different names.
The only real difference is that `succ` is followed by `(n : Nat)`, which specifies that the constructor `succ` takes an argument of type `Nat` which happens to be named `n`.
The names `zero` and `succ` are in a namespace named after their type, so they must be referred to as `Nat.zero` and `Nat.succ`, respectively. -->

ここで，`zero`は0を表し，`succ`は他の数値の後続値を表します．`succ`の宣言で言及されている`Nat`は，まさに定義中の`Nat`型です．後続値(_Successor_)は`1つ大きい`を意味するため，5の後続値は6，32,185の後続値は32,186です．この定義を使用すると，`{{#example_eval Examples/Intro.lean four 1}}`は`{{#example_eval Examples/Intro.lean four 0}}`として表されます．この定義は，名前がわずかに異なる`Bool`の定義にほぼ似ています．唯一の本当の違いは，`succ`の後に`(n : Nat)`が続くことです．これは，コンストラクタ`succ`が`n`という名前の`Nat`型の引数を取ることを指定します．名前`zero`と`succ`は，その型にちなんで名付けられた名前空間内にあるため，それぞれ`Nat.zero`と`Nat.succ`として参照する必要があります．

<!-- Argument names, such as `n`, may occur in Lean's error messages and in feedback provided when writing mathematical proofs.
Lean also has an optional syntax for providing arguments by name.
Generally, however, the choice of argument name is less important than the choice of a structure field name, as it does not form as large a part of the API. -->

`n`などの引数名は，Leanのエラーメッセージや数学的証明を作成するときに提供されるフィードバックに出現することがあります．Leanには，引数を名前で指定するためのオプションの構文もあります．ただし，引数名を考えることはAPIの大部分を形成しないため，一般に構造体フィールド名を考えるときほど重要ではありません．

<!-- In C# or Java, `Nat` could be defined as follows: -->

C#またはJavaでは，`Nat`は次のように定義できます:
```C#
abstract class Nat {}
class Zero : Nat {}
class Succ : Nat {
  public Nat n;
  public Succ(Nat pred) {
	n = pred;
  }
}
```
<!-- Just as in the `Bool` example above, this defines more types than the Lean equivalent.
Additionally, this example highlights how Lean datatype constructors are much more like subclasses of an abstract class than they are like constructors in C# or Java, as the constructor shown here contains initialization code to be executed. -->

以前の`Bool`の例と同様に，これは同等のLeanで表される型よりも多くの型を定義します．さらに，この例ではLeanでのデータ型コンストラクタが，C#やJavaのコンストラクタというよりも抽象クラスのサブクラスによく似ていることを強調しています．これは，ここで示されているコンストラクタには，実行される初期化コードが含まれているためです．

<!-- Sum types are also similar to using a string tag to encode discriminated unions in TypeScript.
In TypeScript, `Nat` could be defined as follows: -->

直和型は，TypeScriptで文字列タグを使用して判別共用体をエンコードすることにも似ています．TypeScriptでは，`Nat`は次のように定義できます．

```typescript
interface Zero {
    tag: "zero";
}

interface Succ {
    tag: "succ";
    predecessor: Nat;
}

type Nat = Zero | Succ;
```
<!-- Just like C# and Java, this encoding ends up with more types than in Lean, because `Zero` and `Succ` are each a type on their own.
It also illustrates that Lean constructors correspond to objects in JavaScript or TypeScript that include a tag that identifies the contents. -->

C#やJavaと同様に，`Zero`と`Succ`はそれぞれ独立した型であるため，このエンコーディングではLeanよりも多くの型が含まれることになります．また，Leanのコンストラクタが中身を識別するタグを含むJavaScriptまたはTypeScriptのオブジェクトに対応することも示しています．

<!-- ## Pattern Matching -->

## パターンマッチング

<!-- In many languages, these kinds of data are consumed by first using an instance-of operator to check which subclass has been received and then reading the values of the fields that are available in the given subclass.
The instance-of check determines which code to run, ensuring that the data needed by this code is available, while the fields themselves provide the data.
In Lean, both of these purposes are simultaneously served by _pattern matching_. -->

多くの言語では，この種のデータは，最初にinstance-of演算子を使用してどのサブクラスを受け取ったかを確認し，次に与えられたサブクラスで使用可能なフィールドの値を読み取ることによって消費されます．instance-ofチェックは実行するコードを決定し，フィールド自体がデータを提供しながら，このコードで必要なデータが利用可能であることを確認します．Leanでは，これらの目的は両方とも**パターンマッチング**によって同時に達成されます．

<!-- An example of a function that uses pattern matching is `isZero`, which is a function that returns `true` when its argument is `Nat.zero`, or false otherwise. -->

パターンマッチングを使用する関数の例は`isZero`です．これは，引数が`Nat.zero`の場合に`true`を返し，それ以外の場合は`false`を返す関数です．

```lean
{{#example_decl Examples/Intro.lean isZero}}
```
<!-- The `match` expression is provided the function's argument `n` for destructuring.
If `n` was constructed by `Nat.zero`, then the first branch of the pattern match is taken, and the result is `true`.
If `n` was constructed by `Nat.succ`, then the second branch is taken, and the result is `false`. -->

`match`式には，デストラクトのために関数の引数`n`が指定されます．`n`が`Nat.zero`によって構築された場合，マッチパターンの最初の分岐が選択され，結果は`true`になります．`n`が`Nat.succ`によって構築された場合，2番目の分岐が選択され，結果は`false`になります．

<!-- Step-by-step, evaluation of `{{#example_eval Examples/Intro.lean isZeroZeroSteps 0}}` proceeds as follows: -->

`{{#example_eval Examples/Intro.lean isZeroZeroSteps 0}}`の評価は，段階的には次のように進められます．

```lean
{{#example_eval Examples/Intro.lean isZeroZeroSteps}}
```

<!-- Evaluation of `{{#example_eval Examples/Intro.lean isZeroFiveSteps 0}}` proceeds similarly: -->

`{{#example_eval Examples/Intro.lean isZeroFiveSteps 0}}`の評価も同様に行われます．

```lean
{{#example_eval Examples/Intro.lean isZeroFiveSteps}}
```

<!-- The `k` in the second branch of the pattern in `isZero` is not decorative.
It makes the `Nat` that is the argument to `succ` visible, with the provided name.
That smaller number can then be used to compute the final result of the expression. -->

`isZero`のパターンの2番目の分岐の`k`は飾りではありません．これにより，`succ`の引数である`Nat`が与えられた名前で表示されます．そのより小さい数値を使用して，式の最終結果を計算できます．

<!-- Just as the successor of some number \\( n \\) is one greater than \\( n \\) (that is, \\( n + 1\\)), the predecessor of a number is one less than it.
If `pred` is a function that finds the predecessor of a `Nat`, then it should be the case that the following examples find the expected result: -->

ある数値\\(n\\)の後続の数値が\\(n\\)より1大きい(つまり，\\(n+1\\))のと同じように，ある数値の前の数値はそれより1小さいです．`pred`がある`Nat`の前を見つける関数である場合，次の例では期待される結果が見つかるはずです．

```lean
{{#example_in Examples/Intro.lean predFive}}
```
```output info
{{#example_out Examples/Intro.lean predFive}}
```
```lean
{{#example_in Examples/Intro.lean predBig}}
```
```output info
{{#example_out Examples/Intro.lean predBig}}
```
<!-- Because `Nat` cannot represent negative numbers, `0` is a bit of a conundrum.
Usually, when working with `Nat`, operators that would ordinarily produce a negative number are redefined to produce `0` itself: -->

`Nat`は負の数を表すことができないため，`0`は少し難問です．通常，`Nat`を使用する場合，通常負の数を生成する演算子は，`0`自体を生成するように再定義されます．
```lean
{{#example_in Examples/Intro.lean predZero}}
```
```output info
{{#example_out Examples/Intro.lean predZero}}
```

<!-- To find the predecessor of a `Nat`, the first step is to check which constructor was used to create it.
If it was `Nat.zero`, then the result is `Nat.zero`.
If it was `Nat.succ`, then the name `k` is used to refer to the `Nat` underneath it.
And this `Nat` is the desired predecessor, so the result of the `Nat.succ` branch is `k`. -->

`Nat`の前を見つけるには，最初のステップはそれを作成するためにどのコンストラクターが使用されたかを確認することです．それが`Nat.zero`だった場合，結果は`Nat.zero`になります．それが`Nat.succ`だった場合，名前`k`はその下の`Nat`を参照するために使用されます．そして，この`Nat`が望ましい数値であるため，`Nat.succ`分岐の結果は`k`になります．
```lean
{{#example_decl Examples/Intro.lean pred}}
```
<!-- Applying this function to `5` yields the following steps: -->

この関数を`5`に適用すると，次の手順が出てきます．
```lean
{{#example_eval Examples/Intro.lean predFiveSteps}}
```

<!-- Pattern matching can be used with structures as well as with sum types.
For instance, a function that extracts the third dimension from a `Point3D` can be written as follows: -->

パターンマッチングは，直和型だけでなく構造体でも使用できます．たとえば，`Point3D`から\\(z\\)座標を取り出す関数は次のように記述できます．
```lean
{{#example_decl Examples/Intro.lean depth}}
```
<!-- In this case, it would have been much simpler to just use the `z` accessor, but structure patterns are occasionally the simplest way to write a function. -->

この場合，単に`z`アクセサーを使用する方がはるかにシンプルですが，構造体パターンが関数を記述する最もシンプルな方法になる場合があります．

<!-- ## Recursive Functions -->

## 再帰関数

<!-- Definitions that refer to the name being defined are called _recursive definitions_.
Inductive datatypes are allowed to be recursive; indeed, `Nat` is an example of such a datatype because `succ` demands another `Nat`.
Recursive datatypes can represent arbitrarily large data, limited only by technical factors like available memory.
Just as it would be impossible to write down one constructor for each natural number in the datatype definition, it is also impossible to write down a pattern match case for each possibility. -->

定義されている名前を参照する定義は，**再帰的定義**(recursive definitions)と呼ばれます．帰納的データ型は再帰的に書くことが許されます．実際，`succ`は別の`Nat`を要求するため，`Nat`はそのようなデータ型の例です．再帰データ型は，使用可能なメモリなどの技術的要因によってのみ制限される，任意の大きなデータを表すことができます．データ型定義時に自然数ごとに1つのコンストラクターを書き留めることが不可能であるのと同様に，可能性ごとにパターンマッチのケースを書き出すことも不可能です．

<!-- Recursive datatypes are nicely complemented by recursive functions.
A simple recursive function over `Nat` checks whether its argument is even.
In this case, `zero` is even.
Non-recursive branches of the code like this one are called _base cases_.
The successor of an odd number is even, and the successor of an even number is odd.
This means that a number built with `succ` is even if and only if its argument is not even. -->

再帰データ型は，再帰関数によって適切に補完されます．`Nat`に対する単純な再帰関数は，引数が偶数かどうかをチェックします．この場合，`zero`は偶数です．このようなコードの非再帰分岐は，**基底ケース**(base cases)と呼ばれます．奇数の後続は偶数であり，偶数の後続は奇数です．これは，`succ`で作成された数値は，その引数が偶数でない場合にのみ偶数であることを意味します．

```lean
{{#example_decl Examples/Intro.lean even}}
```

<!-- This pattern of thought is typical for writing recursive functions on `Nat`.
First, identify what to do for `zero`.
Then, determine how to transform a result for an arbitrary `Nat` into a result for its successor, and apply this transformation to the result of the recursive call.
This pattern is called _structural recursion_. -->

この思考パターンは，`Nat`で再帰関数を記述する場合によくあります．まず，`zero`に対して何をすべきかを特定します．次に，任意の`Nat`の結果をその後続の結果に変換する方法を決定し，この変換を再帰呼び出しの結果に適用します．このパターンは**構造的再帰**(structural recursion)と呼ばれます．

<!-- Unlike many languages, Lean ensures by default that every recursive function will eventually reach a base case.
From a programming perspective, this rules out accidental infinite loops.
But this feature is especially important when proving theorems, where infinite loops cause major difficulties.
A consequence of this is that Lean will not accept a version of `even` that attempts to invoke itself recursively on the original number: -->

多くの言語とは異なり，Leanはデフォルトで，すべての再帰関数が最終的に基本ケースに到達することを保証します．プログラミングの観点から見ると，これにより偶発的な無限ループが排除されます．ただし，この機能は，無限ループが大きな問題を引き起こすような定理を証明する場合に特に重要です．この結果，Leanは元々の数値に対して再帰的に自身を呼び出そうとするバージョンの`even`を受け入れなくなります．

```lean
{{#example_in Examples/Intro.lean evenLoops}}
```
<!-- The important part of the error message is that Lean could not determine that the recursive function always reaches a base case (because it doesn't). -->

エラーメッセージの重要な部分は，再帰関数が常に基本ケースに到達するかどうかを(実際到達しないが故に)Leanが判断できなかったことです．
```output error
{{#example_out Examples/Intro.lean evenLoops}}
```

<!-- Even though addition takes two arguments, only one of them needs to be inspected.
To add zero to a number \\( n \\), just return \\( n \\).
To add the successor of \\( k \\) to \\( n \\), take the successor of the result of adding \\( k \\) to \\( n \\). -->

加算には2つの引数が必要ですが，検査する必要があるのはそのうちの1つだけです．数値\\(n\\)に0を足すには，\\(n\\)を返すだけです．\\(k\\)の後続値を\\(n\\)に加算するには，\\(k\\)を\\(n\\)に加算した結果の後続値を取得します．
```lean
{{#example_decl Examples/Intro.lean plus}}
```
<!-- In the definition of `plus`, the name `k'` is chosen to indicate that it is connected to, but not identical with, the argument `k`.
For instance, walking through the evaluation of `{{#example_eval Examples/Intro.lean plusThreeTwo 0}}` yields the following steps: -->

`plus`の定義では，引数`k`に繋がっているが同一ではないことを示すために`k'`という名前が選択されています．たとえば，`{{#example_eval Examples/Intro.lean plusThreeTwo 0}}`の評価を実行すると，次の手順が出てきます．
```lean
{{#example_eval Examples/Intro.lean plusThreeTwo}}
```

<!-- One way to think about addition is that \\( n + k \\) applies `Nat.succ` \\( k \\) times to \\( n \\).
Similarly, multiplication \\( n × k \\) adds \\( n \\) to itself \\( k \\) times and subtraction \\( n - k \\) takes \\( n \\)'s predecessor \\( k \\) times. -->

加算について考える1つの方法は，\\(n + k\\)が`Nat.succ`を\\(n\\)に\\(k\\)回適用することです．同様に，乗算\\(n × k\\)は\\(n\\)を\\(n\\)自身に\\(k\\)回加算し，減算\\(n - k\\)は\\(n\\)の前者を\\(k\\)回取ります．
```lean
{{#example_decl Examples/Intro.lean times}}

{{#example_decl Examples/Intro.lean minus}}
```

<!-- Not every function can be easily written using structural recursion.
The understanding of addition as iterated `Nat.succ`, multiplication as iterated addition, and subtraction as iterated predecessor suggests an implementation of division as iterated subtraction.
In this case, if the numerator is less than the divisor, the result is zero.
Otherwise, the result is the successor of dividing the numerator minus the divisor by the divisor. -->

すべての関数が構造的再帰を使用して簡単に記述できるわけではありません．加算は`Nat.succ`の反復，乗算は加算の反復，減算は前者の反復として理解され，除算は減算の反復として実装されることが示唆されます．この場合，分子が除数より小さい場合，結果はゼロになります．それ以外の場合，結果は 分子から除数を引いた値を除数で除算したもの の後者になります．

```lean
{{#example_in Examples/Intro.lean div}}
```
<!-- As long as the second argument is not `0`, this program terminates, as it always makes progress towards the base case.
However, it is not structurally recursive, because it doesn't follow the pattern of finding a result for zero and transforming a result for a smaller `Nat` into a result for its successor.
In particular, the recursive invocation of the function is applied to the result of another function call, rather than to an input constructor's argument.
Thus, Lean rejects it with the following message: -->

2番目の引数が`0`でない限り，このプログラムは常に基本ケースに向かって進むため，終了します．ただし，ゼロの結果を見つけて，より小さい`Nat`の結果をその後続の結果に変換するパターンに従っていないため，構造的再帰ではありません．特に，関数の再帰呼び出しは，入力コンストラクターの引数ではなく，別の関数呼び出し(今回であれば引き算)の結果に適用されます．したがって，Leanは次のメッセージを表示してこれを拒否します．
```output error
{{#example_out Examples/Intro.lean div}}
```
<!-- This message means that `div` requires a manual proof of termination.
This topic is explored in [the final chapter](../programs-proofs/inequalities.md#division-as-iterated-subtraction). -->

このメッセージは，`div`には手動での終了の証明が必要であることを意味します．このトピックについては，[最終章](../programs-proofs/inequalities.md#division-as-iterated-subtraction)で説明します．
