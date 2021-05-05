require 'rails_helper'

RSpec.describe 'Registration', type: :request do
  let(:signup_params) do
    {
      email: 'user@example.com',
      password: '12345678',
      password_confirmation: '12345678'
    }
  end

  subject(:signup) do
    post user_registration_path, params: signup_params
    response
  end

  describe 'User registration' do
    describe 'POST /auth/' do
      context 'signup with valid params' do
        it { expect(signup).to have_http_status(200) }

        it 'returns the token auth headers' do
          expect(signup.headers).to(
            include('token-type', 'access-token', 'client', 'expiry', 'uid')
          )
        end

        it { expect(json['status']).to eq('success') }

        it 'returns user email' do
          expect(json['data']['email']).to eq(signup_params[:email])
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
          expect(json['status']).to eq 'error'
        end

        it { expect(json['success']).to eq(false) }

        it 'returns a error message' do
          expect(json['errors'].join).to eq 'Please submit proper sign up data in request body.'
        end
      end
    end
  end
end
