# github.com/SavageCore/docker-freepbx

[![Build Status](https://img.shields.io/github/actions/workflow/status/SavageCore/docker-freepbx/main.yml?style=flat-square)](https://github.com/SavageCore/docker-freepbx/actions/workflows/main.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/savagecore/freepbx.svg)](https://hub.docker.com/r/savagecore/freepbx)

* * *

## Introduction

Dockerfile to build a [FreePBX](https://www.freepbx.org) - A Voice over IP manager for Asterisk.
Upon starting this image it will give you a turn-key PBX system for SIP calling.

* Latest release FreePBX 17
* Latest release Asterisk 22
* Installed from Sangoma packages, no source compile
* Choice of running embedded database or modifies to support external MariaDB Database and only require one DB.
* Supports data persistence
* Fail2Ban installed to block brute force attacks
* Debian Bookworm base w/ Apache2
* NodeJS stock Bookworm
* PHP 8.2
* Redis for caching, replaces MongoDB and XMPP lets-chat
* Automatically installs User Control Panel and displays at first page
* Option to Install [Flash Operator Panel 2](https://www.fop2.com/)
* Customizable FOP and Admin URLs

**If you are presently running this image when it utilized FreePBX 14 and
Asterisk 14 and can no longer use your image, please see [this post](https://github.com/tiredofit/docker-freepbx/issues/51)**


[Changelog](CHANGELOG.md)

## Maintainer

- [SavageCore](https://github.com/SavageCore)

This project is a fork of [tiredofit/docker-freepbx](https://github.com/tiredofit/docker-freepbx)
by [Dave Conroy](https://github.com/tiredofit), which provided the original
container layout, init scripts, and documentation this image builds on.

## Table of Contents

- [Introduction](#introduction)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Prerequisites and Assumptions](#prerequisites-and-assumptions)
- [Installation](#installation)
  - [Build from Source](#build-from-source)
  - [Prebuilt Images](#prebuilt-images)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
  - [Environment Variables](#environment-variables)
    - [Base Images used](#base-images-used)
  - [Networking](#networking)
  - [Fail2Ban](#fail2ban)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support](#support)
  - [Usage](#usage)
  - [Bugfixes](#bugfixes)
  - [Feature Requests](#feature-requests)
  - [Updates](#updates)
- [License](#license)
- [References](#references)
-
## Prerequisites and Assumptions
*  Assumes you are using some sort of SSL terminating reverse proxy such as:
   *  [Traefik](https://github.com/tiredofit/docker-traefik)
   *  [Nginx](https://github.com/jc21/nginx-proxy-manager)
   *  [Caddy](https://github.com/caddyserver/caddy)
* You must have access to create records on your DNS server to be able to setup the demo installation before configuration.


You will also need an external MySQL/MariaDB container, although it can use an internally provided service (not recommended).

## Installation

### Build from Source
Clone this repository and build the image with `docker build -t (imagename) .`

### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/savagecore/freepbx) and is the recommended method of installation.

```bash
docker pull savagecore/freepbx:(imagetag)
```

The following image tags are available along with their tagged release based on what's written in the [Changelog](CHANGELOG.md):


| Version | Container OS | FreePBX Version | Tag      |
| ------- | ------------ | --------------- | -------- |
| latest  | Debian       | 17.x            | `latest` |
| 17      | Debian       | 17.x            | `17`     |


## Configuration

### Quick Start


 The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image. A Sample `docker-compose.yml` is provided that will work right out of the box for most people without any fancy optimizations.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make [networking ports](#networking) available for public access if necessary

*The first boot can take from 3 minutes - 30 minutes depending on your internet connection as there is a considerable amount of downloading to do!*

Login to the web server's admin URL (default /admin) and enter in your admin username, admin password, and email address and start configuring the system!

### Persistent Storage

The container supports data persistence and during Dockerfile build creates symbolic links for
`/var/lib/asterisk`, `/var/spool/asterisk`, `/home/asterisk`, and `/etc/asterisk`.
Upon startup configuration files are copied and generated to support portability.

The following directories should be mapped for persistent storage in order to utilize the container effectively.


| Directory        | Description                                                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------------- |
| `/certs`         | Drop your certificates here for TLS w/PJSIP / UCP / HTTPd/ FOP                                        |
| `/var/log/`      | Apache, Asterisk and FreePBX Log Files                                                                |
| `/data`          | Data persistence for Asterisk and FreePBX and FOP                                                     |
| `/assets/custom` | *OPTIONAL* - If you would like to overwrite some files in the container,                              |
|                  | put them here following the same folder structure for anything underneath the /var/www/html directory |
### Environment Variables

#### Base Images used

This image is based on Debian Bookworm with the [s6-overlay](https://github.com/just-containers/s6-overlay) init system for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`, `nano`,`vim`.

The container layout and base init scripts were originally adapted from the [tiredofit/docker-debian](https://github.com/tiredofit/docker-debian/) base image family.

| Parameter                    | Description                                                                                                     | Default                 |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `ADMIN_DIRECTORY`            | What folder to access admin panel                                                                               | `/admin`                |
| `DB_EMBEDDED`                | Allows you to use an internally provided MariaDB Server e.g. `TRUE` or `FALSE`                                  | `TRUE`                  |
| `DB_HOST`                    | Host or container name of MySQL Server e.g. `freepbx-db`                                                        |                         |
| `DB_PORT`                    | MySQL Port                                                                                                      | `3306`                  |
| `DB_NAME`                    | MySQL Database name e.g. `asterisk`                                                                             |                         |
| `DB_USER`                    | MySQL Username for above database e.g. `asterisk`                                                               |                         |
| `DB_PASS`                    | MySQL Password for above database e.g. `password`                                                               |                         |
| `ENABLE_FAIL2BAN`            | Enable Fail2ban to block the "bad guys"                                                                         | `TRUE`                  |
| `ENABLE_FOP`                 | Enable Flash Operator Panel                                                                                     | `FALSE`                 |
| `ENABLE_SSL`                 | Enable HTTPd to serve SSL requests                                                                              | `FALSE`                 |
| `FOP_DIRECTORY`              | What folder to access FOP                                                                                       | `/fop`                  |
| `HTTP_PORT`                  | HTTP listening port                                                                                             | `80`                    |
| `HTTPS_PORT`                 | HTTPS listening port                                                                                            | `443`                   |
| `INSTALL_ADDITIONAL_MODULES` | Comma separated list of modules to additionally install on first container startup                              |                         |
| `RTP_START`                  | What port to start RTP transmissions                                                                            | `18000`                 |
| `RTP_FINISH`                 | What port to start RTP transmissions                                                                            | `20000`                 |
| `UCP_FIRST`                  | Load UCP as web frontpage `TRUE` or `FALSE`                                                                     | `TRUE`                  |
| `TLS_CERT`                   | TLS certificate to drop in /certs for HTTPS if no reverse proxy                                                 |                         |
| `TLS_KEY`                    | TLS Key to drop in /certs for HTTPS if no reverse proxy                                                         |                         |
| `WEBROOT`                    | If you wish to install to a subfolder use this. Example: `/var/www/html/pbx`                                    | `/var/www/html`         |

*`ADMIN_DIRECTORY ` and `FOP_DIRECTORY` may not work correctly if `WEBROOT` is changed or `UCP_FIRST=FALSE`*

### Networking

The following ports are exposed.

| Port              | Description |
| ----------------- | ----------- |
| `80`              | HTTP        |
| `443`             | HTTPS       |
| `4445`            | FOP         |
| `4569`            | IAX         |
| `5060/udp`        | PJSIP       |
| `5160/udp`        | SIP         |
| `5061`            | PJSIP TLS   |
| `5161`            | SIP TLS     |
| `8001`            | UCP         |
| `8003`            | UCP SSL     |
| `8008`            | UCP         |
| `8009`            | UCP SSL     |
| `8025`            | PM2         |
| `18000-20000/udp` | RTP ports   |


### Fail2Ban

* For fail2ban rules to kickin, the `security` log level needs to be enable for asterisk `full` log file. This can be done from the Settings > Log File Settings > Log files.

### Reverse proxying (UCP)

If you terminate TLS on a reverse proxy (recommended) instead of exposing
the container directly, the UCP web client needs its Node.js backend.
The browser connects to `/socket.io/` on the same host, so proxy that
path to the container's UCP Node port (8001). Plain HTTP proxying is not
enough: socket.io upgrades to websockets, so the proxy must handle the
`Upgrade` header. Apache example (needs `proxy`, `proxy_http`,
`proxy_wstunnel`, `rewrite`):

```apache
ProxyPreserveHost On

# UCP Node.js (websocket + long-poll fallback). Must come BEFORE the
# generic backend ProxyPass, otherwise UCP fails with "xhr poll error".
RewriteEngine On
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteRule ^/socket.io/(.*) ws://localhost:8001/socket.io/$1 [P,L]
ProxyPass /socket.io/ http://localhost:8001/socket.io/
ProxyPassReverse /socket.io/ http://localhost:8001/socket.io/

ProxyPass / http://localhost:8200/
ProxyPassReverse / http://localhost:8200/
```

Direct port publishing (replace the loopback `127.0.0.1:8001:8001` with
`8001:8001` plus `8003:8003`, open both in the host firewall) also works
but exposes the Node server; proxying keeps a single TLS entry point.
Note: the UCP client always targets the HTTPS node port (`:8003`
currently), so direct access requires 8003 published, not just 8001.

The UCP web client derives its socket URL from the `NODEJSHTTPSBINDPORT`
setting (default `8003`). Do NOT set it to `443` to force same-origin
proxying: the Node server binds that port itself and collides with Apache.
Keep Node on 8001/8003 and proxy `/socket.io/` to it as above.

## Migration from 15 (skip 16)

There is no in-place upgrade. 15 to 17 crosses Debian Buster to Bookworm,
PHP 5.6 to 8.2, and Asterisk 17 to 22 (dialplan macros removed).

1. On the 15 system: Admin, Backup and Restore, run a Full Backup, download the tarball.
2. Deploy this 17 image with an EMPTY `/data` volume and complete first boot.
3. On the 17 system: Admin, Backup and Restore, Restore from the 15 tarball.
4. If the 15 system used an external database and the 17 system does not, re-point Settings, Advanced Settings, CDR Database Settings (host, name, user, password) at the new database, then `fwconsole reload` so Asterisk ODBC follows.
5. Audit custom dialplan and third-party modules for Asterisk macro usage (`Macro()`, `MacroExit`) and rewrite as `GoSub` before cutover.
6. Re-issue/renew certificates (cert paths move with the new Apache/PHP layout) and re-test trunks, routes, voicemail, UCP.

## Maintenance

* There seems to be a problem with the CDR Module when updating where it refuses to update when using an external DB Server.
If that happens, simply enter the container (as shown below) and execute `upgrade-cdr`, which will download the latest CDR module,
apply a tweak, install, and reload the system for you.

# Known Bugs

* When installing Parking Lot or Feature Codes you sometimes get `SQLSTATE[22001]: String data, right truncated:
1406 Data too long for column 'helptext' at row 1`. To resolve login to your SQL server and issue this statement:
`alter table featurecodes modify column helptext varchar(500);`
* If you find yourself needing to update the framework or core modules and experience issues, enter the container and
run `upgrade-core` which will truncate the column and auto upgrade the core and framework modules.

### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

```bash
docker exec -it (whatever your container name is e.g. freepbx) bash
```

## Support

These images were built to serve a specific need in a production environment and gradually have had more functionality added based on requests from the community.
### Usage
- The [Discussions board](../../discussions) is a great place for working with the community on tips and tricks of using this image.
### Bugfixes
- Please, submit a [Bug Report](issues/new) if something isn't working as expected. I'll do my best to issue a fix in short order.

### Feature Requests
- Feel free to submit a feature request, however there is no guarantee that it will be added, or at what timeline.

### Updates
- Best effort to track upstream changes, More priority if I am actively using the image in a production environment.

## License
MIT. See [LICENSE](LICENSE) for more details.
## References


* https://freepbx.org/
