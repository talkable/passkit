require "fileutils"

module Passkit
  class BasePass
    # The filename Wallet looks for in the bundle, per image slot. The names are
    # not derivable from the keys -- Apple mixes camelCase basenames with an
    # @2x/@3x scale suffix -- so swapping "_" for "@" yields primary@logo.png,
    # a file Wallet ignores in silence: no error, and no logo on the pass.
    # https://developer.apple.com/documentation/walletpasses/creating-a-pass-with-pass-designer
    IMAGE_FILE_NAMES = {
      icon: "icon.png", icon_2x: "icon@2x.png", icon_3x: "icon@3x.png",
      logo: "logo.png", logo_2x: "logo@2x.png", logo_3x: "logo@3x.png",
      # The logo slot of the poster styles (iOS 27+). posterGeneric renders
      # primaryLogo and never logo, so a poster pass shipping logo.png alone has
      # no logo at all. Max 126x30pt -- 252x60 at @2x, 378x90 at @3x.
      primary_logo: "primaryLogo.png", primary_logo_2x: "primaryLogo@2x.png",
      primary_logo_3x: "primaryLogo@3x.png",
      strip: "strip.png", strip_2x: "strip@2x.png", strip_3x: "strip@3x.png",
      # The poster styles' full-bleed image. Not background.png, which is the
      # blurred backdrop of the classic event ticket.
      artwork: "artwork.png", artwork_2x: "artwork@2x.png", artwork_3x: "artwork@3x.png"
    }.freeze

    def initialize(generator = nil)
      @generator = generator
    end

    # Copies prepared images into the pass bundle under the names Wallet looks
    # for. Keys are IMAGE_FILE_NAMES slots; an unknown one raises rather than
    # writing a file Wallet would ignore without complaining.
    #
    #   install_images(icon: "/tmp/icon.png", primary_logo: "/tmp/brand.png")
    def install_images(sources)
      FileUtils.mkdir_p(pass_path)
      sources.each do |slot, source|
        FileUtils.cp(source, File.join(pass_path, IMAGE_FILE_NAMES.fetch(slot)))
      end
    end

    def format_version
      ENV["PASSKIT_FORMAT_VERSION"] || 1
    end

    def apple_team_identifier
      ENV["PASSKIT_APPLE_TEAM_IDENTIFIER"] || raise(Error.new("Missing environment variable: PASSKIT_APPLE_TEAM_IDENTIFIER"))
    end

    def language
      nil
    end

    def last_update
      @generator&.updated_at
    end

    def pass_path
      rails_folder = Rails.root.join("private/passkit/#{folder_name}")
      # if folder exists, otherwise is in the gem itself under lib/passkit/base_pass
      if File.directory?(rails_folder)
        rails_folder
      else
        File.join(File.dirname(__FILE__), folder_name)
      end
    end

    def pass_type
      :storeCard
      # :coupon
      # :eventTicket
      # :generic
      # :boardingPass
    end

    def web_service_url
      raise Error.new("Missing environment variable: PASSKIT_WEB_SERVICE_HOST") unless ENV["PASSKIT_WEB_SERVICE_HOST"]
      "#{ENV["PASSKIT_WEB_SERVICE_HOST"]}/passkit/api"
    end

    # The foreground color, used for the values of fields shown on the front of the pass.
    def foreground_color
      # black
      "rgb(0, 0, 0)"
    end

    # The background color, used for the background of the front and back of the pass.
    # If you provide a background image, any background color is ignored.
    def background_color
      # white
      "rgb(255, 255, 255)"
    end

    # The label color, used for the labels of fields shown on the front of the pass.
    def label_color
      # black
      "rgb(0, 0, 0)"
    end

    # The organization name is displayed on the lock screen when your pass is relevant and by apps such as Mail which
    # act as a conduit for passes. The value for the organizationName key in the pass specifies the organization name.
    # Choose a name that users recognize and associate with your organization or company.
    def organization_name
      "Passkit"
    end

    # The description lets VoiceOver make your pass accessible to blind and low-vision users. The value for the
    # description key in the pass specifies the description.
    # @see https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html
    def description
      "A basic description for a pass"
    end

    # An array of up to 10 latitudes and longitudes. iOS uses these locations to determine when to display the pass on the lock screen
    #
    # @see https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/PassKit_PG/Creating.html
    def locations
      []
    end

    def voided
      false
    end

    # After base files are copied this is called to allow for adding custom images
    def add_other_files(path)
    end

    # Distance in meters from locations; if blank uses pass default.
    # The system uses the smaller of either this distance or the default distance.
    def max_distance
    end

    # URL to launch the associated app (nil by default)
    # Returns a String
    def app_launch_url
    end

    # A list of Apple App Store identifiers for apps associated
    # with the pass. The first one that is compatible with the
    # device is picked.
    # Returns an array of numbers
    def associated_store_identifiers
      []
    end

    # An array of barcodes, the first one that can
    # be displayed on the device is picked.
    # Returns an array of hashes representing Pass.Barcodes
    def barcodes
      []
    end

    # List of iBeacon identifiers to identify when the
    # pass should be displayed.
    # Returns an array of hashes representing Pass.Beacons
    def beacons
      []
    end

    # Information specific to a boarding pass
    # Returns a hash representing Pass.BoardingPass
    # https://developer.apple.com/documentation/walletpasses/pass/boardingpass
    # i.e {transitType: 'PKTransitTypeGeneric'}
    def boarding_pass
      {}
    end

    # Date and time the pass expires, must include
    # days, hours and minutes (seconds are optional)
    # Returns a String representing the date and time in W3C format ('%Y-%m-%dT%H:%M:%S%:z')
    # For example, 1980-05-07T10:30-05:00.
    def expiration_date
    end

    # A key to identify group multiple passes together
    # (e.g. a number of boarding passes for the same trip)
    # Returns a String
    def grouping_identifier
    end

    # Information specific to Value Added Service Protocol
    # transactions
    # Returns a hash representing Pass.NFC
    def nfc
    end

    # Date and time when the pass becomes relevant and should be
    # displayed, must include days, hours and minutes
    # (seconds are optional)
    # Returns a String representing the date and time in W3C format ('%Y-%m-%dT%H:%M:%S%:z')
    def relevant_date
    end

    # Machine readable metadata that the device can use
    # to suggest actions
    # Returns a hash representing SemanticTags
    def semantics
    end

    # Display the strip image without a shine effect
    # Returns a boolean
    def suppress_strip_shine
      true
    end

    # JSON dictionary to display custom information for
    # companion apps. Data isn't displayed to the user. e.g.
    # a machine readable version of the user's favourite coffee
    def user_info
    end

    def file_name
      @file_name ||= SecureRandom.uuid
    end

    # QRCode by default
    def barcode
      { messageEncoding: "iso-8859-1",
        format: "PKBarcodeFormatQR",
        message: "https://github.com/coorasse/passkit",
        altText: "https://github.com/coorasse/passkit" }
    end

    # Barcode example
    # def barcode
    #   { messageEncoding: 'iso-8859-1',
    #     format: 'PKBarcodeFormatCode128',
    #     message: '12345',
    #     altText: '12345' }
    # end

    def logo_text
      "Logo text"
    end

    def header_fields
      []
    end

    def primary_fields
      []
    end

    def secondary_fields
      []
    end

    def auxiliary_fields
      []
    end

    def back_fields
      []
    end

    def sharing_prohibited
      false
    end

    # Poster style dictionary to emit alongside pass_type. :posterGeneric (iOS 27+)
    # is the only poster style Wallet accepts as a top-level key -- posterEventTicket
    # is a preferredStyleSchemes entry instead, not a style dictionary.
    # Older iOS ignores the unknown key and renders pass_type instead, so a pass
    # carrying both is readable everywhere.
    def poster_pass_type
    end

    # Poster styles replace the secondary/auxiliary rows of the classic layouts
    # with a single footer field.
    def footer_fields
      []
    end

    # The row above the footer of a poster style. The classic primary fields sit
    # above the barcode instead, so a pass carrying both layouts usually needs
    # different content here.
    def poster_primary_fields
      primary_fields
    end

    # Up to two buttons rendered on the face of the pass (iOS 27+).
    # Returns an array of hashes representing Pass.FeaturedActions
    # i.e {identifier: "redeem", type: "shop", url: "https://example.com"}
    def featured_actions
      []
    end

  private

    def folder_name
      self.class.name.demodulize.underscore
    end
  end
end
