module WithQualifications
  extend ActiveSupport::Concern

  included do
    # The training programme outcome that originated in the UCAS NetUpdate system.
    #
    # See [UCAS Teacher Training Set-up Guide](https://www.ucas.com/file/115581/download?token=mv-G6P53),
    # page 32
    enum profpost_flag: {

      # Recommendation for QTS: the student will not receive an academic teacher
      # training qualification on successful completion of the
      # programme.
      recommendation_for_qts: "",

      # Professional: the student will receive a Professional Graduate
      # Certificate of Education (offered at Level 6) or Professional
      # Graduate Diploma in Education (PGDE), with no credits or
      # modules at postgraduate (master’s) Level 7 on successful
      # completion of the programme.
      professional: "PF",

      # Postgraduate: the student will receive a Postgraduate Certificate
      # of Education (PGCE) or other qualification which includes at
      # least one module or some credits at postgraduate
      # (master’s) Level 7 on successful completion the
      # programme.
      postgraduate: "PG",

      # Both professional and postgraduate: the student has the option of taking at least one
      # postgraduate (master’s) Level 7 module or obtaining some
      # postgraduate-level credits as part of the programme.
      professional_postgraduate: "BO",
    }

    # When UCAS basic courses were being imported into Manage Courses DB, this
    # field wasn't coming from the UCAS data. Instead, the UCAS importer derived
    # this field from the `profpost_flag`, the `pgde_course` table and from the
    # subjects this course was tagged to.
    #
    # Defined here: https://github.com/DFE-Digital/manage-courses-api/blob/master/src/ManageCourses.Domain/Models/CourseQualification.cs
    enum qualification: %i[qts pgce_with_qts pgde_with_qts pgce pgde]

    # This field may seem like an unnecessary overhead when there is already a
    # database-backed `qualification` field. However it's misleading, from the
    # point of view of the teacher training domain, to think of 'PGCE with QTS'
    # as a single qualification, since the QTS and PGCE aspects are completely
    # separate and may even be delivered in different places by different providers.
    # e.g. the QTS might come from a SCITT but the PGCE would come from a university.
    #
    # It's more accurate (and hopefully more future-proof) to represent qualifications
    # as a list and leave the gluing of them to the presentation layer.
    def qualifications
      case qualification
      when "qts" then [:qts]
      when "pgce_with_qts" then %i[qts pgce]
      when "pgde_with_qts" then %i[qts pgde]
      when "pgce" then [:pgce]
      when "pgde" then [:pgde]
      end
    end

    def qualifications_description
      qualifications.map(&:upcase).sort.join(" with ")
    end

    def qualification=(value)
      super(value)
      self.profpost_flag = qts? ? :recommendation_for_qts : :postgraduate
    end

    def qualification_valid?(course)
      if course.level == :further_education
        course.qualifications.exclude?(:qts)
      else
        course.qualifications.include?(:qts)
      end
    end
  end
end
