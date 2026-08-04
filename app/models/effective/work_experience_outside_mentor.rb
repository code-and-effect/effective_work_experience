# An intern whose mentor does not have an account. We store their mentor as freeform fields.
module Effective
  class WorkExperienceOutsideMentor < ActiveRecord::Base
    self.table_name = (EffectiveWorkExperience.work_experience_outside_mentors_table_name || :work_experience_outside_mentors).to_s

    belongs_to :user, polymorphic: true

    log_changes(to: :user) if respond_to?(:log_changes)

    effective_resource do
      name                    :string
      email                   :string
      phone                   :string
      regulated_profession    :string
      admin_notes             :text

      timestamps
    end

    scope :sorted, -> { order(:name) }
    scope :deep, -> { includes(:user) }

    validates :name, presence: true
    validates :email, presence: true, email: true
    validates :phone, presence: true
    validates :regulated_profession, presence: true

    # A user has just one outside mentor
    validates :user_id, uniqueness: { scope: :user_type }

    def to_s
      name.presence || model_name.human
    end
  end
end
