defmodule NelsonApproved.Repo.Migrations.CreateFood do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add :name, :string, null: false
      add :approved, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:foods, [:name])
  end
end
