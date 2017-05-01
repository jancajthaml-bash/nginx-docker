[ -f nginx.key ] || {
	openssl req -x509 -nodes \
		-days 365 \
		-newkey rsa:2048 \
		-keyout nginx.key \
		-out nginx.crt \
		-subj "/C=CZ/ST=Czech Republic/L=Prague/O=HTTP2 Demo/OU=Docker Nginx/CN=localhost"
}
[ -f dhparam.pem ] || {
	openssl dhparam -out ./dhparam.pem 2048
}
