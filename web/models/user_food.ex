defmodule NelsonApproved.UserFood do
  use NelsonApproved.Web, :model

  schema "user_foods" do
    field :name, :string
    field :approved, :boolean, default: true
    belongs_to :user, NelsonApproved.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :approved])
    |> validate_required([:name, :approved])
    |> unique_constraint(:name, name: :user_foods_user_id_name_index)
    |> sanitize_name()
    |> assoc_constraint(:user)
  end
  # Note on the unique constraint:
  # `user_foods_user_id_name_index` is the name of the constraint.
  # It needs to be specified because complex constraint names
  # cannot be inferred by ecto

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

  def all_for_user(user) do
    assoc(user, :foods)
  end

end
