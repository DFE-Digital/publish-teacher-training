module MCB
  module Render
    class << self
      def course_record(course, name: 'Course')
        course_table = Terminal::Table.new rows: course

        [
          "#{name}:",
          *course_table,
        ]
      end

      def provider_record(provider, name: 'Provider')
        provider_table = Terminal::Table.new rows: provider

        [
          "#{name}:",
          *provider_table,
        ]
      end

      def site_statuses_table(site_statuses, name: 'Site Statuses')
        if site_statuses.all? { |site_status| site_status.respond_to? :keys }
          site_statuses = hashes_to_ostructs site_statuses
        end

        site_statuses_table = Tabulo::Table.new site_statuses,
                                                :campus_code,
                                                :name,
                                                :vac_status,
                                                :publish,
                                                :status,
                                                :course_open_date

        [
          "#{name}:",
          *site_statuses_table.pack(max_table_width: nil),
          site_statuses_table.horizontal_rule
        ]
      end

      def subjects_table(subjects, name: 'Subjects')
        if subjects.all? { |subject| subject.respond_to? :keys }
          subjects = hashes_to_ostructs subjects
        end

        subjects_table = Tabulo::Table.new subjects,
                                           :subject_code,
                                           :subject_name

        [
          "#{name}:",
          *subjects_table.pack(max_table_width: nil),
          subjects_table.horizontal_rule
        ]
      end

      private

      def hashes_to_ostructs(hashes)
        hashes.map { |hash| OpenStruct.new(hash) }
      end
    end
  end
end
