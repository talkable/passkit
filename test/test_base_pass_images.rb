# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class TestBasePassImages < Minitest::Test
  # BasePass#pass_path resolves against Rails.root; point it at a scratch dir
  # so the test writes nothing into the gem's own example pass folder.
  class ScratchPass < Passkit::BasePass
    attr_reader :pass_path

    def initialize(pass_path)
      super(nil)
      @pass_path = pass_path
    end
  end

  def setup
    @dir = Dir.mktmpdir
    @source = File.join(@dir, "source.png")
    File.write(@source, "not really a png")
    @pass = ScratchPass.new(File.join(@dir, "bundle"))
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  # Wallet renders primaryLogo on a poster face and logo on the classic one, so
  # the poster slot has to land under Apple's camelCase name. Deriving it from
  # the key would write primary@logo.png, which Wallet drops without an error.
  def test_poster_logo_lands_under_apples_camel_case_name
    @pass.install_images(primary_logo: @source, primary_logo_2x: @source, primary_logo_3x: @source)

    assert_equal %w[primaryLogo.png primaryLogo@2x.png primaryLogo@3x.png],
      Dir.children(@pass.pass_path).sort
  end

  def test_classic_slots_keep_their_names
    @pass.install_images(icon: @source, icon_2x: @source, logo: @source, artwork_3x: @source)

    assert_equal %w[artwork@3x.png icon.png icon@2x.png logo.png],
      Dir.children(@pass.pass_path).sort
  end

  def test_unknown_slot_raises_instead_of_writing_a_file_wallet_ignores
    assert_raises(KeyError) { @pass.install_images(banner: @source) }
  end
end
