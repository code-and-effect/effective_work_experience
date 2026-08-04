# The total work experience for one intern. Not an ActiveRecord model.
module Effective
  class WorkExperienceReport
    include ActiveModel::Model

    attr_accessor :user # The intern

    def to_s
      'Work Experience Report'
    end

    def to_param
      user&.to_param
    end

    def mentor
      user&.try(:work_experience_mentor)
    end

    def backdated_work_experience_record
      work_experience_records.find(&:backdated?)
    end

    def start_on
      work_experience_records.select { |work_experience_record| work_experience_record.month.present? }.map(&:month).sort.first
    end

    def end_on
      work_experience_records.select { |work_experience_record| work_experience_record.month.present? }.map(&:month).sort.last
    end

    def years
      return [] unless start_on.present?
      (start_on.year..end_on.year).to_a
    end

    def total_hours
      work_experience_records.sum { |work_experience_record| work_experience_record.total_hours.to_f }.round(2)
    end

    def work_experience_subcategories
      @work_experience_subcategories ||= Effective::WorkExperienceSubcategory.all.sorted
    end

    def work_experience_records
      return unless user.present?
      @work_experience_records ||= user.work_experience_records
    end
  end
end
