defmodule GoogleMaps.BypassCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require opening a Bypass server.
  """

  use ExUnit.CaseTemplate

  setup _tags do
    bypass = Bypass.open()

    {:ok,
     %{
       bypass: bypass,
       test_endpoint: test_endpoint(bypass),
       test_port: bypass.port
     }}
  end

  defp test_endpoint(bypass) do
    "http://127.0.0.1" <> ":" <> to_string(bypass.port) <> "/google/"
  end
end
