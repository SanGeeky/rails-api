require 'rails_helper'
RSpec.describe 'Session', type: :request do
  let(:user) { create :user }
  let(:login_params) do
    {
      email: user.email,
      password: user.password
    }
  end

  # Login Token Auth
  subject(:login) do
    post user_session_path,
         params: login_params.to_json,
         headers: {
           CONTENT_TYPE: 'application/json',
           ACCEPT: 'application/json'
         }
    response
  end

  describe 'POST /auth/sign_in/' do
    context 'login params is valid' do
      it { expect(login).to have_http_status(200) }

      it 'returns the token auth headers' do
        expect(login.headers).to(
          include('token-type', 'access-token', 'client', 'expiry', 'uid')
        )
      end

      it 'returns user email' do
        expect(json['data']['email']).to eq(user.email)
      end
    end

    context 'login params is invalid' do
      before { post user_session_path }

      it 'returns unathorized status 401' do
        expect(response).to have_http_status(401)
      end

      it { expect(json['errors'].join).to eq('Invalid login credentials. Please try again.') }

      it { expect(json['success']).to eq(false) }
    end
  end

  describe 'DELETE /auth/sign_out/' do
    subject do
      login
      headers = {
        'access-token': login.headers['access-token'],
        'client': login.headers['client'],
        'uid': login.headers['uid'],
        'expiry': login.headers['expiry'],
        'token-type': login.headers['token-type']
      }
      delete destroy_user_session_path, headers: headers
      response
    end

    it { expect(subject).to have_http_status(200) }

    it 'returns status success' do
      expect(json['success']).to eq true
    end
  end
end
