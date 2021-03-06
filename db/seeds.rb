# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Logger.new(STDOUT).info 'Start Organisations seed'
Organisation.import_addresses 'db/data.csv', 1006

Logger.new(STDOUT).info 'Start Users seed'
user = User.where(email: "superadmin@harrowcn.org.uk").first_or_initialize
user.password = "asdf1234"
user.password_confirmation = "asdf1234"
user.confirmed_at = DateTime.now
user.superadmin = true
user.save!

user = User.where(email: "admin@harrowcn.org.uk").first_or_initialize
user.password = "asdf1234"
user.password_confirmation = "asdf1234"
user.confirmed_at = DateTime.now
user.superadmin = true
user.save!

user = User.where(email: "siteadmin@harrowcn.org.uk").first_or_initialize
user.password = "asdf1234"
user.password_confirmation = "asdf1234"
user.confirmed_at = DateTime.now
user.siteadmin = true
user.save!

(1..120).each do |i|
  user = User.where(email: "user#{i}@example.com").first_or_initialize
  user.password = "asdf1234"
  user.password_confirmation = "asdf1234"
  user.confirmed_at = DateTime.now
  user.organisation_id = Organisation.all.sample.id
  user.save!
end

Logger.new(STDOUT).info 'Start VolunteerOps seed'
3.times do |n|
  VolunteerOp.create(description: "This is a test#{n}", title: "Test#{n}", organisation_id: "#{1 + n}")
end

Logger.new(STDOUT).info 'Start features seed'
Feature.create(name: 'volunteer_ops_create')
Feature.activate('volunteer_ops_create')
Feature.create(name: 'volunteer_ops_list')
Feature.activate('volunteer_ops_list')
Feature.create(name: 'automated_propose_org')
Feature.activate('automated_propose_org')
Feature.create(name: 'search_input_bar_on_org_pages')
Feature.activate('search_input_bar_on_org_pages')
Feature.create(name: 'doit_volunteer_opportunities')
Feature.activate('doit_volunteer_opportunities')
Feature.create(name: 'reachskills_volunteer_opportunities')
Feature.activate('reachskills_volunteer_opportunities')
Feature.create(name: 'events')
Feature.activate('events')

Logger.new(STDOUT).info 'Seed completed'
