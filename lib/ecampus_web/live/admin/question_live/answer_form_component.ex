defmodule EcampusWeb.QuestionLive.AnswerFormComponent do
  use EcampusWeb, :live_component

  alias Ecampus.Quizzes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="answer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:subtitle]} type="text" label="Subtitle" />
        <.input field={@form[:sort_order]} type="number" label="Sort order" />
        <.input field={@form[:is_correct]} type="checkbox" label="Is correct" />
        <%= if @question.type == :sequence do %>
          <.input field={@form[:sequence_order_number]} type="number" label="Sequence order number" />
        <% end %>

        <.input field={@form[:question_id]} type="hidden" value={@question.id} />

        <:actions>
          <.button phx-disable-with="Saving...">Save Answer</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{answer: answer} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Quizzes.change_answer(answer))
     end)}
  end

  @impl true
  def handle_event("validate", %{"answer" => answer_params}, socket) do
    changeset = Quizzes.change_answer(socket.assigns.answer, answer_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"answer" => answer_params}, socket) do
    save_question(socket, socket.assigns.action, answer_params)
  end

  defp save_question(socket, :edit_answer, answer_params) do
    case Quizzes.update_answer(socket.assigns.answer, answer_params) do
      {:ok, answer} ->
        notify_parent({:saved, answer})

        {:noreply,
         socket
         |> put_flash(:info, "Answer updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_question(socket, :new_answer, answer_params) do
    case Quizzes.create_answer(answer_params) do
      {:ok, answer} ->
        notify_parent({:saved, answer})

        {:noreply,
         socket
         |> put_flash(:info, "Answer created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
