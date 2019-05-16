defmodule DirectionsTest do
  use ExUnit.Case, async: true
  alias GoogleMaps, as: Maps
  use GoogleMaps.BypassCase

  @origin "Cột mốc Quốc Gia, Đất Mũi, Ca Mau, Vietnam"
  @destination "Cột cờ Lũng Cú, Đường lên Cột Cờ, Lũng Cú, Ha Giang, Vietnam"

  test "directions between two addresses", %{bypass: bypass, test_endpoint: test_endpoint} do
    Application.put_env(:google_maps, :url, test_endpoint)

    bypass
    |> Bypass.expect(fn conn ->
      conn
      |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=UTF-8")
      |> Plug.Conn.resp(200, Jason.encode!(fake_direction()))
    end)

    {:ok, result} = Maps.directions(@origin, @destination)
    assert result["geocoded_waypoints"]
    assert_single_route(result)
  end

  test "directions between two coordinates", %{bypass: bypass, test_endpoint: test_endpoint} do
    Application.put_env(:google_maps, :url, test_endpoint)

    bypass
    |> Bypass.expect(fn conn ->
      conn
      |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=UTF-8")
      |> Plug.Conn.resp(200, Jason.encode!(fake_direction()))
    end)

    {:ok, result} = Maps.directions("8.6069305,104.7196242", "23.363697,105.3140251")
    assert result["geocoded_waypoints"]
    assert_single_route(result)
  end

  test "directions between two lat/lng tupples", %{bypass: bypass, test_endpoint: test_endpoint} do
    Application.put_env(:google_maps, :url, test_endpoint)

    bypass
    |> Bypass.expect(fn conn ->
      conn
      |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=UTF-8")
      |> Plug.Conn.resp(200, Jason.encode!(fake_direction()))
    end)

    {:ok, result} = Maps.directions({8.6069305, 104.7196242}, {23.363697, 105.3140251})
    assert result["geocoded_waypoints"]
    assert_single_route(result)
  end

  test "directions with optional parameters", %{bypass: bypass, test_endpoint: test_endpoint} do
    Application.put_env(:google_maps, :url, test_endpoint)

    bypass
    |> Bypass.expect(fn conn ->
      conn
      |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=UTF-8")
      |> Plug.Conn.resp(200, Jason.encode!(fake_direction()))
    end)

    {:ok, result} =
      Maps.directions("8.6069305,104.7196242", "23.363697,105.3140251",
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
    assert String.contains?(Enum.at(legs, 0)["distance"]["text"], " km")
  end

  defp assert_single_route(%{"routes" => [route]}) do
    assert Enum.count(route["legs"]) === 1
  end

  defp fake_direction() do
    %{
      "geocoded_waypoints" => [
        %{
          "geocoder_status" => "OK",
          "place_id" => "ChIJT90dXUQUpDERuJ1YTHGYJjA",
          "types" => ["establishment", "point_of_interest"]
        },
        %{
          "geocoder_status" => "OK",
          "place_id" => "ChIJxzMMivbhyzYRH5HpywpNLDA",
          "types" => ["establishment", "point_of_interest"]
        }
      ],
      "routes" => [
        %{
          "bounds" => %{
            "northeast" => %{"lat" => 23.3629183, "lng" => 109.3589569},
            "southwest" => %{"lat" => 8.579790599999999, "lng" => 104.7208905}
          },
          "copyrights" => "Map data ©2019 Google",
          "legs" => [
            %{
              "distance" => %{"text" => "2,573 km", "value" => 2_572_928},
              "duration" => %{"text" => "2 days 2 hours", "value" => 178_203},
              "end_address" => "Đường lên Cột Cờ, Lũng Cú, Đồng Văn, Hà Giang 312600, Vietnam",
              "end_location" => %{"lat" => 23.3629183, "lng" => 105.3164059},
              "start_address" => "Dat Mui, Ngọc Hiển District, Ca Mau, Vietnam",
              "start_location" => %{"lat" => 8.6063308, "lng" => 104.7208905},
              "steps" => [
                %{
                  "distance" => %{"text" => "0.1 km", "value" => 105},
                  "duration" => %{"text" => "1 min", "value" => 25},
                  "end_location" => %{"lat" => 8.6066299, "lng" => 104.7217917},
                  "html_instructions" => "Head <b>east</b>",
                  "polyline" => %{"points" => "q|os@qhd~RCOAIAKKc@ESGOCOEQOc@"},
                  "start_location" => %{"lat" => 8.6063308, "lng" => 104.7208905},
                  "travel_mode" => "DRIVING"
                },
                %{
                  "distance" => %{"text" => "0.2 km", "value" => 165},
                  "duration" => %{"text" => "1 min", "value" => 37},
                  "end_location" => %{"lat" => 8.6052561, "lng" => 104.7221947},
                  "html_instructions" => "Turn <b>right</b> at Nhà Hàng Công Đoàn Đất Mũi",
                  "maneuver" => "turn-right",
                  "polyline" => %{"points" => "m~os@end~RrAu@d@QVGFAF?H?PAXATAb@F"},
                  "start_location" => %{"lat" => 8.6066299, "lng" => 104.7217917},
                  "travel_mode" => "DRIVING"
                }
              ],
              "traffic_speed_entry" => [],
              "via_waypoint" => []
            }
          ],
          "overview_polyline" => %{
            "points" => "Kk{AusEgqDqiIofPovF|vBcuDcwC"
          },
          "summary" => "QL1A",
          "warnings" => [],
          "waypoint_order" => []
        }
      ],
      "status" => "OK"
    }
  end
end
