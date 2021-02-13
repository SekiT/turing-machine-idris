module TuringMachine.Language

import Data.SortedMap
import Text.Token
import Text.Lexer
import Text.Parser
import TuringMachine

%default total

data TMTokenKind
  = TMBra
  | TMKet
  | TMComma
  | TMNat
  | TMDirection
  | TMA
  | TMComment
  | TMIgnore

Eq TMTokenKind where
  TMBra       == TMBra       = True
  TMKet       == TMKet       = True
  TMComma     == TMComma     = True
  TMNat       == TMNat       = True
  TMDirection == TMDirection = True
  TMA         == TMA         = True
  TMComment   == TMComment   = True
  TMIgnore    == TMIgnore    = True
  _           == _           = False

TokenKind TMTokenKind where
  TokType TMBra       = ()
  TokType TMKet       = ()
  TokType TMComma     = ()
  TokType TMNat       = Nat
  TokType TMDirection = Direction
  TokType TMA         = State
  TokType TMComment   = ()
  TokType TMIgnore    = ()

  tokValue TMBra       _ = ()
  tokValue TMKet       _ = ()
  tokValue TMComma     _ = ()
  tokValue TMNat       x = cast x
  tokValue TMDirection x = if x == "R" then R else L
  tokValue TMA         _ = A
  tokValue TMComment   _ = ()
  tokValue TMIgnore    _ = ()

TMToken : Type
TMToken = Token TMTokenKind

Show TMToken where
  show (Tok TMBra       _) = "<"
  show (Tok TMKet       _) = ">"
  show (Tok TMComma     _) = ","
  show (Tok TMNat       n) = "Nat[" ++ n ++ "]"
  show (Tok TMDirection d) = "D[" ++ d ++ "]"
  show (Tok TMA         _) = "A"
  show (Tok TMComment   _) = "[comment]"
  show (Tok TMIgnore    _) = ""

tmTokenMap : TokenMap TMToken
tmTokenMap = toTokenMap $
  [ (is '<', TMBra)
  , (is '>', TMKet)
  , (is ',', TMComma)
  , (digits, TMNat)
  , (oneOf "RL", TMDirection)
  , (exact "A", TMA)
  , (lineComment (is '#'), TMComment)
  , (spaces, TMIgnore)
  ]

lexTM : String -> Maybe (List TMToken)
lexTM str = case lex tmTokenMap str of
  (tokens, _, _, "") => Just $ map tok tokens
  _                  => Nothing

bitFromNat : Nat -> Grammar TMToken False Bit
bitFromNat Z     = pure O
bitFromNat (S Z) = pure I
bitFromNat _     = fail "Bit should be 0 or 1"

command : Grammar TMToken True Command
command = do
  match TMBra
  st1 <- match TMNat
  match TMComma
  b1 <- match TMNat >>= bitFromNat
  match TMComma
  b2 <- match TMNat >>= bitFromNat
  match TMComma
  dir <- match TMDirection
  match TMComma
  st2 <- (Cont <$> match TMNat) <|> match TMA
  match TMKet
  pure $ MkCommand st1 b1 b2 dir st2

commandListToProgram : List Command -> Program
commandListToProgram commands =
  MkProgram $ fromList $ map commandToPair commands where
    commandToPair : Command -> ((Nat, Bit), Command)
    commandToPair cmd@(MkCommand st1 b1 _ _ _) = ((st1, b1), cmd)

tm : Grammar TMToken True Program
tm = map commandListToProgram (some command)

ignored : TMToken -> Bool
ignored (Tok TMIgnore  _) = True
ignored (Tok TMComment _) = True
ignored _                 = False

parseTM : List TMToken -> Maybe Program
parseTM toks = case parse tm $ filter (not . ignored) toks of
  Right (program, []) => Just program
  _                   => Nothing

export
compile : String -> Maybe Program
compile str = lexTM str >>= parseTM
