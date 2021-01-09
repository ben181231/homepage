port module Widgets.Search exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Css exposing (..)
import Css.Transitions exposing (transition)
import Debounce
import Html.Styled exposing (..)
import Html.Styled.Attributes
    exposing
        ( autofocus
        , css
        , href
        , placeholder
        , type_
        , value
        )
import Html.Styled.Events exposing (onInput)
import Http
import Json.Decode as Decode
import Misc.Helpers exposing (css2, isTrimmedEmpty)
import Partials.Clock as Clock
import Styles.Themes exposing (Theme)
import Url.Builder


port execJsonp : String -> Cmd msg


port getJsonpData : (String -> msg) -> Sub msg


type alias SearchResult =
    { term : String
    , url : String
    }


type alias Model =
    { clockModel : Clock.Model
    , searchTerm : String
    , debouncedSearchTerm : String
    , searchResults : List SearchResult
    , searchDebounce : Debounce.Model String
    }


type Msg
    = ClockMsg Clock.Msg
    | DebounceMsg (Debounce.Msg String)
    | SearchTermUpdate String
    | GotSearchResults (List SearchResult)


init : () -> ( Model, Cmd Msg )
init flags =
    let
        ( clockInitModel, clockCmd ) =
            Clock.init flags
    in
    ( Model
        clockInitModel
        ""
        ""
        []
        (Debounce.init 500 "")
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

        DebounceMsg debounceMsg ->
            updateDebounce debounceMsg model

        SearchTermUpdate term ->
            let
                newSearchResults =
                    if isTrimmedEmpty term then
                        []

                    else
                        model.searchResults
            in
            updateDebounce (Debounce.Change term) <|
                { model
                    | searchTerm = term
                    , searchResults = newSearchResults
                }

        GotSearchResults results_ ->
            let
                results =
                    if isTrimmedEmpty model.searchTerm then
                        []

                    else
                        results_
            in
            ( { model | searchResults = results }, Cmd.none )


updateDebounce : Debounce.Msg String -> Model -> ( Model, Cmd Msg )
updateDebounce debounceMsg model =
    let
        ( newSearchDebounce, debounceCmd, maybeDebouncedTerm ) =
            Debounce.update debounceMsg model.searchDebounce

        newDebouncedTerm =
            Maybe.withDefault model.debouncedSearchTerm maybeDebouncedTerm
    in
    ( { model
        | searchDebounce = newSearchDebounce
        , debouncedSearchTerm = newDebouncedTerm
      }
    , Cmd.batch <|
        (::) (Cmd.map DebounceMsg debounceCmd) <|
            if newDebouncedTerm == model.debouncedSearchTerm then
                []

            else
                [ getSearchResult newDebouncedTerm ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Clock.subscriptions model.clockModel |> Sub.map ClockMsg
        , getJsonpData searchResultsHandler
        ]


view : Theme -> List Style -> Model -> Html Msg
view theme overrideStyle model =
    let
        ( topOffset, clockRotation ) =
            if List.isEmpty model.searchResults then
                ( 0, 0 )

            else
                ( -145, 90 )
    in
    div
        [ css2
            [ transform <| translateY <| px topOffset
            , transition [ Css.Transitions.transform 500 ]
            ]
            overrideStyle
        ]
        [ Html.Styled.map ClockMsg <|
            Clock.view
                theme
                [ textAlign center
                , paddingBottom <| px 5
                , transform <| rotateX <| deg clockRotation
                , property "transform-origin" "50% bottom"
                , transition [ Css.Transitions.transform 500 ]
                ]
                model.clockModel
        , viewSearchBar theme model
        , viewSearchResults theme model
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


viewSearchResults : Theme -> Model -> Html Msg
viewSearchResults theme model =
    if List.isEmpty model.searchResults then
        text ""

    else
        model.searchResults
            |> List.map (viewSearchResult theme)
            |> ul
                [ css
                    [ margin zero
                    , padding zero
                    , listStyle none
                    , width <| pct 100
                    , height auto
                    ]
                ]


viewSearchResult : Theme -> SearchResult -> Html Msg
viewSearchResult theme searchResult =
    a
        [ href searchResult.url
        , css
            [ textDecoration none
            , fontFamilies <| theme.textFonts
            , color <| theme.textColor
            ]
        ]
        [ li
            [ css
                [ boxSizing borderBox
                , minHeight <| px 34
                , maxHeight <| px 68
                , width <| pct 100
                , padding <| px 5
                , borderStyle solid
                , borderColor theme.searchResultBorderColor
                , borderWidth4 zero zero (px 1) (px 3)
                , backgroundColor theme.searchResultBackgroundColor
                , hover
                    [ borderLeftColor theme.searchResultBorderHoverColor
                    , backgroundColor
                        theme.searchResultBackgroundHoverColor
                    ]
                ]
            ]
            [ text searchResult.term ]
        ]


getSearchResult : String -> Cmd Msg
getSearchResult term =
    if isTrimmedEmpty term then
        Cmd.none

    else
        let
            url =
                Url.Builder.crossOrigin
                    "http://suggestqueries.google.com"
                    [ "complete", "search" ]
                    [ Url.Builder.string "client" "firefox"
                    , Url.Builder.string "callback" "_sr"
                    , Url.Builder.string "q" term
                    ]
        in
        execJsonp url


searchResultsHandler : String -> Msg
searchResultsHandler data =
    let
        resultsDecoder : Decode.Decoder (List SearchResult)
        resultsDecoder =
            Decode.list Decode.string
                |> Decode.index 1
                |> Decode.map (\ts -> List.map resultBuilder ts)
    in
    Decode.decodeString resultsDecoder data
        |> (Result.withDefault [] >> GotSearchResults)


resultBuilder : String -> SearchResult
resultBuilder term =
    SearchResult term <|
        Url.Builder.crossOrigin
            "https://www.google.com"
            [ "search" ]
            [ Url.Builder.string "q" term ]
