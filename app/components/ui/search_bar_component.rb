# frozen_string_literal: true

module Ui
  class SearchBarComponent < ViewComponent::Base
    attr_reader :url, :method, :placeholder, :param_name, :value

    def initialize(url:, method: :get, placeholder: "Buscar...", param_name: :q, value: nil)
      @url = url
      @method = method
      @placeholder = placeholder
      @param_name = param_name
      @value = value
    end

    def outer_container_classes
      "relative max-w-3xl mx-auto group"
    end

    def glow_classes
      "absolute -inset-0.5 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-2xl blur opacity-20 group-hover:opacity-40 transition duration-300"
    end

    def inner_container_classes
      "relative flex items-center bg-slate-800 rounded-2xl border border-slate-700 shadow-2xl overflow-hidden"
    end

    def icon_container_classes
      "absolute inset-y-0 left-0 pl-5 flex items-center pointer-events-none"
    end

    def input_classes
      "w-full bg-transparent border-0 pl-14 pr-24 py-5 text-white placeholder-gray-500 text-lg focus:ring-0 focus:outline-none"
    end

    def button_classes
      "absolute right-3 p-3 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-xl hover:shadow-lg hover:shadow-indigo-500/50 transition-all duration-200 hover:scale-105"
    end
  end
end
