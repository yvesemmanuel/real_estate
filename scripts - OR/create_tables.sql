-- Pessoa (CPF, Nome, Email, Avaliação, Descrição)
CREATE OR REPLACE TYPE t_pessoa AS OBJECT(
    cpf VARCHAR2(14),
    nome VARCHAR2(30),
    email VARCHAR2(30),
    avaliacao NUMBER,
    descricao VARCHAR2(100)
);

-- Dados_Bancários (%CPF_Pessoa%, Banco, Agência, Conta)
CREATE OR REPLACE TYPE t_banco AS OBJECT(
    cpf VARCHAR2(14),
    banco NUMBER(10),
    agencia NUMBER(10),
    conta VARCHAR2(10)
);

-- Endereço_Pessoa (%CPF_Pessoa%, Número, %CEP%)
-- Endereço_Gerente (%CPF_Gerente%, Número, %CEP%)
CREATE OR REPLACE TYPE t_endereco_pessoal AS OBJECT(
    cpf VARCHAR2(14),
    numero NUMBER,
    cep VARCHAR2(9)
);

-- Endereços (CEP, Rua, Bairro, Cidade, Estado)
CREATE OR REPLACE TYPE t_local AS OBJECT(
    cep VARCHAR2(9),
    rua VARCHAR2(50),
    bairro VARCHAR2(50),
    cidade VARCHAR2(50),
    estado VARCHAR2(50)
);

-- Corretor (%CPF_Corretor%, #CRECI#, %CPF_Comitente%)
CREATE OR REPLACE TYPE t_corretor AS OBJECT(
    cpf VARCHAR2(14),
    nome VARCHAR2(30),
    email VARCHAR2(30),
    avaliacao NUMBER,
    descricao VARCHAR2(100)
    creci VARCHAR2(8),
    cpf_comitente VARCHAR2(14)
);

-- Cliente (%CPF_Cliente%, %CPF_Auxiliador%)
CREATE OR REPLACE TYPE t_cliente AS OBJECT(
    cpf VARCHAR2(14),
    nome VARCHAR2(30),
    email VARCHAR2(30),
    avaliacao NUMBER,
    descricao VARCHAR2(100)
    cpf_auxiliador VARCHAR2(14),
);

-- Anúncio (Cod_Anuncio, %CPF_Pessoa%,  Tipo de Anúncio, Tipo de Imóvel)
CREATE OR REPLACE TYPE t_anuncio AS OBJECT(
    cod_anuncio NUMBER,
    cpf VARCHAR2(14),
    tipo_anuncio VARCHAR2(50),
    tipo_imovel VARCHAR2(50)
)

-- Anúncio_Info (%Cod_Anuncio%, %CPF_Pessoa%, Valor, Área, Quantidade de Quartos, Comissão, Descrição)
CREATE OR REPLACE TYPE t_anuncio_info AS OBJECT(
    cod_anuncio NUMBER,
    cpf VARCHAR2(14),
    valor NUMBER,
    area NUMBER,
    qtd_quartos NUMBER,
    comissao NUMBER,
    descricao VARCHAR(150)
)

-- Fotos_Anúncio (Imagem, %Cod_Anuncio%)
CREATE OR REPLACE TYPE t_fotos_anuncio AS OBJECT(
    cod_anuncio NUMBER,
    imagem VARCHAR2(100)
)

-- Endereço_Anúncio (%Cod_Anuncio%, Número, %CEP%,)
CREATE OR REPLACE TYPE t_endereco_anuncio AS OBJECT(
    cod_anuncio NUMBER,
    numero NUMBER,
    cep VARCHAR2(9)
);

-- Gerente (CPF_Gerente, Nome, Email)
CREATE OR REPLACE TYPE t_gerente AS OBJECT(
    cpf VARCHAR2(14),
    nome VARCHAR2(30),
    email VARCHAR2(30),
);

-- Telefone_Pessoa (Telefone, %CPF_Pessoa%)
-- Telefone_Gerente (Telefone, %CPF_Gerente%)
CREATE OR REPLACE TYPE t_telefone AS OBJECT(
    cpf VARCHAR2(14),
    numero VARCHAR2(16)
);

-- Proposta (Valor, Status, Data, %Cod_Anuncio%, %CPF_Pessoa%, %CPF_Cliente%)
CREATE OR REPLACE TYPE t_proposta AS OBJECT(
    valor NUMBER,
    status VARCHAR2(8),
    data DATE,
    -- composta = cod_anuncio + cpf_cliente + cpf_pessoa
    cpf_cliente VARCHAR2(14),
    cpf_pessoa VARCHAR2(14)
    cod_anuncio NUMBER,
);

-- Revisões_Propostas (%CPF_Gerente%, %CPF_Cliente%, %CPF_Pessoa%, %Cod_Anuncio%, Data)
CREATE OR REPLACE TYPE t_revisoes AS OBJECT(
    cpf_gerente VARCHAR2(14),
    cpf_cliente VARCHAR2(14),
    cpf_pessoa VARCHAR2(14),
    cod_anuncio NUMBER,
    data DATE
);

-- Avaliar (%CPF_Avaliado%, %CPF_Avaliador%, Avaliação_Dada)
CREATE OR REPLACE TYPE t_avaliacao AS OBJECT(
    cpf_avaliado VARCHAR2(14),
    cpf_avaliador VARCHAR2(14)
    valor NUMBER,
);