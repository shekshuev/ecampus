defmodule EcampusWeb.Plugs.SetLocale do
  @moduledoc """
  This module contains login to manage app locale in cookies.
  """

  import Plug.Conn

  @supported_locales Gettext.known_locales(EcampusWeb.Gettext)

  def init(_options), do: nil

  def call(conn, _options) do
    locale = fetch_locale_from(conn)
    EcampusWeb.Gettext |> Gettext.put_locale(locale)

    conn
    |> put_resp_cookie("locale", locale, max_age: 365 * 24 * 60 * 60)
    |> put_session(:locale, locale)
  end

  defp fetch_locale_from(conn) do
    (conn.params["locale"] || conn.cookies["locale"])
    |> check_locale
  end

  defp check_locale(locale) when locale in @supported_locales, do: locale

  defp check_locale(_), do: System.get_env("DEFAULT_LOCALE", "en")
end
