-- Silver / staging: tipagem técnica do cadastro de cidadãos.
-- Não aplicamos aqui regras de elegibilidade para hipertensão.

select
    try_cast(co_fat_cidadao_pec as bigint)                           as co_fat_cidadao_pec,
    nullif(trim(no_cidadao), '')                                     as no_cidadao,
    try_cast(dt_registro_nascimento as date)                         as dt_registro_nascimento,
    nullif(trim(ds_sexo), '')                                        as ds_sexo,
    nullif(trim(nu_cns), '')                                         as nu_cns,
    nullif(trim(nu_cpf_cidadao), '')                                 as nu_cpf_cidadao,
    nullif(trim(nu_telefone_celular), '')                            as nu_telefone_celular,
    try_cast(st_faleceu as smallint)                                 as st_faleceu,
    try_cast(dt_ultima_atualizacao_cidadao as timestamp)             as dt_ultima_atualizacao_cidadao,
    try_cast(st_diabetes_diagnosticada as smallint)                  as st_diabetes_diagnosticada,
    try_cast(st_hipertensao_diagnosticada as smallint)               as st_hipertensao_diagnosticada,
    nullif(trim(nu_ine), '')                                         as nu_ine,
    nullif(trim(no_equipe), '')                                      as no_equipe,
    try_cast(data_ultimo_atend_individual as date)                   as data_ultimo_atend_individual,
    nullif(trim(equipe_ine_atendimento), '')                         as equipe_ine_atendimento,
    nullif(trim(equipe_nome_atendimento), '')                        as equipe_nome_atendimento,
    try_cast(nu_atend_ubs_ultimos_12_meses as bigint)                as nu_atend_ubs_ultimos_12_meses,
    try_cast(data_transmissao as date)                               as data_transmissao
from {{ ref('br_cidadao_pec') }}
