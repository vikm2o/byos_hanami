# auto_register: false
# frozen_string_literal: true

module Terminus
  module Serializers
    # A playlist item serializer for specific keys.
    class PlaylistItem
      KEYS = %i[id playlist_id screen_id position repeat_interval repeat_type repeat_days last_day_of_month start_at stop_at hidden_at created_at updated_at].freeze

      def initialize record, keys: KEYS, transformer: Transformers::Time
        @record = record
        @keys = keys
        @transformer = transformer
      end

      def to_h
        attributes = record.to_h.slice(*keys)
        attributes.transform_values!(&transformer)
        attributes.merge! screen: screen_data if record.screen
        attributes
      end

      private

      attr_reader :record, :keys, :transformer

      def screen_data
        Serializers::Screen.new(record.screen).to_h
      end
    end
  end
end
