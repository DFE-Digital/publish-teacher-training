# frozen_string_literal: true

module Find
  module ViewHelper
    SHORTAGE_SUBJECT_CODES = %w[
      C1
      F1
      11
      DT
      G1
      F3
      F8
      A1
      A2
      Q3
      15
      17
      18
      19
      A0
      20
      24
      21
      22
    ].freeze

    def permitted_referrer?
      return false if request.referer.blank?

      [*Settings.find_hosts, *Settings.publish_hosts].include?(referer.host)
    end

    def course_back_link
      if referer.request_uri =~ %r{^/candidate/saved-courses}
        find_candidate_saved_courses_path
      elsif referer.request_uri =~ %r{^/results}
        request.referer
      elsif referer && cookies[:results_path]&.match?(%r{^/results})
        cookies[:results_path]
      end
    end

    def show_salary_subject_message?(filters)
      funding_selected =
        (Array(filters["funding"]) & %w[salary apprenticeship]).any?

      shortage_subject_selected =
        (Array(filters["subjects"]) & SHORTAGE_SUBJECT_CODES).any?

      funding_selected && shortage_subject_selected
    end

  private

    def referer
      URI.parse(request.referer)
    end
  end
end
