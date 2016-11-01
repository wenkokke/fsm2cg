{-# LANGUAGE RecordWildCards #-}
module Main where

import Lib (FSA(..),toCG3)
import Prelude hiding (Word,words)
import Control.Arrow (first)
import Data.Char (isSpace)
import Data.List (nub)
import qualified Data.String as S (words)

newtype State = State Int
  deriving (Eq)

instance Show State where
  show (State s) = 's':show s

instance Read State where
  readsPrec d r = map (first State) (readsPrec d r)

newtype Word = Word String
  deriving (Eq)

instance Show Word where
  show (Word s) = s

main :: IO ()
main = do input <- getContents
          let fsa = pFSA input
          putStrLn (toCG3 fsa)

pFSA :: String -> FSA State Word
pFSA input = FSA { .. }
  where
    (l:ls) = lines input
    start  = pStart l
    trans  = map pTrans (init ls)
    final  = pFinal (last ls)
    states = nub (start : final ++ map fst3 trans ++ map trd3 trans)
    words  = nub (map snd3 trans)

    fst3 (x,_,_) = x
    snd3 (_,y,_) = y
    trd3 (_,_,z) = z

    pStart :: String -> State
    pStart = read
    pTrans :: String -> (State,Word,State)
    pTrans input = let [s,w,s'] = S.words input
                   in  (read s, Word (filter (not . isSpace) w), read s')
    pFinal :: String -> [State]
    pFinal = map read . S.words
