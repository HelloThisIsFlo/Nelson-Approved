defmodule NelsonApproved do
  alias NelsonApproved.FoodNames
  alias NelsonApproved.Food
  alias NelsonApproved.Repo
  import Ecto.Query

  defmodule Behaviour do
    @callback approved?(String.t) :: :approved | :not_approved | :unknown
  end

  @behaviour NelsonApproved.Behaviour
  # Used to determine if a word is "similar enough" to another one.
  @similarity_threshold Application.fetch_env!(:nelson_approved, :similarity_threshold)

  @spec approved?(String.t) :: :approved | :not_approved | :unknown
  def approved?(food) do
    match = find_closest_match(food, FoodNames.all_food_names())
    dist = String.jaro_distance(food, match)

    if dist > @similarity_threshold do
      match
      |> find_one_by_name
      |> is_approved?
    else
      :unknown
    end
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

  def find_closest_match(food_name, all_food_names) do
    all_food_names
    |> Enum.max_by(&String.jaro_distance(&1, food_name))
  end

end
