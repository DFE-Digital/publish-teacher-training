Rails.application.config.assets.paths << Rails.root.join("node_modules")

# GOVUK Deps
Rails.application.config.assets.precompile += %w[
  accessible-autocomplete/dist/accessible-autocomplete.min.css
  govuk-frontend/govuk/assets/images/govuk-opengraph-image.png
  govuk-frontend/govuk/assets/images/favicon.ico
  govuk-frontend/govuk/assets/images/govuk-mask-icon.svg
  govuk-frontend/govuk/assets/images/govuk-apple-touch-icon.png
  govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-152x152.png
  govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-167x167.png
  govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-180x180.png
]
