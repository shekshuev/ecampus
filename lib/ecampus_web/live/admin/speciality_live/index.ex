defmodule EcampusWeb.SpecialityLive.Index do
  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Specialities
  alias Ecampus.Specialities.Speciality

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {specialities, meta} = Specialities.list_specialities(params)

    {:noreply,
     socket
     |> assign(:meta, meta)
     |> stream(:specialities, specialities, reset: true)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Speciality")
    |> assign(:speciality, Specialities.get_speciality!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Speciality")
    |> assign(:speciality, %Speciality{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Specialities")
    |> assign(:speciality, nil)
  end

  @impl true
  def handle_info({EcampusWeb.SpecialityLive.FormComponent, {:saved, speciality}}, socket) do
    {:noreply, stream_insert(socket, :specialities, speciality)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    speciality = Specialities.get_speciality!(id)
    {:ok, _} = Specialities.delete_speciality(speciality)

    {:noreply, stream_delete(socket, :specialities, speciality)}
  end
end
