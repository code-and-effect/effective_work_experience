module Effective
  class WorkExperienceSummary < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_summaries_table_name || :work_experience_summaries).to_s

    effective_work_experience_summary
  end
end
