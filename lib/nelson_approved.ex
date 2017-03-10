defmodule NelsonApproved do
  alias NelsonApproved.ArtificialIntelligence
  alias NelsonApproved.Food
  alias NelsonApproved.Repo
  alias NelsonApproved.User
  alias NelsonApproved.UserFood
  alias NelsonApproved.Response
  import Ecto.Query
  import Ecto
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

  @spec find_closest_match(String.t, [String.t]) :: String.t
  def find_closest_match(food_name, all_food_names) do
    all_food_names
    |> Enum.max_by(&String.jaro_distance(&1, food_name))
  end

  @spec approved?(String.t, %User{}) :: Response.t
  def approved?(food, user \\ nil) when is_bitstring(food) do
    if user do
      food =
        food
        |> String.downcase
        |> String.trim

      user_database_resp =
        assoc(user, :foods)
        |> where([f], f.name == ^food)
        |> Repo.one
        |> is_approved?()

      after_user_database(food, user_database_resp)
    else
      priv_approved?(food)
    end
  end

  defp after_user_database(food, is_approved?)
  defp after_user_database(food, :not_found) do
    priv_approved?(food)
  end
  defp after_user_database(food, is_approved?), do: %Response{approved?: is_approved?, using_ai?: false}


  @spec approved?(String.t) :: Response.t
  # TODO: Remove (or at least make private)
  defp priv_approved?(food) when is_bitstring(food) do

    # TODO: Remove
    food =
      food
      |> String.downcase
      |> String.trim

    is_food_name? = food in NelsonApproved.FoodNames.all_food_names()

    do_approved(food, is_food_name?, :not_fetched, :not_fetched)
  end

  defp do_approved(food, is_food_name?, database_value, ai_value)
  defp do_approved(   _, false, _, _),                     do: %Response{approved?: :unknown, using_ai?: false}
  defp do_approved(   _, true, :approved, _),              do: %Response{approved?: :approved, using_ai?: false}
  defp do_approved(   _, true, :not_approved, _),          do: %Response{approved?: :not_approved, using_ai?: false}
  defp do_approved(   _, true, :not_found, :approved),     do: %Response{approved?: :approved, using_ai?: true}
  defp do_approved(   _, true, :not_found, :not_approved), do: %Response{approved?: :not_approved, using_ai?: true}
  defp do_approved(   _, true, :not_found, :unknown),      do: %Response{approved?: :unknown, using_ai?: true}
  defp do_approved(food, true, :not_fetched, _) do
    database_resp =
      food
      |> find_one_by_name
      |> is_approved?

    log(food, database_resp, false)
    do_approved(food, true, database_resp, :not_fetched)
  end
  defp do_approved(food, true, :not_found, :not_fetched) do
    ai_value =
      ArtificialIntelligence.is_processed_food?(food)
      |> convert_ai_value()

    log(food, ai_value, true)
    do_approved(food, true, :not_found, ai_value)
  end


  # Convert approved values ###################################################
  defp is_approved?(%UserFood{approved: true}),  do: :approved
  defp is_approved?(%UserFood{approved: false}), do: :not_approved
  # defp is_approved?(_),                      do: :not_found

  defp is_approved?(%Food{approved: true}),  do: :approved
  defp is_approved?(%Food{approved: false}), do: :not_approved
  defp is_approved?(_),                      do: :not_found

  defp convert_ai_value(is_processed_food?)
  defp convert_ai_value(true),  do: :not_approved
  defp convert_ai_value(false), do: :approved
  defp convert_ai_value(_),     do: :unknown


  # Utility functions #########################################################
  @spec find_one_by_name(String.t) :: %Food{} | :not_found
  defp find_one_by_name(name) do
    Food
    |> where([f], f.name == ^name)
    |> Repo.one
  end

  defp log(food, :not_found, _) do
    Logger.info("Food: " <> food <> " | Not found in Database ... checking with AI")
  end
  defp log(food, approved?, using_ai?) do
    Logger.info("Food: " <> food <> " | Approved?: " <> to_string(approved?) <> " | Using_Ai?: " <> to_string(using_ai?))
  end

end
