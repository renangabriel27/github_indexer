# frozen_string_literal: true

module Profiles
  module Github
    class HtmlParser < OrganizedService
      def initialize(html, update_name: false)
        @html = html
        @update_name = update_name
        @doc = Nokogiri::HTML(html)
      end

      def parse
        call.value_or({})[:data]
      end

      private

      def context
        { doc: @doc, update_name: @update_name, data: {} }
      end

      def steps
        [
          :extract_identity,
          :extract_statistics,
          :extract_avatar,
          :extract_location,
          :extract_organizations
        ]
      end

      def extract_identity(ctx)
        result = Extractors::IdentityExtractor.call(ctx[:doc], update_name: ctx[:update_name])
        result.fmap { |data| ctx[:data].merge!(data); ctx }
      end

      def extract_statistics(ctx)
        result = Extractors::StatisticsExtractor.call(ctx[:doc])
        result.fmap { |data| ctx[:data].merge!(data); ctx }
      end

      def extract_avatar(ctx)
        result = Extractors::AvatarExtractor.call(ctx[:doc])
        result.fmap { |data| ctx[:data].merge!(data); ctx }
      end

      def extract_location(ctx)
        result = Extractors::LocationExtractor.call(ctx[:doc])
        result.fmap { |data| ctx[:data].merge!(data); ctx }
      end

      def extract_organizations(ctx)
        result = Extractors::OrganizationsExtractor.call(ctx[:doc])
        result.fmap { |data| ctx[:data].merge!(data); ctx }
      end
    end
  end
end
