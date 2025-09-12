# frozen_string_literal: true

RSpec.describe AiGitCommit::CLI do
  # class CLI < Thor
  #   HOOK_PATH = ".git/hooks/prepare-commit-msg"
  #   SCRIPT = <<~SCRIPT
  #     #{"#!/bin/bash" unless File.exist?(HOOK_PATH)}
  #     ruby -r './lib/ai_git_commit.rb' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
  #   SCRIPT
  #
  #   # Installs the prepare-commit-msg hook.
  #   # If the hook already exists, appends the script; otherwise, creates a new hook file.
  #   # Makes the hook executable and prints a confirmation message.
  #   desc "install", "Set up prepare-commit-msg hook"
  #   def install
  #     if File.exist?(HOOK_PATH)
  #       File.open(HOOK_PATH, "a") { _1.puts SCRIPT }
  #     else
  #       File.write(HOOK_PATH, SCRIPT)
  #     end
  #
  #     FileUtils.chmod("+x", HOOK_PATH)
  #     puts "AI Git Commit prepare-commit-msg hook set up."
  #   end
  # end

  it 'inherits from Thor' do
    expect(described_class.superclass).to eq(Thor)
  end

  context 'constants' do
    describe 'HOOK_PATH' do
      subject { described_class::HOOK_PATH }

      it { is_expected.to eq('.git/hooks/prepare-commit-msg') }
    end
  end

  # spec/lib/cli_spec.rb

  describe '#install' do
    let(:cli) { described_class.new }
    let(:script_content) { 'script content' }

    before do
      allow(cli).to receive(:script).and_return(script_content)
      allow(FileUtils).to receive(:chmod)
      allow($stdout).to receive(:puts)
    end

    subject { cli.install }

    after { subject }

    context 'when hook file exists' do
      before do
        allow(cli).to receive(:hook_file_exists?).and_return(true)
        allow(File).to receive(:open)
      end

      it 'appends script to the hook file' do
        expect(File).to receive(:open).with(described_class::HOOK_PATH, "a")
      end

      it 'makes the hook file executable' do
        expect(FileUtils).to receive(:chmod).with("+x", described_class::HOOK_PATH)
      end

      it 'prints confirmation message' do
        expect($stdout).to receive(:puts).with("AI Git Commit prepare-commit-msg hook set up.")
      end
    end

    context 'when hook file does not exist' do
      before do
        allow(cli).to receive(:hook_file_exists?).and_return(false)
        allow(File).to receive(:write)
      end

      it 'writes script to the hook file' do
        expect(File).to receive(:write).with(described_class::HOOK_PATH, script_content)
      end

      it 'makes the hook file executable' do
        expect(FileUtils).to receive(:chmod).with("+x", described_class::HOOK_PATH)
      end

      it 'prints confirmation message' do
        expect($stdout).to receive(:puts).with("AI Git Commit prepare-commit-msg hook set up.")
      end
    end
  end

  describe '#script' do
    before do
      allow(File).to receive(:exist?).with('.git/hooks/prepare-commit-msg').and_return(hook_file_exists)
    end

    subject { described_class.new.send(:script) }

    context 'when the hook file exists' do
      let(:hook_file_exists) { true }
      let(:script) do
        <<~SCRIPT
          \nruby -r './lib/ai_git_commit.rb' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
        SCRIPT
      end

      it { is_expected.to eq(script) }
    end

    context 'when the hook file does not exist' do
      let(:hook_file_exists) { false }
      let(:script) do
        <<~SCRIPT
          #!/bin/bash
          ruby -r './lib/ai_git_commit.rb' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
        SCRIPT
      end

      it { is_expected.to eq(script) }
    end
  end
end
