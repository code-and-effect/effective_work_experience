class CreateEffectiveWorkExperience < ActiveRecord::Migration[6.0]
  def change
    create_table :work_experience_categories, if_not_exists: true do |t|
      t.string :title
      t.integer :minimum_hours
      t.integer :position

      t.timestamps
    end

    create_table :work_experience_subcategories, if_not_exists: true do |t|
      t.integer :work_experience_category_id

      t.string :title
      t.integer :minimum_hours
      t.integer :position

      t.timestamps
    end

    create_table :work_experience_outside_mentors, if_not_exists: true do |t|
      t.integer :user_id
      t.string :user_type

      t.string :name
      t.string :email
      t.string :phone
      t.string :regulated_profession
      t.text :admin_notes

      t.timestamps
    end

    create_table :work_experience_records, if_not_exists: true do |t|
      t.integer :user_id
      t.string :user_type

      t.date :month
      t.decimal :total_hours, precision: 10, scale: 2

      # There can only be one backdated work experience record
      t.boolean :backdated, default: false

      t.string :status
      t.text :status_steps

      t.datetime :submitted_at
      t.datetime :reviewed_at

      t.timestamps
    end

    create_table :work_experience_entries, if_not_exists: true do |t|
      t.integer :user_id
      t.string :user_type

      t.integer :work_experience_record_id
      t.integer :work_experience_subcategory_id

      t.decimal :week_1, precision: 10, scale: 2
      t.decimal :week_2, precision: 10, scale: 2
      t.decimal :week_3, precision: 10, scale: 2
      t.decimal :week_4, precision: 10, scale: 2
      t.decimal :week_5, precision: 10, scale: 2

      t.timestamps
    end

    create_table :work_experience_projects, if_not_exists: true do |t|
      t.integer :user_id
      t.string :user_type

      t.string :name
      t.text :description

      t.date :start_on
      t.date :end_on

      t.timestamps
    end

    create_table :work_experience_summaries, if_not_exists: true do |t|
      t.integer :user_id
      t.string :user_type

      t.integer :mentor_id
      t.string :mentor_type

      t.integer :supervisor_id
      t.string :supervisor_type

      t.string :status
      t.text :status_steps

      t.text :wizard_steps

      t.date :start_on
      t.date :end_on

      t.decimal :total_hours, precision: 10, scale: 2

      t.string :recommendation
      t.text :comments

      t.datetime :submitted_at
      t.datetime :reviewed_at

      t.string :token

      t.timestamps
    end

    add_index :work_experience_outside_mentors, [:user_id, :user_type], unique: true, if_not_exists: true
    add_index :work_experience_records, [:user_id, :user_type], if_not_exists: true
    add_index :work_experience_entries, [:work_experience_record_id], if_not_exists: true
    add_index :work_experience_projects, [:user_id, :user_type], if_not_exists: true
    add_index :work_experience_summaries, [:user_id, :user_type], if_not_exists: true
    add_index :work_experience_summaries, [:mentor_id, :mentor_type], if_not_exists: true
  end
end
