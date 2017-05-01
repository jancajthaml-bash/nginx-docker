NAME = jancajthaml/nginx
VERSION = latest

.PHONY: all image tag upload publish

all: image

image:
	docker build -t $(NAME):stage .
	docker run -it $(NAME):stage cat /dev/null
	docker export $$(docker ps -a | awk '$$2=="$(NAME):stage" { print $$1 }'| head -1) | docker import - $(NAME):stripped
	docker tag $(NAME):stripped $(NAME):$(VERSION)
	docker rmi -f $(NAME):stripped
	docker rmi -f $(NAME):stage

tag: image
	git checkout -B release/$(VERSION)
	git add --all
	git commit -a --allow-empty-message -m '' 2> /dev/null || :
	git rebase --no-ff --autosquash release/$(VERSION)
	git pull origin release/$(VERSION) 2> /dev/null || :
	git push origin release/$(VERSION)
	git checkout -B master

run:
	pushd example; sh self_signed_certificate.sh; popd
	make image
	docker run --rm -it --log-driver none \
		-p 8080:8080 \
		-p 443:443 \
		-v $$(pwd)/example/nginx.crt:/etc/nginx/ssl/nginx.crt \
		-v $$(pwd)/example/nginx.key:/etc/nginx/ssl/nginx.key \
		-v $$(pwd)/example/dhparam.pem:/etc/nginx/ssl/dhparam.pem \
		-v $$(pwd)/example/nginx.conf:/etc/nginx/nginx.conf \
		-v $$(pwd)/example/index.html:/var/www/index.html \
		$(NAME):$(VERSION) nginx

upload:
	docker login -u jancajthaml https://index.docker.io/v1/
	docker push $(NAME)

publish: image tag upload
