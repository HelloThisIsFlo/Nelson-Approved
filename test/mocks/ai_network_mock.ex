defmodule NelsonApproved.AiNetworkMock do
  @behaviour NelsonApproved.ArtificialIntelligence.Network.Behaviour

  @spec semantic_relatedness(String.t, String.t) :: number
  def semantic_relatedness(_, _) do
    send_back_first_message_from_inbox(:unknown)
  end

  defp send_back_first_message_from_inbox(default) do
    receive do
      result_from_test ->
        result_from_test
    after
      0 -> default
    end
  end
end
