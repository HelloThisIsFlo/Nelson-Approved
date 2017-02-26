defmodule NelsonApproved do
  alias NelsonApproved.Food
  alias NelsonApproved.Repo
  import Ecto.Query

  @spec approved?(String.t) :: :approved | :not_approved | :unknown
  def approved?(food) do
    food
    |> find_one_by_name
    |> is_approved?
  end
  defp is_approved?(%Food{approved: true}),  do: :approved
  defp is_approved?(%Food{approved: false}), do: :not_approved
  defp is_approved?(_),                      do: :unknown

  @spec find_one_by_name(String.t) :: %Food{} | :not_found
  defp find_one_by_name(name) do
    Food
    |> where([f], f.name == ^name)
    |> Repo.one
  end

  def find_closest_match(food_name, all_food_names) do
    all_food_names
    |> Enum.max_by(&String.jaro_distance(&1, food_name))
  end

end
