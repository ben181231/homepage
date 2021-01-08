module Partials.Clock exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Misc.Helpers exposing (css2)
import Styles.Themes exposing (Theme)


view : Theme -> List Style -> Html msg
view theme overrideStyle =
    div
        [ css2
            [ color theme.textColor
            , fontFamilies theme.textFonts
            , fontSize <| Css.em 1.4
            ]
            overrideStyle
        ]
        [ text "Fri Jan 08 2021, 16:00:06" ]
