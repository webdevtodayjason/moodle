# Moodle LMS on Railway

This repository contains configuration files to deploy Moodle Learning Management System on Railway.com. It uses PHP 8.2, PostgreSQL 14+, and persistent storage for media and course files.

## Overview

Moodle is a free and open-source learning management system written in PHP and distributed under the GNU General Public License. Moodle is used for blended learning, distance education, flipped classroom and other e-learning projects in schools, universities, workplaces and other sectors.

This setup includes:

- Moodle LMS with PHP 8.2
- PostgreSQL 14+ database
- Persistent storage for uploads and course files
- Automatic database initialization
- Cron jobs for Moodle tasks
- Apache web server with proper configuration
- Supervisor process management

## Requirements

- A Railway.com account
- A basic understanding of Moodle administration
- Optionally, a custom domain for your Moodle installation

## Deployment Instructions

### Option 1: Deploy with One Click

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/moodle)

### Option 2: Manual Deployment

1. Fork this repository to your GitHub account
2. Create a new Railway project
3. Add a new service and select "Deploy from GitHub repo"
4. Connect your GitHub account and select the forked repository
5. Railway will automatically detect the `railway.toml` file and configure the build
6. Configure the required environment variables (see below)
7. Deploy the project

## Environment Variables

Configure the following environment variables in your Railway project:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `DATABASE_URL` | PostgreSQL connection URL | Yes | Auto-provided by Railway |
| `MOODLE_ADMIN_PASSWORD` | Password for the admin user | Yes | None |
| `MOODLE_ADMIN_USER` | Username for the admin user | No | admin |
| `MOODLE_SITE_NAME` | Full name of your Moodle site | No | Moodle LMS |
| `MOODLE_SITE_SHORTNAME` | Short name of your Moodle site | No | Moodle |
| `PHP_MAX_EXECUTION_TIME` | Maximum execution time for PHP scripts | No | 600 |
| `PHP_MEMORY_LIMIT` | PHP memory limit | No | 512M |
| `PHP_UPLOAD_MAX_FILESIZE` | Maximum file upload size | No | 256M |
| `PHP_POST_MAX_SIZE` | Maximum POST request size | No | 256M |
| `HEALTHCHECK_TOKEN` | Secret token for accessing the healthcheck endpoint | Yes | None |

## Post-Installation Steps

After deploying your Moodle instance, follow these steps:

1. Access your Moodle site using the Railway-provided URL
2. Log in with the admin credentials you configured
3. Complete the Moodle site setup:
   - Configure site settings
   - Set up courses and categories
   - Add users or configure authentication methods
   - Install additional plugins if needed
4. Configure a custom domain (optional):
   - Add a custom domain in Railway project settings
   - Set up DNS records as instructed by Railway
   - Update your Moodle site URL in Site Administration → Server → HTTP

## Maintenance

### Updating Moodle

To update Moodle to a newer version:

1. Update the code in your GitHub repository
2. Railway will automatically rebuild and deploy the updated version

### Backing Up

Moodle has built-in backup functionality:

1. Go to Site Administration → Courses → Backups
2. Configure automated course backups
3. For database backups, you can use Railway's database backup features

## Health Monitoring

This deployment includes a built-in health check endpoint that Railway uses to monitor the application's status:

- **Endpoint**: `/healthcheck.php`
- **Features**:
  - Database connectivity check
  - File system access verification
  - Core Moodle functionality testing
  - Security checks

The health check can also be accessed externally by sending the `HEALTHCHECK_TOKEN` in the `X-Healthcheck-Token` HTTP header.

Example:
```
curl -H "X-Healthcheck-Token: your-token-here" https://your-moodle-instance.railway.app/healthcheck.php
```

## Security Considerations

- **HEALTHCHECK_TOKEN**: Set this to a strong, unique value to protect the health check endpoint
- **Admin Password**: Use a strong password for the Moodle admin user
- **File Permissions**: The setup applies secure file permissions by default
- **Railway Environment**: All sensitive environment variables are securely managed by Railway

## Troubleshooting

Common issues and solutions:

- **Database Connection Errors**: Verify that the DATABASE_URL environment variable is correctly set and the PostgreSQL service is running.
- **File Permission Issues**: Check that the persistent storage volume is correctly mounted and has appropriate permissions.
- **Performance Issues**: Adjust PHP memory and execution time limits as needed.
- **Cron Tasks Not Running**: Verify that the cron job is set up correctly. Check the logs with `railway logs`.
- **Health Check Failures**: Check the response from the health check endpoint for specific error messages.

## Resources

- [Moodle Documentation](https://docs.moodle.org/)
- [Railway Documentation](https://docs.railway.app/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

# Moodle

<p align="center"><a href="https://moodle.org" target="_blank" title="Moodle Website">
  <img src="https://raw.githubusercontent.com/moodle/moodle/main/.github/moodlelogo.svg" alt="The Moodle Logo">
</a></p>

[Moodle][1] is the World's Open Source Learning Platform, widely used around the world by countless universities, schools, companies, and all manner of organisations and individuals.

Moodle is designed to allow educators, administrators and learners to create personalised learning environments with a single robust, secure and integrated system.

## Documentation

- Read our [User documentation][3]
- Discover our [developer documentation][5]
- Take a look at our [demo site][4]

## Community

[moodle.org][1] is the central hub for the Moodle Community, with spaces for educators, administrators and developers to meet and work together.

You may also be interested in:

- attending a [Moodle Moot][6]
- our regular series of [developer meetings][7]
- the [Moodle User Association][8]

## Installation and hosting

Moodle is Free, and Open Source software. You can easily [download Moodle][9] and run it on your own web server, however you may prefer to work with one of our experienced [Moodle Partners][10].

Moodle also offers hosting through both [MoodleCloud][11], and our [partner network][10].

## License

Moodle is provided freely as open source software, under version 3 of the GNU General Public License. For more information on our license see

[1]: https://moodle.org
[2]: https://moodle.com
[3]: https://docs.moodle.org/
[4]: https://sandbox.moodledemo.net/
[5]: https://moodledev.io
[6]: https://moodle.com/events/mootglobal/
[7]: https://moodledev.io/general/community/meetings
[8]: https://moodleassociation.org/
[9]: https://download.moodle.org
[10]: https://moodle.com/partners
[11]: https://moodle.com/cloud
[12]: https://moodledev.io/general/license
