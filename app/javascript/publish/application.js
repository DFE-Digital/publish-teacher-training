// Entry point for the build script in your package.json
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import autocompleteSetup from './autocomplete'
import L from 'leaflet'
import initLocationsMap from './locations-map'
import FilterToggle from './filters'

window.jQuery = jQuery
window.$ = jQuery
window.L = L
window.initLocationsMap = initLocationsMap

initAll()
FilterToggle.init()

document.addEventListener('DOMContentLoaded', () => {
  const mapTarget = document.getElementById('map')
  if (!mapTarget) return

  const mapData = JSON.parse(mapTarget.dataset.map)
  const map = L.map('map')

  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map)

  map.fitBounds(mapData)
  mapData.forEach(([lat, lng, name]) => {
    L.marker([lat, lng]).addTo(map)
      .bindPopup(name)
      .openPopup()
  })
})

autocompleteSetup()
