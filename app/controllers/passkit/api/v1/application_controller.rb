# frozen_string_literal: true

module Passkit
  module Api
    module V1
      class ApplicationController < ActionController::API
        after_action :allow_iframe

        # The X-Frame-Options - header that indicate whether or not a browser should be allowed to render a page in a <frame>
        def allow_iframe
          response.headers.except! 'X-Frame-Options'
        end
      end
    end
  end
end
