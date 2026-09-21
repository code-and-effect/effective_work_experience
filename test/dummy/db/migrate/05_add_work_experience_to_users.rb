class AddWorkExperienceToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :work_experience_mentor_id, :integer
    add_column :users, :work_experience_supervisor_id, :integer
  end
end
