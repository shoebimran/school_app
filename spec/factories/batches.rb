# frozen_string_literal: true

FactoryBot.define do
  factory :batch do
    max_count { '123' }
    name { 'test batch' }
  end
end
