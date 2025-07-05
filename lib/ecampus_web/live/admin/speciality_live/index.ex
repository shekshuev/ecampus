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
  def handle_params(params, url, socket) do
    parsed = URI.parse(url)
    full_path = parsed.path <> if(parsed.query, do: "?" <> parsed.query, else: "")

    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params, full_path)}
  end

  defp apply_action(socket, :edit, %{"id" => id}, _full_path) do
    socket
    |> assign(:page_title, dgettext("specialities", "Edit"))
    |> assign(:speciality, Specialities.get_speciality!(id))
  end

  defp apply_action(socket, :new, _params, _full_path) do
    socket
    |> assign(:page_title, dgettext("specialities", "New"))
    |> assign(:speciality, %Speciality{})
  end

  defp apply_action(socket, :index, params, full_path) do
    {specialities, meta} = Specialities.list_specialities(params)

    socket
    |> assign(:meta, meta)
    |> assign(:current_path, full_path)
    |> stream(:specialities, specialities, reset: true)
    |> assign(:page_title, dgettext("specialities", "Listing Specialities"))
    |> assign(:speciality, nil)
  end

  @impl true
  def handle_info({EcampusWeb.SpecialityLive.FormComponent, {:saved, speciality}}, socket) do
    {:noreply, stream_insert(socket, :specialities, speciality)}
  end
end
