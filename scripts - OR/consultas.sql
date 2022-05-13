-- Consultando a porcentagem de avaliação do cliente com cpf = '146.463.678-97'
DECLARE
    cliente tp_cliente;
BEGIN
SELECT VALUE(C) INTO cliente FROM tb_cliente C WHERE C.cpf = '146.463.678-97';
cliente.porcent_avaliacao(cliente.avaliacao);
END;

-- Consultando o endereço do cliente com cpf = '146.463.678-97'
DECLARE
    cliente tp_cliente;
BEGIN
SELECT VALUE(C) INTO cliente FROM tb_cliente C WHERE C.cpf = '146.463.678-97';
cliente.display_address();
END;
/

-- Consultando as informações do cliente com cpf = '146.463.678-97'
DECLARE
    cliente tp_cliente;
BEGIN
SELECT VALUE(C) INTO cliente FROM tb_cliente C WHERE C.cpf = '146.463.678-97';
cliente.display_info();
END;

-- Consultando as informações do corretor com cpf = '149.221.550-31'
DECLARE
    corretor tp_corretor;
BEGIN
SELECT VALUE(C) INTO corretor FROM tb_corretor C WHERE C.cpf = '149.221.550-31';
corretor.display_info();
END;
/

SELECT cpf, nome, C.endereco.rua, creci FROM tb_corretor C;
SELECT cpf, nome, G.endereco.rua FROM tb_gerente G;
SELECT data, DEREF(PC.cliente).nome, (PC.corretor).nome, (PC.gerente).nome FROM tb_indicacao PC;
SELECT data, DEREF(PP.cliente).nome, id_anuncio, valor, status FROM tb_proposta PP;

-- Os clientes com avaliacao maior que a média devem ter prioridade na indicação de corretores
SELECT cpf, TC.endereco.rua, TC.endereco.cidade, TC.dados_bancarios.banco
FROM tb_cliente TC
WHERE avaliacao > (SELECT AVG(avaliacao) FROM tb_cliente);

-- Consultar os cliente cujo valor do anuncio são menores do que o valor máximo dos anúncios dos corretores
SELECT cpf, nome, A_CLI.valor
FROM tb_cliente TC, TABLE(TC.anuncios) A_CLI
WHERE A_CLI.valor < (SELECT MAX(A_CORR.valor)
                 FROM tb_corretor TC,
                 TABLE(TC.anuncios) A_CORR);

-- Calcular média dos valores dos imóveis
DECLARE
    media_cliente NUMBER;
    media_corretor NUMBER;
    media_final NUMBER;
BEGIN
    SELECT AVG(A.valor) INTO media_cliente FROM tb_cliente T_CLI, TABLE(T_CLI.anuncios) A;
    SELECT AVG(A.valor) INTO media_corretor FROM tb_corretor T_CORR, TABLE(T_CORR.anuncios) A;
    
    media_final := (media_corretor + media_cliente) / 2;
    DBMS_OUTPUT.PUT_LINE('A média dos valores de imóveis em nossa corretora é ' || media_final);
END;
/

-- VARRAY QUERY
-- Consultar os imóveis localizados no Recife
SELECT T_CLI.nome, A.endereco.rua AS RUA, A.endereco.bairro AS BAIRRO, T.*
FROM tb_cliente T_CLI, TABLE(T_CLI.anuncios) A, TABLE(T_CLI.telefone) T
WHERE A.endereco.cidade = 'Recife'
UNION
SELECT T_CORR.nome, A.endereco.rua, A.endereco.bairro, T.*
FROM tb_corretor T_CORR, TABLE(T_CORR.anuncios) A, TABLE(T_CORR.telefone) T
WHERE A.endereco.cidade = 'Recife';

-- Consultar de forma ordenada as propostas dos anúncios feitos pelo cliente com cpf '146.463.678-97'
SELECT status, valor
FROM tb_proposta
WHERE id_anuncio = (SELECT A.id_anuncio
                    FROM tb_cliente T_CLI, TABLE(T_CLI.anuncios) A
                    WHERE T_CLI.cpf = '146.463.678-97')
ORDER BY valor DESC;

--Consultar os valores ordenados das propostas revisadas pelo gerente
SELECT T_prop.id_anuncio, T_prop.revisor.nome AS gerente, T_prop.valor
FROM tb_proposta T_prop WHERE T_prop.revisor.nome IS NOT NULL ORDER BY valor;


-- Consultar valores de propostas que sejam menor que o valor do anuncio
SELECT TP.id_proposta, TP.cliente.nome, TP.valor AS valor_proposta, TCA.valor AS valor_anuncio 
FROM tb_proposta TP, tb_cliente TC, TABLE(TC.anuncios) TCA
WHERE TCA.id_anuncio = TP.id_anuncio AND TP.valor < (SELECT TCA.valor FROM tb_cliente TC, TABLE(TC.anuncios) TCA 
WHERE TCA.id_anuncio = TP.id_anuncio);


-- Consultar todos os anúncios de clientes e corretores que possuem área maior que a média de áreas
SELECT cpf, nome, area
FROM (
    SELECT T_corr.cpf, T_corr.nome, T_corr_A.area  FROM tb_corretor T_corr, table (T_corr.anuncios) T_corr_A
    UNION ALL
    SELECT T_cli.cpf, T_cli.nome, T_cli_A.area FROM tb_cliente T_cli, table (T_cli.anuncios) T_cli_A 
) where area > (SELECT AVG(area) FROM (
    SELECT T_corr_A.area  FROM tb_corretor T_corr, table (T_corr.anuncios) T_corr_A
    UNION ALL
    SELECT T_cli_A.area FROM tb_cliente T_cli, table (T_cli.anuncios) T_cli_A 
));