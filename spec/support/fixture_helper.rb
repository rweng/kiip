module FixtureHelper
  def fixture_path sub_path
    File.join(__dir__, '..', 'fixtures', sub_path)
  end

  def run_kiip commands
    `kiip #{commands}`
  end
end