# TYPO3 docker container
## by crynton.com

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