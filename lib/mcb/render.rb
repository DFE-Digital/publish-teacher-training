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

    # Render a user for output to the terminal.
    #
    # Takes care of rendering out all the attributes and related objects in
    # the correct format. Associations are specified as params to allow the
    # caller to decide how they are retrieved (ActiveRecord objects will
    # access attributes and associations differently from JSON API
    # responses).
    def user(user,
             providers:)
      [
        user_record(user),
        "\n",
        providers_table(providers, name: "Has access to providers"),
      ]
    end

    def user_record(user, name: 'User')
      user_table = Terminal::Table.new rows: user

      [
        "#{name}:",
        *user_table,
      ]
    end

    # Render a course for output to the terminal.
    #
    # Takes care of rendering out all the attributes and related objects in
    # the correct format. Associations are specified as params to allow the
    # caller to decide how they are retrieved (ActiveRecord objects will
    # access attributes and associations differently from JSON API
    # responses).
    def course(course,
               provider:,
               accrediting_provider:,
               subjects:,
               site_statuses:,
               enrichments:,
               recruitment_cycle:)
      [
        course_record(course),
        "\n",
        providers_table([provider], name: "Provider"),
        "\n",
        providers_table(
          [accrediting_provider],
          name: "Accredited body",
          add_columns: [[:accrediting_provider, header: 'accrediting']]
        ),
        "\n",
        recruitment_cycle_table(recruitment_cycle),
        "\n",
        subjects_table(subjects),
        "\n",
        course_site_statuses_table(site_statuses),
        "\n",
        unless enrichments.nil?
          course_enrichments_table(enrichments)
        end
      ]
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

    def organisations_table(organisations,
                        name: 'Organisations',
                        add_columns: [])
      return if organisations.nil?

      [
        "#{name}:",
        render_table_or_none(organisations, organisations_table_columns + add_columns)
      ]
    end

    def organisations_table_columns
      [
        :id,
        [:name, header: 'name'],
      ]
    end

    def providers_table(providers,
                        name: 'Providers',
                        add_columns: [],
                        **opts)
      return if providers.nil?

      columns =
        providers_table_columns(extended: opts[:'extended-listing']) + add_columns

      [
        "#{name}:",
        render_table_or_none(providers, columns)
      ]
    end

    def providers_table_columns(extended: false)
      if extended
        [
          :id,
          [:provider_name, header: 'name'],
          [:provider_code, header: 'code'],
          [:organisation_id, ->(p) { p.organisation_ids.first }],
          [:organisation, ->(p) { p.organisations.first&.name }],
          [:provider_type, header: 'type'],
          [:courses, ->(p) { p.courses.count }],
          # :nctl_organisation_id,
          # [:nctl_organisation, ->(p) { p.nctl_organisation&.name }],
          :postcode,
        ]
      else
        [
          :id,
          [:provider_name, header: 'name'],
          [:provider_code, header: 'code'],
          [:organisation_id, ->(p) { p.organisation_ids.first }],
          [:provider_type, header: 'type'],
          :nctl_organisation_id
        ]
      end
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

    def recruitment_cycle_table(recruitment_cycle)
      [
        "Recruitment cycle:",
        render_table_or_none([recruitment_cycle], %i[year application_start_date application_end_date])
      ]
    end

    def subjects_table_columns
      %i[subject_code subject_name]
    end

    # Render a provider for output to the terminal.
    #
    # Takes care of rendering out all the attributes and related objects in
    # the correct format. Associations are specified as params to allow the
    # caller to decide how they are retrieved (ActiveRecord objects will
    # access attributes and associations differently from JSON API
    # responses).
    def provider(provider,
                 contacts:,
                 organisations:)
      [
        provider_record(provider),
        "\n",
        contacts_table(contacts),
        "\n",
        organisations_table(organisations),
      ]
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
