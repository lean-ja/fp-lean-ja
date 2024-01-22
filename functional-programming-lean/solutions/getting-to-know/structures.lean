/- # 1.4 Structures 演習問題 -/

/-! ## 1
Define a structure named `RectangularPrism` that contains the height, width, and depth of a rectangular prism, each as a `Float`.-/

structure RectangularPrism where
  height : Float
  width : Float
  depth : Float

/-! ## 2
Define a function named `volume : RectangularPrism → Float` that computes the volume of a rectangular prism. -/

def volume (r : RectangularPrism) : Float :=
  r.height * r.width * r.depth

/-! ## 3
Define a structure named `Segment` that represents a line segment by its endpoints, and define a function `length : Segment → Float` that computes the length of a line segment. `Segment` should have at most two fields. -/

/-- 本文からコピー -/
structure Point where
  x : Float
  y : Float

/-- 本文からコピー -/
def distance (p1 : Point) (p2 : Point) : Float :=
  Float.sqrt (((p2.x - p1.x) ^ 2.0) + ((p2.y - p1.y) ^ 2.0))

structure Segment where
  s : Point
  t : Point

def length (seg : Segment) : Float := distance seg.s seg.t

/-! ## 4
Which names are introduced by the declaration of `RectangularPrism`? -/

#check RectangularPrism.mk

#check RectangularPrism.height

#check RectangularPrism.width

#check RectangularPrism.depth

/-! ## 5
Which names are introduced by the following declarations of `Hamster` and `Book`? What are their types?-/

/-- 本文からコピー -/
structure Hamster where
  name : String
  fluffy : Bool

/-- 本文からコピー -/
structure Book where
  makeBook ::
  title : String
  author : String
  price : Float

#check (Hamster.mk : String → Bool → Hamster)

#check (Hamster.name : Hamster → String)

#check (Hamster.fluffy : Hamster → Bool)

#check (Book.makeBook : String → String → Float → Book)

#check (Book.title : Book → String)

#check (Book.author : Book → String)

#check (Book.price : Book → Float)
