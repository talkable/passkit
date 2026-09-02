# frozen_string_literal: true

require "rails_helper"

class TestGenerator < Minitest::Test
  # Passkit::Pass does not delegate :sharing, but Generator#generate_json_pass
  # reads it. Provide it so the generator can run outside the host app.
  class PassRecord < Passkit::Pass
    def sharing
    end
  end

  # barcodes is empty and #barcode is defined, so this exercises the legacy
  # singular barcode fallback on its own value, not BasePass's default.
  class LegacyBarcodePass < Passkit::BasePass
    def barcode
      {messageEncoding: "iso-8859-1", format: "PKBarcodeFormatCode128",
       message: "REAL-12345", altText: "REAL-12345"}
    end
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
    assert_equal "PKBarcodeFormatCode128", json["barcode"]["format"]
    assert_equal "REAL-12345", json["barcode"]["message"]
    assert_equal "REAL-12345", json["barcode"]["altText"]
    assert_equal "iso-8859-1", json["barcode"]["messageEncoding"]
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
