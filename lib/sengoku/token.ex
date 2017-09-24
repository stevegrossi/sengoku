defmodule Sengoku.Token do
  def new(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.encode16(case: :lower)
  end
end
