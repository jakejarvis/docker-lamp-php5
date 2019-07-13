# ![Docker-LAMP][logo]
Docker-LAMP-PHP5 is a Docker image that includes the Phusion base along with a LAMP stack ([Apache 2.4.7][apache], [MySQL 5.7][mysql] and [PHP 5.6][php]) on Ubuntu 16.04 Xenial, all in one handy container. [phpMyAdmin][phpmyadmin] is also bundled.

**This image is only intended for legacy PHP 5.6 applications, which is [end-of-life](https://www.php.net/supported-versions.php) as of January 2019. Use at your own risk, preferably *not* in production and/or public-facing environments!**

Based off an old version of [mattrayner/docker-lamp](https://github.com/mattrayner/docker-lamp).


[![Docker Hub][shield-docker-hub]][info-docker-hub]
[![License][shield-license]][info-license]


## Usage

### Directory structure

```
/ (project root)
/app/ (your PHP files aka the web root)
/mysql/ (Docker will create this and store your MySQL data here)
```

### Starting from command line

```
docker run -p "80:80" -v ${PWD}/app:/app -v ${PWD}/mysql:/var/lib/mysql jakejarvis/lamp-php5:latest
```

### Starting with Docker Compose

```
version: "3"
services:
  lamp:
    image: jakejarvis/lamp-php5:latest
    ports:
      - "80:80"
    volumes:
      - "./app:/app"
      - "./mysql:/var/lib/mysql"
```

### Starting from a Dockerfile

```
FROM jakejarvis/lamp-php5:latest

# Your custom commands

CMD ["/run.sh"]
```

### MySQL Databases

When you first run the image, you'll see a message showing your `admin` user's password. This is the user you should use in your application. If you need this login later, you can run `docker logs CONTAINER_ID` and you should see it at the top of the log.

You can access [phpMyAdmin][phpmyadmin] at `/phpmyadmin` with the `admin` username and password.

By default, the image comes with a `root` MySQL account that has no password. This account is only available locally, i.e. within your application. It is not available from outside your Docker image or through phpMyAdmin.


## License
Docker-LAMP is licensed under the [Apache 2.0 License][info-license].


[logo]: https://cdn.rawgit.com/mattrayner/docker-lamp/831976c022782e592b7e2758464b2a9efe3da042/docs/logo.svg

[apache]: http://www.apache.org/
[mysql]: https://www.mysql.com/
[php]: http://php.net/
[phpmyadmin]: https://www.phpmyadmin.net/

[info-docker-hub]: https://hub.docker.com/r/jakejarvis/lamp-php5
[info-license]: LICENSE.md

[shield-docker-hub]: https://img.shields.io/docker/build/jakejarvis/lamp-php5.svg
[shield-license]: https://img.shields.io/badge/license-Apache%202.0-blue.svg
