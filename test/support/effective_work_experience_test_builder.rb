module EffectiveWorkExperienceTestBuilder

  def create_user!
    build_user.tap { |user| user.save! }
  end

  def build_user
    @user_index ||= 0
    @user_index += 1

    User.new(
      email: "user#{@user_index}@example.com",
      password: 'rubicon2020',
      password_confirmation: 'rubicon2020',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  def build_mentor
    build_user().tap { |user| user.save! }
  end

  # An intern with a mentor
  def build_intern(mentor: nil)
    mentor ||= build_mentor()

    user = build_user()
    user.assign_attributes(work_experience_mentor: mentor)
    user.save!

    user
  end

  # An intern whose mentor doesn't have an account
  def build_intern_with_outside_mentor
    user = build_intern()
    user.update!(work_experience_mentor: nil)

    user.create_work_experience_outside_mentor!(
      name: 'Outside Mentor',
      email: 'outside@mentor.com',
      phone: '1234567890',
      regulated_profession: 'Regulated Profession'
    )

    user.reload
  end

  def build_work_experience_record(user: nil, month: nil)
    user ||= build_intern()
    month ||= Time.zone.now.beginning_of_month

    work_experience_record = Effective::WorkExperienceRecord.new(user: user, month: month)

    work_experience_record.work_experience_subcategories.each do |work_experience_subcategory|
      work_experience_entry = work_experience_record.work_experience_entry(work_experience_subcategory: work_experience_subcategory)
      work_experience_entry.assign_attributes(week_1: 1, week_2: 2, week_3: 3, week_4: 4, week_5: 5)
    end

    work_experience_record
  end

  def create_work_experience_record!(user: nil, month: nil)
    build_work_experience_record(user: user, month: month).tap(&:save!)
  end

  def build_work_experience_project(user: nil, start_on: nil, end_on: nil)
    user ||= build_intern()
    start_on ||= Time.zone.now.beginning_of_quarter

    Effective::WorkExperienceProject.new(user: user, start_on: start_on, end_on: end_on, name: "Test Project #{start_on.strftime('%Y-%m-%d')}")
  end

  def create_work_experience_project!(user: nil, start_on: nil)
    build_work_experience_project(user: user, start_on: start_on).tap(&:save!)
  end

  def build_work_experience_summary(user: nil, start_on: nil)
    user ||= build_intern()
    start_on ||= Time.zone.now.beginning_of_quarter

    # Build one record for each month of the period
    create_work_experience_record!(user: user, month: start_on)
    create_work_experience_record!(user: user, month: start_on + 1.month)
    create_work_experience_record!(user: user, month: start_on + 2.months)

    # Build 2 projects
    create_work_experience_project!(user: user, start_on: start_on)
    create_work_experience_project!(user: user, start_on: start_on + 1.months)

    # A new summary automatically picks them up
    EffectiveWorkExperience.WorkExperienceSummary.new(user: user, start_on: start_on)
  end

  def create_work_experience_summary!(user: nil, start_on: nil)
    build_work_experience_summary(user: user, start_on: start_on).tap(&:save!)
  end

end
