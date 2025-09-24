# frozen_string_literal: true

require "initable"
require "petail"

module Terminus
  module Actions
    module API
      module Playlists
        module Items
          # The delete action for playlist items.
          class Delete < Base
            include Deps[repository: "repositories.playlist_item"]
            include Initable[problem: Petail]

            def handle request, response
              playlist_id = request.params[:playlist_id]
              item_id = request.params[:id]
              
              playlist_item = repository.find_by(playlist_id: playlist_id, id: item_id)

              if playlist_item
                repository.delete playlist_item.id
                response.status = 204
                response.body = ""
              else
                response.body = problem[status: :not_found].to_json
              end
            end
          end
        end
      end
    end
  end
end
