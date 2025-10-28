-------------- Exercicio (que faremos juntos hehe) -----------------
USE db1410_alter_condicional
GO

-- Verifica se a tabela existe antes de tentar qualquer operação

IF OBJECT_ID('clientes', 'U') IS NOT NULL
	BEGIN
		PRINT 'A tabela [clientes] existe! Verificando a quantidade de dados...';
		
		DECLARE @num_dados INT;

		SELECT @num_dados =COUNT(*)
		FROM clientes
		WHERE nome_cliente IS NOT NULL;

		IF @num_dados = 0
			BEGIN
				INSERT INTO clientes
				(cliente_id, nome_cliente, data_cadastro)
				VALUES
				(1, 'Caio', '2025-01-01'),
				(2, 'Gustavo', '2025-01-02'),
				(3, 'Rodrigo', '2025-01-03'),
				(4, 'Rafael', '2025-01-04');
			PRINT 'Dados inseridos com sucesso!';
			END
		ELSE 
			BEGIN
				PRINT 'A tabela já possuí dados, nehuma inserção foi feita!';
			END
	END
ELSE
	BEGIN
		PRINT 'A tabela de [clientes] não existe, Nenhuma ação foi executada';
	END;

SELECT * FROM clientes