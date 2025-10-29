

CREATE DATABASE db1410_updateMerge
GO

USE db1410_updateMerge
GO

CREATE TABLE clientes (
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	total_pedidos DECIMAL(10,2) DEFAULT 0.00,
	status_cliente VARCHAR(50) DEFAULT 'Ativo'
	);

CREATE TABLE pedidos(
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor_pedido DECIMAL (10,2),
	data_pedido DATETIME,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
	);

INSERT INTO clientes
(cliente_id, nome_cliente)
VALUES
	(1, 'Caio'),
	(2, 'Rodrigo'),
	(3, 'Rafael'),
	(4, 'Gustavo');

INSERT INTO pedidos 
	(pedido_id, cliente_id, valor_pedido, data_pedido)
VALUES
	(1, 1, 100.00, '2025-01-01'),
	(2, 1, 150.00, '2025-01-02'),
	(3, 2, 200.00, '2025-01-03'),
	(4, 3, 250.00, '2025-01-04'),
	(5, 3, 300.00, '2025-01-05');

/*
A ideia é comparar os dados dessa tabela com a tabela de pedidos atualizando os
pedidos existentes, inserindo novos pedidos e excluindo pedidos que não são
mais necessarios.
*/

CREATE TABLE novos_pedidos(
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor_pedido DECIMAL (10,2),
	data_pedido DATETIME
	);
INSERT INTO novos_pedidos
(pedido_id, cliente_id, valor_pedido, data_pedido)
VALUES
(2, 1, 160.00,'2025-01-01'), --- Atualizando um pedido existente
(6, 2, 450.00,'2025-01-01'), --- novo
(7, 3, 500.00,'2025-01-10') --- novo

-- usaremos o MERGE para sincronizar a tabela de pedidos com a tabela de novos pedidos

MERGE INTO pedidos AS TARGET
USING novos_pedidos AS source
ON TARGET.pedido_id = source.pedido_id

-- Quando houver a correspondencia de pedidos, fazer UPDATE
WHEN MATCHED THEN
	UPDATE SET
	TARGET.valor_pedido = source.valor_pedido,
	TARGET.data_pedido = source.data_pedido
-- Quando não houver a correspondencia de pedidos, fazer o INSERT
WHEN NOT MATCHED BY TARGET THEN
INSERT
(pedido_id, cliente_id, valor_pedido, data_pedido)
VALUES
(source.pedido_id, source.cliente_id, source.valor_pedido, source.data_pedido)

WHEN NOT MATCHED BY source THEN
	DELETE;

--- Verificação----
SELECT * FROM pedidos