-- Falha se alguma data clínica utilizada na Gold estiver posterior ao snapshot.

select *
from {{ ref('lista_nominal_hipertensao') }}
where dt_ultima_consulta > data_referencia
   or dt_ultima_pressao > data_referencia
   or dt_ultimo_peso_altura > data_referencia
