# frozen_string_literal: true

require "test_helper"
require "active_support/all"
require "delegate"
require "tmpdir"

# Generator resolves Rails paths when it loads; the payload itself needs no app.
# Rake loads every test file into one process, so only stand in for Rails.root
# when nothing else has booted an app -- otherwise this would repoint the
# dummy app the controller tests rely on.
ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"] ||= "AppleWWDRCA.cer"
unless Rails.root
  def Rails.root
    @root ||= Pathname.new(Dir.mktmpdir)
  end
end

class TestGeneratorPoster < Minitest::Test
  # A pass that opts into the poster layout on top of the classic one.
  class PosterCard < Passkit::ExampleStoreCard
    def pass_type
      :generic
    end

    def poster_pass_type
      :posterGeneric
    end

    def primary_fields
      [{key: "balance", value: "$25"}]
    end

    def poster_primary_fields
      [{key: "memberName", label: "Member Name", value: "Juan Chavez"}]
    end

    def footer_fields
      [{key: "membershipType", value: "Family Pass"}]
    end

    def featured_actions
      [{identifier: "redeem", type: "shop", url: "https://example.com/redeem"}]
    end
  end

  # Opts into the poster layout without saying what goes in its primary row.
  class DefaultPosterCard < Passkit::ExampleStoreCard
    def poster_pass_type
      :posterGeneric
    end

    def primary_fields
      [{key: "balance", value: "$25"}]
    end
  end

  # boarding_pass carries the keys only this style has, e.g. transitType.
  class BoardingCard < Passkit::ExampleStoreCard
    def pass_type
      :boardingPass
    end

    def boarding_pass
      {transitType: "PKTransitTypeGeneric"}
    end
  end

  # featured_actions has a [] default, but a subclass is free to return nil.
  class NilActionsCard < Passkit::ExampleStoreCard
    def featured_actions
    end
  end

  # Stands in for Passkit::Pass, which only adds persisted columns on top of
  # the pass instance.
  class PassDouble < SimpleDelegator
    def generator
      nil
    end

    def authentication_token
      "authentication-token"
    end

    def serial_number
      "serial-number"
    end

    def sharing
      nil
    end

    def web_service_url
      "https://example.com/passkit/api"
    end

    def apple_team_identifier
      "TEAMIDENTIFIER"
    end

    def [](key)
      nil
    end
  end

  def pass_json_for(pass_class)
    generator = Passkit::Generator.new(PassDouble.new(pass_class.new))
    generator.send(:pass_json, "pass.com.example.card")
  end

  def test_poster_dictionary_is_emitted_alongside_the_classic_one
    json = pass_json_for(PosterCard)

    assert_equal [{key: "membershipType", value: "Family Pass"}], json[:posterGeneric][:footerFields]
    assert_equal [{key: "memberName", label: "Member Name", value: "Juan Chavez"}], json[:posterGeneric][:primaryFields]
    assert_equal json[:generic][:headerFields], json[:posterGeneric][:headerFields]
    assert_equal json[:generic][:backFields], json[:posterGeneric][:backFields]
  end

  def test_poster_dictionary_carries_no_secondary_or_auxiliary_rows
    assert_equal %i[headerFields primaryFields footerFields backFields], pass_json_for(PosterCard)[:posterGeneric].keys
  end

  # The classic layout puts primary fields above the barcode, the poster below it.
  def test_poster_primary_fields_are_independent_of_the_classic_ones
    json = pass_json_for(PosterCard)

    assert_equal [{key: "balance", value: "$25"}], json[:generic][:primaryFields]
    refute_equal json[:generic][:primaryFields], json[:posterGeneric][:primaryFields]
  end

  def test_featured_actions_are_emitted
    json = pass_json_for(PosterCard)

    assert_equal [{identifier: "redeem", type: "shop", url: "https://example.com/redeem"}], json[:featuredActions]
  end

  def test_passes_without_a_poster_style_are_unchanged
    json = pass_json_for(Passkit::ExampleStoreCard)

    assert json.key?(:storeCard)
    refute json.key?(:posterGeneric)
    refute json.key?(:featuredActions)
  end

  def test_poster_primary_fields_default_to_the_classic_ones
    json = pass_json_for(DefaultPosterCard)

    assert_equal [{key: "balance", value: "$25"}], json[:posterGeneric][:primaryFields]
    assert_equal json[:storeCard][:primaryFields], json[:posterGeneric][:primaryFields]
  end

  def test_boarding_pass_keys_are_merged_into_the_style_dictionary
    json = pass_json_for(BoardingCard)

    assert_equal "PKTransitTypeGeneric", json[:boardingPass][:transitType]
    assert_equal BoardingCard.new.header_fields, json[:boardingPass][:headerFields]
  end

  def test_nil_featured_actions_emit_no_key
    refute pass_json_for(NilActionsCard).key?(:featuredActions)
  end
end
