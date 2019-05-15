defmodule GoogleMapsTest do
  use ExUnit.Case, async: true
  # doctest GoogleMaps

  setup do
    bypass = Bypass.open(port: 1307)

    {:ok, bypass: bypass}
  end

  test "autocomplete respond by zipcode", %{bypass: bypass} do
    bypass
    |> Bypass.expect(fn conn ->
      conn
      |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=UTF-8")
      |> Plug.Conn.resp(200, Jason.encode!(zipcode_body()))
    end)

    {:ok,
     %{
       "predictions" => [
         %{
           "description" => _desc,
           "id" => _id,
           "matched_substrings" => _ms,
           "place_id" => _pid,
           "reference" => _ref,
           "structured_formatting" => _sf,
           "terms" => _terms,
           "types" => _types
         }
         | _tail
       ],
       "status" => status
     }} = GoogleMaps.place_autocomplete("1234")

    assert status == "OK"
  end

  test "autocomplete error respond by zipcode", %{bypass: bypass} do
    bypass
    |> Bypass.expect(fn conn ->
      conn
      |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=UTF-8")
      |> Plug.Conn.resp(400, Jason.encode!(%{"predictions" => [], "status" => "ZERO_RESULTS"}))
    end)

    assert {:error, 400} == GoogleMaps.place_autocomplete("564124356")
  end

  defp zipcode_body() do
    %{
      "predictions" => [
        %{
          "description" => "1234 funny-land, Deutschland",
          "id" => "63eb589bc47b21f5ae1d7e4ec47eq76d4d1b46dd",
          "matched_substrings" => [
            %{"length" => 5, "offset" => 0},
            %{"length" => 11, "offset" => 24}
          ],
          "place_id" => "ChIJUfrcbPKHvkcRcJPmW1jUIhw",
          "reference" => "ChIJUfrcbPKHvkcRcJPmW1jUIhw",
          "structured_formatting" => %{
            "main_text" => "56203",
            "main_text_matched_substrings" => [%{"length" => 5, "offset" => 0}],
            "secondary_text" => "funny-land, Deutschland",
            "secondary_text_matched_substrings" => [
              %{"length" => 19, "offset" => 33}
            ]
          },
          "terms" => [
            %{"offset" => 0, "value" => "1234"},
            %{"offset" => 6, "value" => "funny-land"},
            %{"offset" => 24, "value" => "Deutschland"}
          ],
          "types" => ["postal_code", "geocode"]
        },
        %{
          "description" => "Deutschlandschachtstraße 56203, Oelsnitz/Erzgebirge, Germany",
          "id" => "3d635237e3d0465e129501c37ab46fa6ab7f1172",
          "matched_substrings" => [%{"length" => 24, "offset" => 0}],
          "place_id" =>
            "Ej1EZXV0c2NobGFuZHNjaGFjaHRzdHJhw59lIDU2MjAzLCBPZWxzbml0ei9FcnpnZWJpcmdlLCBHZXJtYW55",
          "reference" =>
            "Ej1EZXV0c2NobGFuZHNjaGFjaHRzdHJhw59lIDU2MjAzLCBPZWxzbml0ei9FcnpnZWJpcmdlLCBHZXJtYW55",
          "structured_formatting" => %{
            "main_text" => "Deutschlandschachtstraße 56203",
            "main_text_matched_substrings" => [%{"length" => 24, "offset" => 0}],
            "secondary_text" => "Oelsnitz/Erzgebirge, Germany"
          },
          "terms" => [
            %{"offset" => 0, "value" => "Deutschlandschachtstraße"},
            %{"offset" => 25, "value" => "56203"},
            %{"offset" => 32, "value" => "Oelsnitz/Erzgebirge"},
            %{"offset" => 53, "value" => "Germany"}
          ],
          "types" => ["route", "geocode"]
        }
      ],
      "status" => "OK"
    }
  end
end
