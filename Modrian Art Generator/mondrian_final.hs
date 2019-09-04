--
-- Starting code for CPSC 449 Assignment 1
--
-- Generate and output a Mondrian-style image as an SVG tag within an HTML 
-- document.
--
import System.IO
import Control.Monad (replicateM)
import System.Random (randomRIO, StdGen, randomR, mkStdGen)

--
-- The width and height of the image being generated.
--
width :: Int
width = 1025

height :: Int
height = 769

--
-- Generate and return a list of 20000 random floating point numbers between 
-- 0 and 1.  (Increase the 20000 if you ever run out of random values).
-- 
randomList :: Int -> [Float]
randomList seed = take 20000 (rl_helper (mkStdGen seed))

rl_helper :: StdGen -> [Float]
rl_helper g = fst vg : rl_helper (snd vg)
  where vg = randomR (0.00, 1.00 :: Float) g

randomList2 :: Int -> [Float]
randomList2 seed = take 20000 (r2_helper (mkStdGen seed)) 
  
r2_helper :: StdGen -> [Float]
r2_helper g = fst vg : r2_helper (snd vg)
  where vg = randomR (0.33, 0.67 :: Float) g
--
-- Compute an integer between low and high from a (presumably random) floating
-- point number between 0 and 1.
--
randomInt :: Int -> Int -> Float -> Int
randomInt low high x = round ((fromIntegral (high - low) * x) + fromIntegral low)

--
-- Generate the tag for a rectangle with random color.  Replace the 
-- implementation of this function so that it generates all of the tags
-- needed for a piece of random Mondrian art.
-- 
-- Parameters:
--   x, y: The upper left corner of the region
--   w, h: The width and height of the region
--   r:s:t:rs: A list of random floating point values between 0 and 1
--
-- Returns:
--   [Float]: The remaining, unused random values
--   String: The SVG tags that draw the image
--

square :: Int -> Int -> Int -> Int -> Float -> String
square x y w h r =
  "<rect x=" ++ (show x) ++ 
  " y=" ++ (show y) ++ 
  " width=" ++ (show w) ++ 
  " height=" ++ (show h) ++ 
  " fill=" ++ (fill r)
                 ++ " stroke=\"black\" />"

--  fillsquare fill -- random floating point goes here
fill :: Float -> String
fill r
  | r < 0.0833 = " red"
  | r < 0.1667 = " skyblue"
  | r < 0.25 = " yellow"
  | otherwise = " white"
 
{-# LANGUAGE NoMonomorphismRestriction #-}
--  mondrian: Creates a mondrian configuration
--  Parameters:
--    x, y: The top left corner of the current region
--    w, h: The width and height of the region
--  Return:
--    A string containing tags that can be rendered within an HTML doc
mondrian :: Int -> Int -> Int -> Int -> [Float] -> (String, [Float])
mondrian x y w h (a:b:c:d:e:rest)
  | fromIntegral w >= (fromIntegral width * 0.5) && fromIntegral h >= (fromIntegral height * 0.5) = -- divide the region into 4 squares                   
                       (ul_tags ++
                       ur_tags ++
                       ll_tags ++
                       lr_tags,
                       lr_rest)
  | fromIntegral w >= (fromIntegral width * 0.5) =
                       (le_tags ++
                       ri_tags,
                       ri_rest)
  | fromIntegral h >= (fromIntegral height * 0.5) =
                       (up_tags ++
                       lo_tags,
                       lo_rest)
  | randomInt (round (fromIntegral w * 1.5)) 120 a < fromIntegral w && randomInt (round (fromIntegral h * 1.5)) 120 b < fromIntegral h =
                       (ul_tags ++
                       ur_tags ++
                       ll_tags ++
                       lr_tags,
                       lr_rest)
  | randomInt (round (fromIntegral w * 1.5)) 120 a < fromIntegral w =
                       (le_tags ++
                       ri_tags,
                       ri_rest)
  | randomInt (round (fromIntegral h * 1.5)) 120 b < fromIntegral h =
                       (up_tags ++
                       lo_tags,
                       lo_rest)
   
  | otherwise        = (square x y w h e, rest) -- add fill property
  where 
    new_w = round((fromIntegral w * (0.3 + (0.3 * c)))) -- * int eeds to be between 33% and 66% of: x (x + w)
    new_h = round((fromIntegral h * (0.3 + (0.3 * d)))) -- * int eeds to be between 33% and 66% of: y (y - h)	
    (ul_tags, ul_rest) = (mondrian x y new_w new_h rest)
    (ur_tags, ur_rest) = (mondrian (x + new_w) y (w - new_w) new_h ul_rest)
    (ll_tags, ll_rest) = (mondrian x (y + new_h) new_w (h - new_h) ur_rest)
    (lr_tags, lr_rest) = (mondrian (x + new_w) (y + new_h) (w - new_w) (h - new_h) ll_rest)
    (le_tags, le_rest) = (mondrian x y new_w h rest)
    (ri_tags, ri_rest) = (mondrian (x + new_w) y (w - new_w) h le_rest)
    (up_tags, up_rest) = (mondrian x y w new_h rest)
    (lo_tags, lo_rest) = (mondrian x (y + new_h) w (h - new_h) up_rest)

--
-- The main program which generates and outputs mondrian.html.
--
main :: IO ()
main = do
  --  Right now, the program will generate a different sequence of random
  --  numbers each time it is run.  If you want the same sequence each time
  --  use "let seed = 0" instead of "seed <- randomRIO (0, 100000 :: Int)"

  --let seed = 0
  seed <- randomRIO (0, 100000 :: Int)
  let randomValues = randomList seed
  let randomSplit = randomList2 7

  let prefix = "<html><head></head><body>\n" ++
               "<svg width=\"" ++ (show width) ++ 
               "\" height=\"" ++ (show height) ++ "\">"
      image = fst (mondrian 0 0 width height randomValues)
      suffix = "</svg>\n</html>"

  writeFile "mondrian.html" (prefix ++ image ++ suffix)
