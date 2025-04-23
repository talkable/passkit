module Passkit
  module Certificates
    class NullCertificate
      def certificate
        ENV.fetch("PASSKIT_PRIVATE_P12_CERTIFICATE") { raise "Please set PASSKIT_PRIVATE_P12_CERTIFICATE" }
      end

      def secret
        ENV.fetch("PASSKIT_CERTIFICATE_KEY") { raise "Please set PASSKIT_CERTIFICATE_KEY" }
      end

      def identifier
        ENV["PASSKIT_PASS_TYPE_IDENTIFIER"] { raise "Please set PASSKIT_PASS_TYPE_IDENTIFIER" }
      end
    end
  end
end
