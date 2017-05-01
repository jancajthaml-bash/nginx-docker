Compact Nginx container ( 20.3MB / 8MB compressed )

## Stack

Build from source of [Nginx](http://nginx.org/download) running on top of lightweight [Alphine Linux](https://alpinelinux.org).

## Usage

```
docker run --rm -it --log-driver none \
	-p 8080:8080 \
	-p 443:443 \
	-v $(pwd)/opt/nginx.crt:/etc/nginx/ssl/nginx.crt \
	-v $(pwd)/opt/nginx.key:/etc/nginx/ssl/nginx.key \
	-v $(pwd)/opt/dhparam.pem:/etc/nginx/ssl/dhparam.pem \
	-v $(pwd)/opt/nginx.conf:/etc/nginx/nginx.conf \
	jancajthaml/nginx:latest nginx
```