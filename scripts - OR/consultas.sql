/*
Decidi testar alguns métodos e fazer consultas básicas para atestar o funcionamento do código,
aqui estão alguns dos testes.
*/

DECLARE
    cliente tp_cliente;
BEGIN
SELECT VALUE(C) INTO cliente FROM tb_cliente C WHERE C.cpf = '146.463.678-97';
cliente.porcent_avaliacao(cliente.avaliacao);
END;

DECLARE
    cliente tp_cliente;
BEGIN
SELECT VALUE(C) INTO cliente FROM tb_cliente C WHERE C.cpf = '146.463.678-97';
cliente.display_address();
END;
/
DECLARE
    cliente tp_cliente;
BEGIN
SELECT VALUE(C) INTO cliente FROM tb_cliente C WHERE C.cpf = '146.463.678-97';
cliente.display_info();
END;

DECLARE
    corretor tp_corretor;
BEGIN
SELECT VALUE(C) INTO corretor FROM tb_corretor C WHERE C.cpf = '149.221.550-31';
corretor.display_info();
END;
/


SELECT * FROM tb_cliente C;
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

-- Consultar os imóveis localizados no Recife
SELECT T_CLI.nome, A.endereco.rua, A.endereco.bairro, T.*
FROM tb_cliente T_CLI, TABLE(T_CLI.anuncios) A, TABLE(T_CLI.telefone) T
WHERE A.endereco.cidade = 'Recife'
UNION
SELECT T_CORR.nome, A.endereco.rua, A.endereco.bairro, T.*
FROM tb_corretor T_CORR, TABLE(T_CORR.anuncios) A, TABLE(T_CORR.telefone) T
WHERE A.endereco.cidade = 'Recife';