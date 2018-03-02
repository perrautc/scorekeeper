module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- model


type alias Model =
    { players : List Player
    , name : String
    , playerId : Maybe Int
    , plays : List Play
    }


type alias Player =
    { id : Int
    , name : String
    , points : Int
    }


type alias Play =
    { id : Int
    , playerId : Int
    , name : String
    , points : Int
    }


initModel : Model
initModel =
    { players = []
    , name = ""
    , playerId = Nothing
    , plays = []
    }



-- update


type Msg
    = Edit Player
    | Score Player Int
    | Input String
    | Save
    | Cancel
    | DeletePlay Play


update msg model =
    case msg of
        Input name ->
            { model | name = name }

        Cancel ->
            { model | name = "", playerId = Nothing }

        Edit player ->
            { model | name = player.name, playerId = Just player.id }

        Save ->
            if (String.isEmpty model.name) then
                model
            else
                save model

        Score player points ->
            score model player points

        DeletePlay play ->
            Debug.log "Deleting Play"
                deletePlay
                model
                play


deletePlay model play =
    let
        newPlays =
            List.filter (\p -> p.id /= play.id) model.plays

        newPlayers =
            List.map
                (\player ->
                    if player.id == play.playerId then
                        { player | points = player.points - 1 * player.points }
                    else
                        player
                )
                model.players
    in
        { model | plays = newPlays, players = newPlayers }


score model scorer points =
    let
        newPlayers =
            model.players
                |> List.map
                    (\player ->
                        if player.id == scorer.id then
                            { player
                                | points = player.points + points
                            }
                        else
                            player
                    )

        play =
            Play (List.length model.plays) scorer.id scorer.name points
    in
        { model | players = newPlayers, plays = play :: model.plays }


save model =
    case model.playerId of
        Just id ->
            edit model id

        Nothing ->
            add model


add model =
    let
        player =
            Player (List.length model.players) model.name 0

        newPlayers =
            player :: model.players
    in
        { model
            | players = newPlayers
            , name = ""
        }


edit model id =
    let
        newPlayers =
            List.map
                (\player ->
                    if player.id == id then
                        { player | name = model.name }
                    else
                        player
                )
                model.players

        newPlays =
            List.map
                (\play ->
                    if play.playerId == id then
                        { play | name = model.name }
                    else
                        play
                )
                model.plays
    in
        { model
            | players = newPlayers
            , plays = newPlays
            , name = ""
            , playerId = Nothing
        }



-- view


view model =
    div [ class "scoreboard" ]
        [ h1 [] [ text "Score Keeper" ]
        , playerSection model
        , playerForm model
        , playSection model
        ]


playSection model =
    div []
        [ playListHeader
        , playList model
        ]


playListHeader =
    header []
        [ div [] [ text "Plays" ]
        , div [] [ text "Points" ]
        ]


playList model =
    model.plays
        |> List.map play
        |> ul []


play play =
    li []
        [ i [ class "remove", onClick (DeletePlay play) ]
            []
        , div [] [ text play.name ]
        , div [] [ text (toString play.points) ]
        ]


playerSection model =
    div []
        [ playerListHeader
        , playerList model
        , pointTotal model
        ]


playerListHeader =
    header []
        [ div [] [ text "Name" ]
        , div [] [ text "Points" ]
        ]


playerList model =
    -- ul []
    --     (List.map player model.players)
    model.players
        |> List.sortBy .name
        |> List.map player
        |> ul []


player player =
    li []
        [ i [ class "edit", onClick (Edit player) ] []
        , div []
            [ text player.name ]
        , button
            [ type_ "button"
            , onClick (Score player 1)
            ]
            [ text "1pt" ]
        , button
            [ type_ "button"
            , onClick (Score player 2)
            ]
            [ text "2pts" ]
        , button
            [ type_ "button"
            , onClick (Score player 3)
            ]
            [ text "3pts" ]
        , div [] [ text (toString player.points) ]
        ]


pointTotal model =
    let
        total =
            List.map .points model.plays
                |> List.sum
    in
        footer []
            [ div [] [ text "Total:" ]
            , div [] [ text (toString total) ]
            ]


playerForm model =
    Html.form [ onSubmit Save ]
        [ input
            [ type_ "text"
            , placeholder "Add/Edit Player..."
            , onInput Input
            , value model.name
            ]
            []
        , button [ type_ "submit" ] [ text "Save" ]
        , button [ type_ "button", onClick Cancel ] [ text "Cancel" ]
        ]


main =
    Html.beginnerProgram
        { model = initModel
        , update = update
        , view = view
        }
