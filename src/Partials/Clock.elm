module Partials.Clock exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Css exposing (..)
import DateFormat
import Html.Styled exposing (..)
import Misc.Helpers exposing (css2)
import Styles.Themes exposing (Theme)
import Task
import Time


type alias Model =
    { currentTime : Time.Posix
    , currentTimezone : Time.Zone
    }


type Msg
    = GotNewTime Time.Posix
    | GotTimezone Time.Zone


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (Time.millisToPosix 0) Time.utc
    , Cmd.batch
        [ Task.perform GotNewTime Time.now
        , Task.perform GotTimezone Time.here
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotNewTime t ->
            ( { model | currentTime = t }, Cmd.none )

        GotTimezone z ->
            ( { model | currentTimezone = z }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 500 GotNewTime


view : Theme -> List Style -> Model -> Html Msg
view theme overrideStyle model =
    div
        [ css2
            [ color theme.textColor
            , fontFamilies theme.textFonts
            , fontSize <| Css.em 1.4
            ]
            overrideStyle
        ]
        [ dateFormatter model.currentTimezone model.currentTime |> text ]


dateFormatter : Time.Zone -> Time.Posix -> String
dateFormatter =
    DateFormat.format
        [ DateFormat.yearNumber
        , DateFormat.text "/"
        , DateFormat.monthFixed
        , DateFormat.text "/"
        , DateFormat.dayOfMonthFixed
        , DateFormat.text " "
        , DateFormat.hourMilitaryFixed
        , DateFormat.text ":"
        , DateFormat.minuteFixed
        , DateFormat.text ":"
        , DateFormat.secondFixed
        , DateFormat.text " "
        , DateFormat.dayOfWeekNameFull
        ]
