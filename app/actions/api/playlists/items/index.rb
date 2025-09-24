# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module API
      module Playlists
        module Items
          # The index action for playlist items.
          class Index < Base
            include Deps[repository: "repositories.playlist_item"]
            include Initable[serializer: Serializers::PlaylistItem]

            def handle request, response
              playlist_id = request.params[:playlist_id]
              items = repository.where(playlist_id: playlist_id)
              response.body = {data: items.map { serializer.new(it).to_h }}.to_json
            end
          end
        end
      end
    end
  end
end
