

CREATE DATABASE db1410_eficiente;
GO

USE db1410_eficiente;
GO

DROP TABLE IF EXISTS clientes
CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	data_cadastro DATETIME
	);

DROP TABLE IF EXISTS pedidos
CREATE TABLE pedidos(
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	data_pedido DATETIME,
	valor_total DECIMAL (10,2)
	);

INSERT INTO clientes (cliente_id, nome_cliente, data_cadastro)
SELECT TOP 100000
/*
gerar o valor sequencial de 1 até o infinito por cada linha
O over exige ordenar, um truque do instrutor para
dizer que não quero em ordem pre-definida
*/
-- Cliente_id
ROW_NUMBER() OVER( ORDER BY (SELECT NULL)),
-- Nome_cliente
'Cliente: ' + CAST(ROW_NUMBER() OVER( ORDER BY (SELECT NULL)) AS VARCHAR (10)),
-- data_cadastro da data de hoje subtraindo do dia o numero da linha
DATEADD(DAY, -(ROW_NUMBER() OVER( ORDER BY (SELECT NULL)) % 3650), GETDATE())

FROM master.dbo.spt_values a , master.dbo.spt_values b;
--EXECUTADO DAQUI--

--Truncate remove todas as linhas da tabela, mais eficiente que o delete pois não registra a remoção das linhas
TRUNCATE TABLE clientes;

