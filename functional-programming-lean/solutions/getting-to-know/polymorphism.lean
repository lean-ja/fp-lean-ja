/- # 1.6 演習問題 -/

/-! ## 1
Write a function to find the last entry in a list. It should return an `Option`.
-/

variable {α : Type}

namespace Test

def tail (l : List α) : Option α :=
  match l with
  | [] => none
  | x :: xs =>
    match xs with
    | [] => some x
    | _ => tail xs

end Test

def tail (l : List α) : Option α :=
  match l with
  | [] => none
  | [x] => some x
  | _ :: xs => tail xs

example : tail [1, 1, 2, 3, 5] = some 5 := rfl

example : tail ([] : List Nat) = none := rfl

/-! ## 2
Write a function that finds the first entry in a list that satisfies a given predicate. Start the definition with `def List.findFirst? {α : Type} (xs : List α) (predicate : α → Bool) : Option α :=`
-/

def List.findFirst? {α : Type} (xs : List α) (predicate : α → Bool) : Option α :=
  match xs with
  | [] => none
  | x :: xs =>
    if predicate x then
      some x
    else
      List.findFirst? xs predicate

example : List.findFirst? [1, 1, 2, 3, 4] (fun x => x % 2 == 0) = some 2 := rfl

/-! ## 3
Write a function Prod.swap that swaps the two fields in a pair. Start the definition with `def Prod.swap {α β : Type} (pair : α × β) : β × α :=`
-/

def Prod.swap {α β : Type} (pair : α × β) : β × α := (pair.snd, pair.fst)

example : Prod.swap (1, 2) = (2, 1) := rfl

/-! ## 4
Rewrite the `PetName` example to use a custom datatype and compare it to the version that uses `Sum`.
-/

namespace Example

def PetName : Type := String ⊕ String

def animals : List PetName :=
  [Sum.inl "Spot", Sum.inr "Tiger", Sum.inl "Fifi", Sum.inl "Rex", Sum.inr "Floof"]

def howManyDogs (pets : List PetName) : Nat :=
  match pets with
  | [] => 0
  | Sum.inl _ :: morePets => howManyDogs morePets + 1
  | Sum.inr _ :: morePets => howManyDogs morePets

end Example

section

inductive PetName where
| dog : String → PetName
| cat : String → PetName

open PetName

def animals : List PetName :=
  [dog "Spot", cat "Tiger", dog "Fifi", dog "Rex", cat "Floof"]

def howManyDogs (pets : List PetName) : Nat :=
  match pets with
  | [] => 0
  | dog _ :: morePets => howManyDogs morePets + 1
  | cat _ :: morePets => howManyDogs morePets

example : howManyDogs animals = 3 := rfl

end

/-! ## 5
Write a function `zip` that combines two lists into a list of pairs. The resulting list should be as long as the shortest input list. Start the definition with `def zip {α β : Type} (xs : List α) (ys : List β) : List (α × β) :=.` -/

def zip {α β : Type} (xs : List α) (ys : List β) : List (α × β) :=
  match xs, ys with
  | [], _ => []
  | _, [] => []
  | x :: xs, y :: ys => (x, y) :: zip xs ys

example : zip [1, 2, 3] ["a", "b", "c"] = [(1, "a"), (2, "b"), (3, "c")] := rfl

example : zip [1, 2, 3] ["a", "b"] = [(1, "a"), (2, "b")] := rfl

/-! ## 6
Write a polymorphic function `take` that returns the first n entries in a list, where n is a `Nat`. If the list contains fewer than n entries, then the resulting list should be the input list. `#eval take 3 ["bolete", "oyster"]` should yield `["bolete", "oyster"]`, and `#eval take 1 ["bolete", "oyster"]` should yield `["bolete"]`.-/

def take {α : Type} (n : Nat) (xs : List α) : List α :=
  match n, xs with
  -- どんなリストでも最初のゼロ個を取ったら空リスト
  | 0, _ => []
  -- リストから何も取れなくなったら空リストを返す
  | _, [] => []
  -- リストから最初の要素を取り出して残りのリストを再帰的に処理する
  | n + 1, x :: xs => x :: take n xs

example : take 3 ["bolete", "oyster"] = ["bolete", "oyster"] := rfl

example : take 1 ["bolete", "oyster"] = ["bolete"] := rfl

/-! ## 7
Using the analogy between types and arithmetic, write a function that distributes products over sums. In other words, it should have type `α × (β ⊕ γ) → (α × β) ⊕ (α × γ)`. -/

def distribute {α β γ : Type} : α × (β ⊕ γ) → (α × β) ⊕ (α × γ)
  | (a, Sum.inl b) => Sum.inl (a, b)
  | (a, Sum.inr c) => Sum.inr (a, c)

/-! ## 8
Using the analogy between types and arithmetic, write a function that turns multiplication by two into a sum. In other words, it should have type `Bool × α → α ⊕ α`. -/

def mulByTwo {α : Type} : Bool × α → α ⊕ α
  | (true, a) => Sum.inl a
  | (false, a) => Sum.inr a
