# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains a Moodle LMS (Learning Management System) deployment configured for Railway.com. It includes the core Moodle application with Docker configuration for deployment on Railway's infrastructure.

## Development Environment Setup

### Prerequisites

- PHP 8.2
- PostgreSQL 14+
- Docker (for containerized development/deployment)
- Composer (PHP package manager)

### Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd moodleLMS
   ```

2. **Configure the database:**
   - Create a PostgreSQL database for Moodle
   - Note the database credentials for configuration

3. **Create a config.php file:**
   - Copy config-dist.php to config.php
   - Update the database connection details
   - Set the data directory path

4. **Install dependencies:**
   ```bash
   composer install
   ```

5. **Set up the data directory:**
   - Create a directory for Moodle data
   - Ensure it has appropriate permissions (typically 777 for development)

## Development Commands

### Moodle CLI Commands

These commands should be run from the Moodle root directory:

```bash
# Install Moodle via CLI
php admin/cli/install.php --options

# Run Moodle cron tasks
php admin/cli/cron.php

# Purge all caches
php admin/cli/purge_caches.php

# Run a specific scheduled task
php admin/cli/scheduled_task.php --task='\core\task\task_name'

# Run an adhoc task
php admin/cli/adhoc_task.php --id=taskid

# Check the environment
php admin/cli/check_database_schema.php

# Database upgrade
php admin/cli/upgrade.php
```

### Docker Development

```bash
# Build the Docker image
docker build -t moodle-lms -f infra/Dockerfile .

# Run the Docker container
docker run -p 8080:80 -e DATABASE_URL=postgres://username:password@host:port/database -e MOODLE_ADMIN_PASSWORD=yourpassword -e HEALTHCHECK_TOKEN=yourtoken moodle-lms
```

### Railway Deployment

```bash
# Deploy to Railway
railway up

# View logs
railway logs

# Access Railway environment
railway connect
```

## Architecture Overview

Moodle LMS follows a modular architecture with these key components:

1. **Core System:** Located in `/lib` directory, provides base functionality
2. **Modules:** Located in `/mod` directory, contain learning activities
3. **Blocks:** Located in `/blocks` directory, provide UI components
4. **Themes:** Located in `/theme` directory, control appearance
5. **Plugins:** Various directories including local, auth, repository, etc.

The main configuration file is `config.php` which contains database connection details and core settings.

## Docker Infrastructure

The Docker setup includes:
- PHP 8.2 with Apache
- Required PHP extensions for Moodle
- PostgreSQL database connection
- Supervisord to manage processes
- Automated installation and configuration

## Key Files

- `infra/Dockerfile`: Container definition
- `infra/supervisord.conf`: Process management config
- `scripts/startup.sh`: Container initialization script
- `railway.toml`: Railway platform configuration

## Moodle Development Guidelines

- All code changes should follow Moodle coding style
- Bug fixes should be reported in the Moodle tracker
- Development is done on the 'main' branch
- Bug fixes are backported to stable branches when applicable

## Deployment Process

The standard deployment process:

1. Configure environment variables in Railway
2. Deploy the application
3. The startup script initializes the database if needed
4. Moodle installation runs automatically on first deployment
5. Access the site using the Railway-provided URL

## Resources

- [Moodle Developer Documentation](https://moodledev.io)
- [Moodle User Documentation](https://docs.moodle.org/)
- [Railway Documentation](https://docs.railway.app/)