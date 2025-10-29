

IF NOT EXISTS (
	SELECT 1 FROM sys.databases 
	WHERE name = 'db1410_triggers'
	)
	CREATE DATABASE db1410_triggers;
GO

USE db1410_triggers;
GO

IF OBJECT_ID('Usuarios', 'U') IS NOT NULL
	DROP TABLE usuarios;
GO

IF OBJECT_ID('auditoria_usuarios', 'U') IS NOT NULL
	DROP TABLE auditoria_usuarios;
GO

IF OBJECT_ID('trg_auditoria_insercao', 'TR') IS NOT NULL
	DROP TRIGGER trg_auditoria_insercao;
GO

CREATE TABLE usuarios (
	id_usuario INT PRIMARY KEY,
	nome_usuario VARCHAR(100),
	email_usuario VARCHAR(50),
	data_cadastro DATE
	);
GO

CREATE TABLE auditoria_usuarios(
	id_auditoria INT IDENTITY (1,1) PRIMARY KEY,
	id_usuario INT,
	operacao NVARCHAR(10),
	data_operacao DATETIME,
	usuario VARCHAR (50)
	);
GO

-------- TRIGGEEEEEEEEERRRR -------
CREATE TRIGGER trg_auditoria_insercao
ON usuarios
AFTER INSERT
AS
	BEGIN
		INSERT INTO auditoria_usuarios
		(id_usuario, operacao, data_operacao, usuario)
		SELECT id_usuario, 'INSERT', GETDATE(), SYSTEM_USER 
		FROM inserted;
		PRINT 'Operação de inserir realizada com sucesso!';

	END;
GO

INSERT INTO usuarios(id_usuario, nome_usuario, email_usuario, data_cadastro)
VALUES 
(1,'Fulano', 'fulano@gmail.com', '2025-01-01'),
(2,'Beutrano', 'beutrano@gmail.com', '2025-01-02'),
(3,'Siclano', 'siclano@gmail.com', '2025-01-03');

------ Verificação -------
SELECT * FROM usuarios;
SELECT * FROM auditoria_usuarios;