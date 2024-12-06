defmodule EcampusWeb.SpecialityLive.FormComponent do
  use EcampusWeb, :live_component

  alias Ecampus.Specialities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage speciality records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="speciality-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:code]} type="text" label="Code" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:title]} type="text" label="Title" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Speciality</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{speciality: speciality} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Specialities.change_speciality(speciality))
     end)}
  end

  @impl true
  def handle_event("validate", %{"speciality" => speciality_params}, socket) do
    changeset = Specialities.change_speciality(socket.assigns.speciality, speciality_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"speciality" => speciality_params}, socket) do
    save_speciality(socket, socket.assigns.action, speciality_params)
  end

  defp save_speciality(socket, :edit, speciality_params) do
    case Specialities.update_speciality(socket.assigns.speciality, speciality_params) do
      {:ok, speciality} ->
        notify_parent({:saved, speciality})

        {:noreply,
         socket
         |> put_flash(:info, "Speciality updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_speciality(socket, :new, speciality_params) do
    case Specialities.create_speciality(speciality_params) do
      {:ok, speciality} ->
        notify_parent({:saved, speciality})

        {:noreply,
         socket
         |> put_flash(:info, "Speciality created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
