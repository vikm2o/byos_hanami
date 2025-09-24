# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module API
      module Playlists
        module Items
          # The create action for playlist items.
          class Create < Base
            include Deps[
              repository: "repositories.playlist_item",
              playlist_repository: "repositories.playlist"
            ]
            include Initable[serializer: Serializers::PlaylistItem]

            using Refines::Actions::Response

            params do
              required(:playlist_id).filled :integer
              required(:playlist_item).filled(:hash) do
                required(:screen_id).filled :integer
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
                playlist_item = create_playlist_item parameters
                response.body = {data: serializer.new(playlist_item).to_h}.to_json
              else
                unprocessable_entity parameters, response
              end
            end

            private

            def create_playlist_item params
              playlist_id = params[:playlist_id]
              playlist = playlist_repository.find playlist_id
              
              halt :not_found unless playlist

              item_params = params[:playlist_item].merge(playlist_id: playlist_id)
              item = repository.create_with_position(**item_params)
              playlist_repository.update_current_item playlist_id, item
              item
            end

            def unprocessable_entity parameters, response
              body = problem[
                type: "/problem_details#playlist_item_payload",
                status: :unprocessable_entity,
                detail: "Validation failed.",
                instance: "/api/playlists/#{parameters[:playlist_id]}/items",
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
