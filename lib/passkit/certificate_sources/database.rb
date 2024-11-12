class Passkit::CertificateSources::Database
  include Passkit::CertificateSources::CertificateSource

  def initialize(site_id)
    @site_id = site_id
  end

  def certificate
    certificate_record.certificate
  end

  def password
    certificate_record.secret
  end

  private

  def certificate_record
    @certificate_record ||= Passkit::Certificate.find_by!(site_id: @site_id)
  end
end

