# == Schema Information
#
# Table name: pgde_course
#
#  id            :integer          not null, primary key
#  course_code   :text             not null
#  provider_code :text             not null
#

# Prior to the UCAS transition, this class is only used in the UCAS importer to
# calculate the `course#qualification` database column.
#
# TODO: delete this class (and entire table) after the UCAS transition is finished

class PGDECourse < ApplicationRecord; end
