import 'babel-polyfill'
import '../scripts/govuk_assets_import'
import '../styles/application.scss'
import '../scripts/components'
import { initAll } from 'govuk-frontend'
import initLocationsMap from "../scripts/locations-map";

initAll()


window.initLocationsMap = initLocationsMap;
