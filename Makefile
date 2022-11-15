setup-test:
	brew install postgres && createdb shim_test

test:
	bin/rails db:migrate RAILS_ENV=test && RAILS_ENV=test bin/rspec spec/services/assignments_service/scheduler_spec.rb --fail-fast
