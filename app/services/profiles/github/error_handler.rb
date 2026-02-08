# frozen_string_literal: true

module Profiles
  module Github
    class ErrorHandler
      def initialize(profile)
        @profile = profile
      end

      def handle_not_found_error(error)
        update_profile(:failed, "Perfil não encontrado")
        Dry::Monads::Failure(error: :profile_not_found, message: error.message)
      end

      def handle_standard_error(error)
        message = standardize_error_message(error)
        update_profile(:failed, message)
        Dry::Monads::Failure(error: :scraping_failed, message: message)
      end

      private

      def update_profile(status, error_message)
        @profile.update(
          scraping_status: status,
          last_error: error_message,
          last_scanned_at: Time.current
        )
      end

      def standardize_error_message(error)
        error_msg = error.message.to_s

        case error_msg
        when /404|not found|não encontrado/i
          "Perfil não encontrado"
        when /timeout|timed out/i
          "Timeout ao carregar página do GitHub"
        when /network|connection|conexão/i
          "Erro de conexão com GitHub"
        when /ferrum|browser/i
          "Erro ao inicializar navegador"
        else
          "Erro ao processar perfil: #{error_msg}"
        end
      end
    end
  end
end
