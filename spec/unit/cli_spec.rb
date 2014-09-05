require_relative '../spec_helper'
require 'opencode_theme'
require 'opencode_theme/cli'

module OpencodeTheme
  describe "Cli" do

    class CliDouble < Cli
      attr_writer :local_files, :mock_config

      desc "",""
      def config
        @mock_config || super
      end

      desc "",""
      def opencode_theme_url
        super
      end

      desc "",""
      def binary_file?(file)
        super
      end

      desc "", ""
      def local_files
        @local_files
      end
    end

    before do
      @cli = CliDouble.new
      OpencodeTheme.config = {}
    end
  end
end
