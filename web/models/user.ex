defmodule NelsonApproved.User do
  use NelsonApproved.Web, :model
  alias Ecto.Changeset

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :pass_hash, :string
    field :admin, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password, :pass_hash, :admin])
    |> validate_required([:username, :password, :admin])
    |> validate_length(:username, min: 3, max: 20)
    |> validate_length(:password, min: 5, max: 20)
    |> unique_constraint(:username)
    |> hash_password()
  end

  defp hash_password(%Changeset{valid?: false} = changeset), do: changeset
  defp hash_password(%Changeset{changes: %{password: password}} = changeset) do
    hash = Comeonin.Bcrypt.hashpwsalt(password)
    put_change(changeset, :pass_hash, hash)
  end

end
