/-
### Mapping on a Tree

Define a function `BinTree.mapM`. By analogy to `mapM` for lists, this function should apply a monadic function to each data entry in a tree, as a preorder traversal. The type signature should be:

`def BinTree.mapM [Monad m] (f : α → m β) : BinTree α → m (BinTree β)`
-/
namespace Class

inductive BinTree (α : Type) where
  | leaf : BinTree α
  | branch : BinTree α → α → BinTree α → BinTree α
deriving Repr

def BinTree.mapM [Monad m] (f : α → m β) : BinTree α → m (BinTree β)
  | BinTree.leaf => pure BinTree.leaf
  | BinTree.branch l x r => do
    let l' ← BinTree.mapM f l
    let x' ← f x
    let r' ← BinTree.mapM f r
    pure (BinTree.branch l' x' r')

def sample := BinTree.branch (BinTree.branch BinTree.leaf 0 BinTree.leaf) 2 (BinTree.branch BinTree.leaf 3 BinTree.leaf)

def test (n : Nat) : Option Nat :=
  if n == 0 then none
  else some n

example : BinTree.mapM test sample = none := rfl

/-
### The Option Monad Contract

First, write a convincing argument that the `Monad` instance for `Option` satisfies the monad contract. Then, consider the following instance:

```
instance : Monad Option where
  pure x := some x
  bind opt next := none
```

Both methods have the correct type. Why does this instance violate the monad contract?
-/

instance instLawfulMonadOption : LawfulMonad Option where
  map_const := by
    intro α β
    rfl
  id_map := by
    intro α x
    cases x <;> rfl
  seqLeft_eq := by
    intro α β x y
    cases x <;> try rfl
    cases y <;> rfl
  seqRight_eq := by
    intro α β x y
    cases x <;> try rfl
    cases y <;> rfl
  pure_seq := by
    intro α β g x
    rfl
  pure_bind := by
    intro α β x f
    rfl
  bind_pure_comp := by
    intro α x f y
    cases y <;> rfl
  bind_assoc := by
    intro α β γ x f g
    cases x <;> rfl
  bind_map := by
    intro α β x f
    cases x <;> rfl

instance (priority := high) : Monad Option where
  pure x := some x
  bind opt next := none

instance : LawfulMonad Option where
  map_const := by
    intro α β
    rfl
  id_map := by
    intro α x
    cases x <;> rfl
  seqLeft_eq := by
    intro α β x y
    cases x <;> try rfl
    cases y <;> rfl
  seqRight_eq := by
    intro α β x y
    cases x <;> try rfl
    cases y <;> rfl
  pure_seq := by
    intro α β g x
    rfl
  pure_bind := by
    intro α β x f
    dsimp [Bind.bind]
    sorry
  bind_pure_comp := by sorry
  bind_assoc := by
    intro α β γ x f g
    cases x <;> rfl
  bind_map := by sorry

end Class
