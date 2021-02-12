module TuringMachine.Language

import Text.Token
import TuringMachine

data TMTokenKind
  = TMCont
  | TMBit
  | TMDirection
  | TMState
  | TMBra
  | TMKet
  | TMComma
  | TMIgnore

TokenKind TMTokenKind where
  TokType TMCont      = Nat
  TokType TMBit       = Bit
  TokType TMDirection = Direction
  TokType TMState     = State
  TokType _           = ()

  tokValue TMCont      x = cast x
  tokValue TMBit       x = if x == "O" then O else I
  tokValue TMDirection x = if x == "R" then R else L
  tokValue TMState     x = if x == "A" then A else Cont (cast x)
  tokValue TMBra       _ = ()
  tokValue TMKet       _ = ()
  tokValue TMComma     _ = ()
  tokValue TMIgnore    _ = ()
