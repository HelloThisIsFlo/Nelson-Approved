defmodule NelsonApproved.Repo.Migrations.CreateUserFood do
  use Ecto.Migration

  def change do
    create table(:user_foods) do
      add :name, :string, null: false
      add :approved, :boolean, default: true, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end
    create index(:user_foods, [:user_id])
    create unique_index(:user_foods, [:user_id, :name])

  end
end
