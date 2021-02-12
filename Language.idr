module TuringMachine.Language

import Text.Token
import Text.Lexer
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
  , (exact "A" <|> digits, TMState)
  , (lineComment (is '#'), TMComment)
  ]

lexTM : String -> Maybe (List TMToken)
lexTM str = case lex tmTokenMap str of
  (tokens, _, _, "") => Just $ map tok tokens
  _                  => Nothing
