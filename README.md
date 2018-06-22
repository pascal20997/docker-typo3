# TYPO3 docker container (TYPO3 7, TYPO3 8, TYPO3 9)

Container by crynton.com

Master git repository: https://git.crynton.com/docker/typo3

Contact: Create an issue ticket if you´ve a feature request, bug, and other with this container development related questions OR use https://crynton.com/contact.html for any other question :)

## Settings

You can configure this docker container by using the following environment variables:

| Variable name     | Description                                                               | Default                                             |
| ----------------- |---------------------------------------------------------------------------| ---------------------------------------------------|
| TYPO3_VERSION     | The version which should be used for installing TYPO3 via composer        | ^9                                                  |
| SERVER_ADMIN      | E-Mail of the server admin (for apache)                                   | pleaseSetTheEnvironment@variable.tld                |
| SURF_DOWNLOAD_URL | Download-URL to be used for installing surf                               | Download URL for surf 2.0.0-beta7                   |
| DOCUMENT_ROOT     | Document root folder                                                      | /home/crynton/htdocs/public (create-project default) |
| INSTALL_TYPO3     | Set to a different value then true to not install TYPO3 with first boot  | true                                                |
| START_SSHD        | Set to a different value then true to not start openssh-server on boot   | true                                                | 

## Examples

### Using TYPO3 with MariaDB

```
version: '3'
services:
  apache_t3-9:
    image: pascal20997/typo3:latest
    container_name: apache_t3-9
    restart: always
    ports:
      - 8080:80
    volumes:
      - htdocs:/home/crynton/htdocs
      - ssh:/root/.ssh
      - /etc/localtime:/etc/localtime:ro
    environment:
      SERVER_ADMIN: "mail@domain.tld"
    depends_on:
      - db_t3-9
  db_t3-9:
    image: mariadb:10
    volumes:
      - db_data:/var/lib/mysql
    environment:
      - "MYSQL_ROOT_PASSWORD=MySecretPassword"
      - "MYSQL_DATABASE=typo3"
      - "MYSQL_USER=typo3"
      - "MYSQL_PASSWORD=123456789"
volumes:
  htdocs:
  ssh:
  db_data:
```

### Using TYPO3 with MariaDB and jwilder/nginx-proxy

```
version: '3'
services:
  apache_t3-9:
    image: pascal20997/typo3:latest
    container_name: apache_t3-9
    restart: always
    volumes:
      - htdocs:/home/crynton/htdocs
      - ssh:/root/.ssh
      - /etc/localtime:/etc/localtime:ro
    environment:
      DEFAULT_HOST: "domain.tld"
      VIRTUAL_HOST: "domain.tld"
      LETSENCRYPT_HOST: "domain.tld"
      LETSENCRYPT_EMAIL: "mail@domain.tld"
      SERVER_ADMIN: "mail@domain.tld"
      SSL_POLICY: "Mozilla-Modern"
    depends_on:
      - db_t3-9
    networks:
      - proxy-prod
  db_t3-9:
    image: mariadb:10
    volumes:
      - db_data:/var/lib/mysql
    environment:
      - "MYSQL_ROOT_PASSWORD=MySecretPassword"
      - "MYSQL_DATABASE=typo3"
      - "MYSQL_USER=typo3"
      - "MYSQL_PASSWORD=123456789"
    networks:
      - proxy-prod
volumes:
  htdocs:
  ssh:
  db_data:
networks:
  proxy-prod:
    external:
      name: nginx-proxy
```

### Using TYPO3 with PostgreSQL

```
version: '3'
services:
  apache_t3-9:
    image: pascal20997/typo3:latest
    container_name: apache_t3-9
    restart: always
    ports:
      - 8080:80
    volumes:
      - htdocs:/home/crynton/htdocs
      - ssh:/root/.ssh
      - /etc/localtime:/etc/localtime:ro
    environment:
      SERVER_ADMIN: "mail@domain.tld"
    depends_on:
      - db_t3-9
  db_t3-9:
    image: postgres:latest
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      - "POSTGRES_USER=typo3"
      - "POSTGRES_PASSWORD=MySecretPassword"
volumes:
  htdocs:
  ssh:
  db_data:
```

### Using those examples on macOS

It may be slow but you can use it. In my test environment I had to remove the /etc/localtime mount from the example and replace the volumes with a local mount.

```
version: '3'
services:
  apache_t3-9:
    image: pascal20997/typo3:latest
    container_name: apache_t3-9
    restart: always
    ports:
      - 8080:80
    volumes:
      - ./data/htdocs:/home/crynton/htdocs
      - ./data/ssh:/root/.ssh
    environment:
      SERVER_ADMIN: "mail@domain.tld"
    depends_on:
      - db_t3-9
  db_t3-9:
    image: mariadb:10
    volumes:
      - ./data/db:/var/lib/mysql
    environment:
      - "MYSQL_ROOT_PASSWORD=MySecretPassword"
      - "MYSQL_DATABASE=typo3"
      - "MYSQL_USER=typo3"
      - "MYSQL_PASSWORD=123456789"
```

## FAQ

### What is the hostname for MySQL?

The hostname is the name of your container. In my examples it´s `db_t3`. You should use that hostname while installing TYPO3.

### Is this container working with TYPO3 lower 7.6?

Not official. You can try using older versions than TYPO3 7.6 but I´ll not support those versions officially.