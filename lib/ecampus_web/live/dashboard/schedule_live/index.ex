defmodule EcampusWeb.Dashboard.ScheduleLive.Index do
  use EcampusWeb, :live_view

  alias Ecampus.Classes
  alias Ecampus.Classes.Class

  @impl true
  def mount(_params, _session, socket) do
    %{group_id: group_id} = socket.assigns[:current_user]

    {:ok, %{list: classes, pagination: pagination}} =
      Classes.list_classes(%{"group_id" => group_id})

    today = Date.utc_today()
    calendar_days = calculate_calendar_days(today)
    classes_by_date = group_classes_by_date(classes)

    {:ok,
     socket
     |> assign(:pagination, pagination)
     |> assign(:calendar_days, calendar_days)
     |> assign(:classes_by_date, classes_by_date)
     |> assign(:current_date, today)
     |> assign(:today, today)
     |> stream(:classes, classes)}
  end

  defp group_classes_by_date(classes) do
    classes
    |> Enum.group_by(fn class ->
      class.begin_date
      |> DateTime.to_date()
    end)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Class")
    |> assign(:class, Classes.get_class(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Class")
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Classes")
    |> assign(:class, nil)
  end

  @impl true
  def handle_info({EcampusWeb.ClassLive.FormComponent, {:saved, class}}, socket) do
    {:noreply, stream_insert(socket, :classes, class)}
  end

  @impl true
  def handle_event("prev_month", _params, socket) do
    new_date = socket.assigns[:current_date] |> Cldr.Calendar.minus(:months, 1)
    %{group_id: group_id} = socket.assigns[:current_user]

    {:ok, %{list: classes, pagination: pagination}} =
      Classes.list_classes(%{"group_id" => group_id})

    calendar_days = calculate_calendar_days(new_date)
    classes_by_date = group_classes_by_date(classes)

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:calendar_days, calendar_days)
     |> assign(:classes_by_date, classes_by_date)
     |> assign(:current_date, new_date)
     |> stream(:classes, classes)}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    new_date = socket.assigns[:current_date] |> Cldr.Calendar.plus(:months, 1)

    %{group_id: group_id} = socket.assigns[:current_user]

    {:ok, %{list: classes, pagination: pagination}} =
      Classes.list_classes(%{"group_id" => group_id})

    calendar_days = calculate_calendar_days(new_date)
    classes_by_date = group_classes_by_date(classes)

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> assign(:calendar_days, calendar_days)
     |> assign(:classes_by_date, classes_by_date)
     |> assign(:current_date, new_date)
     |> stream(:classes, classes)}
  end

  def calendar(assigns) do
    ~H"""
    <div class="flex flex-col h-screen">
      <header class="py-4 flex justify-end items-center gap-2">
        <h1 class="text-lg font-bold">
          {Calendar.strftime(assigns[:current_date], "%B %Y")}
        </h1>
        <button phx-click="prev_month" class="btn btn-sm btn-ghost">
          <.icon name="hero-chevron-left" />
        </button>

        <button phx-click="next_month" class="btn btn-sm btn-ghost">
          <.icon name="hero-chevron-right" />
        </button>
      </header>
      <div class="flex-1 grid grid-cols-7 grid-rows-[auto,repeat(6,minmax(0,1fr))] bg-base-100">
        <div class="font-bold text-center p-2">Пн</div>
        <div class="font-bold text-center p-2">Вт</div>
        <div class="font-bold text-center p-2">Ср</div>
        <div class="font-bold text-center p-2">Чт</div>
        <div class="font-bold text-center p-2">Пт</div>
        <div class="font-bold text-center p-2">Сб</div>
        <div class="font-bold text-center p-2">Вс</div>

        <%= for day <- assigns[:calendar_days] do %>
          <div class={"p-4 flex flex-col items-center border #{if day[:current_month], do: "bg-base-200", else: "bg-base-100"}"}>
            <div class={[
              "w-8 h-8 flex justify-center items-center rounded-full",
              @today == day[:date] && " bg-primary text-primary-content"
            ]}>
              {day[:date].day}
            </div>

            <div class="flex flex-col gap-1 justify-start w-full">
              <%= for event <- Map.get(assigns[:classes_by_date], day[:date], []) do %>
                <div
                  class="tooltip tooltip-top"
                  data-tip={event.lesson.subject.title <>
                  ", аудитория " <>
                  event.classroom <>
                  ", " <>
                  Calendar.strftime(
                      event.begin_date,
                      "%H:%M"
                    ) <>
                  " - " <>
                  Calendar.strftime(
                      event.end_date,
                      "%H:%M"
                    )}
                >
                  <.link patch={~p"/dashboard/classes/#{event.id}"}>
                    <div class="badge badge-primary badge-lg w-full text-nowrap text-left truncate cursor-pointer">
                      {event.lesson.subject.short_title} {event.classroom}
                    </div>
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp calculate_calendar_days(%Date{year: year, month: month}) do
    first_day = Date.new!(year, month, 1)
    last_day = Date.end_of_month(first_day)

    start_date = shift_to_week_start(first_day)
    end_date = shift_to_week_end(last_day)

    Enum.map(Date.range(start_date, end_date), fn date ->
      %{
        date: date,
        current_month: date.month == month
      }
    end)
  end

  defp shift_to_week_start(date) do
    days_to_shift = Date.day_of_week(date) - 1
    Date.add(date, -days_to_shift)
  end

  defp shift_to_week_end(date) do
    days_to_shift = 7 - Date.day_of_week(date)
    Date.add(date, days_to_shift)
  end
end
