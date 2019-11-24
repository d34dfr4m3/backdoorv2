## Backdoor.v2 
Então com grandes demandas vem grandes desafios e um deles é que estou no meio de um teste interno e quero utilizar um backdoor físico para diminuir os riscos de ser pego dentro da empresa, uma vez que a equipe em si não vai estar dentro da empresa e sim remota conectada em um backdoor físico. Técnicas como RogueAP poderiam ser adotadas também onde um dispositivo tem duas interfaces, uma conectada na rede alvo e outra geralmente wireless onde os atacantes se conectam BUT não é a ideia aqui(ainda).

Então a ideia é a seguinte, uma vez que o raspberry for plugado na rede via RJ45 e alimentado com energia, ele irá dar boot e então ele irá tentar obter IP via DHCP, caso ele consiga um IP válido, o equipamento irá tentar fechar um túnel utilizando SOCAT com o servidor de C&C, uma vez que o túnel for estabelecido, é só conectar via SSH no backdoor por dentro do túnel. Ao contrário da versão 1 do backdoor físico(https://diesec.home.blog/2017/12/17/raspberry-backdoor-fisico/)  onde eu utilizava a onion para conectar e na verdade era uma conexão ssh reversa dentro da onion, caso o equipamento fosse capturado as chaves do C&C seriam expostas à equipe de forense e eles poderiam utilizar as mesmas para conectar etc. Nessa nova versão a segurança do C&C é melhorada nesse aspecto uma vez que a conexão SSH parte do servidor para o backdoor e não o contrário, a unica conexão reversa que o backdoor faz ao C&C é a conexão do túnel do SOCAT. 

Bom, o grande desafio dessa treta vai ser conseguir sair da rede do alvo e conectar no C&C, acho que depois disso é só não fazer nenhuma merda que dispare a alerte o blueteam dos caras que geralmente bloqueiam o ponto de rede e vão fisicamente investigar, ai na pior das hipoteses eles vão encontrar um raspberry( se encontrar, porque pretendo implantar isso de um jeito macabro). 


So lets roll.

### Environment
Para esse projeto irei estar utilizando um raspberry pi 3+ com o sistema operacional Raspbian Buster Lite - Minimal image based on Debian Buster e um Sdcard de 16Gb

```
Version: September 2019
Release date: 2019-09-26
Kernel version: 4.19
Size: 435 MB
```
Download pode ser feito aqui: https://www.raspberrypi.org/downloads/raspbian/

### Configurando o Sistema
Posteriormente a instalação do sistema operacional que não irei abordar aqui, é recomendavel que algumas alterações no sistema sejam realizadas:

Adicionando um novo usuário: 

```
~# useradd -s /bin/bash -k /etc/skel/ -m -c RedTeamUser redteam
```

Alterando a senha do usuário redteam:

```
~# passwd redteam 
New password: 
Retype new password: 
passwd: password updated successfully
```

Alterando o hostname do sistema: 
```
~# echo 'server_2030' >  /etc/hostname
```

Adicionando o novo usuário ao grupo whell para execução do comando sudo:

```
~# usermod -aG sudo redteam
```

Bloqueando o usuário nativo do sistema: 
```
~# passwd -l pi
passwd: password expiry information changed.
```


### Realizando o Deploy no Raspberry:
Dê um clone  no repositório, no raspberry você irá precisar apenas da parte cliente. 

```
git clone 

```

Realize a instalação das dependências e etc executando o comando abaixo 

```
cd client
chmod +x install.sh
./install.sh
```

### Configurando o C&C
Dê um clone no repositório, no servidor você irá precisar apenas da parte do handler. 

```
git clone
```

Realize a instação das dependências:

```
cd handler
chmod +x install.sh
./install.sh
```

Então inicie o handler: 
``` 
./handler.sh start
```

Agora em teoria é só conectar seu raspberry em alguma rede ai e aguardar a conexão no C2, o raspberry irá tentar se conectar nas portas TCP 53,123,80,443 e UDP 53,123 à cada 2 minutos. 

No C&C, para verificar as portas abertas para conexão você pode utilizar o seguinte comando:
```
./handler.sh status
```


Repare que a conexão só vai ser estabelecida quando uma interface TUN subir em ambos os hosts. 


#### Tools 
Ferramentas que serão instaladas para agilizar a etapa dos ataques:
- Responder https://github.com/lgandx/Responder
- Impacket https://github.com/SecureAuthCorp/impacket
- enum4linux https://labs.portcullis.co.uk/tools/enum4linux/
- nmap


#### Extras:
E caralho, nunca na sua vida saia passando scan num ataque interno porquẽ se o malandro do blueteam tiver configurado triggers de detecção, você já era, tente explorar os serviços de forma natural na maneira que eles funcionam, não tente procurar por falhas conhecidas na rede porquẽ pode dar muito ruim. 

#### Links: 
- https://www.raspberrypi.org/downloads/raspbian/
