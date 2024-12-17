defmodule EcampusWeb.SubjectLive.FormComponent do
  use EcampusWeb, :live_component

  alias Ecampus.Subjects

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="subject-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:short_title]} type="text" label="Short title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:prerequisites]} type="text" label="Prerequisites" />
        <.input field={@form[:objectives]} type="text" label="Objectives" />
        <.input field={@form[:required_texts]} type="text" label="Required texts" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subject</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subject: subject} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Subjects.change_subject(subject))
     end)}
  end

  @impl true
  def handle_event("validate", %{"subject" => subject_params}, socket) do
    changeset = Subjects.change_subject(socket.assigns.subject, subject_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"subject" => subject_params}, socket) do
    save_subject(socket, socket.assigns.action, subject_params)
  end

  defp save_subject(socket, :edit, subject_params) do
    case Subjects.update_subject(socket.assigns.subject, subject_params) do
      {:ok, subject} ->
        notify_parent({:saved, subject})

        {:noreply,
         socket
         |> put_flash(:info, "Subject updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_subject(socket, :new, subject_params) do
    case Subjects.create_subject(subject_params) do
      {:ok, subject} ->
        notify_parent({:saved, subject})

        {:noreply,
         socket
         |> put_flash(:info, "Subject created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
