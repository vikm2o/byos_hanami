# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module API
      module Playlists
        module Items
          # The patch action for playlist items.
          class Patch < Base
            include Deps[repository: "repositories.playlist_item"]
            include Initable[serializer: Serializers::PlaylistItem]

            using Refines::Actions::Response

            params do
              required(:playlist_id).filled :integer
              required(:id).filled :integer

              required(:playlist_item).filled(:hash) do
                optional(:screen_id).maybe :integer
                optional(:position).maybe :integer
                optional(:repeat_interval).maybe :integer
                optional(:repeat_type).maybe :string
                optional(:repeat_days).maybe :array
                optional(:last_day_of_month).maybe :bool
                optional(:start_at).maybe :date_time
                optional(:stop_at).maybe :date_time
                optional(:hidden_at).maybe :date_time
              end
            end

            def handle request, response
              parameters = request.params

              if parameters.valid?
                playlist_item = repository.find_by(
                  playlist_id: parameters[:playlist_id], 
                  id: parameters[:id]
                )
                
                if playlist_item
                  # Ignore nil optional fields so UI doesn't need to send them
                  cleaned = parameters[:playlist_item].compact
                  updated_item = repository.update(playlist_item.id, **cleaned)
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
                instance: "/api/playlists/#{parameters[:playlist_id]}/items/#{parameters[:id]}",
                extensions: {errors: parameters.errors.to_h}
              ]

              response.with body: body.to_json, format: :problem_details, status: 422
            end
          end
        end
      end
    end
  end
end
