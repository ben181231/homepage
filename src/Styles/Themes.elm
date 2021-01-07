module Styles.Themes exposing (Theme, default)

import Css exposing (..)


type alias Theme =
    { backgroundColor : Color
    , backagrondGradientFrom : Color
    , backagrondGradientTo : Color
    }


default : Theme
default =
    { backgroundColor = hex "#302266"
    , backagrondGradientFrom = hex "#221847"
    , backagrondGradientTo = hex "#302266"
    }
