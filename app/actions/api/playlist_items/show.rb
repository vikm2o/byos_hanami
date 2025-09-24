# frozen_string_literal: true

require "initable"
require "petail"

module Terminus
  module Actions
    module API
      module PlaylistItems
        # The show action.
        class Show < Base
          include Deps[repository: "repositories.playlist_item"]
          include Initable[serializer: Serializers::PlaylistItem, problem: Petail]

          def handle request, response
            playlist_item = repository.find request.params[:id]

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
