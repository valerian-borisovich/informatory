.ONESHELL:
SHELL := /usr/bin/bash
#.DEFAULT_GOAL = help
.DEFAULT_GOAL = build
# ###
# #####################################################################################################################
# ###    Full path of the current script
THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0);
# ### The directory where current script resides
DIR=$(dirname "${THIS}")
# ###
PWD=$(pwd)
# ###
#
#PLUGIN_DIR:=/pub/==vaults==/vera/.obsidian/plugins/obsidian-veracrypt
#

# all: hooks install build init serve
# default: init

default:
	@$(MAKE) -s start
	#@$(MAKE) -s help

# ###
h: ###   Commands list
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ###   This will output the help for each task. thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ### Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ###
#.PHONY: hooks
#hooks:
#	cd .git/hooks && ln -s -f ../../hooks/pre-push pre-push

# ###
#"start": "npm-run-all get-theme build:sass --parallel watch:*",
#"watch:sass": "sass --watch src/site/styles:dist/styles",
#"watch:eleventy": "cross-env ELEVENTY_ENV=dev eleventy --serve",
#"build:eleventy": "cross-env ELEVENTY_ENV=prod NODE_OPTIONS=--max-old-space-size=4096 eleventy",
#"build:sass": "sass src/site/styles:dist/styles --style compressed",
#"get-theme": "node src/site/get-theme.js",
#"build": "npm-run-all get-theme build:*"
# ###
#"setup": "npm install --legacy-peer-deps && npm audit fix --force",
#"clear": "rm -rf ./dist",
#"lint:fix": "eslint --ext .ts,.js,.json src/ --fix",
#"prebuild": "npm run bump",
#"bump": "node ./.github/scripts/commit-and-tag-version.js",
#"build:prod": "obsidian-plugin build --with-stylesheet src/styles.css src/main.ts",
#"build:dev": "obsidian-plugin dev --with-stylesheet src/styles.css src/main.ts --vault-path /pub/==vaults==/vera",
#"dev": "npm run bump && npm run build:dev"


# ###
i init:
	echo -e "init"
	# bash jq -r '.name' ./package.json
	# RELEASE_NAME="$(jq -r '.name' ./package.json)"
	# echo "Release: ${RELEASE_NAME}"

# ###
setup: ### Setup
	@$(MAKE) -s clean
	#@$(shell) npm whoami
	#@$(shell) npm adduser
	@$(shell) npm i --save-dev
	#@$(shell) npm install --legacy-peer-deps
	@$(shell) npm audit fix --force
	@$(MAKE) -s build

# ###
t test:
	@$(shell) echo -e "Testim . . . "
	#	@$(shell) yes | cp -rf "./scripts/vera.sh" "$(PLUGIN_DIR)/vera.sh"
	#	@$(shell) chmod +x "$(PLUGIN_DIR)/vera.sh"

# ###
#i install:
	#@if [ ! -d "$(PLUGIN_DIR)" ]; then @$(shell) mkdir -p "$(PLUGIN_DIR)" ; fi
	#@$(shell) yes | cp -rf "./scripts/vera.sh" "$(PLUGIN_DIR)/vera.sh"
	#@$(shell) chmod +x "$(PLUGIN_DIR)/vera.sh"

# ###
b build:
	@$(MAKE) -s clean
	@$(MAKE) -s setup
	@$(shell) npm run build:all
        @$(shell) npm version --workspaces patch

# ###
bc build-container: ### Build docker compose file in this directory
	@if [ ! -f "compose.yml" ]; then COMPOSE_FILE="docker-compose.yml"; fi
#	@if [ ! -d $(APP_BASE_DIR) ]; then @mkdir $(APP_BASE_DIR); fi
	DOCKER_BUILDKIT=1 docker-compose -f $(COMPOSE_FILE) up -d --build $(c)
#	docker-compose -f $(COMPOSE_FILE) build $(c)

# ###
clean: ####
	@$(MAKE) -s clean-js

# ###
clean-js:
	rm -rf `find . -name node_modules`
	rm -rf `find . -name dist`
	rm -rf `find . -name build`
	rm -f `find . -type f -name package-lock.json`
#	rm -f `find . -type f -name '*~' `
#	rm -f `find . -type f -name '.*~' `

# ###
net: ### sudo netstat -ntlp ; sudo ss -tulpn | grep :9000
	netstat -ntlp
	ss -tulpn | grep :9000

# ###
d dev:
	npm run build:dev

# ###
r run: ### run
	npm run start:bot
	echo -e "Access the graph You can reach the gateway under http://localhost:3001/graphql"

