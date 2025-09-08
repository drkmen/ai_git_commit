# frozen_string_literal: true

RSpec.describe AiGitCommit do
  it "has a version number" do
    expect(AiGitCommit::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
