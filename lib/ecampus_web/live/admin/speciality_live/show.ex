defmodule EcampusWeb.SpecialityLive.Show do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Specialities

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:speciality, Specialities.get_speciality!(id))}
  end

  defp page_title(:show), do: dgettext("specialities", "Show")
  defp page_title(:edit), do: dgettext("specialities", "Edit")
end
