defmodule EcampusWeb.ClassLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Classes
  alias Ecampus.Classes.Class
  alias Ecampus.Groups
  alias Ecampus.Lessons

  @impl true
  def mount(params, _session, socket) do
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 10)

    {:ok, %{list: classes, pagination: pagination}} =
      Classes.list_classes(%{"page" => page, "page_size" => page_size})

    lessons = Lessons.list_lessons()
    groups = Groups.list_groups()

    {
      :ok,
      socket
      |> assign(:pagination, pagination)
      |> assign(:lessons, lessons)
      |> assign(:groups, groups)
      |> assign(:current_page, page)
      |> assign(:classes, classes |> Enum.map(fn class -> {"classes-#{class.id}", class} end))
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"page" => page, "page_size" => page_size} = params) do
    page = String.to_integer(page || "1")
    page_size = String.to_integer(page_size || "10")

    {:ok, %{list: classes, pagination: pagination}} =
      Classes.list_classes(%{"page" => page, "page_size" => page_size})

    socket
    |> assign(:page_title, "Listing Classes")
    |> assign(:pagination, pagination)
    |> assign(:current_page, page)
    |> assign(:params, params)
    |> assign(:classes, classes |> Enum.map(fn class -> {"classes-#{class.id}", class} end))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Class")
    |> assign(:class, Classes.get_class(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Class")
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Classes")
    |> assign(:class, nil)
  end

  @impl true
  def handle_info({EcampusWeb.ClassLive.FormComponent, {:saved, _}}, socket) do
    %{page_size: page_size, page: page} = Map.get(socket.assigns, :pagination)

    {:ok, %{list: classes, pagination: pagination}} =
      Classes.list_classes(%{"page" => page, "page_size" => page_size})

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:current_page, page)
     |> assign(:classes, classes |> Enum.map(fn class -> {"classes-#{class.id}", class} end))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    class = Classes.get_class(id)
    {:ok, _} = Classes.delete_class(class)

    %{page_size: page_size, page: page} = Map.get(socket.assigns, :pagination)

    {:ok, %{list: classes, pagination: pagination}} =
      Classes.list_classes(%{"page" => page, "page_size" => page_size})

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:current_page, page)
     |> assign(:classes, classes |> Enum.map(fn class -> {"classes-#{class.id}", class} end))}
  end

  defp pagination_pages(total_pages, current_page) do
    cond do
      total_pages <= 7 ->
        Enum.to_list(1..total_pages)

      current_page < 4 ->
        [1, 2, 3, 4, :ellipsis, total_pages - 1, total_pages]

      current_page > total_pages - 3 ->
        [1, 2, :ellipsis, total_pages - 3, total_pages - 2, total_pages - 1, total_pages]

      true ->
        [1, :ellipsis, current_page - 1, current_page, current_page + 1, :ellipsis, total_pages]
    end
  end
end
