WEB_DB_NAME = odoo_development
DOCKER = docker
DOCKER_COMPOSE = ${DOCKER} compose
CONTAINER_ODOO = odoo
CONTAINER_DB = odoo-postgres

help:
	@echo "Available targets"
	@echo " start			   			- Start the Odoo and PostgreSQL containers"
	@echo " stop			   			- Stop the Odoo and PostgreSQL containers"
	@echo " restart	   		   			- Restart the Odoo and PostgreSQL containers	"
	@echo " console	   		   			- Open an Odoo shell in the Odoo container"
	@echo " psql			   			- Open a PostgreSQL shell in the PostgreSQL container"
	@echo " logs odoo	   	   			- Follow the Odoo container logs"
	@echo " logs db			   			- Follow the PostgreSQL container logs"
	@echo " addon <addons_name> 		- Restart instance and upgrade addon"

start:
	$(DOCKER_COMPOSE) up -d
stop:
	$(DOCKER_COMPOSE) down
restart:
	$(DOCKER_COMPOSE) restart
console:
	$(DOCKER) exec -it $(CONTAINER_ODOO) odoo shell --db_host=$(CONTAINER_DB) -d $(WEB_DB_NAME) -r $(CONTAINER_ODOO) -w $(CONTAINER_ODOO)
psql:
	$(DOCKER) exec -it $(CONTAINER_DB) psql -U $(CONTAINER_ODOO) -d $(WEB_DB_NAME)

define log_target
	@if [ "$(1)" = "odoo" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_ODOO); \
	elif [ "$(1)" = "db" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_DB); \
	else \
		echo "Invalid logs target. Use 'make logs odoo' or 'make logs db'."; \
	fi
endef

logs:
	$(call log_target,$(word 2,$(MAKECMDGOALS)))

define upgrade_addon
	$(DOCKER) exec -it $(CONTAINER_ODOO) odoo --db_host=$(CONTAINER_DB) -d $(WEB_DB_NAME) -r $(CONTAINER_ODOO) -w $(CONTAINER_ODOO) -u $(1) --dev xml
endef

addon: restart
	$(call upgrade_addon,$(word 2,$(MAKECMDGOALS)))

.PHONY: start stop restart console psql logs odoo db addon