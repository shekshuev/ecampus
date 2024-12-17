defmodule EcampusWeb.SpecialityLiveTest do
  use EcampusWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecampus.SpecialitiesFixtures
  import Ecampus.AccountsFixtures

  @create_attrs %{code: "some code", description: "some description", title: "some title"}
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    title: "some updated title"
  }
  @invalid_attrs %{code: nil, description: nil, title: nil}

  defp create_speciality(_) do
    speciality = speciality_fixture()
    %{speciality: speciality}
  end

  setup %{conn: conn} do
    user = user_fixture(%{role: :admin})
    conn = log_in_user(conn, user)

    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_speciality]

    test "lists all specialities", %{conn: conn, speciality: speciality} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/specialities")

      assert html =~ "Listing Specialities"
      assert html =~ speciality.code
    end

    test "saves new speciality", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/specialities")

      assert index_live |> element("a", "New Speciality") |> render_click() =~
               "New Speciality"

      assert_patch(index_live, ~p"/admin/specialities/new")

      assert index_live
             |> form("#speciality-form", speciality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#speciality-form", speciality: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/specialities")

      html = render(index_live)
      assert html =~ "Speciality created successfully"
      assert html =~ "some code"
    end

    test "updates speciality in listing", %{conn: conn, speciality: speciality} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/specialities")

      assert index_live |> element("#specialities-#{speciality.id} a", "Edit") |> render_click() =~
               "Edit Speciality"

      assert_patch(index_live, ~p"/admin/specialities/#{speciality}/edit")

      assert index_live
             |> form("#speciality-form", speciality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#speciality-form", speciality: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/specialities")

      html = render(index_live)
      assert html =~ "Speciality updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes speciality in listing", %{conn: conn, speciality: speciality} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/specialities")

      assert index_live |> element("#specialities-#{speciality.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#specialities-#{speciality.id}")
    end
  end

  describe "Show" do
    setup [:create_speciality]

    test "displays speciality", %{conn: conn, speciality: speciality} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/specialities/#{speciality}")

      assert html =~ "Show Speciality"
      assert html =~ speciality.code
    end

    test "updates speciality within modal", %{conn: conn, speciality: speciality} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/specialities/#{speciality}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Speciality"

      assert_patch(show_live, ~p"/admin/specialities/#{speciality}/show/edit")

      assert show_live
             |> form("#speciality-form", speciality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#speciality-form", speciality: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/specialities/#{speciality}")

      html = render(show_live)
      assert html =~ "Speciality updated successfully"
      assert html =~ "some updated code"
    end
  end
end
