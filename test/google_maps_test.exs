defmodule GoogleMapsTest do
  use ExUnit.Case
  alias GoogleMaps, as: Maps
  doctest Maps

  test "retrieves directions between two points" do
    {:ok, result} = Maps.directions("Disneyland", "Universal Studios Hollywood")
    assert result["geocoded_waypoints"]
    assert result["routes"]
  end
end
