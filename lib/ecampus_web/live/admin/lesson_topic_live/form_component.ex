defmodule EcampusWeb.LessonTopicLive.FormComponent do
  use EcampusWeb, :live_component

  alias Ecampus.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="lesson_topic-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:sort_order]} type="number" label="Sort order" />
        <.input field={@form[:lesson_id]} type="hidden" value={@lesson_id} />
        <.input field={@form[:content]} type="textarea" class="w-full" label="Content" rows="12" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Lesson topic</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{lesson_topic: lesson_topic} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Lessons.change_lesson_topic(lesson_topic))
     end)}
  end

  @impl true
  def handle_event("validate", %{"lesson_topic" => lesson_topic_params}, socket) do
    changeset = Lessons.change_lesson_topic(socket.assigns.lesson_topic, lesson_topic_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"lesson_topic" => lesson_topic_params}, socket) do
    save_lesson_topic(socket, socket.assigns.action, lesson_topic_params)
  end

  defp save_lesson_topic(socket, :edit, lesson_topic_params) do
    case Lessons.update_lesson_topic(socket.assigns.lesson_topic, lesson_topic_params) do
      {:ok, lesson_topic} ->
        notify_parent({:saved, lesson_topic})

        {:noreply,
         socket
         |> put_flash(:info, "Lesson topic updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_lesson_topic(socket, :new, lesson_topic_params) do
    case Lessons.create_lesson_topic(lesson_topic_params) do
      {:ok, lesson_topic} ->
        notify_parent({:saved, lesson_topic})

        {:noreply,
         socket
         |> put_flash(:info, "Lesson topic created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
