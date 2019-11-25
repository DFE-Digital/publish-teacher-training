require "spec_helper"
require "mcb_helper"

describe "running the mcb script" do
  describe "config" do
    context "when the config is specified" do
      let(:config_file) { Tempfile.new(["new_config_file", ".yml"]) }
      let(:config)      { { "new" => "day" } }

      it "can set the path to the config file" do
        result = with_stubbed_stdout do
          File.write config_file.path, config.to_yaml
          $mcb.run(%W[-c #{config_file.path} config show])
        end
        result = result[:stdout]

        expect(MCB.config_file).to eq config_file.path
        expect(result).to eq config.to_yaml
      end
    end

    context "default config" do
      it "raises an error if the config does not exist", stub_init_rails: false do
        expect {
          MCB.start_mcb_repl(%W[-E my_nonexistent_environment])
        }.to raise_error(Errno::ENOENT, "No such file or directory - Could not find config/azure_environments.yml, consult the MCB section of README.md")
      end

      it "raises an error if an environment cannot be found", stub_init_rails: false do
        FakeFS do
          FileUtils.mkdir_p("/config")
          File.write "config/azure_environments.yml", "azure:"

          expect {
            MCB.start_mcb_repl(%W[-E my_nonexistent_environment])
          }.to raise_error(KeyError, "The environment 'my_nonexistent_environment' could not be found, have you made sure to add it to your config/azure_environments.yml?")
        end
      end
    end
  end

  describe "REPL" do
    context "completion" do
      it "provides completions for empty prompt" do
        output = with_stubbed_stdout(stdin: "\t\t") do
          FakeFS do
            FileUtils.mkdir_p(File.expand_path("/tmp"))
            FileUtils.mkdir_p(File.expand_path("~"))

            MCB.start_mcb_repl([])
          end
        end
        output = output[:stdout]

        expect(output).to include("providers")
        expect(output).to include("console")
        expect(output).to include("courses")
        expect(output).to include("config")
        expect(output).to include("apiv1")
        expect(output).to include("apiv2")
        expect(output).to include("users")
        expect(output).to include("az")
      end

      it "provides relevant completions for a main command" do
        output = with_stubbed_stdout(stdin: "co\t\t") do
          FakeFS do
            FileUtils.mkdir_p(File.expand_path("/tmp"))
            FileUtils.mkdir_p(File.expand_path("~"))

            MCB.start_mcb_repl([])
          end
        end
        output = output[:stdout]

        expect(output).not_to include("providers")
        expect(output).to include("console")
        expect(output).to include("courses")
        expect(output).to include("config")
        expect(output).not_to include("apiv1")
        expect(output).not_to include("apiv2")
        expect(output).not_to include("users")
        expect(output).not_to include("az")
      end
    end

    context "history" do
      let(:up_key) { "\e[A" }
      it "loads commands from saved history file" do
        output = with_stubbed_stdout(stdin: up_key) do
          FakeFS do
            FileUtils.mkdir_p(File.expand_path("/tmp"))

            FileUtils.mkdir_p(File.expand_path("~"))
            File.open(File.expand_path("~/.mcb_history"), "w") do |f|
              f.puts("previous command")
            end
            MCB.start_mcb_repl([])
          end
        end
        expect(output[:stdout]).to match("previous command")
      end

      it "eliminates duplicates from history" do
        output = with_stubbed_stdout(stdin: "i want to show this command\nduplicate command\nduplicate command\n#{up_key}#{up_key}") do
          FakeFS do
            FileUtils.mkdir_p(File.expand_path("/tmp"))

            FileUtils.mkdir_p(File.expand_path("~"))
            MCB.start_mcb_repl([])
          end
        end
        expect(output[:stdout].scan("i want to show this command").size).to eq(2)
      end

      it "eliminates empty items from history" do
        output = with_stubbed_stdout(stdin: "i want to show this command\n\n#{up_key}") do
          FakeFS do
            FileUtils.mkdir_p(File.expand_path("/tmp"))

            FileUtils.mkdir_p(File.expand_path("~"))
            MCB.start_mcb_repl([])
          end
        end
        expect(output[:stdout].scan("i want to show this command").size).to eq(2)
      end

      it "starts normally when history file is not present" do
        expect {
          with_stubbed_stdout(stdin: up_key) do
            FakeFS do
              FileUtils.mkdir_p(File.expand_path("/tmp"))
              FileUtils.mkdir_p(File.expand_path("~"))
              MCB.start_mcb_repl([])
            end
          end
        }.not_to raise_error
      end

      it "appends to the history file on exit" do
        file_contents = nil
        with_stubbed_stdout(stdin: "my first command\nmy second command\n") do
          FakeFS do
            FileUtils.mkdir_p(File.expand_path("/tmp"))
            FileUtils.mkdir_p(File.expand_path("~"))

            File.open(File.expand_path("~/.mcb_history"), "w") do |f|
              f.puts("old command")
            end
            MCB.start_mcb_repl([])

            file_contents = File.open(File.expand_path("~/.mcb_history"), "r").read
          end
        end

        expect(file_contents).to include("old command\nmy first command\nmy second command\n")
      end
    end
  end
end
