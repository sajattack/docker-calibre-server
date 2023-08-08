# [Docker Calibre Server](https://hub.docker.com/r/rloomans/calibre-server)

![GitHub tag](https://img.shields.io/github/v/tag/rloomans/docker-calibre-server?logo=github&link=https%3A%2F%2Fgithub.com%2Frloomans%2Fdocker-calibre-server%2Ftags)
![GitHub release](https://img.shields.io/github/v/release/rloomans/docker-calibre-server?logo=github&link=https%3A%2F%2Fgithub.com%2Frloomans%2Fdocker-calibre-server%2Freleases)
![Docker Image Build](https://img.shields.io/github/actions/workflow/status/rloomans/docker-calibre-server/docker-image-publish.yml?logo=github&label=image%20build)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/rloomans/docker-calibre-server/latest?logo=github&link=https%3A%2F%2Fgithub.com%2Frloomans%2Fdocker-calibre-server%2Fcommits%2Fmain)
![GitHub all releases](https://img.shields.io/github/downloads/rloomans/docker-calibre-server/total?logo=github&link=https%3A%2F%2Fgithub.com%2Frloomans%2Fdocker-calibre-server%2Fpkgs%2Fcontainer%2Fcalibre-server)
![Docker Image Version](https://img.shields.io/docker/v/rloomans/calibre-server?sort=semver&label=image+version&logo=docker&link=http%3A%2F%2Fhub.docker.com%2Fr%2Frloomans%2Fcalibre-server)
![Docker Pulls](https://img.shields.io/docker/pulls/rloomans/calibre-server?logo=docker&link=http%3A%2F%2Fhub.docker.com%2Fr%2Frloomans%2Fcalibre-server)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/rloomans/calibre-server/latest?logo=docker&link=http%3A%2F%2Fhub.docker.com%2Fr%2Frloomans%2Fcalibre-server)

Automatically updating Docker image for `calibre-server`. The image contains a minimal [Calibre](https://calibre-ebook.com/) installation and starts a Calibre server. The current version should correspond with the [latest Calibre release](https://github.com/kovidgoyal/calibre/releases/latest) ![Latest Calibre release](https://img.shields.io/github/v/tag/kovidgoyal/calibre?logo=github&label=Calibre&link=https%3A%2F%2Fgithub.com%2Fkovidgoyal%2Fcalibre%2Freleases%2Flatest)
.

**Note:** This image is unofficial and not affiliated with Calibre.

## Usage

Calibre server is a REST API + web interface for Calibre. For more information about usage of `calibre-server` itself, refer to the [user guide](https://manual.calibre-ebook.com/server.html) and the [CLI manual](https://manual.calibre-ebook.com/generated/en/calibre-server.html) of Calibre.

### Use case 1: Standalone container for local use

```
$ docker run -ti -p 8080:8080 rloomans/calibre-server -v /path/to/library:/library
```

Now you have read+write access to your library via `localhost:8080`.

### Use case 2: Access from other containers within network

The command of "Use case 1" gives r+w access to your library on the host machine, but other containers in the network have readonly access. Calibre does not allow giving global r+w access without whitelisting or authentication. To give write access to other containers you should use the Docker `host` network type (not recommended) or you can whitelist containers within the bridge network:

```
$ docker run -ti -p 8080:8080 -v /path/to/library:/library -e TRUSTED_HOSTS="web1 web2" rloomans/calibre-server
```

**Note:** IP addresses of whitelisted containers (`web1` and `web2`) are resolved when `calibre-server` starts. So containers that need to access `calibre-server` have to start _before_ `calibre-server`.

### Use case 3: Docker compose (recommended)

You can get the same setup as "Use case 2" with this `docker-compose.yaml`:

```yaml
services:
    calibre:
        image: rloomans/calibre-server
        volumes:
            - /path/to/library:/library
        ports: 
            - "8080:8080"
        depends_on:  # start web1 and web2 before calibre
            - web1
            - web2
        environment:
            TRUSTED_HOSTS: web1 web2  # whitelist web1 and web2
    
    web1:
        image: nginx:alpine

    web2:
        image: nginx:alpine
```
