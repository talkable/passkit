module Passkit
  class CertificateSource
		def initialize(*); end

		def call
			OpenSSL::PKCS12.new(File.read(certificate), certificate_password)
		end

		private

		def certificate
			Rails.root.join(ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"]) || (raise "Please set PASSKIT_PRIVATE_P12_CERTIFICATE")
		end
		
		def certificate_password
			ENV["PASSKIT_CERTIFICATE_KEY"] || (raise "Please set PASSKIT_CERTIFICATE_KEY")
		end
	end
end
    