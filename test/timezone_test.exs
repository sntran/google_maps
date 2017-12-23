defmodule TimezoneTest do
  use ExUnit.Case, async: true
  alias GoogleMaps, as: Maps

  test "timezone for a lat/lng tupple" do
    {:ok, result} = Maps.timezone({8.6069305,104.7196242})
    assert result["rawOffset"]
    assert result["timeZoneId"]
  end

  test "timezone for a lat,lng string" do
    {:ok, result} = Maps.timezone("8.6069305,104.7196242")
    assert result["rawOffset"]
    assert result["timeZoneId"]
  end

  test "when there is no result" do
    {:error, "ZERO_RESULTS"} = Maps.timezone({54.0661, -4.7404})
  end
end
