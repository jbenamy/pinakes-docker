# Pinakes - Library Management System (Docker)

This repository contains the Docker configuration for running [Pinakes](https://github.com/fabiodalez-dev/Pinakes), a web-based library management system. It provides a simple, multi-container environment using Docker Compose to run the application, a web server, and a database.

## Overview

The setup consists of three main services orchestrated by `docker-compose.yml`:

*   **`pinakes`**: The PHP application itself, running on PHP 8.2-FPM. The container builds from the official `php` image, fetches the latest Pinakes source code from its GitHub repository, and installs dependencies with Composer.
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
    git clone https://github.com/your-username/pinakes-docker.git
    cd pinakes-docker
    ```

2.  **Build and start the services:**
    ```bash
    docker-compose up -d
    ```
    This command will build the `pinakes` image, download the other required images, and start the containers in the background.

3.  **Complete the web installation:**
    Open your web browser and navigate to `http://localhost:8080/installer/`. You will be guided through the final setup steps by the Pinakes web installer.

    The entrypoint script automatically checks if the database is empty. If it is, the installer is available. Once the installation is complete, the installer will be disabled for security reasons.

4.  **Access the application:**
    Once the installation is complete, you can access Pinakes at `http://localhost:8080`.

## Configuration

The application is configured using environment variables set in the `docker-compose.yml` file. These variables are used by the `docker-entrypoint.sh` script to generate a `.env` file inside the `pinakes` container.

The following variables can be customized in `docker-compose.yml`:

| Variable                | Description                                         | Default      |
| ----------------------- | --------------------------------------------------- | ------------ |
| `DB_HOST`               | The hostname of the database server.                | `mariadb`    |
| `DB_USER`               | The username for the database connection.           | `pinakes`    |
| `DB_PASS`               | The password for the database connection.           | `pinakes`    |
| `DB_NAME`               | The name of the database.                           | `pinakes`    |
| `MARIADB_ROOT_PASSWORD` | The root password for the MariaDB server.           | `pinakes-root` |
| `PINAKES_REF`           | The Git branch or tag of the Pinakes repository to use. | `main`         |

If you need to customize other application settings, you can create your own `.env` file in the project's root directory. This file will be mounted into the container and will take precedence over the auto-generated one.

## Directory Structure

*   `docker-compose.yml`: The main Docker Compose file that defines the services.
*   `Dockerfile`: The Dockerfile for building the `pinakes` PHP-FPM image.
*   `docker-entrypoint.sh`: The entrypoint script for the `pinakes` container.
*   `nginx.conf`: The Nginx configuration file.
*   `php-custom.ini`: Custom PHP settings.
*   `php-fpm-www.conf`: PHP-FPM pool configuration.
*   `.dockerignore`: Specifies files to ignore when building the Docker image.

## Contributing

Contributions are welcome! If you have suggestions for improving this Docker setup, please feel free to open an issue or submit a pull request.

## License

This project is open-source and available under the [MIT License](LICENSE).
