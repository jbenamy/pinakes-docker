# Pinakes - Library Management System (Docker)

This repository contains the Docker configuration for running [Pinakes](https://github.com/fabiodalez-dev/Pinakes), a web-based library management system. It provides a simple, multi-container environment using Docker Compose to run the application, a web server, and a database.

## Overview

The setup consists of three main services orchestrated by `docker-compose.yml`:

*   **`pinakes`**: The PHP application itself, running on PHP 8.2-FPM. A pre-built image is published to the GitHub Container Registry (`ghcr.io/jbenamy/pinakes-docker`) on every push to `main` and on tagged releases. You can also build the image locally from the included `Dockerfile`.
*   **`nginx`**: A lightweight Nginx web server (using the `alpine` image) that serves the application's front-end and acts as a reverse proxy to the PHP-FPM service.
*   **`mariadb`**: A MariaDB 11 database server for storing the application's data.

## Features

*   **Dockerized Environment**: Run Pinakes without installing PHP, Nginx, or MariaDB on your local machine.
*   **Simple Setup**: Get started with a single `docker-compose` command.
*   **Automated Installation**: The entrypoint script detects if the database is empty and guides you to the web installer.
*   **Production-Ready**: The configuration is based on production best practices, including a production `php.ini` and security headers in Nginx.
*   **Customizable**: Easily change the application version, database credentials, and other settings through environment variables.

## Technology Stack

*   **Backend**: PHP 8.2
*   **Web Server**: Nginx
*   **Database**: MariaDB 11
*   **Containerization**: Docker, Docker Compose

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   [Docker](https://docs.docker.com/get-docker/)
*   [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)

### Installation

1.  **Clone this repository:**
    ```bash
    git clone https://github.com/jbenamy/pinakes-docker.git
    cd pinakes-docker
    ```

2.  **Start the services:**
    ```bash
    docker-compose up -d
    ```
    This pulls the pre-built `pinakes` image from `ghcr.io`, downloads the other required images, and starts all containers in the background.

    To build the image locally instead (e.g. to test local changes), replace `image:` with `build: .` in the `pinakes` service and run:
    ```bash
    docker-compose up -d --build
    ```

3.  **Complete the web installation:**
    Open your web browser and navigate to `http://localhost:8080/installer/`. You will be guided through the final setup steps by the Pinakes web installer.

    The entrypoint script automatically checks if the database is empty. If it is, the installer is available. Once installation is complete, Pinakes creates a `.installed` lock file that causes the installer to block re-execution on subsequent visits. (Note: the upstream `.htaccess`-based redirect is Apache-only and has no effect on Nginx; protection here relies on the PHP-level gate in `installer/index.php`.)

4.  **Access the application:**
    Once the installation is complete, you can access Pinakes at `http://localhost:8080`.

## Configuration

The application is configured using environment variables set in the `docker-compose.yml` file. These variables are used by `docker-entrypoint.sh` to generate a `.env` file inside the `pinakes` container at startup if one does not already exist.

### Runtime environment variables

The following variables can be set in the `environment` section of the `pinakes` service in `docker-compose.yml`:

| Variable                | Description                                         | Default      |
| ----------------------- | --------------------------------------------------- | ------------ |
| `DB_HOST`               | The hostname of the database server.                | `mariadb`    |
| `DB_USER`               | The username for the database connection.           | `pinakes`    |
| `DB_PASS`               | The password for the database connection.           | `pinakes`    |
| `DB_NAME`               | The name of the database.                           | `pinakes`    |
| `DB_PORT`               | The port of the database server.                    | `3306`       |
| `APP_ENV`               | Application environment (`production`, `development`). | `production` |
| `APP_DEBUG`             | Enable debug mode.                                  | `false`      |
| `APP_LOCALE`            | Application locale.                                 | `en_US`      |
| `APP_CANONICAL_URL`     | The canonical URL of the application.               | *(empty)*    |
| `SESSION_LIFETIME`      | Session lifetime in seconds.                        | `3600`       |
| `PLUGIN_ENCRYPTION_KEY` | Encryption key for plugins. Auto-generated if not set. | *(random)*   |

The `mariadb` service uses `MARIADB_ROOT_PASSWORD` (default: `pinakes-root`) along with `MARIADB_DATABASE`, `MARIADB_USER`, and `MARIADB_PASSWORD` to initialize the database. These should be changed for any non-local deployment.

### Build arguments

The `pinakes` image accepts one build argument, passed with `--build-arg`:

| Argument        | Description                                              | Default |
| --------------- | -------------------------------------------------------- | ------- |
| `PINAKES_REF`   | The branch or tag of the Pinakes repository to build.    | `main`  |

Example: `docker-compose build --build-arg PINAKES_REF=v1.2.3`

### Custom `.env` override

The entrypoint skips auto-generating `.env` if the file already exists in the container. You can supply your own by adding a bind mount to the `pinakes` service in `docker-compose.yml`:

```yaml
volumes:
  - ./my.env:/var/www/pinakes/.env:ro
```

## Directory Structure

*   `docker-compose.yml`: The main Docker Compose file that defines the services.
*   `Dockerfile`: The Dockerfile for building the `pinakes` PHP-FPM image.
*   `docker-entrypoint.sh`: The entrypoint script for the `pinakes` container.
*   `nginx.conf`: The Nginx configuration file.
*   `php-custom.ini`: Custom PHP settings.
*   `php-fpm-www.conf`: PHP-FPM pool configuration.
*   `.dockerignore`: Specifies files to ignore when building the Docker image.
*   `.github/workflows/docker-publish.yml`: GitHub Actions workflow that builds the image for `linux/amd64` and `linux/arm64` and pushes it to `ghcr.io` on every push to `main` and on `v*` tags.

## Contributing

Contributions are welcome! If you have suggestions for improving this Docker setup, please feel free to open an issue or submit a pull request.

## License

This project is open-source and available under the MIT License.
