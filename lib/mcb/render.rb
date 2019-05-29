module MCB
  module Render
    class << self
      def campuses_table(campuses, name: 'Campuses')
        if campuses.all? { |campuses| campuses.respond_to? :keys }
          campuses = hashes_to_ostructs campuses
        end

        campuses_table = Tabulo::Table.new campuses,
                                           :campus_code,
                                           :name,
                                           :region_code

        [
          "#{name}:",
          *campuses_table.pack(max_table_width: nil),
          campuses_table.horizontal_rule
        ]
      end

      def contacts_table(contacts, name: 'Contacts')
        if contacts.all? { |contact| contact.respond_to? :keys }
          contacts = hashes_to_ostructs contacts
        end

        contacts_table = Tabulo::Table.new contacts,
                                           :type,
                                           :name,
                                           :email,
                                           :telephone

        [
          "#{name}:",
          *contacts_table.pack(max_table_width: nil),
          contacts_table.horizontal_rule
        ]
      end

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

      def sites_table(sites, name: 'Sites')
        if sites.all? { |site| site.respond_to? :keys }
          sites = hashes_to_ostructs sites
        end

        sites_table = Tabulo::Table.new sites,
                                        :code,
                                        :location_name,
                                        :address1,
                                        :address2,
                                        :address3,
                                        :address4,
                                        :postcode,
                                        :region_code

        [
          "#{name}:",
          *sites_table.pack(max_table_width: nil),
          sites_table.horizontal_rule
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
