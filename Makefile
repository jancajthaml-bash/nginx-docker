NAME = jancajthaml/nginx
VERSION = latest

.PHONY: all image tag upload publish

all: image

image:
	docker build -t $(NAME):$(VERSION) .

tag: image
	git checkout -B release/$(VERSION)
	git add --all
	git commit -a --allow-empty-message -m '' 2> /dev/null || true
	git rebase --no-ff --autosquash release/$(VERSION)
	git pull origin release/$(VERSION) 2> /dev/null || true
	git push origin release/$(VERSION)
	git checkout -B master

run:
	pushd opt; sh self_signed_certificate.sh; popd
	make image
	docker run --rm -it --log-driver none \
		-p 8080:8080 \
		-p 443:443 \
		-v $$(pwd)/opt/nginx.crt:/etc/nginx/ssl/nginx.crt \
		-v $$(pwd)/opt/nginx.key:/etc/nginx/ssl/nginx.key \
		-v $$(pwd)/opt/dhparam.pem:/etc/nginx/ssl/dhparam.pem \
		-v $$(pwd)/opt/nginx.conf:/etc/nginx/nginx.conf \
		$(NAME):$(VERSION) nginx

upload:
	docker login -u jancajthaml https://index.docker.io/v1/
	docker push $(NAME)

publish: image tag upload