defmodule EcampusWeb.Dashboard.Index do
  @moduledoc """
  This module contains the dashboard
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  alias Ecampus.Classes

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)

    {:ok, socket |> assign(:incoming, Classes.get_incoming_class())}
  end
end
