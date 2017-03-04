defmodule NelsonApproved.AiNetworkMock do
  @behaviour NelsonApproved.ArtificialIntelligence.Network.Behaviour

  @spec semantic_relatedness(String.t, String.t) :: number
  def semantic_relatedness(_, _) do
    send_back_first_message_from_inbox()
  end

  defp send_back_first_message_from_inbox do
    receive do
      result_from_test ->
        result_from_test
    end
  end
end
