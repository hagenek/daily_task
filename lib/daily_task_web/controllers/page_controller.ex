defmodule DailyTaskWeb.PageController do
  use DailyTaskWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/tasks")
  end
end
