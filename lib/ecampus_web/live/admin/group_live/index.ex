defmodule EcampusWeb.GroupLive.Index do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Groups
  alias Ecampus.Groups.Group

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"speciality_id" => speciality_id} = params, url, socket) do
    parsed = URI.parse(url)
    full_path = parsed.path <> if(parsed.query, do: "?" <> parsed.query, else: "")

    {:noreply,
     socket
     |> assign(:speciality_id, speciality_id)
     |> apply_action(socket.assigns.live_action, params, full_path)}
  end

  defp apply_action(socket, :edit, %{"id" => id}, _full_path) do
    socket
    |> assign(:page_title, dgettext("groups", "Edit Group"))
    |> assign(:group, Groups.get_group!(id))
  end

  defp apply_action(socket, :new, _params, _full_path) do
    socket
    |> assign(:page_title, dgettext("groups", "New Group"))
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
  def handle_info({EcampusWeb.GroupLive.FormComponent, {:saved, group}}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
  end
end
