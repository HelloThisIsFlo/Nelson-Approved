defmodule NelsonApproved do
  alias NelsonApproved.Food
  alias NelsonApproved.Repo
  import Ecto.Query

  defmodule Behaviour do
    @callback approved?(String.t) :: :approved | :not_approved | :unknown
    @callback find_closest_match(String.t, [String.t]) :: String.t
  end

  @behaviour NelsonApproved.Behaviour

  @spec approved?(String.t) :: :approved | :not_approved | :unknown
  def approved?(food) when is_bitstring(food) do
    food
    |> String.downcase
    |> String.trim
    |> find_one_by_name
    |> is_approved?
  end

  @spec find_one_by_name(String.t) :: %Food{} | :not_found
  defp find_one_by_name(name) do
    Food
    |> where([f], f.name == ^name)
    |> Repo.one
  end

  defp is_approved?(%Food{approved: true}),  do: :approved
  defp is_approved?(%Food{approved: false}), do: :not_approved
  defp is_approved?(_),                      do: :unknown

  @spec find_closest_match(String.t, [String.t]) :: String.t
  def find_closest_match(food_name, all_food_names) do
    all_food_names
    |> Enum.max_by(&String.jaro_distance(&1, food_name))
  end

end
