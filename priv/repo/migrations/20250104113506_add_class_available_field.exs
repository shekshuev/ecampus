defmodule Ecampus.Repo.Migrations.AddClassAvailableField do
  use Ecto.Migration

  def change do
    alter table(:classes) do
      add :available, :boolean, default: false, null: false
    end
  end
end
