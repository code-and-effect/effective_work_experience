# frozen_string_literal: true

# EffectiveWorkExperienceUser
#
# Mark your user model with effective_work_experience_user to get the work experience associations
# and the hours calculations used by the records, summaries and reports.
#
# Requires a work_experience_mentor_id column on your users table.
#
# Your user model may also define:
# - supervisor        the user responsible for this intern's day to day work

module EffectiveWorkExperienceUser
  extend ActiveSupport::Concern

  module Base
    def effective_work_experience_user
      include ::EffectiveWorkExperienceUser
    end
  end

  module ClassMethods
    def effective_work_experience_user?; true; end
  end

  included do
    # The user who reviews my work experience summaries
    belongs_to :work_experience_mentor, class_name: name, optional: true

    # The interns I am a mentor for
    has_many :work_experience_mentees, -> { order(:id) }, class_name: name, foreign_key: :work_experience_mentor_id, inverse_of: :work_experience_mentor, dependent: :nullify

    # There is only ever one. The has_many is for the admin form fields.
    # reject_if so the blank one built by the form is ignored unless it's filled in.
    has_one :work_experience_outside_mentor, as: :user, class_name: 'Effective::WorkExperienceOutsideMentor'
    has_many :work_experience_outside_mentors, as: :user, dependent: :destroy, class_name: 'Effective::WorkExperienceOutsideMentor'
    accepts_nested_attributes_for :work_experience_outside_mentors, allow_destroy: true, reject_if: :all_blank

    # Virtual. The admin form checkbox that toggles the outside mentor fields.
    attr_accessor :work_experience_outside_mentor_present

    # An intern has a mentor user or an outside mentor. Never both.
    before_validation(if: -> { work_experience_outside_mentor_present.present? }) do
      if EffectiveResources.truthy?(work_experience_outside_mentor_present)
        assign_attributes(work_experience_mentor: nil)
      else
        work_experience_outside_mentors.each { |outside_mentor| outside_mentor.mark_for_destruction }
      end
    end

    has_many :work_experience_records, -> { order(:month) }, as: :user, dependent: :destroy, class_name: 'Effective::WorkExperienceRecord'
    has_many :work_experience_entries, -> { order(:id) }, as: :user, dependent: :destroy, class_name: 'Effective::WorkExperienceEntry'
    has_many :work_experience_projects, -> { order(:start_on) }, as: :user, dependent: :destroy, class_name: 'Effective::WorkExperienceProject'

    has_many :work_experience_summaries, -> { order(:start_on) }, as: :user, dependent: :destroy, class_name: EffectiveWorkExperience.class_name(name, :work_experience_summaries)

    # I'm the mentor for these work experience summaries
    has_many :mentee_work_experience_summaries, -> { order(:start_on) }, as: :mentor, class_name: EffectiveWorkExperience.class_name(name, :work_experience_summaries)

    scope :work_experience_mentors, -> { where(id: unscoped.select(:work_experience_mentor_id)) }

    scope :deep_work_experience, -> {
      includes(:work_experience_mentor)
      .includes(work_experience_records: [work_experience_entries: { work_experience_subcategory: :work_experience_category }])
    }
  end

  def work_experience_intern?
    return true if try(:intern?) || try(:pre_intern?)
    work_experience_records.present? || work_experience_summaries.present?
  end

  def work_experience_mentor?
    work_experience_mentees.present? || mentee_work_experience_summaries.present?
  end

  # This intern's mentor does not have an account. Their summaries are reviewed automatically.
  def work_experience_outside_mentor?
    work_experience_outside_mentor.present?
  end

  def work_experience_subcategories
    @work_experience_subcategories ||= Effective::WorkExperienceSubcategory.all.sorted
  end

  # One subcategory and month
  def work_experience_hours(month:, work_experience_subcategory: nil)
    work_experience_record = work_experience_records.find { |record| record.month == month }
    return 0.0 if work_experience_record.blank?

    hours = if work_experience_subcategory.present?
      work_experience_record.work_experience_entry(work_experience_subcategory: work_experience_subcategory).hours
    else
      work_experience_record.work_experience_entries.sum { |work_experience_entry| work_experience_entry.hours }
    end

    hours.round(2)
  end

  # One subcategory for every month in this year
  def work_experience_hours_by_year(year:, work_experience_subcategory: nil)
    work_experience_records_in_year = work_experience_records.select { |record| record.month.present? && record.month.year == year }
    return 0.0 if work_experience_records_in_year.blank?

    hours = if work_experience_subcategory.present?
      work_experience_records_in_year.sum { |record| record.work_experience_entry(work_experience_subcategory: work_experience_subcategory).hours }
    else
      work_experience_records_in_year.sum { |record| record.work_experience_entries.sum { |work_experience_entry| work_experience_entry.hours } }
    end

    hours.round(2)
  end

  # One subcategory for all months up to and including this month
  def work_experience_total_hours_to_date(month:, work_experience_subcategory: nil)
    work_experience_records_to_date = if month.blank?
      work_experience_records.select { |record| record.backdated? }
    else
      work_experience_records.select { |record| record.backdated? || record.month <= month }
    end

    return 0.0 if work_experience_records_to_date.blank?

    hours = work_experience_records_to_date.sum do |work_experience_record|
      if work_experience_subcategory.present?
        work_experience_record.work_experience_entry(work_experience_subcategory: work_experience_subcategory).hours
      else
        work_experience_record.work_experience_entries.sum { |work_experience_entry| work_experience_entry.hours }
      end
    end

    hours.round(2)
  end

end
