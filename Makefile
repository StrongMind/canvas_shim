setup-test:
	brew install postgres && createdb shim_test

test:
	bin/rails db:migrate RAILS_ENV=test && rake app:spec
