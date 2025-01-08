defmodule Ecampus.Repo.Migrations.AddTypeFieldToQuiz do
  use Ecto.Migration

  def change do
    alter table(:quizzes) do
      add :type, :string, default: "quiz", null: false
    end
  end
end
