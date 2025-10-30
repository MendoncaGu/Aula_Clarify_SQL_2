

CREATE DATABASE db1410_plano_execucao;
GO

USE db1410_plano_execucao;
GO

CREATE TABLE clientes(
	id INT PRIMARY KEY,
	nome VARCHAR(100),
	cidade VARCHAR (100),
	endereco VARCHAR (100),
	uf VARCHAR (100)
	);

INSERT INTO clientes
	(id,nome,cidade,endereco,uf)
VALUES
	(1, 'Caio', 'S�o Paulo', 'Rua dos instrutores', 'SP'),
	(2, 'Rafael', 'Rio de Janeiro', 'Avenida dos Alunos', 'RJ'),
	(3, 'Caio', 'Florianopolis', 'Trevessa do Python', 'SC');

SELECT nome, endereco FROM clientes WHERE cidade = 'S�o Paulo';

-- Usando o 'CTRL + L' abrimos a execu��o do SMSS

SET  STATISTICS PROFILE ON;
SELECT nome, endereco FROM clientes WHERE cidade = 'S�o Paulo';
SET STATISTICS PROFILE OFF

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT nome, endereco FROM clientes WHERE cidade = 'S�o Paulo';
SET STATISTICS IO OFF;
SET STATISTICS TIME ON;