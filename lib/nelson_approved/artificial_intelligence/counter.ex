defmodule NelsonApproved.ArtificialIntelligence.Counter do
  alias NelsonApproved.KeyValue
  alias NelsonApproved.Repo

  @call_counter_key "CALL_COUNTER"
  @call_counter_limit 3000

  @doc """
  Increment the counter and checks if the number of calls is above the limit
  """
  @spec increment_and_check_counter :: boolean
  def increment_and_check_counter do
    counter = Repo.get_by(KeyValue, %{key: @call_counter_key})
    increment_counter(counter)
    value(counter) < @call_counter_limit
  end

  defp increment_counter(nil) do
    %KeyValue{}
    |> KeyValue.changeset(%{key: @call_counter_key, value: 1})
    |> Repo.insert!()
  end
  defp increment_counter(counter) do
    counter
    |> KeyValue.changeset(%{value: value(counter) + 1})
    |> Repo.update!()
  end
  defp value(%KeyValue{value: val}), do: val
  defp value(_), do: 0

end
