# Docker Gitlab CI PHP image
Gitlab CI PHP docker base image for Symfony applications.

### Usage

```
docker pull rednose/php
```

### Building and publishing the image

```
docker build -t rednose/php:5.6 .
docker tag rednose/php:5.6 rednose/php:latest
docker push rednose/php
```

### Starting bash

```
docker run -it rednose/php /bin/bash
```
