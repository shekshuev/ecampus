defmodule Ecampus.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecampus.Groups` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> Ecampus.Groups.create_group()

    group
  end
end
