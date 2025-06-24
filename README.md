# Tarefas

## Estilização

## Integração
CRUD BAG
- Editar
- Remover mochila (_id, _rev)
- Listagem
- Registrar BAG - RFID
- Listar os últimos UIDs em tela e no select (fazer com o cartão de administrador)

## Modelagem
Strutura do POST
{
    "name": "gustavo bag",
    "hour": "16:40",
    "state": "emprestada",
    "type": “1”,
    “UID”: … da tag
}

Extra
- Notificacao*
- Coletar informação do Mac*
- Mockar Login **

# Endpoints

## Create with uid
http://192.168.128.91:1880/create/bag/uid
Ex:
{
    "hour": "16:40",
    "uid": "BD42A389"
}

## Get latest bags with uids
http://192.168.128.91:1880/bags/uids

## Create with all info
http://192.168.128.91:1880/create/bag
Ex:

{
    "name": "Jorge",
    "hour": "16:09",
    "state": "Interditada",
    "type": "Mochila",
    "uid": "BD42A389"
}

## Get all bags
http://192.168.128.91:1880/bags

## Get bag
http://192.168.128.91:1880/bags

## Show

Pesquisar de acordo com o id cb9610ff856f6d9578759514d55c973

http://127.0.0.1:1880/bag?_id=0cb9610ff856f6d9578759514d55c973

## Delete
http://192.168.128.91:1880/delete/bag
Ex:
{
    "_id": "5b2da77729da3fdfbd9760a11250e884",
    "_rev": "1-48486e9e63045b051122e5117195ccb0"
}

## Update

E preciso passar toda a info, atualizando so o atributo que for atualizado

{
    "name": "Jorge",
    "hour": "16:09",
    "state": "Interditada",
    "type": "Mochila",
    "uid": "BD42A389"
}

http://192.168.128.91:1880/update/bag

# Divisoes

Integração

Estilização

CRUD BAG
- Editar
- Remover mochila (_id, _rev)
- Listagem
- Registrar BAG - RFID
- Listar os últimos UIDs em tela e no select (fazer com o cartão de administrador)

Modelagem
Strutura do POST
{
    "name": "gustavo bag",
    "hour": "16:40",
    "state": "emprestada",
    "type": “1”,
    “UID”: … da tag
}

Extra
- Notificacao*
- Coletar informação do Mac*
- Mockar Login **

Ultima tag identificada



