defmodule DailyTaskWeb.TaskLive.Tomorrow do
  use DailyTaskWeb, :live_view

  alias DailyTask.Tasks
  alias DailyTask.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()
    tomorrow = Date.add(today, 1)
    tomorrow_task = Tasks.get_task_by_tomorrow()

    socket =
      assign(socket,
        today: today,
        tomorrow: tomorrow,
        tomorrow_task: tomorrow_task
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Rediger morgendagens task")
    |> assign(:task, Tasks.get_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Ny task for i morgen")
    |> assign(:task, %Task{date: socket.assigns.tomorrow})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Morgendagens task")
    |> assign(:task, Tasks.get_task_by_tomorrow())
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, assign(socket, :tomorrow_task, nil)}
  end

  @impl true
  def handle_event("complete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, updated_task} = Tasks.update_task(task, %{completed: true})

    {:noreply, assign(socket, :tomorrow_task, updated_task)}
  end

  @impl true
  def handle_info({DailyTaskWeb.TaskLive.FormComponent, {:saved, task}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Task lagret")
     |> assign(tomorrow_task: task)
     |> push_patch(to: ~p"/tasks/tomorrow")}
  end
end