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
    incoming = Classes.get_incoming_class(socket.assigns.current_user)
    stats = Classes.get_stats(socket.assigns.current_user)

    stats = %{
      stats
      | last_quizzes:
          stats.last_quizzes
          |> Enum.with_index()
          |> Enum.map(fn {lq, idx} -> {"last_quizzes-#{idx}", lq} end)
    }

    ranking =
      Classes.rank_students_in_group(socket.assigns.current_user.group_id)
      |> Enum.with_index()
      |> Enum.map(fn {r, idx} -> {"ranking-#{idx}", r} end)

    {:ok,
     socket
     |> assign(:incoming, incoming)
     |> assign(:stats, stats)
     |> assign(:ranking, ranking)}
  end
end
