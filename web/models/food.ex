defmodule NelsonApproved.Food do
  use NelsonApproved.Web, :model

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
  end
end
