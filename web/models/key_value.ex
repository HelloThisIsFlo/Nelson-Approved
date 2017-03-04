defmodule NelsonApproved.KeyValue do
  use NelsonApproved.Web, :model

  schema "key_values" do
    field :key, :string
    field :value, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :value])
    |> validate_required([:key, :value])
    |> unique_constraint(:key)
  end
end
