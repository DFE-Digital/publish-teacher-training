class DFESubject
  FINANCIAL_SUPPORT_FOR_2019_20_RECRUITMENT_CYCLE = [
    { subjects: %w[Mathematics], bursary_amount: 20000, early_career_payments: 10000, scholarship: 22000 },
    { subjects: %w[French Chemistry Computing Spanish Geography Physics German], bursary_amount: 26000, early_career_payments: 0, scholarship: 28000 },
    { subjects: ["Modern languages (other)", "Classics", "Italian", "Japanese", "Mandarin", "Russian", "Biology"], bursary_amount: 26000, early_career_payments: 0, scholarship: 0 },
    { subjects: %w[English], bursary_amount: 15000, early_career_payments: 0, scholarship: 0 },
    { subjects: ["Design and technology", "History"], bursary_amount: 12000, early_career_payments: 0, scholarship: 0 },
    { subjects: %w[Music], bursary_amount: 9000, early_career_payments: 0, scholarship: 0 },
    { subjects: ["Primary with mathematics"], bursary_amount: 6000, early_career_payments: 0, scholarship: 0 },
  ].freeze

  NO_FINANCIAL_INCENTIVES = { bursary_amount: 0, early_career_payments: 0, scholarship: 0, precedence: 0 }.freeze

  def initialize(subject_name)
    @subject_name = subject_name
  end

  def has_bursary?
    bursary_amount.positive?
  end

  def has_scholarship?
    scholarship_amount.positive?
  end

  def has_scholarship_and_bursary?
    has_bursary? && has_scholarship?
  end

  def has_early_career_payments?
    financial_support[:early_career_payments].positive?
  end

  def bursary_amount
    financial_support[:bursary_amount]
  end

  def scholarship_amount
    financial_support[:scholarship]
  end

  def total_bursary_and_early_career_payments_amount
    financial_support.slice(:bursary_amount, :early_career_payments).values.sum
  end

  def to_s
    @subject_name
  end

  def ==(other)
    to_s == other.to_s
  end

private

  def financial_support
    FINANCIAL_SUPPORT_FOR_2019_20_RECRUITMENT_CYCLE.
      detect { |entry| @subject_name.in?(entry[:subjects]) } ||
      NO_FINANCIAL_INCENTIVES
  end
end
