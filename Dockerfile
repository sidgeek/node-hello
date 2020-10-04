FROM node:14.0 as intermediate
# ARG REV_NO

# Add user 'sid'
RUN useradd -ms /bin/bash sid

# Create app directory
WORKDIR /src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
ADD package.json yarn.lock ./

RUN yarn
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source
COPY . .

# Generate DEV dist
# RUN REACT_APP_MONITOR_API_SERVER="http://monitor.warriortrading.com" npm run build
# RUN echo $REV_NO > /src/app/build-dev/static/version.txt


CMD ["npm", "start"]

EXPOSE 8888


