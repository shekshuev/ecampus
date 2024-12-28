defmodule EcampusWeb.QuestionLive.FormComponent do
  use EcampusWeb, :live_component

  alias Ecampus.Quizzes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="question-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Ecampus.Quizzes.Question, :type)}
        />
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:subtitle]} type="text" label="Subtitle" />
        <.input field={@form[:grade]} type="number" label="Grade" />
        <.input field={@form[:quiz_id]} type="hidden" value={@quiz_id} />
        <.input field={@form[:show_correct_answer]} type="checkbox" label="Show correct answer" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Question</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{question: question} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Quizzes.change_question(question))
     end)}
  end

  @impl true
  def handle_event("validate", %{"question" => question_params}, socket) do
    changeset = Quizzes.change_question(socket.assigns.question, question_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"question" => question_params}, socket) do
    save_question(socket, socket.assigns.action, question_params)
  end

  defp save_question(socket, :edit, question_params) do
    case Quizzes.update_question(socket.assigns.question, question_params) do
      {:ok, question} ->
        notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_question(socket, :new, question_params) do
    case Quizzes.create_question(question_params) do
      {:ok, question} ->
        notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
