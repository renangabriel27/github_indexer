# frozen_string_literal: true

module Profiles
  class FormFieldComponent < ViewComponent::Base
    attr_reader :form, :attribute, :label, :icon, :prefix, :placeholder, :help_text, :field_type

    def initialize(form:, attribute:, label:, icon: nil, prefix: nil, placeholder: nil, help_text: nil, field_type: :text)
      @form = form
      @attribute = attribute
      @label = label
      @icon = icon
      @prefix = prefix
      @placeholder = placeholder
      @help_text = help_text
      @field_type = field_type
    end

    def object
      form.object
    end

    def has_errors?
      object.errors[attribute].any?
    end

    def error_message
      object.errors[attribute].first
    end

    def container_classes
      "mb-6"
    end

    def label_classes
      "block text-sm font-medium text-gray-300 mb-2"
    end

    def input_container_classes
      "relative"
    end

    def prefix_container_classes
      "absolute inset-y-0 left-0 flex items-center"
    end

    def prefix_inner_classes
      "flex items-center gap-2 px-4 text-gray-500 border-r border-slate-600 h-full bg-slate-900/80 rounded-l-xl"
    end

    def icon_container_classes
      "absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none"
    end

    def input_classes
      base = "w-full bg-slate-900/50 border rounded-xl text-white placeholder-gray-500 transition-all focus:outline-none focus:ring-2"
      padding = if prefix.present?
        "px-4 sm:pl-44 sm:pr-4 py-3.5"  # Responsive padding: normal on mobile, prefix spacing on desktop
      elsif icon.present?
        "pl-12 pr-4 py-3.5"
      else
        "px-4 py-3.5"
      end

      border_color = if has_errors?
        "border-red-500 focus:ring-red-500/50 focus:border-red-500"
      else
        "border-slate-600 focus:ring-indigo-500/50 focus:border-indigo-500"
      end

      [ base, padding, border_color ].join(" ")
    end

    def error_container_classes
      "mt-2 text-sm text-red-400 flex items-center gap-1"
    end

    def help_container_classes
      "mt-2 text-sm flex items-center gap-1"
    end

    def help_text_classes
      "text-gray-500"
    end
  end
end
