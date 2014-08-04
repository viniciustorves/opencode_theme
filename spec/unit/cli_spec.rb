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

    it "should remove assets that are not a part of the white list" do
      @cli.local_files = ['assets/image.png', 'config.yml', 'layout/theme.liquid']
      local_assets_list = @cli.send(:local_assets_list)
      assert_equal 2, local_assets_list.length
      assert_equal false, local_assets_list.include?('config.yml')
    end

    it "should remove assets that are part of the ignore list" do
      OpencodeTheme.config = {ignore_files: ['config.yml']}
      @cli.local_files = ['templates/default.html', 'layout/default.html', 'config.yml']
      local_assets_list = @cli.send(:local_assets_list)
      assert_equal 2, local_assets_list.length
      assert_equal false, local_assets_list.include?('config.yml')
    end

    it "should generate the shop path URL to the query parameter preview_theme_id if the id is present" do
      @cli.mock_config = {preview_url: 'google.com', theme_id: 12345}
      assert_equal "google.com", @cli.opencode_theme_url
    end

    it "should report binary files as such" do
      assert @cli.binary_file?('hello.pdf'), "PDFs are binary files"
      assert @cli.binary_file?('hello.png'), "PNGs are binary files"
    end

    it "should not report text based files as binary" do
      refute @cli.binary_file?('theme.liquid'), "liquid files are not binary"
      refute @cli.binary_file?('style.sass.liquid'), "sass.liquid files are not binary"
      refute @cli.binary_file?('style.css'), 'CSS files are not binary'
      refute @cli.binary_file?('application.js'), 'Javascript files are not binary'
    end
  end
end
