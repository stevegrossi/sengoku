defmodule Sengoku.Token do

  @doc """
  Returns a random hex string of binary length n. The hex length will be double that.
  """
  def new(n) do
    n
    |> :crypto.strong_rand_bytes
    |> Base.encode16(case: :lower)
  end
end
