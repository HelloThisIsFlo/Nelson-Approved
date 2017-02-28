defmodule NelsonApproved.NelsonApprovedMock do
  @behaviour NelsonApproved.Behaviour

  @spec approved?(String.t) :: :approved | :not_approved | :unknown
  def approved?(_food) do
    # Send back the first message from the inbox
    receive do
      result_from_test ->
        result_from_test
    end
  end

end
