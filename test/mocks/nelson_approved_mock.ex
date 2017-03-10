defmodule NelsonApproved.NelsonApprovedMock do
  alias NelsonApproved.User
  @behaviour NelsonApproved.Behaviour

  @spec approved?(String.t, %User{}) :: Response.t
  def approved?(_food, _user) do
    send_back_first_message_from_inbox(nil)
  end

  @spec find_closest_match(String.t, [String.t]) :: String.t
  def find_closest_match(_, _) do
    send_back_first_message_from_inbox(nil)
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
