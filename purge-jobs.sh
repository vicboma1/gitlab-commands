#!/bin/bash

PROJECT_ID=$1
PRIVATE_TOKEN=$2
GITLAB_URL=$3
DAYS_AGO=$4

LIMIT_DATE=$(date -u -d "-${DAYS_AGO} days" +"%Y-%m-%dT%H:%M:%S.000Z")
echo "Eliminando jobs con estado success/failed anteriores a $LIMIT_DATE ..."

PAGE=0
while true; do
    echo " Descargando pagina $PAGE..."
    RESPONSE=$(curl --silent --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
        "$GITLAB_URL/api/v4/projects/$PROJECT_ID/jobs?per_page=100&page=$PAGE")

    COUNT=$(echo "$RESPONSE" | jq 'length')
    if [ "$COUNT" -eq 0 ]; then
        echo " *********** No hay mas jobs que procesar."
        break
    fi

    echo "$RESPONSE" | jq -c ".[] | select((.status == \"success\" or .status == \"failed\"))" | while read -r job; do
        JOB_ID=$(echo "$job" | jq -r '.id')
        CREATED_AT=$(echo "$job" | jq -r '.created_at')
        STATUS=$(echo "$job" | jq -r '.status')

        echo " Job $JOB_ID: created_at=$CREATED_AT, limite=$LIMIT_DATE"

        if [[ "$CREATED_AT" < "$LIMIT_DATE" ]]; then
            echo "  Eliminando job $JOB_ID ($STATUS, creado el $CREATED_AT)..."

            HTTP_CODE=$(curl --silent --write-out "%{http_code}" --output /dev/null \
                --request POST \
                --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
                "$GITLAB_URL/api/v4/projects/$PROJECT_ID/jobs/$JOB_ID/erase")

            if [ "$HTTP_CODE" -eq 201 ]; then
                echo " Job $JOB_ID eliminado correctamente"
            elif [ "$HTTP_CODE" -eq 404 ]; then
                echo "  Job $JOB_ID no encontrado (404), posiblemente ya borrado"
            elif [ "$HTTP_CODE" -eq 403 ]; then
                echo "  Job $JOB_ID ha sido borrado"
            else
                echo " Error al eliminar job $JOB_ID (HTTP $HTTP_CODE)"
            fi
        else
            echo " Job $JOB_ID mas reciente que $LIMIT_DATE, se mantiene"
        fi
    done

    ((PAGE++))
done

echo "Limpieza completada"
