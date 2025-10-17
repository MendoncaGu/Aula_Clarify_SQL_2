

CREATE DATABASE db1410_fallscompany;
GO

USE db1410_fallscompany;
GO

DROP TABLE IF EXISTS clientes
CREATE TABLE clientes(
	cliente_id INT PRIMARY KEY IDENTITY(1,1),
	nome_cliente VARCHAR(100),
	email_cliente VARCHAR(100)
);

DROP TABLE IF EXISTS pedidos
CREATE TABLE pedidos(
	pedido_id INT PRIMARY KEY IDENTITY(1,1),
	cliente_id INT,
	data_pedido DATETIME,
	valor_total DECIMAL (10,2),
	FOREIGN KEY (cliente_id) REFERENCES clientes (cliente_id)
	ON DELETE CASCADE
	);

INSERT INTO clientes
(nome_cliente, email_cliente)
VALUES
('Fulano','fulano@gmail'),
('Sicrano','sicrano@gmail'),
('Beltrano','beltrano@gmail'),
('Jubileu','jubileu@hotmail');

INSERT INTO pedidos
(cliente_id,data_pedido, valor_total)
VALUES
(1,'2025-01-01',100.00),
(2,'2025-01-02',150.00),
(3,'2025-01-03',400.00),
(4,'2025-01-04',175.00);

SELECT * FROM clientes
SELECT * FROM pedidos

BEGIN TRY
	BEGIN TRANSACTION
		DELETE FROM clientes WHERE cliente_id = 1; -- O erro tinha dado aqui bestão...
		-- esqueceu de mudar a tabela do outro arquivo
	COMMIT TRANSACTION;
	PRINT 'Exclusoes foram realizadas com sucessos'
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION;
	END
	PRINT 'Erro duarnte a exclusão: ' + ERROR_MESSAGE();
END CATCH;
