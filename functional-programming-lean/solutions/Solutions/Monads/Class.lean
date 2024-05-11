/-
### Mapping on a Tree

Define a function `BinTree.mapM`. By analogy to `mapM` for lists, this function should apply a monadic function to each data entry in a tree, as a preorder traversal. The type signature should be:

`def BinTree.mapM [Monad m] (f : α → m β) : BinTree α → m (BinTree β)`
-/

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
