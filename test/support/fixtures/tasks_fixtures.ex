defmodule DailyTask.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DailyTask.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        completed: true,
        date: ~D[2025-06-11],
        description: "some description"
      })
      |> DailyTask.Tasks.create_task()

    task
  end
end
