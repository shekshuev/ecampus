defmodule Backend.QuizzesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Quizzes` context.
  """

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        description: "some description",
        estimation: %{},
        title: "some title"
      })
      |> Backend.Quizzes.create_quiz()

    quiz
  end
end
