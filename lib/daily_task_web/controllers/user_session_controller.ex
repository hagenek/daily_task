defmodule DailyTaskWeb.UserSessionController do
  use DailyTaskWeb, :controller

  alias DailyTask.Accounts
  alias DailyTaskWeb.UserAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Konto opprettet vellykket!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Passord oppdatert vellykket!")
  end

  def create(conn, params) do
    create(conn, params, "Velkommen tilbake!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"username" => username, "password" => password} = user_params

    if user = Accounts.get_user_by_username_and_password(username, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the username is registered.
      conn
      |> put_flash(:error, "Ugyldig brukernavn eller passord.")
      |> put_flash(:username, String.slice(username, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logget ut vellykket.")
    |> UserAuth.log_out_user()
  end
end
