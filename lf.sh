#!/bin/bash

<<coment
Autor: Lucas Jeronimo da Silva
E-mail: l.jeronimo@outlook.com.br
Manutenção: Lucas Jeronimo da Silva - 2023-03-15
#################################### OBJETIVO ###########################################################
- Temos um script que visa o failover entre dois links (Wi-Fi), quando um cai o outro assume.
#################################### HISTORICO ##########################################################   
	Major Release v0.3, Lucas Jeronimo:
		2023-03-14 v0.1 - Versão inicial, temos o failover por ora é executado em outro bash e não fica em backgroud;
		2023-03-15 v0.2 - Inplementado a execução em background, logando também apenas mensagens de desconexão e reconexão em "lf.log".
		2023-03-15 v0.3 - Desta vez um pouco menos "burro", agora ele escaneia as redes e caso não seja a minha ele encerra o programa.
coment

ssid_primario="TIM_JERONIMO_5G"
senha_primaria="!mgqz9JuVws"

ssid_secundario="VT_JERONIMO_5G"
senha_secundaria="pRezey4d-I9rifR"

conectar_rede() {
    ssid=$1
    senha=$2
    echo "$(date) - Conectando à rede $ssid..."
    nmcli dev wifi connect "$ssid" password "$senha"
}

if ! iwlist wlp0s20f3 scan | grep -qE "(ESSID:\"${ssid_primario}\"|ESSID:\"${ssid_secundario}\")"
then
	echo "$(date) - Nenhuma das redes está disponível. Saindo..."
	exit 1

fi

echo "$(date) - Iniciado..."

while true
do
	ping -c 1 8.8.8.8 > /dev/null
	if [ $? -eq 0 ]
	then
		sleep 25
	else
		echo "$(date) - A conexão com a rede falhou."
		conectar_rede "$ssid_secundario" "$senha_secundaria"
		sleep 5
		ping -c 1 8.8.8.8  > /dev/null
	
		if [ $? -eq 0 ]
		then
			echo "$(date) - Conexão com a rede secundária estabelecida."
		else
			echo "$(date) - Não foi possível conectar à rede secundária."
			echo "$(date) - Conectando novamente a rede primária."
			conectar_rede "$ssid_primario" "$senha_primaria"
			sleep 25 
		fi
	fi
done &
