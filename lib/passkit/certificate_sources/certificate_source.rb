module Passkit::CertificateSources::CertificateSource
  def certificate
    raise NotImplementedError
  end

  def password
    raise NotImplementedError
  end
end
