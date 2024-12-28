defmodule EcampusWeb.QuizLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.QuizzesFixtures
  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.AccountsFixtures

  @create_attrs %{
    description: "some description",
    title: "some title",
    questions_per_attempt: 42,
    lesson_id: nil
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    questions_per_attempt: 43,
    lesson_id: nil
  }
  @invalid_attrs %{description: nil, title: nil, questions_per_attempt: nil, lesson_id: nil}

  defp create_lesson(_) do
    %{id: subject_id} = subject_fixture()
    lesson = lesson_fixture(%{subject_id: subject_id})
    %{lesson: lesson}
  end

  defp create_quiz(_) do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    quiz = quiz_fixture(%{lesson_id: lesson_id})
    %{quiz: quiz}
  end

  setup %{conn: conn} do
    user = user_fixture(%{role: :admin})
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_quiz, :create_lesson]

    test "lists all quizzes", %{conn: conn, quiz: quiz} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes")

      assert html =~ "Listing Quizzes"
      assert html =~ quiz.title
    end

    test "saves new quiz", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons/#{lesson.id}/quizzes")

      assert index_live |> element("a", "New Quiz") |> render_click() =~
               "New Quiz"

      assert_patch(index_live, ~p"/admin/lessons/#{lesson.id}/quizzes/new")

      assert index_live
             |> form("#quiz-form", quiz: %{@invalid_attrs | lesson_id: lesson.id})
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quiz-form", quiz: %{@create_attrs | lesson_id: lesson.id})
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lessons/#{lesson.id}/quizzes")

      html = render(index_live)
      assert html =~ "Quiz created successfully"
      assert html =~ @create_attrs.title
    end

    test "updates quiz in listing", %{conn: conn, quiz: quiz} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes")

      assert index_live |> element("#quizzes-#{quiz.id} a", "Edit") |> render_click() =~
               "Edit Quiz"

      assert_patch(index_live, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz}/edit")

      assert index_live
             |> form("#quiz-form", quiz: %{@invalid_attrs | lesson_id: quiz.lesson_id})
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quiz-form", quiz: %{@update_attrs | lesson_id: quiz.lesson_id})
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes")

      html = render(index_live)
      assert html =~ "Quiz updated successfully"
      assert html =~ @update_attrs.title
    end

    test "deletes quiz in listing", %{conn: conn, quiz: quiz} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes")

      assert index_live |> element("#quizzes-#{quiz.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#quizzes-#{quiz.id}")
    end
  end

  describe "Show" do
    setup [:create_quiz]

    test "displays quiz", %{conn: conn, quiz: quiz} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz}")

      assert html =~ "Show Quiz"
      assert html =~ quiz.description
    end

    test "updates quiz within modal", %{conn: conn, quiz: quiz} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Quiz"

      assert_patch(show_live, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz}/show/edit")

      assert show_live
             |> form("#quiz-form", quiz: %{@invalid_attrs | lesson_id: quiz.lesson_id})
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#quiz-form", quiz: %{@update_attrs | lesson_id: quiz.lesson_id})
             |> render_submit()

      assert_patch(show_live, ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz}")

      html = render(show_live)
      assert html =~ "Quiz updated successfully"
      assert html =~ "some updated description"
    end
  end
end
