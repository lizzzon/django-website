migrations:
	docker-compose  run --rm --entrypoint "./manage.py makemigrations" app

migrate:
	docker-compose  run --rm --entrypoint "./manage.py migrate --no-input" app

static:
	docker-compose  run --rm --entrypoint "./manage.py collectstatic --no-input" app

remove-images:
	docker stop website_redis && docker rm website_redis || echo "Deleted redis"
	docker stop website_celery && docker rm website_celery || echo "Deleted celery"
	docker stop website_postres && docker rm website_postres || echo "Deleted postres"
	docker stop website_app && docker rm website_app && docker rmi website -f || echo "Deleted website"
	docker stop website_nginx && docker rm website_nginx || echo "Deleted nginx"
	docker rmi website -f || echo "Deleted website image"
	docker rmi website_celery_image -f || echo "Deleted celery image"
	docker rmi website_nginx_image -f || echo "Deleted nginx image"

build:
	make remove-images
	docker-compose -f docker-compose.yaml up --build -d

start:
	make build
	make migrations
	make migrate
	make static

down:
	docker-compose down --remove-orphans

test:
	docker-compose run --rm --entrypoint "./manage.py test" app

test-coverage:
	docker-compose run --rm --entrypoint "coverage run manage.py test" app
	docker-compose run --rm app coverage report

isort:
	docker-compose run --rm app isort /app

black:
	docker-compose run --rm app black /app

mypy:
	docker-compose run --rm app mypy /app

pylint:
	docker-compose run --rm app pylint apps website

prepare-commit:
	make isort
	make black
	make pylint
	make mypy

shell:
	docker exec -it website_app bash

logs:
	docker-compose logs -f --tail 100

logs-app:
	docker-compose logs -f --tail 100 app

build-prod:
	make remove-images
	docker-compose -f docker-compose.prod.yaml up --build -d

start-prod:
	make build-prod

containers:
	docker ps -a

images:
	docker images

reload:
	docker-compose stop
	docker-compose up -d