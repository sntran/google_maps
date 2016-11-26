# Google Maps

Elixir wrapper around Google Maps APIs

## Services

- [x] Directions - Directions between multiple locations.
- [ ] Distance Matrix - Travel time and distance for multiple destinations.
- [ ] Elevation - Elevation data for any point in the world.
- [ ] Geocoding - Converts between addresses and geographic coordinates.
- [ ] Place Add - Allows you to supplement the data in Google's Places database with data from your application.
- [ ] Place Autocomplete - can be used to automatically fill in the name and/or address of a place as you type.
- [ ] Place Details - Returns more detailed information about a specific Place, including user reviews.
- [ ] Place Photo - Gives you access to the millions of Place related photos stored in Google's Place database
- [ ] Place Search - Returns a list of places based on a user's location or search string.
- [ ] Query Autocomplete - can be used to provide a query prediction service for text-based geographic searches, by returning suggested queries as you type.
- [ ] Timezone - Time zone data for anywhere in the world.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `google_maps` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:google_maps, "~> 0.1.0"}]
    end
    ```

  2. Ensure `google_maps` is started before your application:

    ```elixir
    def application do
      [applications: [:google_maps]]
    end
    ```

