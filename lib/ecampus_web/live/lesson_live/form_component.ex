defmodule EcampusWeb.LessonLive.FormComponent do
  use EcampusWeb, :live_component

  alias Ecampus.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage lesson records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="lesson-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:topic]} type="text" label="Topic" />
        <.input field={@form[:objectives]} type="text" label="Objectives" />
        <.input field={@form[:is_draft]} type="checkbox" label="Is draft" />
        <.input field={@form[:hours_count]} type="number" label="Hours count" />
        <.input field={@form[:sort_order]} type="number" label="Sort order" />
        <.input
          field={@form[:subject_id]}
          type="select"
          label="Subject"
          options={Enum.map(@subjects, &{&1.title, &1.id})}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Lesson</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{lesson: lesson} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Lessons.change_lesson(lesson))
     end)}
  end

  @impl true
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    changeset = Lessons.change_lesson(socket.assigns.lesson, lesson_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  defp save_lesson(socket, :edit, lesson_params) do
    case Lessons.update_lesson(socket.assigns.lesson, lesson_params) do
      {:ok, lesson} ->
        notify_parent({:saved, lesson})

        {:noreply,
         socket
         |> put_flash(:info, "Lesson updated successfully")
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
         |> put_flash(:info, "Lesson created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
