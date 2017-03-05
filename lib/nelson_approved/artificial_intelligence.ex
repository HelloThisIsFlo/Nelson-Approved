defmodule NelsonApproved.ArtificialIntelligence do
  alias NelsonApproved.Repo
  alias NelsonApproved.KeyValue

  @moduledoc """
  This module uses AI to determine if a given food is processed or not.

  In reality, it simply calculates the semantic(meaning) relatedness between the food name
  and the statement "processed food"

  It is very flaky. But fun to implement.
  """

  @call_counter_key "CALL_COUNTER"
  @call_counter_limit 3000

  @related_thres Application.fetch_env!(:nelson_approved, :related_thres)
  @not_related_thres Application.fetch_env!(:nelson_approved, :not_related_thres)

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
    @network_ai.semantic_relatedness(food, "processed food")
    |> are_related_enough?()
  end
  defp are_related_enough?(:error), do: :unknown
  defp are_related_enough?(relatedness) when relatedness > @related_thres, do: true
  defp are_related_enough?(relatedness) when relatedness < @not_related_thres, do: false
  defp are_related_enough?(_), do: :unknown

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
