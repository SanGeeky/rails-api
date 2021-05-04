require 'rails_helper'
RSpec.describe 'Session', type: :request do
  let(:user) { create :user }
  let(:login_params) do
    {
      email: user.email,
      password: user.password
    }
  end

  describe 'POST /auth/sign_in/' do
    context 'when login params is valid' do
      before do
        post user_session_path, params: login_params, as: :json
      end

      it { expect(response).to have_http_status(200) }
      it 'returns token-type in authentication header' do
        expect(response.headers['token-type']).to eq('Bearer')
      end
      it 'returns access-token in authentication header' do
        expect(response.headers['access-token']).to be_present
      end
      it 'returns client in authentication header' do
        expect(response.headers['client']).to be_present
      end
      it 'returns expiry in authentication header' do
        expect(response.headers['expiry']).to be_present
      end
      it 'returns uid in authentication header' do
        expect(response.headers['uid']).to be_present
      end
      it 'returns user email' do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['data']['email']).to eq(login_params[:email])
      end
    end
    context 'when login params is invalid' do
      before { post user_session_path }
      it 'returns unathorized status 401' do
        expect(response.status).to eq 401
      end
    end
  end
  describe 'DELETE /auth/sign_out/' do
    before do
      post user_session_path, params: login_params, as: :json
      headers = {
        'uid': response.headers['uid'],
        'client': response.headers['client'],
        'access-token': response.headers['access-token']
      }
      delete destroy_user_session_path, headers: headers
    end

    it { expect(response).to have_http_status(200) }
    it 'returns status success' do
      expect(response.body).to match(/success/)
    end
  end
end
