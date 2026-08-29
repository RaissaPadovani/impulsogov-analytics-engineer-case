# Nota sobre uso de IA

Utilizei o **ChatGPT** como apoio ao longo do case, principalmente para discutir alternativas de modelagem, revisar regras de negócio, levantar edge cases, estruturar os modelos dbt e revisar a clareza dos textos dos entregáveis.

Aceitei sugestões quando consegui validá-las diretamente nos dados ou nas regras fornecidas. Exemplos: separar o pipeline em camadas Bronze/Silver/Intermediate/Gold, deduplicar registros pela transmissão mais recente, manter a data de referência fixa em 01/08/2026 e documentar explicitamente decisões ambíguas, como o tratamento de “HIPERTENSÃO - CONDIÇÃO RESOLVIDA”.

Também corrigi propostas da IA após validação. Um exemplo concreto foi o contrato inicial da tabela Gold: a primeira versão tratava `no_cidadao` como obrigatório e incluía um teste `not_null`. Ao executar `dbt build`, o teste falhou para **9 cidadãos elegíveis sem nome**. Em vez de excluir essas pessoas ou forçar um valor artificial, revisei a decisão: mantive os registros na Lista Nominal, deixei `no_cidadao` como nullable e criei a flag `st_nome_ausente`. O erro ficou evidente porque os testes automatizados contradisseram a suposição inicial.

Também revisei resultados de profiling e regras diretamente nos CSVs antes de incorporar qualquer sugestão da IA. Assim, a ferramenta foi usada como apoio de raciocínio e revisão, não como fonte de verdade para os números ou para as decisões finais.
