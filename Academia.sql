create table alunos (
	id serial PRIMARY key,
	nome varchar(150) not null,
	email varchar(100) unique not null,
	cpf varchar(11) unique not null,
	telefone VARCHAR(15) not null,
	data_cadastro timestamp DEFAULT CURRENT_TIMESTAMP
);

create table planos (
	id serial primary key,
	nome varchar(50) unique not null,
	valor_mensal_base NUMERIC(10,2) not null check (valor_mensal_base > 0)
);

create table modalidades (
	id serial primary key,
	plano_id int REFERENCES planos(id),
	nome varchar(150) not null,
	sala varchar(100) not null,
	capacidade_maxima int not null check (capacidade_maxima > 0),
	disponivel boolean DEFAULT true
);

create table matriculas(
	id serial primary key,
	aluno_id int REFERENCES alunos(id),
	data_inicio timestamp DEFAULT current_timestamp,
	status varchar(50) default 'ativa' check(status in('ativa','cancelada','trancada'))
)

create table itens_matricula (
	id serial PRIMARY key,
	matricula_id int REFERENCES matriculas(id),
	modalidade_id int REFERENCES modalidades(id),
	duracao_meses int check (duracao_meses > 0) not null,
	valor_mensal_aplicado decimal(10,2) not null check (valor_mensal_aplicado > 0),
	taxa_adesao decimal(10,2) check (taxa_adesao >= 0) default 0.00
);


INSERT INTO planos (nome, valor_mensal_base) VALUES 
('VIP Premium', 220.00), 
('Fitness Standard', 140.00), 
('Basic Fit', 90.00);


INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima, disponivel) VALUES 
(1, 'Crossfit Pro', 'Arena 01', 15, TRUE),
(2, 'Pilates Avançado', 'Studio 02', 10, TRUE),
(3, 'Musculação Livre', 'Salão Principal', 50, TRUE);


INSERT INTO alunos (nome, email, cpf, telefone) VALUES 
('Carlos Silva', 'carlos@email.com', '11122233344', '11999990000'),
('Ana Lima', 'ana@email.com', '22233344455', '11988880000'),
('Beatriz Costa', 'bea@email.com', '33344455566', '11977770000');


INSERT INTO matriculas (aluno_id, status) VALUES 
(1, 'ativa'), 
(2, 'ativa'), 
(3, 'cancelada');

INSERT INTO itens_matricula (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) VALUES 
(5, 1, 6, 220.00, 50.00),
(2, 2, 3, 140.00, 30.00),
(3, 3, 12, 90.00, 0.00),
(4, 1, 1, 220.00, 50.00);

create view vw_modalidades_custo_estimado as
select 
	m.nome as modalidades,
	m.sala,
	p.nome as planos,
	round (p.valor_mensal_base * 1.10,2) as mensalidade_com_taxa
from modalidades m
join planos p on m.plano_id = p.id
order by mensalidade_com_taxa DESC

create View vw_matriculas_ativas as 
select 
	a.nome as alunos,
	a.cpf,
	m.nome as modalides,
	m.sala,
	im.duracao_meses as itens_matricula,
	mat.data_inicio
from matriculas mat
join alunos a on a.id = mat.aluno_id
JOIN itens_matricula im on im.matricula_id = mat.id
join modalidades m on m.id = im.modalidade_id
where mat.status = 'ativa'
