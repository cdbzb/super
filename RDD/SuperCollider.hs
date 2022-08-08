-- | SuperCollider UGen Bindings
module Sound.SC3.UGen.DB.Bindings.SuperCollider where

import Data.List {- base -}
import Text.Printf {- base -}

import qualified Sound.SC3.Common.Rate as Rate {- hsc3 -}

import qualified Sound.SC3.UGen.DB.Record as Db {- hsc3-db -}
import qualified Sound.SC3.UGen.DB.Rename as Rename {- hsc3-db -}

-- | UGens that already have filter methods.
sc_filter_method_ignore_list :: [String]
sc_filter_method_ignore_list =
  ["CheckBadValues","Clip","DegreeToKey","Fold","Lag","Lag2","Lag3","Poll","Sanitize","Slew","UnaryOpUGen","Wrap"]

{- | Filter method for U.
     Note this should (but does not, it does error...) reorder inputs.
-}
sc_filter_method :: Db.U -> String
sc_filter_method u =
  let delete_at k l = let (p,q) = splitAt k l in p ++ tail q
      nm = Db.ugen_name u
      mth = Rename.fromSC3Name nm
      ix = Db.u_unary_filter_ix u
      inp = map Db.input_name (Db.ugen_inputs u)
      def = map Db.input_default (Db.ugen_inputs u)
      self = inp !! ix
      jn = (\i j -> concat [i," = ",show j])
      arg = if length inp == 1
            then ""
            else concat ["    arg ", intercalate ", " (zipWith jn (delete_at ix inp) (delete_at ix def)), ";\n"]
      cons = map (\x -> if x == self then "this" else x) inp
      reo = case Db.ugen_reorder u of
              Nothing -> ""
              Just x -> printf "    \"sc_filter_method: reordering not implemented: %s \".error;\n" (show x)
  in printf "  %s {\n%s%s    ^%s.multiNew(%s)\n  }" mth arg reo nm (intercalate ", " ("this.rate" : cons))

sc_filter_methods :: [Db.U] -> String
sc_filter_methods u =
  unlines
  ["+ UGen {"
  ,unlines (map sc_filter_method u)
  ,"}"
  ,"+ Array {"
  ,unlines (map sc_filter_method u)
  ,"}"]

-- * Implicit Rates

{- | Filter consrtructor with implicit rate for U.
     Note this should (but does not, it does error...) reorder inputs.
-}
sc_filter_constructor :: Db.U -> String
sc_filter_constructor u =
  let nm = Db.ugen_name u
      ix = Db.u_unary_filter_ix u
      inp = map Db.input_name (Db.ugen_inputs u)
      def = map Db.input_default (Db.ugen_inputs u)
      jn = (\i j -> concat [i," = ",show j])
      arg = if length inp == 0
            then ""
            else concat ["arg ", intercalate ", " (zipWith jn inp def), ";"]
      rt = concat [inp !! ix, ".rate"]
      reo = case Db.ugen_reorder u of
              Nothing -> ""
              Just x -> printf "\"sc_filter_constructor: reordering not implemented: %s \".error; " (show x)
  in printf "+ %s { *new { %s%s^%s.multiNew(%s) } }" nm arg reo nm (intercalate ", " (rt : inp))

sc_filter_constructors :: [Db.U] -> String
sc_filter_constructors = unlines . map sc_filter_constructor

sc_implicit_rate_ignore_list :: [String]
sc_implicit_rate_ignore_list =
  ["ClearBuf","Dbufrd","Dbufwr","Dseries","ExpRand","FFT","IFFT","IRand","LinRand","LocalBuf","PV_RandComb","Rand","SetBuf"]

-- | Implicit rate constructor for U.
sc_implicit_rate_constructor :: Db.U -> String
sc_implicit_rate_constructor u =
  let nm = Db.ugen_name u
      inp = map Db.input_name (Db.ugen_inputs u)
      def = map Db.input_default (Db.ugen_inputs u)
      jn = (\i j -> concat [i," = ",show j])
      arg = if length inp == 0
            then ""
            else concat ["arg ", intercalate ", " (zipWith jn inp def), "; "]
      rt = concat ["'",Rate.rateName (Db.ugen_default_rate u),"'"]
      reo = case Db.ugen_reorder u of
              Nothing -> ""
              Just x -> printf "\"sc_implicit_rate_constructor: reordering not implemented: %s \".error; " (show x)
  in printf "+ %s { *new { %s%s^%s.multiNew(%s) } }" nm arg reo nm (intercalate ", " (rt : inp))

sc_implicit_rate_constructors :: [Db.U] -> String
sc_implicit_rate_constructors = unlines . map sc_implicit_rate_constructor
