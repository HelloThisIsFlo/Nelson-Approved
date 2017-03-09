defmodule NelsonApproved.ArtificialIntelligence do
  alias NelsonApproved.ArtificialIntelligence.Counter
  alias NelsonApproved.Repo

  @moduledoc """
  This module uses AI to determine if a given food is processed or not.

  In reality, it simply calculates the semantic(meaning) relatedness between the food name
  and the statement "processed food"

  It is very flaky. But fun to implement.
  """

  @related_thres Application.fetch_env!(:nelson_approved, :related_thres)
  @not_related_thres Application.fetch_env!(:nelson_approved, :not_related_thres)

  @network_ai Application.fetch_env!(:nelson_approved, :network_ai_module)
  @counter_ai Application.fetch_env!(:nelson_approved, :counter_ai_module)

  @spec is_processed_food?(String.t) :: boolean | :unknown | :too_many_calls
  def is_processed_food?(food) do
    if @counter_ai.increment_and_check_counter() do
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


end
