FROM node:latest AS builder

WORKDIR /app
COPY ./react-app .
RUN npm install && npm run build

FROM nginx:latest

# Delete the original configuration file and create a static resource folder and a folder for saving ssl certificates
RUN rm /etc/nginx/conf.d/default.conf \
&& mkdir -p /usr/share/nginx/html/static \
&& mkdir -p /usr/share/nginx/html/media \
&& mkdir -p /usr/share/nginx/ssl

COPY --from=builder /app/build /usr/share/nginx/build

# Set the Media folder user and user group to the Linux default www-data, and give read and execute permissions,
# Otherwise the images uploaded by the user will not be displayed correctly.

RUN chown -R www-data:www-data /usr/share/nginx/html/media \
&& chmod -R 775 /usr/share/nginx/html/media

# add configuration file
ADD ./nginx.conf /etc/nginx/conf.d/

# Turn off nginx daemon
CMD ["nginx", "-g", "daemon off;"]