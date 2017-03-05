defmodule NelsonApproved do
  alias NelsonApproved.ArtificialIntelligence
  alias NelsonApproved.Food
  alias NelsonApproved.Repo
  import Ecto.Query
  require Logger

  defmodule Behaviour do
    @callback approved?(String.t) :: Response.t
    @callback find_closest_match(String.t, [String.t]) :: String.t
  end

  defmodule Response do
    @type t :: %__MODULE__{
      approved?: :approved | :not_approved | :unknown,
      using_ai?: boolean
    }
    defstruct [:approved?,
               :using_ai?]
  end

  @behaviour NelsonApproved.Behaviour

  @spec approved?(String.t) :: Response.t
  def approved?(food) when is_bitstring(food) do
    food =
      food
      |> String.downcase
      |> String.trim

    is_food_name? = food in NelsonApproved.FoodNames.all_food_names()

    do_approved(food, is_food_name?, :not_fetched, :not_fetched)
  end

  defp do_approved(food, is_food_name?, database_value, ai_value)
  defp do_approved(   _, false, _, _),                   do: %Response{approved?: :unknown, using_ai?: false}
  defp do_approved(   _, true, :approved, _),            do: %Response{approved?: :approved, using_ai?: false}
  defp do_approved(   _, true, :not_approved, _),        do: %Response{approved?: :not_approved, using_ai?: false}
  defp do_approved(   _, true, :unknown, :approved),     do: %Response{approved?: :approved, using_ai?: true}
  defp do_approved(   _, true, :unknown, :not_approved), do: %Response{approved?: :not_approved, using_ai?: true}
  defp do_approved(food, true, :not_fetched, _) do
    database_resp =
      food
      |> find_one_by_name
      |> is_approved?
    do_approved(food, true, database_resp, :not_fetched)
  end
  defp do_approved(food, true, :unknown, :not_fetched) do
    Logger.debug("Not Found in Database! | Food: " <> food)
    case ArtificialIntelligence.is_processed_food?(food) do
      true ->
        Logger.debug("AI Disapproved! | Food: " <> food)
        %Response{approved?: :not_approved, using_ai?: true}
      false ->
        Logger.debug("AI Approved! | Food: " <> food)
        %Response{approved?: :approved, using_ai?: true}
      _ ->
        Logger.debug("AI Has no idea! | Food: " <> food)
        %Response{approved?: :unknown, using_ai?: true}
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

  @spec find_closest_match(String.t, [String.t]) :: String.t
  def find_closest_match(food_name, all_food_names) do
    all_food_names
    |> Enum.max_by(&String.jaro_distance(&1, food_name))
  end

end
