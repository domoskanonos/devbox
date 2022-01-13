# project
project template for new projects


  crudyboy:
    image: domoskanonos/crudyboy
    ports:
      - "8080:8081"
    environment:
      CONNECTION_STRING: postgresql://localhost/${POSTGRES_DB}?user=${POSTGRES_USER}&password=${POSTGRES_PASSWORD}
      DATABASE_NAME: ${POSTGRES_DB}