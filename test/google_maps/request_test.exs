defmodule GoogleMaps.RequestTest do
  use ExUnit.Case, async: false
  alias GoogleMaps.Request, as: Request

  defmodule MockRequest do
    def get(url, headers, options) do
      {:ok, %{body: url, headers: headers, options: options}}
    end
  end

  setup do
    requester = Application.get_env(:google_maps, :requester)
    Application.put_env(:google_maps, :requester, MockRequest)

    on_exit fn ->
      Application.put_env(:google_maps, :requester, requester)
    end

    :ok
  end

  test "construct full URL from endpoint" do
    {:ok, %{body: url}} = Request.get("foobar", [])
    assert %{
      scheme: "https",
      authority: "maps.googleapis.com",
      path: "/maps/api/foobar/json"
    } = URI.parse(url)
  end

  test "convert params to query" do
    params = [key: "key", foo: "param1", bar: "param2"]
    {:ok, %{body: url}} = Request.get("foobar", params)
    assert %{query: "key=key&foo=param1&bar=param2"} = URI.parse(url)
  end

  test "supports headers" do
    params = [headers: [{"Accept-Language", "vi"}]]
    {:ok, %{headers: headers}} = Request.get("foobar", params)
    assert headers === params[:headers]
  end

  test "supports options" do
    params = [options: [proxy: "localhost"]]
    {:ok, %{options: options}} = Request.get("foobar", params)
    assert options === params[:options]
  end

  test "support insecure request without API key" do
    params = [secure: false, key: "key", param: "param"]
    {:ok, %{body: url}} = Request.get("foobar", params)
    assert %{
      scheme: "http",
      authority: "maps.googleapis.com",
      path: "/maps/api/foobar/json",
      query: "param=param"
    } = URI.parse(url)
  end
end