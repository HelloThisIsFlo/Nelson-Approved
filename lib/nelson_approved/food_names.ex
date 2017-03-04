defmodule NelsonApproved.FoodNames do

  @food_names_file Application.fetch_env!(:nelson_approved, :food_names_file)

  def start_link do
    Agent.start_link(&load_food_names/0, name: __MODULE__)
  end

  def all_food_names do
    Agent.get(__MODULE__, &(&1))
  end

  def load_food_names do
    @food_names_file
    |> File.read!()
    |> String.split()
  end

end
