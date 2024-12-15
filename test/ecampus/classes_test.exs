defmodule Ecampus.ClassesTest do
  use Ecampus.DataCase

  alias Ecampus.Classes
  alias Ecampus.Classes.Class

  import Ecampus.ClassesFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.LessonsFixtures
  import Ecampus.SpecialitiesFixtures
  import Ecampus.GroupsFixtures

  describe "classes" do
    @invalid_attrs %{begin_date: nil, end_date: nil, classroom: nil}

    test "list_classes/0 returns all classes" do
      class = create_class()
      {:ok, %{list: list}} = Classes.list_classes()
      assert list == [class]
    end

    test "get_class!/1 returns the class with given id" do
      class = create_class()
      assert Classes.get_class!(class.id) == class
    end

    test "create_class/1 with valid data creates a class" do
      %{id: lesson_id} = create_lesson()
      %{id: group_id} = create_group()

      valid_attrs = %{
        begin_date: ~U[2024-12-13 11:48:00Z],
        end_date: ~U[2024-12-13 11:48:00Z],
        classroom: "some classroom",
        lesson_id: lesson_id,
        group_id: group_id
      }

      assert {:ok, %Class{} = class} = Classes.create_class(valid_attrs)
      assert class.begin_date == valid_attrs.begin_date
      assert class.end_date == valid_attrs.end_date
      assert class.classroom == valid_attrs.classroom
      assert class.lesson_id == valid_attrs.lesson_id
      assert class.group_id == valid_attrs.group_id
    end

    test "create_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classes.create_class(@invalid_attrs)
    end

    test "update_class/2 with valid data updates the class" do
      class = create_class()
      %{id: lesson_id} = create_lesson()
      %{id: group_id} = create_group()

      update_attrs = %{
        begin_date: ~U[2024-12-14 11:48:00Z],
        end_date: ~U[2024-12-14 11:48:00Z],
        classroom: "some updated classroom",
        lesson_id: lesson_id,
        group_id: group_id
      }

      assert {:ok, %Class{} = class} = Classes.update_class(class, update_attrs)
      assert class.begin_date == update_attrs.begin_date
      assert class.end_date == update_attrs.end_date
      assert class.classroom == update_attrs.classroom
      assert class.lesson_id == update_attrs.lesson_id
      assert class.group_id == update_attrs.group_id
    end

    test "update_class/2 with invalid data returns error changeset" do
      class = create_class()
      assert {:error, %Ecto.Changeset{}} = Classes.update_class(class, @invalid_attrs)
      assert class == Classes.get_class!(class.id)
    end

    test "delete_class/1 deletes the class" do
      class = create_class()
      assert {:ok, %Class{}} = Classes.delete_class(class)
      assert_raise Ecto.NoResultsError, fn -> Classes.get_class!(class.id) end
    end

    test "change_class/1 returns a class changeset" do
      class = create_class()
      assert %Ecto.Changeset{} = Classes.change_class(class)
    end
  end

  defp create_lesson() do
    %{id: subject_id} = subject_fixture()
    lesson_fixture(%{subject_id: subject_id})
  end

  defp create_group() do
    %{id: speciality_id} = speciality_fixture()
    group_fixture(%{speciality_id: speciality_id})
  end

  defp create_class() do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    %{id: speciality_id} = speciality_fixture()
    %{id: group_id} = group_fixture(%{speciality_id: speciality_id})
    class_fixture(%{lesson_id: lesson_id, group_id: group_id})
  end
end
