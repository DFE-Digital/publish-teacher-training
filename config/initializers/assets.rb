# frozen_string_literal: true

# govuk-frontend related assets
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets/images')
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets/fonts')

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# GOVUK Deps
Rails.application.config.assets.precompile += %w[
  accessible-autocomplete/dist/accessible-autocomplete.min.css
]
