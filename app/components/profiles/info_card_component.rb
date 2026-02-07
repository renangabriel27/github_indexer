# frozen_string_literal: true

module Profiles
  class InfoCardComponent < ViewComponent::Base
    attr_reader :icon, :label, :value, :show

    def initialize(icon:, label:, value:, show: true)
      @icon = icon
      @label = label
      @value = value
      @show = show
    end

    def container_classes
      classes = [ "flex items-center gap-3 text-gray-400" ]
      classes << "hidden" unless show
      classes.join(" ")
    end

    def icon_classes
      "w-5 h-5 text-gray-500"
    end

    def label_classes
      "text-xs text-gray-500"
    end

    def value_classes
      "text-white"
    end
  end
end
