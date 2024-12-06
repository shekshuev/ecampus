defmodule Ecampus.SubjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecampus.Subjects` context.
  """

  @doc """
  Generate a subject.
  """
  def subject_fixture(attrs \\ %{}) do
    {:ok, subject} =
      attrs
      |> Enum.into(%{
        description: "some description",
        objectives: "some objectives",
        prerequisites: "some prerequisites",
        required_texts: "some required_texts",
        short_title: "some short_title",
        title: "some title"
      })
      |> Ecampus.Subjects.create_subject()

    subject
  end
end
