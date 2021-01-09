module Widgets.Search exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes
    exposing
        ( autofocus
        , css
        , placeholder
        , type_
        , value
        )
import Html.Styled.Events exposing (onInput)
import Misc.Helpers exposing (css2)
import Partials.Clock as Clock
import Styles.Themes exposing (Theme)


type alias Model =
    { clockModel : Clock.Model
    , searchTerm : String
    }


type Msg
    = ClockMsg Clock.Msg
    | SearchTermUpdate String


init : () -> ( Model, Cmd Msg )
init flags =
    let
        ( clockInitModel, clockCmd ) =
            Clock.init flags
    in
    ( Model clockInitModel ""
    , Cmd.batch
        [ clockCmd |> Cmd.map ClockMsg ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClockMsg clockMsg ->
            let
                ( newClockModel, newClockCmd ) =
                    Clock.update clockMsg model.clockModel
            in
            ( { model | clockModel = newClockModel }
            , newClockCmd |> Cmd.map ClockMsg
            )

        SearchTermUpdate term ->
            ( { model | searchTerm = term }, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Clock.subscriptions model.clockModel |> Sub.map ClockMsg ]


view : Theme -> List Style -> Model -> Html Msg
view theme overrideStyle model =
    div
        [ css2 [] overrideStyle ]
        [ Html.Styled.map ClockMsg <|
            Clock.view
                theme
                [ textAlign center
                , paddingBottom <| px 5
                ]
                model.clockModel
        , viewSearchBar theme model
        ]


viewSearchBar : Theme -> Model -> Html Msg
viewSearchBar theme model =
    input
        [ type_ "text"
        , autofocus True
        , placeholder "Google Search"
        , value model.searchTerm
        , css
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
            , width <| pct 100
            ]
        , onInput SearchTermUpdate
        ]
        []
