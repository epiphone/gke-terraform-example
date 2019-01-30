FROM node:10-alpine

ARG COMMIT_REF
ARG BUILD_DATE

RUN mkdir -p /code
WORKDIR /code
ADD . /code
RUN npm install -g -s --no-progress yarn && yarn install --prod

ENV APP_COMMIT_REF=${COMMIT_REF} \
    APP_BUILD_DATE=${BUILD_DATE}
CMD [ "yarn", "start" ]
EXPOSE 3000
