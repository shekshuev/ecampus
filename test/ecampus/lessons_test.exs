defmodule Ecampus.LessonsTest do
  use Ecampus.DataCase

  alias Ecampus.Lessons
  alias Ecampus.Lessons.Lesson
  alias Ecampus.Lessons.LessonTopic

  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.LessonsFixtures

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

  describe "lesson_topics" do
    @invalid_attrs %{title: nil, content: nil, sort_order: nil}

    test "list_lesson_topics/0 returns all lesson_topics" do
      lesson_topic = create_lesson_topic()
      {:ok, %{list: list}} = Lessons.list_lesson_topics()
      assert list == [lesson_topic]
    end

    test "get_lesson_topic!/1 returns the lesson_topic with given id" do
      lesson_topic = create_lesson_topic()
      assert Lessons.get_lesson_topic!(lesson_topic.id) == lesson_topic
    end

    test "create_lesson_topic/1 with valid data creates a lesson_topic" do
      %{id: lesson_id} = create_lesson()

      valid_attrs = %{
        title: "some title",
        content: "some content",
        sort_order: 42,
        lesson_id: lesson_id
      }

      assert {:ok, %LessonTopic{} = lesson_topic} = Lessons.create_lesson_topic(valid_attrs)
      assert lesson_topic.title == valid_attrs.title
      assert lesson_topic.content == valid_attrs.content
      assert lesson_topic.sort_order == valid_attrs.sort_order
      assert lesson_topic.lesson_id == valid_attrs.lesson_id
    end

    test "create_lesson_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson_topic(@invalid_attrs)
    end

    test "update_lesson_topic/2 with valid data updates the lesson_topic" do
      lesson_topic = create_lesson_topic()
      %{id: lesson_id} = create_lesson()

      update_attrs = %{
        title: "some updated title",
        content: "some updated content",
        sort_order: 43,
        lesson_id: lesson_id
      }

      assert {:ok, %LessonTopic{} = lesson_topic} =
               Lessons.update_lesson_topic(lesson_topic, update_attrs)

      assert lesson_topic.title == update_attrs.title
      assert lesson_topic.content == update_attrs.content
      assert lesson_topic.sort_order == update_attrs.sort_order
      assert lesson_topic.lesson_id == update_attrs.lesson_id
    end

    test "update_lesson_topic/2 with invalid data returns error changeset" do
      lesson_topic = create_lesson_topic()

      assert {:error, %Ecto.Changeset{}} =
               Lessons.update_lesson_topic(lesson_topic, @invalid_attrs)

      assert lesson_topic == Lessons.get_lesson_topic!(lesson_topic.id)
    end

    test "delete_lesson_topic/1 deletes the lesson_topic" do
      lesson_topic = create_lesson_topic()
      assert {:ok, %LessonTopic{}} = Lessons.delete_lesson_topic(lesson_topic)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson_topic!(lesson_topic.id) end
    end

    test "change_lesson_topic/1 returns a lesson_topic changeset" do
      lesson_topic = create_lesson_topic()
      assert %Ecto.Changeset{} = Lessons.change_lesson_topic(lesson_topic)
    end
  end

  defp create_lesson() do
    %{id: subject_id} = subject_fixture()
    lesson_fixture(%{subject_id: subject_id})
  end

  defp create_lesson_topic() do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    lesson_topic_fixture(%{lesson_id: lesson_id})
  end
end
