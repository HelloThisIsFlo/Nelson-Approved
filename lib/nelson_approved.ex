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
    database_resp =
      food
      |> String.downcase
      |> String.trim
      |> find_one_by_name
      |> is_approved?

    if database_resp == :unknown do
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
    else
      Logger.debug("Found in Database! | Food: " <> food)
      %Response{approved?: database_resp, using_ai?: false}
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
