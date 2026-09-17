require 'test_helper'

class WorkExperienceTest < ActiveSupport::TestCase
  test 'user factory' do
    user = build_user()
    assert user.valid?
  end

  test 'intern' do
    user = build_intern()
    assert user.work_experience_mentor.present?
  end

  test 'work experience record' do
    work_experience_record = create_work_experience_record!

    subcategories = Effective::WorkExperienceSubcategory.count
    assert_equal subcategories, work_experience_record.work_experience_entries.count
    assert work_experience_record.work_experience_entries.all? { |work_experience_entry| work_experience_entry.hours == 15 }
    assert_equal (15 * subcategories), work_experience_record.total_hours
  end

  test 'work experience record month is the first day of the month' do
    work_experience_record = build_work_experience_record()
    work_experience_record.assign_attributes(month: Time.zone.now.beginning_of_month + 5.days)

    assert work_experience_record.valid?
    assert_equal Time.zone.now.beginning_of_month.to_date, work_experience_record.month
  end

  test 'monthly grid records require a unique month for each intern' do
    record = create_work_experience_record!
    duplicate = build_work_experience_record(user: record.user, month: record.month)

    refute duplicate.valid?
    assert duplicate.errors[:month].present?
  end

  test 'hours log records preserve entered hours and allow multiple records in a month' do
    original_mode = EffectiveWorkExperience.mode
    EffectiveWorkExperience.mode = :hours_log
    user = build_intern()
    date = Date.current
    subcategory = Effective::WorkExperienceSubcategory.sorted.first

    first = user.work_experience_records.create!(month: date, date: date, description: 'Site planning', total_hours: 2.5, work_experience_subcategory: subcategory)
    second = user.work_experience_records.create!(month: date, date: date, description: 'Design review', total_hours: 1.25, work_experience_subcategory: subcategory)

    assert_equal date, first.reload.date
    assert_equal subcategory, first.work_experience_subcategory
    assert_equal 'Site planning', first.description
    assert_equal date.beginning_of_month, first.month
    assert_equal 2.5, first.total_hours
    assert_equal 1.25, second.reload.total_hours
    assert_equal 3.75, user.work_experience_hours(month: date.beginning_of_month)
    assert_equal 3.75, user.work_experience_hours_by_year(year: date.year)
    assert_equal 3.75, user.work_experience_total_hours_to_date(month: date.beginning_of_month)

    summary = EffectiveWorkExperience.WorkExperienceSummary.new(user: user, start_on: date)
    assert summary.valid?, summary.errors.full_messages.to_sentence
    assert_equal 3.75, summary.total_hours
  ensure
    EffectiveWorkExperience.mode = original_mode
  end

  test 'hours log records require description date and subcategory' do
    original_mode = EffectiveWorkExperience.mode
    EffectiveWorkExperience.mode = :hours_log
    record = Effective::WorkExperienceRecord.new(user: build_intern(), month: Date.current, total_hours: 2.5)

    refute record.valid?
    assert record.errors[:description].present?
    assert record.errors[:date].present?
    assert record.errors[:work_experience_subcategory].present?
  ensure
    EffectiveWorkExperience.mode = original_mode
  end

  test 'monthly grid records do not require description date or a record subcategory' do
    record = build_work_experience_record()

    assert_nil record.description
    assert_nil record.date
    assert_nil record.work_experience_subcategory
    assert record.valid?, record.errors.full_messages.to_sentence
  end

  test 'work experience summary' do
    work_experience_summary = create_work_experience_summary!()

    subcategories = Effective::WorkExperienceSubcategory.count

    assert_equal 2, work_experience_summary.work_experience_projects.count
    assert_equal 3, work_experience_summary.work_experience_records.count
    assert_equal (3 * 15 * subcategories), work_experience_summary.total_hours
    assert work_experience_summary.draft?
  end

  test 'work experience summary assigns the mentor from the user' do
    user = build_intern()
    work_experience_summary = create_work_experience_summary!(user: user)

    assert_equal user.work_experience_mentor, work_experience_summary.mentor
  end

  test 'work experience summary supervisor is assigned by id alone' do
    work_experience_summary = create_work_experience_summary!
    supervisor = build_mentor()

    # The user model has no supervisor association. The admin form assigns the id only.
    refute work_experience_summary.user.respond_to?(:supervisor)

    work_experience_summary.update!(supervisor_id: supervisor.id)

    assert_equal supervisor, work_experience_summary.reload.supervisor
    assert_equal supervisor.class.name, work_experience_summary.supervisor_type
  end

  test 'work experience summary requires a mentor' do
    user = build_intern()
    user.update!(work_experience_mentor: nil)

    work_experience_summary = build_work_experience_summary(user: user)

    refute work_experience_summary.valid?
    assert work_experience_summary.errors[:user].present?
  end

  test 'work experience report' do
    work_experience_summary = create_work_experience_summary!()

    subcategories = Effective::WorkExperienceSubcategory.count

    work_experience_report = Effective::WorkExperienceReport.new(user: work_experience_summary.user)
    assert_equal (3 * 15 * subcategories), work_experience_report.total_hours
  end

  test 'submit sends an email to the mentor' do
    work_experience_summary = create_work_experience_summary!()

    assert_email(count: 1) { work_experience_summary.submit! }

    assert work_experience_summary.was_submitted?
    assert work_experience_summary.submitted?

    assert work_experience_summary.work_experience_records.all? { |work_experience_record| work_experience_record.was_submitted? }
  end

  test 'review sends an email to the intern' do
    work_experience_summary = create_work_experience_summary!()
    work_experience_summary.submit!

    work_experience_summary.assign_attributes(
      approve_work_experience_summary: true,
      mentor_comments: 'Mentor notes',
      supervisor_recommendation: 'Recommend Decline',
      supervisor_comments: 'Supervisor notes'
    )

    assert_email(count: 1) { work_experience_summary.review! }

    assert work_experience_summary.was_reviewed?
    assert work_experience_summary.reviewed?
    work_experience_summary.reload
    assert_equal work_experience_summary.recommendations.first, work_experience_summary.mentor_recommendation
    assert_equal 'Mentor notes', work_experience_summary.mentor_comments
    assert_equal 'Recommend Decline', work_experience_summary.supervisor_recommendation
    assert_equal 'Supervisor notes', work_experience_summary.supervisor_comments

    assert work_experience_summary.work_experience_records.all? { |work_experience_record| work_experience_record.was_reviewed? }
  end

  test 'outside mentor' do
    user = build_intern_with_outside_mentor()

    assert user.work_experience_outside_mentor?
    assert_equal 'Outside Mentor', user.work_experience_outside_mentor.name

    # A user only ever has one outside mentor
    another = user.work_experience_outside_mentors.build(
      name: 'Another', email: 'another@mentor.com', phone: '1234567890', regulated_profession: 'Regulated Profession'
    )

    refute another.valid?
    assert another.errors[:user_id].present?
  end

  test 'auto review with outside mentor' do
    user = build_intern_with_outside_mentor()

    assert user.work_experience_outside_mentor?
    assert user.work_experience_mentor.blank?

    work_experience_summary = create_work_experience_summary!(user: user)
    assert work_experience_summary.mentor.blank?

    assert_no_difference -> { ActionMailer::Base.deliveries.length } do
      work_experience_summary.submit!
    end

    # It was automatically reviewed
    assert work_experience_summary.was_submitted?
    assert work_experience_summary.reviewed?
  end

end
