module Main exposing (main)

import Browser
import Css exposing (..)
import Html as HtmlCore
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Styles.Themes exposing (Theme)
import Widgets.Search as Search


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { searchModel : Search.Model }


type Msg
    = SearchMsg Search.Msg


init : () -> ( Model, Cmd Msg )
init flags =
    let
        ( searchInitModel, searchCmd ) =
            Search.init flags
    in
    ( Model searchInitModel
    , Cmd.batch
        [ searchCmd |> Cmd.map SearchMsg ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchMsg searchMsg ->
            let
                ( newSearchModel, newSearchCmd ) =
                    Search.update searchMsg model.searchModel
            in
            ( { model | searchModel = newSearchModel }
            , newSearchCmd |> Cmd.map SearchMsg
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Search.subscriptions model.searchModel |> Sub.map SearchMsg ]


view : Model -> HtmlCore.Html Msg
view model =
    toUnstyled <|
        themeView Styles.Themes.default model


themeView : Theme -> Model -> Html Msg
themeView theme model =
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
        [ Html.Styled.map SearchMsg <|
            let
                viewWidth =
                    300

                viewHeight =
                    70
            in
            Search.view
                theme
                [ position relative
                , width <| px viewWidth
                , height <| px viewHeight
                , top <| pct 50
                , left <| pct 50
                , marginTop <| px <| -viewHeight / 2
                , marginLeft <| px <| -viewWidth / 2
                ]
                model.searchModel
        ]
