# Makefile for managing data collection and processing

DATA_COLLECTION_SCRIPT = data_collection.sh
PROCESS_SCRIPT = process.sh

all:
	@echo "Starting data collection and processing..."
	@$(MAKE) run_data_collection
	@$(MAKE) run_process_data

run_data_collection:
	@bash $(DATA_COLLECTION_SCRIPT) >/dev/null 2>&1 &

run_process_data:
	@bash $(PROCESS_SCRIPT)
