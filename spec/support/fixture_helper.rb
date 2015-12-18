module FixtureHelper
  def fixture_path sub_path
    File.join(__dir__, '..', 'fixtures', sub_path)
  end
end