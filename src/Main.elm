module Main exposing (main, view)

import Css exposing (..)
import Css.Transitions exposing (background)
import Html as HtmlCore
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Styles.Themes exposing (Theme)


main : HtmlCore.Html msg
main =
    toUnstyled <|
        view Styles.Themes.default


view : Theme -> Html msg
view theme =
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
        []
