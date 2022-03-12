# Test
kubectl exec -it pod/trino-cli -- trino --server trino:8080 --catalog hive 

#create schema kubedata;

use kubedata;

CREATE TABLE orders (
  orderkey bigint,
  orderstatus varchar,
  totalprice double,
  orderdate date
)
WITH (format = 'ORC');

insert into orders(orderkey,orderstatus,totalprice,orderdate) values(1,'active',2.2,now());

select * from orders;