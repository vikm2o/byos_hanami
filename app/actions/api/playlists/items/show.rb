# frozen_string_literal: true

require "initable"
require "petail"

module Terminus
  module Actions
    module API
      module Playlists
        module Items
          # The show action for playlist items.
          class Show < Base
            include Deps[repository: "repositories.playlist_item"]
            include Initable[serializer: Serializers::PlaylistItem, problem: Petail]

            def handle request, response
              playlist_id = request.params[:playlist_id]
              item_id = request.params[:id]
              
              playlist_item = repository.find_by(playlist_id: playlist_id, id: item_id)

              response.body = if playlist_item
                                {data: serializer.new(playlist_item).to_h}.to_json
                              else
                                problem[status: :not_found].to_json
                              end
            end
          end
        end
      end
    end
  end
end
