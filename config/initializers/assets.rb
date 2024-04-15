# frozen_string_literal: true

# Run bin/rails assets:reveal to see what gets bundled

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# govuk-frontend related assets
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets/images')
Rails.application.config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets/fonts')
# This pulls in all assets from this directory. There is no way to filter single files yet.
# https://github.com/rails/propshaft/issues/178
Rails.application.config.assets.paths << Rails.root.join('node_modules/accessible-autocomplete/dist')
