module Main exposing (..)

import Css exposing (..)
import Css.Transitions exposing (background)
import Html as HtmlCore
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)


main : HtmlCore.Html msg
main =
    toUnstyled <|
        fullScreenView []


fullScreenView : List (Html msg) -> Html msg
fullScreenView content =
    div
        [ css
            [ position absolute
            , backgroundColor <| hex "#302266"
            , backgroundImage <|
                linearGradient
                    (stop <| hex "#221847")
                    (stop <| hex "#302266")
                    []
            , top <| px 0
            , left <| px 0
            , right <| px 0
            , bottom <| px 0
            ]
        ]
        content
