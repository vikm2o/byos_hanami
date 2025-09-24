# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module API
      module PlaylistItems
        # The index action.
        class Index < Base
          include Deps[repository: "repositories.playlist_item"]
          include Initable[serializer: Serializers::PlaylistItem]

          def handle(*, response) = response.body = {data:}.to_json

          private

          def data = repository.all.map { serializer.new(it).to_h }
        end
      end
    end
  end
end
