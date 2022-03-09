import createPopupClass from "./map-popup";

const initLocationsMap = () => {
  const $map = document.getElementById("locations-map");
  const trainingLocations = window.trainingLocations
    .filter(({lat, lng}) => lat !== "" && lng !== "")
    .map(location => {
      location.lat = parseFloat(location.lat);
      location.lng = parseFloat(location.lng);
      return location;
    })

  if (trainingLocations.length === 0) {
    console.error("Failed to initialise map: center is impossible to display, because none of the locations have a lat/lng.");
    $map.style.display = 'none';
    return;
  }

  const Popup = createPopupClass();
  const bounds = new google.maps.LatLngBounds();

  const centerLat = trainingLocations[0].lat;
  const centerLng = trainingLocations[0].lng;

  const map = new google.maps.Map($map, {
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false,
    scaleControl: false,
    streetViewControl: false,
    rotateControl: false,
    fullscreenControl: true,
    fullscreenControlOptions: {
      position: google.maps.ControlPosition.RIGHT_BOTTOM
    },
    zoom: 11,
    center: {
      lat: centerLat,
      lng: centerLng
    },
    styles: [
      {
        featureType: "poi.business",
        stylers: [
          {
            visibility: "off"
          }
        ]
      },
      {
        featureType: "poi.park",
        elementType: "labels.text",
        stylers: [
          {
            visibility: "off"
          }
        ]
      }
    ]
  });

  const locations = window.trainingLocations;

  for (let i = 0, length = locations.length; i < length; i++) {
    const location = locations[i];
    const latLng = new google.maps.LatLng(location.lat, location.lng);

    const closedContent = document.createElement("div");
    closedContent.innerHTML = location.name;

    const openContent = document.createElement("div");
    if (location.vacancies) {
      openContent.insertAdjacentHTML(
        "beforeend",
        `<div class="govuk-tag govuk-tag--no-content govuk-!-margin-bottom-2">${ location.vacancies }</div>`
      );
    }
    if (location.address) {
      openContent.insertAdjacentHTML(
        "beforeend",
        `<p class="govuk-body">${location.address}</p>`
      );
    }

    const popup = new Popup(latLng, closedContent, openContent);
    popup.setMap(map);

    // Extend the bounds by the locations so we get a decent number as part of the first view.
    bounds.extend(latLng);
  }

  // Use provider address to center and zoom when only one location
  if (locations.length > 1) {
    map.fitBounds(bounds);
    map.panToBounds(bounds);
  }
};

export default initLocationsMap;
