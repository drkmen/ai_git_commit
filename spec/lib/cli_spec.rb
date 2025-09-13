# frozen_string_literal: true

RSpec.describe AiGitCommit::CLI do
  it "inherits from Thor" do
    expect(described_class.superclass).to eq(Thor)
  end

  context "constants" do
    describe "HOOK_PATH" do
      subject { described_class::HOOK_PATH }

      it { is_expected.to eq(".git/hooks/prepare-commit-msg") }
    end
  end

  describe "#install" do
    let(:cli) { described_class.new }
    let(:script_content) { "script content" }
    let(:file_double) { instance_double(File) }

    before do
      allow(cli).to receive(:script).and_return(script_content)
      allow(FileUtils).to receive(:chmod)
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:cp)
      allow(File).to receive(:open).and_yield(file_double)
      allow(File).to receive(:write)
      allow(file_double).to receive(:puts)
      allow($stdout).to receive(:puts)
    end

    subject { cli.install }

    it "creates a dir and copies initializer file" do
      expect(FileUtils).to receive(:mkdir_p)
      expect(FileUtils).to receive(:cp)
      subject
    end

    context "when hook file exists" do
      before do
        allow(cli).to receive(:hook_file_exists?).and_return(true)
      end

      it "appends script to the hook file" do
        expect(File).to receive(:open).with(described_class::HOOK_PATH, "a").and_yield(file_double)
        expect(file_double).to receive(:puts).with(script_content)
        subject
      end

      it "makes the hook file executable" do
        expect(FileUtils).to receive(:chmod).with("+x", described_class::HOOK_PATH)
        subject
      end

      it "prints confirmation message" do
        expect($stdout).to receive(:puts).with("AI Git Commit prepare-commit-msg hook set up.")
        subject
      end
    end

    context "when hook file does not exist" do
      before do
        allow(cli).to receive(:hook_file_exists?).and_return(false)
      end

      it "writes script to the hook file" do
        expect(File).to receive(:write).with(described_class::HOOK_PATH, script_content)
        subject
      end

      it "makes the hook file executable" do
        expect(FileUtils).to receive(:chmod).with("+x", described_class::HOOK_PATH)
        subject
      end

      it "prints confirmation message" do
        expect($stdout).to receive(:puts).with("AI Git Commit prepare-commit-msg hook set up.")
        subject
      end
    end
  end

  describe "#script" do
    before do
      allow(File).to receive(:exist?).with(".git/hooks/prepare-commit-msg").and_return(hook_file_exists)
    end

    subject { described_class.new.send(:script) }

    context "when the hook file exists" do
      let(:hook_file_exists) { true }
      let(:script) do
        <<~SCRIPT
          \nruby -r 'ai_git_commit' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
        SCRIPT
      end

      it { is_expected.to eq(script) }
    end

    context "when the hook file does not exist" do
      let(:hook_file_exists) { false }
      let(:script) do
        <<~SCRIPT
          #!/bin/bash
          ruby -r 'ai_git_commit' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
        SCRIPT
      end

      it { is_expected.to eq(script) }
    end
  end
end
