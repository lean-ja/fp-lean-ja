import Solutions.TypeClasses.Pos
/- # Type Classes and Polymorphism -/

/-! Write an instance of `OfNat` for the even number datatype from the previous section's exercises that uses recursive instance search. For the base instance, it is necessary to write `OfNat Even Nat.zero` instead of `OfNat Even 0`. -/

instance : OfNat Even Nat.zero where
  ofNat := Even.zero

#check (0 : Even)

def Nat.nthEven (n : Nat) : Even :=
  match n with
  | 0 => Even.zero
  | n + 1 => Even.succ (Nat.nthEven n)

instance (n : Nat) : OfNat Even n where
  ofNat :=
    if n % 2 == 0 then
      Nat.nthEven $ n / 2
    else
      Nat.nthEven 0

#eval (2 : Even)

#eval (3 : Even)

