defmodule Ecampus.LessonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecampus.Lessons` context.
  """

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(attrs \\ %{}) do
    {:ok, lesson} =
      attrs
      |> Enum.into(%{
        hours_count: 42,
        is_draft: true,
        objectives: "some objectives",
        sort_order: 42,
        title: "some title",
        topic: "some topic"
      })
      |> Ecampus.Lessons.create_lesson()

    lesson
  end
end
