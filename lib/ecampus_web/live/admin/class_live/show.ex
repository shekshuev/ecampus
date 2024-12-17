defmodule EcampusWeb.ClassLive.Show do
  use EcampusWeb, :live_view

  alias Ecampus.Classes
  alias Ecampus.Groups
  alias Ecampus.Lessons

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:lessons, Lessons.list_lessons())
     |> assign(:groups, Groups.list_groups())
     |> assign(:class, Classes.get_class(id))}
  end

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
