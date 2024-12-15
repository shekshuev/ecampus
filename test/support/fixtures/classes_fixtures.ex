defmodule Ecampus.ClassesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecampus.Classes` context.
  """

  @doc """
  Generate a class.
  """
  def class_fixture(attrs \\ %{}) do
    {:ok, class} =
      attrs
      |> Enum.into(%{
        begin_date: ~U[2024-12-13 11:48:00Z],
        classroom: "some classroom",
        end_date: ~U[2024-12-13 11:48:00Z]
      })
      |> Ecampus.Classes.create_class()

    class
  end
end
