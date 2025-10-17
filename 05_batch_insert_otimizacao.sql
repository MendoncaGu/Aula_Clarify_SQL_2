

/*
Este script demonstra como realizar inserções em lote
utilizando as transações.
Ou seja, inserir um grande volume de dados de forma
eficiente dividindo em pequenos lotes
('batches' ou 'chunks')
*/

USE db1410_empresaMuitoLegal
GO

DROP TABLE IF EXISTS vendas;
CREATE TABLE vendas (
	vendas_id INT IDENTITY (1,1) PRIMARY KEY,
	cliente_id INT,
	produto_id INT,
	quantidade INT,
	valor_total DECIMAL (10,2),
	data_venda DATETIME
);

-- Variaveis para o controle de lotes
DECLARE @batch_size INT = 1000;
DECLARE @total_registros INT = 10000;
DECLARE @contador INT = 0;

BEGIN TRY
-- tenta executar essa transação 
	WHILE @contador < @total_registros
	BEGIN
		BEGIN TRANSACTION 
			INSERT INTO vendas (
			cliente_id,
			produto_id,
			quantidade,
			valor_total,
			data_venda
			)
			SELECT
			-- Gerando um cliente_id aleatorio entre 1 e 1000
			ABS(CHECKSUM(NEWID())) % 1000 + 1,
			-- Gerando um produto_id aleatorio entre 1 e 100
			ABS(CHECKSUM(NEWID())) % 100 + 1,
			-- Gerando uma quantidade aleatoria entre 1 e 10
			ABS(CHECKSUM(NEWID())) % 10 + 1,
			-- Gerando um valor total aleatorio entre 1 e 1000
			(ABS(CHECKSUM(NEWID())) % 1000 + 1) *10,
			-- data da venda será a data e hora atual
			GETDATE()
			FROM master.dbo.spt_values t1
			CROSS JOIN master.dbo.spt_values t2
			WHERE t1.type = 'p' AND t2.type = 'p'
			ORDER BY NEWID()
			
			-- Atualizar o contador de registros inseridos 
			OFFSET @contador ROWS FETCH NEXT @batch_size ROWS ONLY;
			-- Atualizar o contador de registros inseridos
			SET @contador = @contador +@batch_size;
		-- confirmando a transação e commitando
		COMMIT TRANSACTION

		--exibir uma mensagem de progresso
		PRINT 'Lote: ' +CAST(@contador / @batch_size AS VARCHAR) + 'Inseridos com sucesso!'
	END

END TRY
BEGIN CATCH
-- Casso ocorra algum erro realizamos um rollback da transação
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
		PRINT 'Erro: ' + ERROR_MESSAGE();
END CATCH

SELECT COUNT(*) AS total_vendas FROM vendas
SELECT * FROM vendas