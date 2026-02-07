# frozen_string_literal: true

module Shared
  class ModalComponent < ViewComponent::Base
    renders_one :trigger
    renders_one :body

    attr_reader :title, :description, :confirm_text, :cancel_text, :confirm_url, :confirm_method, :modal_id

    def initialize(title:, description: nil, confirm_text: "Confirmar", cancel_text: "Cancelar", confirm_url: nil, confirm_method: :post, modal_id: nil)
      @title = title
      @description = description
      @confirm_text = confirm_text
      @cancel_text = cancel_text
      @confirm_url = confirm_url
      @confirm_method = confirm_method
      @modal_id = modal_id || "modal-#{SecureRandom.hex(4)}"
    end

    def backdrop_classes
      "fixed inset-0 bg-black/50 backdrop-blur-sm z-50 hidden items-center justify-center"
    end

    def container_classes
      "bg-slate-800 border border-slate-700 rounded-2xl p-6 max-w-md mx-4 shadow-2xl"
    end

    def icon_container_classes
      "flex-shrink-0 w-12 h-12 bg-red-500/20 rounded-full flex items-center justify-center"
    end
  end
end
