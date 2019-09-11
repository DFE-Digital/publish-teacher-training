class DFESubject
  FINANCIAL_SUPPORT_FOR_2019_20_RECRUITMENT_CYCLE = [
    { ucas_subjects: %w[Mathematics], bursary_amount: 20000, early_career_payments: 10000, scholarship: 22000 },
    { ucas_subjects: %w[French Chemistry Computing Spanish Geography Physics German], bursary_amount: 26000, early_career_payments: nil, scholarship: 28000 },
    { ucas_subjects: ["Modern languages (other)", "Classics", "Italian", "Japanese", "Mandarin", "Russian", "Biology"], bursary_amount: 26000, early_career_payments: nil, scholarship: nil },
    { ucas_subjects: %w[English], bursary_amount: 15000, early_career_payments: nil, scholarship: nil },
    { ucas_subjects: ["Design and technology", "History"], bursary_amount: 12000, early_career_payments: nil, scholarship: nil },
    { ucas_subjects: %w[Music], bursary_amount: 9000, early_career_payments: nil, scholarship: nil },
    { ucas_subjects: ["Primary with mathematics"], bursary_amount: 6000, early_career_payments: nil, scholarship: nil },
  ].freeze

  def initialize(subject_name)
    @subject_name = subject_name
  end

  def has_bursary?
    financial_support&.fetch(:bursary_amount).present?
  end

  def has_scholarship?
    financial_support&.fetch(:scholarship).present?
  end

  def has_scholarship_and_bursary?
    has_bursary? && has_scholarship?
  end

  def has_early_career_payments?
    financial_support&.fetch(:early_career_payments).present?
  end

  def bursary_amount
    financial_support&.fetch(:bursary_amount)
  end

  def scholarship_amount
    financial_support&.fetch(:scholarship)
  end

  def to_s
    @subject_name
  end

  def ==(other)
    to_s == other.to_s
  end

private

  def financial_support
    FINANCIAL_SUPPORT_FOR_2019_20_RECRUITMENT_CYCLE.detect { |entry| @subject_name.in?(entry[:subjects]) }
  end
end
