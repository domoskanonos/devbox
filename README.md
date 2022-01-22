
![Alt text](./assets/logo-ink.svg)


# project
project template for new projects


  crudyboy:
    image: domoskanonos/crudyboy
    ports:
      - "8080:8081"
    environment:
      CONNECTION_STRING: postgresql://localhost/${POSTGRES_DB}?user=${POSTGRES_USER}&password=${POSTGRES_PASSWORD}
      DATABASE_NAME: ${POSTGRES_DB}




CREATE USER gitea WITH PASSWORD 'gitea';
CREATE DATABASE gitea;
GRANT ALL PRIVILEGES ON DATABASE gitea TO gitea;



      POSTGRES_PASSWORD=pwd
POSTGRES_USER=user


## 
docker-compose -f docker-compose-local.yml up

docker-compose -f docker-compose-local.yml down

## daemon mode
docker-compose -f docker-compose-local.yml up -d


open api gen:

docker run --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate -i /local/petstore.yaml -g go -o /local/out/go


https://openapi-generator.tech/docs/installation/



FUnktioneirt: jAva muss vorhanden sein im Path:

npx @openapitools/openapi-generator-cli generate -i http://localhost:8094/v3/api-docs -g typescript -o ./tmp/test/

