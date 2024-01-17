# frozen_string_literal: true

require 'rails_helper'

describe Configs::CourseInformation do
  let(:scitt_provider) { build(:provider, :scitt, provider_code:) }
  let(:university_provider) { build(:provider, :university, provider_code:) }

  let(:he_course) { build(:course, :with_higher_education, provider:, course_code:) }
  let(:scitt_course) { build(:course, :with_scitt, provider:, course_code:) }

  let(:provider_code) { 'XXX' }
  let(:course_code) { 'XXX' }

  describe '#show_placement_guidance?' do
    let(:course) { scitt_course }
    let(:provider) { university_provider }
    let(:type) { :provider_type }

    context 'when University providers provider code is present' do
      let(:provider_code) { 'B31' }

      it 'returns false' do
        obj = described_class.new(course)

        expect(obj.show_placement_guidance?(type)).to be(false)
      end
    end

    context 'when University providers provider_code is absent' do
      it 'returns true' do
        obj = described_class.new(course)

        expect(obj.show_placement_guidance?(type)).to be(true)
      end
    end

    context 'when SCITT course with provider_code present' do
      let(:provider) { scitt_provider }
      let(:type) { :program_type }
      let(:provider_code) { 'E65' }

      it 'returns false' do
        obj = described_class.new(course)

        expect(obj.show_placement_guidance?(type)).to be(false)
      end
    end

    context 'when SCITT course with provider_code absent' do
      let(:provider) { scitt_provider }
      let(:type) { :program_type }

      it 'returns true' do
        obj = described_class.new(course)

        expect(obj.show_placement_guidance?(type)).to be(true)
      end
    end

    context 'when Higher Education course with provider_code present' do
      let(:course) { he_course }
      let(:provider) { scitt_provider }
      let(:type) { :program_type }
      let(:provider_code) { 'B31' }

      it 'returns false' do
        obj = described_class.new(course)

        expect(obj.show_placement_guidance?(type)).to be(false)
      end
    end

    context 'when Higher Education course with provider_code absent' do
      let(:course) { he_course }
      let(:provider) { scitt_provider }
      let(:type) { :program_type }

      it 'returns true' do
        obj = described_class.new(course)

        expect(obj.show_placement_guidance?(type)).to be(true)
      end
    end
  end

  describe '#contact_form?' do
    let(:provider) { scitt_provider }
    let(:course) { scitt_course }

    context 'when provider has a contact form' do
      let(:provider_code) { 'U80' }

      it 'returns true' do
        obj = described_class.new(course)

        expect(obj.contact_form?).to be(true)
      end
    end

    context 'when provider does not have a contact form' do
      it 'returns false' do
        obj = described_class.new(course)

        expect(obj.contact_form?).to be(false)
      end
    end
  end

  describe '#contact_form' do
    let(:provider) { scitt_provider }
    let(:course) { scitt_course }

    context 'when provider has a contact form' do
      let(:provider_code) { 'U80' }

      it 'returns the contact form URL' do
        obj = described_class.new(course)

        expect(obj.contact_form).to eq('https://www.ucl.ac.uk/prospective-students/graduate/admissions-enquiries')
      end
    end

    context 'when provider does not have a contact form' do
      it 'returns false' do
        obj = described_class.new(course)

        expect(obj.contact_form).to be_nil
      end
    end
  end

  describe '#show_address?' do
    subject { described_class.new(course).show_address? }

    let(:provider) { scitt_provider }
    let(:course) { scitt_course }

    context 'when course and provider codes exist' do
      let(:provider_code) { '28T' }
      let(:course_code) { 'X104' }

      it { is_expected.to be(true) }
    end

    context 'when course and provider codes do not exist' do
      it { is_expected.to be(false) }
    end
  end
end
