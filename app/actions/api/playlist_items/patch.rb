# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module API
      module PlaylistItems
        # The patch action.
        class Patch < Base
          include Deps[repository: "repositories.playlist_item"]
          include Initable[serializer: Serializers::PlaylistItem]

          using Refines::Actions::Response

          params do
            required(:id).filled :integer

            required(:playlist_item).filled(:hash) do
              optional(:screen_id).filled :integer
              optional(:position).filled :integer
              optional(:repeat_interval).filled :integer
              optional(:repeat_type).filled :string
              optional(:repeat_days).filled :array
              optional(:last_day_of_month).filled :bool
              optional(:start_at).filled :date_time
              optional(:stop_at).filled :date_time
              optional(:hidden_at).filled :date_time
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              playlist_item = repository.find parameters[:id]
              
              if playlist_item
                updated_item = repository.update(*parameters.to_h.values_at(:id, :playlist_item))
                response.body = {data: serializer.new(updated_item).to_h}.to_json
              else
                response.body = problem[status: :not_found].to_json
              end
            else
              unprocessable_entity parameters, response
            end
          end

          private

          def unprocessable_entity parameters, response
            body = problem[
              type: "/problem_details#playlist_item_payload",
              status: :unprocessable_entity,
              detail: "Validation failed.",
              instance: "/api/playlist_items",
              extensions: {errors: parameters.errors.to_h}
            ]

            response.with body: body.to_json, format: :problem_details, status: 422
          end
        end
      end
    end
  end
end
