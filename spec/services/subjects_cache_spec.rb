# frozen_string_literal: true

require 'rails_helper'

describe SubjectsCache do
  let(:cache) { described_class.new }

  describe '#primary_subjects' do
    it 'returns primary subjects ordered by name' do
      expect(cache.primary_subjects.map(&:subject_name)).to eq(
        [
          'Primary',
          'Primary with English',
          'Primary with geography and history',
          'Primary with mathematics',
          'Primary with modern languages',
          'Primary with physical education',
          'Primary with science'
        ]
      )
    end
  end

  describe '#primary_subject_codes' do
    it 'returns subject codes for primary subjects' do
      expect(cache.primary_subject_codes).to match_array(
        %w[
          00 01 02 03 04 06 07
        ]
      )
    end
  end

  describe '#secondary_subjects' do
    it 'returns secondary subjects excluding Modern Languages' do
      expect(cache.secondary_subjects.map(&:subject_name)).to contain_exactly(
        'Ancient Greek',
        'Ancient Hebrew',
        'Art and design',
        'Biology',
        'Business studies',
        'Chemistry',
        'Citizenship',
        'Classics',
        'Communication and media studies',
        'Computing',
        'Dance',
        'Design and technology',
        'Drama',
        'Economics',
        'English',
        'French',
        'Geography',
        'German',
        'Health and social care',
        'History',
        'Italian',
        'Japanese',
        'Latin',
        'Mandarin',
        'Mathematics',
        'Modern languages (other)',
        'Music',
        'Philosophy',
        'Physical education',
        'Physical education with an EBacc subject',
        'Physics',
        'Psychology',
        'Religious education',
        'Russian',
        'Science',
        'Social sciences',
        'Spanish'
      )
    end
  end

  describe '#secondary_subject_codes' do
    it 'returns subject codes for secondary subjects' do
      expect(cache.secondary_subject_codes).to match_array(
        %w[
          A1 A2 W1 C1 08 F1 09 Q8 P3 11 12 DT
          13 L1 Q3 15 F8 17 L5 V1 18 19 A0 20
          G1 24 W3 P1 C6 C7 F3 C8 V6 21 F0 14 22
        ]
      )
    end
  end
end
