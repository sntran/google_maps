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
end
