<!--
# Monad Transformers
-->

# モナド変換子

<!--
A monad is a way to encode some collection of side effects in a pure language.
Different monads provide different effects, such as state and error handling.
Many monads even provide useful effects that aren't available in most languages, such as nondeterministic searches, readers, and even continuations.
-->

モナドは純粋言語においてなんらかの副作用を実装するための手段です。状態やエラー処理など、異なるモナドは異なる作用を提供します。非決定論的検索やリーダ、さらには継続など、ほとんどの言語では利用できない便利な作用を提供するモナドも多く存在します。

<!--
A typical application has a core set of easily testable functions written without monads paired with an outer wrapper that uses a monad to encode the necessary application logic.
These monads are constructed from well-known components.
For example:
-->

典型的なアプリケーションはモナドを使わないテストの容易な関数を中心とし、それをモナドで必要なアプリケーションロジックを実装したラッパーで覆うことで成り立っています。これらのモナドは良く知られたコンポーネントから構成されます。例えば：

 <!--
 * Mutable state is encoded with a function parameter and a return value that have the same type
 * Error handling is encoded by having a return type that is similar to `Except`, with constructors for success and failure
 * Logging is encoded by pairing the return value with the log
 -->
 * 可変状態はパラメータと戻り値の型が同じ関数としてエンコードされます
 * エラー処理は `Except` に似た成功と失敗から構成される型を戻り値に持つものとしてエンコードされます
 * ロギングは戻り値とログのペアとしてエンコードされます
 
<!--
Writing each monad by hand is tedious, however, involving boilerplate definitions of the various type classes.
Each of these components can also be extracted to a definition that modifies some other monad to add an additional effect.
Such a definition is called a _monad transformer_.
A concrete monad can be build from a collection of monad transformers, which enables much more code re-use.
-->

しかし、それぞれのモナドを手作業で書くのはさまざまな型クラスの定型的な定義が必要になるため面倒です。これらの各コンポーネントは、ほかのモナドを修正して追加作用を加える定義に抽出することもできます。このような定義は **モナド変換子** （monad transformer）と呼ばれます。具体的なモナドはモナド変換子を組み合わせることで構築することができ。コードの再利用がより可能になります。
