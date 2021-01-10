port module Widgets.Search exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Array
import Browser.Events exposing (onKeyUp)
import Browser.Navigation
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
import Html.Styled.Events exposing (keyCode, onInput)
import Http
import Json.Decode as Decode
import List
import List.Extra
import Misc.Helpers exposing (css2, isTrimmedEmpty)
import Partials.Clock as Clock
import Styles.Themes exposing (Theme)
import Url.Builder


port execJsonp : String -> Cmd msg


port getJsonpData : (String -> msg) -> Sub msg


type alias SearchResult =
    { term : String
    , url : String
    , selected : Bool
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
    | KeyUp Int


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

        KeyUp code ->
            handleKeyUp code model


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


handleKeyUp : Int -> Model -> ( Model, Cmd Msg )
handleKeyUp keyCode model =
    let
        isEmptyTerm =
            isTrimmedEmpty model.searchTerm

        isEmtpyResult =
            List.isEmpty model.searchResults

        selectedIndex =
            List.indexedMap Tuple.pair model.searchResults
                |> List.filter (Tuple.second >> .selected)
                |> List.map Tuple.first
                |> List.head

        selectedResult =
            selectedIndex
                |> Maybe.andThen
                    (\idx ->
                        List.Extra.getAt idx model.searchResults
                    )

        allUnselectedResults =
            model.searchResults
                |> List.map (\r -> { r | selected = False })

        targetUrl =
            Maybe.andThen (.url >> Just) selectedResult
                |> Maybe.withDefault
                    (buildResultUrl <| String.trim model.searchTerm)
    in
    case ( isEmptyTerm, isEmtpyResult, keyCode ) of
        ( True, _, _ ) ->
            ( model, Cmd.none )

        -- 13: Enter
        ( _, _, 13 ) ->
            ( model, Browser.Navigation.load targetUrl )

        ( _, True, _ ) ->
            ( model, Cmd.none )

        -- 38: Arrow Up
        ( _, _, 38 ) ->
            case selectedIndex of
                Nothing ->
                    ( model, Cmd.none )

                Just 0 ->
                    ( { model | searchResults = allUnselectedResults }
                    , Cmd.none
                    )

                Just idx ->
                    ( { model
                        | searchResults =
                            allUnselectedResults
                                |> List.Extra.updateAt
                                    (idx - 1)
                                    (\r -> { r | selected = True })
                      }
                    , Cmd.none
                    )

        -- 40: Arrow Down
        ( _, _, 40 ) ->
            let
                isLastIndex =
                    selectedIndex
                        |> Maybe.map
                            (\idx ->
                                idx + 1 == List.length model.searchResults
                            )
                        |> Maybe.withDefault False
            in
            case ( selectedIndex, isLastIndex ) of
                ( Nothing, _ ) ->
                    ( { model
                        | searchResults =
                            allUnselectedResults
                                |> List.Extra.updateAt
                                    0
                                    (\r -> { r | selected = True })
                      }
                    , Cmd.none
                    )

                ( _, True ) ->
                    ( { model | searchResults = allUnselectedResults }
                    , Cmd.none
                    )

                ( Just idx, _ ) ->
                    ( { model
                        | searchResults =
                            allUnselectedResults
                                |> List.Extra.updateAt
                                    (idx + 1)
                                    (\r -> { r | selected = True })
                      }
                    , Cmd.none
                    )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Clock.subscriptions model.clockModel |> Sub.map ClockMsg
        , getJsonpData searchResultsHandler
        , onKeyUp (Decode.map KeyUp keyCode)
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
    let
        baseStyles =
            [ margin zero
            , padding zero
            , listStyle none
            , width <| pct 100
            , height auto
            , property "transform-origin" "50% top"
            , transition [ Css.Transitions.transform 500 ]
            ]
    in
    if List.isEmpty model.searchResults then
        ul
            [ css2
                baseStyles
                [ transform <| rotateX <| deg -75 ]
            ]
            []

    else
        model.searchResults
            |> List.map (viewSearchResult theme)
            |> ul
                [ css2
                    baseStyles
                    [ transform <| rotateX <| deg 0 ]
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
            [ css2
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
                (if searchResult.selected then
                    [ borderLeftColor theme.searchResultBorderHoverColor
                    , backgroundColor
                        theme.searchResultBackgroundHoverColor
                    ]

                 else
                    []
                )
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
                |> Decode.map (\ts -> List.map buildResult ts)
    in
    Decode.decodeString resultsDecoder data
        |> (Result.withDefault []
                >> List.take 7
                >> GotSearchResults
           )


buildResult : String -> SearchResult
buildResult term =
    SearchResult
        term
        (buildResultUrl term)
        False


buildResultUrl : String -> String
buildResultUrl term =
    Url.Builder.crossOrigin
        "https://www.google.com"
        [ "search" ]
        [ Url.Builder.string "q" term ]
