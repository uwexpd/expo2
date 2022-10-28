class OmsfaStudentInfo < ApplicationRecord
  self.table_name = "omsfa_student_info"
  belongs_to :person
end
