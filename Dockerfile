FROM nginx
LABEL name = nginx-version-test
EXPOSE 80
ADD index.html /usr/share/nginx/html/index.html

