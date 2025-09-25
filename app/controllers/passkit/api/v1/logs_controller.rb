module Passkit
  module Api
    module V1
      class LogsController < ApplicationController
        def create
          params[:logs].each do |message|
            Log.create!(content: message)
          end
          render json: {}, status: :ok
        end
      end
    end
  end
end
