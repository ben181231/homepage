module Partials.SearchBar exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (autofocus, placeholder, type_)
import Misc.Helpers exposing (css2)
import Styles.Themes exposing (Theme)


view : Theme -> List Style -> Html msg
view theme overrideStyle =
    input
        [ type_ "text"
        , autofocus True
        , placeholder "Google Search"
        , css2
            [ backgroundColor <| rgba 255 255 255 0.05
            , margin zero
            , padding <| px 10
            , borderWidth zero
            , borderStyle solid
            , borderColor theme.searchBoxBorderColor
            , borderRadius zero
            , borderBottomWidth <| px 1
            , fontSize <| Css.em 1
            , color theme.searchBoxTextColor
            , boxSizing borderBox
            , focus
                [ borderColor theme.searchBoxBorderHighlightColor
                , outline zero
                ]
            ]
            overrideStyle
        ]
        []
