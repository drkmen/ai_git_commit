# frozen_string_literal: true

require 'tmpdir'

RSpec.describe AiGitCommit do
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
    system("export OPENAI_API_KEY='test_key'")
  end

  xit "generates commit message via AI hook" do
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    Dir.mktmpdir do |dir|
      FileUtils.cp_r(Dir.pwd + "/.", dir)
      Dir.chdir(dir) do
        system("git init")
        system("export OPENAI_API_KEY='test_key'")
        hook_script = <<~HOOK
          #!/bin/bash
          ruby -r './lib/ai_git_commit.rb' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
        HOOK
        File.write(".git/hooks/pre-commit", hook_script)
        FileUtils.chmod("+x", ".git/hooks/pre-commit")
        File.write("test.txt", "test")
        system("git add test.txt")
        system("git commit -m 'stub'")
        msg = File.read(".git/COMMIT_EDITMSG")
        expect(msg).to include("Generated commit message") # или ожидаемый текст
      end
    end
  end
end
