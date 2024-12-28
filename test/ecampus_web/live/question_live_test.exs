defmodule EcampusWeb.QuestionLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.QuizzesFixtures
  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.AccountsFixtures
  import Ecampus.QuizzesFixtures

  @create_attrs %{
    type: :multiple,
    title: "some title",
    subtitle: "some subtitle",
    grade: 42,
    show_correct_answer: true,
    quiz_id: nil
  }
  @update_attrs %{
    type: :multiple,
    title: "some updated title",
    subtitle: "some updated subtitle",
    grade: 43,
    show_correct_answer: false,
    quiz_id: nil
  }
  @invalid_attrs %{type: nil, title: nil, subtitle: nil, grade: nil, show_correct_answer: false}

  defp create_quiz(_) do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    quiz = quiz_fixture(%{lesson_id: lesson_id})
    %{quiz: quiz}
  end

  defp create_question(_) do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    %{id: quiz_id} = quiz_fixture(%{lesson_id: lesson_id})
    question = question_fixture(%{quiz_id: quiz_id})
    %{question: question}
  end

  setup %{conn: conn} do
    user = user_fixture(%{role: :admin})
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_question, :create_quiz]

    test "lists all questions", %{conn: conn, question: question} do
      {:ok, _index_live, html} =
        live(
          conn,
          ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions"
        )

      assert html =~ "Listing Questions"
      assert html =~ question.title
    end

    test "saves new question", %{conn: conn, quiz: quiz} do
      {:ok, index_live, _html} =
        live(
          conn,
          ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz.id}/questions"
        )

      assert index_live |> element("a", "New Question") |> render_click() =~
               "New Question"

      assert_patch(
        index_live,
        ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz.id}/questions/new"
      )

      assert index_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question-form", question: %{@create_attrs | quiz_id: quiz.id})
             |> render_submit()

      assert_patch(
        index_live,
        ~p"/admin/lessons/#{quiz.lesson_id}/quizzes/#{quiz.id}/questions"
      )

      html = render(index_live)
      assert html =~ "Question created successfully"
      assert html =~ "some title"
    end

    test "updates question in listing", %{conn: conn, question: question} do
      {:ok, index_live, _html} =
        live(
          conn,
          ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions"
        )

      assert index_live |> element("#questions-#{question.id} a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(
        index_live,
        ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions/#{question}/edit"
      )

      assert index_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question-form", question: %{@update_attrs | quiz_id: question.quiz.id})
             |> render_submit()

      assert_patch(
        index_live,
        ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz.id}/questions"
      )

      html = render(index_live)
      assert html =~ "Question updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes question in listing", %{conn: conn, question: question} do
      {:ok, index_live, _html} =
        live(
          conn,
          ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions"
        )

      assert index_live |> element("#questions-#{question.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#questions-#{question.id}")
    end
  end

  describe "Show" do
    setup [:create_question]

    test "displays question", %{conn: conn, question: question} do
      {:ok, _show_live, html} =
        live(
          conn,
          ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions/#{question}"
        )

      assert html =~ "Show Question"
      assert html =~ question.title
    end

    test "updates question within modal", %{conn: conn, question: question} do
      {:ok, show_live, _html} =
        live(
          conn,
          ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions/#{question}"
        )

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(
        show_live,
        ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions/#{question}/show/edit"
      )

      assert show_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#question-form", question: %{@update_attrs | quiz_id: question.quiz.id})
             |> render_submit()

      assert_patch(
        show_live,
        ~p"/admin/lessons/#{question.quiz.lesson_id}/quizzes/#{question.quiz_id}/questions/#{question}"
      )

      html = render(show_live)
      assert html =~ "Question updated successfully"
      assert html =~ "some updated title"
    end
  end
end
