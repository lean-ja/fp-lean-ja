<!--
# Programming, Proving, and Performance
-->

# プログラミング・証明・パフォーマンス

<!--
This chapter is about programming.
Programs need to compute the correct result, but they also need to do so efficiently.
To write efficient functional programs, it's important to know both how to use data structures appropriately and how to think about the time and space needed to run a program.
-->

この章ではプログラミングについて述べます。プログラムは正しい結果を計算する必要がありますが、同時に効率的である必要もあります。効率的な関数型プログラムを書くためには、データ構造の適切な使い方と、プログラムを実行するために必要な時間と空間について考える方法の両方を知ることが重要です。

<!--
This chapter is also about proofs.
One of the most important data structures for efficient programming in Lean is the array, but safe use of arrays requires proving that array indices are in bounds.
Furthermore, most interesting algorithms on arrays do not follow the pattern of structural recursion—instead, they iterate over the array.
While these algorithms terminate, Lean will not necessarily be able to automatically check this.
Proofs can be used to demonstrate why a program terminates.
-->

またこの章では証明についても述べます。Leanの効率的なプログラミングにおいて最も重要なデータ構造の1つは配列ですが、配列を安全に使用するには配列の添字が境界内にあることを証明する必要があります。さらに、配列に関する興味深いアルゴリズムのほとんどは構造的再帰のパターンに従いません、その代わりに配列上の繰り返しになります。これらのアルゴリズムは必ず終了しますが、Leanはこれを自動的にチェックできるとは限りません。プログラムが終了する理由を示すために証明を利用することができます。

<!--
Rewriting programs to make them faster often results in code that is more difficult to understand.
Proofs can also show that two programs always compute the same answers, even if they do so with different algorithms or implementation techniques.
In this way, the slow, straightforward program can serve as a specification for the fast, complicated version.
-->

高速化のためにプログラムを書き直すと理解しにくいコードになることが多いものです。証明はまた、2つのプログラムが異なるアルゴリズムや実装技術を使っていても常に同じ答えを計算することを示すことができます。このように、遅くて簡単なプログラムを、早くて複雑なバージョンの仕様書としての役割を果たすようにすることができます。

<!--
Combining proofs and programming allows programs to be both safe and efficient.
Proofs allow elision of run-time bounds checks, they render many tests unnecessary, and they provide an extremely high level of confidence in a program without introducing any runtime performance overhead.
However, proving theorems about programs can be time consuming and expensive, so other tools are often more economical.
-->

証明とプログラミングを組み合わせることで、プログラムを安全かつ効率的にすることができます。証明は実行時の境界チェックの省略を可能にし、多くのテストを不要にします。また、実行時のパフォーマンスのオーバーヘッドを発生させることなく、プログラムに対する極めて高い信頼性を提供してくれます。しかし、プログラムに関する定理の証明には時間とコストがかかるため、他のツールの方が経済的な場合が多いものです。

<!--
Interactive theorem proving is a deep topic.
This chapter provides only a taste, oriented towards the proofs that come up in practice while programming in Lean.
Most interesting theorems are not closely related to programming.
Please refer to [Next Steps](next-steps.md) for a list of resources for learning more.
Just as when learning programming, however, there's no substitute for hands-on experience when learning to write proofs—it's time to get started!

-->

対話的な定理証明は奥の深いトピックです。この章ではLeanでプログラミングしているときに実際に出てくる証明を中心にしつつ、味見だけにとどまります。ほとんどの興味深い定理はプログラミングと密接な関係を持ちません。さらに学ぶための教材のリストについては[「次のステップ」](next-steps.md) を参照してください。しかし、プログラミングを学ぶ時と同じように、証明の書き方の学習にあたっては実体験に勝るものはありません！

