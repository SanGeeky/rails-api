# frozen_string_literal: true

# spec/support/request_spec_helper
module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    !response.nil? ? JSON.parse(response.body) : JSON.parse(subject.body)
  end
end
