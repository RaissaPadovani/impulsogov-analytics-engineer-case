-- Falha se a flag de pendência estiver inconsistente com os três status.

select *
from {{ ref('lista_nominal_hipertensao') }}
where
    (
        status_consulta = 'Em dia'
        and status_pressao = 'Em dia'
        and status_peso_altura = 'Em dia'
        and st_possui_pendencia <> false
    )
    or
    (
        (
            status_consulta <> 'Em dia'
            or status_pressao <> 'Em dia'
            or status_peso_altura <> 'Em dia'
        )
        and st_possui_pendencia <> true
    )
