

IF NOT EXISTS (
	SELECT 1 FROM sys.databases 
	WHERE name = 'db1410_triggers'
	)
	CREATE DATABASE db1410_triggers;
GO

USE db1410_triggers
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

----- EXECUTAR TUDO AMANHÃ------