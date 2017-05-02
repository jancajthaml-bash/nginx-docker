FROM alpine:latest

MAINTAINER	Jan Cajthaml <jan.cajthaml@gmail.com>

ENV 		NGINX_VERSION=1.13.0 \
			PCRE_VERSION=8.39 \
			MORE_HEADERS_VERSION=v0.32

RUN 		CONFIG="\
				--prefix=/etc/nginx \
				--sbin-path=/usr/sbin/nginx \
				--modules-path=/usr/lib/nginx/modules \
				--conf-path=/etc/nginx/nginx.conf \
				--error-log-path=/var/log/nginx/error.log \
				--http-log-path=/var/log/nginx/access.log \
				--pid-path=/var/run/nginx.pid \
				--lock-path=/var/run/nginx.lock \
				--http-client-body-temp-path=/var/cache/nginx/client_temp \
				--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
				--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
				--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
				--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
				--with-pcre=/var/cache/nginx/pcre_temp \
				--user=nginx \
				--group=nginx \
				--with-http_ssl_module \
				--with-http_gunzip_module \
				--with-http_gzip_static_module \
				--with-http_secure_link_module \
				--with-http_auth_request_module \
				--with-http_image_filter_module=dynamic \
				--with-threads \
				--with-stream \
				--with-stream_ssl_module \
				--with-stream_ssl_preread_module \
				--with-stream_realip_module \
				--with-http_slice_module \
				--with-compat \
				--with-file-aio \
				--with-http_v2_module \
				--without-http_empty_gif_module \
				--add-module=/var/cache/nginx/more_headers_temp \
			" && \
			addgroup -S nginx && \
			adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
			apk add --no-cache --virtual .build-deps \
										  gcc \
										  g++ \
										  perl \
										  libc-dev \
										  make \
										  openssl-dev \
										  pcre-dev \
										  zlib-dev \
										  linux-headers \
										  curl \
										  gnupg \
										  gd-dev && \
			mkdir -p /usr/src/nginx-${NGINX_VERSION} && \
			curl -sSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | \
				tar xvz --no-same-owner -C /usr/src/nginx-${NGINX_VERSION} --strip-components 1 -f - && \
			mkdir -p /var/cache/nginx/pcre_temp && \
		    curl -sSL ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz | \
		    	tar xvz --no-same-owner -C /var/cache/nginx/pcre_temp --strip-components 1 -f - && \
		    mkdir -p /var/cache/nginx/more_headers_temp && \
		    curl -sSL https://github.com/openresty/headers-more-nginx-module/archive/${MORE_HEADERS_VERSION}.tar.gz | \
		    	tar xvz --no-same-owner -C /var/cache/nginx/more_headers_temp --strip-components 1 -f - && \
			cd /usr/src/nginx-${NGINX_VERSION} && \
			/usr/src/nginx-${NGINX_VERSION}/configure $CONFIG --with-debug && \
			make -j$(getconf _NPROCESSORS_ONLN) -C /usr/src/nginx-${NGINX_VERSION} && \
			mv /usr/src/nginx-${NGINX_VERSION}/objs/nginx /usr/src/nginx-${NGINX_VERSION}/objs/nginx-debug && \
			mv /usr/src/nginx-${NGINX_VERSION}/objs/ngx_http_image_filter_module.so /usr/src/nginx-${NGINX_VERSION}/objs/ngx_http_image_filter_module-debug.so && \
			/usr/src/nginx-${NGINX_VERSION}/configure $CONFIG && \
			make -j$(getconf _NPROCESSORS_ONLN) -C /usr/src/nginx-${NGINX_VERSION} install && \
			rm -rf /etc/nginx/html/ && \
			mkdir /etc/nginx/conf.d/ && \
			mkdir /etc/nginx/ssl/ && \
			mkdir -p /usr/share/nginx/html/ && \
			install -m755 objs/nginx-debug /usr/sbin/nginx-debug && \
			install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so && \
			ln -s ../../usr/lib/nginx/modules /etc/nginx/modules && \
			strip /usr/sbin/nginx* && \
			strip /usr/lib/nginx/modules/*.so && \
			rm -rf /usr/src/nginx-${NGINX_VERSION} && \
			apk add --no-cache --virtual .gettext gettext && \
			mv /usr/bin/envsubst /tmp/ && \
			runDeps="$( \
				scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
					| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
					| sort -u \
					| xargs -r apk info --installed \
					| sort -u \
			)" && \
			apk add --no-cache --virtual .nginx-rundeps $runDeps && \
			apk del .build-deps .gettext && \
			mv /tmp/envsubst /usr/local/bin/ && \
			ln -sf /dev/stdout /var/log/nginx/access.log && \
			ln -sf /dev/stderr /var/log/nginx/error.log

COPY 		opt/sysctl.conf /etc/sysctl.conf
COPY 		opt/limits.conf /etc/security/limits.conf

EXPOSE 		8080

STOPSIGNAL 	SIGQUIT

CMD 		["nginx"]
