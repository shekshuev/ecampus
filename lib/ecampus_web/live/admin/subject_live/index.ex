defmodule EcampusWeb.SubjectLive.Index do
  @moduledoc """
  LiveView for managing the list of academic subjects.

  Handles rendering, listing, pagination, and form modal interactions
  for creating and editing `Subject` entities.
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Subjects
  alias Ecampus.Subjects.Subject

  @impl true
  @spec mount(map(), map(), Phoenix.LiveView.Socket.t()) ::
          {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end

  @impl true
  @spec handle_params(map(), String.t(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_params(params, url, socket) do
    parsed = URI.parse(url)
    full_path = parsed.path <> if(parsed.query, do: "?" <> parsed.query, else: "")

    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params, full_path)}
  end

  @spec apply_action(Phoenix.LiveView.Socket.t(), atom(), map(), String.t()) ::
          Phoenix.LiveView.Socket.t()
  defp apply_action(socket, :edit, %{"id" => id}, _full_path) do
    socket
    |> assign(:page_title, dgettext("subjects", "Edit"))
    |> assign(:subject, Subjects.get_subject!(id))
  end

  defp apply_action(socket, :new, _params, _full_path) do
    socket
    |> assign(:page_title, dgettext("subjects", "New"))
    |> assign(:subject, %Subject{})
  end

  defp apply_action(socket, :index, params, full_path) do
    {subjects, meta} = Subjects.list_subjects(params)

    socket
    |> assign(:meta, meta)
    |> assign(:current_path, full_path)
    |> stream(:subjects, subjects, reset: true)
    |> assign(:page_title, dgettext("subjects", "Listing Subjects"))
    |> assign(:subject, nil)
  end

  @impl true
  @spec handle_info({module(), {:saved, Subject.t()}}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({EcampusWeb.SubjectLive.FormComponent, {:saved, subject}}, socket) do
    {:noreply, stream_insert(socket, :subjects, subject)}
  end
end
