module Passkit
  class Factory
    class << self
      # generator is an optional ActiveRecord object, the application data for the pass
      def create_pass(pass_class, generator = nil, pass_attributes = {}, certificate_id = nil)
        pass = Passkit::Pass.create!(klass: pass_class, generator: generator, **pass_attributes)
        Passkit::Generator.new(pass).generate_and_sign(certificate_id)
      end
    end
  end
end
