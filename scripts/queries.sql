-- -- -- -- -- -- -- SQL

-- 1) Alterando coluna e depois alterando de volta
ALTER TABLE pessoa RENAME COLUMN descricao TO description;
ALTER TABLE pessoa RENAME COLUMN description TO descricao;

-- 2) novo indexador do corretor
CREATE INDEX idx_corretor
ON corretor(creci);

-- 3 & 5) Inserindo linha em pessoa e logo em seguida deletando-a
INSERT INTO pessoa (cpf, nome, descricao, email, ranking)
VALUES ('111.671.330-85', 'Senhor Ubaldo', 'platea dictumst morbi vestibulum vselit is diamjusto nec te', 'ubaldo@gmail.com', 1);
DELETE from pessoa WHERE nome = 'Senhor Ubaldo';

-- 4) dia 27 será um feriado, então todas as visitas desse dia serão adiadas para o dia seguinte às 11h
UPDATE agendar_visita
SET data = (TO_DATE('2022-03-28 11:00', 'yyyy-mm-dd hh24:mi'))
WHERE EXTRACT(DAY FROM data) = '27';

-- 6) consultar as propostas que foram bem sucedidas na plataforma
SELECT AI.tipo_anuncio, AI.tipo_imovel, AI.descricao
FROM proposta P, anuncio_info AI
WHERE P.status = 'Aceita';

-- 7) Seleciona pessoas com os rankings entre 2 e 5 (2 <= x <= 5)
SELECT * from pessoa WHERE ranking BETWEEN 2 and 5;

-- 8) consultar os usuários que residem em São Paulo ou Minas Gerais
SELECT P.nome, E.estado
FROM endereco E, pessoa P
WHERE E.estado in ('Sao Paulo', 'Minas Gerais') AND E.cpf_pessoa = P.cpf;

-- 9) Selecina pessoas onde o nome possui as letras 'ch' no meio
SELECT * from pessoa WHERE nome LIKE '%ch%';

-- 10) Selecionar os usuários avaliados na plataforma
SELECT nome, descricao
FROM pessoa
WHERE avaliacao IS NOT NULL;

-- 11) Seleciona o nome do corretor e cliente onde eles possuem o mesmo ranking
SELECT corretor.nome, cliente.nome FROM corretor INNER JOIN cliente ON cliente.ranking = corretor.ranking;

-- 12) consultar o anúncio mais caro, exibindo seu ID e o anunciante (CPF)
SELECT id_anuncio, A.cpf_pessoa
FROM anuncio_info, anuncio A
WHERE valor IN (SELECT MAX(valor) FROM anuncio_info) AND id_anuncio = A.id;

-- 13 & 17) Seleciona as linhas da tabela pessoa onde a pessoa pussui o menor ranking // subconsulta com operador relacional
SELECT * from pessoa WHERE pessoa.ranking = (SELECT MIN (ranking) AS min_ranking FROM pessoa);

-- 14) consultar a média de avaliação dos usuários da plataforma
SELECT AVG(avaliacao) Media_Avaliacao_Usuarios
FROM avaliar;

-- 15) Retorna a contagem de corretores onde o ranking é maior ou igual a 5
SELECT COUNT (nome) FROM corretor WHERE corretor.ranking >= 5;

-- 16) consultar todos os corretores e os corretores associados (se existir)
SELECT corretor.nome AS Corretor, gerente.nome AS Gerente
FROM corretor
FULL OUTER JOIN gerente ON corretor.cpf_comitente = gerente.cpf_gerente
ORDER BY corretor.nome;

-- 18) consultar os usuários do banco identificado por 122 para comunicar sobre atraso de recibos 
SELECT P.nome, P.email
FROM pessoa P
WHERE P.cpf IN (SELECT cpf_pessoa FROM dado_bancario WHERE banco = '122');

-- 19) Retorna os dados do cliente para os clientes que possuem qualquer anúncio
-- *corretores não possuem anúncios (povoar depois)
SELECT * from cliente WHERE cpf_cliente = ANY (SELECT cpf_pessoa from anuncio);

-- 20) Seleciona o nome, ranking e cpf de pessoa onde o ranking é menor que todos os rankings
-- iguais a 3
SELECT nome, ranking, cpf FROM pessoa WHERE ranking < ALL 
(SELECT ranking FROM pessoa WHERE pessoa.ranking = 3);

-- 21) Seleciona o nome, creci e ranking do corretor e ordena as linhas pelo ranking
SELECT nome, creci, ranking FROM corretor ORDER BY ranking;

-- 22 && 23) Seleciona as cidades da tabela indereço onde se elas possuirem um numero maior ou 
-- igual a 8 de ocorrências
SELECT cidade from endereco GROUP BY cidade HAVING COUNT(cidade) >= 8;

-- 24) Faz a união de todos os clientes e corretores que residem no estado de Pernambuco e a organiza 
-- numa tabela com seus respectivos nomes e rankings
SELECT nome, ranking from cliente WHERE cpf_cliente IN (SELECT cpf_pessoa from endereco WHERE estado = 'Pernambuco') UNION
SELECT nome, ranking from corretor where cpf_corretor IN (SELECT cpf_pessoa from endereco WHERE estado = 'Pernambuco');

-- 25) Cria uma view e seleciona todos os clientes que residem em Paulista
DROP VIEW "Clientes de Paulista";
CREATE VIEW "Clientes de Paulista" AS SELECT * from cliente WHERE cpf_cliente IN 
(SELECT cpf_pessoa FROM endereco WHERE cidade = 'Paulista');
Select * from "Clientes de Paulista";

-- 26) Dando permissão publica para todas as operações na view Clientes de Pauliusta 
-- e depois revogando-a.
GRANT ALL ON "Clientes de Paulista" TO public;
REVOKE ALL ON "Clientes de Paulista" TO public;


-- -- -- -- -- -- -- PL

-- 1 && 6 && 7 && 15) 4) Procedure que rastreia a pessoa pelo cpf dado na entrada.
-- A procedure cria primeiramente um registro e só então faz a busca.
CREATE OR REPLACE PROCEDURE track_pessoa_by_cpf(
input_cpf IN pessoa.cpf%TYPE
) IS
pessoa_reg pessoa%rowtype;
BEGIN
    SELECT *
    INTO pessoa_reg
    FROM pessoa
    WHERE pessoa.cpf = input_cpf;
    
    DBMS_OUTPUT.PUT_LINE ('Nome: ' || pessoa_reg.nome);
    DBMS_OUTPUT.PUT_LINE ('CPF: ' || pessoa_reg.cpf);
EXCEPTION
    WHEN no_data_found THEN
    DBMS_OUTPUT.PUT_LINE ('CPF não encontrado no banco de dados');
END;
-- TESTANDO A PROCEDURE ACIMA
EXECUTE track_pessoa_by_cpf('643.188.210-56');

-- 2) Criando tabela com TABLE para armazenar as visitas agendadas para o mês atual
CREATE OR REPLACE TYPE tp_visita AS OBJECT(
    id_anuncio NUMBER,
    data DATE
);

CREATE TABLE tb_visita_ultimo_mes OF tp_visita (
    id_anuncio PRIMARY KEY
);

DECLARE
idx NUMBER := 0;
BEGIN
    FOR rec IN (SELECT id_anuncio, data FROM agendar_visita WHERE EXTRACT(MONTH FROM data) = EXTRACT(MONTH FROM sysdate)) LOOP
        INSERT INTO tb_visita_ultimo_mes VALUES(rec.id_anuncio, rec.data);
    END LOOP;
END;

-- 3) Testando a função com um bloco anônimo
DECLARE contagem_prop NUMBER;
BEGIN
    contagem_prop := num_proposta(TO_DATE('2022-03-21 08:40', 'yyyy-mm-dd hh24:mi'));
    DBMS_OUTPUT.PUT_LINE('Número de propostas feitas na data inserida: ' || contagem_prop);
END;

-- 5) e 8) Consultar o número de telefones registrados em PE e PB
CREATE OR REPLACE FUNCTION compareStr (value IN VARCHAR2, pattern IN VARCHAR2)
RETURN BOOLEAN IS 
BEGIN 
   IF value LIKE pattern THEN
        RETURN TRUE;
   ELSE 
      RETURN FALSE;
   END IF; 
END;

DECLARE
    num_paraiba NUMBER:= 0;
    num_pernambuco NUMBER := 0;
BEGIN
    FOR telefone IN (SELECT numero FROM telefone_pessoa UNION SELECT numero FROM telefone_gerente)
    LOOP
        IF compareStr(telefone.numero, '(83)%') THEN
            num_paraiba := num_paraiba +1;
        ELSIF compareStr(telefone.numero, '(81)%') THEN
            num_pernambuco := num_pernambuco +1;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('Números totais da paraíba: ' || num_paraiba);
    DBMS_OUTPUT.PUT_LINE ('Números totais de pernambuco: ' || num_pernambuco);
END;

-- 5 && 13) Criando uma função que conta o número de propostas feitas em uma certa data inserida
-- Descobrir depois como reduzir a precisão da data na consulta
CREATE OR REPLACE FUNCTION num_proposta 
(
    data_propostas IN date
) RETURN NUMBER
AS 
    num_propostas number := 0;
BEGIN
    SELECT COUNT(*) INTO num_propostas FROM proposta 
    WHERE data_propostas = data_proposta;
    RETURN num_propostas;
END num_proposta;

-- 19) gatilho par
CREATE TYPE Media_Avaliado IS RECORD (
    cpf_avaliado VARCHAR2(14),
    media NUMBER,
    CONSTRAINT pessoa_cpf_ck CHECK (cpf LIKE ('___.___.___-__'))
);

-- PACKAGES
-- 17) Criando um package com duas procedures simples já feitas acima

CREATE OR REPLACE PACKAGE av4_package
AS

PROCEDURE track_pessoa_by_cpf
(
input_cpf IN pessoa.cpf%TYPE
);


PROCEDURE add_pessoa 
(
novo_cpf IN VARCHAR2, 
novo_nome IN VARCHAR2, 
novo_email IN VARCHAR2,
nova_descricao IN VARCHAR2, 
novo_ranking IN NUMBER, 
nova_avaliacao IN NUMBER
);

END av4_package;

-- 18) Descrição do body do package criado
CREATE OR REPLACE PACKAGE BODY av4_package
AS

PROCEDURE track_pessoa_by_cpf(
input_cpf IN pessoa.cpf%TYPE
) IS
pessoa_reg pessoa%rowtype;
BEGIN
    SELECT *
    INTO pessoa_reg
    FROM pessoa
    WHERE pessoa.cpf = input_cpf;
    
    DBMS_OUTPUT.PUT_LINE ('Nome: ' || pessoa_reg.nome);
    DBMS_OUTPUT.PUT_LINE ('CPF: ' || pessoa_reg.cpf);
EXCEPTION
    WHEN no_data_found THEN
    DBMS_OUTPUT.PUT_LINE ('CPF não encontrado no banco de dados');
END;

PROCEDURE add_pessoa (novo_cpf IN VARCHAR2, novo_nome IN VARCHAR2, novo_email IN VARCHAR2,
nova_descricao IN VARCHAR2, novo_ranking IN NUMBER, nova_avaliacao IN NUMBER)
AS
BEGIN
    INSERT INTO pessoa(cpf, nome, email, descricao, ranking, avaliacao) VALUES
    (novo_cpf, novo_nome, novo_email, nova_descricao, novo_ranking, nova_avaliacao);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE ('Dados inseridos com sucesso');
END;

END av4_package;

-- Testando as procedures do package criado
EXECUTE av4_package.add_pessoa ('700.573.614-10', 'Ubaldius', 'duml@cin.ufpe.br', 'lorem ipsum dolor sic amet', 1, 7)
EXECUTE av4_package.track_pessoa_by_cpf('700.573.614-10');

-- 19) gatilho que proíbe a dimuinção do valor de pagamento da proposta
CREATE OR REPLACE TRIGGER checar_proposta
BEFORE UPDATE ON proposta
FOR EACH ROW
BEGIN
    IF (:new.valor_pagamento < :old.valor_pagamento) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Não é permitido realizar alterar o valor de pagamento para um valor inferior.');
    END IF;
END checar_proposta;
/

UPDATE proposta
SET valor_pagamento = 1
WHERE id_anuncio = 2;

-- 20) gatilho que proíbe agendamento de visitas no final de semana
CREATE OR REPLACE TRIGGER checar_visita
BEFORE INSERT OR UPDATE ON agendar_visita
BEGIN
    IF (TO_CHAR(SYSDATE, 'DY') in ('SAT', 'SUN')) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Não é permitido agendar visitas no fim de semana.');
    END IF;
END checar_visita;
/

DECLARE  
i NUMBER := SELECT COUNT(*) FROM anuncio;
BEGIN  
    LOOP EXIT WHEN i ;  
        DBMS_OUTPUT.PUT_LINE(i);  
        i := i+1; 
    END LOOP;  
END;

-- 11) checar o nome dos anunciantes
DECLARE
i NUMBER;
cpf_dono pessoa.cpf%TYPE;
nome_dono pessoa.nome%TYPE;
BEGIN
    SELECT COUNT(*) INTO i
    FROM anuncio;
    
    WHILE (i > 0) LOOP
        SELECT cpf_pessoa INTO cpf_dono
        FROM anuncio
        WHERE id = i;
        
        SELECT nome INTO nome_dono
        FROM pessoa
        WHERE cpf = cpf_dono;
    
        DBMS_OUTPUT.PUT_LINE (nome_dono);
        i := i - 1;
    END LOOP;
END;

-- 12) consultar os bairros e cidades dos alunos
DECLARE
num NUMBER;
cidade_v endereco_anuncio.cidade%TYPE;
bairro_v endereco_anuncio.bairro%TYPE;
BEGIN
    SELECT COUNT(*) INTO num
    FROM endereco_anuncio;
    
    FOR i IN 1..num LOOP
        SELECT cidade, bairro INTO cidade_v, bairro_v
        FROM endereco_anuncio
        WHERE id_anuncio = i;
        
        DBMS_OUTPUT.PUT_LINE('Anúncio no bairro ' ||bairro_v || ' na cidado ' || cidade_v);
    END LOOP;
END;


-- 10), 14), 13) Consultar o local de residência dos gerentes

DECLARE
    nome_v gerente.nome%TYPE;
    cpf_v gerente.cpf_gerente%TYPE;
    cidade_v endereco_gerente.cidade%TYPE;

    CURSOR gerente_nome IS
        SELECT nome, cpf_gerente
        FROM gerente;
BEGIN
    OPEN gerente_nome;
        LOOP
            FETCH gerente_nome INTO nome_v, cpf_v;
            
            EXIT WHEN gerente_nome%NOTFOUND;

            SELECT cidade INTO cidade_v
            FROM endereco_gerente
            WHERE cpf_gerente = cpf_v;

            DBMS_OUTPUT.PUT_LINE('O gerente ' || nome_v || ' reside em ' || cidade_v || '!');
        END LOOP;
    CLOSE gerente_nome;
END;
/

-- 9) Checar as agências dos bancos parceiros (Santander e Bradesco)
DECLARE
    banco_cod dado_bancario.banco%TYPE;
    agencia_v dado_bancario.agencia%TYPE;
    K BOOLEAN;

    CURSOR identificar_banco IS
        SELECT banco, agencia
        FROM dado_bancario;
BEGIN
    OPEN identificar_banco;
        LOOP
            FETCH identificar_banco
            INTO banco_cod, agencia_v;
            
            EXIT WHEN identificar_banco%NOTFOUND;

            CASE banco_cod
                WHEN 121 THEN DBMS_OUTPUT.PUT_LINE('É do Santander! Agência ' || agencia_v || '.');
                WHEN 122 THEN DBMS_OUTPUT.PUT_LINE('É da Bradesco! Agência ' || agencia_v || '.');
                ELSE DBMS_OUTPUT.PUT_LINE('Não é nosso parceiro.');
            END CASE;

        END LOOP;
    CLOSE identificar_banco;
END;
/