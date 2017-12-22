# Google Maps

Elixir wrapper around Google Maps APIs

## Services

- [x] [Directions](https://developers.google.com/maps/documentation/directions/intro) - Directions between multiple locations.
- [x] [Distance Matrix](https://developers.google.com/maps/documentation/distance-matrix/intro) - Travel time and distance for multiple destinations. (contributed by @bnns)
- [ ] [Elevation](https://developers.google.com/maps/documentation/elevation/intro) - Elevation data for any point in the world.
- [x] [Geocoding](https://developers.google.com/maps/documentation/geocoding/intro) - Converts between addresses and geographic coordinates.
- [ ] [Place Add](https://developers.google.com/places/web-service/add-place) - Allows you to supplement the data in Google's Places database with data from your application.
- [x] [Place Autocomplete](https://developers.google.com/places/web-service/autocomplete) - can be used to automatically fill in the name and/or address of a place as you type.
- [x] [Place Details](https://developers.google.com/places/web-service/details) - Returns more detailed information about a specific Place, including user reviews.
- [ ] [Place Photo](https://developers.google.com/places/web-service/photos) - Gives you access to the millions of Place related photos stored in Google's Place database
- [x] [Place Nearby Search](https://developers.google.com/places/web-service/search#PlaceSearchRequests) - Returns a list of places within a specified area based on a user's location or search string. (contributed by @distortia)
- [x] [Query Autocomplete](https://developers.google.com/places/web-service/query) - can be used to provide a query prediction service for text-based geographic searches, by returning suggested queries as you type.
- [x] [Timezone](https://developers.google.com/maps/documentation/timezone/intro) - Time zone data for anywhere in the world.

## Methods

- `distance/3`
- `directions/3`
- `geocode/2`
- `place_autocomplete/2`
- `place_query/2`
- `place_nearby/3`
- `place_details/2`
- `timezone/2`
- `get/2`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `google_maps` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:google_maps, "~> 0.8"}]
end
```

2. Ensure `google_maps` is started before your application:

```elixir
def application do
  [applications: [:google_maps]]
end
```

3. In your application's `config/config.exs`, add:

```elixir
config :google_maps,
  api_key: "YOUR API KEY HERE"
```

Or you can use `GOOGLE_MAPS_API_KEY` system environment variable when running in `iex`.

If separate API keys are needed per request, they can be set through
`key` option, i.e.:

```elixir
GoogleMaps.directions("Toronto", "Montreal", key: API_KEY_1)
```

## Development

You'll need a [Google API key](https://console.developers.google.com) with
all relevant APIs (see above) enabled. Add your key to the environment as specified above.

Then run tests:

`mix deps.get test`

`mix test`
