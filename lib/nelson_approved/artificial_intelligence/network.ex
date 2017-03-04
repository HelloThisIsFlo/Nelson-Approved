defmodule NelsonApproved.ArtificialIntelligence.Network do

  defmodule Behaviour do
    @type word :: String.t
    @callback semantic_relatedness(word, word) :: number
  end

  @behaviour Behaviour

  @spec semantic_relatedness(String.t, String.t) :: number
  def semantic_relatedness(word1, word2) do
    0.7
  end


end
