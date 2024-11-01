# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::QualificationsSummaryComponent::View, type: :component do
  context 'QTS qualification' do
    it 'renders correct text' do
      course = build(:course, :resulting_in_qts).decorate
      result = render_inline(described_class.new(course:))

      expect(result.text).to include('Qualified teacher status (QTS) allows you to teach in state schools in England')
    end
  end

  context 'PGCE with QTS qualification' do
    it 'renders correct text' do
      course = build(:course, :resulting_in_pgce_with_qts).decorate
      result = render_inline(described_class.new(course:))

      expect(result.text).to include('QTS with PGCE')
      expect(result.text).to include('You need qualified teacher status (QTS) to teach in state schools in England. QTS may also allow you to teach in other parts of the UK.')
      expect(result.text).to include('This course also offers a postgraduate certificate in education (PGCE)')
    end
  end

  context 'PGDE with QTS qualification' do
    it 'renders correct text' do
      course = build(:course, :resulting_in_pgde_with_qts).decorate
      result = render_inline(described_class.new(course:))

      expect(result.text).to include('QTS with PGDE')
      expect(result.text).to include('A postgraduate diploma in education (PGDE) with qualified teacher status (QTS) will allow you to teach in state schools in England')
    end
  end

  context 'PGCE qualification' do
    it 'renders correct text' do
      course = build(:course, :resulting_in_pgce).decorate
      result = render_inline(described_class.new(course:))

      expect(result.text).to include('A postgraduate certificate in education (PGCE) is an academic qualification in education.')
    end
  end

  context 'PGDE qualification' do
    it 'renders correct text' do
      course = build(:course, :resulting_in_pgde).decorate
      result = render_inline(described_class.new(course:))

      expect(result.text).to include('A postgraduate diploma in education (PGDE) is equivalent to a postgraduate certificate in education (PGCE).')
    end
  end

  context 'Teacher degree apprenticeship with QTS' do
    it 'renders correct text' do
      course = build(:course, :resulting_in_undergraduate_degree_with_qts).decorate
      result = render_inline(described_class.new(course:))

      expect(result.text).to include('Teacher degree apprenticeship (TDA) with QTS')
      expect(result.text).to include('On a teacher degree apprenticeship you’ll work in a school and earn a salary while getting a bachelor’s degree and qualified teacher status (QTS). Find out more about teacher degree apprenticeships')
    end
  end
end
