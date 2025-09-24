# frozen_string_literal: true

require "initable"
require "petail"

module Terminus
  module Actions
    module API
      module PlaylistItems
        # The delete action.
        class Delete < Base
          include Deps[repository: "repositories.playlist_item"]
          include Initable[problem: Petail]

          def handle request, response
            playlist_item = repository.find request.params[:id]

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
