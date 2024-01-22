/- # 1.2 演習問題 -/

/-! ## 1
関数 `joinStringsWith` を `String -> String -> String -> String` 型の関数であって，その第一引数を第二引数と第三引数の間に配置して新しい文字列を作成するようなものとして定義してください．`joinStringsWith ", " "one" "and another"` は `"one, and another"` に等しくなるはずです.-/

def joinStringsWith (s1 : String) (s2 : String) (s3 : String) : String :=
  s2 ++ s1 ++ s3

example : joinStringsWith ", " "one" "and another" = "one, and another" := rfl

/- ### 補足: `String.append` と `++` は同じか？ -/

example (s t : String) : s ++ t = String.append s t := rfl

#synth Append String

#check String.instAppendString

/-! ## 2
`joinStringsWith ": "` の型は何でしょうか？ Lean で答えを確認してください．-/

#check (joinStringsWith ": " : String → String → String)

/-! ## 3
与えられた高さ，幅，奥行きを持つ直方体の体積を計算する関数 `volume` を `Nat → Nat → Nat → Nat` 型の関数として定義してください．
-/

def volume (h : Nat) (w : Nat) (d : Nat) : Nat := h * w * d

example : volume 3 4 5 = 60 := rfl

#check (volume : Nat → Nat → Nat → Nat)
