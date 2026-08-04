puts "Running effective_work_experience seeds"

# An example set of work experience categories and subcategories.
# Each application will define their own, from the admin screens or their own seeds.

categories = [
  { title: 'Design Development', minimum_hours: 500, position: 1 },
  { title: 'Contract Documents', minimum_hours: 1275, position: 2 },
  { title: 'Office Practice', minimum_hours: 155, position: 3 },
  { title: 'Other', minimum_hours: nil, position: 4 }
]

categories.each do |attributes|
  work_experience_category = Effective::WorkExperienceCategory.where(title: attributes[:title]).first_or_initialize
  work_experience_category.update!(attributes)
end

subcategories = [
  { category: 'Design Development', position: 1, minimum_hours: 200, title: 'Conceptual Designs' },
  { category: 'Design Development', position: 2, minimum_hours: 300, title: 'Other Design Development' },
  { category: 'Contract Documents', position: 3, minimum_hours: 150, title: 'Grading and Drainage Plans' },
  { category: 'Contract Documents', position: 4, minimum_hours: 1125, title: 'Other Contract Documents' },
  { category: 'Office Practice', position: 5, minimum_hours: 155, title: 'Meetings' },
  { category: 'Other', position: 6, minimum_hours: nil, title: 'Other' }
]

subcategories.each do |attributes|
  work_experience_category = Effective::WorkExperienceCategory.where(title: attributes[:category]).first!

  work_experience_subcategory = Effective::WorkExperienceSubcategory.where(position: attributes[:position]).first_or_initialize

  work_experience_subcategory.update!(
    work_experience_category: work_experience_category,
    position: attributes[:position],
    minimum_hours: attributes[:minimum_hours],
    title: attributes[:title]
  )
end

puts "Created #{Effective::WorkExperienceCategory.count} work experience categories and #{Effective::WorkExperienceSubcategory.count} subcategories"
