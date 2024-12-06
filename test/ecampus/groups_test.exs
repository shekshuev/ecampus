defmodule Ecampus.GroupsTest do
  use Ecampus.DataCase

  alias Ecampus.Groups
  alias Ecampus.Groups.Group

  import Ecampus.GroupsFixtures
  import Ecampus.SpecialitiesFixtures

  describe "groups" do
    @invalid_attrs %{description: nil, title: nil, speciality_id: nil}

    test "list_groups/0 returns all groups" do
      group = create_group()
      assert Groups.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = create_group()
      assert Groups.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      %{id: speciality_id} = create_speciality()

      valid_attrs = %{
        description: "some description",
        title: "some title",
        speciality_id: speciality_id
      }

      assert {:ok, %Group{} = group} = Groups.create_group(valid_attrs)
      assert group.description == valid_attrs.description
      assert group.title == valid_attrs.title
      assert group.speciality_id == valid_attrs.speciality_id
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = create_group()
      %{id: speciality_id} = create_speciality()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        speciality_id: speciality_id
      }

      assert {:ok, %Group{} = group} = Groups.update_group(group, update_attrs)
      assert group.description == update_attrs.description
      assert group.title == update_attrs.title
      assert group.speciality_id == update_attrs.speciality_id
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = create_group()
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, @invalid_attrs)
      assert group == Groups.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = create_group()
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = create_group()
      assert %Ecto.Changeset{} = Groups.change_group(group)
    end
  end

  def create_speciality() do
    speciality_fixture()
  end

  def create_group() do
    speciality = speciality_fixture()
    group_fixture(%{speciality_id: speciality.id})
  end
end
