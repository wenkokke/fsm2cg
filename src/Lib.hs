{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Lib (FSA(..),toCG3) where

import Prelude hiding (words)
import Data.Char (toLower,toUpper)
import Data.List (intersperse)
import Text.Printf (printf)

data FSA state word = FSA
  { states :: [state]
  , words  :: [word]
  , start  :: state
  , trans  :: [(state,word,state)]
  , final  :: [state]
  }

toCG3 :: (Eq state, Show state, Show word) => FSA state word -> String
toCG3 (fsa :: FSA state word) = unlines . concat $
  [ ["DELIMITERS = \"<$.>\" \"<$?>\" \"<$!>\" \"<$:>\" \"<$\\;>\" ;"]
  , [[]]
  , ["SET <<< = (<<<);"]
  , ["SET >>> = (>>>);"]
  , map state' (states fsa)
  , map word'  (words  fsa)
  , [final' (final fsa)]
  , [[]]
  , ["BEFORE-SECTIONS"]
  , map start' (filter (\(_,_,s') -> s' == start fsa) (trans fsa))
  , map trans' (trans fsa)
  , [[]]
  , ["AFTER-SECTIONS"]
  , ["REMCOHORT (*) IF (1* <<< LINK NOT 0 FINAL);"]
  , ["REMCOHORT <<< (NOT 0 FINAL);"]
  ]
  where
    state' s        = printf "SET %s = (%s);" (uc s) (lc s)
    word'  w        = printf "SET %s = (\"%s\");" (uc w) (lc w)
    final' f        = printf "SET FINAL = (%s);" (joinWith " OR " $ map lc f)
    start' (_,w,s') = printf "ADD %s %s IF (-1 >>>);" (uc s') (uc w)
    trans' (s,w,s') = printf "ADD %s %s IF (-1 %s);" (uc s') (uc w) (uc s)
    joinWith x xs   = concat (intersperse x xs)

    lc,uc :: (Show a) => a -> String
    lc = map toLower . show
    uc = map toUpper . show
