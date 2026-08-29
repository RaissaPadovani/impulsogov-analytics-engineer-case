-- Silver / staging: tipagem técnica, deduplicação e abertura dos campos JSON.
-- O mesmo procedimento pode aparecer em transmissões diferentes.
-- Mantemos a versão recebida mais recentemente.

with source as (

    select
        nullif(trim(tabela), '')                              as tabela,
        nullif(trim(co_seq_fat_proced), '')                   as co_seq_fat_proced,
        try_cast(co_fat_cidadao_pec as bigint)               as co_fat_cidadao_pec,
        nullif(trim(co_proced), '')                           as co_proced,
        nullif(trim(ds_proced), '')                           as ds_proced,
        nullif(trim(nu_ine), '')                              as nu_ine,
        nullif(trim(no_equipe), '')                           as no_equipe,
        nullif(trim(no_profissional), '')                     as no_profissional,
        nullif(trim(nu_cbo), '')                              as nu_cbo,
        nullif(trim(no_cbo), '')                              as no_cbo,
        try_cast(dt_registro as date)                         as dt_registro,
        nullif(trim(qt_afericao_pressao_arterial), '')        as qt_afericao_pressao_arterial,
        nullif(trim(qt_glicemia), '')                         as qt_glicemia,
        try_cast(data_transmissao as date)                    as data_transmissao,
        nullif(trim(propriedades), '')                        as propriedades,
        nullif(trim(versao), '')                              as versao
    from {{ ref('br_procedimentos') }}

),

ranked as (

    select
        *,
        row_number() over (
            partition by co_seq_fat_proced
            order by data_transmissao desc, dt_registro desc
        ) as rn
    from source

),

deduplicated as (

    select * exclude (rn)
    from ranked
    where rn = 1

)

select
    *,
    json_extract_string(
        try_cast(propriedades as json),
        '$.pressao_arterial'
    )                                                         as pressao_arterial,
    try_cast(
        json_extract_string(try_cast(propriedades as json), '$.peso')
        as decimal(10, 2)
    )                                                         as peso,
    try_cast(
        json_extract_string(try_cast(propriedades as json), '$.altura')
        as decimal(10, 2)
    )                                                         as altura_cm
from deduplicated
