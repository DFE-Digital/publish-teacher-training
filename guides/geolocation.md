# Geolocation

We use geolocation services in two ways.

1. Autocomplete a users text input when searching for a location.
2. Retreiving the geographic coordinates of the corresponding place.

### *Example:*
- A user wants to find the courses near Bristol and order the courses by their distance to Bristol.

#### Scenario
1. First the user types 'Bristol' into the search for the location.
2. This is the Google geocode service. It returns a matching place and location types (postcode, administrative_area_2, etc.).
3. We then pass the autocompleted place name to get the coordinates of the place using the geocode API.
4. When we get the coordinates, we can use postgis to select all the courses whose schools are within a given distance of this place.
5. We return the filtered and sorted list of courses.

## Classes

### `Geolocation::Suggestions`

We take user input for a place or region in the UK to search for courses. This query is sent to Google and returns the responses to the user.
When the user chooses an option and submits their selection we then need to get the coordtinates for that place.

### `Geolocation::CoordinatesQuery`

We take the autocompleted place name from the `Geolocation::Suggestions` and use that to fetch the coordinates of the place from the geocode API in Google.
