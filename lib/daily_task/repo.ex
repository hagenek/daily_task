defmodule DailyTask.Repo do
  use Ecto.Repo,
    otp_app: :daily_task,
    adapter: Ecto.Adapters.Postgres
end
