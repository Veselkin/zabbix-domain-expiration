# Zabbix Domain Expiration Check

Скрипт для Zabbix, проверяющий количество дней до истечения срока регистрации домена
с использованием `whois`.

Поддерживает различные форматы дат, встречающиеся у регистраторов.

## Возможности

- Проверка срока действия домена
- Возвращает количество дней до истечения
- Корректно обрабатывает разные форматы даты
- Подходит для Zabbix LLD (Low-Level Discovery)

## Требования

- Linux
- bash
- whois
- GNU date
- Zabbix Agent

## Установка

1. Скопируйте скрипт:

```bash
cp check_domain_expiration.sh /usr/lib/zabbix/externalscripts/
chmod +x /usr/lib/zabbix/externalscripts/check_domain_expiration.sh
```

2. Убедитесь, что whois установлен:

```
apt install whois
# или
yum install whois
```

Использование

Ручной запуск:

./check_domain_expiration.sh example.com


Вывод:

123


Где 123 — количество дней до окончания регистрации.

Если дату определить невозможно — возвращается 0.

Использование с LLD

Пример файла domains.json:

{
  "data": [
    { "{#DOMAIN}": "example.com" },
    { "{#DOMAIN}": "example.net" }
  ]
}