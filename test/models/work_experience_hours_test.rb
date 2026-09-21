require 'test_helper'

class WorkExperienceHoursTest < ActiveSupport::TestCase
  test 'hours logs aggregate all records by category month and year including backdated totals' do
    original_mode = EffectiveWorkExperience.mode
    EffectiveWorkExperience.mode = :hours_log
    user = build_intern()
    month = Date.new(2026, 1, 1)
    subcategory, other_subcategory = Effective::WorkExperienceSubcategory.sorted.limit(2)

    [
      [month, subcategory, 2.5],
      [month, subcategory, 1.25],
      [month, other_subcategory, 4],
      [month + 1.month, subcategory, 3],
      [month + 1.year, subcategory, 8],
      [nil, subcategory, 10],
      [nil, other_subcategory, 20]
    ].each do |record_month, record_subcategory, hours|
      user.work_experience_records.create!(
        month: record_month, date: month + 15.days, description: 'Site visit',
        work_experience_subcategory: record_subcategory, total_hours: hours, backdated: record_month.nil?
      )
    end

    user.reload
    assert_equal 3.75, user.work_experience_hours(month: month, work_experience_subcategory: subcategory)
    assert_equal 4, user.work_experience_hours(month: month, work_experience_subcategory: other_subcategory)
    assert_equal 7.75, user.work_experience_hours(month: month)
    assert_equal 0, user.work_experience_hours(month: month + 2.months, work_experience_subcategory: subcategory)

    assert_equal 6.75, user.work_experience_hours_by_year(year: 2026, work_experience_subcategory: subcategory)
    assert_equal 10.75, user.work_experience_hours_by_year(year: 2026)
    assert_equal 0, user.work_experience_hours_by_year(year: 2025, work_experience_subcategory: subcategory)

    assert_equal 13.75, user.work_experience_total_hours_to_date(month: month, work_experience_subcategory: subcategory)
    assert_equal 24, user.work_experience_total_hours_to_date(month: month, work_experience_subcategory: other_subcategory)
    assert_equal 37.75, user.work_experience_total_hours_to_date(month: month)
    assert_equal 10, user.work_experience_total_hours_to_date(month: nil, work_experience_subcategory: subcategory)
    assert_equal 30, user.work_experience_total_hours_to_date(month: nil)

    assert user.work_experience_records.all? { |record| record.work_experience_entries.empty? }
  ensure
    EffectiveWorkExperience.mode = original_mode
  end

  test 'work experience hours for one month' do
    user = build_intern()
    month = Time.zone.now.beginning_of_quarter

    create_work_experience_record!(user: user, month: month)

    subcategories = Effective::WorkExperienceSubcategory.count
    work_experience_subcategory = Effective::WorkExperienceSubcategory.sorted.first

    assert_equal (15 * subcategories), user.work_experience_hours(month: month)
    assert_equal 15, user.work_experience_hours(month: month, work_experience_subcategory: work_experience_subcategory)
    assert_equal 0.0, user.work_experience_hours(month: month + 1.month)
  end

  test 'work experience hours by year' do
    user = build_intern()
    month = Time.zone.now.beginning_of_quarter

    create_work_experience_record!(user: user, month: month)
    create_work_experience_record!(user: user, month: month + 1.month)

    subcategories = Effective::WorkExperienceSubcategory.count

    assert_equal (2 * 15 * subcategories), user.work_experience_hours_by_year(year: month.year)
    assert_equal 0.0, user.work_experience_hours_by_year(year: month.year - 1)
  end

  test 'work experience total hours to date' do
    user = build_intern()
    month = Time.zone.now.beginning_of_quarter

    create_work_experience_record!(user: user, month: month)
    create_work_experience_record!(user: user, month: month + 1.month)

    subcategories = Effective::WorkExperienceSubcategory.count

    assert_equal (15 * subcategories), user.work_experience_total_hours_to_date(month: month)
    assert_equal (2 * 15 * subcategories), user.work_experience_total_hours_to_date(month: month + 1.month)
  end

  test 'backdated work experience records are always included' do
    user = build_intern()
    month = Time.zone.now.beginning_of_quarter

    backdated = build_work_experience_record(user: user, month: nil)
    backdated.assign_attributes(backdated: true)
    backdated.save!

    assert backdated.backdated?
    assert backdated.month.blank?

    subcategories = Effective::WorkExperienceSubcategory.count

    assert_equal (15 * subcategories), user.reload.work_experience_total_hours_to_date(month: month)
    assert_equal (15 * subcategories), user.work_experience_total_hours_to_date(month: nil)
  end

end
