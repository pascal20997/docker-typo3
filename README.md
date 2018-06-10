# TYPO3 docker container
## by crynton.com

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

*Example docker-compose.yml:*
```
version: '3'
services:
  apache_t3-9:
    image: git.crynton.com:49153/docker/typo3:latest
    container_name: apache_t3-9
    restart: always
    volumes:
      - htdocs:/var/www
      - ssh:/root/.ssh
      - /etc/localtime:/etc/localtime:ro
    environment:
      SERVER_ADMIN: "mail@domain.tld"
    depends_on:
      - db_t3-9
  db_t3-9:
    image: mysql:5.7
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

*Example docker-compose.yml using jwilder nginx proxy:*
```
version: '3'
services:
  apache_t3-9:
    image: git.crynton.com:49153/docker/typo3:latest
    container_name: apache_t3-9
    restart: always
    volumes:
      - htdocs:/var/www
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
    image: mysql:5.7
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
