test:
	@find t -type d -print0 | xargs -0 vendor/bats/bin/bats --pretty
