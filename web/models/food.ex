defmodule NelsonApproved.Food do
  use NelsonApproved.Web, :model
  alias NelsonApproved.FoodNames

  schema "foods" do
    field :name, :string
    field :approved, :boolean, default: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :approved])
    |> validate_required([:name, :approved])
    |> unique_constraint(:name)
    |> sanitize_name()
    |> validate_inclusion(:name, FoodNames.all_food_names(), message: "is not a food name")
  end

  defp sanitize_name(changeset =
    %Ecto.Changeset{
      valid?: true,
      changes: %{name: name}
    }) do

    name =
      name
      |> String.downcase
      |> String.trim

    put_change(changeset, :name, name)
  end
  defp sanitize_name(changeset), do: changeset

end
