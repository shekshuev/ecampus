defmodule Ecampus.Repo.Migrations.AddCoverToSubjects do
  use Ecto.Migration

  def change do
    alter table(:subjects) do
      add :cover, :string
    end
  end
end
