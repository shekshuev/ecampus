defmodule Ecampus.SpecialitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecampus.Specialities` context.
  """

  @doc """
  Generate a speciality.
  """
  def speciality_fixture(attrs \\ %{}) do
    {:ok, speciality} =
      attrs
      |> Enum.into(%{
        code: "some code",
        description: "some description",
        title: "some title"
      })
      |> Ecampus.Specialities.create_speciality()

    speciality
  end
end
