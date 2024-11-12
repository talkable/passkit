class Passkit::CertificateSources::Factory
  def self.find_source(site_id)
    if Passkit.configuration.use_database_for_certificates
      Passkit::CertificateSources::Database.new(site_id)
    else
      Passkit::CertificateSources::Env.new
    end
  end
end
