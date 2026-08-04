class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  def is?(value)
    to_s == 'Member User'
  end

end
