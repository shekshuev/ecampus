defmodule EcampusWeb.ClassLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.ClassesFixtures
  import Ecampus.GroupsFixtures
  import Ecampus.AccountsFixtures
  import Ecampus.LessonsFixtures
  import Ecampus.SpecialitiesFixtures
  import Ecampus.SubjectsFixtures

  @create_attrs %{
    begin_date: "2024-12-13T11:48:00Z",
    end_date: "2024-12-13T11:48:00Z",
    classroom: "some classroom"
  }
  @update_attrs %{
    begin_date: "2024-12-14T11:48:00Z",
    end_date: "2024-12-14T11:48:00Z",
    classroom: "some updated classroom"
  }
  @invalid_attrs %{begin_date: nil, end_date: nil, classroom: nil}

  defp create_lesson(_) do
    %{id: subject_id} = subject_fixture()
    lesson = lesson_fixture(%{subject_id: subject_id})
    %{lesson: lesson}
  end

  defp create_group(_) do
    %{id: speciality_id} = speciality_fixture()
    group = group_fixture(%{speciality_id: speciality_id})
    %{group: group}
  end

  defp create_class(_) do
    %{id: subject_id} = subject_fixture()
    %{id: lesson_id} = lesson_fixture(%{subject_id: subject_id})
    %{id: speciality_id} = speciality_fixture()
    %{id: group_id} = group_fixture(%{speciality_id: speciality_id})
    class = class_fixture(%{lesson_id: lesson_id, group_id: group_id})
    %{class: class}
  end

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_class]

    test "lists all classes", %{conn: conn, class: class} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/classes")

      assert html =~ "Listing Classes"
      assert html =~ class.classroom
    end

    test "saves new class", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/classes")

      assert index_live |> element("a", "New Class") |> render_click() =~
               "New Class"

      assert_patch(index_live, ~p"/admin/classes/new")

      assert index_live
             |> form("#class-form", class: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#class-form", class: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/classes")

      html = render(index_live)
      assert html =~ "Class created successfully"
      assert html =~ "some classroom"
    end

    test "updates class in listing", %{conn: conn, class: class} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/classes")

      assert index_live |> element("#classes-#{class.id} a", "Edit") |> render_click() =~
               "Edit Class"

      assert_patch(index_live, ~p"/admin/classes/#{class}/edit")

      assert index_live
             |> form("#class-form", class: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#class-form", class: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/classes")

      html = render(index_live)
      assert html =~ "Class updated successfully"
      assert html =~ "some updated classroom"
    end

    test "deletes class in listing", %{conn: conn, class: class} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/classes")

      assert index_live |> element("#classes-#{class.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#classes-#{class.id}")
    end
  end

  describe "Show" do
    setup [:create_class]

    test "displays class", %{conn: conn, class: class} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/classes/#{class}")

      assert html =~ "Show Class"
      assert html =~ class.classroom
    end

    test "updates class within modal", %{conn: conn, class: class} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/classes/#{class}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Class"

      assert_patch(show_live, ~p"/admin/classes/#{class}/show/edit")

      assert show_live
             |> form("#class-form", class: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#class-form", class: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/classes/#{class}")

      html = render(show_live)
      assert html =~ "Class updated successfully"
      assert html =~ "some updated classroom"
    end
  end
end
