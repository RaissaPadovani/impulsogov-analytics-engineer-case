-- Camada Bronze: espelho do CSV bruto.
-- all_varchar=true evita perda de zeros à esquerda em identificadores como CNS/CPF/INE.

select *
from read_csv_auto(
    '{{ var("data_path") }}/cidadao_pec.csv',
    header = true,
    all_varchar = true
)
