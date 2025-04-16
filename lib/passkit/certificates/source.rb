module Passkit
  module Certificates
    class Source
      delegate :certificate, :key, to: :source

      def initialize(certificate_id = nil)
        @certificate_id = certificate_id
      end

      def source
        cert_data = if @certificate_id
          Passkit::Certificate.find(@certificate_id)
        else
          Passkit::Certificates::NullCertificate.new
        end

        OpenSSL::PKCS12.new(File.read(cert_data.certificate), cert_data.secret)
      end
    end
  end
end
