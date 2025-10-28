CREATE DATABASE db1410_subquery
GO

USE db1410_subquery
GO

CREATE TABLE clientes (
	cliente_id INT PRIMARY KEY,
	nome_cliente VARCHAR(100),
	total_pedidos DECIMAL(10,2),
	status_cliente VARCHAR(50) DEFAULT 'Ativo'
);
CREATE TABLE pedidos(
	pedido_id INT PRIMARY KEY,
	cliente_id INT,
	valor_pedido DECIMAL(10,2),
	data_pedido DATETIME,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);
--------------------JÁ EXECUTADO -------------------

-- Lembre-se, primeiro executamos o insert de CLIENTES, depois de PEDIDOS(foreing key)
INSERT INTO clientes
	(cliente_id, nome_cliente)
VALUES
	(10,'Caio'),
	(20,'Rodrigo'),
	(30,'Rafael'),
	(40,'Gustavo');

INSERT INTO pedidos
	(pedido_id, cliente_id, valor_pedido, data_pedido)
VALUES
	(1,1, 100.00,'2025-01-01'),
	(2,2, 150.00,'2025-01-01'),
	(3,1, 200.00,'2025-01-01'),
	(4,2, 250.00,'2025-01-01'),
	(5,1, 300.00,'2025-01-01'),
	(6,2, 350.00,'2025-01-01');

-- condição garantir para atualizar apenas clientes com pedidos
UPDATE clientes
-- Atualizar o compo de total_pedidos na tabela clientes
SET total_pedidos = (
	SELECT SUM(valor_pedido)
	FROM pedidos
	WHERE pedidos.cliente_id = clientes.cliente_id
)
-- essa é a condição que permite atualizar só clienets com pedidos
WHERE cliente_id IN (SELECT cliente_id FROM pedidos)
-- ver o resultado 
SELECT * FROM clientes
SELECT * FROM pedidos

-- Exemplo de Update com condição avançada

UPDATE clientes
SET status_cliente = 'Inativo'
WHERE total_pedidos < 100.00 OR total_pedidos IS NULL;

SELECT * FROM clientes
SELECT * FROM pedidos

UPDATE pedidos
SET valor_pedido = valor_pedido * 2
WHERE cliente_id = 3 AND data_pedido < '2024-12-12';

/*
	DESAFIO DO TRAVESÃO
Classificar clientes corretamente de acordo com seu volume de compras (total_pedidos) Ou seja, 
clientes que compraram mais de 500 são vips
clientes com pedidos maiores que 0 são ativos
caso contraro serão inativos
*/

UPDATE clientes
SET status_cliente = 'VIP'
WHERE total_pedidos > 500.00;

UPDATE clientes
SET status_cliente = 'Ativo'
WHERE total_pedidos > 0;

UPDATE clientes
SET status_cliente = 'Inativo'
WHERE total_pedidos < 0 OR total_pedidos IS NULL;

DECLARE @tier1 AS VARCHAR(50) = 'VIP';
DECLARE @tier2 AS VARCHAR(50) = 'Ativo';
DECLARE @tier3 AS VARCHAR(50) = 'Inativo';
-----Forma case-------

UPDATE clientes
SET status_cliente = 
	CASE
		WHEN total_pedidos >= 500 THEN @tier1
		WHEN total_pedidos > 0 THEN @tier2
		ELSE @tier3
	END

