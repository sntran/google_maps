defmodule DirectionsTest do
  use ExUnit.Case, async: true
  alias GoogleMaps, as: Maps

  @origin "Cột mốc Quốc Gia, Đất Mũi, Ca Mau, Vietnam"
  @destination "Cột cờ Lũng Cú, Đường lên Cột Cờ, Lũng Cú, Ha Giang, Vietnam"

  test "directions between two addresses" do
    {:ok, result} = Maps.directions(@origin, @destination)
    assert result["geocoded_waypoints"]
    assert_single_route(result)
  end

  test "directions between two coordinates" do
    {:ok, result} = Maps.directions("8.6069305,104.7196242", "23.363697,105.3140251")
    assert result["geocoded_waypoints"]
    assert_single_route(result)
  end

  test "directions between two lat/lng tuples" do
    {:ok, result} = Maps.directions({8.6069305,104.7196242}, {23.363697,105.3140251})
    assert result["geocoded_waypoints"]
    assert_single_route(result)
  end

  test "directions with optional parameters" do
    {:ok, result} = Maps.directions("8.6069305,104.7196242", "23.363697,105.3140251",
                      mode: "driving",
                      waypoints: [
                        "10.402504,107.056638",
                        "10.8976049,108.1020933",
                        "11.9039022,108.3806826",
                        "12.2595881,109.1707299",
                        "16.0470775,108.1712141"
                      ],
                      alternatives: true,
                      language: "vi",
                      units: "metric"
                    )

    [route | _rest] = result["routes"]
    legs = route["legs"]
    assert Enum.count(legs) > 1
    leg = Enum.at(route["legs"], 1)
    assert Regex.match?(~r([\d]+ phút), leg["duration"]["text"])
    assert Regex.match?(~r([\d]+ km), leg["distance"]["text"])
  end

  defp assert_single_route(%{"routes" => [route]}) do
    assert Enum.count(route["legs"]) === 1
  end
end
