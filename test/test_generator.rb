# frozen_string_literal: true

require "rails_helper"

class TestGenerator < Minitest::Test
  # Passkit::Pass does not delegate :sharing, but Generator#generate_json_pass
  # reads it. Provide it so the generator can run outside the host app.
  class PassRecord < Passkit::Pass
    def sharing
    end
  end

  # BasePass#barcodes is empty and #barcode returns the default QR code,
  # so this exercises the legacy singular barcode fallback.
  class LegacyBarcodePass < Passkit::BasePass
  end

  class NoBarcodePass < Passkit::BasePass
    def barcode
    end
  end

  def teardown
    FileUtils.rm_rf(@temporary_path) if @temporary_path
  end

  def test_writes_barcodes_when_barcodes_present
    json = generate_pass_json(Passkit::ExampleStoreCard)

    refute_includes json.keys, "barcode"
    assert_equal JSON.parse(Passkit::ExampleStoreCard.new.barcodes.to_json), json["barcodes"]
  end

  def test_falls_back_to_legacy_barcode_when_barcodes_empty
    json = generate_pass_json(LegacyBarcodePass)

    refute_includes json.keys, "barcodes"
    assert_equal JSON.parse(LegacyBarcodePass.new.barcode.to_json), json["barcode"]
  end

  def test_omits_barcode_keys_when_pass_has_no_barcodes
    json = generate_pass_json(NoBarcodePass)

    refute_includes json.keys, "barcode"
    refute_includes json.keys, "barcodes"
  end

  private

  def generate_pass_json(pass_class)
    pass = PassRecord.new(klass: pass_class.name)
    generator = Passkit::Generator.new(pass)
    generator.send(:create_temporary_directory)
    @temporary_path = generator.instance_variable_get(:@temporary_path)
    FileUtils.mkdir_p(@temporary_path)
    generator.send(:generate_json_pass, "pass.test.identifier")
    JSON.parse(File.read(File.join(@temporary_path, "pass.json")))
  end
end
