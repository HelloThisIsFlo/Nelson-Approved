defmodule NelsonApproved.ArtificialIntelligence do
  alias NelsonApproved.Repo
  alias NelsonApproved.KeyValue

  @call_counter_key "CALL_COUNTER"
  @call_counter_limit 3000
  @semantic_approved_thres 0.8
  @semantic_not_approved_thres 0.5
  @network_ai Application.fetch_env!(:nelson_approved, :network_ai_module)

  @spec is_processed_food?(String.t) :: boolean | :unknown | :too_many_calls
  def is_processed_food?(food) do
    if check_and_increment_counter() do
      ask_ai(food)
    else
      :too_many_calls
    end
  end

  defp ask_ai(food) do
    do_ask_ai(@network_ai.semantic_relatedness(food, "processed food"))
  end
  defp do_ask_ai(relatedness) when relatedness > @semantic_approved_thres, do: true
  defp do_ask_ai(relatedness) when relatedness < @semantic_not_approved_thres, do: false
  defp do_ask_ai(_), do: :unknown


  defp check_and_increment_counter do
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
