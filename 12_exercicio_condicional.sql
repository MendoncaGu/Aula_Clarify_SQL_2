

USE db1410_alter_condicional
GO

IF OBJECT_ID('clientes', 'U') IS NULL
	BEGIN
		PRINT 'A Tabela não existe! Criando tabela...'
		CREATE TABLE clientes (
		cliente_id INT PRIMARY KEY,
		nome_cliente VARCHAR(100),
		data_cadastro DATETIME
		);
		INSERT INTO clientes
				(cliente_id, nome_cliente, data_cadastro)
				VALUES
				(1, 'Caio', '2025-01-01'),
				(2, 'Gustavo', '2025-01-02'),
				(3, 'Rodrigo', '2025-01-03'),
				(4, 'Rafael', '2025-01-04');
	END
ELSE
	BEGIN
		PRINT 'A tabela já existe! Nemhuma ação feita'
	END

SELECT * FROM clientes
DROP TABLE IF EXISTS clientes