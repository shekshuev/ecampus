defmodule EcampusWeb.LessonLive.FormComponent do
  @moduledoc """
  LiveComponent for creating and editing lessons.

  Handles form rendering, validation, saving (create/update), and deletion
  of `Lesson` entities associated with a specific subject.
  """

  use EcampusWeb, :live_component
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Lessons
  alias Phoenix.LiveView.Socket

  @impl true
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="lesson-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label={dgettext("lessons", "Title")} />
        <.input field={@form[:topic]} type="text" label={dgettext("lessons", "Topic")} />
        <.input field={@form[:objectives]} type="text" label={dgettext("lessons", "Objectives")} />
        <.input field={@form[:is_draft]} type="checkbox" label={dgettext("lessons", "Is draft")} />
        <.input field={@form[:hours_count]} type="number" label={dgettext("lessons", "Hours count")} />
        <.input field={@form[:sort_order]} type="number" label={dgettext("lessons", "Sort order")} />
        <.input field={@form[:subject_id]} type="hidden" value={@subject_id} />
        <:actions>
          <.button phx-disable-with={dgettext("lessons", "Saving...")}>
            {dgettext("lessons", "Save")}
          </.button>
          <%= if @action == :edit do %>
            <.button
              phx-click="delete"
              phx-target={@myself}
              class="btn-error"
              type="button"
              data-confirm={dgettext("lessons", "Are you sure?")}
            >
              {dgettext("lessons", "Delete")}
            </.button>
          <% end %>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  @spec update(map(), Socket.t()) :: {:ok, Socket.t()}
  def update(%{lesson: lesson} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Lessons.change_lesson(lesson))
     end)}
  end

  @impl true
  @spec handle_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    changeset = Lessons.change_lesson(socket.assigns.lesson, lesson_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("delete", _params, socket) do
    case Lessons.delete_lesson(socket.assigns.lesson) do
      {:ok, _deleted} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("lessons", "Lesson deleted successfully"))
         |> push_navigate(to: ~p"/admin/subjects/#{socket.assigns.subject_id}/lessons")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, dgettext("lessons", "Failed to delete lesson"))
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  @spec save_lesson(Socket.t(), :new | :edit, map()) :: {:noreply, Socket.t()}
  defp save_lesson(socket, :edit, lesson_params) do
    case Lessons.update_lesson(socket.assigns.lesson, lesson_params) do
      {:ok, lesson} ->
        notify_parent({:saved, lesson})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("lessons", "Lesson updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_lesson(socket, :new, lesson_params) do
    case Lessons.create_lesson(lesson_params) do
      {:ok, lesson} ->
        notify_parent({:saved, lesson})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("lessons", "Lesson created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @spec notify_parent({:saved, Lessons.Lesson.t()}) :: :ok
  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
