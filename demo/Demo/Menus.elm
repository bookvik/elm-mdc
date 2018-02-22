module Demo.Menus exposing (Model, defaultModel, Msg(Mdl), view, update, subscriptions)

import Demo.Page as Page exposing (Page)
import Html.Attributes as Html
import Html.Events as Html
import Html exposing (Html, text)
import Json.Decode as Json
import Material
import Material.Button as Button
import Material.List as Lists
import Material.Menu as Menu
import Material.Options as Options exposing (styled, cs, css, nop, when)


type alias Model =
    { mdl : Material.Model
    , selected : Maybe ( Int, String )
    , position : List String
    , anchorCorner : Menu.Corner
    , topMargin : String
    , bottomMargin : String
    , leftMargin : String
    , rightMargin : String
    , rtl : Bool
    , rememberSelectedItem : Bool
    , openAnimation : Bool
    , menuSize : MenuSize
    , anchorWidth : AnchorWidth
    }


defaultModel : Model
defaultModel =
    { mdl = Material.defaultModel
    , selected = Nothing
    , position = [ "top", "left" ]
    , anchorCorner = Menu.topStartCorner
    , topMargin = "0"
    , bottomMargin = "0"
    , leftMargin = "0"
    , rightMargin = "0"
    , rtl = False
    , rememberSelectedItem = False
    , openAnimation = True
    , menuSize = Regular
    , anchorWidth = Comparable
    }


type MenuSize
    = Regular
    | Large
    | ExtraTall


type AnchorWidth
    = Small
    | Comparable
    | Wider


type Msg m
    = Mdl (Material.Msg m)
    | Select ( Int, String )
    | SetPosition ( List String )
    | SetAnchorCorner Menu.Corner
    | SetTopMargin String
    | SetBottomMargin String
    | SetLeftMargin String
    | SetRightMargin String
    | ToggleRtl
    | ToggleRememberSelectedItem
    | ToggleOpenAnimation
    | SetMenuSize MenuSize
    | SetAnchorWidth AnchorWidth


update : (Msg m -> m) -> Msg m -> Model -> ( Model, Cmd m )
update lift msg model =
    case msg of
        Mdl msg_ ->
            Material.update (Mdl >> lift) msg_ model

        Select value ->
            ( { model | selected = Just value }, Cmd.none )

        SetPosition position ->
            ( { model | position = position }, Cmd.none )

        SetAnchorCorner anchorCorner ->
            ( { model | anchorCorner = anchorCorner }, Cmd.none )

        SetTopMargin topMargin ->
            ( { model | topMargin = topMargin }, Cmd.none )

        SetBottomMargin bottomMargin ->
            ( { model | bottomMargin = bottomMargin }, Cmd.none )

        SetLeftMargin leftMargin ->
            ( { model | leftMargin = leftMargin }, Cmd.none )

        SetRightMargin rightMargin ->
            ( { model | rightMargin = rightMargin }, Cmd.none )

        ToggleRtl ->
            ( { model | rtl = not model.rtl }, Cmd.none )

        ToggleRememberSelectedItem ->
            ( { model | rememberSelectedItem = not model.rememberSelectedItem }, Cmd.none )

        ToggleOpenAnimation ->
            ( { model | openAnimation = not model.openAnimation }, Cmd.none )

        SetMenuSize menuSize ->
            ( { model | menuSize = menuSize }, Cmd.none )

        SetAnchorWidth anchorWidth ->
            ( { model | anchorWidth = anchorWidth }, Cmd.none )


menuItems : MenuSize -> List ( Int, String )
menuItems menuSize =
    case menuSize of
        Regular ->
            [ ( 0, "Back" )
            , ( 1, "Forward" )
            , ( 2, "Reload" )
            , (-1, "-" )
            , ( 3, "Save As…" )
            , ( 4, "Help" )
            ]

        Large ->
            [ ( 0, "Back" )
            , ( 1, "Forward" )
            , ( 2, "Reload" )
            , (-1, "-" )
            , ( 3, "Save As…" )
            , ( 4, "Help" )
            , ( 5, "Settings" )
            , ( 6, "Feedback" )
            , ( 7, "Options…" )
            , ( 8, "Item 1" )
            , ( 9, "Item 2" )
            ]

        ExtraTall ->
            [ ( 0, "Back" )
            , ( 1, "Forward" )
            , ( 2, "Reload" )
            , (-1, "-" )
            , ( 3, "Save As…" )
            , ( 4, "Help" )
            , ( 5, "Settings" )
            , ( 6, "Feedback" )
            , ( 7, "Options…" )
            , ( 8, "Item 1" )
            , ( 9, "Item 2" )
            , ( 10, "Item 3" )
            , ( 11, "Item 4" )
            , ( 12, "Item 5" )
            , ( 13, "Item 6" )
            , ( 14, "Item 7" )
            , ( 15, "Item 8" )
            , ( 16, "Item 9" )
            ]


menuAnchor : (Msg m -> m) -> Model -> Html m
menuAnchor lift model =
    let
        anchorMargin =
            { top =
                Maybe.withDefault 0 (Result.toMaybe (String.toFloat model.topMargin))
            , left =
                Maybe.withDefault 0 (Result.toMaybe (String.toFloat model.leftMargin))
            , bottom =
                Maybe.withDefault 0 (Result.toMaybe (String.toFloat model.bottomMargin))
            , right =
                Maybe.withDefault 0 (Result.toMaybe (String.toFloat model.rightMargin))
            }
    in
    styled Html.div
    [ cs "mdc-menu-anchor"
    , css "margin" "16px"
    , css "position" "absolute"
    , model.position
      |> List.map (\ c ->
           if c == "middle" then
               css "top" "35%"
           else
               css c "0"
         )
      |> Options.many
    ]
    [ Button.render (Mdl >> lift) [1] model.mdl
      [ Button.raised
      , Button.primary
      , Menu.attach (Mdl >> lift) [2]
      ]
      [ text <|
        case model.anchorWidth of
            Small ->
                "Show"

            Comparable ->
                "Show Menu"

            Wider ->
                "Show Menu from here now!"
      ]

    , Menu.render (Mdl >> lift) [2] model.mdl
      [ Menu.anchorCorner model.anchorCorner
      , Menu.anchorMargin anchorMargin
      ]
      ( Menu.ul Lists.ul []
        ( menuItems model.menuSize
          |> List.map (\ ( index, label ) ->
               if label == "-" then
                   Menu.li Lists.divider [] []
               else
                   Menu.li Lists.li
                   [ Menu.onSelect (lift (Select (index, label)))
                   , Options.attribute (Html.tabindex 0)
                   ]
                   [ text label
                   ]
          )
        )
      )
    ]


view : (Msg m -> m) -> Page m -> Model -> Html m
view lift page model =
    page.body "Simple Menu"
    [
      Page.hero [] []
--      [ Menu.render (Mdl >> lift) [0] model.mdl
--        [ -- Menu.open
--        ]
--        ( Menu.ul Lists.ul []
--          [ Menu.li Lists.li []
--            [ text "Back"
--            ]
--          , Menu.li Lists.li []
--            [ text "Forward"
--            ]
--          , Menu.li Lists.li []
--            [ text "Reload"
--            ]
--          , Menu.li Lists.divider [] []
--          , Menu.li Lists.li []
--            [ text "Help & Feedback"
--            ]
--          , Menu.li Lists.li []
--            [ text "Settings"
--            ]
--          ]
--        )
--      ]

    , styled Html.div
      [ cs "demo-content"
      , css "position" "relative"
      , css "flex" "1"
      , css "top" "64px"
      ]
      [ styled Html.div []
        [
          menuAnchor lift model
        ]
      ,
        demoControls lift model
      ]
    ]


demoControls : (Msg m -> m) -> Model -> Html m
demoControls lift model =
    styled Html.div
    [ cs "demo-controls-container"
    , css "width" "100%"
    , css "height" "calc(100vh - 80px)"
    ]
    [ styled Html.div
      [ cs "demo-controls"
      , css "width" "360px"
      , css "margin-left" "auto"
      , css "margin-right" "auto"
      ]
      [
        buttonPositions lift model
      ,
        defaultMenuPosition lift model
      ,
        Html.p [] [ text "Anchor Margins" ]
      ,
        marginInputs lift model
      ,
        Html.p [] []
      ,
        styled Html.div []
        [
          styled Html.label
          [
          ]
          [
            Html.input
            [ Html.type_ "checkbox"
            , Html.checked model.rtl
            , Html.on "click" (Json.succeed (lift ToggleRtl))
            ]
            []
          ,
            text " "
          ,
            text "RTL"
          ]
        ]
      ,
        styled Html.div []
        [
          styled Html.label
          [
          ]
          [
            Html.input
            [ Html.type_ "checkbox"
            , Html.checked model.rememberSelectedItem
            , Html.on "click" (Json.succeed (lift ToggleRememberSelectedItem))
            ]
            []
          ,
            text " "
          ,
            text "Remember Selected Item"
          ]
        ]
      ,
        styled Html.div []
        [
          styled Html.label
          [
          ]
          [
            Html.input
            [ Html.type_ "checkbox"
            , Html.checked (not model.openAnimation)
            , Html.on "click" (Json.succeed (lift ToggleOpenAnimation))
            ]
            []
          ,
            text " "
          ,
            text "Disable open animation"
          ]
        ]
      ,
        Html.p [] []
      ,
        menuSizes lift model
      ,
        anchorWidths lift model
      ,
        Html.p [] []
      ,
        Html.hr [] []
      ,
        Html.div []
        [ Html.span []
          [ text "Last Selected item: "
          ]
        , Html.em []
          [ text <|
            case model.selected of
                Just ( index, label ) ->
                    "\"" ++ label ++ "\" at index " ++ toString index
                Nothing ->
                    "<none selected>"
          ]
        ]
      ]
    ]


buttonPositions : (Msg m -> m) -> Model -> Html m
buttonPositions lift model =
    styled Html.div
    [ css "display" "inline-block"
    , css "vertical-align" "top"
    ]
    ( List.concat
      [
        [ text "Button Position:"
        ]
      ,
        [ { label = "Top left", position = [ "top", "left" ] }
        , { label = "Top right", position = [ "top", "right" ] }
        , { label = "Middle left", position = [ "middle", "left" ] }
        , { label = "Middle right", position = [ "middle", "right" ] }
        , { label = "Bottom left", position = [ "bottom", "left" ] }
        , { label = "Bottom right", position = [ "bottom", "right" ] }
        ]
        |> List.map (\ { label, position } ->
             styled Html.div []
             [ styled Html.label []
               [ Html.input
                 [ Html.type_ "radio"
                 , Html.checked (model.position == position)
                 , Html.on "click" (Json.succeed (lift (SetPosition position)))
                 ]
                 []
               ,
                 text " "
               ,
                 text label
               ]
             ]
           )
      ]
    )


defaultMenuPosition : (Msg m -> m) -> Model -> Html m
defaultMenuPosition lift model =
    styled Html.div
    [ css "display" "inline-block"
    , css "vertical-align" "top"
    , css "margin-left" "2rem"
    ]
    ( List.concat
      [
        [ text "Default Menu Position:"
        ]
      ,
        [ { label = "Top start", anchorCorner = Menu.topStartCorner }
        , { label = "Top end", anchorCorner = Menu.topEndCorner }
        , { label = "Bottom start", anchorCorner = Menu.bottomStartCorner }
        , { label = "Bottom end", anchorCorner = Menu.bottomEndCorner }
        ]
        |> List.map (\ { label, anchorCorner } ->
             styled Html.div []
             [ styled Html.label []
               [ Html.input
                 [ Html.type_ "radio"
                 , Html.checked (model.anchorCorner == anchorCorner)
                 , Html.on "click" (Json.succeed (lift (SetAnchorCorner anchorCorner)))
                 ]
                 []
               ,
                 text " "
               ,
                 text label
               ]
             ]
           )
      ]
    )


marginInputs : (Msg m -> m) -> Model -> Html m
marginInputs lift model =
    styled Html.div []
    (
      [ { label = "T", msg = SetTopMargin, value = .topMargin }
      , { label = "B", msg = SetBottomMargin, value = .bottomMargin }
      , { label = "L", msg = SetLeftMargin, value = .leftMargin }
      , { label = "R", msg = SetRightMargin, value = .rightMargin }
      ]
      |> List.map (\ { label, msg, value } ->
           styled Html.label []
           [
             text (label ++ ":")
           ,
             text " "
           ,
             styled Html.input
             [ Options.many << List.map Options.attribute <|
               [ Html.type_ "text"
               , Html.size 3
               , Html.maxlength 3
               , Html.value (value model)
               ]
             , css "width" "2rem"
             , Options.on "change" (Json.map (lift << msg) Html.targetValue)
             ]
             []
           ]
         )
      |> List.intersperse (text " ")
    )


menuSizes : (Msg m -> m) -> Model -> Html m
menuSizes lift model =
    styled Html.div
    [ css "display" "inline-block"
    , css "vertical-align" "top"
    ]
    ( List.concat
      [
        [ text "Menu Sizes:"
        ]
      ,
        ( [ { label = "Regular menu", size = Regular }
          , { label = "Large menu", size = Large }
          , { label = "Extra tall menu", size = ExtraTall }
          ]
          |> List.map (\ { label, size } ->
               styled Html.div []
               [
                 styled Html.label []
                 [
                   Html.input
                   [ Html.type_ "radio"
                   , Html.checked (model.menuSize == size)
                   , Html.on "click" (Json.succeed (lift (SetMenuSize size)))
                   ]
                   []
                 ,
                   text " "
                 ,
                   text label
                 ]
               ]
             )
        )
      ]
    )


anchorWidths : (Msg m -> m) -> Model -> Html m
anchorWidths lift model =
    styled Html.div
    [ css "display" "inline-block"
    , css "vertical-align" "top"
    , css "margin-left" "2rem"
    ]
    ( List.concat
      [
        [ text "Anchor Widths:"
        ]
      ,
        ( [ { label = "Small button", width = Small }
          , { label = "Comparable to menu", width = Comparable }
          , { label = "Wider than menu", width = Wider }
          ]
          |> List.map (\ { label, width } ->
               styled Html.div []
               [
                 styled Html.label []
                 [
                   Html.input
                   [ Html.type_ "radio"
                   , Html.checked (model.anchorWidth == width)
                   , Html.on "click" (Json.succeed (lift (SetAnchorWidth width)))
                   ]
                   []
                 ,
                   text " "
                 ,
                   text label
                 ]
               ]
             )
        )
      ]
    )


subscriptions : (Msg m -> m) -> Model -> Sub m
subscriptions lift model =
    Menu.subs (Mdl >> lift) model.mdl
