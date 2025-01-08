defmodule Ecampus.Repo.Migrations.AddSortOrderFieldToQuestionsAndAnswers do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :sort_order, :integer, default: 0, null: false
    end

    alter table(:answers) do
      add :sort_order, :integer, default: 0, null: false
    end
  end
end
