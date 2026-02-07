# frozen_string_literal: true

module Ui
  class BackLinkComponent < ViewComponent::Base
    attr_reader :text, :href

    def initialize(text: "Voltar", href:)
      @text = text
      @href = href
    end

    def classes
      "inline-flex items-center gap-2 text-gray-400 hover:text-white transition-colors"
    end
  end
end
