defmodule EcampusWeb.LessonLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.AccountsFixtures

  @create_attrs %{
    title: "some title",
    topic: "some topic",
    objectives: "some objectives",
    is_draft: true,
    hours_count: 42,
    sort_order: 42,
    subject_id: nil
  }
  @update_attrs %{
    title: "some updated title",
    topic: "some updated topic",
    objectives: "some updated objectives",
    is_draft: false,
    hours_count: 43,
    sort_order: 43,
    subject_id: nil
  }
  @invalid_attrs %{
    title: nil,
    topic: nil,
    objectives: nil,
    is_draft: false,
    hours_count: nil,
    sort_order: nil
  }

  defp create_subject(_) do
    subject = subject_fixture()
    %{subject: subject}
  end

  defp create_lesson(_) do
    %{id: subject_id} = subject_fixture()
    lesson = lesson_fixture(%{subject_id: subject_id})
    %{lesson: lesson}
  end

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_lesson, :create_subject]

    test "lists all lessons", %{conn: conn, lesson: lesson} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/lessons")

      assert html =~ "Listing Lessons"
      assert html =~ lesson.title
    end

    test "saves new lesson", %{conn: conn, subject: %{id: subject_id}} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons")

      assert index_live |> element("a", "New Lesson") |> render_click() =~
               "New Lesson"

      assert_patch(index_live, ~p"/admin/lessons/new")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lesson-form", lesson: %{@create_attrs | subject_id: subject_id})
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lessons")

      html = render(index_live)
      assert html =~ "Lesson created successfully"
      assert html =~ "some title"
    end

    test "updates lesson in listing", %{conn: conn, lesson: lesson, subject: %{id: subject_id}} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons")

      assert index_live |> element("#lessons-#{lesson.id} a", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(index_live, ~p"/admin/lessons/#{lesson}/edit")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lesson-form", lesson: %{@update_attrs | subject_id: subject_id})
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lessons")

      html = render(index_live)
      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons")

      assert index_live |> element("#lessons-#{lesson.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lessons-#{lesson.id}")
    end
  end

  describe "Show" do
    setup [:create_lesson, :create_subject]

    test "displays lesson", %{conn: conn, lesson: lesson} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/lessons/#{lesson}")

      assert html =~ "Show Lesson"
      assert html =~ lesson.title
    end

    test "updates lesson within modal", %{conn: conn, lesson: lesson, subject: %{id: subject_id}} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/lessons/#{lesson}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(show_live, ~p"/admin/lessons/#{lesson}/show/edit")

      assert show_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#lesson-form", lesson: %{@update_attrs | subject_id: subject_id})
             |> render_submit()

      assert_patch(show_live, ~p"/admin/lessons/#{lesson}")

      html = render(show_live)
      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated title"
    end
  end
end
