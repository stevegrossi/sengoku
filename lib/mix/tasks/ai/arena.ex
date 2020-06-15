defmodule Mix.Tasks.Ai.Arena do
  @moduledoc """
  For playing AIs against each other.

      mix ai.arena
  """

  use Mix.Task

  alias Sengoku.{GameServer}

  @games_to_play 2_000
  @max_turns 1_000
  @game_opts %{"board" => "westeros"}
  @default_ai Sengoku.AI.Smart
  @custom_ai_player_number 1

  def run([ai_name]) do
    Registry.start_link(keys: :unique, name: :game_server_registry)
    ai_module = String.to_existing_atom("Elixir.#{ai_name}")

    IO.puts """
    Starting #{@games_to_play} games with #{inspect(ai_module)} as Player 1
    against #{inspect(@default_ai)} as all other players
    """

    results =
      @games_to_play
      |> start_n_games(ai_module)
      |> tally_winners()

    IO.puts "Player | Win % "
    IO.puts "-------|-------"
    Enum.each(results, fn({player_id, win_count}) ->
      win_percent = win_count / @games_to_play * 100
      player =
        case player_id do
          id when is_integer(id) -> Integer.to_string(id)
          nil -> "Draw"
        end
      IO.puts " #{String.pad_leading(player, 5)} | #{String.pad_leading(Float.to_string(Float.round(win_percent, 1)), 5)}%"
    end)
  end

  defp start_n_games(num, ai_module) when is_integer(num) do
    Enum.map(1..num, fn(_) ->
      {:ok, game_id} = GameServer.new(@game_opts, true)
      GameServer.update_ai_player(game_id, @custom_ai_player_number, ai_module)
      GameServer.action(game_id, nil, %{type: "start_game"})
      game_id
    end)
  end

  defp tally_winners(game_ids) when is_list(game_ids) do
    Enum.reduce(game_ids, %{}, &tally_winner/2)
  end

  defp tally_winner(game_id, results) do
    game_state = GameServer.get_state(game_id)
    winning_player = game_state.winning_player
    if is_nil(winning_player) && game_state.turn < @max_turns do
      Process.sleep(1_000)
      tally_winner(game_id, results)
    else
      Map.update(results, winning_player, 1, &(&1 + 1))
    end
  end
end
