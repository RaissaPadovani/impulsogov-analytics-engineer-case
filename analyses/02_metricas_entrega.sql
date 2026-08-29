-- Números solicitados no entregável do case.
-- para executar:
-- dbt show --inline "select * from {{ ref('lista_nominal_hipertensao') }} limit 5" --profiles-dir .


with base as (

    select *
    from {{ ref('lista_nominal_hipertensao') }}

),

metrics as (

    select
        'Consulta' as boa_pratica,
        status_consulta as status,
        count(*) as pessoas
    from base
    group by status_consulta

    union all

    select
        'Aferição de pressão arterial' as boa_pratica,
        status_pressao as status,
        count(*) as pessoas
    from base
    group by status_pressao

    union all

    select
        'Peso e altura' as boa_pratica,
        status_peso_altura as status,
        count(*) as pessoas
    from base
    group by status_peso_altura

)

select *
from metrics
order by boa_pratica, status
