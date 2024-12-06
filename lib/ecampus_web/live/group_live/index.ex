defmodule EcampusWeb.GroupLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Groups
  alias Ecampus.Groups.Group
  alias Ecampus.Specialities

  @impl true
  def mount(_params, _session, socket) do
    specialities = Specialities.list_specialities()

    {:ok,
     socket
     |> assign(:specialities, specialities)
     |> stream(:groups, Groups.list_groups())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Group")
    |> assign(:group, Groups.get_group!(id))
    |> assign(:specialities, Specialities.list_specialities())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Group")
    |> assign(:group, %Group{})
    |> assign(:specialities, Specialities.list_specialities())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Groups")
    |> assign(:group, nil)
  end

  @impl true
  def handle_info({EcampusWeb.GroupLive.FormComponent, {:saved, group}}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    group = Groups.get_group!(id)
    {:ok, _} = Groups.delete_group(group)

    {:noreply, stream_delete(socket, :groups, group)}
  end
end
