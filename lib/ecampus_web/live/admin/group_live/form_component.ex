defmodule EcampusWeb.GroupLive.FormComponent do
  @moduledoc """
  LiveComponent for creating and editing academic groups.

  Renders the form and handles form validation, saving (create/update),
  and deletion of `Group` entities within a speciality.
  """

  use EcampusWeb, :live_component
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Groups
  alias Phoenix.LiveView.Socket

  @impl true
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label={dgettext("groups", "Title")} />
        <.input field={@form[:description]} type="text" label={dgettext("groups", "Description")} />
        <.input field={@form[:speciality_id]} type="hidden" value={@speciality_id} />
        <:actions>
          <.button phx-disable-with={dgettext("groups", "Saving...")}>
            {dgettext("groups", "Save")}
          </.button>
          <%= if @action == :edit do %>
            <.button
              phx-click="delete"
              phx-target={@myself}
              class="btn-error"
              type="button"
              data-confirm={dgettext("groups", "Are you sure?")}
            >
              {dgettext("groups", "Delete")}
            </.button>
          <% end %>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  @spec update(map(), Socket.t()) :: {:ok, Socket.t()}
  def update(%{group: group} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Groups.change_group(group))
     end)}
  end

  @impl true
  @spec handle_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset = Groups.change_group(socket.assigns.group, group_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("delete", _params, socket) do
    case Groups.delete_group(socket.assigns.group) do
      {:ok, _deleted} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("groups", "Group deleted successfully"))
         |> push_navigate(to: ~p"/admin/specialities/#{socket.assigns.speciality_id}/groups")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, dgettext("groups", "Failed to delete group"))
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  def handle_event("save", %{"group" => group_params}, socket) do
    save_group(socket, socket.assigns.action, group_params)
  end

  @spec save_group(Socket.t(), :new | :edit, map()) :: {:noreply, Socket.t()}
  defp save_group(socket, :edit, group_params) do
    case Groups.update_group(socket.assigns.group, group_params) do
      {:ok, group} ->
        notify_parent({:saved, group})

        {:noreply,
         socket
         |> put_flash(:info, "Group updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_group(socket, :new, group_params) do
    case Groups.create_group(group_params) do
      {:ok, group} ->
        notify_parent({:saved, group})

        {:noreply,
         socket
         |> put_flash(:info, "Group created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @spec notify_parent({:saved, Groups.Group.t()}) :: :ok
  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
