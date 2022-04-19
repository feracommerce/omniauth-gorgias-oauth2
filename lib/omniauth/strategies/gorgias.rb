require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Gorgias < OmniAuth::Strategies::OAuth2
      option :client_options, {
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/token'
      }

      option :gorgias_domain, 'gorgias.com'

      option :setup, (proc { |env|
        strategy = env['omniauth.strategy']
        site = "https://#{strategy.account}.#{strategy.options[:gorgias_domain]}"

        strategy.options[:client_options][:site] = site
      })

      def request_phase
        return fail!(:account_missing) unless account_present?

        options[:scope] ||= 'openid'
        options[:response_type] ||= 'code'

        super
      end

      uid { account }

      def authorize_params
        nonce = SecureRandom.hex(16)
        session['omniauth.nonce'] = nonce

        super.merge(nonce: nonce)
      end

      def callback_url
        full_host + script_name + callback_path + "?account=#{account}"
      end

      def token_params
        super.merge(
          headers: {
            'Authorization' => "Basic #{Base64.strict_encode64("#{options.client_id}:#{options.client_secret}")}"
          },
          redirect_uri: callback_url
        )
      end

      def account
        @account ||= request.params['account']
      end

      def account_present?
        !!(account =~ /\A[a-z0-9]+\z/i)
      end
    end
  end
end
