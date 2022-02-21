#!/bin/bash
docker pull postgres
docker run --name postgres_01 -p 5432:5432 -e POSTGRES_USER=test_sde -e POSTGRES_PASSWORD=@sde_password012 -e POSTGRES_DB=demo -d -v "C:\Users\krist\test_git_repo\sde_test_db\sql\init_db":/docker-entrypoint-initdb.d postgres
#docker cp "C:/Users/krist/test_git_repo/sde_test_db/sql/init_db/demo.sql" postgres_01:/docker-entrypoint-initdb.d/demo.sql
#docker exec -u test_sde postgres_01 psql demo test_sde -f docker-entrypoint-initdb.d/demo.sql
