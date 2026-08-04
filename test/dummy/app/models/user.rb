class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  effective_work_experience_user

  def to_s
    [first_name, last_name].compact.join(' ').presence || email
  end

  def is?(value)
    to_s == 'Member User'
  end

end
