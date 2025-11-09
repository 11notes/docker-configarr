![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/banner/README.png)

# CONFIGARR
![size](https://img.shields.io/badge/image_size-68MB-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/configarr?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-configarr?color=7842f5">](https://github.com/11notes/docker-configarr/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/main/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Run configarr rootless, distroless and secure by default!

# INTRODUCTION 📢

[Configarr](https://github.com/raydak-labs/configarr) (created by [raydak-labs](https://github.com/raydak-labs)) is an open-source tool designed to simplify configuration and synchronization for Sonarr and Radarr (and other experimental). It integrates with TRaSH Guides to automate updates of custom formats, quality profiles, and other settings, while also supporting user-defined configurations. Configarr offers flexibility with deployment options like Docker and Kubernetes, ensuring compatibility with the latest versions of Sonarr and Radarr. By streamlining media server management, it saves time, enhances consistency, and reduces manual intervention.

# SYNOPSIS 📖
**What can I do with this?** This image will give you a [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md) Configarr installation for your adventures on the high seas *arrrr*!

# ARR STACK IMAGES 🏴‍☠️
This image is part of the so called arr-stack (apps to pirate and manage media content). Here is the list of all it's companion apps for the best pirate experience:

- [11notes/plex](https://github.com/11notes/docker-plex) - as your media server
- [11notes/prowlarr](https://github.com/11notes/docker-prowlarr) - to manage all your indexers
- [11notes/qbittorrent](https://github.com/11notes/docker-qbittorrent) - as your torrent client
- [11notes/radarr](https://github.com/11notes/docker-radarr) - to manage your films
- [11notes/sabnzbd](https://github.com/11notes/docker-sabnzbd) - as your usenet client
- [11notes/sonarr](https://github.com/11notes/docker-sonarr) - to manage your TV shows

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image is built and compiled from source
>* ... this image has a custom init process that enables scheduling natively
>* ... this image supports 32bit architecture
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/configarr:1.17.2 | 68MB | 1000:1000 | ✅ | amd64, arm64 |
| raydak-labs/configarr | 187MB | 0:0 | ❌ | amd64, arm64 |

# VOLUMES 📁
* **/configarr/etc** - Directory of your config
* **/configarr/var** - Directory of the synced guides

# COMPOSE ✂️
```yaml
name: "arr"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  configarr:
    image: "11notes/configarr:1.17.2"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      # sync configarr every two hours
      CONFIGARR_SCHEDULE: "0 */2 * * *"
    networks:
      frontend:
    volumes:
      - "configarr.etc:/configarr/etc"
      - "configarr.var:/configarr/var"
    restart: "always"

volumes:
  configarr.etc:
  configarr.var:

networks:
  frontend:
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /configarr | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [1.17.2](https://hub.docker.com/r/11notes/configarr/tags?name=1.17.2)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:1.17.2``` you can use ```:1``` or ```:1.17```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/configarr:1.17.2
docker pull ghcr.io/11notes/configarr:1.17.2
docker pull quay.io/11notes/configarr:1.17.2
```

# SOURCE 💾
* [11notes/configarr](https://github.com/11notes/docker-configarr)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates, nothing else
>* [11notes/distroless:node](https://github.com/11notes/docker-distroless/blob/master/node.dockerfile) - runtime for javascript applications
>* [11notes/distroless:git](https://github.com/11notes/docker-distroless/blob/master/git.dockerfile) - app to pull and push data to git repositories

# BUILT WITH 🧰
* [raydak-labs/configarr](https://github.com/raydak-labs/configarr)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-configarr/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-configarr/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-configarr/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 09.11.2025, 06:14:02 (CET)*