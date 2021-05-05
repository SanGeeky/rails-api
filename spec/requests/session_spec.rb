require 'rails_helper'
RSpec.describe 'Session', type: :request do
  let(:user) { create :user }
  let(:login_params) do
    {
      email: user.email,
      password: user.password
    }
  end
  let(:login) do
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
      it 'returns token-type in authentication header' do
        expect(login.headers['token-type']).to eq('Bearer')
      end
      it 'returns access-token in authentication header' do
        expect(login.headers['access-token']).to be_present
      end
      it 'returns client in authentication header' do
        expect(login.headers['client']).to be_present
      end
      it 'returns expiry in authentication header' do
        expect(login.headers['expiry']).to be_present
      end
      it 'returns uid in authentication header' do
        expect(login.headers['uid']).to be_present
      end
      it 'returns user email' do
        parsed_response = JSON.parse(login.body)
        expect(parsed_response['data']['email']).to eq(user.email)
      end
    end

    context 'login params is invalid' do
      before { post user_session_path }
      it 'returns unathorized status 401' do
        expect(response.status).to eq 401
      end
      it { expect(response.body).to match(/Invalid login credentials. Please try again./) }
    end
  end

  describe 'DELETE /auth/sign_out/' do
    before do
      login
      headers = {
        'access-token': login.headers['access-token'],
        'client': login.headers['client'],
        'uid': login.headers['uid'],
        'expiry': login.headers['expiry'],
        'token-type': login.headers['token-type']
      }
      delete destroy_user_session_path, headers: headers
    end

    it { expect(response).to have_http_status(200) }
    it 'returns status success' do
      expect(response.body).to match(/success/)
    end
  end
end
