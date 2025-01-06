defmodule EcampusWeb.UserSettingsLive do
  use EcampusWeb, :live_view

  alias Ecampus.Accounts
  alias Ecampus.Groups

  def render(assigns) do
    ~H"""
    <.header>
      Account Settings
    </.header>

    <div>
      <div>
        <.simple_form
          for={@personal_data_form}
          id="personal_data_form"
          phx-submit="update_personal_data"
        >
          <.input
            field={@personal_data_form[:first_name]}
            type="text"
            name="first_name"
            label="First name"
            value={@current_user.first_name}
          />
          <.input
            field={@personal_data_form[:middle_name]}
            type="text"
            name="middle_name"
            label="Middle name"
            value={@current_user.middle_name}
          />
          <.input
            field={@personal_data_form[:last_name]}
            type="text"
            name="last_name"
            label="Last name"
            value={@current_user.last_name}
          />
          <:actions>
            <.button phx-disable-with="Changing...">
              Change Personal Data
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>

    <div>
      <div>
        <.simple_form for={@group_form} id="group_form" phx-submit="update_group">
          <.input
            field={@group_form[:group_id]}
            name="group_id"
            type="select"
            label="Group"
            options={Enum.map(@groups, &{&1.title, &1.id})}
            value={@current_user.group_id}
            prompt="Select a group"
            disabled={@current_user.group_id != nil}
          />
          <:actions>
            <.button disabled={@current_user.group_id != nil} phx-disable-with="Changing...">
              Change Group
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>

    <div>
      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input
            field={@email_form[:email]}
            type="email"
            label="Email"
            value={@current_user.email}
            required
          />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_user.email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    group_changeset = Accounts.change_user_group(user)
    personal_data_changeset = Accounts.change_user_personal_data(user)

    groups = Groups.list_groups()

    socket =
      socket
      |> assign(:groups, groups)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:group_form, to_form(group_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:personal_data_form, to_form(personal_data_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("update_group", %{"group_id" => group_id}, socket) do
    user = socket.assigns.current_user

    params = %{group_id: String.to_integer(group_id)}

    case Accounts.update_user_group(user, params) do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Group selected successfully.")}

      {:error, changeset} ->
        {:noreply, assign(socket, group_form: to_form(changeset))}
    end
  end

  def handle_event(
        "update_personal_data",
        %{"first_name" => first_name, "middle_name" => middle_name, "last_name" => last_name},
        socket
      ) do
    user = socket.assigns.current_user

    params = %{first_name: first_name, middle_name: middle_name, last_name: last_name}

    case Accounts.update_user_personal_data(user, params) do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Personal data changed successfully.")}

      {:error, changeset} ->
        {:noreply, assign(socket, group_form: to_form(changeset))}
    end
  end
end
