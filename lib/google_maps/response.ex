defmodule GoogleMaps.Response do
  @moduledoc false

  @type t :: {:ok, map()} | {:error, error()}

  @type status :: String.t

  @type error :: HTTPoison.Error.t | status()

  def wrap({:error, error}), do: {:error, error}
  def wrap({:ok, %{body: %{"status" => "OK"} = body}}), do: {:ok, body}
  def wrap({:ok, %{body: %{"status" => status}}}), do: {:error, status}
end