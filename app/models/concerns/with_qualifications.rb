# frozen_string_literal: true

module WithQualifications
  extend ActiveSupport::Concern

  included do
    # The training programme outcome that originated in the UCAS NetUpdate system.
    #
    # See [UCAS Teacher Training Set-up Guide](https://www.ucas.com/file/115581/download?token=mv-G6P53),
    # page 32
    enum :profpost_flag, {

      # Recommendation for QTS: the student will not receive an academic teacher
      # training qualification on successful completion of the
      # programme.
      recommendation_for_qts: '',

      # Professional: the student will receive a Professional Graduate
      # Certificate of Education (offered at Level 6) or Professional
      # Graduate Diploma in Education (PGDE), with no credits or
      # modules at postgraduate (master's) Level 7 on successful
      # completion of the programme.
      professional: 'PF',

      # Postgraduate: the student will receive a Postgraduate Certificate
      # of Education (PGCE) or other qualification which includes at
      # least one module or some credits at postgraduate
      # (master's) Level 7 on successful completion the
      # programme.
      postgraduate: 'PG',

      # Both professional and postgraduate: the student has the option of taking at least one
      # postgraduate (master's) Level 7 module or obtaining some
      # postgraduate-level credits as part of the programme.
      professional_postgraduate: 'BO'
    }

    # When UCAS basic courses were being imported into Manage Courses DB, this
    # field wasn't coming from the UCAS data. Instead, the UCAS importer derived
    # this field from the `profpost_flag`, the `pgde_course` table and from the
    # subjects this course was tagged to.
    #
    # Defined here: https://github.com/DFE-Digital/manage-courses-api/blob/master/src/ManageCourses.Domain/Models/CourseQualification.cs
    enum :qualification, { qts: 0, pgce_with_qts: 1, pgde_with_qts: 2, pgce: 3, pgde: 4, undergraduate_degree_with_qts: 5 }

    # This field may seem like an unnecessary overhead when there is already a
    # database-backed `qualification` field. However it's misleading, from the
    # point of view of the teacher training domain, to think of 'QTS with PGCE'
    # as a single qualification, since the QTS and PGCE aspects are completely
    # separate and may even be delivered in different places by different providers.
    # e.g. the QTS might come from a SCITT but the PGCE would come from a university.
    #
    # It's more accurate (and hopefully more future-proof) to represent qualifications
    # as a list and leave the gluing of them to the presentation layer.
    def qualifications
      case qualification
      when 'qts' then [:qts]
      when 'undergraduate_degree_with_qts' then %i[qts undergraduate_degree]
      when 'pgce_with_qts' then %i[qts pgce]
      when 'pgde_with_qts' then %i[qts pgde]
      when 'pgce' then [:pgce]
      when 'pgde' then [:pgde]
      end
    end

    def full_qualifications
      case qualification
      when 'qts' then 'Qualified teacher status (QTS)'
      when 'pgce_with_qts' then 'Qualified teacher status (QTS) with a postgraduate certificate in education (PGCE)'
      when 'pgde_with_qts' then 'Postgraduate diploma in education (PGDE) with qualified teacher status (QTS)'
      when 'pgce' then 'Postgraduate certificate in education (PGCE) without qualified teacher status (QTS)'
      when 'pgde' then 'Postgraduate diploma in education (PGDE) without qualified teacher status (QTS)'
      end
    end

    def qualifications_description
      return '' unless qualifications

      I18n.t("qualifications.description.#{qualification}")
    end

    def full_qualification_descriptions
      return '' unless full_qualifications

      full_qualifications
    end

    def qualification=(value)
      super
      self.profpost_flag = if qts?
                             :recommendation_for_qts
                           else
                             :postgraduate
                           end
    end
  end
end
