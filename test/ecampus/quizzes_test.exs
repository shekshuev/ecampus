defmodule Ecampus.QuizzesTest do
  use Ecampus.DataCase

  alias Ecampus.Quizzes
  alias Ecampus.Quizzes.Quiz
  alias Ecampus.Quizzes.Question
  alias Ecampus.Quizzes.AnsweredQuestion

  import Ecampus.QuizzesFixtures
  import Ecampus.LessonsFixtures
  import Ecampus.SubjectsFixtures
  import Ecampus.AccountsFixtures

  describe "quizzes" do
    @invalid_attrs %{description: nil, title: nil, questions_per_attempt: nil, lesson_id: nil}

    test "list_quizzes/0 returns all quizzes" do
      quiz = create_quiz()
      {:ok, %{list: list}} = Quizzes.list_quizzes()
      assert list == [quiz]
    end

    test "list_all_quizzes/0 returns all quizzes" do
      quiz = create_quiz()
      list = Quizzes.list_all_quizzes()
      assert list == [quiz]
    end

    test "get_quiz/1 returns the quiz with given id" do
      quiz = create_quiz()
      assert Quizzes.get_quiz(quiz.id) == quiz
    end

    test "create_quiz/1 with valid data creates a quiz" do
      %{id: lesson_id} = create_lesson()

      valid_attrs = %{
        description: "some description",
        title: "some title",
        questions_per_attempt: 42,
        lesson_id: lesson_id,
        type: :quiz
      }

      assert {:ok, %Quiz{} = quiz} = Quizzes.create_quiz(valid_attrs)
      assert quiz.description == valid_attrs.description
      assert quiz.title == valid_attrs.title
      assert quiz.questions_per_attempt == valid_attrs.questions_per_attempt
      assert quiz.lesson_id == valid_attrs.lesson_id
    end

    test "create_quiz/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_quiz(@invalid_attrs)
    end

    test "update_quiz/2 with valid data updates the quiz" do
      quiz = create_quiz()
      %{id: lesson_id} = create_lesson()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        questions_per_attempt: 43,
        lesson_id: lesson_id,
        type: :quiz
      }

      assert {:ok, %Quiz{} = quiz} = Quizzes.update_quiz(quiz, update_attrs)
      assert quiz.description == update_attrs.description
      assert quiz.title == update_attrs.title
      assert quiz.questions_per_attempt == update_attrs.questions_per_attempt
      assert quiz.lesson_id == update_attrs.lesson_id
    end

    test "update_quiz/2 with invalid data returns error changeset" do
      quiz = create_quiz()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_quiz(quiz, @invalid_attrs)
      assert quiz == Quizzes.get_quiz(quiz.id)
    end

    test "delete_quiz/1 deletes the quiz" do
      quiz = create_quiz()
      assert {:ok, %Quiz{}} = Quizzes.delete_quiz(quiz)
      assert nil == Quizzes.get_quiz(quiz.id)
    end

    test "change_quiz/1 returns a quiz changeset" do
      quiz = create_quiz()
      assert %Ecto.Changeset{} = Quizzes.change_quiz(quiz)
    end
  end

  describe "questions" do
    @invalid_attrs %{type: nil, title: nil, subtitle: nil, grade: nil, show_correct_answer: nil}

    test "list_questions/0 returns all questions" do
      question = create_question()
      {:ok, %{list: list}} = Quizzes.list_questions()
      assert list == [question]
    end

    test "get_question/1 returns the question with given id" do
      question = create_question()
      assert Quizzes.get_question(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      %{id: quiz_id} = create_quiz()

      valid_attrs = %{
        type: :multiple,
        title: "some title",
        subtitle: "some subtitle",
        grade: 42,
        show_correct_answer: true,
        quiz_id: quiz_id,
        sort_order: 0
      }

      assert {:ok, %Question{} = question} = Quizzes.create_question(valid_attrs)
      assert question.type == valid_attrs.type
      assert question.title == valid_attrs.title
      assert question.subtitle == valid_attrs.subtitle
      assert question.grade == valid_attrs.grade
      assert question.show_correct_answer == valid_attrs.show_correct_answer
      assert question.quiz_id == valid_attrs.quiz_id
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      %{id: quiz_id} = create_quiz()
      question = create_question()

      update_attrs = %{
        type: :multiple,
        title: "some updated title",
        subtitle: "some updated subtitle",
        grade: 43,
        show_correct_answer: false,
        quiz_id: quiz_id,
        sort_order: 0
      }

      assert {:ok, %Question{} = question} = Quizzes.update_question(question, update_attrs)
      assert question.type == update_attrs.type
      assert question.title == update_attrs.title
      assert question.subtitle == update_attrs.subtitle
      assert question.grade == update_attrs.grade
      assert question.show_correct_answer == update_attrs.show_correct_answer
      assert question.quiz_id == update_attrs.quiz_id
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = create_question()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_question(question, @invalid_attrs)
      assert question == Quizzes.get_question(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = create_question()
      assert {:ok, %Question{}} = Quizzes.delete_question(question)
      assert nil == Quizzes.get_question(question.id)
    end

    test "change_question/1 returns a question changeset" do
      question = create_question()
      assert %Ecto.Changeset{} = Quizzes.change_question(question)
    end
  end

  describe "answers" do
    alias Ecampus.Quizzes.Answer

    import Ecampus.QuizzesFixtures

    @invalid_attrs %{title: nil, subtitle: nil, is_correct: nil, sequence_order_number: nil}

    test "list_answers/0 returns all answers" do
      answer = create_answer()
      assert Quizzes.list_answers() == [answer]
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = create_answer()
      assert Quizzes.get_answer(answer.id) == answer
    end

    test "create_answer/1 with valid data creates a answer" do
      %{id: question_id} = create_question()

      valid_attrs = %{
        title: "some title",
        subtitle: "some subtitle",
        is_correct: true,
        sequence_order_number: 42,
        question_id: question_id,
        sort_order: 0
      }

      assert {:ok, %Answer{} = answer} = Quizzes.create_answer(valid_attrs)
      assert answer.title == valid_attrs.title
      assert answer.subtitle == valid_attrs.subtitle
      assert answer.is_correct == valid_attrs.is_correct
      assert answer.sequence_order_number == valid_attrs.sequence_order_number
      assert answer.question_id == valid_attrs.question_id
    end

    test "create_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_answer(@invalid_attrs)
    end

    test "update_answer/2 with valid data updates the answer" do
      %{id: question_id} = create_question()
      answer = create_answer()

      update_attrs = %{
        title: "some updated title",
        subtitle: "some updated subtitle",
        is_correct: false,
        sequence_order_number: 43,
        question_id: question_id,
        sort_order: 0
      }

      assert {:ok, %Answer{} = answer} = Quizzes.update_answer(answer, update_attrs)
      assert answer.title == update_attrs.title
      assert answer.subtitle == update_attrs.subtitle
      assert answer.is_correct == update_attrs.is_correct
      assert answer.sequence_order_number == update_attrs.sequence_order_number
      assert answer.question_id == update_attrs.question_id
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = create_answer()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_answer(answer, @invalid_attrs)
      assert answer == Quizzes.get_answer(answer.id)
    end

    test "delete_answer/1 deletes the answer" do
      answer = create_answer()
      assert {:ok, %Answer{}} = Quizzes.delete_answer(answer)
      assert nil == Quizzes.get_answer(answer.id)
    end

    test "change_answer/1 returns a answer changeset" do
      answer = create_answer()
      assert %Ecto.Changeset{} = Quizzes.change_answer(answer)
    end
  end

  describe "answered_questions" do
    test "list_answered_questions/0 returns all answered_questions" do
      answered_question = create_answered_question()
      assert Quizzes.list_answered_questions() == [answered_question]
    end

    test "get_answered_question!/1 returns the answered_question with given id" do
      answered_question = create_answered_question()

      assert Quizzes.get_answered_question(%{
               user_id: answered_question.user_id,
               question_id: answered_question.question_id,
               quiz_id: answered_question.quiz_id
             }) == answered_question
    end

    test "create_answered_question/1 with valid data creates a answered_question" do
      %{id: question_id} = create_question()
      %{id: user_id} = user_fixture()
      %{id: quiz_id} = create_quiz()

      valid_attrs = %{
        answer: %{},
        question_id: question_id,
        user_id: user_id,
        quiz_id: quiz_id
      }

      assert {:ok, %AnsweredQuestion{} = answered_question} =
               Quizzes.create_answered_question(valid_attrs)

      assert answered_question.answer == valid_attrs.answer
      assert answered_question.question_id == valid_attrs.question_id
      assert answered_question.user_id == valid_attrs.user_id
      assert answered_question.quiz_id == valid_attrs.quiz_id
    end

    test "change_answered_question/1 returns a answered_question changeset" do
      answered_question = create_answered_question()
      assert %Ecto.Changeset{} = Quizzes.change_answered_question(answered_question)
    end
  end

  defp create_lesson() do
    %{id: subject_id} = subject_fixture()
    lesson_fixture(%{subject_id: subject_id})
  end

  defp create_quiz() do
    %{id: lesson_id} = create_lesson()
    quiz_fixture(%{lesson_id: lesson_id})
  end

  defp create_question() do
    %{id: quiz_id} = create_quiz()
    question_fixture(%{quiz_id: quiz_id})
  end

  defp create_answer() do
    %{id: question_id} = create_question()
    answer_fixture(%{question_id: question_id})
  end

  defp create_answered_question() do
    %{id: question_id} = create_question()
    %{id: user_id} = user_fixture()
    %{id: quiz_id} = create_quiz()
    answered_question_fixture(%{question_id: question_id, user_id: user_id, quiz_id: quiz_id})
  end
end
