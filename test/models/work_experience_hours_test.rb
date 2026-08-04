require 'test_helper'

class WorkExperienceHoursTest < ActiveSupport::TestCase
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
