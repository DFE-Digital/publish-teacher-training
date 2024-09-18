# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Publish::Providers::SchoolPlacements::ExplainerComponent, type: :component do
  it 'renders School Placement information for the Provider' do
    render_inline(described_class.new)

    expect(page).to have_text('A school placement is a school where the candidate might be placed in to do classroom experience, for example. Add placement schools then attach them to any of your courses from the ‘Basic details’ tab on the course page.')
    expect(page).to have_text('Candidates will see a list of the attached placements in the ‘Training locations’ section on the course page on Find to help them get a sense of the areas your organisation operates in.')
  end
end
