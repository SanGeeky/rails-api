require 'rails_helper'

RSpec.describe 'Registration', type: :request do
  let(:signup_params) do
    {
      email: 'user@example.com',
      password: '12345678',
      password_confirmation: '12345678'
    }
  end
  let(:signup) do
    post user_registration_path, params: signup_params
    response
  end

  describe 'User registration' do
    describe 'POST /auth/' do
      context 'signup with valid params' do
        it { expect(signup).to have_http_status(200) }
        it 'returns authentication header with right attributes' do
          expect(signup.headers['access-token']).to be_present
        end
        it 'returns client in authentication header' do
          expect(signup.headers['client']).to be_present
        end
        it 'returns expiry in authentication header' do
          expect(signup.headers['expiry']).to be_present
        end
        it 'returns uid in authentication header' do
          expect(signup.headers['uid']).to be_present
        end
        it 'returns status success' do
          expect(signup.body).to match(/success/)
        end
        it 'returns user email' do
          parsed_response = JSON.parse(signup.body)
          expect(parsed_response['data']['email']).to eq(signup_params[:email])
        end
        it 'creates new user' do
          expect do
            post user_registration_path,
                 params: signup_params.merge({ email: 'test@example.com' })
          end.to change(User, :count).by(1)
        end
      end

      context 'signup with not valid params' do
        before { post user_registration_path }

        it { expect(response).to have_http_status(422) }
        it 'returns status error' do
          expect(response.body).to match(/error/)
        end
        it 'returns a error message' do
          expect(response.body).to match(/Please submit proper sign up data in request body./)
        end
      end
    end
  end
end
