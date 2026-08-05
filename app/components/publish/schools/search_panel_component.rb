module Publish
  module Schools
    # The search box above a list of school checkboxes, shared by the course
    # schools edit page and the add course wizard's schools step.
    #
    # Everything here is inert until the schools-list Stimulus controller
    # connects: the panel is hidden, the select carries no name and both actions
    # are plain buttons, so a provider without JavaScript sees - and submits -
    # exactly what they did before.
    class SearchPanelComponent < ViewComponent::Base
      SELECT_ID = "school-search".freeze

      def initialize(sites:)
        @sites = sites

        super()
      end

      # One <option> per school, in the shape options_for_select expects:
      # [label, value, html_attributes]. This mirrors the dfe-autocomplete gem's
      # own helper, which we cannot call directly because a Site is named by
      # `location_name` and we want the space-stripped postcode as well.
      #
      # The postcode and URN ride along as synonyms, which dfe-autocomplete
      # matches but never displays. The town is deliberately not a synonym - the
      # box only promises name, postcode and URN - so it appears in `data-append`
      # instead, which is context for the dropdown and is never matched.
      def autocomplete_options
        options = sites.map do |site|
          [
            site.location_name,
            site.id,
            {
              "data-synonyms" => synonyms_for(site).join("|"),
              "data-append" => append_for(site),
            }.compact,
          ]
        end

        options.unshift([nil, nil, nil])
      end

    private

      attr_reader :sites

      def synonyms_for(site)
        [site.urn, site.postcode, site.postcode&.delete(" ")].compact_blank.uniq
      end

      def append_for(site)
        context = [site.town, site.postcode].compact_blank.join(", ")

        tag.strong("(#{context})") if context.present?
      end
    end
  end
end
