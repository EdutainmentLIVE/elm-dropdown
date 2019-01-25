module Dropdown.View.Trigger exposing (arrowView, clearView, onKeyUpAttribute, promptOrCurrentView, view)

import Dropdown.Events exposing (onBlurAttribute)
import Dropdown.Messages exposing (..)
import Dropdown.Models exposing (..)
import Dropdown.Utils as Utils
import Dropdown.View.Arrow as Arrow
import Dropdown.View.Clear as Clear
import Html exposing (..)
import Html.Attributes exposing (class, id, style, tabindex)
import Html.Events exposing (keyCode, on, onClick, stopPropagationOn)
import Json.Decode as Decode


onKeyUpAttribute : Attribute (Msg item)
onKeyUpAttribute =
    let
        fn code =
            case Utils.toKey code of
                KeyEnter ->
                    Decode.succeed OnClickPrompt

                KeySpace ->
                    Decode.succeed OnClickPrompt

                KeyArrowDown ->
                    Decode.succeed OnClickPrompt

                _ ->
                    Decode.fail "Invalid"
    in
    on "keyup" (Decode.andThen fn keyCode)


view : Config msg item -> State -> List item -> Maybe item -> Html (Msg item)
view config state items selected =
    let
        styles =
            List.append config.triggerStyles
                [ ( "display", "flex" )
                , ( "align-items", "center" )
                , ( "cursor", "pointer" )
                ]

        classes =
            config.triggerClass
    in
    div
        ([ class classes
         , onBlurAttribute config state
         , onClick OnClickPrompt
         , onKeyUpAttribute
         , tabindex 0
         , Utils.referenceAttr config state
         ]
            ++ List.map (\( f, s ) -> style f s) styles
        )
        [ promptOrCurrentView config state selected
        , clearView config state selected
        , arrowView config state
        ]


promptOrCurrentView : Config msg item -> State -> Maybe item -> Html (Msg item)
promptOrCurrentView config state selected =
    let
        ( maybePromptClass, maybePromptStyles ) =
            case selected of
                Nothing ->
                    ( config.promptClass, config.promptStyles )

                _ ->
                    ( "", [] )

        classes =
            maybePromptClass

        styles =
            List.append
                [ ( "flex-grow", "1" )
                , ( "text-overflow", "ellipsis" )
                , ( "overflow", "hidden" )
                , ( "white-space", "nowrap" )
                ]
                maybePromptStyles

        shownText =
            case selected of
                Nothing ->
                    config.prompt

                Just item ->
                    config.toLabel item
    in
    span (class classes :: List.map (\( f, s ) -> style f s) styles) [ text shownText ]


clearView : Config msg item -> State -> Maybe item -> Html (Msg item)
clearView config state selected =
    let
        classes =
            "elm-dropdown-clear " ++ config.clearClass

        styles =
            List.append config.clearStyles
                [ ( "line-height", "0rem" ) ]

        alwaysPreventDefault msg =
            ( msg, True )

        onClickWithoutPropagation msg =
            Decode.succeed msg
                |> Decode.map alwaysPreventDefault
                |> stopPropagationOn "click"
    in
    if config.hasClear then
        case selected of
            Nothing ->
                text ""

            Just _ ->
                span
                    ([ class classes
                     , onClickWithoutPropagation OnClear
                     ]
                        ++ List.map (\( f, s ) -> style f s) styles
                    )
                    [ Clear.view config ]

    else
        text ""


arrowView : Config msg item -> State -> Html (Msg item)
arrowView config state =
    let
        classes =
            "elm-dropdown-arrow " ++ config.arrowClass

        styles =
            List.append config.arrowStyles
                [ ( "margin", "0 0.25rem 0 0" )
                , ( "line-height", "0rem" )
                ]
    in
    span
        (class classes :: List.map (\( f, s ) -> style f s) styles)
        [ Arrow.view config ]
