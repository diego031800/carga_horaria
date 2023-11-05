
DROP table IF EXISTS envio_carga_director;
create table envio_carga_director(
chec_id bigint primary key auto_increment,
sem_id int,
sec_id int,
prg_id int,
chec_doc_nombre varchar(180),
chec_doc_correo varchar(180),
chec_envio bit,
chec_envio_fecha datetime,
chec_envio_error varchar(180),
usuario int(11),
fechahora datetime,
dispositivo varchar(100)
);