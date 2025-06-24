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

## Create
http://192.168.128.91:1880/create/bag
Ex:
{
    "name": "gustavo bag",
    "hour": "16:40",
    "state": "emprestada",
    "type": "1"
}

## Get All
http://192.168.128.91:1880/bags

## Show
Not made yet

## Delete
http://192.168.128.91:1880/delete/bag
Ex:
{
    "_id": "5b2da77729da3fdfbd9760a11250e884",
    "_rev": "1-48486e9e63045b051122e5117195ccb0"
}

## Update
http://192.168.128.91:1880/update/bag


