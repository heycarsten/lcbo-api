# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Plan.create! \
  kind: Plan.kinds[:free],
  title: 'Free',
  has_cors: true,
  request_pool_size: 50_000,
  fee_in_cents: 0

Plan.create! \
  kind: Plan.kinds[:supporter],
  title: 'Supporter',
  has_cors: true,
  has_upc_lookup: true,
  request_pool_size: 100_000,
  fee_in_cents: 7000

Plan.create! \
  kind: Plan.kinds[:developer],
  stripe_uid: 'developer20',
  title: 'Developer',
  has_cors: true,
  has_ssl: true,
  has_upc_lookup: true,
  request_pool_size: 500_000,
  fee_in_cents: 2000

Plan.create! \
  kind: Plan.kinds[:developer],
  stripe_uid: 'developer40',
  title: 'Developer',
  has_cors: true,
  has_ssl: true,
  has_upc_lookup: true,
  request_pool_size: 1_100_000,
  fee_in_cents: 4000

Plan.create! \
  kind: Plan.kinds[:developer],
  stripe_uid: 'developer80',
  title: 'Developer',
  has_cors: true,
  has_ssl: true,
  has_upc_lookup: true,
  request_pool_size: 2_200_000,
  fee_in_cents: 8000

Plan.create! \
  kind: Plan.kinds[:developer],
  stripe_uid: 'pro160',
  title: 'Pro',
  has_cors: true,
  has_ssl: true,
  has_upc_lookup: true,
  request_pool_size: 4_400_000,
  fee_in_cents: 16_000

# Plan.create! \
#   kind: Plan.kinds[:developer],
#   stripe_uid: 'pro320',
#   title: 'Pro',
#   has_cors: true,
#   has_ssl: true,
#   has_upc_lookup: true,
#   request_pool_size: 8_000_000,
#   fee_in_cents: 32_000
#
# Plan.create! \
#   kind: Plan.kinds[:enterprise],
#   stripe_uid: 'enterprise2200',
#   title: 'Enterprise',
#   has_cors: true,
#   has_ssl: true,
#   has_upc_lookup: true,
#   has_upc_value: true,
#   has_webhooks: true,
#   has_history: true,
#   has_reports: true,
#   request_pool_size: 40_000_000,
#   fee_in_cents: 220_000
