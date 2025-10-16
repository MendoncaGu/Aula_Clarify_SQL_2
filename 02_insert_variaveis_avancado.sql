

USE db1410_vendas;
GO

-- insere a coluna de valor total que falta na tabela de vendas
ALTER TABLE vendas
ADD valor_total DECIMAL (10,2);

/*
A logica aqui é realizar multiplas inserções 
de forma controlada, usando variavis
para armazenar os dados

*/
-- iniciar a transação--
BEGIN TRANSACTION;


DECLARE @cliente_id INT = 1; --Cliente para o pedido (caio)
DECLARE @produto_id INT = 2; --Produto Comprado (Notebook)
DECLARE @quantidade INT = 3; --Quantidade comprada (3 Unidades)
DECLARE @valor_total DECIMAL (10,2); -- Valor do total do pedido
DECLARE @data_venda DATETIME = GETDATE(); -- Data Atual
DECLARE @status_transacao VARCHAR(50); --

-- calcular o valor da venda
SELECT @valor_total = p.preco * @quantidade
FROM produtos p 
WHERE p.produto_id = @produto_id;

-- validação para garantir que a quantidade seja vendida
IF @quantidade <= 0
BEGIN
	SET @status_transacao = 'Falha: Quantidade invalida';
	ROLLBACK TRANSACTION; -- Reverte a transação caso a quantidade seja invalida
	PRINT @status_transacao;
	RETURN;
END

-- Inserindo outra venda usando nosso novo 'metodo'
INSERT INTO vendas
	(cliente_id, produto_id, quantidade,valor_total,data_venda)
VALUES
	(@cliente_id, @produto_id, @quantidade, @valor_total, @data_venda)

IF @@ERROR <> 0
BEGIN
	SET @status_transacao = 'Falha: Erro na inserção da venda';
	ROLLBACK TRANSACTION;
	PRINT @status_transacao;
	RETURN;
END

-- Se todas as inserções forem ok, confirma a transacao
SET @status_transacao = 'Sucesso: Vendas inseridas com sucesso!'

COMMIT TRANSACTION;

SELECT * FROM vendas

/*=====================================================
					Caso erro

=====================================================*/
BEGIN TRANSACTION;


DECLARE @cliente_id INT = 1; --Cliente para o pedido (caio)
DECLARE @produto_id INT = 2; --Produto Comprado (Notebook)
DECLARE @quantidade INT = 3; --Quantidade comprada (3 Unidades)
DECLARE @valor_total DECIMAL (10,2); -- Valor do total do pedido
DECLARE @data_venda DATETIME = GETDATE(); -- Data Atual
DECLARE @status_transacao VARCHAR(50); --

SET @quantidade = -1;
SET @cliente_id = 1;
SET @produto_id = 1;
SET @data_venda = GETDATE();

SELECT @valor_total = p.preco * @quantidade
FROM produtos p 
WHERE p.produto_id = @produto_id;

IF @quantidade <= 0
BEGIN
	SET @status_transacao = 'Falha: Quantidade invalida';
	ROLLBACK TRANSACTION; -- Reverte a transação caso a quantidade seja invalida
	PRINT @status_transacao;
	RETURN;
END

INSERT INTO vendas
	(cliente_id, produto_id, quantidade,valor_total,data_venda)
VALUES
	(@cliente_id, @produto_id, @quantidade, @valor_total, @data_venda)

COMMIT TRANSACTION