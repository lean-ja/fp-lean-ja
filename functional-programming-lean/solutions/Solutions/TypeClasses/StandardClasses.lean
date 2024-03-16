variable {α β : Type}

structure NonEmptyList (α : Type) where
  head : α
  tail : List α
  deriving Repr

def appendNonEmptyList (xs : List α) (ys : NonEmptyList α) : NonEmptyList α :=
  match xs with
  | [] => ys
  | x :: xs => { head := x, tail := xs ++ ys.head :: ys.tail }

instance : HAppend (List α) (NonEmptyList α) (NonEmptyList α) where
  hAppend xs ys := appendNonEmptyList xs ys

#eval [1, 2, 3] ++ ({ head := 4, tail := [5, 6] }: NonEmptyList Nat)

inductive BinTree (α : Type) where
  | leaf : BinTree α
  | branch : BinTree α → α → BinTree α → BinTree α
  deriving Repr

def eqBinTree [BEq α] : BinTree α → BinTree α → Bool
  | BinTree.leaf, BinTree.leaf =>
    true
  | BinTree.branch l x r, BinTree.branch l2 x2 r2 =>
    x == x2 && eqBinTree l l2 && eqBinTree r r2
  | _, _ =>
    false

instance [BEq α] : BEq (BinTree α) where
  beq := eqBinTree

def hashBinTree [Hashable α] : BinTree α → UInt64
  | BinTree.leaf =>
    0
  | BinTree.branch left x right =>
    mixHash 1 (mixHash (hashBinTree left) (mixHash (hash x) (hashBinTree right)))

instance [Hashable α] : Hashable (BinTree α) where
  hash := hashBinTree

def mapBinTree (f: α → β) : BinTree α → BinTree β
  | BinTree.leaf => BinTree.leaf
  | BinTree.branch l x r => BinTree.branch (mapBinTree f l) (f x) (mapBinTree f r)

instance : Functor BinTree where
  map f b := mapBinTree f b

#eval  (· + 100) <$> (BinTree.branch (BinTree.branch BinTree.leaf 1 BinTree.leaf) 2 (BinTree.branch BinTree.leaf 3 BinTree.leaf))
