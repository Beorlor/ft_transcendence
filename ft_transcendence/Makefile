up:
	docker-compose up --build

down:
	docker-compose down

restart:
	docker-compose down && docker-compose up --build

up_user_management:
	docker-compose up --build ruby_user_management postgres adminer smtp4dev

up_test:
	@echo "Generating certificates with mkcert..."
	./nginx/generate_cert.sh  # Run the cert generation script
	@echo "Starting Docker containers..."
	docker-compose up --build
