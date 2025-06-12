defmodule DailyTaskWeb.TaskLiveTest do
  use DailyTaskWeb.ConnCase

  import Phoenix.LiveViewTest
  import DailyTask.TasksFixtures

  @invalid_attrs %{description: ""}

  setup %{conn: conn} do
    today = Date.utc_today()
    %{conn: bypass_through(conn, [DailyTaskWeb.UserAuth]) |> assign(:current_user, nil), today: today}
  end

  describe "Index" do
    test "displays an add task button when no task exists for today", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/tasks")
      assert html =~ "No task for today. Add one!"
      assert html =~ "Add Task"
    end

    test "displays today's task when one exists", %{conn: conn, today: today} do
      _task = task_fixture(%{date: today, description: "My Task For Today"})
      {:ok, _index_live, html} = live(conn, ~p"/tasks")

      assert html =~ "My Task For Today"
      refute html =~ "No task for today. Add one!"
    end

    # test "shows validation error for invalid data", %{conn: conn} do
    #   {:ok, index_live, _html} = live(conn, ~p"/tasks/new")
    #
    #   assert index_live
    #          |> form("#task-form", task: @invalid_attrs)
    #          |> render_change() =~ "can't be blank"
    # end

    test "creates a new task for today", %{conn: conn, today: today} do
      {:ok, index_live, _html} = live(conn, ~p"/tasks/new")
      create_attrs = %{description: "A brand new task"}

      index_live
      |> form("#task-form", task: create_attrs)
      |> render_submit()

      html = render(index_live)
      assert html =~ "Task saved successfully"
      assert html =~ "A brand new task"

      assert %{description: "A brand new task", date: ^today} =
               DailyTask.Tasks.get_task_by_date(today)
    end

    test "updates an existing task", %{conn: conn, today: today} do
      task = task_fixture(%{date: today})
      {:ok, index_live, _html} = live(conn, ~p"/tasks/#{task.id}/edit")

      update_attrs = %{description: "An updated task"}
      index_live
      |> form("#task-form", task: update_attrs)
      |> render_submit()

      html = render(index_live)
      assert html =~ "Task saved successfully"
      assert html =~ "An updated task"
    end

    test "deletes a task", %{conn: conn, today: today} do
      task = task_fixture(%{date: today})
      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      index_live
      |> element(~s/a[aria-label="delete-task-#{task.id}"]/)
      |> render_click()

      assert_raise Ecto.NoResultsError, fn -> DailyTask.Tasks.get_task!(task.id) end
    end

    test "completes a task", %{conn: conn, today: today} do
      task = task_fixture(%{date: today, completed: false})
      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      index_live |> element(~s/button[phx-value-id="#{task.id}"]/, "Complete") |> render_click()

      html = render(index_live)
      assert html =~ "line-through"
      assert DailyTask.Tasks.get_task!(task.id).completed
    end

    test "splits a task", %{conn: conn, today: today} do
      task = task_fixture(%{date: today, description: "Original Task"})
      {:ok, index_live, _html} = live(conn, ~p"/tasks")

      index_live
      |> element(~s/a[aria-label="split-task-#{task.id}"]/)
      |> render_click()

      assert_patch(index_live, ~p"/tasks/#{task.id}/split")

      split_attrs = %{
        description_today: "The first part",
        description_tomorrow: "The second part"
      }

      index_live
      |> form("#split-task-form", task: split_attrs)
      |> render_submit()

      html = render(index_live)
      assert html =~ "Task split successfully"
      assert html =~ "The first part"

      tomorrow = Date.add(today, 1)
      assert %{description: "The second part"} = DailyTask.Tasks.get_task_by_date(tomorrow)
    end
  end
end
