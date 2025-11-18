# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mpietrza <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/11/06 15:17:09 by mpietrza          #+#    #+#              #
#    Updated: 2025/11/06 16:09:36 by mpietrza         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DOMAIN_NAME		:= mpietrza.42.fr
COMPOSE			:= docker compose
COMPOSE_FILE	:= srcs/docker-compose.yml
DATA_PATH		:= /home/mpietrza/data

all: up

check-hosts:
	@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		echo "WARNING: $(DOMAIN_NAME) not found in /etc/hosts"; \
		echo "Run: sudo echo '127.0.0.1 $(DOMAIN_NAME) ' >> /etc/hosts"; \
		exit 1; \
	fi

# builds all the images and starts containers----------------------------------
up: check-hosts
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
# 		-p - parents (creates parent directories if needed) 
	@$(COMPOSE) -f $(COMPOSE_FILE) up -d --build
# 		--file (-f) makes docker read the file and not use the default version
# 		--detach (-d) - opens in background 
# 		--build - always builds the image even if it exists

#  force rebuilds without cache------------------------------------------------
rebuild:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	@$(COMPOSE) -f $(COMPOSE_FILE) build --no-cache
	@$(COMPOSE) -f $(COMPOSE_FILE) up -d

# stops and removes all services and networks----------------------------------
down:
	@$(COMPOSE) --file $(COMPOSE_FILE) down --remove-orphans
#		--remove-orphans removes orphan containers no longer defined in docker-compose.yml

# starts all the containers----------------------------------------------------
start:
	@$(COMPOSE) --file $(COMPOSE_FILE) start

# stops all the containers-----------------------------------------------------
stop:
	@$(COMPOSE) --file $(COMPOSE_FILE) stop

# shows the combined logs from all containers----------------------------------
logs:
	@$(COMPOSE) --file $(COMPOSE_FILE) logs -f
# 		--follow (-f) prints logs "live" (immediately) in the terminal

# list all the containers in a table with the configuration info
ps:
	@$(COMPOSE) --file $(COMPOSE_FILE) ps

# stop and remove all containers and unused Docker resources on the system-----
clean: down
	
	@docker system prune -af --volumes
# 		--all (-a) tells Docker to remove all images, not only dangling (detached) ones
# 		--force (-f) skips the confirmation prompt
# 		--volumes tells Docker to remove all unused volumes

# clean + removing all the data------------------------------------------------
fclean: clean
	sudo rm -rf $(DATA_PATH)

# regenerate and restart all---------------------------------------------------
re: fclean all

.PHONY: all check-hosts up rebuild down start stop logs ps clean fclean re

