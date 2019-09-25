module MCB
  module Render
    module APIV1
      class << self
        include MCB::Render

        def campuses_table(campuses, name: "Campuses")
          return if campuses.nil?

          [
            "#{name}:",
            render_table_or_none(hashes_to_ostructs(campuses),
                                 campuses_table_columns),
          ]
        end

        def campuses_table_columns
          %i[campus_code name region_code]
        end

        def contacts_table(contacts, name: "Contacts")
          super(hashes_to_ostructs(contacts),
                name: name)
        end

        def course(course)
          # duplicate this so we can remove keys we don't want displayed, as
          # course_record below just outputs all the key-value pairs in course
          render_course = course.dup

          super(
            render_course,
            provider:             render_course.delete("provider"),
            accrediting_provider: render_course.delete("accrediting_provider"),
            subjects:             render_course.delete("subjects"),
            site_statuses:        render_course.delete("campus_statuses"),
            enrichments:          nil,
            recruitment_cycle:    nil,
          )
        end

        def course_record(course, name: "Course")
          course_table = Terminal::Table.new rows: course

          [
            "#{name}:",
            *course_table,
          ]
        end

        def course_site_statuses_table(site_statuses, name: "Campuses")
          super(hashes_to_ostructs(site_statuses),
                name: name)
        end

        def course_site_statuses_table_columns
          %i[campus_code name vac_status status publish course_open_date]
        end

        def providers_table(providers, name: "Providers", add_columns: [])
          super(hashes_to_ostructs(providers),
                name: name,
                add_columns: add_columns)
        end

        def providers_table_columns(*)
          %i[institution_name institution_code]
        end

        def sites_table(sites, name: "Sites")
          super(hashes_to_ostructs(sites),
                name: name)
        end

        def subjects_table(subjects, name: "Subjects")
          super(hashes_to_ostructs(subjects),
                name: name)
        end

      private

        def hashes_to_ostructs(hashes_or_ostructs)
          hashes_or_ostructs.map do |hash_or_ostruct|
            if hash_or_ostruct.is_a? OpenStruct
              hash_or_ostruct
            else
              OpenStruct.new(hash_or_ostruct)
            end
          end
        end
      end
    end
  end
end
