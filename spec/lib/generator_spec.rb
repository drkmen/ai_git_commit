# frozen_string_literal: true

RSpec.describe AiGitCommit::Generator do
  describe "commit_message" do
    let(:openai_api_key) { "openai_api_key" }
    let(:staged_diff) { "staged diff content" }
    let(:openai_client) do
      double(
        :openai_client,
        chat: double(
          :chat,
          completions: double(
            :completions,
            create: open_ai_response
          )
        )
      )
    end
    let(:open_ai_response) do
      double(
        :response,
        choices: [
          double(
            :choices,
            message: double(:message, content:)
          )
        ]
      )
    end
    let(:content) { "Generated commit message" }

    before do
      AiGitCommit.configure { _1.openai_api_key = openai_api_key }
      allow(described_class).to receive(:staged_diff).and_return(staged_diff)
      allow(described_class).to receive(:openai).and_return(openai_client)
    end

    subject { described_class.commit_message }

    it "returns a commit message from OpenAI" do
      is_expected.to eq(content)
    end

    context "when there are no staged changes" do
      let(:staged_diff) { "" }

      it { is_expected.to eq("# No staged changes found.") }
    end

    context "when OPENAI_API_KEY is not set" do
      let(:openai_api_key) { nil }

      it { is_expected.to eq("# AI skipped: OPENAI_API_KEY is not set.") }
    end
  end
end
