# frozen_string_literal: true

require "rails_helper"

# The Ruby counterpart of schoolChanges() in
# app/javascript/publish/schools_changes.js, case for case, so the attach page
# and the bulk update pages cannot describe the same change differently.
describe Publish::Schools::SchoolChanges do
  let(:provider) { create(:provider) }

  let(:ash) { school("Ash Academy") }
  let(:beech) { school("Beech School") }
  let(:cedar) { school("Cedar School") }

  # Ash and Beech are on the course; Cedar is not.
  let(:baseline) { [ash.uuid, beech.uuid] }
  let(:schools) { [ash, beech, cedar] }

  def school(name)
    create(:site, :with_provider_school, provider:, location_name: name)
    provider.reload.schools.joins(:gias_school).find_by!(gias_school: { name: name })
  end

  def changes(*ticked, all: schools, was: baseline)
    described_class.new(schools: all, submitted: ticked.map(&:uuid), baseline: was)
  end

  it "reports nothing when the ticks match what is attached" do
    result = changes(ash, beech)

    expect(result).not_to be_changed
    expect(result.added_names).to be_empty
    expect(result.removed_names).to be_empty
  end

  it "names a school ticked that was not attached" do
    result = changes(ash, beech, cedar)

    expect(result).to be_changed
    expect(result.added_names).to eq(["Cedar School"])
  end

  it "names an attached school no longer ticked" do
    expect(changes(beech).removed_names).to eq(["Ash Academy"])
  end

  it "reports both halves at once" do
    result = changes(beech, cedar)

    expect(result.added_names).to eq(["Cedar School"])
    expect(result.removed_names).to eq(["Ash Academy"])
  end

  it "keeps the order the schools are listed in" do
    expect(changes.removed_names).to eq(["Ash Academy", "Beech School"])
  end

  it "says all when every school ends up ticked" do
    result = changes(ash, beech, cedar)

    expect(result).to be_adding_all
    expect(result).not_to be_removing_all
  end

  it "says all when no school is left ticked" do
    result = changes

    expect(result).to be_removing_all
    expect(result).not_to be_adding_all
  end

  it "does not say all for a partial selection" do
    result = changes(ash)

    expect(result).not_to be_adding_all
    expect(result).not_to be_removing_all
  end

  it "treats a course with nothing attached as adding only" do
    result = changes(cedar, was: [])

    expect(result.added_names).to eq(["Cedar School"])
    expect(result.removed_names).to be_empty
  end

  it "reports nothing for an empty list" do
    expect(changes(all: [], was: [])).not_to be_changed
  end

  # A school taken off the provider's list while the provider was choosing is
  # not written either, so it is not named.
  it "leaves out a school that is no longer in the list" do
    gone = school("Damson Primary School")
    result = described_class.new(
      schools: [ash, beech, cedar],
      submitted: [ash.uuid, beech.uuid, gone.uuid],
      baseline:,
    )

    expect(result.added_names).to be_empty
  end
end
