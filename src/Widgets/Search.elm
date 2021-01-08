module Widgets.Search exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Misc.Helpers exposing (css2)
import Partials.Clock as Clock
import Partials.SearchBar as SearchBar
import Styles.Themes exposing (Theme)


view : Theme -> List Style -> Html msg
view theme overrideStyle =
    div
        [ css2 [] overrideStyle ]
        [ Clock.view theme
            [ textAlign center
            , paddingBottom <| px 5
            ]
        , SearchBar.view theme
            [ width <| pct 100
            ]
        ]
