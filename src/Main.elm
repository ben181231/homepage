module Main exposing (..)

import Css exposing (..)
import Css.Transitions exposing (background)
import Html as HtmlCore
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Styles.Themes


main : HtmlCore.Html msg
main =
    let
        theme =
            Styles.Themes.default
    in
    toUnstyled <|
        fullScreenView theme []


fullScreenView : Styles.Themes.Theme -> List (Html msg) -> Html msg
fullScreenView theme content =
    div
        [ css
            [ position absolute
            , backgroundColor theme.backgroundColor
            , backgroundImage <|
                linearGradient
                    (stop theme.backagrondGradientFrom)
                    (stop theme.backagrondGradientTo)
                    []
            , top <| px 0
            , left <| px 0
            , right <| px 0
            , bottom <| px 0
            ]
        ]
        content
