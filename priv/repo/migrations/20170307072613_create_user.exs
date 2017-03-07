defmodule NelsonApproved.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :pass_hash, :string, null: false
      add :admin, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:users, :username)
  end
end
