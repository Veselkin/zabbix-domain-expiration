#!/bin/bash
DOMAIN="$1"

if [ -z "$DOMAIN" ]; then
    echo 0
    exit 0
fi

EXPIRATION_DATE=$(whois "$DOMAIN" 2>/dev/null | grep -i -E 'Expiration Date:|Expiry Date:|Registrar Registration Expiration Date:' | head -n 1 | awk -F': ' '{print $2}' | awk '{print $1}' | sed 's/T.*$//' | sed 's/Z$//' | sed 's/\..*$//')

if [ -z "$EXPIRATION_DATE" ]; then
    EXPIRATION_DATE=$(whois "$DOMAIN" 2>/dev/null | grep -i -E 'Expires on:|paid-till:' | head -n 1 | awk -F': ' '{print $2}' | awk '{print $1}' | sed 's/T.*$//' | sed 's/Z$//' | sed 's/\..*$//')
fi

if [ -z "$EXPIRATION_DATE" ]; then
    echo 0
    exit 0
fi

if [[ "$EXPIRATION_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
    NORMALIZED_EXP_DATE="$EXPIRATION_DATE"
elif [[ "$EXPIRATION_DATE" =~ ^[0-9]{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01]) ]]; then
    NORMALIZED_EXP_DATE="${EXPIRATION_DATE:0:4}-${EXPIRATION_DATE:4:2}-${EXPIRATION_DATE:6:2}"
elif [[ "$EXPIRATION_DATE" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2} ]]; then
    NORMALIZED_EXP_DATE=$(echo "$EXPIRATION_DATE" | sed 's/\./-/g')
elif [[ "$EXPIRATION_DATE" =~ ^[0-9]{4}\/[0-9]{2}\/[0-9]{2} ]]; then
    NORMALIZED_EXP_DATE=$(echo "$EXPIRATION_DATE" | sed 's/\//-/g')
else
    NORMALIZED_EXP_DATE=$(TZ=UTC date -d "$EXPIRATION_DATE" +%Y-%m-%d 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$NORMALIZED_EXP_DATE" ]; then
        echo 0
        exit 0
    fi
fi

CURRENT_DATE=$(date +%s)
EXP_DATE_SECONDS=$(date -d "$NORMALIZED_EXP_DATE" +%s 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$EXP_DATE_SECONDS" ]; then
    echo 0
    exit 0
fi

DAYS_REMAINING=$(( (EXP_DATE_SECONDS - CURRENT_DATE) / 86400 ))

# Не допускаем отрицательных значений
if [ "$DAYS_REMAINING" -lt 0 ]; then
    echo 0
else
    echo "$DAYS_REMAINING"
fi
