# Effective Work Experience

Interns record their work experience hours and projects, and mentors review them.

Interns record their hours each month against a set of work experience subcategories, and record the projects they worked on. Every few months they submit a summary of that period, which is reviewed by their mentor. A work experience report totals everything to date against the minimum hours of each category.

## Getting Started

This requires Rails 6+ and Twitter Bootstrap 4 and just works with Devise.

Please first install the [effective_datatables](https://github.com/code-and-effect/effective_datatables) gem.

Please download and install the [Twitter Bootstrap4](http://getbootstrap.com)

Add to your Gemfile:

```ruby
gem 'effective_work_experience'
```

Run the bundle command to install it:

```console
bundle install
```

Then run the generator:

```ruby
rails generate effective_work_experience:install
```

The generator will install an initializer which describes all configuration options and creates a database migration.

Then migrate the database:

```ruby
rake db:migrate
```

## Models

- `Effective::WorkExperienceCategory` — the top level grouping, with a minimum hours target
- `Effective::WorkExperienceSubcategory` — belongs to a category. Hours are recorded against these.
- `Effective::WorkExperienceRecord` — one intern's hours for one month
- `Effective::WorkExperienceEntry` — one row of a record. Five weeks of hours for one subcategory.
- `Effective::WorkExperienceProject` — one project an intern worked on
- `Effective::WorkExperienceSummary` — one period, submitted by the intern and reviewed by their mentor
- `Effective::WorkExperienceOutsideMentor` — a mentor without an account, stored as freeform fields
- `Effective::WorkExperienceReport` — an ActiveModel report of everything to date

The work experience summary is the only swappable class. Mark your own with `effective_work_experience_summary`:

```ruby
module Bcsla
  class WorkExperienceSummary < ApplicationRecord
    effective_work_experience_summary
  end
end
```

and configure it:

```ruby
config.work_experience_summary_class_name = 'Bcsla::WorkExperienceSummary'
```

## Categories

Nothing works until there are categories and subcategories to record hours against — a new record
has one row per subcategory, so with none it is an empty form. Every application defines its own,
either from the admin screens or from its own seeds. See `db/seeds.rb` for an example set.

`minimum_hours` is optional on both. The work experience report shows a target and a percent
complete for each category and subcategory that has one, and just the hours to date for those that
don't.

## User

An intern's mentor is another user, so this gem needs one column on your users table. The install
migration does not add it. Write your own:

```ruby
class AddWorkExperienceMentorToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :work_experience_mentor_id, :integer
  end
end
```

Then add the following to your User model:

```ruby
effective_work_experience_user
```

which adds the `belongs_to :work_experience_mentor` for that column, plus:

- `work_experience_mentees` — the interns I am a mentor for
- `work_experience_outside_mentor` — my mentor when they don't have an account. A `has_one`.
- `work_experience_records`, `work_experience_entries`, `work_experience_projects`, `work_experience_summaries`, `mentee_work_experience_summaries`
- the `work_experience_hours`, `work_experience_hours_by_year` and `work_experience_total_hours_to_date` calculations
- `work_experience_intern?`, `work_experience_mentor?` and `work_experience_outside_mentor?`, used by the views and permissions below

An intern with an outside mentor has no `work_experience_mentor`, so their summaries are reviewed automatically on submit.

The summary's `user`, `mentor` and `supervisor` are polymorphic. A summary assigns its mentor from the user's `work_experience_mentor`, and its supervisor from the user's `supervisor` when your User model defines one.

### Who is an intern

`work_experience_intern?` is true once a user has any records or summaries. To have someone see the
intern dashboard before they've recorded anything, define `intern?` on your User model and it will
be used too:

```ruby
def intern?
  membership.present? && membership.category.intern?
end
```

### Admin user form

Render the mentor fields from your own admin user form:

```haml
= render('admin/work_experience/user_fields', f: f, hint: 'Who can be a mentor')
```

This is the `work_experience_mentor` select plus an `f.has_many` builder for the one outside mentor.
The `work_experience_mentor_id` and `work_experience_outside_mentors_attributes` params are permitted
by effective_resources for free — there is nothing to add to your `effective_resource do` block.

Render an intern's records, projects, summaries and report as a tab on the same form:

```haml
- if user.work_experience_intern?
  = tab Effective::WorkExperienceRecord, label: 'Work Experience' do
    = render('admin/work_experience/user_work_experience', user: user)
```

## Dashboard

Render the dashboard partials from your own dashboard:

```haml
- if current_user.work_experience_intern?
  = render 'effective/work_experience/dashboard_intern'

- if current_user.work_experience_mentor?
  = render 'effective/work_experience/dashboard_mentor'
```

## Configuration

All configuration options are documented in the `config/initializers/effective_work_experience.rb` initializer.

## Authorization

All authorization checks are handled via the effective_resources gem found in the `config/initializers/effective_resources.rb` file.

## Permissions

The permissions you actually want to define are as follows (using CanCan):

```ruby
if user.persisted?
  can([:index, :show, :new, :create], Effective::WorkExperienceRecord) { |record| record.user == user }
  can([:edit, :update], Effective::WorkExperienceRecord) { |record| !record.backdated? && !record.was_reviewed? }
  can(:destroy, Effective::WorkExperienceRecord) { |record| !record.backdated? && !record.was_submitted? }

  can(crud, Effective::WorkExperienceProject) { |project| project.user == user }

  can([:new, :create], EffectiveWorkExperience.WorkExperienceSummary) { |summary| summary.user == user }
  can(:destroy, EffectiveWorkExperience.WorkExperienceSummary) { |summary| summary.user == user && summary.draft? }

  can([:show, :index], EffectiveWorkExperience.WorkExperienceSummary) do |summary|
    summary.user == user || (summary.mentor == user && summary.was_submitted?)
  end

  can(:update, EffectiveWorkExperience.WorkExperienceSummary) do |summary|
    (summary.user == user && !summary.was_submitted?) || (summary.mentor == user && summary.was_submitted?)
  end

  can(:show, Effective::WorkExperienceReport) { |report| report.user == user || report.mentor == user }

  if user.work_experience_mentor?
    can(:index, EffectiveWorkExperienceReportsReviewDatatable)
  end
end

if user.admin?
  can :admin, :effective_work_experience

  can([:index, :edit, :update], Effective::WorkExperienceCategory)
  can([:index, :edit, :update], Effective::WorkExperienceSubcategory)
  can(crud - [:show], Effective::WorkExperienceProject)
  can(crud - [:show], Effective::WorkExperienceRecord)
  can(crud, Effective::WorkExperienceReport)
  can(crud, EffectiveWorkExperience.WorkExperienceSummary)
  can(:index, Admin::EffectiveWorkExperienceReportsDatatable)
end
```

Add a link to the admin menu:

```haml
- if can? :admin, :effective_work_experience
  = nav_link_to Effective::WorkExperienceRecord, effective_work_experience.admin_work_experience_records_path
  = nav_link_to Effective::WorkExperienceProject, effective_work_experience.admin_work_experience_projects_path
  = nav_link_to EffectiveWorkExperience.WorkExperienceSummary, effective_work_experience.admin_work_experience_summaries_path
  = nav_link_to Effective::WorkExperienceReport, effective_work_experience.admin_work_experience_reports_path
```

## License

MIT License. Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

## Testing

Run tests by:

```ruby
rails test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
