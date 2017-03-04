defmodule NelsonApproved.ArtificialIntelligence.Network do

  defmodule Behaviour do
    @type word :: String.t
    @callback semantic_relatedness(word, word) :: number
  end

end
