defmodule GoogleMaps.Response do
  @moduledoc false

  @type t :: {:ok, map()} | {:error, error()} | {:error, error(), String.t()}

  @type status :: String.t

  @type error :: String.t

  def wrap({:error, error}), do: {:error, error}
  def wrap({:ok, %{body: body, headers: %{"content-type" => "application/json" <> _}} = response})
  when is_binary(body) do
    wrap({:ok, %{response | body: Jason.decode!(body)}})
  end
  def wrap({:ok, %{body: %{"status" => "OK"} = body}}), do: {:ok, body}
  def wrap({:ok, %{body: %{"status" => status, "error_message" => error_message}}}), do: {:error, status, error_message}
  def wrap({:ok, %{body: %{"status" => status}}}), do: {:error, status}
  def wrap({:ok, %{body: body, status_code: 200, headers: %{"content-type" => "image" <> _}}})
  when is_binary(body), do: {:ok, body}
  def wrap({:ok, %{status_code: status, headers: %{"content-type" => _}}}), do: {:error, status}
end
