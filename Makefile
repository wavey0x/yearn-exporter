flags := --remove-orphans --detach
ifdef FLAGS
	flags += $(FLAGS)
endif

dashboards_command := docker-compose --file services/dashboard/docker-compose.yml --file services/dashboard/docker-compose.local.yml --project-directory .
tvl_command := docker-compose --file services/tvl/docker-compose.yml --project-directory .
test_command := docker-compose --file services/dashboard/docker-compose.test.yml --project-directory .
all_command := docker-compose --file services/dashboard/docker-compose.yml --project-directory .

dashboards-up:
	$(dashboards_command) up $(flags)

dashboards-down:
	$(dashboards_command) down

dashboards-build:
	$(dashboards_command) build $(BUILD_FLAGS)

dashboards-clean-volumes:
	$(dashboards_command) down -v

dashboards-clean-cache:
	docker volume rm yearn-exporter_cache

tvl-up:
	$(tvl_command) up $(flags)

tvl-down:
	$(tvl_command) down

tvl-build:
	$(tvl_command) build $(BUILD_FLAGS)

tvl-clean-volumes:
	$(tvl_command) down -v

clean-volumes: dashboards-clean-volumes tvl-clean-volumes

dashboards: dashboards-up
tvl: tvl-up

up: dashboards-up
build: dashboards-build
down: dashboards-down

clean-cache: dashboards-clean-cache
clean-volumes: dashboards-clean-volumes

rebuild: down build up
scratch: clean-volumes build up

logs:
	$(dashboards_command) logs -f -t eth-exporter historical-eth-exporter ftm-exporter historical-ftm-exporter treasury-exporter historical-treasury-exporter ftm-treasury-exporter historical-ftm-treasury-exporter sms-exporter historical-sms-exporter ftm-sms-exporter historical-ftm-sms-exporter transactions-exporter ftm-transactions-exporter

test:
	$(test_command) up

all:
	$(all_command) down && $(all_command) build --no-cache && $(all_command) up $(flags)

logs-all:
	$(dashboards_command) logs -f -t eth-exporter historical-eth-exporter ftm-exporter historical-ftm-exporter treasury-exporter historical-treasury-exporter ftm-treasury-exporter historical-ftm-treasury-exporter sms-exporter historical-sms-exporter ftm-sms-exporter historical-ftm-sms-exporter transactions-exporter wallet-exporter ftm-transactions-exporter ftm-wallet-exporter

postgres:
	$(dashboards_command) up -d --build postgres

# Mainnet:
mainnet:
	$(all_command) up -d --build eth-exporter historical-eth-exporter treasury-exporter historical-treasury-exporter sms-exporter historical-sms-exporter transactions-exporter wallet-exporter

logs-mainnet:
	$(all_command) logs -ft eth-exporter historical-eth-exporter treasury-exporter historical-treasury-exporter sms-exporter historical-sms-exporter transactions-exporter wallet-exporter

eth:
	make mainnet

logs-eth:
	make logs-mainnet

# Fantom:
fantom:
	$(all_command) up -d --build ftm-exporter historical-ftm-exporter ftm-treasury-exporter historical-ftm-treasury-exporter ftm-sms-exporter historical-ftm-sms-exporter ftm-transactions-exporter ftm-wallet-exporter

logs-fantom:
	$(all_command) logs -ft ftm-exporter historical-ftm-exporter ftm-treasury-exporter historical-ftm-treasury-exporter ftm-sms-exporter historical-ftm-sms-exporter ftm-transactions-exporter ftm-wallet-exporter
	

# Gnosis chain:
gnosis:
	$(all_command) up -d --build gnosis-exporter historical-gnosis-exporter gnosis-treasury-exporter historical-gnosis-treasury-exporter gnosis-sms-exporter historical-gnosis-sms-exporter gnosis-transactions-exporter gnosis-wallet-exporter

logs-gnosis:
	$(all_command) logs -ft gnosis-exporter historical-gnosis-exporter gnosis-treasury-exporter historical-gnosis-treasury-exporter gnosis-sms-exporter historical-gnosis-sms-exporter gnosis-transactions-exporter gnosis-wallet-exporter
