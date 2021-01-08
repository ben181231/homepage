module Main exposing (main, view)

import Css exposing (..)
import Css.Transitions exposing (background)
import Html as HtmlCore
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Styles.Themes exposing (Theme)
import Widgets.Search


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
            , top zero
            , left zero
            , right zero
            , bottom zero
            ]
        ]
        [ Widgets.Search.view theme
            [ position relative
            , width <| px 300
            , height <| px 70
            , top <| pct 50
            , left <| pct 50
            , marginTop <| px -35
            , marginLeft <| px -150
            ]
        ]
