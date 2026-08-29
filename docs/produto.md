# Lista Nominal de Hipertensão — regras e decisões para Produto

**Data de referência:** 01/08/2026  
**Resultado do snapshot:** 323 pessoas na Lista Nominal

## 1. Quem aparece na lista

A tabela tem **uma linha por cidadão**. A pessoa entra na Lista Nominal quando existe, em qualquer momento do histórico até a data de referência, um atendimento individual em que hipertensão foi registrada como condição avaliada por médico ou enfermeiro. Não aplicamos uma janela de tempo ao diagnóstico, pois hipertensão é tratada como condição crônica nas regras do case

A pessoa deixa de ser elegível quando está registrada como falecida ou quando o estado mais recente da condição é **“HIPERTENSÃO - CONDIÇÃO RESOLVIDA”**

### Decisão sobre condição resolvida

Foi encontrada uma situação ambígua relevante: há pessoas com uma condição marcada como resolvida e um novo registro de hipertensão em data posterior

- **Alternativa descartada:** excluir definitivamente qualquer pessoa que já tenha tido uma condição resolvida
- **Regra adotada:** considerar o **evento mais recente** entre “HIPERTENSÃO” e “HIPERTENSÃO - CONDIÇÃO RESOLVIDA”.
- **Motivo:** um novo registro de hipertensão posterior à resolução representa uma informação clínica mais recente e deve permitir que a pessoa volte ao acompanhamento
- **Impacto:** evita retirar da lista pessoas que voltaram a ter hipertensão registrada após uma resolução anterior

## 2. Como são calculadas as boas práticas

Todas as janelas são calculadas em relação ao snapshot de **01/08/2026**, e não à data em que o pipeline for executado.

| Boa prática | Regra adotada |
|---|---|
| **Consulta** | Último atendimento individual realizado por médico ou enfermeiro. Está **Em dia** se ocorreu nos últimos 6 meses |
| **Aferição de pressão arterial** | Última aferição realizada por médico, enfermeiro ou técnico/auxiliar de enfermagem. Está **Em dia** se ocorreu nos últimos 6 meses |
| **Peso e altura** | Último registro em que **peso e altura estão presentes no mesmo registro/dia**, realizado por profissional habilitado. Está **Em dia** se ocorreu nos últimos 12 meses |

Para as três práticas:

- **Em dia:** o registro válido mais recente está dentro da janela
- **Atrasada:** existe registro válido no histórico, mas o mais recente está fora da janela
- **Nunca realizada:** não existe registro válido dessa prática no histórico

Registros feitos por qualquer profissional habilitado da APS são considerados; não é necessário que tenham sido realizados pela equipe de vínculo da pessoa

## 3. Outras decisões adotadas

### Eventos posteriores ao snapshot

Foram encontrados atendimentos e procedimentos com datas posteriores a 01/08/2026

- **Alternativa descartada:** considerar todos os registros existentes nos arquivos
- **Regra adotada:** eventos clínicos posteriores à data de referência são ignorados
- **Impacto:** evita usar informação que ainda não deveria existir no retrato apresentado pela tela

### Dados cadastrais inválidos ou ausentes

Foram identificados cidadãos elegíveis com data de nascimento futura e **9 pessoas sem nome preenchido**

Não excluímos essas pessoas da lista, porque uma inconsistência cadastral não deve esconder uma necessidade de acompanhamento. Para nascimento inválido, idade e data exibível ficam indisponíveis. Para nome ausente, a tabela sinaliza explicitamente o problema por meio de uma flag de qualidade
### Equipe

Usamos o **INE da equipe de vínculo** do cadastro do cidadão como referência da equipe na Lista Nominal. O INE é a chave estável; o nome da equipe é um atributo de exibição e pode sofrer variações de grafia nas fontes de eventos

## 4. Limitações

**Microárea.** O protótipo prevê informação/filtro de microárea, mas nenhuma das três fontes fornecidas contém esse atributo. Por isso, a tabela entregue não suporta esse filtro. Não foi inferido nem criado um valor artificial

**Pressão arterial.** O campo documentado para o resultado da pressão veio sem preenchimento nos registros fornecidos. O valor utilizado está disponível no campo estruturado `propriedades`. A tela pode ser alimentada com esse valor, mas recomendamos alinhar o contrato da origem antes de considerar esse comportamento definitivo em produção

**Dados cadastrais incompletos.** Casos sem nome ou com data de nascimento inválida permanecem na população e precisam de tratamento de apresentação no produto

## 5. Recomendações

1. **Disponibilizar microárea na camada de origem/analítica** antes de habilitar o filtro correspondente no produto.
2. **Definir um fallback de interface para cadastro incompleto**, especialmente nome ausente, sem remover a pessoa da lista
3. **Formalizar o contrato do valor de pressão arterial**, definindo qual campo é a fonte oficial e adicionando monitoramento de completude
4. **Expor estados de qualidade de dados de forma controlada**, para que problemas cadastrais possam ser corrigidos sem afetar silenciosamente a população acompanhada
