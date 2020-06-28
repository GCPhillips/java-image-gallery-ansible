#!/usr/bin/bash

CMD=$(aws --region "us-east-2" secretsmanager get-secret-value --secret-id m5-db-image-gallery-pass | jq --raw-output '.SecretString' | jq -r .password)
PASS="${CMD}"
CMD=$(aws --region "us-east-2" secretsmanager get-secret-value --secret-id m5-db-postgres-pass | jq --raw-output '.SecretString' | jq -r .password)
ADMINPASS="${CMD}"
CMD=$(aws rds --region "us-east-2" describe-db-instances --db-instance-identifier m5-image-gallery-db | jq -r '.DBInstances' | jq -r '.[0].Endpoint.Address')
HOST="${CMD}"
echo $HOST:5432:*:postgres:$ADMINPASS > /home/ec2-user/.pgpass
chmod go-rwx /home/ec2-user/.pgpass
psql -c "create user image_gallery login password '$PASS';" -h $HOST -U postgres
psql -c "grant image_gallery to postgres;" -h $HOST -U postgres
psql -c "create database image_gallery owner image_gallery;" -h $HOST -U postgres
echo $HOST:5432:*:image_gallery:$PASS > /home/ec2-user/.pgpass
psql -c "create table users (username varchar(100) not null primary key, password varchar(100), fullname varchar(200));" -h $HOST -U image_gallery
rm -rf /home/ec2-user/.pgpass