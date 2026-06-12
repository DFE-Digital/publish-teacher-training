// Entry point for the build script in your package.json
import jQuery from "jquery";
import { initAll } from "govuk-frontend";

import FilterToggle from "./filters";

import { Application } from "@hotwired/stimulus";
import InputPreviewController from "./courses/input_preview_controller";
import SelectAllCheckboxesController from "./controllers/select_all_checkboxes_controller";
import CopyLinkController from "./controllers/copy_link_controller";
import RemoteAutocompleteController from "../shared/remote_autocomplete_controller";
import SchoolSearchController from "./controllers/school_search_controller";
import CourseFiltersController from "./controllers/course_filters_controller";
import ShowMoreController from "./controllers/show_more_controller";
import SchoolDiffController from "./controllers/school_diff_controller";

window.jQuery = jQuery;
window.$ = jQuery;

initAll();
FilterToggle.init();

window.Stimulus = Application.start();
Stimulus.register("input-preview", InputPreviewController);
Stimulus.register("select-all-checkboxes", SelectAllCheckboxesController);
Stimulus.register("copy-link", CopyLinkController);
Stimulus.register("remote-autocomplete", RemoteAutocompleteController);
Stimulus.register("school-search", SchoolSearchController);
Stimulus.register("course-filters", CourseFiltersController);
Stimulus.register("show-more", ShowMoreController);
Stimulus.register("school-diff", SchoolDiffController);
