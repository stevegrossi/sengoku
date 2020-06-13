defmodule Mix.Tasks.Ai.Arena do
  @moduledoc """
  For playing AIs against each other.

      mix ai.arena
  """

  use Mix.Task

  alias Sengoku.{GameServer}

  @iterations 1000
  @game_opts %{"board" => "westeros"}

  def run([]) do
    Registry.start_link(keys: :unique, name: :game_server_registry)

    results =
      @iterations
      |> start_n_games()
      |> tally_winners()

    IO.puts "Player | Win % "
    IO.puts "-------|-------"
    Enum.each(results, fn({player_id, win_count}) ->
      win_percent = win_count / @iterations * 100
      player =
        case player_id do
          id when is_integer(id) -> Integer.to_string(id)
          nil -> "Tie"
        end
      IO.puts " #{String.pad_leading(player, 5)} | #{String.pad_leading(Float.to_string(Float.round(win_percent, 1)), 5)}%"
    end)
  end

  defp start_n_games(num) when is_integer(num) do
    Enum.map(1..num, fn(_) ->
      {:ok, game_id} = GameServer.new(@game_opts)
      GameServer.action(game_id, nil, %{type: "start_game"})
      game_id
    end)
  end

  defp tally_winners(game_ids) when is_list(game_ids) do
    Enum.reduce(game_ids, %{}, &tally_winner/2)
  end

  defp tally_winner(game_id, map) do
    winning_player = GameServer.get_state(game_id).winning_player
    Map.update(map, winning_player, 1, &(&1 + 1))
  end
end
