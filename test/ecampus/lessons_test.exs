defmodule Ecampus.LessonsTest do
  use Ecampus.DataCase

  alias Ecampus.Lessons
  alias Ecampus.Lessons.Lesson

  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures

  describe "lessons" do
    @invalid_attrs %{
      title: nil,
      topic: nil,
      objectives: nil,
      is_draft: nil,
      hours_count: nil,
      sort_order: nil
    }

    test "list_lessons/0 returns all lessons" do
      lesson = create_lesson()
      assert Lessons.list_lessons() == [lesson]
    end

    test "get_lesson!/1 returns the lesson with given id" do
      lesson = create_lesson()
      assert Lessons.get_lesson!(lesson.id) == lesson
    end

    test "create_lesson/1 with valid data creates a lesson" do
      %{id: subject_id} = subject_fixture()

      valid_attrs = %{
        title: "some title",
        topic: "some topic",
        objectives: "some objectives",
        is_draft: true,
        hours_count: 42,
        sort_order: 42,
        subject_id: subject_id
      }

      assert {:ok, %Lesson{} = lesson} = Lessons.create_lesson(valid_attrs)
      assert lesson.title == valid_attrs.title
      assert lesson.topic == valid_attrs.topic
      assert lesson.objectives == valid_attrs.objectives
      assert lesson.is_draft == valid_attrs.is_draft
      assert lesson.hours_count == valid_attrs.hours_count
      assert lesson.sort_order == valid_attrs.sort_order
      assert lesson.subject_id == subject_id
    end

    test "create_lesson/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson(@invalid_attrs)
    end

    test "update_lesson/2 with valid data updates the lesson" do
      lesson = create_lesson()
      %{id: subject_id} = subject_fixture()

      update_attrs = %{
        title: "some updated title",
        topic: "some updated topic",
        objectives: "some updated objectives",
        is_draft: false,
        hours_count: 43,
        sort_order: 43,
        subject_id: subject_id
      }

      assert {:ok, %Lesson{} = lesson} = Lessons.update_lesson(lesson, update_attrs)
      assert lesson.title == update_attrs.title
      assert lesson.topic == update_attrs.topic
      assert lesson.objectives == update_attrs.objectives
      assert lesson.is_draft == update_attrs.is_draft
      assert lesson.hours_count == update_attrs.hours_count
      assert lesson.sort_order == update_attrs.sort_order
    end

    test "update_lesson/2 with invalid data returns error changeset" do
      lesson = create_lesson()
      assert {:error, %Ecto.Changeset{}} = Lessons.update_lesson(lesson, @invalid_attrs)
      assert lesson == Lessons.get_lesson!(lesson.id)
    end

    test "delete_lesson/1 deletes the lesson" do
      lesson = create_lesson()
      assert {:ok, %Lesson{}} = Lessons.delete_lesson(lesson)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson!(lesson.id) end
    end

    test "change_lesson/1 returns a lesson changeset" do
      lesson = create_lesson()
      assert %Ecto.Changeset{} = Lessons.change_lesson(lesson)
    end
  end

  defp create_lesson() do
    %{id: subject_id} = subject_fixture()
    lesson_fixture(%{subject_id: subject_id})
  end
end
