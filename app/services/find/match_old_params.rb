# frozen_string_literal: true

module Find
  class MatchOldParams
    include ServicePattern

    FILTERS = {
      'senCourses' => 'send_courses',
      'lat' => 'latitude',
      'lng' => 'longitude',
      'rad' => 'radius',
      'query' => 'provider.provider_name',
      'hasvacancies' => 'has_vacancies',
      'subject_codes' => 'subjects'
    }.freeze

    STUDY_FILTERS = {
      'parttime' => 'part_time',
      'fulltime' => 'full_time'
    }.freeze

    QAULIFICATION_FILTERS = {
      'Other' => 'pgce pgde',
      'PgdePgceWithQts' => 'pgce_with_qts',
      'QtsOnly' => 'qts'
    }.freeze

    def initialize(request_params)
      @request_params = request_params
    end

    def call
      sortby_and_funding
      qualification_filters
      filters
      study_filters

      @request_params
    end

    private

    def sortby_and_funding
      @request_params['sortby'] = 'distance' if @request_params['sortby'] == '2'
      @request_params['funding'] = 'salary' if @request_params['funding'] == '8'
    end

    def qualification_filters
      return unless @request_params['qualifications']

      @request_params['qualification'] = @request_params.delete('qualifications')
      @request_params['qualification'] = @request_params['qualification'].split(',') if @request_params['qualification'].is_a?(String)

      QAULIFICATION_FILTERS.each do |k, v|
        if @request_params['qualification'].include?(k)
          @request_params['qualification'] -= [k]
          @request_params['qualification'] |= [v]
        end
      end
    end

    def filters
      return unless FILTERS.keys & @request_params.keys

      (FILTERS.keys & @request_params.keys).each do |k|
        @request_params[FILTERS[k]] = @request_params.delete k
      end
    end

    def study_filters
      return unless STUDY_FILTERS.keys & @request_params.keys

      (STUDY_FILTERS.keys & @request_params.keys).each do |k|
        next unless @request_params[k] == 'true'

        @request_params['study_type'] ||= []
        @request_params['study_type'] |= [STUDY_FILTERS[k]]
        @request_params.delete(k)
      end
    end
  end
end
