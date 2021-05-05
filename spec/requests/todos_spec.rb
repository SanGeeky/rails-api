# frozen_string_literal: true

# spec/requests/todos_spec.rb
require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  # initialize test data
  let!(:todos) { create_list(:todo, 10) }
  let(:todo_id) { todos.first.id }

  # Create User
  let(:user) { create :user }
  let(:login_params) do
    {
      email: user.email,
      password: user.password
    }
  end

  # Login and generate Token
  let(:auth) do
    post user_session_path,
         params: login_params.to_json,
         headers: {
           CONTENT_TYPE: 'application/json',
           ACCEPT: 'application/json'
         }
    headers = {
      'access-token': response.headers['access-token'],
      'client': response.headers['client'],
      'uid': response.headers['uid'],
      'expiry': response.headers['expiry'],
      'token-type': response.headers['token-type']
    }
  end

  # Test suite for GET /todos
  describe 'GET /todos' do
    # make HTTP get request before each example
    before { get '/todos', headers: auth }

    it 'returns todos' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /todos/:id
  describe 'GET /todos/:id' do
    before { get "/todos/#{todo_id}", headers: auth }

    context 'todo record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'todo record does not exist' do
      let(:todo_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  # Test suite for POST /todos
  describe 'POST /todos' do
    # valid payload
    let(:valid_attributes) { { title: 'Learn Ruby', created_by: '1' } }

    context 'todo params are invalid' do
      before { post '/todos', params: valid_attributes, headers: auth }

      it 'creates a todo' do
        expect(json['title']).to eq('Learn Ruby')
        expect(json['created_by']).to eq('1')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'todo params are invalid' do
      before { post '/todos', params: { title: 'Foobar' }, headers: auth }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Created by can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /todos/:id' do
    let(:valid_attributes) { { title: 'Shopping' } }

    context 'todo record exists' do
      before { put "/todos/#{todo_id}", params: valid_attributes, headers: auth }

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
      it 'updates the record' do
        expect(response.body).to be_empty
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /todos/:id' do
    before { delete "/todos/#{todo_id}", headers: auth }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
    it 'deletes the record' do
      expect(response.body).to be_empty
    end
  end
end
