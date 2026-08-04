require 'test_helper'

class WorkExperienceTest < ActiveSupport::TestCase
  test 'user factory' do
    user = build_user()
    assert user.valid?
  end

end
