module Misc.Helpers exposing (..)

import Css exposing (Style)
import Html.Styled exposing (Attribute)
import Html.Styled.Attributes exposing (css)


css2 : List Style -> List Style -> Attribute msg
css2 style1 style2 =
    css (style1 ++ style2)


isTrimmedEmpty : String -> Bool
isTrimmedEmpty =
    String.trim >> String.isEmpty
