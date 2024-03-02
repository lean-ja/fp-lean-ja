/-! Prove the following theorems using rfl: `2 + 3 = 5`, `15 - 8 = 7`, `"Hello, ".append "world" = "Hello, world"`. What happens if rfl is used to prove 5 < 18? Why? -/

example : 2 + 3 = 5 := rfl

example : 15 - 8 = 7 := rfl

example : "Hello, ".append "world" = "Hello, world" := rfl

#check_failure (rfl : 5 < 18)

/-! Prove the following theorems using by simp: `2 + 3 = 5`, `15 - 8 = 7`, `"Hello, ".append "world" = "Hello, world"`, `5 < 18`.-/

example : 2 + 3 = 5 := by simp

example : 15 - 8 = 7 := by simp

-- simp では示すことができなかった
example : "Hello, ".append "world" = "Hello, world" := by
  try simp
  rfl

example : 5 < 18 := by simp

/-! Write a function that looks up the fifth entry in a list. Pass the evidence that this lookup is safe as an argument to the function. -/

def lookup_fifth_entry {α : Type} (ls : List α) (h : ls.length >= 5) : α :=
  ls[4]

example : lookup_fifth_entry [1, 2, 3, 4, 5, 6, 7] (by simp) = 5 := rfl
