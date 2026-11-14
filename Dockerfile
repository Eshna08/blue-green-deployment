FROM nginx:alpine
ARG SITE_FILE=index.html
COPY ${SITE_FILE} /usr/share/nginx/html/index.html
EXPOSE 80
