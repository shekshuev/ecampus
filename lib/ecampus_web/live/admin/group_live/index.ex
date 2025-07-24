defmodule EcampusWeb.GroupLive.Index do
  @moduledoc """
  LiveView for listing, creating, and editing academic groups tied to a speciality.

  Handles localization, pagination, loading group data, and interaction
  with the `FormComponent` for create/edit functionality.
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Groups
  alias Ecampus.Groups.Group
  alias Phoenix.LiveView.Socket

  @impl true
  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), String.t(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_params(%{"speciality_id" => speciality_id} = params, url, socket) do
    parsed = URI.parse(url)
    full_path = parsed.path <> if(parsed.query, do: "?" <> parsed.query, else: "")

    params = Map.update(params, "page_size", "10", fn existing -> existing end)

    {:noreply,
     socket
     |> assign(:speciality_id, speciality_id)
     |> apply_action(socket.assigns.live_action, params, full_path)}
  end

  @spec apply_action(Socket.t(), :index | :edit | :new, map(), String.t()) :: Socket.t()
  defp apply_action(socket, :edit, %{"id" => id}, _full_path) do
    socket
    |> assign(:page_title, dgettext("groups", "Edit"))
    |> assign(:group, Groups.get_group!(id))
  end

  defp apply_action(socket, :new, _params, _full_path) do
    socket
    |> assign(:page_title, dgettext("groups", "New"))
    |> assign(:group, %Group{})
  end

  defp apply_action(socket, :index, params, full_path) do
    {groups, meta} = Groups.list_groups(params)

    socket
    |> assign(:meta, meta)
    |> assign(:current_path, full_path)
    |> stream(:groups, groups, reset: true)
    |> assign(:page_title, dgettext("groups", "Listing Groups"))
    |> assign(:group, nil)
  end

  @impl true
  @spec handle_info({module(), {:saved, Group.t()}}, Socket.t()) :: {:noreply, Socket.t()}
  def handle_info({EcampusWeb.GroupLive.FormComponent, {:saved, group}}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
  end
end
