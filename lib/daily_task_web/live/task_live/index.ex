defmodule DailyTaskWeb.TaskLive.Index do
  use DailyTaskWeb, :live_view

  alias DailyTask.Tasks
  alias DailyTask.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()
    task = Tasks.get_task_by_date(today)

    socket =
      assign(socket,
        today: today,
        task: task,
        split_changeset: Tasks.change_task(%Task{})
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, Tasks.get_task!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{date: socket.assigns.today})
  end

  defp apply_action(socket, :split, %{"id" => id}) do
    socket
    |> assign(:page_title, "Split Task")
    |> assign(:task, Tasks.get_task!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Today's Task")
    |> assign(:task, Tasks.get_task_by_date(socket.assigns.today))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply, assign(socket, :task, nil)}
  end

  @impl true
  def handle_event("complete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, updated_task} = Tasks.update_task(task, %{completed: true})

    {:noreply, assign(socket, :task, updated_task)}
  end

  @impl true
  def handle_event("save_split", %{"task" => new_task_attrs}, socket) do
    today_attrs = %{description: new_task_attrs["description_today"]}
    tomorrow_attrs = %{description: new_task_attrs["description_tomorrow"]}

    case Tasks.split_task(socket.assigns.task, today_attrs, tomorrow_attrs) do
      {:ok, %{today: task, tomorrow: _}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task splittet! Se morgendagens tasks for å se den andre delen.")
         |> assign(task: task)
         |> push_patch(to: ~p"/tasks")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Det oppstod en feil under splitting av tasken.")
         |> push_patch(to: ~p"/tasks")}
    end
  end

  @impl true
  def handle_info({DailyTaskWeb.TaskLive.FormComponent, {:saved, task}}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Task saved successfully")
     |> assign(task: task)
     |> push_patch(to: ~p"/tasks")}
  end
end
