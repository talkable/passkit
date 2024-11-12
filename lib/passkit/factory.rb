module Passkit
  class Factory
    class << self
      # generator is an optional ActiveRecord object, the application data for the pass
      def create_pass(pass_class, generator: nil, site_id: nil)
        attributes = { klass: pass_class, generator: generator }
        attributes[:site_id] = site_id if site_id

        pass = Passkit::Pass.find_or_create_by!(attributes)
        Passkit::Generator.new(pass).generate_and_sign
      end
    end
  end
end
