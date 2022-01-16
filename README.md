# project
project template for new projects


  crudyboy:
    image: domoskanonos/crudyboy
    ports:
      - "8080:8081"
    environment:
      CONNECTION_STRING: postgresql://localhost/${POSTGRES_DB}?user=${POSTGRES_USER}&password=${POSTGRES_PASSWORD}
      DATABASE_NAME: ${POSTGRES_DB}




      POSTGRES_PASSWORD=pwd
POSTGRES_USER=user


## 
docker-compose -f docker-compose-local.yml up

docker-compose -f docker-compose-local.yml down

## daemon mode
docker-compose -f docker-compose-local.yml up -d
