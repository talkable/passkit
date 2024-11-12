class Passkit::CertificateSources::Env
  include Passkit::CertificateSources::CertificateSource

  def certificate
    Rails.root.join(ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"])
  end

  def password
    ENV["PASSKIT_CERTIFICATE_KEY"]
  end
end

