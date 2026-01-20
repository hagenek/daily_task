defmodule DailyTaskWeb.TaskLive.TomorrowTest do
  use DailyTaskWeb.ConnCase

  import Phoenix.LiveViewTest
  import DailyTask.TasksFixtures

  @invalid_attrs %{description: ""}

  setup %{conn: conn} do
    today = Date.utc_today()
    tomorrow = Date.add(today, 1)
    %{conn: bypass_through(conn, [DailyTaskWeb.UserAuth]) |> assign(:current_user, nil), today: today, tomorrow: tomorrow}
  end

  describe "Tomorrow Index" do
    test "displays add task button when no task exists for tomorrow", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/tasks/tomorrow")
      assert html =~ "Ingen task for i morgen ennå"
      assert html =~ "Legg til task for i morgen"
    end

    test "displays tomorrow's task when one exists", %{conn: conn, tomorrow: tomorrow} do
      _task = task_fixture(%{date: tomorrow, description: "Morgendagens task"})
      {:ok, _index_live, html} = live(conn, ~p"/tasks/tomorrow")

      assert html =~ "Morgendagens task"
      refute html =~ "Ingen task for i morgen ennå"
    end

    test "creates a new task for tomorrow", %{conn: conn, tomorrow: tomorrow} do
      {:ok, index_live, _html} = live(conn, ~p"/tasks/tomorrow/new")
      create_attrs = %{description: "En ny task for i morgen"}

      index_live
      |> form("#task-form", task: create_attrs)
      |> render_submit()

      html = render(index_live)
      assert html =~ "Task lagret"
      assert html =~ "En ny task for i morgen"

      assert %{description: "En ny task for i morgen", date: ^tomorrow} =
               DailyTask.Tasks.get_task_by_date(tomorrow)
    end

    test "updates tomorrow's task", %{conn: conn, tomorrow: tomorrow} do
      task = task_fixture(%{date: tomorrow})
      {:ok, index_live, _html} = live(conn, ~p"/tasks/tomorrow/#{task.id}/edit")

      update_attrs = %{description: "Oppdatert morgendagens task"}
      index_live
      |> form("#task-form", task: update_attrs)
      |> render_submit()

      html = render(index_live)
      assert html =~ "Task lagret"
      assert html =~ "Oppdatert morgendagens task"
    end

    test "deletes tomorrow's task", %{conn: conn, tomorrow: tomorrow} do
      task = task_fixture(%{date: tomorrow})
      {:ok, index_live, _html} = live(conn, ~p"/tasks/tomorrow")

      index_live
      |> element(~s/a[aria-label="delete-task-#{task.id}"]/)
      |> render_click()

      assert_raise Ecto.NoResultsError, fn -> DailyTask.Tasks.get_task!(task.id) end
    end

    test "completes tomorrow's task", %{conn: conn, tomorrow: tomorrow} do
      task = task_fixture(%{date: tomorrow, completed: false})
      {:ok, index_live, _html} = live(conn, ~p"/tasks/tomorrow")

      index_live |> element(~s/button[phx-value-id="#{task.id}"]/, "Fullfør") |> render_click()

      html = render(index_live)
      assert html =~ "line-through"
      assert DailyTask.Tasks.get_task!(task.id).completed
    end

    test "shows navigation back to today's tasks", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/tasks/tomorrow")
      assert html =~ "Tilbake til dagens tasks"
    end
  end
end