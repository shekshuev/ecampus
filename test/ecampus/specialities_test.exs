defmodule Ecampus.SpecialitiesTest do
  use Ecampus.DataCase

  alias Ecampus.Specialities

  describe "specialities" do
    alias Ecampus.Specialities.Speciality

    import Ecampus.SpecialitiesFixtures

    @invalid_attrs %{code: nil, description: nil, title: nil}

    test "list_specialities/0 returns all specialities" do
      speciality = speciality_fixture()
      assert Specialities.list_specialities() == [speciality]
    end

    test "get_speciality!/1 returns the speciality with given id" do
      speciality = speciality_fixture()
      assert Specialities.get_speciality!(speciality.id) == speciality
    end

    test "create_speciality/1 with valid data creates a speciality" do
      valid_attrs = %{code: "some code", description: "some description", title: "some title"}

      assert {:ok, %Speciality{} = speciality} = Specialities.create_speciality(valid_attrs)
      assert speciality.code == "some code"
      assert speciality.description == "some description"
      assert speciality.title == "some title"
    end

    test "create_speciality/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Specialities.create_speciality(@invalid_attrs)
    end

    test "update_speciality/2 with valid data updates the speciality" do
      speciality = speciality_fixture()

      update_attrs = %{
        code: "some updated code",
        description: "some updated description",
        title: "some updated title"
      }

      assert {:ok, %Speciality{} = speciality} =
               Specialities.update_speciality(speciality, update_attrs)

      assert speciality.code == "some updated code"
      assert speciality.description == "some updated description"
      assert speciality.title == "some updated title"
    end

    test "update_speciality/2 with invalid data returns error changeset" do
      speciality = speciality_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Specialities.update_speciality(speciality, @invalid_attrs)

      assert speciality == Specialities.get_speciality!(speciality.id)
    end

    test "delete_speciality/1 deletes the speciality" do
      speciality = speciality_fixture()
      assert {:ok, %Speciality{}} = Specialities.delete_speciality(speciality)
      assert_raise Ecto.NoResultsError, fn -> Specialities.get_speciality!(speciality.id) end
    end

    test "change_speciality/1 returns a speciality changeset" do
      speciality = speciality_fixture()
      assert %Ecto.Changeset{} = Specialities.change_speciality(speciality)
    end
  end
end
