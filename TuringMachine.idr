module TuringMachine

%default total

data Bit = O | I
data Direction = R | L
data State = Cont Nat | A

data Command : Type where
  Cmd : (st1: Nat) -> (b1 : Bit) -> (b2 : Bit) -> (dir : Direction) -> (st2 : State) -> Command

Program : Type
Program = List Command

record Machine where
  constructor MkMachine
  state  : State
  left   : List Bit
  center : Bit
  right  : List Bit
