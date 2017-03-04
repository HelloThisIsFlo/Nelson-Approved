defmodule NelsonApproved.ArtificialIntelligence do
  alias NelsonApproved.Repo
  alias NelsonApproved.KeyValue

  @call_counter_key "CALL_COUNTER"
  @call_counter_limit 3000

  @spec approved?(String.t) :: :approved | :not_approved | :unknown | :too_many_calls
  def approved?(food) do
    if check_and_increment_counter() do
      ask_ai(food)
    else
      :too_many_calls
    end
  end

  defp ask_ai(food) do
    
  end

  defp check_and_increment_counter do
    counter = Repo.get_by(KeyValue, %{key: @call_counter_key})
    increment_counter(counter)
    counter < @call_counter_limit
  end
  defp increment_counter(counter) do
    counter
    |> KeyValue.changeset(%{value: counter.value + 1})
    |> Repo.update!()
  end

end
