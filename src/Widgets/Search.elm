module Widgets.Search exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Css exposing (..)
import Css.Transitions exposing (transition)
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
import Misc.Helpers exposing (css2)
import Partials.Clock as Clock
import Styles.Themes exposing (Theme)


type alias SearchResult =
    { term : String
    , url : String
    }


type alias Model =
    { clockModel : Clock.Model
    , searchTerm : String
    , searchResults : List SearchResult
    }


type Msg
    = ClockMsg Clock.Msg
    | SearchTermUpdate String
    | GotSearchResults (List SearchResult)


init : () -> ( Model, Cmd Msg )
init flags =
    let
        ( clockInitModel, clockCmd ) =
            Clock.init flags
    in
    ( Model clockInitModel "" []
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

        GotSearchResults results ->
            ( { model | searchResults = results }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Clock.subscriptions model.clockModel |> Sub.map ClockMsg ]


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
