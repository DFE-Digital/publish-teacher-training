module Find
  module ResultFilters
    class FiltersView
      def initialize(params:)
        @params = params
      end

      def qts_only_checked?
        checked?("qts")
      end

      def pgde_pgce_with_qts_checked?
        checked?("pgce_with_qts")
      end

      def other_checked?
        checked?("pgce pgde") || checked?("pgce") || checked?("pgde")
      end

      def qualification_selected?
        return false if params[:qualification].nil?

        params[:qualification].any?
      end

      def qualification_params_nil?
        params[:qualification].nil?
      end

      def location_query?
        params[:l] == "1"
      end

      def across_england_query?
        params[:l] == "2"
      end

      def provider_query?
        params[:l] == "3"
      end

      def funding_checked?
        params[:funding] == "salary"
      end

      def engineers_teach_physics_checked?
        params[:engineers_teach_physics] == "true"
      end

      def send_checked?
        params[:send_courses] == "true"
      end

      def visa_checked?
        params[:can_sponsor_visa] == "true"
      end

      def has_vacancies_checked?
        params[:has_vacancies] == "true"
      end

      def full_time_checked?
        return false if params[:study_type].nil?

        params[:study_type].include?("full_time")
      end

      def part_time_checked?
        return false if params[:study_type].nil?

        params[:study_type].include?("part_time")
      end

      def default_study_types_to_true
        return true if params[:study_type].nil?

        params[:study_type] == "full_time_or_part_time"
      end

      def default_with_vacancies_to_true
        params[:has_vacancies].nil?
      end

      def all_courses_radio_chosen?
        params[:degree_required] == "show_all_courses"
      end

      def default_all_courses_radio_to_true
        params[:degree_required].nil?
      end

      def two_two_radio_chosen?
        params[:degree_required] == "two_two"
      end

      def third_class_radio_chosen?
        params[:degree_required] == "third_class"
      end

      def any_degree_grade_radio_chosen?
        params[:degree_required] == "not_required"
      end

      def location_query_params
        {
          c: params[:c],
          l: params[:l],
          lq: params[:lq],
          latitude: params[:latitude],
          loc: params[:loc],
          longitude: params[:longitude],
          query: params["provider.provider_name"],
          radius: params[:radius],
          sortby: params[:sortby],
        }
      end

    private

      attr_reader :params

      def checked?(param_value)
        return false if params[:qualification].nil?

        param_value.in?(params[:qualification])
      end
    end
  end
end
