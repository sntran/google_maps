defmodule DirectionsTest do
  use ExUnit.Case, async: true
  alias GoogleMaps, as: Maps

  test "retrieves directions between two addresses" do
    {:ok, result} = Maps.directions("Cột mốc Quốc Gia, Đất Mũi, Ngọc Hiển, Cà Mau, Vietnam", "Cột Cờ Lũng Cú, Lũng Cú, Đồng Văn, Ha Giang, Vietnam")
    assert result["geocoded_waypoints"]
    assert result["routes"]
  end

  test "retrieves directions between two coordinates" do
    {:ok, result} = Maps.directions("15.9216161,101.9985552", "15.9216161,101.9985552")
    assert result["geocoded_waypoints"]
    assert result["routes"]
  end

  test "retrieves directions between two lat/lng tupples" do
    {:ok, result} = Maps.directions({15.9216161,101.9985552}, {15.9216161,101.9985552})
    assert result["geocoded_waypoints"]
    assert result["routes"]
  end
end
