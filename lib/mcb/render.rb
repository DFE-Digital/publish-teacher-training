module MCB
  module Render
    def contacts_table(contacts, name: 'Contacts')
      return if contacts.nil?

      [
        "#{name}:",
        render_table_or_none(contacts, contacts_table_columns)
      ]
    end

    def contacts_table_columns
      %i[type name email telephone]
    end

    def course_enrichments_table(enrichments, name: 'Course Enrichments')
      return if enrichments.nil?

      [
        "#{name}:",
        render_table_or_none(enrichments, course_enrichments_table_columns)
      ]
    end

    def course_enrichments_table_columns
      [
        :id,
        :status,
        [:last_published, ->(ce) { ce.last_published_timestamp_utc }]
      ]
    end

    def course_record(course, name: 'Course')
      course_table = Terminal::Table.new rows: course

      [
        "#{name}:",
        *course_table,
      ]
    end

    def course_site_statuses_table(site_statuses,
                                   name: 'Site Statuses',
                                   add_columns: [])
      columns = course_site_statuses_table_columns + add_columns

      site_statuses_table = Tabulo::Table.new site_statuses do |t|
        add_columns_to_table columns, table: t
      end

      [
        "#{name}:",
        *site_statuses_table.pack(max_table_width: nil),
        site_statuses_table.horizontal_rule
      ]
    end

    def course_site_statuses_table_columns
      [
        :id,
        [:code, ->(ss) { ss.site.code }],
        [:location_name, ->(ss) { ss.site.location_name }],
        :vac_status,
        :status,
        :publish,
        :applications_accepted_from
      ]
    end

    def provider_record(provider, name: 'Provider')
      provider = provider.attributes if provider.respond_to?(:attributes)

      provider_table = Terminal::Table.new rows: provider

      [
        "#{name}:",
        *provider_table,
      ]
    end

    def providers_table(providers,
                        name: 'Providers',
                        add_columns: [])
      return if providers.nil?

      [
        "#{name}:",
        render_table_or_none(providers, providers_table_columns + add_columns)
      ]
    end

    def providers_table_columns
      [
        :id,
        [:provider_name, header: 'name'],
        [:provider_code, header: 'code']
      ]
    end

    def sites_table(sites, name: 'Sites')
      return if sites.nil?

      [
        "#{name}:",
        render_table_or_none(sites, sites_table_columns)
      ]
    end

    def sites_table_columns
      %i[code location_name address1 address2 address3 address4 postcode
         region_code]
    end

    def subjects_table(subjects, name: 'Subjects')
      return if subjects.nil?

      [
        "#{name}:",
        render_table_or_none(subjects, subjects_table_columns)
      ]
    end

    def subjects_table_columns
      %i[subject_code subject_name]
    end

  private

    def add_columns_to_table(columns, table:)
      columns.each do |column|
        # An Array will have to be splat-expanded ...
        #
        # e.g. [:provider_name, header: 'name']
        if column.is_a? Array
          # A Proc will have to be block-annotated.
          #
          # e.g. [:code, ->(ss) { ss.site.code }]
          if column.last.is_a? Proc
            block = column.pop
            table.add_column(*column, &block)
          else
            table.add_column(*column)
          end
        else
          table.add_column column
        end
      end
    end

    def render_table_or_none(rows, columns)
      if rows.any?
        table = Tabulo::Table.new rows do |t|
          add_columns_to_table columns, table: t
        end

        [
          table.pack(max_table_width: nil),
          table.horizontal_rule
        ]
      else
        ['-none-']
      end
    end
  end
end
