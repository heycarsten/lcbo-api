require 'spec_helper'

describe User do
  it 'needs a password' do
    u = User.create(name: 'Carsten', email: 'hi@example.com')
    expect(u.errors.email).to_not be_zero
  end
end
