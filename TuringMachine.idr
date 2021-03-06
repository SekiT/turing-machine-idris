module TuringMachine

import Data.SortedMap
import Data.Fuel

%default total
%access public export

data Bit       = O | I
data Direction = R | L
data State     = A | Cont Nat

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

takeHeadOfTape : List Bit -> (Bit, List Bit)
takeHeadOfTape []        = (O, [])
takeHeadOfTape (b :: bs) = (b, bs)

private
step : Program -> Machine -> Maybe Machine
step _                    (MkMachine A _ _ _)                        = Nothing
step (MkProgram commands) (MkMachine (Cont state) left center right) = do
  MkCommand st1 b1 b2 dir st2 <- lookup (state, center) commands
  case dir of
    R => Just $ uncurry (MkMachine st2 (b2 :: left)) (takeHeadOfTape right)
    L => Just $ (uncurry . flip) (MkMachine st2) (takeHeadOfTape left) (b2 :: right)

export
run : Fuel -> Program -> Machine -> Machine
run Dry         _       machine = machine
run (More fuel) program machine = case step program machine of
  Nothing         => machine
  Just newMachine => run fuel program newMachine

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

private
showBitList : List Bit -> String
showBitList []        = ""
showBitList (b :: bs) = show b ++ showBitList bs

Show Machine where
  show (MkMachine state left center right) =
    let
      leftStr = showBitList (reverse left)
      indent  = concat $ replicate (3 + length leftStr) " "
    in
      "..." ++ leftStr ++ show center ++ showBitList right ++ "...\n"
      ++ indent ++ "↑\n"
      ++ indent ++ show state
