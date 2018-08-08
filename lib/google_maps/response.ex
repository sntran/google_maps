defmodule GoogleMaps.Response do
  @moduledoc false

  @type t :: {:ok, map()} | {:error, error()} | {:error, error(), String.t()}

  @type status :: String.t

  @type error :: HTTPoison.Error.t | status()

  def wrap({:error, error}), do: {:error, error}
  def wrap({:ok, %{body: body} = response}) when is_binary(body) do
    wrap({:ok, %{response | body: Jason.decode!(body)}})
  end
  def wrap({:ok, %{body: %{"status" => "OK"} = body}}), do: {:ok, body}
  def wrap({:ok, %{body: %{"status" => status, "error_message" => error_message}}}), do: {:error, status, error_message}
  def wrap({:ok, %{body: %{"status" => status}}}), do: {:error, status}
end
