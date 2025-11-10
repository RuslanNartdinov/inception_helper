name = inception
compose = name=$(name) docker-compose -f ./srcs/docker-compose.yml

all:
	@printf "Launch configuration ${name}...\n"
	@$(compose) up --build -d

build:
	@printf "Building configuration ${name}...\n"
	@$(compose) build

up:
	@printf "Run configuration ${name}...\n"
	@$(compose) up -d

stop:
	@printf "Stopping configuration ${name}...\n"
	@$(compose) stop

clean:
	@printf "Cleaning configuration ${name}...\n"
	@$(compose) down

re: clean
	@printf "Rebuild configuration ${name}...\n"
	@$(MAKE) all

fclean:
	@printf "Total clean of all configurations docker\n"
	@$(compose) down -v
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@sudo rm -rf $(HOME)/data/wordpress/*
	@sudo rm -rf $(HOME)/data/mariadb/*

.PHONY	: all build up stop re clean fclean
