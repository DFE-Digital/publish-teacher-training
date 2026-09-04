# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Blazer" do
  let(:data_source) { Blazer.data_sources["main"] }

  it "can reach the database its data source points at" do
    # A URL Blazer cannot connect to breaks the whole suite rather than just
    # Blazer: it registers the pool, and setup_transactional_fixtures then pins
    # every registered pool in every later example. Blazer stays quiet about it,
    # rescuing the failure and rendering its query page anyway, so assert on the
    # connection here.
    result = data_source.run_statement("SELECT 1 AS one")

    expect(result.error).to be_nil
    expect(result.rows).to eq([[1]])
  end

  it "can run every smart column and smart variable lookup" do
    # These name tables and columns in config/blazer.yml, where nothing checks
    # them. A typo surfaces as an empty dropdown or an unresolved id, months
    # later, to whoever is mid-investigation.
    lookups = data_source.smart_columns.values.map { |sql| sql.sub("{value}", "(NULL)") } +
      data_source.smart_variables.values

    expect(lookups).not_to be_empty

    lookups.each do |sql|
      expect(data_source.run_statement(sql).error).to be_nil, "#{sql.inspect} failed"
    end
  end

  it "names query creators with a method User actually has" do
    # Blazer renders creators as `creator.try(Blazer.user_name)`, so a name it
    # does not respond to fails silently and the column is blank for everyone
    # but you. Blazer's own default, :name, is one of those.
    expect(User.new).to respond_to(Blazer.user_name)
  end

  it "defaults the recruitment cycle to the one the app is running" do
    # variable_defaults is a static hash read once at boot, so it cannot follow
    # the cycle on its own. This fails at the next rollover, which is the point:
    # the build tells you to change the one line rather than everyone quietly
    # querying last year.
    expect(data_source.variable_defaults["recruitment_cycle_year"])
      .to eq(Find::CycleTimetable.current_year.to_s)
  end

  it "links columns to paths the app serves" do
    # Blazer only interpolates {value}, so a linked column has to name a route
    # keyed on that column alone. Blazer is mounted on the publish host, so
    # recognise the paths against it.
    host = Settings.publish_hosts.first
    paths = data_source.linked_columns.values.grep_v(%r{\Ahttps?://})

    expect(paths).not_to be_empty

    paths.each do |path|
      recognised = Rails.application.routes.recognize_path("http://#{host}#{path.sub('{value}', 'ABC')}", method: :get)

      expect(recognised).to be_present, "#{path.inspect} is not a route"
    end
  end
end
