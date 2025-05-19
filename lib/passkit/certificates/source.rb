module Passkit
  module Certificates
    class Source
      delegate :certificate, :key, to: :source
      delegate :identifier, to: :cert_data

      def initialize(certificate_id = nil)
        @certificate_id = certificate_id
      end

      def source
        @source ||= OpenSSL::PKCS12.new(Base64.decode64(cert_data.certificate), cert_data.secret)
      end

      private

      def cert_data
        @cert_data ||= if @certificate_id
          Passkit::Certificate.find(@certificate_id)
        else
          Passkit::Certificates::NullCertificate.new
        end
      end
    end
  end
end
