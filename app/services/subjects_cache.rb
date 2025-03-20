# frozen_string_literal: true

class SubjectsCache
  attr_reader :expires_in

  def initialize(expires_in: 1.day)
    @expires_in = expires_in
  end

  def primary_subjects
    Rails.cache.fetch('subjects:primary', expires_in: expires_in) do
      Subject.where(type: 'PrimarySubject').order(:subject_name).to_a
    end
  end

  def primary_subject_codes
    primary_subjects.map(&:subject_code)
  end

  def secondary_subject_codes
    secondary_subjects.map(&:subject_code)
  end

  def secondary_subjects
    Rails.cache.fetch('subjects:secondary', expires_in: expires_in) do
      Subject.where(type: %w[SecondarySubject ModernLanguagesSubject])
             .where.not(subject_name: ['Modern Languages'])
             .order(:subject_name).to_a
    end
  end

  def all_subjects
    Rails.cache.fetch('subjects:all', expires_in: expires_in) do
      Subject.active.where.not(subject_name: ['Modern Languages']).map do |subject|
        SubjectSuggestion.new(name: subject.subject_name, value: subject.subject_code)
      end
    end
  end
end
