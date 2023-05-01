.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")

DOCKER_USER ?= username
APP_NAME ?= app
GIT_HASH ?= $(shell git log --format="%h" -n 1)

help:                  ## Show the help.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep


docker-build:          ## Build docker
	@docker build --tag ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} .

docker-run:            ## Run docker
	@docker run ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} 

docker-push:           ## Push docker
    @docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}

docker-release:        ## Release docker
	@docker pull ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH}
	@docker tag  ${DOCKER_USERNAME}/${APPLICATION_NAME}:${GIT_HASH} ${DOCKER_USERNAME}/${APPLICATION_NAME}:latest
	@docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:latest

create-venv:           ## Create python venv
	@echo "creating virtualenv ..."
	@rm -rf .venv
	@python3 -m venv .venv
	@./.venv/bin/pip install -U pip
	@./.venv/bin/pip install -r requirements.txt
	@./.venv/bin/pip install -r requirements-test.txt
	@echo
	@echo "Run 'source .venv/bin/activate' to enable this environment"

fmt:              ## Format code using black & isort.
	$(ENV_PREFIX)isort app/
	$(ENV_PREFIX)black -l 79 app/
	$(ENV_PREFIX)black -l 79 tests/

lint:             ## Run pep8, black, mypy linters.
	$(ENV_PREFIX)flake8 app/
	$(ENV_PREFIX)black -l 79 --check app/
	$(ENV_PREFIX)black -l 79 --check tests/
	$(ENV_PREFIX)mypy --ignore-missing-imports app/

test:             ## Run tests and generate coverage report.
	$(ENV_PREFIX)pytest -v --cov-config .coveragerc --cov=project_name -l --tb=short --maxfail=1 tests/
	$(ENV_PREFIX)coverage xml
	$(ENV_PREFIX)coverage html

clean:            ## Clean unused files.
	@find ./ -name '*.pyc' -exec rm -f {} \;
	@find ./ -name '__pycache__' -exec rm -rf {} \;
	@find ./ -name 'Thumbs.db' -exec rm -f {} \;
	@find ./ -name '*~' -exec rm -f {} \;
	@rm -rf .cache
	@rm -rf .pytest_cache
	@rm -rf .mypy_cache
	@rm -rf build
	@rm -rf dist
	@rm -rf *.egg-info
	@rm -rf htmlcov
	@rm -rf .tox/
	@rm -rf docs/_build

release:          ## Create a new tag for release.
	@echo "WARNING: This operation will create semantic version tag and push to github"
	@read -p "Version? (provide the next x.y.z) : " TAG \
	&& echo "creating git tag : $${TAG}" \
	&& git tag $${TAG} \
	&& echo "$${TAG}" > app/VERSION \
	&& $(ENV_PREFIX)gitchangelog > HISTORY.md \
	&& git add app/VERSION HISTORY.md \
	&& git commit -m "release: version $${TAG} 🚀" \
	&& git push -u origin HEAD --tags \
	&& echo "Github Actions will detect the new tag and release the new version."

docs:             ## Build the documentation.
	@echo "building documentation ..."
	@$(ENV_PREFIX)mkdocs build
	URL="site/index.html"; xdg-open $$URL || sensible-browser $$URL || x-www-browser $$URL || gnome-open $$URL  || open $$URL