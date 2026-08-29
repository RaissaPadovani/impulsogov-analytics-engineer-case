-- Camada Bronze: espelho do CSV bruto.

select *
from read_csv_auto(
    '{{ var("data_path") }}/procedimentos.csv',
    header = true,
    all_varchar = true
)
