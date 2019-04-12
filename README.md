# Docker GitLab CI PHP image
GitLab CI PHP Docker base image for Symfony applications.

### Usage

```
docker pull rednose/php
```

### Building and publishing the image

```
docker build -t rednose/php:7.2 -t rednose/php:latest .
docker push rednose/php:7.2
docker push rednose/php:latest
```

### Starting bash

```
docker run -it rednose/php /bin/bash
```

### Clearing the cache and building the image from scratch

```
docker build --no-cache .
```
