defmodule NelsonApproved.AiNetworkMock do
  @behaviour NelsonApproved.ArtificialIntelligence.Network.Behaviour

  @spec semantic_relatedness(String.t, String.t) :: number
  def semantic_relatedness(_, _) do
    get_mocked_value()
  end
  defp get_mocked_value(), do: Agent.get(__MODULE__, &(&1))


  # Mock related functions ####################################################
  def start_mock() do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def set_mocked_value(val) do
    Agent.update(__MODULE__, fn(_) -> val end)
  end

end
