PROJECT_NAME        := inception

DOCKER_COMPOSE_FILE := ./srcs/compose.yaml
ENV_FILE            := srcs/.env
COMPOSE_CMD         := docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE)

DATA_DIR            := $(HOME)/data
WORDPRESS_DATA_DIR  := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR    := $(DATA_DIR)/mariadb
PORTAINER_DATA_DIR  := $(DATA_DIR)/portainer


all: up

build: check_env create_dirs
	@printf "Building and launching $(PROJECT_NAME) project...\n"
	@$(COMPOSE_CMD) up -d --build

up: check_env create_dirs
	@printf "Launching $(PROJECT_NAME) project...\n"
	@$(COMPOSE_CMD) up -d

down:
	@printf "Stopping $(PROJECT_NAME) project...\n"
	@$(COMPOSE_CMD) down -v

re: down build

clean: down
	@printf "Cleaning $(PROJECT_NAME) project...\n"
	@printf "Pruning dangling Docker resources...\n"
	@docker system prune --force
	@printf "Removing data from host volumes...\n"
	@if [ -d "$(WORDPRESS_DATA_DIR)" ]; then sudo rm -rf $(WORDPRESS_DATA_DIR)/*; fi
	@if [ -d "$(MARIADB_DATA_DIR)" ]; then sudo rm -rf $(MARIADB_DATA_DIR)/*; fi
	@if [ -d "$(PORTAINER_DATA_DIR)" ]; then sudo rm -rf $(PORTAINER_DATA_DIR)/*; fi

fclean: clean
	@printf "Performing total clean for $(PROJECT_NAME)...\n"
	@printf "Pruning all unused Docker images, networks, and volumes...\n"
	@docker system prune --all --force --volumes
	@printf "Total clean complete.\n"

logs:
	@$(COMPOSE_CMD) logs -f

create_dirs:
	@printf "Creating data directories if they don't exist...\n"
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@mkdir -p $(MARIADB_DATA_DIR)
	@mkdir -p $(PORTAINER_DATA_DIR)

check_env:
	@if [ ! -f "$(ENV_FILE)" ]; then \
		printf "\033[33mWarning: Environment file $(ENV_FILE) not found. Creating a default one.\033[0m\n"; \
		printf "Please review $(ENV_FILE) and adjust values if necessary.\n"; \
		printf "DOMAIN_NAME=pehenri2.42.fr\n\
MYSQL_USER=user\n\
MYSQL_PASSWORD=1234\n\
MYSQL_DATABASE=mariadb\n\
MYSQL_ROOT_PASSWORD=1234\n\n\
WORDPRESS_TITLE=Inception\n\
WORDPRESS_ADMIN_USER=owner\n\
WORDPRESS_ADMIN_PASSWORD=1234\n\
WORDPRESS_ADMIN_EMAIL=pehenri2@student.42sp.org.br\n\
WORDPRESS_USER=user\n\
WORDPRESS_PASSWORD=1234\n\
WORDPRESS_EMAIL=pehenri2@student.42sp.org.br\n\n"\
FTP_PASSWORD=1234\n > $(ENV_FILE); \
	fi

help:
	@printf "Usage: make [target]\n\n"
	@printf "Available targets:\n"
	@printf "  all         Builds images if they don't exist and starts all services.\n"
	@printf "  up          Starts all services (alias for 'all').\n"
	@printf "  build       Forces a rebuild of images and starts all services.\n"
	@printf "  down        Stops and removes all services, networks, and anonymous volumes.\n"
	@printf "  re          Rebuilds and restarts the application (down, build).\n"
	@printf "  clean       Stops services, prunes dangling Docker resources, and removes data from host volumes.\n"
	@printf "  fclean      Performs a more thorough cleanup: stops services, prunes all unused Docker resources (images, volumes, networks), and removes data from host volumes.\n"
	@printf "  logs        Follows the logs of all running services.\n"
	@printf "  create_dirs Creates necessary data directories on the host.\n"
	@printf "  check_env   Checks if the .env file exists.\n"
	@printf "  help        Shows this help message.\n"

.PHONY: all build up down re clean fclean logs create_dirs check_env help