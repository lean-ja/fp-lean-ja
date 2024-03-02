import Solutions.TypeClasses.Pos
/- # Type Classes and Polymorphism -/

/-! ## Even Number Literals
Write an instance of `OfNat` for the even number datatype from the previous section's exercises that uses recursive instance search. For the base instance, it is necessary to write `OfNat Even Nat.zero` instead of `OfNat Even 0`. -/

instance : OfNat Even Nat.zero where
  ofNat := Even.zero

#check (0 : Even)

instance [OfNat Even n] : OfNat Even (n + 2) where
  ofNat := Even.succ (OfNat.ofNat n)

#eval (2 : Even)

#check_failure (3 : Even)

/-! ## Recursive Instance Search Depth
There is a limit to how many times the Lean compiler will attempt a recursive instance search. This places a limit on the size of even number literals defined in the previous exercise. Experimentally determine what the limit is.
-/

#eval (254 : Even)

#check_failure (256 : Even)
