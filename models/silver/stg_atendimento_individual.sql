-- Silver / staging: tipagem técnica + deduplicação das retransmissões.
-- O mesmo identificador pode ser reenviado em transmissões diferentes.
-- Mantemos a versão recebida mais recentemente.

with source as (

    select
        nullif(trim(co_seq_fat_atd_ind), '')                  as co_seq_fat_atd_ind,
        try_cast(co_fat_cidadao_pec as bigint)               as co_fat_cidadao_pec,
        nullif(trim(atend_ind_classificacao), '')             as atend_ind_classificacao,
        nullif(trim(nu_ciap), '')                             as nu_ciap,
        nullif(trim(no_ciap), '')                             as no_ciap,
        nullif(trim(nu_cid), '')                              as nu_cid,
        nullif(trim(no_cid), '')                              as no_cid,
        nullif(trim(no_profissional), '')                     as no_profissional,
        nullif(trim(nu_cbo), '')                              as nu_cbo,
        nullif(trim(no_cbo), '')                              as no_cbo,
        nullif(trim(ds_local_atendimento), '')                as ds_local_atendimento,
        nullif(trim(nu_ine), '')                              as nu_ine,
        nullif(trim(no_equipe), '')                           as no_equipe,
        try_cast(dt_registro as date)                         as dt_registro,
        try_cast(data_transmissao as date)                    as data_transmissao,
        nullif(trim(propriedades), '')                        as propriedades,
        nullif(trim(versao), '')                              as versao
    from {{ ref('br_atendimento_individual') }}

),

ranked as (

    select
        *,
        row_number() over (
            partition by co_seq_fat_atd_ind
            order by data_transmissao desc, dt_registro desc
        ) as rn
    from source

)

select
    co_seq_fat_atd_ind,
    co_fat_cidadao_pec,
    atend_ind_classificacao,
    nu_ciap,
    no_ciap,
    nu_cid,
    no_cid,
    no_profissional,
    nu_cbo,
    no_cbo,
    ds_local_atendimento,
    nu_ine,
    no_equipe,
    dt_registro,
    data_transmissao,
    propriedades,
    versao
from ranked
where rn = 1
