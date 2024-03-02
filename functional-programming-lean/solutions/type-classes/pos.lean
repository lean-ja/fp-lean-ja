/-! ## Another Representation -/

-- sorry

/-! ## Even Numbers -/

/-- even numbers -/
inductive Even : Type where
  | zero : Even
  | succ : Even → Even

namespace Even

def two : Even := succ (zero)

def four : Even := succ $ succ $ zero

def Even.add (m n : Even) : Even :=
  match n with
  | Even.zero => m
  | Even.succ n' => Even.succ (Even.add m n')

instance : Add Even where
  add := Even.add

example : two + zero = two := rfl

def Even.mul (m n : Even) : Even :=
  match n with
  | Even.zero => zero
  | Even.succ n' => (Even.mul m n') + m + m

instance : Mul Even where
  mul := Even.mul

example : two * two = four := rfl

def Even.toNat : Even → Nat
  | zero => 0
  | succ n => 2 + (Even.toNat n)

instance : ToString Even where
  toString := toString ∘ Even.toNat

#eval four

end Even
