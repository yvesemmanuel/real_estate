DROP TABLE pessoa;
DROP TABLE cliente;
DROP TABLE gerente;
DROP TABLE corretor;
DROP TABLE anuncio;
DROP TABLE telefone_pessoa;
DROP TABLE telefone_gerente;
DROP TABLE endereco;
DROP TABLE endereco_anuncio;
DROP TABLE endereco_gerente;
DROP TABLE contatos;
DROP TABLE proposta;
DROP TABLE avaliar;
DROP TABLE agendar_visita;
DROP TABLE dado_bancario;
DROP TABLE proposta;
DROP TABLE fotos_imovel;
DROP SEQUENCE anuncio_sequence_seq;


CREATE TABLE pessoa (cpf VARCHAR2(14),
                     nome VARCHAR2(30) NOT NULL,
                     email VARCHAR2(30) NOT NULL,
                     descricao VARCHAR2(100) NOT NULL,
                     ranking NUMBER,
                     avaliacao NUMBER,
                     CONSTRAINT pessoa_pk PRIMARY KEY (cpf),
                     CONSTRAINT pessoa_cpf_ck CHECK (cpf LIKE ('___.___.___-__')));

CREATE TABLE gerente (cpf_gerente VARCHAR2(14),
                      nome VARCHAR2(30) NOT NULL,
                      email VARCHAR2(30) NOT NULL,
                      CONSTRAINT gerente_pk PRIMARY KEY (cpf_gerente),
                      CONSTRAINT gerente_cpf_gerente_ck CHECK (cpf_gerente LIKE ('___.___.___-__')));

CREATE TABLE corretor (cpf_corretor VARCHAR2(14),
                       nome VARCHAR2(50) NOT NULL,
                       email VARCHAR2(30) NOT NULL,
                       descricao VARCHAR2(100),
                       ranking NUMBER,
                       creci VARCHAR2(8) NOT NULL,
                       cpf_comitente VARCHAR2(14),
                       CONSTRAINT corretor_pk PRIMARY KEY (cpf_corretor),
                       CONSTRAINT corretor_cpf_comitente_fk FOREIGN KEY (cpf_comitente) REFERENCES gerente(cpf_gerente),
                       CONSTRAINT corretor_cpf_ck CHECK (cpf_corretor LIKE ('___.___.___-__')),
                       CONSTRAINT cliente_cpf_comitente_ck CHECK (cpf_comitente LIKE ('___.___.___-__')));

CREATE TABLE cliente (cpf_cliente VARCHAR2(14) NOT NULL,
                      nome VARCHAR2(50) NOT NULL,
                      email VARCHAR2(40) NOT NULL,
                      descricao VARCHAR2(100) NOT NULL,
                      ranking NUMBER,
                      cpf_auxiliador VARCHAR2(14),
                      CONSTRAINT cliente_pk PRIMARY KEY (cpf_cliente),
                      CONSTRAINT cliente_cpf_auxiliador_fk FOREIGN KEY (cpf_auxiliador) REFERENCES corretor(cpf_corretor),
                      CONSTRAINT cliente_cpf_ck CHECK (cpf_cliente LIKE ('___.___.___-__')),
                      CONSTRAINT cliente_cpf_auxiliador_ck CHECK (cpf_auxiliador LIKE ('___.___.___-__')));

CREATE TABLE anuncio (id NUMBER NOT NULL,
                      cpf_pessoa VARCHAR2(14) NOT NULL,
                      CONSTRAINT anuncio PRIMARY KEY (id),
                      CONSTRAINT anuncio_cpf_pessoa_fk FOREIGN KEY (cpf_pessoa) REFERENCES pessoa(cpf),
                      CONSTRAINT anuncio_cpf_pessoa_ck CHECK (cpf_pessoa LIKE ('___.___.___-__')));

CREATE TABLE telefone_pessoa (cpf_pessoa VARCHAR2(14) NOT NULL,
                              numero VARCHAR2(16),
                              CONSTRAINT telefone_pessoa_pk PRIMARY KEY (numero),
                              CONSTRAINT telefone_pessoa_cpf_pessoa_fk FOREIGN KEY (cpf_pessoa) REFERENCES pessoa(cpf),
                              CONSTRAINT telefone_pessoa_cpf_pessoa_ck CHECK (cpf_pessoa LIKE ('___.___.___-__')),
                              CONSTRAINT telefone_pessoa_numero_ck CHECK (numero LIKE ('(__) _ ____-____')));

CREATE TABLE telefone_gerente (cpf_gerente VARCHAR2(14) NOT NULL,
                               numero VARCHAR2(16),
                               CONSTRAINT telefone_gerente_pk PRIMARY KEY (cpf_gerente, numero),
                               CONSTRAINT telefone_gerente_cpf_gerente_fk FOREIGN KEY (cpf_gerente) REFERENCES gerente(cpf_gerente),
                               CONSTRAINT telefone_gerente_cpf_gerente_ck CHECK (cpf_gerente LIKE ('___.___.___-__')),
                               CONSTRAINT telefone_gerente_numero_ck CHECK (numero LIKE ('(__) _ ____-____')));

CREATE TABLE endereco (cpf_pessoa VARCHAR2(14) NOT NULL,
                       rua VARCHAR2(50),
                       numero NUMBER NOT NULL,
                       bairro VARCHAR2(50),
                       cep VARCHAR2(9),
                       cidade VARCHAR2(50),
                       estado VARCHAR2(50),
                       CONSTRAINT endereco_pk PRIMARY KEY (cpf_pessoa, cep),
                       CONSTRAINT endereco_cpf_pessoa_ck CHECK (cpf_pessoa LIKE ('___.___.___-__')),
                       CONSTRAINT endereco_cep_ck CHECK (cep LIKE ('_____-___')),
                       CONSTRAINT endereco_cpf_pessoa_fk FOREIGN KEY (cpf_pessoa) REFERENCES pessoa(cpf));

CREATE TABLE endereco_gerente (cpf_gerente VARCHAR2(14) NOT NULL,
                               rua VARCHAR2(50),
                               numero NUMBER NOT NULL,
                               bairro VARCHAR2(50),
                               cep VARCHAR2(9),
                               cidade VARCHAR2(50),
                               estado VARCHAR2(50),
                               CONSTRAINT endereco_gerente_pk PRIMARY KEY (cpf_gerente, cep),
                               CONSTRAINT endereco_gerente_cpf_gerente_fk FOREIGN KEY (cpf_gerente) REFERENCES gerente(cpf_gerente),
                               CONSTRAINT endereco_gerente_cpf_gerente_ck CHECK (cpf_gerente LIKE ('___.___.___-__')),
                               CONSTRAINT endereco_gerente_cep_ck CHECK (cep LIKE ('_____-___')));

CREATE TABLE endereco_anuncio (id_anuncio NUMBER NOT NULL,
                               rua VARCHAR2(50),
                               numero NUMBER NOT NULL,
                               bairro VARCHAR2(50),
                               cep VARCHAR2(9),
                               cidade VARCHAR2(50),
                               CONSTRAINT endereco_anuncio_pk PRIMARY KEY (id_anuncio, cep),
                               CONSTRAINT endereco_anuncio_cep_ck CHECK (cep LIKE ('_____-___')),
                               CONSTRAINT endereco_anuncio_id_anuncio_fk FOREIGN KEY (id_anuncio) REFERENCES anuncio(id));

CREATE TABLE dado_bancario (cpf_pessoa VARCHAR2(14) NOT NULL,
                            banco NUMBER(10) NOT NULL,
                            agencia NUMBER(10) NOT NULL,
                            conta VARCHAR2(10) NOT NULL,
                            CONSTRAINT dado_bancario_pk PRIMARY KEY (cpf_pessoa, conta),
                            CONSTRAINT dado_bancario_cpf_pessoa_fk FOREIGN KEY (cpf_pessoa) REFERENCES pessoa(cpf),
                            CONSTRAINT dado_bancario_cpf_pessoa_ck CHECK (cpf_pessoa LIKE ('___.___.___-__')),
                            CONSTRAINT dado_bancario_conta_ck CHECK (conta LIKE ('________-_')));

CREATE TABLE anuncio_info (id_anuncio NUMBER NOT NULL,
                           tipo_anuncio VARCHAR2(50) NOT NULL,
                           tipo_imovel VARCHAR2(50) NOT NULL,
                           valor NUMBER NOT NULL,
                           area NUMBER NOT NULL,
                           qtd_quartos NUMBER NOT NULL,
                           comissao NUMBER NOT NULL,
                           descricao VARCHAR(150),
                           CONSTRAINT anuncio_pk PRIMARY KEY (id_anuncio),
                           CONSTRAINT tipo_anuncio_ck CHECK (tipo_anuncio IN ('Aluguel', 'Venda')),
                           CONSTRAINT tipo_imovel_ck CHECK (tipo_imovel IN ('Apartamento','Casa','Kitnet','Flat')),
                           CONSTRAINT anuncio_info_id_anuncio_fk FOREIGN KEY (id_anuncio) REFERENCES anuncio(id));
 
CREATE TABLE fotos_imovel (id_anuncio NUMBER NOT NULL,
                           imagem VARCHAR2(100) NOT NULL,
                           CONSTRAINT fotos_imovel_id_anuncio_fk FOREIGN KEY (id_anuncio) REFERENCES anuncio(id));

CREATE TABLE contatos (id_anuncio NUMBER NOT NULL,
                       num VARCHAR2(16) NOT NULL,
                       cpf_pessoa VARCHAR2(14) NOT NULL,
                       CONSTRAINT contatos_pk PRIMARY KEY (num),
                       CONSTRAINT contatos_id_anuncio_fk FOREIGN KEY (id_anuncio) REFERENCES anuncio(id),
                       CONSTRAINT contatos_cpf_pessoa_fk FOREIGN KEY (cpf_pessoa) REFERENCES pessoa(cpf),
                       CONSTRAINT contatos_cpf_pessoa_ck CHECK (cpf_pessoa LIKE ('___.___.___-__')),
                       CONSTRAINT contatos_num_ck CHECK (num LIKE ('(__) _ ____-____')));

CREATE TABLE proposta (id_anuncio NUMBER NOT NULL,
                       cpf_anunciante VARCHAR2(14),
                       cpf_cliente VARCHAR2(14),
                       data_proposta DATE NOT NULL,
                       data_pagamento DATE,
                       valor_pagamento NUMBER NOT NULL,
                       metodo_pagamento VARCHAR2(10),
                       status VARCHAR2(11) NOT NULL,
                       CONSTRAINT proposta_pk PRIMARY KEY (id_anuncio, cpf_anunciante, cpf_cliente),
                       CONSTRAINT proposta_cpf_anunciante_fk FOREIGN KEY (cpf_anunciante) REFERENCES pessoa(cpf),
                       CONSTRAINT proposta_cpf_cliente_fk FOREIGN KEY (cpf_cliente) REFERENCES cliente(cpf_cliente),
                       CONSTRAINT proposta_id_anuncio_fk FOREIGN KEY (id_anuncio) REFERENCES anuncio(id),
                       CONSTRAINT proposta_cpf_anunciante_ck CHECK (cpf_anunciante LIKE ('___.___.___-__')),
                       CONSTRAINT proposta_cpf_cliente_ck CHECK (cpf_cliente LIKE ('___.___.___-__')),
                       CONSTRAINT proposta_metodo_pagamento_ck CHECK (metodo_pagamento IN ('Dinheiro', 'Cartão', 'Boleto')),
                       CONSTRAINT proposta_status_ck CHECK (status IN ('Aceita', 'Recusada', 'Pendente')));

CREATE TABLE avaliar (cpf_avaliado VARCHAR2(14),
                      cpf_avaliador VARCHAR2(14),
                      avaliacao NUMBER NOT NULL,
                      data DATE NOT NULL,
                      CONSTRAINT avaliar_pk PRIMARY KEY (cpf_avaliado, cpf_avaliador),
                      CONSTRAINT avaliar_cpf_avaliado_fk FOREIGN KEY (cpf_avaliado) REFERENCES pessoa(cpf),
                      CONSTRAINT avaliar_cpf_avaliador_fk FOREIGN KEY (cpf_avaliador) REFERENCES pessoa(cpf),
                      CONSTRAINT avaliar_cpf_avaliado_ck CHECK (cpf_avaliado LIKE ('___.___.___-__')),
                      CONSTRAINT avaliar_cpf_avaliador_ck CHECK (cpf_avaliador LIKE ('___.___.___-__')));

CREATE TABLE agendar_visita (id_anuncio NUMBER NOT NULL,
                             cpf_pessoa VARCHAR2(14) NOT NULL,
                             cpf_cliente VARCHAR2(14) NOT NULL,
                             data DATE NOT NULL,
                             CONSTRAINT agendar_visita_pk PRIMARY KEY (id_anuncio, cpf_pessoa, cpf_cliente),
                             CONSTRAINT agendar_visita_id_anuncio_fk FOREIGN KEY (id_anuncio) REFERENCES anuncio(id),
                             CONSTRAINT agendar_visita_cpf_pessoa_fk FOREIGN KEY (cpf_pessoa) REFERENCES pessoa(cpf),
                             CONSTRAINT agendar_visita_cpf_cliente_fk FOREIGN KEY (cpf_cliente) REFERENCES cliente(cpf_cliente),
                             CONSTRAINT agendar_visita_cpf_pessoa_ck CHECK (cpf_pessoa LIKE ('___.___.___-__')),
                             CONSTRAINT agendar_visita_cpf_cliente_ck CHECK (cpf_cliente LIKE ('___.___.___-__')));


CREATE SEQUENCE anuncio_sequence_seq
    MINVALUE 1
    START WITH 1
    INCREMENT BY 1
    ORDER
    CACHE 50;