defmodule EcampusWeb.SubjectLive.FormComponent do
  use EcampusWeb, :live_component
  use Gettext, backend: EcampusWeb.Gettext

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
        multipart
      >
        <.input field={@form[:title]} type="text" label={dgettext("subjects", "Title")} />
        <.input field={@form[:short_title]} type="text" label={dgettext("subjects", "Short title")} />
        <.input field={@form[:description]} type="text" label={dgettext("subjects", "Description")} />
        <.input
          field={@form[:prerequisites]}
          type="text"
          label={dgettext("subjects", "Prerequisites")}
        />
        <.input field={@form[:objectives]} type="text" label={dgettext("subjects", "Objectives")} />
        <.input
          field={@form[:required_texts]}
          type="text"
          label={dgettext("subjects", "Required texts")}
        />
        <.live_file_input upload={@uploads[:cover]} />
        <:actions>
          <.button phx-disable-with={dgettext("subjects", "Saving...")}>
            {dgettext("subjects", "Save")}
          </.button>
          <%= if @action == :edit do %>
            <.button
              phx-click="delete"
              phx-target={@myself}
              class="btn-error"
              type="button"
              data-confirm={dgettext("subjects", "Are you sure?")}
            >
              {dgettext("subjects", "Delete")}
            </.button>
          <% end %>
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
     end)
     |> allow_upload(:cover, accept: ~w(.jpg .jpeg .png))}
  end

  @impl true
  def handle_event("validate", %{"subject" => subject_params}, socket) do
    changeset = Subjects.change_subject(socket.assigns.subject, subject_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("delete", _params, socket) do
    case Subjects.delete_subject(socket.assigns.subject) do
      {:ok, _deleted} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("subjects", "Subject deleted successfully"))
         |> push_navigate(to: ~p"/admin/specialities")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, dgettext("subjects", "Failed to delete subject"))
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  def handle_event("save", %{"subject" => subject_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :cover, fn %{path: path}, entry ->
        Ecampus.Uploaders.SubjectCover.store({path, entry})
      end)

    save_subject(
      socket,
      socket.assigns.action,
      Map.put(subject_params, "cover", List.first(uploaded_files) || nil)
    )
  end

  defp save_subject(socket, :edit, subject_params) do
    case Subjects.update_subject(socket.assigns.subject, subject_params) do
      {:ok, subject} ->
        notify_parent({:saved, subject})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("subjects", "Subject updated successfully"))
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
         |> put_flash(:info, dgettext("subjects", "Subject created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
