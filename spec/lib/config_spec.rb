# frozen_string_literal: true

RSpec.describe AiGitCommit::Config do
  describe "initialize" do
    let(:default_values) do
      {
        openai_api_key: ENV.fetch("OPENAI_API_KEY", nil),
        model: "gpt-3.5-turbo",
        program_language:,
        max_tokens: 300,
        temperature: 0.7,
        system_role_message:
      }
    end
    let(:program_language) { "Ruby" }
    let(:system_role_message) do
      <<~MESSAGE
        You are a senior #{program_language} developer. Your task is to write a concise, clear commit
        message and a detailed description based on the provided code changes. The message
        should be in the imperative mood. The body should be wrapped at 72 characters.
      MESSAGE
    end

    subject { described_class.new }

    it "defines default configuration values" do
      is_expected.to have_attributes(default_values)
    end
  end

  describe ".config" do
    subject { AiGitCommit.config }

    it "returns a Config instance" do
      is_expected.to be_a(AiGitCommit::Config)
    end
  end

  describe ".configure" do
    let(:new_model) { "gpt-4" }

    subject do
      AiGitCommit.configure do |config|
        config.model = new_model
      end
    end

    it "yields config block" do
      expect { subject }.to change { AiGitCommit.config.model }.to(new_model)
    end
  end
end
