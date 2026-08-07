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

      # `value` names the attribute the checkboxes are keyed by, so each
      # suggestion can be paired with its row: the course schools page keys on
      # the site id, the add course wizard on the school uuid.
      def initialize(schools:, value: :id)
        @schools = schools
        @value = value

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
        options = schools.map do |school|
          [
            school.location_name,
            school.public_send(value),
            {
              "data-synonyms" => synonyms_for(school).join("|"),
              "data-append" => append_for(school),
            }.compact,
          ]
        end

        options.unshift([nil, nil, nil])
      end

    private

      attr_reader :schools, :value

      def synonyms_for(school)
        [school.urn, school.postcode, school.postcode&.delete(" ")].compact_blank.uniq
      end

      # Plain text, not markup: dfe-autocomplete escapes an option's appended
      # text before rendering it, so a <strong> here would reach the dropdown as
      # its own source. (The gem's own Ruby helper still wraps this in a tag,
      # which its renderer no longer honours.)
      def append_for(school)
        context = [school.town, school.postcode].compact_blank.join(", ")

        "(#{context})" if context.present?
      end
    end
  end
end
