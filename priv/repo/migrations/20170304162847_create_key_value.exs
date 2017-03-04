defmodule NelsonApproved.Repo.Migrations.CreateKeyValue do
  use Ecto.Migration

  def change do
    create table(:key_values) do
      add :key, :string, null: false
      add :value, :integer, null: false

      timestamps()
    end

    create unique_index(:key_values, [:key])
  end
end
