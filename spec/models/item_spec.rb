# frozen_string_literal: true

# spec/models/item_spec.rb
require 'rails_helper'

# Test suite for the Item model
RSpec.describe Item, type: :model do
  # Association test
  # ensure an item record belongs to a single todo record
  it { is_expected.to belong_to(:todo) }
  # Validation test
  # ensure column name is present before saving
  it { is_expected.to validate_presence_of(:name) }
  # Database tests
  # ensure columns name, done and todo_id are present in database
  it { is_expected.to have_db_column(:name) }
  it { is_expected.to have_db_column(:done) }
  it { is_expected.to have_db_column(:todo_id) }
end
