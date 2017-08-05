module Material.Checkbox
    exposing
        ( Model
        , defaultModel
        , Msg
        , update
        , Config
        , view
        , render
        , disabled
        , indeterminate
        , checked
        , react
        )

{-| TODO
-}

import Html.Attributes as Html
import Html exposing (Html, text)
import Json.Decode as Json
import Json.Encode
import Material.Component as Component exposing (Indexed)
import Material.Helpers exposing (map1st, map2nd, blurOn, filter, noAttr)
import Material.Internal.Checkbox exposing (Msg(..))
import Material.Internal.Options as Internal
import Material.Msg exposing (Index)
import Material.Options as Options exposing (Style, cs, styled, many, when, maybe)
import Svg.Attributes as Svg
import Svg exposing (path)

-- MODEL


{-| Component model.
-}
type alias Model =
    { isFocused : Bool
    }


{-| Default component model.
-}
defaultModel : Model
defaultModel =
    { isFocused = False
    }



-- ACTION, UPDATE


{-| Component message.
-}
type alias Msg
    = Material.Internal.Checkbox.Msg


{-| Component update.
-}
update : (Msg -> m) -> Msg -> Model -> ( Maybe Model, Cmd m )
update _ msg model =
    case msg of
        SetFocus focus ->
            ( Just { model | isFocused = focus }, Cmd.none )
        NoOp ->
            ( Nothing, Cmd.none )


-- OPTIONS


type alias Config m =
    { input : List (Options.Style m)
    , container : List (Options.Style m)
    , value : Bool
    }


defaultConfig : Config m
defaultConfig =
    { input = []
    , container = []
    , value = False
    }


{-| TODO
-}
type alias Property m =
    Options.Property (Config m) m


{-| TODO
-}
disabled : Property m
disabled =
    Options.many
    [ cs "mdc-checkbox--disabled"
    , Internal.input
      [ Internal.attribute <| Html.disabled True
      ]
    ]


{-| TODO
-}
checked : Property m
checked =
    Internal.option (\config -> { config | value = True })


{-| TODO
-}
indeterminate : Property m
indeterminate =
    Internal.input
    [ Internal.attribute <| Html.property "indeterminate" (Json.Encode.bool True)
    ]


-- VIEW


{-| Component view.
-}
view : (Msg -> m) -> Model -> List (Property m) -> List (Html m) -> Html m
view lift model options _ =
    let
        ({ config } as summary) =
            Internal.collect defaultConfig options
    in
    Internal.applyContainer summary Html.div
    [ cs "mdc-checkbox"
    , Internal.attribute <| blurOn "mouseup"
    ]
    [ Internal.applyInput summary
        Html.input
        [ cs "mdc-checkbox__native-control"
        , Internal.attribute <| Html.type_ "checkbox"
        , Internal.attribute <| Html.checked config.value
        , Internal.on1 "focus" lift (SetFocus True)
        , Internal.on1 "blur" lift (SetFocus False)
        , Options.onWithOptions "click"
            { preventDefault = True
            , stopPropagation = False
            }
            (Json.succeed (lift NoOp))
        ]
        []
    , styled Html.div
      [ cs "mdc-checkbox__background"
      ]
      [ Svg.svg
        [ Svg.class "mdc-checkbox__checkmark"
        , Svg.viewBox "0 0 24 24"
        ]
        [ path
          [ Svg.class "mdc-checkbox__checkmark__path"
          , Svg.fill "none"
          , Svg.stroke "white"
          , Svg.d "M1.73,12.91 8.1,19.28 22.79,4.59"
          ]
          [
          ]
        ]
      , styled Html.div
        [ cs "mdc-checkbox__mixedmark"
        ]
        []
      ]
    ]


-- COMPONENT


type alias Store s =
    { s | checkbox : Indexed Model }


( get, set ) =
    Component.indexed .checkbox (\x y -> { y | checkbox = x }) defaultModel


{-| Component react function.
-}
react :
    (Material.Msg.Msg m -> m)
    -> Msg
    -> Index
    -> Store s
    -> ( Maybe (Store s), Cmd m )
react =
    Component.react get set Material.Msg.CheckboxMsg update
    -- TODO: make react always like this ^^^^, don't use generalise?


{-| Component render (checkbox)
-}
render :
    (Material.Msg.Msg m -> m)
    -> Index
    -> Store s
    -> List (Property m)
    -> List (Html m)
    -> Html m
render lift index store options =
    Component.render get view Material.Msg.CheckboxMsg lift index store
        (Internal.dispatch lift :: options)
