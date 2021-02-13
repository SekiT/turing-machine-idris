module TuringMachine.Language

import Data.SortedMap
import Text.Token
import Text.Lexer
import Text.Parser
import TuringMachine

%default total

data TMTokenKind
  = TMBit
  | TMDirection
  | TMState
  | TMBra
  | TMKet
  | TMComma
  | TMComment
  | TMIgnore

Eq TMTokenKind where
  TMBit       == TMBit       = True
  TMDirection == TMDirection = True
  TMState     == TMState     = True
  TMBra       == TMBra       = True
  TMKet       == TMKet       = True
  TMComma     == TMComma     = True
  TMComment   == TMComment   = True
  TMIgnore    == TMIgnore    = True
  _           == _           = False

TokenKind TMTokenKind where
  TokType TMBit       = Bit
  TokType TMDirection = Direction
  TokType TMState     = State
  TokType _           = ()

  tokValue TMBit       x = if x == "O" then O else I
  tokValue TMDirection x = if x == "R" then R else L
  tokValue TMState     x = if x == "A" then A else Cont (cast x)
  tokValue TMBra       _ = ()
  tokValue TMKet       _ = ()
  tokValue TMComma     _ = ()
  tokValue TMComment   _ = ()
  tokValue TMIgnore    _ = ()

TMToken : Type
TMToken = Token TMTokenKind

tmTokenMap : TokenMap TMToken
tmTokenMap = toTokenMap $
  [ (spaces, TMIgnore)
  , (is ',', TMComma)
  , (is '<', TMBra)
  , (is '>', TMKet)
  , (oneOf "RL", TMDirection)
  , (exact "A" <|> digits, TMState)
  , (lineComment (is '#'), TMComment)
  ]

lexTM : String -> Maybe (List TMToken)
lexTM str = case lex tmTokenMap str of
  (tokens, _, _, "") => Just $ map tok tokens
  _                  => Nothing

command : Grammar TMToken True Command
command = do
  match TMBra
  st1 <- match TMState
  the (Grammar _ True _) $ case st1 of
    A         => fail "before state should not be A"
    Cont st1n => do
      match TMComma
      b1 <- match TMBit
      match TMComma
      b2 <- match TMBit
      match TMComma
      dir <- match TMDirection
      match TMComma
      st2 <- match TMState
      match TMKet
      pure $ MkCommand st1n b1 b2 dir st2

commandListToProgram : List Command -> Program
commandListToProgram commands =
  MkProgram $ fromList $ map commandToPair commands where
    commandToPair : Command -> ((Nat, Bit), Command)
    commandToPair cmd@(MkCommand st1 b1 _ _ _) = ((st1, b1), cmd)

tm : Grammar TMToken True Program
tm = map (commandListToProgram) $ some command

ignored : TMToken -> Bool
ignored (Tok TMIgnore  _) = True
ignored (Tok TMComment _) = True
ignored _                 = False

parseTM : List TMToken -> Maybe Program
parseTM toks = case parse tm $ filter (not . ignored) toks of
  Right (program, []) => Just program
  _                   => Nothing

export
parseProgram : String -> Maybe Program
parseProgram str = lexTM str >>= parseTM
