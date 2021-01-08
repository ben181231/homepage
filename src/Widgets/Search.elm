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
import Misc.Helpers exposing (css2)
import Partials.Clock as Clock
import Partials.SearchBar as SearchBar
import Styles.Themes exposing (Theme)


type alias Model =
    { clockModel : Clock.Model }


type Msg
    = ClockMsg Clock.Msg


init : () -> ( Model, Cmd Msg )
init flags =
    let
        ( clockInitModel, clockCmd ) =
            Clock.init flags
    in
    ( Model clockInitModel
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
        , SearchBar.view theme
            [ width <| pct 100
            ]
        ]
