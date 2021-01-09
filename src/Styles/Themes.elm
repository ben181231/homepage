module Styles.Themes exposing (Theme, default)

import Css exposing (..)


type alias Theme =
    { backagrondGradientFrom : Color
    , backagrondGradientTo : Color
    , backgroundColor : Color
    , searchBoxBorderColor : Color
    , searchBoxBorderHighlightColor : Color
    , searchResultBackgroundColor : Color
    , searchResultBackgroundHoverColor : Color
    , searchResultBorderColor : Color
    , searchResultBorderHoverColor : Color
    , searchBoxTextColor : Color
    , textColor : Color
    , textFonts : List String
    }


default : Theme
default =
    { backagrondGradientFrom = hex "#221847"
    , backagrondGradientTo = hex "#302266"
    , backgroundColor = hex "#302266"
    , searchBoxBorderColor = hex "#000000"
    , searchBoxBorderHighlightColor = hex "#ffffff"
    , searchResultBackgroundColor = hex "#122A4F"
    , searchResultBackgroundHoverColor = hex "#265DA6"
    , searchResultBorderColor = hex "#1A3C71"
    , searchResultBorderHoverColor = hex "#387AD1"
    , searchBoxTextColor = hex "#ffffff"
    , textColor = hex "#739CBF"
    , textFonts =
        [ "HelveticaNeue-Light"
        , "Helvetica"
        , "sans-serif"
        ]
    }
