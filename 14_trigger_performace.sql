

IF NOT EXISTS (
	SELECT 1 FROM sys.databases 
	WHERE name = 'db1410_triggers'
	)
	CREATE DATABASE db1410_triggers;
GO

USE db1410_triggers;
GO

IF OBJECT_ID('vendas', 'U') IS NOT NULL
	DROP TABLE vendas;
GO

IF OBJECT_ID('auditoria_vendas', 'U') IS NOT NULL
	DROP TABLE auditoria_vendas;
GO

IF OBJECT_ID('trg_auditoria_insercao', 'TR') IS NOT NULL
	DROP TRIGGER trg_auditoria_insercao;
GO

IF OBJECT_ID('trg_auditoria_exclusao', 'TR') IS NOT NULL
	DROP TRIGGER trg_auditoria_exclusao;
GO

CREATE TABLE vendas (
	id_venda INT PRIMARY KEY,
	valor_venda DECIMAL(18,2),
	data_venda DATE,
	status NVARCHAR(20) DEFAULT 'Ativa'
	);
GO

CREATE TABLE auditoria_vendas(
	id_auditoria INT IDENTITY (1,1) PRIMARY KEY,
	id_venda INT,
	operacao NVARCHAR(10),
	data_operacao DATETIME,
	usuario VARCHAR (50)
	);
GO

------------ TRIGGERS --------------------

CREATE TRIGGER trg_auditoria_insercao
ON vendas
AFTER INSERT
AS
	BEGIN
		INSERT INTO auditoria_vendas
		(id_venda, operacao, data_operacao, usuario)
		SELECT id_venda, 'INSERT', GETDATE(), SYSTEM_USER 
		FROM inserted;
		PRINT 'Operação de inserir realizada com sucesso!';

	END;
GO

CREATE TRIGGER trg_auditoria_exclusao
	ON vendas
	AFTER DELETE
	AS
		BEGIN
			INSERT INTO auditoria_vendas
			(id_venda, operacao, data_operacao, usuario)
			SELECT id_venda, 'DELETE', GETDATE(), SYSTEM_USER
			FROM deleted
			PRINT 'Operação de excluir realizada com sucesso!';
		END;
	GO

CREATE TRIGGER trg_auditoriaAtualizacao
ON vendas
AFTER UPDATE
AS
	BEGIN
		INSERT INTO auditoria_vendas
		(id_venda, operacao, data_operacao, usuario)
		SELECT id_venda, 'UPDATE', GETDATE(), SYSTEM_USER 
		FROM inserted
		WHERE EXISTS(
			SELECT 1
			FROM deleted
			WHERE deleted.id_venda = inserted.id_venda
			AND (
				deleted.valor_venda <> inserted.valor_venda
				OR
				deleted.status <> inserted.status
			)
		);
	END;
GO

------ Testar Inserção e Exclusão
INSERT INTO vendas (id_venda, valor_venda, data_venda)
VALUES 
(1, 150.00, '2025-01-01'),
(2, 200.00, '2025-01-02'),
(3, 500.00, '2025-01-03');

DELETE FROM vendas WHERE id_venda = 1;

UPDATE vendas SET valor_venda = 600 WHERE id_venda = 2

------- Exibir resultados
SELECT * FROM vendas;
SELECT * FROM auditoria_vendas;

