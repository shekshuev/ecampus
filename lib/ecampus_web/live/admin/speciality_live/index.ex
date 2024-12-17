defmodule EcampusWeb.SpecialityLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Specialities
  alias Ecampus.Specialities.Speciality

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :specialities, Specialities.list_specialities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
