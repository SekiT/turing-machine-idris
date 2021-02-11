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
  Cmd : (st1: Nat) -> (b1 : Bit) -> (b2 : Bit) -> (dir : Direction) -> (st2 : State) -> Command

Program : Type
Program = SortedMap (Nat, Bit) Command

record Machine where
  constructor MkMachine
  state  : State
  left   : List Bit
  center : Bit
  right  : List Bit
