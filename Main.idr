module Main

import Data.Fuel
import TuringMachine
import TuringMachine.Language

%default total

parseBit : Char -> Maybe Bit
parseBit '0' = Just O
parseBit '1' = Just I
parseBit _   = Nothing

parseTape : String -> Maybe (List Bit)
parseTape tapeStr = sequence (map parseBit (unpack tapeStr))

parseSteps : String -> Maybe Nat
parseSteps str = case all isDigit (unpack str) of
  True  => Just (cast str)
  False => Nothing

parseArgs : List String -> Maybe (String, List Bit, Maybe Nat)
parseArgs (_ :: filepath :: tapeStr :: stepsStr :: []) = do
  tape  <- parseTape tapeStr
  steps <- parseSteps stepsStr
  pure (filepath, tape, Just steps)
parseArgs (_ :: filepath :: tapeStr :: []) =
  case parseTape tapeStr of
    Just tape => Just (filepath, tape, Nothing)
    Nothing   => Nothing
parseArgs _ = Nothing

partial
stepsToFuel : Maybe Nat -> Fuel
stepsToFuel Nothing  = forever
stepsToFuel (Just n) = limit n

partial
main : IO ()
main = do
  Just (filepath, tape, steps) <- parseArgs <$> getArgs
    | Nothing => putStrLn "Usage: tm [program_file_path] [tape] [max steps]"
  Right programStr <- readFile filepath
    | Left error => printLn error
  Just program <- pure $ compile programStr
    | Nothing => putStrLn "Invalid program"
  printLn $ run (stepsToFuel steps) program $ (MkMachine (Cont 0) []) `uncurry` (takeHeadOfTape tape)
