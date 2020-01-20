.DEFAULT_GOAL := help

.PHONY: help
help: ## Show help message for Makefile target
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build documentations with mkdocs
	@docker build -t mkdocs .

.PHONY: view
view: build ## Live viewing with mkdocs
	@docker run --rm -it -p 3000:3000 -v ${PWD}:/docs mkdocs

.PHONY: deploy
deploy: build ## Deploy generated documentations to gh-pages
	@docker run --rm -it -v ${PWD}:/docs -v ~/.ssh:/root/.ssh mkdocs mkdocs gh-deploy
