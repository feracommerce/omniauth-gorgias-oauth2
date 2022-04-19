require 'omniauth-gorgias-oauth2'

describe OmniAuth::Strategies::Gorgias do # rubocop:disable Metrics/BlockLength
  let(:request) { double('Request', env: {}, params: { 'account' => 'test' }, cookies: {}) }
  let(:client_id) { 'aBc123' }
  let(:client_secret) { 'a1B2c3' }

  subject do
    args = [client_id, client_secret, {}].compact
    OmniAuth::Strategies::Gorgias.new(nil, *args).tap do |strategy|
      env = strategy.env || {}
      env['omniauth.strategy'] = strategy

      allow(strategy).to receive(:request) { request }
      allow(strategy).to receive(:session) { {} }

      strategy.options[:setup].call(env)
    end
  end

  describe '::setup' do
    it 'should set the site' do
      expect(subject.options.client_options.site).to eq('https://test.gorgias.com')
    end
  end

  describe '#client' do
    it 'has correct gorgias site' do
      expect(subject.client.site).to eq('https://test.gorgias.com')
    end

    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('/oauth/authorize')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('/oauth/token')
    end
  end

  describe '#callback_url' do
    let(:base_url) { 'http://auth.myapp.com' }

    it 'returns callback with account' do
      allow(request).to receive(:scheme) { 'http' }
      allow(request).to receive(:url) { "#{base_url}/path" }

      allow(subject).to receive(:script_name) { '' } # to not depend from Rack env

      expect(subject.callback_url).to eq("#{base_url}/auth/gorgias/callback?account=test")
    end
  end

  describe '#authorize_params' do
    it 'adds nonce' do
      expect(subject.authorize_params).to be_a(Hash)
      expect(subject.authorize_params[:nonce]).to be_a(String)
    end
  end

  describe '#uid' do
    it 'returns the account username' do
      expect(subject.uid).to eq('test')
    end
  end

  describe '#credentials' do
    let(:access_token) { double('OAuth2::AccessToken') }

    before :each do
      allow(access_token).to receive(:token)
      allow(access_token).to receive(:expires?)
      allow(access_token).to receive(:expires_at)
      allow(access_token).to receive(:refresh_token)

      allow(subject).to receive(:access_token) { access_token }
    end

    it 'returns a Hash' do
      expect(subject.credentials).to be_a(Hash)
    end

    it 'returns the token' do
      allow(access_token).to receive(:token) { '123' }
      expect(subject.credentials['token']).to eq('123')
    end

    it 'returns the expiry status' do
      allow(access_token).to receive(:expires?) { true }
      expect(subject.credentials['expires']).to eq(true)

      allow(access_token).to receive(:expires?) { false }
      expect(subject.credentials['expires']).to eq(false)
    end
  end

  describe '#account_present?' do
    it 'returns true if account query param is present' do
      expect(subject.account_present?).to eq(true)
    end

    context 'when account is missing in the URL' do
      let(:request) { double('Request', params: {}) }

      it 'returns false' do
        expect(subject.account_present?).to eq(false)
      end
    end
  end
end
