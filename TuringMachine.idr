module TuringMachine

import Data.SortedMap

%default total

data Bit = O | I
data Direction = R | L
data State = Cont Nat | A

Eq Bit where
  O == O = True
  I == I = True
  _ == _ = False

Ord Bit where
  compare O O = EQ
  compare O I = LT
  compare I O = GT
  compare I I = EQ

data Command : Type where
  MkCommand : (st1: Nat) -> (b1 : Bit) -> (b2 : Bit) -> (dir : Direction) -> (st2 : State) -> Command

data Program : Type where
  MkProgram : SortedMap (Nat, Bit) Command -> Program

record Machine where
  constructor MkMachine
  state  : State
  left   : List Bit
  center : Bit
  right  : List Bit

Show Bit where
  show O = "0"
  show I = "1"

Show Direction where
  show R = "R"
  show L = "L"

Show State where
  show (Cont n) = show n
  show A        = "A"

Show Command where
  show (MkCommand st1 b1 b2 dir st2) =
    "<" ++ show st1 ++ ", " ++ show b1 ++ ", " ++ show b2 ++ ", " ++ show dir ++ ", " ++ show st2 ++ ">"

Show Program where
  show (MkProgram commands) = concatMap show (values commands)
