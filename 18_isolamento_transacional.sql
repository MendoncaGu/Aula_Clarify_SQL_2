

CREATE DATABASE db1410_isolamento;
GO

USE db1410_isolamento;
GO

CREATE TABLE produtos(
	produto_id INT PRIMARY KEY,
	nome_produto VARCHAR(100),
	quantidade INT,
	preco DECIMAL (10,2)
	);

INSERT INTO produtos
	(produto_id, nome_produto,quantidade,preco)
VALUES
(1, 'camiseta', 100, 50.00),
(2, 'cal�a', 50, 120.00),
(3, 'tenis', 75, 300.00),
(4, 'meia', 35, 10.00),
(5, 'blusa', 10, 140.00);

	SELECT * FROM produtos;

/*
Exemplo de controle de isolamento transacional para observar o comportamento
vamos realizar algumas opera��es

A - Usar diferentes tipos de isolamento
B - Simular transa��es recorrentes

Vamos come�ar com uma transa��o com nivel de isolamento READ UNCOMMITTED
*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
	--Vamos ler os dados da tabela de produtos permitindo dados n�o confirmados

	PRINT 'Transa��o 01 (READ UNCOMMITTED)';
	SELECT * FROM produtos;

	-- alterando a quantidade sem confirmar a transa��o
	UPDATE produtos 
	SET quantidade = quantidade - 5
	WHERE produto_id = 1;

	--simulando algum processamento
	WAITFOR DELAY '00:00:10';

COMMIT TRANSACTION;

-- agora vamos realizar uma transa��o com nivel de isolamento
-- "SERIALIZIBLE"

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
	--Vamos ler e bloquear a linha de produto_id 1
	PRINT 'Transa��o 02 (SERIALIZABLE)';
	SELECT * FROM produtos 
	WHERE produto_id = 1;
	WAITFOR DELAY '00:00:10';
COMMIT TRANSACTION;

SELECT * FROM produtos