Compact Nginx container ( 11.5MB / 8MB compressed )

## Stack

Build from source of [Nginx](http://nginx.org/download) running on top of lightweight [Alphine Linux](https://alpinelinux.org).

## Usage

```
docker run --rm -it --log-driver none \
	-p 8080:8080 \
	-p 443:443 \
	-v $(pwd)/example/nginx.crt:/etc/nginx/ssl/nginx.crt \
	-v $(pwd)/example/nginx.key:/etc/nginx/ssl/nginx.key \
	-v $(pwd)/example/dhparam.pem:/etc/nginx/ssl/dhparam.pem \
	-v $(pwd)/example/nginx.conf:/etc/nginx/nginx.conf \
	jancajthaml/nginx:latest nginx
```