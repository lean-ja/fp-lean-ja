<!--
# Overloading and Type Classes
-->

# オーバーロードと型クラス

<!--
In many languages, the built-in datatypes get special treatment.
For example, in C and Java, `+` can be used to add `float`s and `int`s, but not arbitrary-precision numbers from a third-party library.
Similarly, numeric literals can be used directly for the built-in types, but not for user-defined number types.
Other languages provide an _overloading_ mechanism for operators, where the same operator can be given a meaning for a new type.
In these languages, such as C++ and C#, a wide variety of built-in operators can be overloaded, and the compiler uses the type checker to select a particular implementation.
-->

多くの言語では，組み込みのデータ型は特別な扱いをうけます．例えば，CやJavaでは `+` を `float` や `int` の足し算に利用できますが，サードパーティライブラリの任意精度の数値の足し算に使うことはできません．同様に，数値リテラルは組み込み型には直接使用できますが，ユーザ定義の数値型には使用できません．他の言語では，演算子の **オーバーロード** （overload）機構が用意されており，同じ演算子に新しい型の意味を持たせることができます．C++やC#を含むこの手の言語では，多種多様な組み込み演算子オーバーロードすることができ，コンパイラは型チェッカを使ってどの型に対しての特定の実装であるかを選択します．

<!--
In addition to numeric literals and operators, many languages allow overloading of functions or methods.
In C++, Java, C# and Kotlin, multiple implementations of a method are allowed, with differing numbers and types of arguments.
The compiler uses the number of arguments and their types to determine which overload was intended.
-->

数値リテラルや演算子に加えて，多くの言語では関数やメソッドのオーバーロードが認められています．C++やJava，C#，Kotlinでは1つのメソッドについて引数の数や型が異なる複数の実装が認められています．コンパイラは引数の数と型を使用して，どのオーバーロードが意図されたかを判断します．

<!--
Function and operator overloading has a key limitation: polymorphic functions can't restrict their type arguments to types for which a given overload exists.
For example, an overloaded method might be defined for strings, byte arrays, and file pointers, but there's no way to write a second method that works for any of these.
Instead, this second method must itself be overloaded for each type that has an overload of the original method, resulting in many boilerplate definitions instead of a single polymorphic definition.
Another consequence of this restriction is that some operators (such as equality in Java) end up being defined for _every_ combination of arguments, even when it is not necessarily sensible to do so.
If programmers are not very careful, this can lead to programs that crash at runtime or silently compute an incorrect result.
-->

関数や演算子のオーバーロードには重要な制限があります：多相関数はその型引数を指定されたオーバーロードが存在する型に限定することができません．例えば，文字列，バイト文字列，ファイルポインタに対してオーバーロードされたメソッドが定義されている場合，これら3つのメソッドのどれに対しても機能するような単一のメソッドを書くことができません．その代わりに，この別のメソッドは元のメソッドのオーバーロードを持つ型ごとにいちいちオーバーロードされなければならず，結果として多くの同じような定義が生まれ，単一の多相な定義にすることができません．この制限はさらに，（Javaの等号のような）いくつかの演算子についてどう考えても要らないようなケースも含めて **すべての** 引数の組み合わせに対して定義されてしまうという結果をも引き起こします．そのためプログラマの注意が不十分だと，実行時にクラッシュしたり，黙って不正な計算をするプログラムが出来上がってしまう可能性があります．

<!--
Lean implements overloading using a mechanism called _type classes_, pioneered in Haskell, that allows overloading of operators, functions, and literals in a manner that works well with polymorphism.
A type class describes a collection of overloadable operations.
To overload these operations for a new type, an _instance_ is created that contains an implementation of each operation for the new type.
For example, a type class named `Add` describes types that allow addition, and an instance of `Add` for `Nat` provides an implementation of addition for `Nat`.
-->

LeanはHaskellで先駆的に開発された **型クラス** （type class）と呼ばれる機構を使用してオーバーロードを実装しています．これによって演算子，関数，リテラルを多相性とうまく連動させてオーバーロードを実現しています．型クラスはオーバーロード可能な演算の集まりを記述したものです．新しい型に対してこれらの演算をオーバーロードするには，新しい型に対する各演算の実装を含んだ **インスタンス** （instance）を作成します．例えば，`Add` という名前の型クラスは足し算ができる型を記述しており，`Nat` に対する `Add` のインスタンスは `Nat` に対する足し算の実装を提供します．

<!--
The terms _class_ and _instance_ can be confusing for those who are used to object-oriented languages, because they are not closely related to classes and instances in object-oriented languages.
However, they do share common roots: in everyday language, the term "class" refers to a group that shares some common attributes.
While classes in object-oriented programming certainly describe groups of objects with common attributes, the term additionally refers to a specific mechanism in a programming language for describing such a group.
Type classes are also a means of describing types that share common attributes (namely, implementations of certain operations), but they don't really have anything else in common with classes as found in object-oriented programming.
-->

**クラス** と **インスタンス** という用語はオブジェクト指向言語で言うところのクラスとインスタンスとは密接に関連していないため，オブジェクト指向言語に慣れている人にとっては混乱を招くかもしれません．ただ，両者は日常言語における「クラス」という用語のいくつかの共通の属性を持つグループという意味をルーツとしている点においては共通しています．オブジェクト指向プログラミングにおけるクラスでも共通の属性を持つオブジェクトの集まりを意味しますが，この用語はさらに，そのような集まりを記述するためのプログラミング言語の特定の機構を指します．型クラスもまた，共通の属性を持つ型（すなわち，その型にまつわる演算の実装）を記述する道具ですが，オブジェクト指向プログラミングで見られるクラスとは，それ以外の共通点はありません．

<!--
A Lean type class is much more analogous to a Java or C# _interface_.
Both type classes and interfaces describe a conceptually related set of operations that are implemented for a type or collection of types.
Similarly, an instance of a type class is akin to the code in a Java or C# class that is prescribed by the implemented interfaces, rather than an instance of a Java or C# class.
Unlike Java or C#'s interfaces, types can be given instances for type classes that the author of the type does not have access to.
In this way, they are very similar to Rust traits.
-->


Leanの型クラスは，JavaやC#の **インターフェース** （interface）によく似ています．型クラスもインターフェースも，型や型のあつまりに対して実装される，概念的には同じような演算の集合を記述します．同様に，型クラスのインスタンスは，JavaやC#のクラスのインスタンスではなく，インターフェースを継承したクラスによって記述されるコードに似ています．JavaやC#のインターフェースとは異なり，何かしらの型の作者がある型クラスを触れないケースでも，その型に型クラスのインスタンスを与えることができます．この点で，型クラスはRustのtraitとよく似ています．


