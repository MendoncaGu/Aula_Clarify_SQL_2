

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

SELECT @
