defmodule DailyTask.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :description, :string
    field :date, :date
    field :completed, :boolean, default: false

    field :description_today, :string, virtual: true
    field :description_tomorrow, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :description,
      :date,
      :completed,
      :description_today,
      :description_tomorrow
    ])
    |> validate_required([:description, :date])
  end
end
