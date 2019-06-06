module MCB
  module Render
    module APIV1
      class << self
        include MCB::Render

        def contacts_table(contacts, name: 'Contacts')
          super(hashes_to_ostructs(contacts),
                name: name)
        end

        def course_record(course, name: 'Course')
          course_table = Terminal::Table.new rows: course

          [
            "#{name}:",
            *course_table,
          ]
        end

        def course_site_statuses_table(site_statuses, name: 'Campuses')
          super(hashes_to_ostructs(site_statuses),
                name: name)
        end

        def course_site_statuses_table_columns
          %i[campus_code name vac_status status publish course_open_date]
        end

        def providers_table(providers, name: 'Providers', add_columns: [])
          super(hashes_to_ostructs(providers),
                name: name,
                add_columns: add_columns)
        end

        def providers_table_columns
          %i[institution_name institution_code]
        end

        def sites_table(sites, name: 'Sites')
          super(hashes_to_ostructs(sites),
                name: name)
        end

        def subjects_table(subjects, name: 'Subjects')
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
