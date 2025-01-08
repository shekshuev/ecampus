defmodule EcampusWeb.QuizLive.FormComponent do
  use EcampusWeb, :live_component

  alias Ecampus.Quizzes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="quiz-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Ecampus.Quizzes.Quiz, :type)}
        />
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:lesson_id]} type="hidden" value={@lesson_id} />
        <.input field={@form[:questions_per_attempt]} type="number" label="Questions per attempt" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Quiz</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{quiz: quiz} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Quizzes.change_quiz(quiz))
     end)}
  end

  @impl true
  def handle_event("validate", %{"quiz" => quiz_params}, socket) do
    changeset = Quizzes.change_quiz(socket.assigns.quiz, quiz_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"quiz" => quiz_params}, socket) do
    save_quiz(socket, socket.assigns.action, quiz_params)
  end

  defp save_quiz(socket, :edit, quiz_params) do
    case Quizzes.update_quiz(socket.assigns.quiz, quiz_params) do
      {:ok, quiz} ->
        notify_parent({:saved, quiz})

        {:noreply,
         socket
         |> put_flash(:info, "Quiz updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_quiz(socket, :new, quiz_params) do
    case Quizzes.create_quiz(quiz_params) do
      {:ok, quiz} ->
        notify_parent({:saved, quiz})

        {:noreply,
         socket
         |> put_flash(:info, "Quiz created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
