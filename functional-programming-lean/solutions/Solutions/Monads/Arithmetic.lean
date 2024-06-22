/- Check the monad contract for `State σ` and `Except ε`. -/
set_option autoImplicit false

section Textbook

  variable {α : Type} {σ : Type}

  def State (σ : Type) (α : Type) : Type :=
    σ → (σ × α)

  def ok (x : α) : State σ α :=
    fun s => (s, x)

  instance : Monad (State σ) where
    pure x := fun s => (s, x)
    bind first next :=
      fun s =>
        let (s', x) := first s
        next x s'

end Textbook

section
  variable (σ : Type)

  instance : LawfulMonad (State σ) where
    map_const := by intros; rfl
    id_map := by intros; rfl
    seqLeft_eq := by intros; rfl
    seqRight_eq := by intros; rfl
    pure_seq := by intros; rfl
    bind_pure_comp := by intros; rfl
    bind_assoc := by intros; rfl
    bind_map := by intros; rfl
    pure_bind := by intros; rfl

  -- 既に標準ライブラリに存在する
  #synth Monad (Except σ)

  instance : LawfulMonad (Except σ) where
    map_const := by intros; rfl
    id_map := by
      intro α x
      cases x <;> rfl
    seqLeft_eq := by
      intro α β x y
      cases x <;> rfl
    seqRight_eq := by
      intro α β x y
      cases x <;> cases y
      all_goals rfl
    pure_seq := by intros; rfl
    bind_pure_comp := by intros; rfl
    bind_assoc := by
      intro α β γ x f g
      cases x <;> rfl
    bind_map := by intros; rfl
    pure_bind := by intros; rfl
end
/- Adapt the reader monad example so that it can also indicate failure when the custom operator is not defined, rather than just returning zero. In other words, given these definitions:

`def ReaderOption (ρ : Type) (α : Type) : Type := ρ → Option α

def ReaderExcept (ε : Type) (ρ : Type) (α : Type) : Type := ρ → Except ε α`

do the following:

1. Write suitable `pure` and `bind` functions
2. Check that these functions satisfy the `Monad` contract
3. Write `Monad` instances for `ReaderOption` and `ReaderExcept`
4. Define suitable `applyPrim` operators and test them with `evaluateM` on some example expressions
-/
section

def ReaderOption (ρ : Type) (α : Type) : Type := ρ → Option α

def ReaderExcept (ε : Type) (ρ : Type) (α : Type) : Type := ρ → Except ε α

variable {ρ : Type} {ε : Type}

instance : Monad (ReaderOption ρ) where
  pure x := fun _ => some x
  bind first next :=
    fun r =>
      match first r with
      | none => none
      | some x => next x r

instance : Monad (ReaderExcept ε ρ) where
  pure x := fun _ => Except.ok x
  bind first next :=
    fun r =>
      match first r with
      | Except.error e => Except.error e
      | Except.ok x => next x r

instance : LawfulMonad (ReaderOption ρ) where
  map_const := by intros; rfl
  id_map := by
    intro α f
    funext r
    dsimp [Functor.map]
    cases f r <;> rfl
  seqLeft_eq := by
    intro α β x y
    funext r
    dsimp [Functor.map, SeqLeft.seqLeft, Seq.seq]
    cases x r <;> try simp
  seqRight_eq := by
    intro α β x y
    funext r
    dsimp [Functor.map, SeqRight.seqRight, Seq.seq]
    cases x r <;> try simp
    cases y r <;> rfl
  pure_seq := by intros; rfl
  bind_pure_comp := by intros; rfl
  bind_assoc := by
    intro α β γ x f g
    funext r
    dsimp [Bind.bind]
    cases x r <;> rfl
  bind_map := by intros; rfl
  pure_bind := by intros; rfl

instance : LawfulMonad (ReaderExcept ε ρ) where
  map_const := by intros; rfl
  id_map := by
    intro α f
    funext r
    dsimp [Functor.map]
    cases f r <;> rfl
  seqLeft_eq := by
    intro α β x y
    funext r
    dsimp [Functor.map, SeqLeft.seqLeft, Seq.seq]
    cases x r <;> try simp
  seqRight_eq := by
    intro α β x y
    funext r
    dsimp [Functor.map, SeqRight.seqRight, Seq.seq]
    cases x r <;> try simp
    cases y r <;> rfl
  pure_seq := by intros; rfl
  bind_pure_comp := by intros; rfl
  bind_assoc := by
    intro α β γ x f g
    funext r
    dsimp [Bind.bind]
    cases x r <;> rfl
  bind_map := by intros; rfl
  pure_bind := by intros; rfl

inductive Expr (op : Type) where
  | const : Int → Expr op
  | prim : op → Expr op → Expr op → Expr op

inductive Arith where
  | plus
  | minus
  | times
  | div

inductive Prim (special : Type) where
  | plus
  | minus
  | times
  | other : special → Prim special

def «3×2» : Expr (Prim String) := Expr.prim .times (.const 3) (.const 2)

def «5+4» : Expr (Prim String) := Expr.prim .plus (.const 5) (.const 4)

def «0» : Expr (Prim String) := Expr.const 0

variable {m : Type → Type}

def applyPrim [Monad m] {special : Type} (applySpecial : special → Int → Int → m Int) : Prim special → Int → Int → m Int
  | Prim.plus, x, y => pure (x + y)
  | Prim.minus, x, y => pure (x - y)
  | Prim.times, x, y => pure (x * y)
  | Prim.other op, x, y => applySpecial op x y

def evaluateM [Monad m] {special : Type} (applySpecial : special → Int → Int → m Int): Expr (Prim special) → m Int
  | Expr.const i => pure i
  | Expr.prim p e1 e2 =>
    evaluateM applySpecial e1 >>= fun v1 =>
    evaluateM applySpecial e2 >>= fun v2 =>
    applyPrim applySpecial p v1 v2

abbrev Env : Type := List (String × (Int → Int → Option Int))

def div (x y : Int) : Option Int := if y = 0 then none else some (x / y)

def exampleEnv : Env := [("div", div)]

def applyPrimReader (op : String) (x : Int) (y : Int) : ReaderOption Env Int := do
  let env ← pure
  match env.lookup op with
  | none => pure 0
  | some f =>
    match f x y with
    | none => fun _ => none
    | some z => pure z

#eval evaluateM applyPrimReader (Expr.prim (Prim.other "div") «5+4» «0») exampleEnv

end
