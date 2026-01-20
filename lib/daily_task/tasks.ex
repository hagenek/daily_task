defmodule DailyTask.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias DailyTask.Repo

  alias DailyTask.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Task
    |> order_by(:date)
    |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Gets a single task by date.

  Returns `nil` if the Task does not exist.

  ## Examples

      iex> get_task_by_date(date)
      %Task{}

      iex> get_task_by_date(date)
      nil

  """
  def get_task_by_date(date) do
    Repo.get_by(Task, date: date)
  end

  @doc """
  Gets tomorrow's task.

  Returns `nil` if no task exists for tomorrow.

  ## Examples

      iex> get_task_by_tomorrow()
      %Task{}

      iex> get_task_by_tomorrow()
      nil

  """
  def get_task_by_tomorrow do
    tomorrow = Date.add(Date.utc_today(), 1)
    get_task_by_date(tomorrow)
  end

  @doc """
  Splits a task into two.

  The original task is updated with new attributes, and a new task is
  created for the next day with the provided attributes.
  This is done in a transaction to ensure atomicity.

  ## Examples

      iex> split_task(task, %{description: "New task for tomorrow"})
      {:ok, %{today: %Task{}, tomorrow: %Task{}}}

      iex> split_task(task, %{description: ""})
      {:error, %Ecto.Changeset{}}

  """
  def split_task(task, today_attrs, tomorrow_attrs) do
    tomorrow_date = Date.add(task.date, 1)
    tomorrow_task_attrs = Map.put(tomorrow_attrs, :date, tomorrow_date)

    Repo.transaction(fn ->
      with {:ok, today} <- update_task(task, today_attrs),
           {:ok, tomorrow} <- create_task(tomorrow_task_attrs) do
        %{today: today, tomorrow: tomorrow}
      else
        error -> Repo.rollback(error)
      end
    end)
  end
end
