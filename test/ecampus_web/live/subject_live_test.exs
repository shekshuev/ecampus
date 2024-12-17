defmodule EcampusWeb.SubjectLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.SubjectsFixtures
  import Ecampus.AccountsFixtures

  @create_attrs %{
    description: "some description",
    title: "some title",
    short_title: "some short_title",
    prerequisites: "some prerequisites",
    objectives: "some objectives",
    required_texts: "some required_texts"
  }
  @update_attrs %{
    description: "some updated description",
    title: "some updated title",
    short_title: "some updated short_title",
    prerequisites: "some updated prerequisites",
    objectives: "some updated objectives",
    required_texts: "some updated required_texts"
  }
  @invalid_attrs %{
    description: nil,
    title: nil,
    short_title: nil,
    prerequisites: nil,
    objectives: nil,
    required_texts: nil
  }

  defp create_subject(_) do
    subject = subject_fixture()
    %{subject: subject}
  end

  setup %{conn: conn} do
    user = user_fixture(%{role: :admin})
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_subject]

    test "lists all subjects", %{conn: conn, subject: subject} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/subjects")

      assert html =~ "Listing Subjects"
      assert html =~ subject.title
    end

    test "saves new subject", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/subjects")

      assert index_live |> element("a", "New Subject") |> render_click() =~
               "New Subject"

      assert_patch(index_live, ~p"/admin/subjects/new")

      assert index_live
             |> form("#subject-form", subject: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#subject-form", subject: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/subjects")

      html = render(index_live)
      assert html =~ "Subject created successfully"
      assert html =~ "some title"
    end

    test "updates subject in listing", %{conn: conn, subject: subject} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/subjects")

      assert index_live |> element("#subjects-#{subject.id} a", "Edit") |> render_click() =~
               "Edit Subject"

      assert_patch(index_live, ~p"/admin/subjects/#{subject}/edit")

      assert index_live
             |> form("#subject-form", subject: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#subject-form", subject: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/subjects")

      html = render(index_live)
      assert html =~ "Subject updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes subject in listing", %{conn: conn, subject: subject} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/subjects")

      assert index_live |> element("#subjects-#{subject.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#subjects-#{subject.id}")
    end
  end

  describe "Show" do
    setup [:create_subject]

    test "displays subject", %{conn: conn, subject: subject} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/subjects/#{subject}")

      assert html =~ "Show Subject"
      assert html =~ subject.description
    end

    test "updates subject within modal", %{conn: conn, subject: subject} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/subjects/#{subject}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Subject"

      assert_patch(show_live, ~p"/admin/subjects/#{subject}/show/edit")

      assert show_live
             |> form("#subject-form", subject: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#subject-form", subject: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/subjects/#{subject}")

      html = render(show_live)
      assert html =~ "Subject updated successfully"
      assert html =~ "some updated description"
    end
  end
end
