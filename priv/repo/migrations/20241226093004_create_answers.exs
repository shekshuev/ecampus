defmodule Ecampus.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :title, :string
      add :subtitle, :string
      add :is_correct, :boolean, default: false, null: false
      add :sequence_order_number, :integer, default: 0
      add :question_id, references(:questions, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:answers, [:question_id])
  end
end
