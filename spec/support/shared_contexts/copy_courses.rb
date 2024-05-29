# frozen_string_literal: true

require 'rails_helper'

shared_context 'copy_courses' do
  let!(:course2) do
    create(
      :course,
      provider:,
      name: 'Biology',
      enrichments: [course2_enrichment]
    )
  end

  let!(:course3) do
    create(:course,
           provider:,
           name: 'Biology',
           enrichments: [course3_enrichment])
  end

  let(:course2_enrichment) do
    build(:course_enrichment,
          interview_process: 'Course 2 - Interview process',
          how_school_placements_work: 'Course 2 - How teaching placements work')
  end

  let(:course3_enrichment) do
    build(:course_enrichment,
          interview_process: nil,
          how_school_placements_work: 'Course 3 - this is how placements work here')
  end
end
