import Solutions.GettingToKnow.Polymorphism

instance [HMul α α α] : HMul (PPoint α) α (PPoint α) where
  hMul p s := {x := p.x * s, y := p.y * s}

#eval {x := 2.5, y := 3.7 : PPoint Float} * 2.0
