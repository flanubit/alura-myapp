#!/bin/bash
# Script: monitoramento-logs.sh
# Autor: Flanubio Ribeiro
# Descrição: Projeto do curso de nivelamento DevOps da Alura. O script faz o proessamento de arquivos de logs.
# Uso: ./monitoramento-logs.sh

LOG_DIR="../"
DIVISOR=$(printf '%.0s-' {1..50})
ARQUIVO_DIR="../logs-processados/"

mkdir -p $ARQUIVO_DIR

echo "Verificando logs no diretório: $LOG_DIR"

find $LOG_DIR -name "*.log" -print0 | while IFS= read -r -d '' arquivo; do
	grep "ERROR" $arquivo > "${arquivo}.filtrado"
	grep "SENSITIVE_DATA" $arquivo >> "${arquivo}.filtrado"

	sed -i 's/User password is .*/User password is REDACTED/g' "${arquivo}.filtrado"
	sed -i 's/User password reset request with token .*/User password reset request with token REDACTED/g' "${arquivo}.filtrado"
	sed -i 's/API key leaked: .*/API key leaked: REDACTED/g' "${arquivo}.filtrado"
	sed -i 's/User credit card last four digits: .*/User credit card last four digits: REDACTED/g' "${arquivo}.filtrado"
	sed -i 's/User session initiated with token: .*/User session initiated with token: REDACTED/g' "${arquivo}.filtrado"

	sort "${arquivo}.filtrado" -o "${arquivo}.filtrado"

	uniq "${arquivo}.filtrado" > "${arquivo}.unico"

	num_palavras=$(wc -w < "${arquivo}.unico")
	num_linhas=$(wc -l < "${arquivo}.unico")

	nome_arquivo=$(basename "${arquivo}.unico")

	echo "Arquivo: $nome_arquivo" >> status-logs-$(date +%F).txt
	echo "Nº de linhas: $num_linhas" >> status-logs-$(date +%F).txt
	echo "Nº de palavras: $num_palavras" >> status-logs-$(date +%F).txt
	echo $DIVISOR >> status-logs-$(date +%F).txt


	if [[ "$nome_arquivo" == *frontend* ]]; then
		sed 's/^/[FRONTEND] /g' "${arquivo}.unico" >> "${ARQUIVO_DIR}logs-combinados-$(date +%F).log"
	elif [[ "$nome_arquivo" == *backend* ]]; then
		sed 's/^/[BACKEND] /g' "${arquivo}.unico" >> "${ARQUIVO_DIR}logs-combinados-$(date +%F).log"
	else
		cat "${arquivo}.unico" >> "${ARQUIVO_DIR}logs-combinados-$(date +%F).log"
	fi
done

sort -k2 "${ARQUIVO_DIR}logs-combinados-$(date +%F).log" -o "${ARQUIVO_DIR}logs-combinados-$(date +%F).log"
