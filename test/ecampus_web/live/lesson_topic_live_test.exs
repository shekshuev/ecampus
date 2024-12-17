defmodule EcampusWeb.LessonTopicLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.AccountsFixtures

  @create_attrs %{title: "some title", content: "some content", sort_order: 42, lesson_id: nil}
  @update_attrs %{
    title: "some updated title",
    content: "some updated content",
    sort_order: 43,
    lesson_id: nil
  }
  @invalid_attrs %{title: nil, content: nil, sort_order: nil, lesson_id: nil}

  defp create_lesson(_) do
    %{id: subject_id} = subject_fixture()
    lesson = lesson_fixture(%{subject_id: subject_id})
    %{lesson: lesson}
  end

  defp create_lesson_topic(_) do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    lesson_topic = lesson_topic_fixture(%{lesson_id: lesson_id})
    %{lesson_topic: lesson_topic}
  end

  setup %{conn: conn} do
    user = user_fixture(%{role: :admin})
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_lesson_topic, :create_lesson]

    test "lists all lesson_topics", %{conn: conn, lesson_topic: lesson_topic} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics")

      assert html =~ "Listing Lesson topics"
      assert html =~ lesson_topic.title
    end

    test "saves new lesson_topic", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons/#{lesson.id}/topics")

      assert index_live |> element("a", "New Lesson topic") |> render_click() =~
               "New Lesson topic"

      assert_patch(index_live, ~p"/admin/lessons/#{lesson.id}/topics/new")

      assert index_live
             |> form("#lesson_topic-form", lesson_topic: %{@invalid_attrs | lesson_id: lesson.id})
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lesson_topic-form", lesson_topic: %{@create_attrs | lesson_id: lesson.id})
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lessons/#{lesson.id}/topics")

      html = render(index_live)
      assert html =~ "Lesson topic created successfully"
      assert html =~ "some title"
    end

    test "updates lesson_topic in listing", %{
      conn: conn,
      lesson: lesson,
      lesson_topic: lesson_topic
    } do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics")

      assert index_live
             |> element("#lesson_topics-#{lesson_topic.id} a", "Edit")
             |> render_click() =~
               "Edit Lesson topic"

      assert_patch(
        index_live,
        ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics/#{lesson_topic.id}/edit"
      )

      assert index_live
             |> form("#lesson_topic-form",
               lesson_topic: %{@invalid_attrs | lesson_id: lesson_topic.lesson_id}
             )
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lesson_topic-form",
               lesson_topic: %{@update_attrs | lesson_id: lesson_topic.lesson_id}
             )
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics")

      html = render(index_live)
      assert html =~ "Lesson topic updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes lesson_topic in listing", %{conn: conn, lesson_topic: lesson_topic} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics")

      assert index_live
             |> element("#lesson_topics-#{lesson_topic.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#lesson_topics-#{lesson_topic.id}")
    end
  end

  describe "Show" do
    setup [:create_lesson_topic]

    test "displays lesson_topic", %{conn: conn, lesson_topic: lesson_topic} do
      {:ok, _show_live, html} =
        live(conn, ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics/#{lesson_topic.id}")

      assert html =~ "Show Lesson topic"
      assert html =~ lesson_topic.title
    end

    test "updates lesson_topic within modal", %{conn: conn, lesson_topic: lesson_topic} do
      {:ok, show_live, _html} =
        live(conn, ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics/#{lesson_topic.id}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Lesson topic"

      assert_patch(
        show_live,
        ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics/#{lesson_topic.id}/show/edit"
      )

      assert show_live
             |> form("#lesson_topic-form",
               lesson_topic: %{@invalid_attrs | lesson_id: lesson_topic.lesson_id}
             )
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#lesson_topic-form",
               lesson_topic: %{@update_attrs | lesson_id: lesson_topic.lesson_id}
             )
             |> render_submit()

      assert_patch(
        show_live,
        ~p"/admin/lessons/#{lesson_topic.lesson_id}/topics/#{lesson_topic.id}"
      )

      html = render(show_live)
      assert html =~ "Lesson topic updated successfully"
      assert html =~ "some updated title"
    end
  end
end
