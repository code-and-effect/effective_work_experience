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
    assert_equal subcategories, work_experience_record.work_experience_subcategories.count
    assert work_experience_record.work_experience_entries.all? { |work_experience_entry| work_experience_entry.hours == 15 }
    assert_equal (15 * subcategories), work_experience_record.total_hours
  end

  test 'work experience record month is the first day of the month' do
    work_experience_record = build_work_experience_record()
    work_experience_record.assign_attributes(month: Time.zone.now.beginning_of_month + 5.days)

    assert work_experience_record.valid?
    assert_equal Time.zone.now.beginning_of_month.to_date, work_experience_record.month
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

    work_experience_summary.assign_attributes(recommendation: 'Recommend Approve')

    assert_email(count: 1) { work_experience_summary.review! }

    assert work_experience_summary.was_reviewed?
    assert work_experience_summary.reviewed?

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
